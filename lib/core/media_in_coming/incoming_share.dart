import 'dart:async';

import 'package:flutter/services.dart';
// En caso de agregar ios, falta agregar esto en chanel
class IncomingShare {
  static const MethodChannel _methodChannel =
      MethodChannel('com.papitas.notita/incoming_share');

  static const EventChannel _eventChannel =
      EventChannel('com.papitas.notita/incoming_share_events');

  static Stream<String> get stream {
    return _eventChannel
        .receiveBroadcastStream()
        .where((event) => event != null)
        .map((event) => event.toString());
  }

  static Future<String?> getInitial() async {
    return _methodChannel.invokeMethod<String>('getInitialShare');
  }
}