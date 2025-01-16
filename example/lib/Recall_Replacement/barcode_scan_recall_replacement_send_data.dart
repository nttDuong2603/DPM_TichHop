// import 'package:flutter/material.dart';
// import 'package:rfid_c72_plugin/rfid_c72_plugin.dart';
// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import '../Assign_Packing_Information/model_information_package.dart';
// import 'package:rfid_c72_plugin_example/utils/common_functions.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'recall_replacement_model.dart';
// import 'package:just_audio/just_audio.dart';
// import 'dart:collection';
// import 'recall_replacement_database.dart';
// import '../utils/key_event_channel.dart';
//
//
// class QrCodeScanningPage extends StatefulWidget {
//
//   final CalendarRecallReplacement event;
//   final bool isRecallScan;
//
//   const QrCodeScanningPage ({Key? key, required this.event, required this.isRecallScan}) : super(key: key);
//
//   @override
//   State<QrCodeScanningPage> createState() => _QrCodeScanningPageState();
// }
//
// class _QrCodeScanningPageState extends State<QrCodeScanningPage> {
//   final StreamController<int> _updateStreamController = StreamController<int>.broadcast(); // Tạo StreamController
//   late CalendarRecallReplacement event;
//   final CalendarRecallReplacementDatabaseHelper databaseHelper = CalendarRecallReplacementDatabaseHelper();
//   String _platformVersion = 'Unknown';
//   final bool _isHaveSavedData = false;
//   final bool _isStarted = false;
//   final bool _isEmptyTags = false;
//   bool _isConnected = false;
//   bool _isLoading = true;
//   int _totalEPC = 0, _invalidEPC = 0, _scannedEPC = 0;
//   int currentPage = 0;
//   int itemsPerPage = 5;
//   late CalendarRecallReplacementDatabaseHelper _databaseHelper;
//   List<TagEpcLBD> paginatedData = [];
//   int targetTotalEPC = 100;
//   late Timer _timer;
//   TextEditingController _agencyNameController = TextEditingController();
//   TextEditingController _goodsNameController = TextEditingController();
//   bool confirm = false;
//   List<TagEpcLBD> _data = [];
//   final List<String> _EPC = [];
//   List<TagEpcLBD> _successfulTags = [];
//   int totalTags = 0;
//   static int _value  = 0;
//   int successfullySaved = 0;
//   int previousSavedCount = 0;
//   bool isScanning = false;
//   Queue<List<TagEpcLBD>> p = Queue<List<TagEpcLBD>>();
//   bool _isNotified = false;
//   bool _isShowModal = false;
//   List<TagEpcLBD> newData = [];
//   int saveCount = 0;
//   int a = 0;
//   int TotalScan = 0;
//   int scannedTagsCount = 0;
//   final _storage = FlutterSecureStorage();
//   final _storageRecallReplace = FlutterSecureStorage();
//   String _selectedAgencyName = '';
//   String _selectedGoodsName = '';
//   int tagCount = 0;
//   int tagRecallReplaceCount = 0;
//   bool _isContinuousCall = false;
//   bool _is2dscanCall = false;
//   AudioPlayer _audioPlayer = AudioPlayer();
//   bool dadongbao = false;
//   Stream<int> get updateStream => _updateStreamController.stream;
//   bool _isSnackBarDisplayed = false;
//   int successCountRecall = 0;
//   int failCountRecall = 0;
//   int _saveCounter = 0; // Biến toàn cục để theo dõi số lần lưu
//   final secureRecallStorage = FlutterSecureStorage();
//   final secureStorage = FlutterSecureStorage();
//   final _storageAcountCode = FlutterSecureStorage();
//   final secureLTHStorage = FlutterSecureStorage();
//   bool dadongbo = false;
//   bool _isDialogShown = false;
//   bool showConfirmationDialog = false;
//   bool _isScanningMethodSelected = false; // Trạng thái để kiểm tra phương thức quét đã chọn hay chưa
//   String _selectedScanningMethod = 'qr'; // Lưu trữ phương thức quét đã chọn
//   bool isShowModal = false;
//   List<EPCInforRecall> EPCInforRecalls = [];
//   List<EPCInforRecall> EPCInforReplaces = [];
//   bool _isScanningStarted = false; // Kiểm tra xem việc quét đã bắt đầu chưa
//   bool _isScanningRecallReplaceStarted = false; // Kiểm tra xem việc quét đã bắt đầu chưa
//   bool isRecallScan = false; // Mặc định là quét mã thu hồi
//   List<String> tagRecallReplaceList = [];
//   List<String> tagsList = [];
//   String IP = 'http://192.168.19.69:5088';
//   StreamSubscription<dynamic>? _barcodeSubscription;
//   @override
//   void initState() {
//     super.initState();
//     event = widget.event;
//     _databaseHelper = CalendarRecallReplacementDatabaseHelper();
//     _initDatabase();
//     initPlatformState();
//     loadSuccessfullySaved(event.idLTHTT);
//     _agencyNameController.text = _selectedAgencyName;
//     _goodsNameController.text = _selectedGoodsName;
//     loadTagCount();
//     loadRecallReplaceTagCount();
//     KeyEventChannel(
//       onKeyReceived: startBarCode,
//     ).initialize();
//   }
//
//
//   @override
//   void dispose() {
//     _barcodeSubscription?.cancel();  // Hủy lắng nghe mã vạch khi không cần
//     _updateStreamController.close();  // Đóng StreamController
//     super.dispose();
//   }
//
//
//   closeAll() {
//     RfidC72Plugin.closeScan;
//   }
//
//   Future<void> _initDatabase() async {
//     await _databaseHelper.initDatabase();
//   }
//   Future<void> initPlatformState() async {
//     String platformVersion;
//     print('StrDebug: initPlatformState');
//     try {
//       platformVersion = (await RfidC72Plugin.platformVersion)!;
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }
//
//     // Lắng nghe sự kiện mã QR khi khởi tạo
//     _barcodeSubscription = RfidC72Plugin.tagsStatusStream.receiveBroadcastStream().listen((scannedCode) async {
//       if (scannedCode != null && scannedCode.isNotEmpty) {
//         // Xử lý mã quét được
//         String? extractedCode = _extractCodeFromUrl(scannedCode);
//
//         if (extractedCode != null) {
//           setState(() {
//             _data.clear();
//             _data.add(TagEpcLBD(epc: extractedCode)); // Thêm mã QR vào danh sách EPC
//             _totalEPC = _data.length; // Cập nhật số lượng EPC quét được
//             _is2dscanCall = false; // Dừng quét
//           });
//
//           // Dừng quét sau khi mã QR đã được xử lý
//           await RfidC72Plugin.stopScan;
//
//           // Ngắt kết nối máy quét sau khi dừng quét
//           await RfidC72Plugin.closeScan;
//
//           // Hiển thị modal lưu mã chip (nếu cần)
//           await _showBarcodeConfirmationDialog();
//         }
//       }
//     });
//
//     // Kết nối mã vạch khi khởi tạo
//     await RfidC72Plugin.connectBarcode;
//     await _initDatabase();
//
//     if (!mounted) return;
//
//     setState(() {
//       _platformVersion = platformVersion;
//       _isLoading = false;
//     });
//   }
//
//
//   Future<void> saveSuccessfullySaved(String eventId, int value) async {
//     final secureStorage = FlutterSecureStorage();
//     await secureStorage.write(key: '${eventId}_length', value: value.toString());
//   }
//
//   Future<void> loadSuccessfullySaved(String eventId) async {
//     String? savedLength = await _storage.read(key: '${eventId}_length');
//     if (savedLength != null) {
//       setState(() {
//         successfullySaved = int.parse(savedLength);
//       });
//     }
//   }
//   void updateIsConnected(dynamic isConnected) {
//     _isConnected = isConnected;
//     print(' successful');
//   }
//   Future<void> _playScanSound() async {
//     try {
//       await _audioPlayer.setAsset('assets/sound/Bip.mp3');
//       await _audioPlayer.play();
//     } catch (e) {
//       print("$e");
//     }
//   }
//   void updateTags(dynamic result) async {
//     String? extractedCode = _extractCodeFromUrl(result);
//
//     if (extractedCode != null) {
//       // Thêm mã QR vào danh sách EPC và phát âm thanh
//       _data.add(TagEpcLBD(epc: extractedCode));
//       _playScanSound();
//
//       if (mounted) {
//         setState(() {
//           isScanning = false; // Đánh dấu đã quét xong
//           successfullySaved = _data.length; // Cập nhật trạng thái
//         });
//       }
//
//       // Gửi sự kiện cập nhật sau khi quét xong
//       sendUpdateEvent(successfullySaved);
//
//       // Dừng quét
//       await RfidC72Plugin.stop;
//       setState(() {
//         _isContinuousCall = false;
//       });
//       await _showBarcodeConfirmationDialog();
//         // Đóng modal đang hiển thị
//         Navigator.of(context, rootNavigator: true).pop(); // Đóng modal đang mở
//     }
//   }
//   void sendUpdateEvent(int value) {
//     _updateStreamController.add(value);
//   }
//
//   String? _extractCodeFromUrl(String url) {
//     try {
//       Uri uri = Uri.parse(url);
//       return uri.queryParameters['id']; // Trả về phần mã phía sau `id=`
//     } catch (e) {
//       print("Error parsing URL: $e");
//       return null; // Trả về null nếu có lỗi khi phân tích URL
//     }
//   }
//
//   Future<void> startBarCode() async {
//     setState(() {
//       _is2dscanCall = !_is2dscanCall; // Thay đổi trạng thái quét
//     });
//
//     if (_is2dscanCall) {
//       // Kết nối Barcode scanner (đã được thực hiện trong initPlatformState)
//       await RfidC72Plugin.scanBarcode; // Bắt đầu quét mã QR
//     } else {
//       // Dừng quét nếu đang quét
//       await RfidC72Plugin.stopScan;
//
//       // Không cần hủy lắng nghe ở đây, vì lắng nghe đã được xử lý trong initPlatformState
//     }
//   }
//
//
//   Future<void> stopRfidScan() async {
//     await RfidC72Plugin.stopScan; // Dừng quét RFID
//     await RfidC72Plugin.closeScan; // Ngắt kết nối máy quét
//     setState(() {
//       isScanning = false;
//       _isContinuousCall = false;
//     });
//   }
//
//   void loadTagCount() async {
//     if (widget.event.idLTHTT!= null) { // Giả sử widget.event là sự kiện được chọn và có thuộc tính id
//       List<TagEpcLBD> tags = await loadData('recall_${event.idLTHTT}');
//       setState(() {
//         tagCount = tags.length; // Cập nhật số lượng tags vào biến trạng thái
//         tagsList = tags.map((tag) => tag.epc).toList();
//       });
//     }
//   }
//
//   void loadRecallReplaceTagCount() async {
//     if (widget.event.idLTHTT!= null) { // Giả sử widget.event là sự kiện được chọn và có thuộc tính id
//       List<TagEpcLBD> tag = await loadRecallReplaceData('replace_${event.idLTHTT}');
//       setState(() {
//         tagRecallReplaceCount = tag.length; // Cập nhật số lượng tags vào biến trạng thái
//         tagRecallReplaceList = tag.map((tag) => tag.epc).toList();
//       });
//     }
//   }
//
//   // Hiển thị modal khi quét
//   Future<void> _showBarcodeConfirmationDialog() async {
//     print("isRecallScan: $isRecallScan");
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Lưu mã chip?',
//             style: TextStyle(
//                 color: AppColor.mainText,
//                 fontWeight: FontWeight.bold
//             ),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 // Text('Bạn có chắc chắn muốn lưu kết quả quét không?'),
//                 SizedBox(height: 20),
//                 Container(
//                   // Giới hạn chiều cao của Container chứa ListView.builder
//                   height: 200, // Hoặc một giá trị phù hợp với nhu cầu của bạn
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: _data.length,
//                     itemBuilder: (context, index) {
//                       String tagepc = _data[index].epc;
//                       return ListTile(
//                         title:
//                         Text(
//                           '${index+1}.$tagepc',
//                           style: TextStyle(
//                               color: AppColor.mainText
//                           ),
//                         ) ,
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
//                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                   RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
//                   ),
//                 ),
//                 fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
//               ),
//               child: Text('Hủy Bỏ',
//                   style:TextStyle(
//                     color: Colors.white,
//                   )
//               ),
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 await RfidC72Plugin.clearData;
//                 setState(() {
//                   successfullySaved = tagCount;
//                   _data.clear();
//                   showConfirmationDialog = false;
//                 });
//               },
//             ),
//             SizedBox(width: 8,),
//             TextButton(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
//                     ),
//                   ),
//                   fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
//                 ),
//                 child: Text('Xác Nhận',
//                     style:TextStyle(
//                       color: Colors.white,
//                     )
//                 ),
//                 onPressed: () async {
//                   // Lưu trực tiếp danh sách mã mới mà không nối tiếp danh sách cũ
//                   if (isRecallScan) {
//                     // Nếu là quét mã thu hồi
//                     await saveData('recall_${event.idLTHTT}', _data);  // Ghi đè dữ liệu
//                     await _storage.write(key: 'recall_${event.idLTHTT}_length', value: _data.length.toString());
//                   } else {
//                     // Nếu là quét mã thay thế
//                     await saveRecallReplaceData('replace_${event.idLTHTT}', _data);  // Ghi đè dữ liệu
//                     await _storageRecallReplace.write(key: 'replace_${event.idLTHTT}_length', value: _data.length.toString());
//                   }
//                   Navigator.pop(context, true);
//                   // Navigator.of(context).pop();
//                   setState(() {
//                     loadTagCount();
//                     loadRecallReplaceTagCount();
//                     showConfirmationDialog = false;
//                     _selectedScanningMethod = 'qr';
//                     _isScanningStarted = false;
//                     _isScanningRecallReplaceStarted = false;
//                   });
//                 }
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   String _convertTagIfNeeded(String tagepc) {
//     // Kiểm tra nếu là EPC thì chuyển đổi, còn không thì để nguyên
//     if (RegExp(r'^[0-9A-Fa-f]+$').hasMatch(tagepc)) {
//       return CommonFunction().hexToString(tagepc);
//     }
//     return tagepc;
//   }
//
//   Future<void> saveData(String key, List<TagEpcLBD> data) async {
//     // Chuyển đổi danh sách tags thành chuỗi JSON sử dụng phương thức toMap()
//     String dataString = TagEpcLBD.tagsToJson(data);
//     await _storage.write(key: key, value: dataString);
//   }
//
//   Future<List<TagEpcLBD>> loadData(String key) async {
//     String? dataString = await _storage.read(key: key);
//     if (dataString != null) {
//       // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpcLBD
//       return TagEpcLBD.parseTags(dataString);
//     }
//     return [];
//   }
//
//   Future<void> saveRecallReplaceData(String key, List<TagEpcLBD> data) async {
//     // Chuyển đổi danh sách tags mới thành chuỗi JSON
//     String dataString = TagEpcLBD.tagsToJson(data);
//
//     // Lưu chuỗi JSON vào bộ nhớ bảo mật
//     await _storageRecallReplace.write(key: key, value: dataString);
//   }
//
//
//   Future<List<TagEpcLBD>> loadRecallReplaceData(String key) async {
//     String? dataString = await _storageRecallReplace.read(key: key);
//     if (dataString != null) {
//       // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpcLBD
//       return TagEpcLBD.parseTags(dataString);
//     }
//     return [];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Quét mã RFID'),
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: isScanning ? stopRfidScan : startBarCode,
//             child: Text(isScanning ? 'Dừng quét RFID' : 'Bắt đầu quét RFID'),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _data.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text('Tag RFID: ${_data[index]}'),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
