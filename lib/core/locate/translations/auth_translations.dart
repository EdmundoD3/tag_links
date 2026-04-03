import 'package:tag_links/core/locate/app_lang.dart';

class TranslatesAuth {
  const TranslatesAuth();

  final String loginWithGoogle = 'loginWithGoogle';
  final String logOut = 'logOut';
  final String syncLinks = 'syncLinks';
  final String syncWithGoogleDrive = 'syncWithGoogleDrive';
  final String continueWithGoogle = 'continueWithGoogle';
  final String authenticationError = 'authenticationError';
  final String skipForNow = 'skipNow';
  final String sessionExpired = 'sessionExpired';
  final String reconnectGoogle = 'reconnectGoogle';

  static const Map<String, Map<AppLang, String>> translations = {
    'loginWithGoogle': {
      AppLang.es: 'No se encontró una app para abrir este enlace',
      AppLang.en: 'No app found to open this link',
    },
    'logOut': {AppLang.es: 'Cerrar Sesión', AppLang.en: 'Log Out'},
    'syncLinks': {
      AppLang.es: 'Sincroniza tus enlaces',
      AppLang.en: 'Sync your links',
    },
    'syncWithGoogleDrive': {
      AppLang.es:
          'Utilizaremos Google Drive para mantener tus notas seguras y sincronizadas entre dispositivos.',
      AppLang.en:
          'We will use Google Drive to keep your notes secure and synchronized between devices',
    },
    'continueWithGoogle': {
      AppLang.es: 'Continuar con Google',
      AppLang.en: 'Continue with Google',
    },
    'authenticationError': {
      AppLang.es: 'Error de autenticación',
      AppLang.en: 'Authentication Error',
    },
    'skipNow': {AppLang.es: 'Omitir por ahora', AppLang.en: 'Skip for now'},
    'sessionExpired': {
      AppLang.es: 'Sesión expirada',
      AppLang.en: 'Session expired',
    },
    'reconnectGoogle': {
      AppLang.es:
          'Tu conexión con Google Drive se ha perdido. Vuelve a iniciar sesión para sincronizar tus cambios.',
      AppLang.en:
          'Your Google Drive connection has been lost. Log in again to synchronize your changes.',
    },
  };
}
