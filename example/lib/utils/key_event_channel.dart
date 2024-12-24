import 'package:flutter/services.dart';

class KeyEventChannel {
  static const MethodChannel _channel = MethodChannel('rfid_c72_plugin');

  Function? onKeyReceived;

  KeyEventChannel({this.onKeyReceived});

  void initialize() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onKeyDown":
        final int keyCode = call.arguments;
        if (keyCode == 293) {
          onKeyReceived?.call();
        }
        break;
      default:
        print("Unhandled method: ${call.method}");
    }
  }
}
