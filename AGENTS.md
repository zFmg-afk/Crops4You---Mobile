# AGENTS.md — Crops4You Mobile

## Monorepo layout

- `crops4you/` — Flutter app (Dart SDK ^3.10.7, Material 3)
- `backend/` — Node.js / Express 5 API (Supabase via `@supabase/supabase-js`)

## Backend API

- Entrypoint is `backend/index.js` (port 3000, override with `PORT`). `backend/app.js` is **orphaned** — only mounts `/health` + error handler; `npm start`/`npm run dev` use `index.js`, so don't add routes to `app.js`.
- Routes mounted in `index.js`: `/health` and `/status` (both no auth) plus `/parcelas`, `/actividades`, `/cultivos`, `/insumos`, `/recordatorios`. All data routes follow the `cultivo.service.js`/`actividadService.js` pattern; recordatorios mirror actividades (same layer, `*.service.js`/`*.controller.js`).
- **Every data route requires `Authorization: Bearer <access_token>`** (Supabase JWT). No token → 401. Controllers/middlewares are inconsistent in naming: `parcelaController.js`/`actividadController.js` (camelCase) vs `cultivo.controller.js`/`insumo.controller.js`/`health.controller.js` (dotted). Grep both when locating files.
- **RLS**: the backend uses the anon key, so Supabase row-level security blocks queries unless the user's JWT is presented. `middlewares/auth.js` verifies the JWT via `supabase.auth.getUser()` and attaches `req.supabase` — an authenticated per-request client built with `createAuthenticatedClient(token)` from `config/db.js`. Controllers pass `req.supabase` to services; never drop this threading or you'll hit `new row violates row-level security policy`.
- Data flow: `controller -> service -> supabase`. `service/*.js` scopes every query by `user_id` and accepts `sb` (default `defaultSupabase`) as the last param.
- Manual API testing: `backend/postman/Crops4You.postman_collection.json`.
- Root `.gitignore` ignores `.env` → `backend/.env` must be created locally with `SUPABASE_URL=` and `SUPABASE_ANON_KEY=` (values live in `crops4you/.env`).

## Flutter app key facts

- **Entrypoint**: `crops4you/lib/main.dart` — loads `.env` via `flutter_dotenv`, initializes Supabase, home is `LoginScreen`. `Supabase.instance.client` is exported as `final supabase` from `main.dart`.
- **Auth**: email/password via Supabase Auth (`auth_service.dart`).
- **State mgmt**: `setState` only — no provider/riverpod/bloc.
- **Navigation**: Material 3 `NavigationBar` (not `BottomNavigationBar`) with 6 tabs (`home_screen.dart`): Inicio, Parcelas, Clima, IA, Alertas, Perfil.
- **Map**: parcel polygon delimitation uses `flutter_map` + `latlong2` + `geolocator`. `google_maps_flutter` is in `pubspec.yaml` but **unused**.
- **Services calling the backend API** (`ApiConfig.backendBaseUrl` + `http`, JWT from `supabase.auth.currentSession?.accessToken`): `parcela_service.dart`, `cultivo_service.dart`, `actividad_service.dart`.
- **Services still calling Supabase directly** (`supabase.from(...)` — works because the app client carries the user's session): `insumo_service.dart`, `recordatorio_service.dart`. Note the backend has `/insumos` and `/actividades` routes, but the Flutter side only routes parcelas/cultivos/actividades through HTTP—insumos and recordatorios stay on direct Supabase. Recordatorios **do** have a backend route (`/recordatorios`) but the app doesn't consume it.
- **External APIs**: OpenWeatherMap (`weather_service.dart`), Google Gemini (`ai_service.dart`).
- `ApiConfig.backendBaseUrl` (`lib/config/api_config.dart`) is a getter: web → `http://localhost:3000`, non-web → `http://10.0.2.2:3000`.

## Env files

- `crops4you/.env` is declared in `pubspec.yaml` assets; file must exist or `flutter run` fails. Keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `OPENWEATHER_KEY`, `GEMINI_KEY`. (`API_URL` unused — services read `ApiConfig`.)
- `backend/.env` needed by the server; not committed.

## Commands

Backend (from `backend/`):

| Command | Action |
|---|---|
| `npm run dev` | Start server with nodemon |
| `npm start` | Start server |
| `node --check <file>.js` | Syntax-check (no test suite) |

Flutter (from `crops4you/`):

| Command | Action |
|---|---|
| `flutter run` | Launch app on connected device/emulator |
| `flutter analyze` | Lint + static analysis |
| `flutter test` | Run tests |

## Gotchas

- `test/widget_test.dart` is **broken** — still references the deleted `MyApp` and imports `main.dart`, which now needs Supabase/`.env`. Rewrite before running tests.
- `lib/widgets/custom_button.dart` and `custom_input.dart` are empty placeholders (0 lines).
- Backend services/controllers split between `*.service.js` and `parcelaService.js`/`actividadService.js` naming — check both conventions.
- Generated plugin files under `crops4you/{linux,macos,windows}/flutter/` change on `flutter pub get` and are safe to leave unstaged.
- No CI, no codegen, no migration tooling configured. Backend startup pings the `parcelas` table and logs an error if Supabase creds are invalid.