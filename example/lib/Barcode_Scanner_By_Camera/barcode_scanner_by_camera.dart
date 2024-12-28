import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:rfid_c72_plugin_example/Assign_Packing_Information/model_information_package.dart';

class BarcodeScannerInPhoneController {

  // Phương thức quét mã QR và trả về kết quả mã sản phẩm đã trích xuất (nếu URL hợp lệ)
  Future<String?> scanQRCode() async {
    try {
      // Quét mã QR và nhận kết quả
      final code = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);

      // Kiểm tra nếu mã quét được là URL hợp lệ và có chứa "check/"
      if ((code.startsWith('http://') || code.startsWith('https://')) && code.contains("check/")) {
        // Nếu là URL, trích xuất mã sản phẩm từ URL và trả về
        String? extractedCode = _extractCodeFromUrl(code);
        return extractedCode;
      } else {
        // Nếu không phải URL, trả về mã QR nguyên bản
        return code;
      }

    } on PlatformException {
      print("Lỗi khi quét mã QR");
      return null; // Trả về null nếu có lỗi khi quét
    }
  }

  String? _extractCodeFromUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      return uri.queryParameters['id']; // Trả về phần mã phía sau `id=`
    } catch (e) {
      print("Error parsing URL: $e");
      return null; // Trả về null nếu có lỗi khi phân tích URL
    }
  }
}

