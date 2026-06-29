# AGENTS.md — Crops4You Mobile

## Monorepo layout

- `crops4you/` — Flutter app (Dart SDK ^3.10.7, Material 3)
- `backend/` — Node.js / Express 5 API (Supabase backend, `index.js` entrypoint)

## Flutter app key facts

- **Entrypoint**: `crops4you/lib/main.dart` — initializes Supabase, loads `.env`, renders `Crops4YouApp`
- **Auth**: email/password via Supabase Auth (`AuthService`)
- **Database**: Supabase tables `parcelas`, `cultivos`, `actividades`, `insumos`, `recordatorios` — all scoped by `user_id`
- **External APIs**: OpenWeatherMap (`lib/services/weather_service.dart`), Google Gemini 2.5 Flash (`lib/services/ai_service.dart`)
- **State mgmt**: `setState` only — no provider/riverpod/bloc
- **Map**: `flutter_map` + `latlong2` + `geolocator` for parcel polygon delimitation
- **Navigation**: `BottomNavigationBar` with 6 tabs in `HomeScreen`

## Required env file

`crops4you/.env` is declared in `pubspec.yaml` assets. It must exist at that path with keys:
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
OPENWEATHER_KEY=
GEMINI_KEY=
```

## Commands (run from `crops4you/`)

| Command | Action |
|---|---|
| `flutter run` | Launch app on connected device/emulator |
| `flutter analyze` | Lint + static analysis |
| `flutter test` | Run tests |

## Gotchas

- `test/widget_test.dart` is **broken** — references `MyApp` (deleted). Rewrite before running tests.
- `lib/widgets/custom_button.dart` and `custom_input.dart` are empty placeholders.
- `backend/package.json` had a syntax error (missing comma after `"scripts"`), already fixed.
- No CI, no codegen, no migration tooling configured.
