class GoogleSignInAppConfig {
    static final clientId = "793153150656-igkermg1hi4bae7dh89cvgr5nukjbtf5.apps.googleusercontent.com";
}

// 1. El Certificado SHA-1 (La "Llave" Real)
// https://console.cloud.google.com/
// Debug: Debes registrar el SHA-1 de tu máquina local (donde programas) para que el login funcione mientras desarrollas.
// Release: Debes registrar el SHA-1 que Google Play usa para firmar tu app en producción.

// 2. El archivo google-services.json
// necesitas descargar este archivo desde el proyecto de Firebase (o Google Cloud) y colocarlo en android/app/.
// Este archivo contiene:
//   Tu project_number.
//   El client_id específico para Android.
//   La configuración de los servicios que tienes activos.

// 3. Los Scopes (Permisos)
// Como estás usando el AppDataFolder (que es lo mejor para Tag Links porque el usuario no puede borrar archivos por accidente), tu scope debería ser:
// https://www.googleapis.com/auth/drive.appdata
