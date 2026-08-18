# AGENTS.md — Crops4You Mobile

## Monorepo layout

- `crops4you/` — Flutter app (Dart SDK ^3.10.7, Material 3)
- `backend/` — Node.js / Express 5 API (Supabase via `@supabase/supabase-js`)

## Backend API

- Entrypoint is `backend/index.js` (port 3000, override with `PORT`). `backend/app.js` is **orphaned** — only mounts `/health` + error handler; `npm start`/`npm run dev` use `index.js`, so don't add routes to `app.js`.
- Routes mounted in `index.js`: `/health` and `/status` (both no auth), `GET /clima?lat&lon` and `GET /clima/pronostico?lat&lon` (both no auth, proxy OpenWeather via `climaService.js` — current weather and 5-day forecast), `POST /ia/analisis` (auth, proxies Gemini via `ia.service.js`) plus `/parcelas`, `/actividades`, `/cultivos`, `/insumos`, `/recordatorios`. All data routes follow the `cultivo.service.js`/`actividadService.js` pattern; recordatorios mirror actividades (same layer, `*.service.js`/`*.controller.js`).
- **Every data route requires `Authorization: Bearer <access_token>`** (Supabase JWT). No token → 401. Controllers/middlewares are inconsistent in naming: `parcelaController.js`/`actividadController.js`/`climaController.js` (camelCase) vs `cultivo.controller.js`/`insumo.controller.js`/`health.controller.js` (dotted). Grep both when locating files.
- **RLS**: the backend uses the anon key, so Supabase row-level security blocks queries unless the user's JWT is presented. `middlewares/auth.js` verifies the JWT via `supabase.auth.getUser()` and attaches `req.supabase` — an authenticated per-request client built with `createAuthenticatedClient(token)` from `config/db.js`. Controllers pass `req.supabase` to services; never drop this threading or you'll hit `new row violates row-level security policy`.
- Data flow: `controller -> service -> supabase`. `service/*.js` scopes every query by `user_id` and accepts `sb` (default `defaultSupabase`) as the last param.
- All errors respond `{ error: true, mensaje: '...' }` (see `middlewares/errorHandler.js`); Flutter services parse `mensaje`.
- Manual API testing: `backend/postman/Crops4You.postman_collection.json` (v2 is a JSON file without `.json` extension at `backend/postman/Crops4You_v2.postman_collection` — not a directory).
- Root `.gitignore` ignores `.env` → `backend/.env` must be created locally (see Env files below).

## Flutter app key facts

- **Entrypoint**: `crops4you/lib/main.dart` — loads `.env` via `flutter_dotenv`, initializes Supabase, home is `LoginScreen`. `Supabase.instance.client` is exported as `final supabase` from `main.dart`.
- **Auth**: email/password via Supabase Auth (`auth_service.dart`).
- **State mgmt**: `setState` only — no provider/riverpod/bloc.
- **Navigation**: Material 3 `NavigationBar` (not `BottomNavigationBar`) with 6 tabs (`home_screen.dart`): Inicio, Parcelas, Clima, IA, Alertas, Perfil.
- **Map**: parcel polygon delimitation uses `flutter_map` + `latlong2` + `geolocator`. `google_maps_flutter` is in `pubspec.yaml` but **unused**.
- **Services calling the backend API** (`ApiConfig.backendBaseUrl` + `http`, JWT from `supabase.auth.currentSession?.accessToken`): `parcela_service.dart`, `cultivo_service.dart`, `actividad_service.dart`, `insumo_service.dart`, `recordatorio_service.dart`, `ai_service.dart` (via `POST /ia/analisis`). **All data access goes through the backend** — no `supabase.from(...)` calls remain in `lib/` (only `supabase.auth` in `auth_service.dart`). `getPendientes`/`getByCultivo` in `recordatorio_service.dart` and `getByCultivo` in `insumo_service.dart` map to backend query params (`?cultivo_id=`, client-side filter for pendientes).
- **External APIs**: all weather (current + 5-day forecast) goes through the backend (`GET /clima`, `GET /clima/pronostico`); `weather_service.dart` only uses `geolocator` locally and hits those endpoints — no OpenWeather key in the app. Google Gemini is called exclusively through the backend `POST /ia/analisis`.
- `ApiConfig.backendBaseUrl` (`lib/config/api_config.dart`) is a getter: web → `http://localhost:3000`, non-web → `http://10.0.2.2:3000`. Physical devices need the LAN IP; the app does not proxy through the backend by default.

## Env files

- `crops4you/.env` is declared in `pubspec.yaml` assets; file must exist or `flutter run` fails. Keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. (`API_URL` unused — services read `ApiConfig`; weather and Gemini keys live only in the backend.)
- `backend/.env` needed by the server; not committed. Keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `OPENWEATHER_KEY`, `GEMINI_KEY`. `config/db.js` exits on startup if the Supabase keys are missing.

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
| `flutter analyze` | Lint + static analysis (run before `flutter test`) |
| `flutter test` | Tests |
| `flutter run` | Launch app |

## Conventions

- **Spanish** — all UI strings, variable names, and commit messages.
- **Supabase RLS tables**: `parcelas`, `cultivos`, `actividades`, `insumos`, `recordatorios` — every insert includes `user_id: req.user.id` (from the JWT; services add it). Flutter never writes `user_id` — the app sends the token only.

## Dead code (safe to delete)

- `crops4you/lib/widgets/custom_button.dart` and `custom_input.dart` — empty, imported nowhere
- `crops4you/lib/services/api_service.dart` — 5-line stub, imported nowhere
- `crops4you/pubspec.yaml` — `google_maps_flutter` is listed but never imported in any `.dart` file
- `backend/app.js` — unused duplicate of `index.js` setup

## Gotchas

- **Backend crashes at startup on Node < 22**: `@supabase/supabase-js` (^2.108) requires WebSocket, missing in Node 18 → `config/db.js` throws `Node.js 18 detected without native WebSocket support` and the server never listens (affects every endpoint, not just clima). Fixed in `config/db.js` by installing `ws` and passing `realtime: { transport: WebSocket }` to both `createClient` calls. Keep that option if you touch `db.js`.
- `test/widget_test.dart` is **broken** — still references the deleted `MyApp` and imports `main.dart`, which now needs Supabase/`.env`. Rewrite before running tests.
- Backend services/controllers split between `*.service.js` and `parcelaService.js`/`actividadService.js` naming — check both conventions.
- Generated plugin files under `crops4you/{linux,macos,windows}/flutter/` change on `flutter pub get` and are safe to leave unstaged.
- No CI, no codegen, no migration tooling configured. Backend startup pings the `parcelas` table and logs an error if Supabase creds are invalid.
