
# TagLinks - Flutter App 🚀

Una solución robusta para la gestión de enlaces y notas, construida con **Flutter** y sincronizada con un backend en **Node.js/TS**. Esta aplicación demuestra un flujo completo de monetización, persistencia local y arquitectura escalable.

---

## 🛠 Configuración del Entorno

### 1. Variables de API (Inyección en Compilación)
Para mantener la seguridad y flexibilidad entre entornos (Desarrollo vs. Producción), la URL del servidor se inyecta mediante `--dart-define`.

#### **Configuración en VS Code (`.vscode/launch.json`)**
Para depurar sin escribir comandos largos, agrega esto a tu configuración de lanzamiento:

```json
{
  "name": "TagLinks Debug",
  "request": "launch",
  "type": "dart",
  "toolArgs": [
    "--dart-define",
    "API_BASE_URL=https://tu-servidor-local.com/api"
  ]
}
```

### 2. Google AdMob (Android)
La publicidad está integrada mediante el SDK oficial. Debes configurar el ID de aplicación en el manifiesto de Android.
**Archivo:** `android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

**Archivo:** `lib/core/ads/ad_mob_config.dart`
Recuerda actualizar los IDs de los bloques de anuncios para producción:
* `bannerAdUnitId`: Banner inferior.
* `interstitialAdUnitId`: Intersticial de transición.
* `rewardedAdUnitId`: Video para recompensas.

### 💎 Compras In-App (Sin Publicidad)
El sistema permite a los usuarios eliminar la publicidad mediante suscripciones. Los IDs registrados en Google Play Console son:
* `premium_monthly`
* `premium_yearly`

---

## 🚀 Comandos de Ejecución

### Ejecutar en Desarrollo

```bash
flutter run --dart-define=API_BASE_URL=https://tu-servidor-js.com/api
```

### Compilar APK de Producción

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.tu-dominio-real.com
```

---

## ⚙️ Tecnologías y Arquitectura
* **Gestión de Estado:** Riverpod (Notifier & FutureProvider).
* **Base de Datos:** SQLite para persistencia offline y SharedPreferences para ajustes.
* **Backend:** Sincronización con API REST (Node.js / TypeScript).
* **Monetización:** Google Mobile Ads + In-App Purchases (IAP).
* **UI/UX:** Diseño adaptativo con soporte para temas personalizados.