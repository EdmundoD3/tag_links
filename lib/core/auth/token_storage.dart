import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  final String _key = 'session_token';
   Future<void> save(String token)async{
     final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }
   Future<String?> get() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
   Future<void> clean() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}