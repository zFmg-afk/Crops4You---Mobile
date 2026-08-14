# AGENTS.md — Crops4You Mobile

## Monorepo

- `crops4you/` — Flutter app (Dart SDK ^3.10.7, Material 3)
- `backend/` — Node.js / Express 5 API (entrypoint `index.js`)

No root `package.json` or workspace config. Run commands inside the subdirectory.

## Setup

Both packages need a `.env` file (gitignored):

| Package | Required keys |
|---|---|
| `crops4you/.env` | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `OPENWEATHER_KEY`, `GEMINI_KEY` |
| `backend/.env` | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `OPENWEATHER_KEY` |

Missing `.env` → Flutter build fails at asset load (`.env` is declared in `pubspec.yaml` assets), backend exits on startup.

## Commands

| In | Command | Action |
|---|---|---|
| `crops4you/` | `flutter analyze` | Lint + static analysis |
| `crops4you/` | `flutter test` | Tests |
| `crops4you/` | `flutter run` | Launch app |
| `backend/` | `npm run dev` | Dev server (nodemon) |
| `backend/` | `npm start` | Production |

**Always** run `flutter analyze` before `flutter test` — lint catches silent test crashes.

## Flutter architecture

- **Auth**: email/password via Supabase Auth (`AuthService`)
- **State**: `setState` only — do NOT introduce Provider / Riverpod / Bloc
- **Routing**: `Navigator.push` / `pushReplacement` only — no named routes, no router package
- **Global supabase**: all services import `package:crops4you/main.dart` for the global `supabase` instance — never instantiate a second client
- **Navigation**: `BottomNavigationBar` with 6 tabs (`HomeScreen`), tab state preserved via `IndexedStack`
- **Data access is hybrid — do not assume one path:**
  - **Via backend HTTP API** (`parcela_service.dart`, `cultivo_service.dart`, `actividad_service.dart`): calls Express with `Authorization: Bearer <supabase.auth.currentSession.accessToken>`; base URL from `lib/config/api_config.dart`
  - **Direct Supabase** (`auth_service.dart`, `insumo_service.dart`, `recordatorio_service.dart`): uses the global client
- **Base URL quirk**: `ApiConfig.backendBaseUrl` is `http://10.0.2.2:3000` (Android emulator) or `http://localhost:3000` (web) — physical devices need the LAN IP. Flutter does not proxy via the backend by default.
- **External APIs**: OpenWeatherMap (`weather_service.dart`), Google Gemini 2.5 Flash (`ai_service.dart`, hardcoded model URL)
- **Map**: `flutter_map` + `latlong2` + `geolocator` for parcel polygon delimitation

## Backend architecture

Express 5 (`express.json()` replaces body-parser). Layered: routes → controllers → services. Entrypoint `index.js` is self-booting — does NOT export `app` (backend `app.js` is a stale duplicate, unused).

- Routes: `GET /health` and `GET /status` (no auth) map to `health.routes.js`; `GET /clima?lat&lon` (no auth) proxies OpenWeather (`climaService.js`); full CRUD on `/parcelas`, `/cultivos`, `/actividades`
- **Every CRUD route requires `middlewares/auth.js`**: reads `Bearer` token, calls `supabase.auth.getUser`, then sets `req.user` and `req.supabase` (a per-request authenticated Supabase client created via `createAuthenticatedClient` in `config/db.js`). New CRUD routes must mount `auth`.
- Services take `(userId, sb)` where `sb` is the per-request client — never the shared `supabase` export for user-scoped queries
- All errors respond `{ error: true, mensaje: '...' }` (see `middlewares/errorHandler.js`); Flutter services parse `mensaje`
- Supabase client created once in `config/db.js` (requires `SUPABASE_URL` + `SUPABASE_ANON_KEY`, exits on startup if missing)

## Conventions

- **Spanish** — all UI strings, variable names, and commit messages
- **Supabase RLS tables**: `parcelas`, `cultivos`, `actividades`, `insumos`, `recordatorios` — every insert includes `user_id: supabase.auth.currentUser.id` (Flutter direct path) or `user_id: req.user.id` (backend path)

## Dead code (safe to delete)

- `crops4you/lib/widgets/custom_button.dart` — empty, imported nowhere
- `crops4you/lib/widgets/custom_input.dart` — empty, imported nowhere
- `crops4you/lib/services/api_service.dart` — 5-line stub, imported nowhere
- `crops4you/pubspec.yaml` — `google_maps_flutter` is listed but never imported in any `.dart` file
- `backend/app.js` — unused duplicate of `index.js` setup

## Gotchas

- `crops4you/test/widget_test.dart` is **broken** — references deleted `MyApp` (renamed to `Crops4YouApp`). Rewrite before running tests.
- Backend has no test suite; verify changes via `npm run dev` + Postman collection at `backend/postman/`
- No CI, no codegen, no migration tooling configured.