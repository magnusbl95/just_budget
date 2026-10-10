import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'storage_service.dart';

enum SyncConflictResolution { keepLocal, keepCloud }

class FirebaseCloudSyncService {
  final FirebaseFirestore _firestore;
  final StorageService _storage;
  final Future<void> Function() _reloadRepositories;
  final ValueNotifier<String?> status = ValueNotifier(null);

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  DocumentReference<Map<String, dynamic>>? _document;
  Map<String, dynamic>? _lastSyncedSnapshot;
  Future<void> _writeQueue = Future<void>.value();
  Future<void> _cloudApplyQueue = Future<void>.value();
  int _connectionGeneration = 0;

  FirebaseCloudSyncService({
    required FirebaseFirestore firestore,
    required StorageService storage,
    required Future<void> Function() reloadRepositories,
  })  : _firestore = firestore,
        _storage = storage,
        _reloadRepositories = reloadRepositories;

  Future<bool> connect(
    String userId, {
    required Future<SyncConflictResolution?> Function() resolveConflict,
  }) async {
    await disconnect();
    final generation = _connectionGeneration;
    final document = _firestore.collection('users').doc(userId);
    final cloudDocument = await document.get();
    if (generation != _connectionGeneration) return false;
    final localSnapshot = _storage.exportSnapshot();
    final cloudSnapshot = cloudDocument.data()?['snapshot'];

    if (cloudDocument.exists && cloudSnapshot is! Map<String, dynamic>) {
      throw StateError('The saved Firebase budget has an invalid format.');
    }

    if (cloudSnapshot is Map<String, dynamic>) {
      if (_storage.hasMeaningfulLocalData &&
          !_snapshotsEqual(localSnapshot, cloudSnapshot)) {
        final resolution = await resolveConflict();
        if (resolution == null || generation != _connectionGeneration) {
          return false;
        }
        if (resolution == SyncConflictResolution.keepLocal) {
          await document.set({
            'snapshot': localSnapshot,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          if (generation != _connectionGeneration) return false;
          _lastSyncedSnapshot = localSnapshot;
        } else {
          await _applyCloudSnapshot(cloudSnapshot, generation);
          if (generation != _connectionGeneration) return false;
        }
      } else {
        await _applyCloudSnapshot(cloudSnapshot, generation);
        if (generation != _connectionGeneration) return false;
      }
    } else {
      await document.set({
        'snapshot': localSnapshot,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (generation != _connectionGeneration) return false;
      _lastSyncedSnapshot = localSnapshot;
    }

    if (generation != _connectionGeneration) return false;
    _document = document;
    _storage.setChangeListener(() {
      unawaited(_uploadLocalSnapshot());
    });
    _subscription = document.snapshots().listen(
      (snapshot) => _handleCloudSnapshot(snapshot, generation),
      onError: (Object error) {
        if (generation == _connectionGeneration) {
          status.value = 'Cloud sync failed: $error';
        }
      },
    );
    status.value = 'Cloud sync is on.';
    return true;
  }

  Future<void> disconnect() async {
    _storage.setChangeListener(null);
    _connectionGeneration++;
    final subscription = _subscription;
    _subscription = null;
    _document = null;
    _lastSyncedSnapshot = null;
    _writeQueue = Future<void>.value();
    _cloudApplyQueue = Future<void>.value();
    status.value = null;
    await subscription?.cancel();
  }

  Future<void> _applyCloudSnapshot(
    Map<String, dynamic> snapshot,
    int generation,
  ) async {
    if (generation != _connectionGeneration) return;
    await _storage.applySnapshot(snapshot);
    if (generation != _connectionGeneration) return;
    await _reloadRepositories();
    if (generation == _connectionGeneration) {
      _lastSyncedSnapshot = _storage.exportSnapshot();
    }
  }

  Future<void> _uploadLocalSnapshot() async {
    final document = _document;
    if (document == null) return;
    final generation = _connectionGeneration;

    _writeQueue = _writeQueue.then((_) async {
      if (generation != _connectionGeneration || document != _document) return;
      final snapshot = _storage.exportSnapshot();
      if (_snapshotsEqual(snapshot, _lastSyncedSnapshot)) return;
      await document.set({
        'snapshot': snapshot,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (generation == _connectionGeneration && document == _document) {
        _lastSyncedSnapshot = snapshot;
        status.value = 'Cloud sync is on.';
      }
    }).catchError((Object error) {
      if (generation == _connectionGeneration) {
        status.value = 'Cloud sync failed: $error';
      }
    });
    await _writeQueue;
  }

  void _handleCloudSnapshot(
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
    int generation,
  ) {
    if (generation != _connectionGeneration) return;
    final snapshot = documentSnapshot.data()?['snapshot'];
    if (snapshot is! Map<String, dynamic> ||
        _snapshotsEqual(snapshot, _lastSyncedSnapshot)) {
      return;
    }
    _cloudApplyQueue = _cloudApplyQueue.then((_) async {
      if (generation != _connectionGeneration ||
          _snapshotsEqual(snapshot, _lastSyncedSnapshot)) {
        return;
      }
      await _applyCloudSnapshot(snapshot, generation);
      if (generation == _connectionGeneration) {
        status.value = 'Cloud sync is on.';
      }
    }).catchError((Object error) {
      if (generation == _connectionGeneration) {
        status.value = 'Cloud sync failed: $error';
      }
    });
    unawaited(_cloudApplyQueue);
  }

  bool _snapshotsEqual(
    Map<String, dynamic>? first,
    Map<String, dynamic>? second,
  ) {
    if (first == null || second == null) return first == second;
    return jsonEncode(_sortMap(first)) == jsonEncode(_sortMap(second));
  }

  Object? _sortValue(Object? value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      return _sortMap(map);
    }
    if (value is List) return value.map(_sortValue).toList();
    return value;
  }

  Map<String, dynamic> _sortMap(Map<String, dynamic> map) {
    final keys = map.keys.toList()..sort();
    return {
      for (final key in keys) key: _sortValue(map[key]),
    };
  }
}
