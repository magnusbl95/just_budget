import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/services/firebase_cloud_sync_service.dart';
import '../../domain/enums/theme_preference.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../view_models/budget_view_model.dart';
import 'firebase_account_section.dart';
import 'manage_people_dialog.dart';

class SettingsScreen extends StatelessWidget {
  final AppSettingsViewModel settingsViewModel;
  final BudgetViewModel budgetViewModel;
  final FirebaseAuth? firebaseAuth;
  final FirebaseCloudSyncService? cloudSyncService;

  const SettingsScreen({
    super.key,
    required this.settingsViewModel,
    required this.budgetViewModel,
    required this.firebaseAuth,
    required this.cloudSyncService,
  });

  void _showCurrencyDialog(BuildContext context) {
    const currencies = [
      {'code': 'USD', 'symbol': r'$', 'name': r'US Dollar ($)'},
      {'code': 'EUR', 'symbol': '€', 'name': 'Euro (€)'},
      {'code': 'GBP', 'symbol': '£', 'name': 'British Pound (£)'},
      {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen (¥)'},
      {'code': 'CAD', 'symbol': r'$', 'name': r'Canadian Dollar (CAD $)'},
      {'code': 'AUD', 'symbol': r'$', 'name': r'Australian Dollar (AUD $)'},
      {'code': 'CHF', 'symbol': 'CHF', 'name': 'Swiss Franc (CHF)'},
      {'code': 'SEK', 'symbol': 'kr', 'name': 'Swedish Krona (kr)'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: 320,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final c = currencies[index];
              final isSelected = settingsViewModel.currencyCode == c['code'];

              return ListTile(
                dense: true,
                title: Text(c['name']!),
                trailing: isSelected ? const Icon(Icons.check_rounded, color: Colors.green) : null,
                onTap: () {
                  settingsViewModel.setCurrency(c['symbol']!, c['code']!);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all your budget items, budget lines, and reset the app to a clean state. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await budgetViewModel.clearAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data has been reset.')),
              );
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsViewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final settings = settingsViewModel.settings;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Appearance Section
              _buildSectionHeader('APPEARANCE (MATERIAL 3)', theme, colorScheme),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Mode',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      SegmentedButton<ThemePreference>(
                        segments: const [
                          ButtonSegment(
                            value: ThemePreference.system,
                            icon: Icon(Icons.brightness_auto_rounded),
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: ThemePreference.light,
                            icon: Icon(Icons.light_mode_rounded),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemePreference.dark,
                            icon: Icon(Icons.dark_mode_rounded),
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {settings.themePreference},
                        onSelectionChanged: (set) {
                          settingsViewModel.setThemePreference(set.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Regional & Currency
              _buildSectionHeader('CURRENCY & LOCALIZATION', theme, colorScheme),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.attach_money_rounded),
                  title: const Text('Display Currency'),
                  subtitle: Text('${settings.currencyCode} (${settings.currencySymbol})'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showCurrencyDialog(context),
                ),
              ),
              const SizedBox(height: 16),

              // Household / People
              _buildSectionHeader('HOUSEHOLD & PEOPLE', theme, colorScheme),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.group_outlined),
                  title: const Text('Manage People & Owners'),
                  subtitle: Text(
                    settings.people.isEmpty
                        ? 'No people defined'
                        : '${settings.people.length} people (${settings.people.map((p) => p.name).join(', ')})',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => ManagePeopleDialog(settingsViewModel: settingsViewModel),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Account / Cloud Sync
              _buildSectionHeader('ACCOUNT & CLOUD SYNC', theme, colorScheme),
              FirebaseAccountSection(
                auth: firebaseAuth,
                cloudSync: cloudSyncService,
              ),
              const SizedBox(height: 16),

              // Data Management
              _buildSectionHeader('DATA & STORAGE', theme, colorScheme),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                  title: const Text('Reset All Data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Delete all budget lines and items to start fresh'),
                  onTap: () => _confirmReset(context),
                ),
              ),
              const SizedBox(height: 32),

              // App Info
              Center(
                child: Column(
                  children: [
                    Text(
                      'Just Budget • v1.0.0',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distraction-free running budgets with Material 3',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
