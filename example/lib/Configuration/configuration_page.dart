import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../DevicesConfiguration/chainway_R5_RFID/chainwayR5Rfid.dart';
import '../DevicesConfiguration/chainway_R5_RFID/uhfManager.dart';
import '../utils/app_color.dart';
import '../utils/app_config.dart';


class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({Key? key}) : super(key: key);

  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  final TextEditingController _ipController = TextEditingController();
  FlutterSecureStorage storage = FlutterSecureStorage();
  String? selectedDevice = 'C5'; // Giá trị mặc định
  final UHFManager _uhfManager = UHFManager();
  List<Map<String, String>> bluetoothDevices = [];
  String? connectedDeviceName;
  String? connectedDeviceMac;



  @override
  void initState() {
    super.initState();
    _loadIPFromStorage();
  }

  // Đọc IP từ Secure Storage
  Future<void> _loadIPFromStorage() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String? savedIP = await storage.read(key: 'app_ip');
    if (savedIP != null && savedIP.isNotEmpty) {
      setState(() {
        _ipController.text = savedIP;
      });
    }
  }

  // Start scan device
  void startScanning() async {
    await UHFManager.scanDevices(true);
  }

  Future<void> _saveIPToStorage() async {
    String newIP = _ipController.text.trim();
    if (newIP.isNotEmpty) {
      AppConfig.IP = newIP;  // Cập nhật IP trong AppConfig
      await storage.write(key: 'app_ip', value: newIP);  // Lưu vào Secure Storage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("IP đã được cập nhật"),
          backgroundColor: Colors.green,  // Màu xanh lá cây (hoặc bạn có thể dùng màu khác tùy thích)
        ),
      );
      setState(() {
        AppConfig.IP = newIP;
      });
      // Quay lại trang LoginPage sau khi lưu thành công
      Navigator.pop(context, true);  // Quay lại trang trước đó (LoginPage)
    }
  }


  // // Gọi hàm lưu cả IP và thiết bị quét
  // Future<void> _saveConfiguration() async {
  //   await _saveIPToStorage(); // Lưu địa chỉ IP
  //   await _saveDeviceToStorage(); // Lưu thiết bị quét
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text("Lưu cấu hình thành công"),
  //       backgroundColor: Colors.green,
  //     ),
  //   );
  //   Navigator.pop(context, true); // Quay lại trang trước
  // }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.12, // Chiều cao thanh công cụ
        backgroundColor: const Color(0xFFE9EBF1),
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.5),
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.03), // Khoảng cách từ mép trái
          child: Container(
            width: screenWidth * 0.2, // Chiều rộng logo
            height: screenHeight * 0.15, // Chiều cao logo
            child: Image.asset(
              'assets/image/logoJVF_RFID.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          'Cấu hình IP',
          style: TextStyle(
            fontSize: screenWidth * 0.07, // Kích thước chữ
            fontWeight: FontWeight.bold,
            color: AppColor.mainText,
          ),
        ),
        actions: [],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: screenHeight *0.05, left: screenWidth * 0.05, right: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nhập địa chỉ IP',
              style: TextStyle(
                  fontSize: 26,
                  color: AppColor.mainText,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 20),
            TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: 'Nhập địa chỉ IP',
                  labelStyle: TextStyle(
                      color: Color(0xFFA2A4A8),
                      fontWeight: FontWeight.normal,
                      fontSize: 22
                  ),
                  filled: true,
                  fillColor: Color(0xFFEBEDEC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Color(0xFFEBEDEC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEBEDEC)),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEBEDEC)),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                )
            ),
          ]
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          style: TextButton.styleFrom(
            backgroundColor: AppColor.mainText,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2, vertical: screenHeight * 0.022),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.048),
            ),
            minimumSize: Size(screenWidth * 0.8, 0),
          ),
          onPressed:(){
            _saveIPToStorage();
          },
          child: Text("Lưu IP",
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
