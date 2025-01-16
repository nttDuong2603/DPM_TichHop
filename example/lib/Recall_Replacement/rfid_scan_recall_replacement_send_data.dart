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
// import '../utils/scan_count_modal.dart';
// import '../utils/key_event_channel.dart';
//
//
// class RfidScanningPage extends StatefulWidget {
//
//   final CalendarRecallReplacement event;
//   final bool isRecallScan;
//   const RfidScanningPage ({Key? key, required this.event, required this.isRecallScan}) : super(key: key);
//
//   @override
//   State<RfidScanningPage> createState() => _RfidScanningPageState();
// }
//
// class _RfidScanningPageState extends State<RfidScanningPage> {
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
//   StreamSubscription<dynamic>? _tagsSubscription;
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
//       onKeyReceived: startRfidScan,
//     ).initialize();
//   }
//
//
//   @override
//   void dispose() {
//     super.dispose();
//     _updateStreamController.close();
//     _tagsSubscription?.cancel();  // Hủy lắng nghe sự kiện RFID
//     _updateStreamController.close();  // Đóng StreamController
//     closeAll();
//   }
//
//   closeAll() {
//     RfidC72Plugin.close;
//   }
//
//   Future<void> _initDatabase() async {
//     await _databaseHelper.initDatabase();
//   }
//   // Future<void> initPlatformState() async {
//   //   String platformVersion;
//   //   print('StrDebug: initPlatformState');
//   //   try {
//   //     platformVersion = (await RfidC72Plugin.platformVersion)!;
//   //   } on PlatformException {
//   //     platformVersion = 'Failed to get platform version.';
//   //   }
//   //   // RfidC72Plugin.tagsStatusStream.receiveBroadcastStream().listen((barcode) {
//   //   //   print('Barcode scanned: $barcode');
//   //   // });
//   //   RfidC72Plugin.connectedStatusStream
//   //       .receiveBroadcastStream()
//   //       .listen(updateIsConnected);
//   //   RfidC72Plugin.tagsStatusStream.receiveBroadcastStream().listen(updateTags);
//   //   await RfidC72Plugin.connect;
//   //   await _initDatabase();
//   //   if (!mounted) return;
//   //   setState(() {
//   //     _platformVersion = platformVersion;
//   //     print('Connection successful');
//   //     _isLoading = false;
//   //   });
//   // }
//   Future<void> initPlatformState() async {
//     String platformVersion;
//     print('StrDebug: initPlatformState');
//     try {
//       platformVersion = (await RfidC72Plugin.platformVersion)!;
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }
//
//     // Kiểm tra nếu chưa có lắng nghe
//     if (_tagsSubscription == null) {
//       _tagsSubscription = RfidC72Plugin.tagsStatusStream
//           .receiveBroadcastStream()
//           .listen(updateTags); // Lắng nghe sự kiện quét mã
//
//       RfidC72Plugin.connectedStatusStream
//           .receiveBroadcastStream()
//           .listen(updateIsConnected); // Lắng nghe sự kiện kết nối
//     }
//
//     await RfidC72Plugin.connect;
//     await _initDatabase();
//
//     if (!mounted) return;
//
//     setState(() {
//       _platformVersion = platformVersion;
//       _isLoading = false;
//     });
//   }
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
//   void _showScanningModal() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         // Trả về widget dialog
//         return Center(
//           child: Dialog(
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             child: Container(
//               // Nội dung dialog
//               child: SavedTagsModal(
//                 updateStream: _updateStreamController.stream,
//               ),
//             ),
//           ),
//         );
//       },
//     ).then((_) => _isDialogShown = false); // Cập nhật trạng thái khi dialog đóng
//     _isDialogShown = true;
//   }
//   void updateTags(dynamic result) async {
//     if (_data.isEmpty) { // Chỉ cho phép quét khi chưa có mã RFID nào được quét
//       List<TagEpcLBD> newData = TagEpcLBD.parseTags(result);
//
//       if (newData.isNotEmpty) {
//         TagEpcLBD firstTag = newData.first; // Lấy thẻ đầu tiên được quét
//
//         // Thêm thẻ đầu tiên vào danh sách và phát âm thanh
//         _data.add(firstTag);
//         _playScanSound();
//
//         setState(() {
//           isScanning = false; // Đánh dấu đã quét xong
//           successfullySaved = _data.length; // Cập nhật trạng thái
//         });
//
//         // Gửi sự kiện cập nhật sau khi quét xong
//         sendUpdateEvent(successfullySaved);
//         // Dừng quét sau khi nhận được thẻ đầu tiên
//         await RfidC72Plugin.stop; // Dừng quét
//         setState(() {
//           _isContinuousCall = false;
//         });
//         await _showConfirmationDialog();
//
//         // Đóng modal đang hiển thị
//         Navigator.of(context, rootNavigator: true).pop(); // Đóng modal đang mở
//       }
//     }
//   }
//   void sendUpdateEvent(int value) {
//     _updateStreamController.add(value);
//   }
//
//   Future<void> startRfidScan() async {
//     if (_isContinuousCall) {
//       // Dừng quét
//       await RfidC72Plugin.stop;
//       _isContinuousCall = false;
//       // Đóng dialog quét nếu nó đang hiển thị
//       if (_isDialogShown) {
//         Navigator.of(context, rootNavigator: true).pop('dialog');
//       }
//       // Chờ một khoảng thời gian ngắn (nếu cần) và mở dialog xác nhận
//       if (!showConfirmationDialog) {
//         Future.delayed(Duration(milliseconds: 100), () {
//           _showConfirmationDialog();
//           showConfirmationDialog = true;
//         });
//       }
//     } else {
//       if(!showConfirmationDialog){
//         await RfidC72Plugin.startSingle;
//         // _data.clear();
//         _isContinuousCall = true;
//         if (!_isDialogShown) {
//           _showScanningModal();
//         }
//       }
//     }
//     setState(() {
//       _isShowModal = _isContinuousCall;
//     });
//   }
//
//   Future<void> stopRfidScan() async {
//     await RfidC72Plugin.stop; // Dừng quét RFID
//     await RfidC72Plugin.close; // Ngắt kết nối máy quét
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
//   // Hiển thị dialog xác nhận
//   Future<void> _showConfirmationDialog() async {
//     print("isRecallScan: $isRecallScan");
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             'Lưu mã chip?',
//             style: TextStyle(
//                 color: AppColor.mainText,
//                 fontWeight: FontWeight.bold
//             ),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 SizedBox(height: 20),
//                 Container(
//                   // Giới hạn chiều cao của Container chứa ListTile
//                   height: 100, // Hoặc một giá trị phù hợp với nhu cầu của bạn
//                   child: _data.isNotEmpty
//                       ? ListTile(
//                     title: Text(
//                       '1. ${_convertTagIfNeeded(_data.last.epc)}', // Chỉ hiển thị mã cuối cùng
//                       style: TextStyle(
//                         color: AppColor.mainText,
//                       ),
//                     ),
//                   )
//                       : Center(
//                     child: Text(
//                       'Không có mã nào được quét',
//                       style: TextStyle(
//                         color: AppColor.mainText,
//                       ),
//                     ),
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
//               child: Text(
//                 'Hủy Bỏ',
//                 style: TextStyle(
//                   color: Colors.white,
//                 ),
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
//             SizedBox(width: 8),
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
//               child: Text(
//                 'Xác Nhận',
//                 style: TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//               onPressed: () async {
//                 // Chỉ lưu mã cuối cùng từ danh sách _data
//                 if (_data.isNotEmpty) {
//                   if (isRecallScan) {
//                     // Nếu là quét mã thu hồi
//                     await saveData('recall_${event.idLTHTT}', [_data.last]);  // Ghi đè dữ liệu, chỉ lưu mã cuối cùng
//                     await _storage.write(key: 'recall_${event.idLTHTT}_length', value: '1');
//                   } else {
//                     // Nếu là quét mã thay thế
//                     await saveRecallReplaceData('replace_${event.idLTHTT}', [_data.last]);  // Ghi đè dữ liệu, chỉ lưu mã cuối cùng
//                     await _storageRecallReplace.write(key: 'replace_${event.idLTHTT}_length', value: '1');
//                   }
//                 }
//
//                 Navigator.of(context).pop();
//                 setState(() {
//                   loadTagCount();
//                   loadRecallReplaceTagCount();
//                   showConfirmationDialog = false;
//                   _selectedScanningMethod = 'qr';
//                   _isScanningStarted = false;
//                   _isScanningRecallReplaceStarted = false;
//                 });
//               },
//             ),
//           ],
//         );
//       },
//     );
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
//             onPressed: isScanning ? stopRfidScan : startRfidScan,
//             child: Text(isScanning ? 'Dừng quét QR code' : 'Bắt đầu QR code'),
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
