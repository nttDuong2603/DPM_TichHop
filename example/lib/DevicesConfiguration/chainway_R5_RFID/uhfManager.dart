import 'dart:convert';

import 'package:flutter/services.dart';

/*
Creator: NMC97
Date: 12/2024
Description: UHF manager for data process
*/
class UHFManager {
  static const MethodChannel _channel = MethodChannel('rfid_c72_plugin');
  static final UHFManager _instance = UHFManager._internal();

  // All callback
  Function(List<Map<String, String>>)? _onDeviceListReceived;
  Function(List<Map<String, String>>)? _onMultiTagReceived;

  factory UHFManager() {
    return _instance;
  }
  UHFManager._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  // Register for callbacks
  void setDeviceListCallback(Function(List<Map<String, String>>) callback) {
    _onDeviceListReceived = callback;
  }

  void setMultiTagCallback(Function(List<Map<String, String>>) callback) {
    _onMultiTagReceived = callback;
  }

  // Handles methods sent from Java
  // Callbacks should be called together and then divided into cases, but cannot be called in parallel, which will override the callback
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onDeviceListReceived":
        if (_onDeviceListReceived != null) {
          final String devicesJson = call.arguments;
          final List<dynamic> devices = jsonDecode(devicesJson);
          final deviceList = devices.map((device) => Map<String, String>.from(device)).toList();
          _onDeviceListReceived!(deviceList);
        }
        break;

      case "inventoryMultiTag":
        if (_onMultiTagReceived != null) {
          final String tagsJson = call.arguments;
          final List<dynamic> tags = jsonDecode(tagsJson);
          final tagList = tags.map((tag) => Map<String, String>.from(tag)).toList();
          _onMultiTagReceived!(tagList);
        }
        break;

      default:
        print("Unhandled method: ${call.method}");
        break;
    }
  }

//////////////////////////////////////Triggers from flutter (Not callbacks)////////////////////////////////////////////
  // Connection method to RFID device
  Future<bool> connect(String mac) async {
    final bool result = await _channel.invokeMethod('connect', {'mac': mac});
    return result;
  }

  // Bắt đầu quét
  static Future<void> scanDevices(bool enable) async {
    try {
      await _channel.invokeMethod('scanDevices', {'enable': enable});
    } catch (e) {
      print("Error starting scan: $e");
    }
  }

  /// Inventory single Read Tag (Get tagList from native code)
  Future<List<Map<String, String>>> singleRead() async {
    try {
      final List<dynamic> data =
      await _channel.invokeMethod('inventorySingleTag');

      // Convert each item to Map<String, String> with null checks
      List<Map<String, String>> listMap = data.map((item) {
        // Ensure item is treated as a Map with String keys and dynamic values
        Map<String, dynamic> dynamicMap = Map<String, dynamic>.from(item);

        // Create a new map with non-null String values or empty strings
        Map<String, String> stringMap = {};
        dynamicMap.forEach((key, value) {
          stringMap[key] =
              value?.toString() ?? ""; // Replace null with empty string
        });
        return stringMap;
      }).toList();
      return listMap;
    } on PlatformException catch (e) {
      print("Error fetching data: ${e.message}");
      return [];
    }
  }

  // Disconnection method
  Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }

  // Card scanning start method
  Future<void> startInventoryTag() async {
    await _channel.invokeMethod('startInventoryTag');
  }

  //Method to stop card scanning
  Future<void> stopInventory() async {
    await _channel.invokeMethod('stopInventory');
  }
}
