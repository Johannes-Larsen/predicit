# A6 Reflection

I only had to touch a small number of files because `PortfolioModel` already owned the portfolio state and all real mutations went through model methods like `placeBet`. That meant persistence could be added at the model/storage boundary instead of scattering save calls through screens and widgets. The unmodifiable `bets` getter from A4 is what makes this work: outside UI code can read bets, but it cannot secretly mutate the list without the model saving and notifying listeners.
