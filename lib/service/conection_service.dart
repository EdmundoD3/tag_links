import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionService {
  // 1. Verificar si hay conexión física (Wi-Fi/Datos)
  Future<bool> hasPhysicalConnection() async {
    final List<ConnectivityResult> connectivityResult = 
        await (Connectivity().checkConnectivity());
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  // 2. Verificar si hay internet real (Haciendo un lookup de DNS)
  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}