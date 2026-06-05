# A10 Reflection — PredictIt Jr.

## Causal graph / cross-arrows

- **A1 `MarketRepository` + `Market` model → A3 detail route.** Because the list already loaded real `Market` objects from a repository, A3 could make `/market/:id` look the market up by id instead of passing whole objects through routes.
- **A1 nullable market location (`mkt_003`) → A8 distance chips.** The early choice to model missing coordinates as `null` forced the A8 UI to treat absence as absence instead of pretending the market was at `(0,0)`.
- **A2 reusable `BetSheet` → A3 detail page → A4 portfolio.** Since the bet sheet took a `Market` and did not depend on the list screen, A3 could reuse it from detail, then A4 could connect it to `PortfolioModel` without rewriting the form.
- **A4 `PortfolioModel` mutation methods → A6 persistence.** Since every bet went through `placeBet`, persistence only needed to hook into the model instead of being scattered through the UI.
- **A6 injected `PortfolioStorage` → A9 fake storage tests.** Because the storage seam was injectable, the unit tests could use `FakePortfolioStorage` instead of real `shared_preferences`.
- **A7 `AuthModel` + router redirect → A8 protected `/create`.** Because authentication was centralized in the router, A8 could protect create-market by extending the existing route table instead of adding one-off checks in the screen.
- **A8 `PermissionService` seam → A9 testability.** Permission handling stayed out of widgets, which made the permission logic easier to reason about and fake later.
- **Theme/colorScheme use throughout → A10 dark theme.** Because screens mostly relied on `ThemeData` and Material defaults, dark mode could be added in `AppTheme` and `main.dart` instead of editing every screen.

## Prompt 1 — The through-line

The principle that stood out most to me was **structure makes the next thing cheap**. In A4, `PortfolioModel` seemed like extra work because a bet could have just been stored in the screen that created it. But making `placeBet` the single place where bets were added made A6 much easier: saving the portfolio only needed to happen at the end of that one method. The same decision also paid off in A9 because `PortfolioModel` could be constructed by itself with `FakePortfolioStorage`, so the tests did not need a running app or real disk storage. A1 also mattered more than it looked at the time. Having a real `Market` model and `MarketRepository` made later routing and detail screens cleaner, and `mkt_003` having `null` coordinates forced the A8 distance feature to handle missing data honestly. The pattern was that early structure was not just cleanliness; it changed how expensive later assignments were.

## Prompt 2 — The seam that paid off, and one that did not

The seam that paid off the most was the storage seam around `PortfolioStorage`. By keeping storage separate from `PortfolioModel`, A6 could add persistence without turning the model into a `shared_preferences` wrapper, and A9 could test portfolio behavior with a fake. That made the model easier to trust because the tests checked the actual business rules: bets, cash, reset, and save calls. A place where my structure was weaker was around location and create-market behavior in A8. The location refresh originally risked happening too early during widget build, which caused a Provider notification problem. If I started again, I would make startup data loading and optional device data clearly separate from the beginning: auth and portfolio can block startup because they define app state, but location should be requested after the first screen paints and should always be optional. That separation would have prevented the black-screen and build-time notification issues.

## Prompt 3 — The thing that is not Flutter

The non-Flutter idea I will remember most is that **client-side security checks are not real security**. In A7, the login screen and redirect pattern were useful architecture, but the actual credential check against `users.json` was deliberately fake. Anyone who has the app bundle can read the file, see the plaintext passwords, or patch the client. A real system needs server-side verification, password hashing, token expiry, revocation, and secure transport. That idea applies far beyond Flutter: a web frontend, desktop app, or mobile app is ultimately running on someone else’s machine, so the client cannot be trusted to enforce secrets. The useful part from A7 is the state and routing pattern, not the toy authentication method. That distinction matters because it is easy to confuse “the UI prevents it” with “the system prevents it.”

## Prompt 4 — If I started over

If I rebuilt PredictIt Jr. from scratch, one structural decision I would make differently is to define repository interfaces earlier. `MarketRepository` eventually grew from loading bundled markets to also handling created markets, detail lookup, and test data. Making it more explicitly injectable from the start would make A8 and A9 cleaner. A second change would be to separate platform features like permissions, image picking, and location into services before writing the create screen. A8 showed that platform APIs are harder to test and easier to break, so I would design those seams first instead of adding them as the feature grew. One decision I would definitely keep is using ids in routes instead of passing full `Market` objects. It felt like extra work in A3, but it made deep links, redirects, and the navigation stack make more sense. I would also keep Provider models for shared state, especially `PortfolioModel`, because that single source of truth made persistence and testing possible later.

## Release and performance notes

The intended release command is:

```bash
flutter build apk --release
```

I could not run Flutter inside the ChatGPT sandbox, so this repository includes the command to run locally rather than real build output. Before submitting, run the command above and paste the successful terminal output below or into `a10_release_output.txt`.

For performance, test with:

```bash
flutter run --profile
```

Then enable the performance overlay in DevTools and scroll the market list quickly. The likely thing to check is whether images are correctly sized and whether there are avoidable rebuilds in the card list. If the frame bars stay under budget, note that the list was smooth under profile mode.
