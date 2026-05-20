# PredictIt Jr.

A teaching app for CPTR 241: Object-Oriented Mobile Application Development.

You will build this app over 10 assignments. Each assignment adds one
capability. By the end you'll have a multi-screen prediction-market app
with mock authentication, camera and GPS integration, persistence, and
a small test suite.

---

## First-time setup

1. Install Flutter (3.24 or later): https://docs.flutter.dev/get-started/install
2. Verify your install: `flutter doctor`
3. From this folder, generate platform projects:
   ```
   flutter create .
   ```
4. Fetch dependencies:
   ```
   flutter pub get
   ```
5. Run on an emulator or device:
   ```
   flutter run
   ```

You should see a screen titled **Markets** with a "TODO (Assignment 1)"
message. That's correct — Assignment 1 is where you replace it.

---

## Project layout

```
lib/
  main.dart              App entry point.
  models/                Plain data classes (Market, Bet, User).
  data/                  Data-loading layer (MarketRepository).
  providers/             ChangeNotifier classes. Empty until A4.
  screens/               One file per route.
  widgets/               Reusable UI pieces.
  theme/                 App-wide colors and styles.
  utils/                 Formatting helpers.

assets/
  data/                  Mock JSON data (markets, users).
  images/                Market images.

test/                    Widget tests (you'll add more in A9).
```

### Conventions

- **Screens vs widgets.** If it's a destination you navigate to, it's a
  screen. If it's a piece reused inside screens, it's a widget. Keep
  files small; if a screen file exceeds ~150 lines, extract widgets.
- **Models are immutable.** All fields are `final`. To "change" a model,
  build a new one. You'll learn the `copyWith` pattern in A4.
- **No business logic in widgets.** Widgets describe UI. Computation
  belongs in models, repositories, or (from A4 onward) providers.

---

## Working through the assignments

Each assignment unlocks new dependencies in `pubspec.yaml`. The commented
lines there are a roadmap — uncomment as you go:

| Assignment | Package(s) added                                   |
|------------|----------------------------------------------------|
| A1         | `flutter_svg` (included; used for market images)   |
| A2         | (none)                                             |
| A3         | `go_router`, optionally `fl_chart`                 |
| A4         | `provider`                                         |
| A5         | (none — uses LayoutBuilder / MediaQuery)           |
| A6         | `shared_preferences`                               |
| A7         | (uses go_router redirects from A3)                 |
| A8         | `image_picker`, `geolocator`, `permission_handler` |
| A9         | (uses flutter_test)                                |
| A10        | `flutter_launcher_icons`, `flutter_native_splash`  |

After uncommenting, always run `flutter pub get`.

---

## A note on the mock data

`assets/data/users.json` contains plaintext passwords. This is the
**wrong** way to do authentication and is for teaching purposes only.
We'll discuss real auth (hashing, tokens, OAuth) in lecture during A7.

Don't ship anything that looks like this.

---

## Getting help

- Flutter docs: https://docs.flutter.dev
- Dart language tour: https://dart.dev/language
- DartPad (in-browser sandbox): https://dartpad.dev
- pub.dev (package registry): https://pub.dev

When asking for help on the course forum, include:
1. What you expected to happen.
2. What actually happened (full error message, not a screenshot).
3. The smallest code snippet that reproduces it.
