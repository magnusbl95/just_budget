import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/services/firebase_cloud_sync_service.dart';

class FirebaseAccountSection extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseCloudSyncService? cloudSync;

  const FirebaseAccountSection({
    super.key,
    required this.auth,
    required this.cloudSync,
  });

  @override
  State<FirebaseAccountSection> createState() => _FirebaseAccountSectionState();
}

class _FirebaseAccountSectionState extends State<FirebaseAccountSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  StreamSubscription<User?>? _authSubscription;
  bool _createAccount = false;
  bool _busy = false;
  String? _error;
  String? _connectedUid;

  @override
  void initState() {
    super.initState();
    final auth = widget.auth;
    if (auth != null) {
      _authSubscription = auth.authStateChanges().listen(
        (user) {
          if (user == null) {
            _connectedUid = null;
            unawaited(widget.cloudSync?.disconnect());
          } else if (_connectedUid != user.uid) {
            _connectedUid = user.uid;
            unawaited(_connect(user.uid));
          }
          if (mounted) setState(() {});
        },
        onError: (Object error) {
          if (mounted) setState(() => _error = 'Authentication failed: $error');
        },
      );
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<SyncConflictResolution?> _resolveConflict() {
    return showDialog<SyncConflictResolution>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Choose which budget to keep'),
        content: const Text(
          'This device and your Firebase account both have budget data. '
          'Keeping one will replace the other.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              SyncConflictResolution.keepLocal,
            ),
            child: const Text('Keep this device'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              SyncConflictResolution.keepCloud,
            ),
            child: const Text('Keep cloud data'),
          ),
        ],
      ),
    );
  }

  Future<void> _connect(String userId) async {
    final cloudSync = widget.cloudSync;
    if (cloudSync == null) return;
    if (mounted) {
      setState(() {
        _busy = true;
        _error = null;
      });
    }
    try {
      final connected = await cloudSync.connect(
        userId,
        resolveConflict: _resolveConflict,
      );
      if (!connected && mounted) {
        setState(() => _error = 'Sync canceled. Your local and cloud data were not changed.');
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Could not sync with Firebase: ${error.message ?? error.code}';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not sync with Firebase: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = widget.auth!;
      if (_createAccount) {
        await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = error.message ?? error.code);
    } on FirebaseException catch (error) {
      if (mounted) setState(() => _error = error.message ?? error.code);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email address first.');
      return;
    }
    try {
      await widget.auth!.sendPasswordResetEmail(email: email);
      if (mounted) {
        setState(() => _error = 'Password reset email sent.');
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = error.message ?? error.code);
    } on FirebaseException catch (error) {
      if (mounted) setState(() => _error = error.message ?? error.code);
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth!.signOut();
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = error.message ?? error.code);
    } on FirebaseException catch (error) {
      if (mounted) setState(() => _error = error.message ?? error.code);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.auth;
    if (auth == null || widget.cloudSync == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.cloud_off_outlined),
          title: Text('Firebase is not configured'),
          subtitle: Text(
            'Add your Firebase app settings to enable sign-in and cloud sync. '
            'Local storage remains available.',
          ),
        ),
      );
    }

    final user = auth.currentUser;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Signed in'),
                subtitle: Text(user.email ?? user.uid),
                trailing: TextButton(
                  onPressed: _busy ? null : _signOut,
                  child: const Text('Sign out'),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _busy ? null : () => _connect(user.uid),
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Sync now'),
                ),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: widget.cloudSync!.status,
                builder: (context, status, _) => Text(
                  status ?? 'Connecting to cloud…',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ] else ...[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null ||
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value.trim())) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Use at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: Text(
                        _busy
                            ? 'Please wait…'
                            : _createAccount
                                ? 'Create account'
                                : 'Sign in',
                      ),
                    ),
                    if (!_createAccount)
                      TextButton(
                        onPressed: _busy ? null : _sendPasswordReset,
                        child: const Text('Forgot password?'),
                      ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                                _createAccount = !_createAccount;
                                _error = null;
                              }),
                      child: Text(
                        _createAccount
                            ? 'Already have an account? Sign in'
                            : 'New here? Create an account',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
