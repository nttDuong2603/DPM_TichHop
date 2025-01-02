import 'package:flutter/material.dart';

class ConnectionNotificationRSeries {
  static void showConnectionStatus(BuildContext context, bool isConnected) {
    final message = isConnected ? "Kết nối thành công!" : "Thiết bị quét mất kết nối!";
    final color = isConnected ? Colors.green : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3), // Hiển thị trong 3 giây
      ),
    );
  }
  static void showDeviceWaring(BuildContext context, bool isConnected) {
    final message = isConnected ? "" : "Vui lòng kết nối thiết bị quét!";
    final color = isConnected ? Colors.green : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3), // Hiển thị trong 3 giây
      ),
    );
  }
}

