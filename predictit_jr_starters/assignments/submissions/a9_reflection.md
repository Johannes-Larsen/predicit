# A9 Reflection

The easiest tests to write were the `PortfolioModel` unit tests because `PortfolioModel` accepts a `PortfolioStorage` in its constructor. That clean seam let the tests use `FakePortfolioStorage` instead of touching `shared_preferences`, launching the app, or using an emulator. The harder parts were the widget tests around routing and cross-screen behavior, because they need a small harness with `MaterialApp`, `Provider`, and sometimes `go_router`; that difficulty shows why UI tests should stay focused and why logic should remain in models where possible.

## Test output

Run this before submitting:

```bash
flutter test
```

Paste your real terminal output into `assignments/submissions/a9_test_output.txt` before submitting.
