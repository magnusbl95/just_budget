import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/storage_service.dart';
import 'theme/app_theme.dart';
import 'ui/budget/budget_screen.dart';
import 'ui/core/adaptive_scaffold.dart';
import 'ui/insights/insights_screen.dart';
import 'ui/settings/settings_screen.dart';
import 'ui/setup/first_launch_setup_sheet.dart';
import 'view_models/app_settings_view_model.dart';
import 'view_models/budget_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  final storageService = await StorageService.initialize();

  final categoryRepo = CategoryRepository(storageService);
  await categoryRepo.init();

  final settingsRepo = SettingsRepository(storageService);
  await settingsRepo.init();

  final budgetRepo = BudgetRepository(storageService);
  await budgetRepo.init();

  final settingsViewModel = AppSettingsViewModel(settingsRepo);
  final budgetViewModel = BudgetViewModel(
    budgetRepo: budgetRepo,
    categoryRepo: categoryRepo,
  );

  runApp(JustBudgetApp(
    settingsViewModel: settingsViewModel,
    budgetViewModel: budgetViewModel,
  ));
}

class JustBudgetApp extends StatelessWidget {
  final AppSettingsViewModel settingsViewModel;
  final BudgetViewModel budgetViewModel;

  const JustBudgetApp({
    super.key,
    required this.settingsViewModel,
    required this.budgetViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsViewModel,
      builder: (context, _) {
        return MaterialApp(
          title: 'Just Budget',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(seedColor: settingsViewModel.settings.seedColorHex),
          darkTheme: AppTheme.dark(seedColor: settingsViewModel.settings.seedColorHex),
          themeMode: settingsViewModel.themeMode,
          home: MainNavigationShell(
            settingsViewModel: settingsViewModel,
            budgetViewModel: budgetViewModel,
          ),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AppSettingsViewModel settingsViewModel;
  final BudgetViewModel budgetViewModel;

  const MainNavigationShell({
    super.key,
    required this.settingsViewModel,
    required this.budgetViewModel,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // If first launch, show onboarding prompt after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.settingsViewModel.isFirstLaunchCompleted) {
        _showFirstLaunchPrompt();
      }
    });
  }

  void _showFirstLaunchPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FirstLaunchSetupSheet(
        settingsViewModel: widget.settingsViewModel,
        budgetViewModel: widget.budgetViewModel,
        onFinished: () {
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      BudgetScreen(
        budgetViewModel: widget.budgetViewModel,
        settingsViewModel: widget.settingsViewModel,
      ),
      InsightsScreen(
        budgetViewModel: widget.budgetViewModel,
        settingsViewModel: widget.settingsViewModel,
      ),
      SettingsScreen(
        settingsViewModel: widget.settingsViewModel,
        budgetViewModel: widget.budgetViewModel,
      ),
    ];

    return AdaptiveScaffold(
      selectedIndex: _currentIndex,
      onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
      destinations: const [
        AdaptiveScaffoldDestination(
          icon: Icons.account_balance_wallet_outlined,
          selectedIcon: Icons.account_balance_wallet_rounded,
          label: 'Budget',
        ),
        AdaptiveScaffoldDestination(
          icon: Icons.insights_outlined,
          selectedIcon: Icons.insights_rounded,
          label: 'Insights',
        ),
        AdaptiveScaffoldDestination(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings_rounded,
          label: 'Settings',
        ),
      ],
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }
}
