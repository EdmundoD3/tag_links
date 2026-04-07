import '../app_lang.dart';

class TranslatesSync {
  const TranslatesSync();

  final String stateSync = 'stateSync';
  final String lastSync = 'lastSync';
  final String notSynced = 'notSynced';
  final String syncNow = 'syncNow';
  final String driveSync = 'driveSync';
  final String errorSync = 'errorSync';
  final String loginSync = 'loginSync';
  final String backUpTitle = 'backUpTitle';
  final String backUpMessage = 'backUpMessage';

  static const Map<String, Map<AppLang, String>> translations = {
    'stateSync': {
      AppLang.es: 'Estado de sincronizado:',
      AppLang.en: 'Sync state:',
    },
    'lastSync': {AppLang.es: 'Última vez: ', AppLang.en: 'Last sync: '},
    'notSynced': {
      AppLang.es: 'No se ha sincronizado',
      AppLang.en: 'Not synced',
    },
    'syncNow': {AppLang.es: 'Sincronizar ahora', AppLang.en: 'Sync now'},
    'driveSync': {
      AppLang.es: 'Sincronizando con Drive...',
      AppLang.en: 'Syncing with Drive...',
    },
    'errorSync': {AppLang.es: 'Error al sincronizar', AppLang.en: 'Sync error'},
    'loginSync': {
      AppLang.es: 'Inicia sesión para sincronizar',
      AppLang.en: 'Login to sync',
    },
    'backUpTitle': {
      AppLang.es: 'Respaldo en la nube',
      AppLang.en: 'Back up in the cloud',
    },
    'backUpMessage': {
      AppLang.es:
          'Para mantener tus notas seguras y sincronizadas en todos tus dispositivos, necesitas iniciar sesión con Google Drive.',
      AppLang.en:
          'To keep your notes secure and synchronized across all your devices, you need to log in with Google Drive.',
    },
  };
}
