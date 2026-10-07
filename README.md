# Just Budget 💰

> A modern, distraction-free personal finance app built with **Flutter** and strictly based on Google's **Material 3** design system.

[![Version](https://img.shields.io/badge/version-0.1.0-emerald.svg)](pubspec.yaml)
[![Design](https://img.shields.io/badge/design-Material_3-blue.svg)](https://m3.material.io/)
[![Platform](https://img.shields.io/badge/platform-Mobile%20%7C%20Web-purple.svg)](lib/)

---

## ✨ Features

- **Evergreen Running Budget:** Operates continuously without rigid start/end dates. It represents a living financial blueprint calculating real-time monthly and annual run-rates.
- **4 Financial Pillars:** Classifies every item as **Income**, **Living Expense**, **Savings Reserve**, or **Wealth Investment** instead of oversimplifying into basic in/out.
- **Timeline Normalization:** Supports **Daily**, **Weekly**, **Bi-Weekly**, **Monthly**, **Quarterly**, **Half-Yearly**, and **Yearly** items with automatic mathematical normalization to uniform monthly equivalents.
- **Household & Multi-Owner Equal Split:** Define household members in settings. Items shared between multiple people automatically split amounts equally.
- **Composite Hierarchy:**
  - **Standalone Items:** Appear directly as line items on the budget list.
  - **Budget Lines:** Group multiple items together, summarize their totals, and provide default owner inheritance to child items.
- **Strict Material 3 Design:** Built with dynamic color schemes seeded from Emerald (`#006C4C`), M3 tonal containers, and complete support for **Light Mode** and **Dark Mode**.
- **Responsive Layout:** Adaptive navigation using Material 3 `NavigationBar` on mobile and `NavigationRail` on web/desktop.
- **Clean Slate on First Launch:** No dummy or fake numbers. An intuitive onboarding wizard guides you to define your household members and initial items in seconds.

---

## 🏛️ Architecture

Organized with a layered **MVVM + Repository** architecture:

```text
lib/
├── domain/
│   ├── enums/            # Budget activities, timeline frequencies, theme preferences
│   └── models/           # BudgetItem, BudgetLine, Budget, Person, Category
├── data/
│   ├── services/         # StorageService (Cross-platform JSON / SharedPreferences)
│   └── repositories/     # BudgetRepository, CategoryRepository, SettingsRepository
├── view_models/          # BudgetViewModel, AppSettingsViewModel
├── theme/                # Material 3 Light & Dark themes
└── ui/
    ├── core/             # AdaptiveScaffold, ActivityBadge, TimelineBadge, PersonAvatarChip
    ├── setup/            # FirstLaunchSetupSheet (interactive prompt)
    ├── budget/           # BudgetScreen, BudgetLineCard, BudgetItemTile, AddBudgetItemSheet
    ├── insights/         # InsightsScreen (4-pillar distribution, household breakdown)
    └── settings/         # SettingsScreen (Theme, currency, people management)
```

---

## 🚀 Getting Started

### 1. Interactive Web Preview (Zero Dependencies)
You can run and test the interactive preview directly in your browser:
```powershell
powershell -ExecutionPolicy Bypass -File preview/serve.ps1 -Port 8085
```
Then visit `http://localhost:8085/`.

### 2. Flutter Application
Ensure Flutter is installed and run:
```bash
flutter pub get
flutter run
```

### 3. Run Automated Tests
```bash
flutter test
```

---

## 📄 License
MIT License.
