# MyIndustryHouse Mobile

Native Flutter mobile client (Android + iOS) for the MyIndustryHouse B2B
industrial marketplace.

## Scope (by design)

- **Buyer Panel** and **Seller Panel** only.
- **No admin surface at all** - if an admin account logs in, the app shows
  *"Admin access is restricted to the web portal."* Admin operations remain
  entirely on the web platform.
- **Pure native Flutter widgets - no WebView.**
- **Strict client**: consumes the existing REST API at
  `https://www.myindustryhouse.com/api/v1/...` exactly as deployed.
  The backend, database, schemas and routes are NOT modified by this app.

## Architecture

- **State management**: Riverpod (`flutter_riverpod`)
  - `sessionProvider` (StateNotifier) - auth session, role and persistence
    (SharedPreferences-backed)
  - `authGateProvider` - single routing decision point
    (signedOut / buyer / seller / adminBlocked)
- **Networking**: Dio (`lib/data/api_client.dart`) with session-header
  interceptors, timeouts and honest error mapping
- **Endpoints**: `lib/data/endpoints.dart` documents the existing API paths
- **Role-based routing**: unified SMS-OTP login, then the backend's role
  response routes to the Buyer or Seller shell with role-specific bottom
  navigation.

## Project layout

```
lib/
  main.dart                     # ProviderScope + MaterialApp + AuthGate
  core/
    app_config.dart             # API base URL, constants
    app_theme.dart              # palette/typography matching the web platform
    role.dart                   # AppRole (buyer/seller/admin)
  data/
    api_client.dart             # Dio wrapper (session headers, errors)
    endpoints.dart              # existing backend routes (client view)
    auth_repository.dart        # SMS OTP flow wrappers
    models/user_session.dart
  providers/
    session_provider.dart       # Riverpod session + auth gate
  screens/
    auth/login_screen.dart      # unified login (phone + SMS OTP)
    admin/admin_blocked_screen.dart
    buyer/buyer_shell.dart       # 5-tab bottom nav (buyer layout)
    seller/seller_shell.dart    # 5-tab bottom nav (seller layout)
    shared/placeholder_panel.dart
```

## Run

```bash
flutter pub get
flutter run            # Android emulator / iOS simulator / device
flutter analyze
flutter test
```

> For local development against a local backend, point
> `AppConfig.apiBaseUrl` to `http://10.0.2.2:8081` (Android emulator) or
> `http://localhost:8081` (iOS simulator).
