# 🔄 Sistema de Sincronización (SyncManager)

Este documento describe la arquitectura y el flujo de la sincronización bidireccional y encriptada de la aplicación.

---

## 1. Arquitectura General
El sistema utiliza una arquitectura por capas para garantizar que la interfaz de usuario nunca se bloquee y que los datos se mantengan íntegros.



## 2. Flujo de Sincronización
El proceso sigue un bucle de **Paginación Bidireccional** que se detiene mediante un `safetyCounter` (límite de 50 iteraciones) para prevenir bucles infinitos.

### Pasos del Proceso:
1. **Pre-flight Checks**: 
   - Verificación de conexión física (Wi-Fi/Datos).
   - Verificación de salida a internet real (DNS Lookup a google.com).
2. **Auth Check**: 
   - Validación de modo de usuario (No `guest`).
   - Recuperación de `accessToken` desde almacenamiento seguro.
3. **Batch Processing (Bucle While)**:
   - **Push (Subida)**: Se obtienen datos locales mediante un cursor `lastPushedAt`. Si el servidor responde OK, se marcan los eliminados localmente para limpieza física.
   - **Pull (Bajada)**: Se reciben datos remotos paginados. Se usa `currentLastId` para mantener el orden en la respuesta del servidor.
4. **Isolate Processing**: 
   - Los payloads encriptados se procesan en un **Isolate secundario** (`compute`) para evitar bloqueos en el hilo principal de la UI.
5. **Local Persistence**: 
   - Guardado masivo (`upsertAll`) en SQLite para asegurar la consistencia.

## 3. Gestión de Errores y Estados
El `SyncManager` devuelve estados específicos que permiten a la UI reaccionar de forma inteligente:

| Estado | Significado | Reacción sugerida |
| :--- | :--- | :--- |
| `ok` | Sincronización completa. | Feedback visual leve (flecha de éxito). |
| `notHasAccessToken` | Token expirado/nulo. | Cambiar a estado `reauth` y pedir login. |
| `limitStorageReached` | Cloudflare D1 lleno (403). | Mostrar banner de "Nube Llena" / Oferta Premium. |
| `notConection` | Sin red física detectada. | Feedback silencioso (Modo Offline). |
| `notConectionServer` | Red sin salida a internet. | Notificar problema de conexión al servidor. |

## 4. Estrategia de Rate Limiting (Delays)
Se implementa un sistema de enfriamiento (*cooldown*) persistente en `SharedPreferences` según el perfil del usuario:

* **Premium**: 5 minutos.
* **Rewarded (Ads disabled)**: 30 minutos.
* **Free**: 4 horas (240 minutos).

## 5. Seguridad y Rendimiento
* **E2EE**: Encriptación de extremo a extremo. Los datos sensibles (`payload`) se procesan localmente con una llave que el servidor nunca conoce.
* **Eficiencia de Hilos**: La lógica pesada de transformación de datos se delega a funciones estáticas para compatibilidad con Isolates de Flutter.

---
*Documentación generada para el módulo de Sincronización - Febrero 2026*