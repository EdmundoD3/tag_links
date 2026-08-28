# Migración de Incoming Share a iOS

## Objetivo

Actualmente `Tag Links` permite recibir desde Android:

* Texto compartido.
* URLs compartidas.
* Texto + URL.
* Procesamiento mediante `MethodChannel` para el share inicial.
* Procesamiento mediante `EventChannel` cuando la aplicación ya está abierta.

La implementación Android está basada en:

```text
Android Intent ACTION_SEND
        ↓
MainActivity.kt
        ↓
MethodChannel / EventChannel
        ↓
lib/core/media_in_coming/incoming_share.dart
        ↓
handle_media_in_coming_url.dart
        ↓
pendingNoteProvider
```

La implementación de iOS debe conservar **el mismo contrato Dart**, de forma que la lógica de negocio no tenga que cambiar.

---

# Archivos Dart que revisar

## 1. `lib/core/media_in_coming/incoming_share.dart`

Actualmente contiene:

* `MethodChannel`
* `EventChannel`
* `getInitial()`
* `stream`

Este archivo debe mantenerse como la interfaz común de Flutter.

### Contrato actual

Method Channel:

```text
com.papitas.notita/incoming_share
```

Método:

```text
getInitialShare
```

Event Channel:

```text
com.papitas.notita/incoming_share_events
```

El objetivo es que iOS implemente exactamente estos mismos nombres.

**No cambiar estos nombres al implementar iOS**, salvo que exista una razón concreta.

---

## 2. `lib/main.dart`

Revisar dónde se registra:

```dart
IncomingShare.stream.listen(...)
```

y:

```dart
IncomingShare.getInitial()
```

La lógica de Flutter debería permanecer igual.

No debería ser necesario agregar lógica específica de iOS aquí.

---

## 3. `lib/core/media_in_coming/handle_media_in_coming_url.dart`

Este archivo contiene la lógica de negocio:

* Validar texto recibido.
* Detectar URL.
* Separar URL y descripción.
* Crear `Note`.
* Crear `LinkPreview`.
* Obtener `fileId`.
* Enviar la nota a `pendingNoteProvider`.

Esta lógica debe permanecer independiente de Android/iOS.

---

## 4. `lib/core/media_in_coming/pending_note_provider.dart`

Revisar únicamente para comprobar que el flujo de:

```text
share → pending note → enriquecimiento → UI
```

no dependa de Android.

No debería requerir cambios para iOS.

---

# Archivos Android de referencia

Estos archivos sirven como referencia para entender qué debe hacer la implementación de iOS.

## `android/app/src/main/kotlin/.../MainActivity.kt`

Actualmente implementa:

```text
MethodChannel
EventChannel
ACTION_SEND
EXTRA_TEXT
onNewIntent()
```

Su función es convertir el mecanismo nativo de Android en eventos que Flutter pueda consumir.

No modificarlo para implementar iOS.

---

## `android/app/src/main/AndroidManifest.xml`

Actualmente contiene el `intent-filter`:

```xml
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
</intent-filter>
```

Esto permite que Android muestre `Notita` como destino al compartir texto.

Este bloque es **específico de Android**.

---

# Archivos iOS que habrá que revisar

Cuando llegue el momento de agregar iOS, revisar como mínimo:

## 1. `ios/Runner/AppDelegate.swift`

Actualmente solo registra Flutter:

```swift
GeneratedPluginRegistrant.register(with: self)
```

Aquí habrá que agregar la implementación de:

```text
MethodChannel
EventChannel
```

usando los mismos nombres que Android.

---

## 2. `ios/Runner/Info.plist`

Revisar la configuración de la aplicación y cualquier configuración necesaria para recibir contenido compartido.

Importante:

**iOS no utiliza `AndroidManifest.xml` ni `ACTION_SEND`.**

Por lo tanto, no hay que intentar copiar literalmente el `intent-filter` de Android.

---

## 3. Share Extension

Investigar/crear una:

```text
Share Extension
```

para que iOS pueda mostrar `Notita` dentro del menú "Compartir".

La arquitectura esperada será aproximadamente:

```text
Safari / Fotos / otra aplicación
        ↓
iOS Share Sheet
        ↓
Notita Share Extension
        ↓
Comunicación con Runner
        ↓
Flutter
```

La Share Extension es importante porque en iOS recibir contenido desde otras aplicaciones no funciona simplemente agregando código al `AppDelegate`.

---

