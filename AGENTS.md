# AGENTS.md — Crops4You Mobile

## Monorepo layout

- `crops4you/` — Flutter app (Dart SDK ^3.10.7, Material 3)
- `backend/` — Node.js / Express 5 API (Supabase via `@supabase/supabase-js`, `index.js` entrypoint)

## Backend API

- Entrypoint `backend/index.js`, port 3000 (override with `PORT`). Routes mounted: `/health`, `/parcelas`, `/cultivos`, `/insumos`.
- **Every endpoint on `/parcelas`, `/cultivos`, `/insumos` requires `Authorization: Bearer <access_token>`** (Supabase JWT). No token → 401.
- **RLS**: the backend uses the anon key, so Supabase row-level security blocks queries unless the user's JWT is presented. `middlewares/auth.js` verifies the JWT via `supabase.auth.getUser()` and attaches `req.supabase` — an authenticated per-request client built with `createAuthenticatedClient(token)` from `config/db.js`. Controllers pass `req.supabase` to services; never remove this threading or you'll hit `new row violates row-level security policy`.
- App stores que manejan datos: `controller -> service -> supabase`. Keep `service/*.js` scoping every query by `user_id` and accepting `sb` (default `defaultSupabase`) as last param.
- Root `.gitignore` ignores `.env` → `backend/.env` must be created locally with `SUPABASE_URL=` and `SUPABASE_ANON_KEY=` (from `crops4you/.env`).

## Flutter app key facts

- **Entrypoint**: `crops4you/lib/main.dart` — initializes Supabase, loads `.env`, renders `Crops4YouApp`
- **Auth**: email/password via Supabase Auth (`AuthService`)
- **State mgmt**: `setState` only — no provider/riverpod/bloc
- **Map**: `flutter_map` + `latlong2` + `geolocator` for parcel polygon delimitation
- **Navigation**: `BottomNavigationBar` with 6 tabs in `HomeScreen`
- **Services talking to the backend API** (`ApiConfig.backendBaseUrl` + `http`): `parcela_service.dart`, `cultivo_service.dart`. They read the JWT from `supabase.auth.currentSession?.accessToken`.
- **Services still talking to Supabase directly** (`supabase.from(...)`): `insumo_service.dart`, `actividad_service.dart`, `recordatorio_service.dart`.
- **External APIs**: OpenWeatherMap (`weather_service.dart`), Google Gemini (`ai_service.dart`).
- `ApiConfig.backendBaseUrl` (`lib/config/api_config.dart`) is a getter: web → `http://localhost:3000`, Android → `http://10.0.2.2:3000`.

## Env files

- `crops4you/.env` declared in `pubspec.yaml` assets; file must exist or `flutter run` fails. Keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `OPENWEATHER_KEY`, `GEMINI_KEY`. (`API_URL` unused — services read `ApiConfig`.)
- `backend/.env` needed by the server; not committed (root `.gitignore`).

## Commands

Backend (from `backend/`):

| Command | Action |
|---|---|
| `npm run dev` | Start server with nodemon |
| `npm start` | Start server |

Flutter (from `crops4you/`):

| Command | Action |
|---|---|
| `flutter run` | Launch app on connected device/emulator |
| `flutter analyze` | Lint + static analysis |
| `flutter test` | Run tests |

## Gotchas

- `test/widget_test.dart` is **broken** — references `MyApp` (deleted). Rewrite before running tests.
- `lib/widgets/custom_button.dart` and `custom_input.dart` are empty placeholders.
- Backend has no test suite; run `node --check <file>.js` to syntax-check.
- Generated plugin files under `crops4you/{linux,macos,windows}/flutter/` change on `flutter pub get` and are safe to leave unstaged.
- No CI, no codegen, no migration tooling configured.