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
      AppLang.pt: 'Entrar com o Google',
      AppLang.fr: 'Se connecter avec Google',
      AppLang.ru: 'Войти через Google',
      AppLang.ja: 'Googleでログイン',
    },
    'logOut': {
      AppLang.es: 'Cerrar sesión',
      AppLang.en: 'Log out',
      AppLang.de: 'Abmelden',
      AppLang.pt: 'Sair',
      AppLang.fr: 'Se déconnecter',
      AppLang.ru: 'Выйти',
      AppLang.ja: 'ログアウト',
    },
    'syncLinks': {
      AppLang.es: 'Sincroniza tus enlaces',
      AppLang.en: 'Sync your links',
      AppLang.de: 'Synchronisiere deine Links',
      AppLang.pt: 'Sincronize seus links',
      AppLang.fr: 'Synchronisez vos liens',
      AppLang.ru: 'Синхронизируйте свои ссылки',
      AppLang.ja: 'リンクを同期',
    },
    'syncWithGoogleDrive': {
      AppLang.es:
          'Utilizaremos Google Drive para mantener tus notas seguras y sincronizadas entre dispositivos.',
      AppLang.en:
          'We will use Google Drive to keep your notes secure and synchronized between devices',
      AppLang.de:
          'Wir verwenden Google Drive, um deine Notizen sicher zu speichern und zwischen Geräten zu synchronisieren.',
      AppLang.pt:
          'Usaremos o Google Drive para manter suas notas seguras e sincronizadas entre dispositivos.',
      AppLang.fr:
          'Nous utiliserons Google Drive pour garder vos notes sécurisées et synchronisées entre vos appareils.',
      AppLang.ru:
          'Мы будем использовать Google Drive, чтобы ваши заметки были в безопасности и синхронизированы между устройствами.',
      AppLang.ja: 'Google Driveを使用して、メモを安全に保ち、デバイス間で同期します。',
    },
    'continueWithGoogle': {
      AppLang.es: 'Continuar con Google',
      AppLang.en: 'Continue with Google',
      AppLang.de: 'Mit Google fortfahren',
      AppLang.pt: 'Continuar com o Google',
      AppLang.fr: 'Continuer avec Google',
      AppLang.ru: 'Продолжить через Google',
      AppLang.ja: 'Googleで続行',
    },
    'authenticationError': {
      AppLang.es: 'Error de autenticación',
      AppLang.en: 'Authentication Error',
      AppLang.de: 'Authentifizierungsfehler',
      AppLang.pt: 'Erro de autenticação',
      AppLang.fr: "Erreur d'authentification",
      AppLang.ru: 'Ошибка аутентификации',
      AppLang.ja: '認証エラー',
    },
    'skipNow': {
      AppLang.es: 'Omitir por ahora',
      AppLang.en: 'Skip for now',
      AppLang.de: 'Jetzt überspringen',
      AppLang.pt: 'Pular por agora',
      AppLang.fr: 'Passer pour le moment',
      AppLang.ru: 'Пропустить пока',
      AppLang.ja: '今はスキップ',
    },
    'sessionExpired': {
      AppLang.es: 'Sesión expirada',
      AppLang.en: 'Session expired',
      AppLang.de: 'Sitzung abgelaufen',
      AppLang.pt: 'Sessão expirada',
      AppLang.fr: 'Session expirée',
      AppLang.ru: 'Сессия истекла',
      AppLang.ja: 'セッションの有効期限が切れました',
    },
    'reconnectGoogle': {
      AppLang.es:
          'Tu conexión con Google Drive se ha perdido. Vuelve a iniciar sesión para sincronizar tus cambios.',
      AppLang.en:
          'Your Google Drive connection has been lost. Log in again to synchronize your changes.',
      AppLang.de:
          'Die Verbindung zu Google Drive wurde unterbrochen. Melde dich erneut an, um deine Änderungen zu synchronisieren.',
      AppLang.pt:
          'Sua conexão com o Google Drive foi perdida. Faça login novamente para sincronizar suas alterações.',
      AppLang.fr:
          'Votre connexion à Google Drive a été perdue. Reconnectez-vous pour synchroniser vos modifications.',
      AppLang.ru:
          'Соединение с Google Drive было потеряно. Войдите снова, чтобы синхронизировать изменения.',
      AppLang.ja: 'Google Driveとの接続が失われました。再度ログインして変更を同期してください。',
    },
    'confirmLogoutMessage': {
      AppLang.es: '¿Estás seguro de que quieres cerrar sesión?',
      AppLang.en: 'Are you sure you want to log out?',
      AppLang.de: 'Möchtest du dich wirklich abmelden?',
      AppLang.pt: 'Tem certeza de que deseja sair?',
      AppLang.fr: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      AppLang.ru: 'Вы уверены, что хотите выйти?',
      AppLang.ja: 'ログアウトしてもよろしいですか？',
    },
  };
}
