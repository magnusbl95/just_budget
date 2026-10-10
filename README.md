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

### 2. One-time setup (web on Android, desktop, and iPhone)
The simplest first release is one hosted web app: open it in Chrome on Android
and desktop, and Safari on iPhone. Add it to each phone's Home Screen for an
app-like shortcut. This avoids installing native Android/iOS build tools;
native mobile builds can be added later.

Install [Flutter](https://docs.flutter.dev/get-started/install),
[Node.js](https://nodejs.org/), and the
[Firebase CLI](https://firebase.google.com/docs/cli). Open PowerShell at the
repository root and run:

```powershell
# Generate the web runner project (one time).
flutter create --platforms=web .
flutter pub get
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

Create a project in the [Firebase Console](https://console.firebase.google.com/),
then configure the web app and deploy the included access rules:

```powershell
flutterfire configure --project YOUR_FIREBASE_PROJECT_ID --platforms web
firebase deploy --only firestore:rules --project YOUR_FIREBASE_PROJECT_ID
```

The FlutterFire command creates the web app registration and generates
`lib/firebase_options.dart`; no copying API keys or `--dart-define` arguments
is needed. In the Firebase Console, enable **Email/Password** and **Google** in
**Authentication → Sign-in method**, add your Firebase Hosting domain under
**Authentication → Settings → Authorized domains**, and create a database in
**Firestore Database**. Google sign-in uses a full-page redirect so it works
in mobile browsers; users can choose Google or email/password in Settings.

For local development, run in Chrome. To publish, build and deploy to Firebase
Hosting:

```powershell
flutter run -d chrome
flutter build web --release
firebase deploy --only hosting --project YOUR_FIREBASE_PROJECT_ID
```

Open the `web.app` Hosting URL in Chrome on Android or Safari on iPhone. Use
**Add to Home Screen** in each phone's browser for an app-like shortcut. Native
Android and iOS builds can be configured later with
`flutterfire configure --platforms android,ios`; iOS builds require macOS and
Xcode.

Firebase stays optional until configured; without it, local storage continues
to work. A new account uploads existing local budget data. On a new device,
existing cloud data is restored; if both local and cloud budgets exist, the app
asks which copy to keep. Signing out keeps the local copy. Firestore access is
limited by `firestore.rules` to the signed-in owner of each user's data.

### 3. Run Automated Tests
```bash
flutter test
```

---

## 📄 License
MIT License.
