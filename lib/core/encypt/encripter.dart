import 'package:tag_links/core/encypt/encypter_services.dart';

// Mantenemos una instancia por defecto para el hilo principal (UI)
final _mainEncryptionService = EncryptionService();

/// Encripta texto. 
/// Si se provee un [service] (como en un Isolate), usa ese. 
/// Si no, usa el servicio global del hilo principal.
Future<String> encripter(String textToEncrypt, {EncryptionService? service}) {
  final s = service ?? _mainEncryptionService;
  return s.encrypt(textToEncrypt);
}

/// Desencripta texto.
/// [service] es obligatorio cuando se llama desde un Isolate (compute).
Future<String> decripter(String textToDecrypt, {EncryptionService? service}) {
  final s = service ?? _mainEncryptionService;
  return s.decrypt(textToDecrypt);
}