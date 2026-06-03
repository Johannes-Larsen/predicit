# Assignment 8 Reflection

Camera permission permanently denied: the app explains that camera/photo access is blocked in Settings and shows an Open Settings button instead of asking again in a loop. I tested this by denying the camera permission in the emulator/app settings and confirming the app displayed the Settings path instead of crashing.

Location permission permanently denied: the app explains that location is blocked in Settings, shows an Open Settings option, and keeps the market list usable without distance chips. I tested this by denying/revoking location permission in device settings and confirming the list still opened and markets without coordinates, like mkt_003, did not crash.