## 4. `ios/Podfile`

Revisar si la Share Extension requiere configuración adicional de CocoaPods.

No modificarlo hasta conocer exactamente la configuración de la extensión.

---

## 5. Proyecto Xcode

Abrir:

```text
ios/Runner.xcworkspace
```

en Xcode y revisar:

* Targets.
* `Runner`.
* Share Extension.
* App Groups.
* Signing & Capabilities.
* Bundle Identifier.
* Deployment Target.

---

# Comunicación entre Share Extension y Flutter

Este será probablemente el punto más importante de la migración.

La extensión de iOS y la aplicación principal son procesos/componentes distintos.

No asumir que:

```text
Share Extension → EventChannel → Flutter
```

funcionará directamente.

La estrategia probable será:

```text
Share Extension
       ↓
App Group / almacenamiento compartido
       ↓
Runner
       ↓
MethodChannel / EventChannel
       ↓
Flutter
```

Por ejemplo, la Share Extension podría guardar temporalmente:

```text
shared_text
```

en un App Group.

Cuando `Runner` se inicia o vuelve a primer plano:

```text
Runner
  ↓
lee el contenido pendiente
  ↓
lo entrega a Flutter
  ↓
Flutter procesa la nota
  ↓
borra el contenido pendiente
```

---

# Contrato que iOS debe respetar

La implementación iOS debería mantener:

### Method Channel

```text
com.papitas.notita/incoming_share
```

Método:

```text
getInitialShare
```

Retorno:

```text
String?
```

---

### Event Channel

```text
com.papitas.notita/incoming_share_events
```

Eventos:

```text
String
```

---

# Comportamiento esperado

## Aplicación cerrada

```text
Usuario comparte URL
        ↓
Share Sheet
        ↓
Notita
        ↓
Share Extension
        ↓
guarda contenido pendiente
        ↓
Notita Runner inicia
        ↓
getInitialShare()
        ↓
Flutter
        ↓
handleMedia()
```

## Aplicación abierta

```text
Usuario comparte URL
        ↓
Share Sheet
        ↓
Notita
        ↓
Share Extension
        ↓
contenido pendiente
        ↓
Runner
        ↓
EventChannel
        ↓
Flutter
        ↓
handleMedia()
```

---

# Funcionalidad mínima a implementar

La primera versión de iOS solo necesita soportar:

* [ ] Texto.
* [ ] URLs.
* [ ] Texto + URL.
* [ ] Share con aplicación cerrada.
* [ ] Share con aplicación abierta.
* [ ] Evitar procesar dos veces el mismo contenido.
* [ ] Mantener el mismo flujo de `Note`.
* [ ] Mantener el mismo enriquecimiento de `LinkPreview`.

No es necesario implementar inicialmente:

* Imágenes.
* Archivos.
* Videos.
* Múltiples elementos compartidos.

Eso puede agregarse posteriormente.

---

# Checklist de migración

Cuando llegue el momento:

* [ ] Revisar `ios/Runner/AppDelegate.swift`.
* [ ] Revisar `ios/Runner/Info.plist`.
* [ ] Crear/configurar Share Extension.
* [ ] Configurar App Group.
* [ ] Revisar `ios/Podfile`.
* [ ] Configurar Signing & Capabilities en Xcode.
* [ ] Implementar almacenamiento temporal entre Extension y Runner.
* [ ] Implementar `MethodChannel`.
* [ ] Implementar `EventChannel`.
* [ ] Mantener los mismos nombres de channels.
* [ ] Mantener `getInitialShare`.
* [ ] Conectar eventos con `IncomingShare.stream`.
* [ ] Probar aplicación cerrada.
* [ ] Probar aplicación abierta.
* [ ] Probar URL sola.
* [ ] Probar texto + URL.
* [ ] Comprobar que no haya duplicados.
* [ ] Comprobar que el enriquecimiento de `LinkPreview` continúe funcionando.

---

# Regla importante

La lógica de negocio debe permanecer en Dart.

La plataforma solamente debe encargarse de:

```text
"¿Cómo obtengo el contenido compartido?"
```

Flutter debe encargarse de:

```text
"¿Qué hago con ese contenido?"
```

Por lo tanto:

```text
Android ──┐
          ├──> IncomingShare ──> handleMedia() ──> Note
iOS ──────┘
```

La meta de la migración es que `handle_media_in_coming_url.dart` no necesite saber si el contenido vino de Android o iOS.
