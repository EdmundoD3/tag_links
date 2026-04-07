import '../app_lang.dart';

class TranslatesSync{
  const TranslatesSync();
  
  final String stateSync = 'stateSync';
  final String lastSync = 'lastSync';
  final String notSynced = 'notSynced';

  static const Map<String, Map<AppLang, String>> translations = {
    'stateSync': {
      AppLang.es: 'Estado de sincronizado:',
      AppLang.en: 'Sync state:',
    },
    'lastSync': {
      AppLang.es: 'Última vez: ',
      AppLang.en: 'Last sync: ',
    },
    'notSynced': {
      AppLang.es: 'No se ha sincronizado',
      AppLang.en: 'Not synced',
    },
  };
}