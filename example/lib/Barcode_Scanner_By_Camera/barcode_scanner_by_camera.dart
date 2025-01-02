import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:rfid_c72_plugin_example/Assign_Packing_Information/model_information_package.dart';
class BarcodeScannerInPhoneController {

  Future<String?> scanQRCode() async {
    try {
      // Scan QR code and get results
      final code = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', //Color of the scanning border
        'Cancel', // Cancel button
        true,     //Flash is allowed
        ScanMode.BARCODE,
      );

      if (code == '-1') {
        // User presses "Cancel", null is returned
        print("Người dùng đã hủy quét mã");
        return null;
      }

      //Check if the scanned code is a valid URL and contains "check/"
      if ((code.startsWith('http://') || code.startsWith('https://')) && code.contains("check/")) {
        // Extract product code from URL and return
        return _extractCodeFromUrl(code);
      }

      // If not a URL, returns the original QR code
      return code;
    } on PlatformException catch (e) {
      print("Lỗi từ thư viện FlutterBarcodeScanner: $e");
      return null;
    } catch (e) {
      print("Lỗi không mong đợi khi quét mã QR: $e");
      return null;
    }
  }


  String? _extractCodeFromUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      return uri.queryParameters['id']; // Returns the code after `id=`
    } catch (e) {
      print("Error parsing URL: $e");
      return null; // Returns null if there was an error parsing the URL
    }
  }
}
