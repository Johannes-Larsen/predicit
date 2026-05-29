# A4 Reflection — Why `setState` Was Not Enough

I first tried to think about the cash balance the same way A2 handled the slider: keep a value in one widget and call `setState` when it changes. That breaks down because the cash balance is needed by more than one screen. The `BetSheet` changes the balance, but the `PortfolioScreen` is a different route, not a child widget that the bet sheet can rebuild with local `setState`.

Passing the balance through constructors also becomes messy because the router builds screens from URLs, and the detail screen and portfolio screen should not need to know about each other. The missing piece is one shared owner for the balance and bets. Provider gives the whole app access to one `PortfolioModel`, and `notifyListeners()` tells every listening screen to rebuild when that shared state changes.
