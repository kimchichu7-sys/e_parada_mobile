# E-Parada Mobile

Flutter client for E-Parada drivers, parking space providers, and administrators.

## Application identity

- App name: `E-Parada`
- Android application ID: `ph.eparada.mobile`
- iOS bundle ID: `ph.eparada.mobile`
- Version: `1.0.0+1`

## Local development

Start Laravel from the website project:

```powershell
cd C:\Users\kimch\e-parada
php artisan serve --host=0.0.0.0 --port=8000
```

Run Flutter on the same PC:

```powershell
cd C:\Users\kimch\e_parada_mobile
C:\Users\kimch\flutter\bin\flutter.bat run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

For a physical phone on the same Wi-Fi, replace `PC_LAN_IP` with the computer's IPv4 address:

```powershell
C:\Users\kimch\flutter\bin\flutter.bat run --dart-define=API_BASE_URL=http://PC_LAN_IP:8000/api
```

Local HTTP is accepted only in debug builds. Release builds require HTTPS.

## Release signing

The Gradle release build reads private credentials from `android/key.properties`.
The file and `*.jks` keystores are ignored by Git.

Back up both private files. Losing the release keystore prevents future Play Store updates under the same application identity.

Build a signed production APK:

```powershell
C:\Users\kimch\flutter\bin\flutter.bat build apk --release --dart-define=API_BASE_URL=https://YOUR-DOMAIN/api
```

Build the preferred Play Store app bundle:

```powershell
C:\Users\kimch\flutter\bin\flutter.bat build appbundle --release --dart-define=API_BASE_URL=https://YOUR-DOMAIN/api
```

## Production backend requirements

The production API must be hosted at a public HTTPS URL. Configure Laravel with production values similar to:

```dotenv
APP_NAME="E-Parada"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://YOUR-DOMAIN
SESSION_SECURE_COOKIE=true
SANCTUM_STATEFUL_DOMAINS=YOUR-DOMAIN
```

Run migrations, queues, scheduled commands, and persistent file storage on the production host. Do not deploy the local SQLite database or `.env` secrets to Git.
