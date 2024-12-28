import 'dart:async';
import 'package:flutter/material.dart';
import 'uhfManager.dart';

/*
Creator: NMC97
Date: 12/2024
Description: UI for R5 Device Management
*/
class Chainwayr5rfid extends StatefulWidget {
  const Chainwayr5rfid({super.key});

  @override
  State<Chainwayr5rfid> createState() => _Chainwayr5rfidState();
}

class _Chainwayr5rfidState extends State<Chainwayr5rfid> {
  final UHFManager _uhfManager = UHFManager();
  List<Map<String, String>> bluetoothDevices = [];
  List<Map<String, String>> _tags = [];

  @override
  void initState() {
    super.initState();

    // // Register for callback to receive device list
    // _uhfManager.setDeviceListCallback((deviceList) {
    //   setState(() {
    //     bluetoothDevices = deviceList;
    //   });
    // });
    _uhfManager.setDeviceListCallback((deviceList) {
      print("Devices found: ${deviceList.length}");
      setState(() {
        bluetoothDevices = deviceList;
      });
    });


    // Register callback to receive multi-tag
    _uhfManager.setMultiTagCallback((tagList) {
      setState(() {
        _tags = tagList;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Start scan device
  void startScanning() async {
    await UHFManager.scanDevices(true);
  }

  // Connect to Device via Mac address
  Future<void> _connectRFID(String mac) async {
    bool connectResult = await _uhfManager.connect(mac);
    if (!connectResult) {
      print("Connection failed");
    } else {
      print("Connected successfully");
    }
  }

  // UI The function connects to the device
  void _connectToDevice(String name, String mac) {
    Navigator.of(context).pop(); // Đóng dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Device'),
          content: Text('Đang kết nối với $name ($mac)...'),
          actions: [
            TextButton(
              onPressed: () {
               _connectRFID(mac);
                Navigator.of(context).pop(); // Đóng thông báo kết nối
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show popup device list
  void _showBluetoothDevicesDialog() async {
    // Bắt đầu quét thiết bị
    startScanning();

    // Hiển thị popup chờ
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng khi nhấn ngoài
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Đang quét thiết bị...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Vui lòng đợi...'),
            ],
          ),
        );
      },
    );

    // Chờ 10 giây (thời gian quét)
    await Future.delayed(const Duration(seconds: 10));
    // await Future.delayed(const Duration(seconds: 20));

    // Đóng popup chờ
    Navigator.of(context).pop();

    // Hiển thị danh sách thiết bị
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Danh sách thiết bị Bluetooth'),
          content: SizedBox(
            // Đặt chiều cao cố định cho danh sách
            height: 250,
            width: double.maxFinite,
            child:
            bluetoothDevices.isEmpty
                ? const Center(
              child: Text('Không tìm thấy thiết bị nào'),
            )
                :
            ListView.builder(
              itemCount: bluetoothDevices.length,
              itemBuilder: (context, index) {
                final device = bluetoothDevices[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(device['name'] ?? 'Unknown'),
                  subtitle: Text(device['address'] ?? 'Unknown'),
                  onTap: () {
                    _connectToDevice(device['name']!, device['address']!);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  // Get tag by button and add to list
  void fetchTags() async {
    List<Map<String, String>> tags = await _uhfManager.singleRead();
    setState(() {
      _tags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("R5 Settings"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color.fromARGB(255, 206, 220, 214),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kết nối đến R5',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
               TextButton(
                 onPressed: _showBluetoothDevicesDialog,
                 style: TextButton.styleFrom(

                   foregroundColor: Colors.white, // Màu văn bản
                   backgroundColor: const Color.fromARGB(255, 8, 117, 69), // Màu nền
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(10), // Bo góc
                   ),
                 ),
                 child:  const Text('Kêt nối',style: TextStyle(fontSize: 18),),
               ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: fetchTags,
                  style: TextButton.styleFrom(

                    foregroundColor: Colors.white, // Màu văn bản
                    backgroundColor: const Color.fromARGB(255, 8, 117, 69), // Màu nền
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bo góc
                    ),
                  ),
                  child:  const Text('Lấy mẫu', style: TextStyle(fontSize: 18),),
                )
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Danh sách lấy mẫu: ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Expanded(
              child: _tags.isEmpty
                  ? const Center(child: Text('No tags available'))
                  : ListView.builder(
                itemCount: _tags.length,
                itemBuilder: (context, index) {
                  final tag = _tags[index];
                  return ListTile(
                    title: Text("Tag Data: ${tag['tagData'] ?? ''}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tag EPC: ${tag['tagEpc'] ?? ''}"),
                        Text("Tag Count: ${tag['tagCount'] ?? ''}"),
                        Text("Tag User: ${tag['tagUser'] ?? ''}"),
                        Text("Tag RSSI: ${tag['tagRssi'] ?? ''}"),
                        Text("Tag TID: ${tag['tagTid'] ?? ''}"),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            )

            //SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
