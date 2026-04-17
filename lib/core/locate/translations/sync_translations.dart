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
      AppLang.de: 'Synchronisierungsstatus:',
      AppLang.pt: 'Estado de sincronização:',
    },
    'lastSync': {
      AppLang.es: 'Última vez: ',
      AppLang.en: 'Last sync: ',
      AppLang.de: 'Letzte Synchronisierung: ',
      AppLang.pt: 'Última sincronização: ',
    },
    'notSynced': {
      AppLang.es: 'No se ha sincronizado',
      AppLang.en: 'Not synced',
      AppLang.de: 'Nicht synchronisiert',
      AppLang.pt: 'Não sincronizado',
    },
    'syncNow': {
      AppLang.es: 'Sincronizar ahora',
      AppLang.en: 'Sync now',
      AppLang.de: 'Jetzt synchronisieren',
      AppLang.pt: 'Sincronizar agora',
    },
    'driveSync': {
      AppLang.es: 'Sincronizando con Drive...',
      AppLang.en: 'Syncing with Drive...',
      AppLang.de: 'Synchronisiere mit Drive...',
      AppLang.pt: 'Sincronizando com o Drive...',
    },
    'errorSync': {
      AppLang.es: 'Error al sincronizar',
      AppLang.en: 'Sync error',
      AppLang.de: 'Fehler bei der Synchronisierung',
      AppLang.pt: 'Erro de sincronização',
    },
    'loginSync': {
      AppLang.es: 'Inicia sesión para sincronizar',
      AppLang.en: 'Login to sync',
      AppLang.de: 'Melde dich an, um zu synchronisieren',
      AppLang.pt: 'Faça login para sincronizar',
    },
    'backUpTitle': {
      AppLang.es: 'Respaldo en la nube',
      AppLang.en: 'Back up in the cloud',
      AppLang.de: 'Cloud-Sicherung',
      AppLang.pt: 'Backup na nuvem',
    },
    'backUpMessage': {
      AppLang.es:
          'Para mantener tus notas seguras y sincronizadas en todos tus dispositivos, necesitas iniciar sesión con Google Drive.',
      AppLang.en:
          'To keep your notes secure and synchronized across all your devices, you need to log in with Google Drive.',
      AppLang.de:
          'Um deine Notizen sicher zu speichern und auf all deinen Geräten zu synchronisieren, musst du dich bei Google Drive anmelden.',
      AppLang.pt:
          'Para manter suas notas seguras e sincronizadas em todos os seus dispositivos, você precisa fazer login com o Google Drive.',
    },
  };
}
