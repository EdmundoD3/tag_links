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
  final String confirmLogoutMessage = 'confirmLogoutMessage';

  static const Map<String, Map<AppLang, String>> translations = {
    'loginWithGoogle': {
      AppLang.es: 'Iniciar sesión con Google',
      AppLang.en: 'Log in with Google',
      AppLang.de: 'Mit Google anmelden',
    },
    'logOut': {
      AppLang.es: 'Cerrar sesión',
      AppLang.en: 'Log out',
      AppLang.de: 'Abmelden',
    },
    'syncLinks': {
      AppLang.es: 'Sincroniza tus enlaces',
      AppLang.en: 'Sync your links',
      AppLang.de: 'Synchronisiere deine Links',
    },
    'syncWithGoogleDrive': {
      AppLang.es:
          'Utilizaremos Google Drive para mantener tus notas seguras y sincronizadas entre dispositivos.',
      AppLang.en:
          'We will use Google Drive to keep your notes secure and synchronized between devices',
      AppLang.de:
          'Wir verwenden Google Drive, um deine Notizen sicher zu speichern und zwischen Geräten zu synchronisieren.',
    },
    'continueWithGoogle': {
      AppLang.es: 'Continuar con Google',
      AppLang.en: 'Continue with Google',
      AppLang.de: 'Mit Google fortfahren',
    },
    'authenticationError': {
      AppLang.es: 'Error de autenticación',
      AppLang.en: 'Authentication Error',
      AppLang.de: 'Authentifizierungsfehler',
    },
    'skipNow': {
      AppLang.es: 'Omitir por ahora',
      AppLang.en: 'Skip for now',
      AppLang.de: 'Jetzt überspringen',
    },
    'sessionExpired': {
      AppLang.es: 'Sesión expirada',
      AppLang.en: 'Session expired',
      AppLang.de: 'Sitzung abgelaufen',
    },
    'reconnectGoogle': {
      AppLang.es:
          'Tu conexión con Google Drive se ha perdido. Vuelve a iniciar sesión para sincronizar tus cambios.',
      AppLang.en:
          'Your Google Drive connection has been lost. Log in again to synchronize your changes.',
      AppLang.de:
          'Die Verbindung zu Google Drive wurde unterbrochen. Melde dich erneut an, um deine Änderungen zu synchronisieren.',
    },
    'confirmLogoutMessage': {
      AppLang.es: '¿Estás seguro de que quieres cerrar sesión?',
      AppLang.en: 'Are you sure you want to log out?',
      AppLang.de: 'Möchtest du dich wirklich abmelden?',
    },
  };
}