// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:rfid_c72_plugin/rfid_c72_plugin.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:just_audio/just_audio.dart';
// import 'dart:collection';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:rfid_c72_plugin_example/utils/common_functions.dart';
// import 'dart:async';
// import '../Assign_Packing_Information/model_information_package.dart';
// import 'package:intl/intl.dart';
// import 'dart:io';
// import 'package:external_path/external_path.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../utils/scan_count_modal.dart';
// import '../utils/key_event_channel.dart';
// import 'recall_replacement_model.dart';
// import 'recall_replacement_database.dart';
// import 'rfid_scan_recall_replacement_send_data.dart';
// import 'barcode_scan_recall_replacement_send_data.dart';
//
// class SendDataRecallReplacement extends StatefulWidget {
//
//   final CalendarRecallReplacement event;
//   final Function(CalendarRecallReplacement) onDeleteEvent;
//   const SendDataRecallReplacement({Key? key, required this.event, required this.onDeleteEvent}) : super(key: key);
//
//   @override
//   State<SendDataRecallReplacement> createState() => _SendDataRecallReplacementState();
// }
//
// class _SendDataRecallReplacementState extends State<SendDataRecallReplacement> {
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
//   // String IP = 'https://jvf-admin.rynansaas.com';
//
//   @override
//   void initState() {
//     super.initState();
//     event = widget.event;
//     _databaseHelper = CalendarRecallReplacementDatabaseHelper();
//     _initDatabase();
//     loadSuccessfullySaved(event.idLTHTT);
//     _agencyNameController.text = _selectedAgencyName;
//     _goodsNameController.text = _selectedGoodsName;
//     loadTagCount();
//     loadRecallReplaceTagCount();
//   }
//
//   Future<void> _initDatabase() async {
//     await _databaseHelper.initDatabase();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _updateStreamController.close();
//   }
//
//   Future<void> _playScanSound() async {
//     try {
//       await _audioPlayer.setAsset('assets/sound/Bip.mp3');
//       await _audioPlayer.play();
//     } catch (e) {
//       print("$e");
//     }
//   }
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
//
//   void sendUpdateEvent(int value) {
//     _updateStreamController.add(value);
//   }
//
//   void onDataReceived(int newData) {
//     sendUpdateEvent(newData);
//   }
//
// // Hàm để dừng timer
//   void stopTimer() {
//     _timer.cancel(); // Hủy timer
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
//   Future<void> stopScanning() async {
//     if (!_isSnackBarDisplayed) {
//       await RfidC72Plugin.stop;
//       _showSnackBar('Đã đạt đủ số lượng');
//       _isSnackBarDisplayed = true;
//       Navigator.pop(context);
//     }
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }
//
//   void updateIsConnected(dynamic isConnected) {
//     _isConnected = isConnected;
//     print(' successful');
//   }
//
//   void deleteEventFromCalendar() async {
//     try {
//       final dbHelper = CalendarRecallReplacementDatabaseHelper();
//
//       await dbHelper.deleteEvent(event);
//       widget.onDeleteEvent(event);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Xóa lịch thành công!'),
//           backgroundColor: Color(0xFF4EB47D),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       print('Lỗi khi xóa lichj: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Đã xảy ra lỗi khi xóa lịch!'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   void _showChipInformation(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Thông tin chip',
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: AppColor.mainText,
//                   ),
//                 ),
//                 FutureBuilder<List<TagEpcLBD>>(
//                   future: loadData(event.idLTHTT), // Sử dụng loadData với event.id
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     } else if (snapshot.hasError) {
//                       return Center(
//                         child: Text('Error: ${snapshot.error}'),
//                       );
//                     } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//                       return ListView.builder(
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         itemCount: snapshot.data!.length,
//                         itemBuilder: (context, index) {
//                           String epcString = CommonFunction().hexToString(snapshot.data![index].epc);
//                           // print(epcString);
//                           return ListTile(
//                             title: Text(
//                               '${index + 1}. $epcString',
//                               style: TextStyle(
//                                 color: AppColor.mainText,
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     } else {
//                       return Center(
//                         child: Text(
//                           'Không có dữ liệu',
//                           style: TextStyle(
//                             color: AppColor.mainText,
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showRecallReplaceChipInformation(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Thông tin chip',
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: AppColor.mainText,
//                   ),
//                 ),
//                 FutureBuilder<List<TagEpcLBD>>(
//                   future: loadRecallReplaceData(event.idLTHTT), // Sử dụng loadData với event.id
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     } else if (snapshot.hasError) {
//                       return Center(
//                         child: Text('Error: ${snapshot.error}'),
//                       );
//                     } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//                       return ListView.builder(
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         itemCount: snapshot.data!.length,
//                         itemBuilder: (context, index) {
//                           String epcString = snapshot.data![index].epc;
//                           // print(epcString);
//                           return ListTile(
//                             title: Text(
//                               '${index + 1}. $epcString',
//                               style: TextStyle(
//                                 color: AppColor.mainText,
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     } else {
//                       return Center(
//                         child: Text(
//                           'Không có dữ liệu',
//                           style: TextStyle(
//                             color: AppColor.mainText,
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
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
//   Future<void> saveTagsToSecureStorage(String calendarId, List<TagEpcLBD> tags) async {
//     // Serialize danh sách tag thành chuỗi JSON
//     List<Map<String, dynamic>> jsonTags = tags.map((tag) => tag.toJson()).toList();
//     String jsonString = jsonEncode(jsonTags);
//     // Sử dụng ID lịch như một phần của key khi lưu
//     await _storage.write(key: 'saved_tags_$calendarId', value: jsonString);
//   }
//
//   Future<List<TagEpcLBD>> loadTagsFromSecureStorage(String calendarId) async {
//     String? jsonString = await _storage.read(key: 'saved_tags_$calendarId');
//     if (jsonString == null) return [];
//     List<dynamic> jsonTags = jsonDecode(jsonString);
//     List<TagEpcLBD> tags = jsonTags.map((jsonTag) => TagEpcLBD.fromJson(jsonTag)).toList();
//     return tags;
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
//   void _closeModal() {
//     setState(() {
//       isShowModal = false;
//     });
//   }
//
//   void showModal() async{
//     setState(() {
//       isShowModal =true;
//     });
//     if(tagsList.isEmpty || tagRecallReplaceList.isEmpty ) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Không thể đồng bộ",style: TextStyle(
//               color: AppColor.mainText,
//               fontWeight: FontWeight.bold,
//             ),
//             ),
//             content: Text("Vui lòng kiểm tra lại dữ liệu quét.",
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: AppColor.mainText,
//                 )
//             ),
//             actions: <Widget>[
//               TextButton( style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
//                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                   RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
//                   ),
//                 ),
//                 fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
//               ),
//                 child: Text("Đóng", style: TextStyle(color: Colors.white),),
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Đóng cửa sổ dialog
//                 },
//               )
//             ],
//           );
//         },
//       ).then((_) {
//         _closeModal();  // Gọi hàm để đóng modal và cập nhật trạng thái
//       });
//     } else{
//       _showInfoEPCRecallDialog();
//     };
//   }
//   void _showInfoEPCRecallDialog() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter modalSetState) {
//             return SizedBox(
//               height: MediaQuery.of(context).size.height * 0.90,
//               child: Column(
//                 children: [
//                   Container(
//                     alignment: Alignment.topRight,
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.close,
//                         color: AppColor.mainText,
//                         size: 30.0,
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context); // Đóng modal
//                       },
//                     ),
//                   ),
//                   // Box chứa thông tin mã EPC bạn muốn thu hồi
//                   _buildEPCInfoSection('Thông tin mã EPC bạn muốn thu hồi', fetchEPCInfoRecallData()),
//                   // Box chứa thông tin mã EPC bạn muốn thay thế
//                   _buildEPCInfoSection('Thông tin mã EPC bạn muốn thay thế', fetchEPCInfoReplaceData()),
//                   // Nút "Bắt đầu đồng bộ"
//                   Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Center(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColor.mainText,
//                           padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.0),
//                           ),
//                           minimumSize: Size(200.0, 40.0), // Kích thước tối thiểu
//                         ),
//                         onPressed: () async {
//                           await startSyncProcess();
//                         },
//                         child: Text(
//                           'Bắt đầu đồng bộ',
//                           style: TextStyle(fontSize: 18, color: Colors.white),
//                         ),
//                       )
//
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
// // Hàm tiện ích để xây dựng mỗi phần thông tin EPC
//   Widget _buildEPCInfoSection(String title, Future<List<EPCInforRecall>> futureData) {
//     return Expanded(
//       child: Column(
//         children: [
//           // Header phần tiêu đề
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Container(
//                   padding: EdgeInsets.fromLTRB(20, 5, 10, 0),
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: AppColor.mainText,
//                     ),
//                     maxLines: 2, // Giới hạn số dòng tối đa
//                     overflow: TextOverflow.ellipsis, // Hiển thị dấu "..." nếu văn bản quá dài
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 5),
//
//           // FutureBuilder để hiển thị dữ liệu EPC
//           Expanded(
//             child: FutureBuilder<List<EPCInforRecall>>(
//               future: futureData, // Gọi hàm lấy dữ liệu EPC
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text('Không có dữ liệu EPC.'));
//                 }
//                 List<EPCInforRecall> epcData = snapshot.data!;
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: epcData.length,
//                   itemBuilder: (context, index) {
//                     EPCInforRecall epcInfo = epcData[index];
//                     return Container(
//                       margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: 'Mã EPC: ',
//                                   style: TextStyle(fontSize: 16, color: AppColor.mainText),
//                                 ),
//                                 TextSpan(
//                                   text: epcInfo.EPC,
//                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.mainText),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 5),
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: 'Tên sản phẩm: ',
//                                   style: TextStyle(fontSize: 14, color: AppColor.mainText),
//                                 ),
//                                 TextSpan(
//                                   text: epcInfo.ProductCode,
//                                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColor.mainText),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 5,),
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: 'Tình trạng Đóng bao: ',
//                                   style: TextStyle(fontSize: 14, color: AppColor.mainText),
//                                 ),
//                                 TextSpan(
//                                   text: epcInfo.PackageStatus == 'true' ? 'Đã đóng bao': ' ',
//                                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColor.mainText),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 5),
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: 'Tình trạng Phân phối: ',
//                                   style: TextStyle(fontSize: 14, color: AppColor.mainText),
//                                 ),
//                                 TextSpan(
//                                   text: epcInfo.DistributionStatus == 'true' ? 'Đã phân phối' : ' ',
//                                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColor.mainText),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 5),
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: 'Phân phối kho thuê: ',
//                                   style: TextStyle(fontSize: 14, color: AppColor.mainText),
//                                 ),
//                                 TextSpan(
//                                   text: epcInfo.WarehouseRentalDistributionStatus == 'true' ? 'Đã phân phối kho thuê': ' ',
//                                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColor.mainText),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//   Future<String?> _getMaTKFromSecureStorage() async {
//     return await _storageAcountCode.read(key: 'maTK');
//   }
//
//   String getSentTagsKey(String eventId) {
//     return 'sent_tags_$eventId';
//   }
//
//   Future<void> saveTagState(TagEpcLBD tag) async {
//     final secureLTHStorage = FlutterSecureStorage();
//     String key = 'tag_${tag.epc}';
//     String json = jsonEncode(tag.toJson());
//     await secureLTHStorage.write(key: key, value: json);
//   }
// String epcRecall = '';
//   Future<List<EPCInforRecall>> fetchEPCInfoRecallData() async {
//     List<EPCInforRecall> EPCInforRecalls = [];
//     List<TagEpcLBD> allRFIDRecall = await loadData('recall_${event.idLTHTT}');
//
//     // Gửi yêu cầu GET tới API với mã EPC
//     for(TagEpcLBD tag in allRFIDRecall){
//       if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(tag.epc) && tag.epc.length % 2 == 0) {
//         // Chỉ khi nào chuỗi là hex hợp lệ mới chuyển đổi
//         epcRecall = CommonFunction().hexToString(tag.epc);
//       } else {
//         // Đối với các chuỗi không phải hex, giữ nguyên giá trị ban đầu
//         epcRecall = tag.epc;
//       }
//       print('epc: $epcRecall');
//       print(tag.epc);
//       // String epcRecall = CommonFunction().hexToString(tag.epc);
//       //   String epcRecall = 'RJVD2400006C7HML';
//     // List<String>allTag=[
//     //       "RJVD2400004PP7ML",
//     //     ];
//     // for (String epcRecall in allTag) {
//       final response = await http.get(
//         Uri.parse('$IP/api/92B13354C5044351B6D29FF4575139D4/$epcRecall'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );
//       // Kiểm tra trạng thái phản hồi
//       if (response.statusCode == 200) {
//         var jsonResponse = json.decode(response.body);
//         List<dynamic> data = jsonResponse['data'];
//
//         // Nếu dữ liệu không rỗng, thêm vào danh sách
//         if (data.isNotEmpty) {
//           for (var item in data) {
//             EPCInforRecalls.add(EPCInforRecall(
//               EPC: item["MaEPC"],
//               EPCStatus: item["TrangThaiEPC"],
//               ProductCode: item["MaSanPham"],
//               PackageAccountCode: item["MaTaiKhoanDongBao"],
//               PackageScanDate: item["NgayQuetDongBao"],
//               PackageStatus: item["TinhTrangDongBao"],
//               PackagingDescription: item["MotaDongBao"],
//               PackageCode: item["MaLichDongBao"],
//               DistributionStatus: item["TinhTrangPhanPhoi"],
//               DistributionScanDate: item["NgayQuetPhanPhoi"],
//               DistributionDescription: item["MoTaPhanPhoi"],
//               DistributionCode: item["MaPhanPhoi"],
//               DistributionAccountCode: item["MaTaiKhoanPhanPhoi"],
//               WarehouseRentalDistributionStatus: item["TinhTrangPhanPhoiKhoThue"],
//               WarehouseRentalDistributionScanDate: item["NgayQuetPPKT"],
//               WarehouseRentalDistributionDescription: item["MoTaPhanPhoiKhoThue"],
//               WarehouseRentalDistributionCode: item["MaPhanPhoiKhoThue"],
//               WarehouseRentalDistributionAccountCode: item["MaTaiKhoanPPKT"],
//             ));
//           }
//           // print('Data fetched for : $data'); // In dữ liệu để kiểm tra
//         } else {
//           print('No data found for .'); // In thông báo nếu không có dữ liệu
//         }
//       } else {
//         // throw Exception('Failed to load data: ${response.statusCode}'); // Thông báo lỗi nếu không thành công'
//         print('Failed to load data: ${response.statusCode}');
//       }
//     }
//
//     return EPCInforRecalls; // Trả về danh sách dữ liệu EPC đã thu thập
//   }
//
//
//   Future<List<EPCInforRecall>> fetchEPCInfoReplaceData() async {
//     // Khởi tạo danh sách exportCodes
//     // EPCInforReplaces = [
//     //   EPCInforRecall(
//     //     EPC: "RCMA240DP7ZTOL1C1",
//     //     PackageStt: "Đã Đóng Bao",
//     //     DistributionStt: "Đã Phân Phối Đến Đại Lý",
//     //     DistributionWearhouseStt: "",
//     //     GoodsName: "TPH-G01C",
//     //   ),
//     // ];
//     List<EPCInforRecall> EPCInforRecalls = [];
//     List<TagEpcLBD> allRFIDRecall = await loadRecallReplaceData('replace_${event.idLTHTT}');
//
//     // Gửi yêu cầu GET tới API với mã EPC
//     for(TagEpcLBD tag in allRFIDRecall){
//       if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(tag.epc) && tag.epc.length % 2 == 0) {
//         // Chỉ khi nào chuỗi là hex hợp lệ mới chuyển đổi
//         epcRecall = CommonFunction().hexToString(tag.epc);
//       } else {
//         // Đối với các chuỗi không phải hex, giữ nguyên giá trị ban đầu
//         epcRecall = tag.epc;
//       }
//
//       // String epcRecall = CommonFunction().hexToString(tag.epc);
//       print("mã thay thế $epcRecall");
//     //   String epcRecall = 'RJVD2400006C7HML';
//     // List<String>allTag=[
//     //   "JVFE240000I1UQML",
//     // ];
//     // for (String epcRecall in allTag) {
//       final response = await http.get(
//         Uri.parse('$IP/api/92B13354C5044351B6D29FF4575139D4/$epcRecall'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );
//       // Kiểm tra trạng thái phản hồi
//       if (response.statusCode == 200) {
//         var jsonResponse = json.decode(response.body);
//         List<dynamic> data = jsonResponse['data'];
//         // Nếu dữ liệu không rỗng, thêm vào danh sách
//         if (data.isNotEmpty) {
//           for (var item in data) {
//             EPCInforRecalls.add(EPCInforRecall(
//               EPC: item["MaEPC"],
//               EPCStatus: item["TrangThaiEPC"],
//               ProductCode: item["MaSanPham"],
//               PackageAccountCode: item["MaTaiKhoanDongBao"],
//               PackageScanDate: item["NgayQuetDongBao"],
//               PackageStatus: item["TinhTrangDongBao"],
//               PackagingDescription: item["MotaDongBao"],
//               PackageCode: item["MaLichDongBao"],
//               DistributionStatus: item["TinhTrangPhanPhoi"],
//               DistributionScanDate: item["NgayQuetPhanPhoi"],
//               DistributionDescription: item["MoTaPhanPhoi"],
//               DistributionCode: item["MaPhanPhoi"],
//               DistributionAccountCode: item["MaTaiKhoanPhanPhoi"],
//               WarehouseRentalDistributionStatus: item["TinhTrangPhanPhoiKhoThue"],
//               WarehouseRentalDistributionScanDate: item["NgayQuetPPKT"],
//               WarehouseRentalDistributionDescription: item["MoTaPhanPhoiKhoThue"],
//               WarehouseRentalDistributionCode: item["MaPhanPhoiKhoThue"],
//               WarehouseRentalDistributionAccountCode: item["MaTaiKhoanPPKT"],
//             ));
//           }
//           // print('Data fetched for : $data'); // In dữ liệu để kiểm tra
//         } else {
//           print('No data found for .'); // In thông báo nếu không có dữ liệu
//         }
//       } else {
//         // throw Exception('Failed to load data: ${response.statusCode}'); // Thông báo lỗi nếu không thành công'
//         print('Failed to load data: ${response.statusCode}');
//       }
//     }
//
//     return EPCInforRecalls;
//   }
//
//   String getKey( String eventId, String id) {
//     return '$eventId-$id';
//   }
//
//   Future<void> saveCountsToStorage(String eventId, int successCount, int failCount, String currentDate) async {
//     List<String> keys = [
//       "successCount",
//       "failCount",
//       "currentDate"
//     ];
//     // Đọc giá trị hiện tại từ bộ nhớ và cộng dồn giá trị mới
//     for (String key in keys) {
//       String storageKey = getKey(key, eventId);
//       String? value = await secureRecallStorage.read(key: storageKey);
//       int currentValue = int.tryParse(value ?? '') ?? 0; // Sử dụng 0 làm giá trị mặc định nếu không phải số
//       // Cộng dồn giá trị mới với giá trị đã lưu
//       switch (key) {
//         case "successCount":
//           currentValue += successCount;
//           break;
//         case "failCount":
//           currentValue += failCount;
//           break;
//         case "currentDate":
//           await secureRecallStorage.write(key: storageKey, value: currentDate);
//           continue; // Bỏ qua bước lưu số vì đã lưu chuỗi ngày
//       }
//       // Lưu giá trị đã cộng dồn trở lại vào bộ nhớ
//       await secureRecallStorage.write(key: storageKey, value: currentValue.toString());
//     }
//   }
//
//   Future<void> saveCounterToStorage() async {
//     await secureStorage.write(key: "saveCounter", value: _saveCounter.toString());
//   }
//
//   Future<void> loadCounterFromStorage() async {
//     String? counterString = await secureStorage.read(key: "saveCounter");
//     _saveCounter = int.tryParse(counterString ?? '0') ?? 0; // Đặt lại _saveCounter nếu tìm thấy
//   }
//
//   Future<List<Map<String, dynamic>>> loadAllRecalls(String eventId) async {
//     List<Map<String, dynamic>> allRecalls = [];
//     final allKeys = (await secureStorage.readAll()).keys.where((key) => key.contains(eventId)).toList();
//     // Tạo một cấu trúc dữ liệu để giữ thông tin thành công và thất bại cho mỗi postId
//     Map<String, Map<String, int>> recallCounts = {};
//     for (var key in allKeys) {
//       var parts = key.split('-');
//       var postId = parts[parts.length - 1]; // Giả sử postId là phần tử cuối cùng
//       var value = await secureStorage.read(key: key);
//       var count = int.tryParse(value ?? '0') ?? 0;
//       recallCounts[postId] ??= {'successCountRecall': 0, 'failCountRecall': 0};
//       if (key.contains("successCountRecall")) {
//         recallCounts[postId]!['successCountRecall'] = count;
//       } else if (key.contains("failCountRecall")) {
//         recallCounts[postId]!['failCountRecall'] = count;
//       }
//     }
//     // Chuyển đổi recallCounts thành danh sách cho allRecalls
//     recallCounts.forEach((postId, counts) {
//       allRecalls.add({
//         'postId': int.tryParse(postId) ?? 0,
//         ...counts // Sử dụng spread operator để thêm counts vào Map
//       });
//     });
//     // Sắp xếp allRecalls dựa trên postId từ cũ đến mới
//     allRecalls.sort((a, b) => a['postId'].compareTo(b['postId']));
//     return allRecalls;
//   }
//
//   void onAgencySelected(String selectedAgencyName) {
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
//   Future<void> startSyncProcess() async {
//     try {
//       // Gọi fetch để lấy dữ liệu từ API trước khi thực hiện đồng bộ
//       List<EPCInforRecall> epcRecallList = await fetchEPCInfoRecallData();
//       List<EPCInforRecall> epcReplaceList = await fetchEPCInfoReplaceData();
//
//       // Tạo các map để lưu dữ liệu tạm thời
//       Map<String, EPCInforRecall> epcRecallMap = {};
//       Map<String, EPCInforRecall> epcReplaceMap = {};
//
//       // Điền dữ liệu vào epcRecallMap
//       for (var epcRecall in epcRecallList) {
//         epcRecallMap[epcRecall.EPC] = epcRecall;
//         epcReallString = epcRecall.EPC;
//       }
//
//       // Điền dữ liệu vào epcReplaceMap
//       for (var epcReplace in epcReplaceList) {
//         epcReplaceMap[epcReplace.EPC] = epcReplace;
//         epcReplaceString = epcReplace.EPC;
//       }
//
//       // Sau khi lấy và lưu dữ liệu tạm thời, gọi các hàm putRecal và putReplace
//       await putRecal(epcRecallList, epcReplaceMap);
//       await putReplace(epcReplaceList, epcRecallMap);
//     } catch (e) {
//       print("Có lỗi xảy ra khi đồng bộ: $e");
//       // Bạn có thể hiển thị thông báo lỗi nếu cần
//     }
//   }
//   Future<void> putRecal(List<EPCInforRecall> epcRecallList, Map<String, EPCInforRecall> epcReplaceMap) async {
//     print('Thu hồi được gọi');
//     showDialog(
//       context: context,
//       barrierDismissible: false, // Người dùng không thể tắt dialog bằng cách nhấn ngoài biên
//       builder: (BuildContext context) {
//         return Dialog(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(AppColor.mainText),
//                 ),
//                 SizedBox(width: 20),
//                 Text(
//                   "Đang đồng bộ...",
//                   style: TextStyle(
//                     color: AppColor.mainText,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//
//     String eventId = event.idLTHTT; // ID của lịch
//     int successCount = 0;
//     int failCount = 0;
//     String LDTH = widget.event.ghiChuLTHTT; // Lấy ghi chú của sự kiện
//     String? maTK = await _getMaTKFromSecureStorage();
//     DateTime ngayPost = DateTime.now(); // Định dạng ngày gửi
//     String postDate = ngayPost.toIso8601String();
//     bool networkErrorOccurred = false;
//
//     String key = getSentTagsKey(event.idLTHTT); // Tạo khóa duy nhất dựa trên ID lịch
//     String? sentTagsJson = await secureLTHStorage.read(key: key);
//     List<String> sentTags = sentTagsJson != null ? List<String>.from(jsonDecode(sentTagsJson)) : [];
//     String baseUrl = '$IP/api/9215A3F22E3C4E529042582F399CF53D';
//
//     final DateTime now = DateTime.now();
//     String formattedTimestamp = now.millisecondsSinceEpoch.toString().padLeft(18, '0');
//
//     for (var epcRecall in epcRecallList) {
//       String epcString = epcRecall.EPC; // Lấy EPC từ danh sách recall
//       String apiUrl = '$baseUrl/$epcString';
//       var replaceData = epcReplaceMap[epcReplaceString];
//
//       if (!sentTags.contains(epcString)) {
//         Map<String, dynamic> data = {
//           "10ME": "${epcString}_${formattedTimestamp}",
//           "10MTK": maTK,
//           "2LDTH": LDTH,
//           "4NTH": postDate,
//           "1MESP": epcString,
//           "1METT": replaceData?.EPC ?? " ",
//           "30TT": "TT001",
//           "3MLĐB": epcRecall.PackageCode ?? " ",
//           "1TTĐB": "true",
//           "28GC": "Mã EPC được thay thế",
//           "16MT": "ERROR_0000",
//           "2MPP": epcRecall.DistributionCode ?? " ",
//           "1TTPP": "true",
//           "29GC": "Mã EPC được thay thế",
//           "15MT": "ERROR_0000",
//           "1TTPPKT": "true",
//           "18MT": "ERROR_0000",
//           "30GC": "Mã EPC được thay thế",
//           "3MPPKT": epcRecall.WarehouseRentalDistributionCode ?? " ",
//           "3SĐQ": 0,
//           "2SQTC": 0,
//           "3SGTC": 0,
//           "2SLĐQ": 0,
//           "4SGTC": 0,
//           "3SQTC": 0
//         };
//         print(apiUrl);
//         print(data);
//         try {
//           final response = await http.put(
//             Uri.parse(apiUrl),
//             headers: {'Content-Type': 'application/json; charset=UTF-8'},
//             body: jsonEncode(data),
//           );
//
//           if (response.statusCode == 200) {
//             sentTags.add(epcString);
//             await secureLTHStorage.write(key: key, value: jsonEncode(sentTags));
//             final responseData = json.decode(response.body);
//             if (responseData["success"] == true) {
//               successCount++;
//             } else {
//               failCount++;
//             }
//           } else {
//             failCount++;
//           }
//         } on SocketException {
//           networkErrorOccurred = true;
//           break;
//         } catch (e) {
//           print("Error occurred while posting data for EPC $epcString: $e");
//           failCount++;
//         }
//       }
//     }
//
//     Navigator.pop(context); // Đóng dialog
//
//     if (networkErrorOccurred) {
//       // Hiển thị thông báo lỗi kết nối
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Mất kết nối!", style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold)),
//             content: Text("Vui lòng kiểm tra kết nối mạng.", style: TextStyle(fontSize: 18, color: AppColor.mainText)),
//             actions: <Widget>[
//               TextButton(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//                   ),
//                   fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
//                 ),
//                 child: Text("OK", style: TextStyle(color: Colors.white)),
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Đóng cửa sổ dialog
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//
//     // Lưu kết quả vào cơ sở dữ liệu và đếm số thành công, thất bại
//     final dbHelper = CalendarRecallReplacementDatabaseHelper();
//     await dbHelper.syncEvent(event);
//     saveCountsToStorage(eventId, successCount, failCount, DateFormat('dd/MM/yyyy').format(ngayPost));
//   }
//
//   String epcReallString = '';
//   String epcReplaceString = '';
//   Future<void> putReplace(List<EPCInforRecall> epcReplaceList, Map<String, EPCInforRecall> epcRecallMap) async {
//     print('Đang thực hiện đồng bộ thay thế...');
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(AppColor.mainText),
//                 ),
//                 SizedBox(width: 20),
//                 Text(
//                   "Đang đồng bộ...",
//                   style: TextStyle(
//                     color: AppColor.mainText,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//
//     String eventId = event.idLTHTT;
//     int successCount = 0;
//     int failCount = 0;
//     String LDTH = widget.event.ghiChuLTHTT;
//     String? maTK = await _getMaTKFromSecureStorage();
//     DateTime ngayPost = DateTime.now();
//     String postDate = ngayPost.toIso8601String();
//     bool networkErrorOccurred = false;
//
//     String key = getSentTagsKey(eventId);
//     String? sentTagsJson = await secureLTHStorage.read(key: key);
//     List<String> sentTags = sentTagsJson != null ? List<String>.from(jsonDecode(sentTagsJson)) : [];
//     String baseUrl = '$IP/api/FE9B89F49FB3471BAAB71A8DEDE3F9CB';
//
//     final DateTime now = DateTime.now();
//     String formattedTimestamp = now.millisecondsSinceEpoch.toString().padLeft(18, '0');
//
//     for (var epcReplace in epcReplaceList) {
//       String epcString = epcReplace.EPC;
//       String apiUrl = '$baseUrl/$epcString';
//       var recallData = epcRecallMap[epcReallString];
//
//       if (!sentTags.contains(epcString)) {
//         Map<String, dynamic> data = {
//           "1MR": recallData?.EPC,
//           "30TT": recallData?.EPCStatus ?? "TT001",
//           "29MSP": recallData?.ProductCode ?? " ",
//           "3MLĐB": recallData?.PackageCode ?? "DB202452800052",
//           "1TTĐB": "true",
//           "28GC": "Mã EPC được thay thế",
//           "16MT": recallData?.PackagingDescription ?? "ERROR_0000",
//           "2ME": epcReplace.EPC,
//           "12ME": "${epcReplace.EPC}_$formattedTimestamp",
//           "30NT": recallData?.PackageScanDate ?? "$postDate",
//           "32MSP": recallData?.ProductCode ?? " ",
//           "17MTK": recallData?.PackageAccountCode ?? "user002",
//           "2MPP": recallData?.DistributionCode ?? "DN20246400098",
//           "1TTPP": "true",
//           "29GC": "Mã EPC được thay thế",
//           "15MT": recallData?.DistributionDescription ?? "ERROR_0000",
//           "29NT": recallData?.DistributionScanDate ?? "$postDate",
//           "1ME": epcReplace.EPC ?? "A",
//           "11ME": "${epcReplace.EPC}_$formattedTimestamp",
//           "31MSP": recallData?.ProductCode ?? " ",
//           "16MTK": recallData?.DistributionAccountCode ?? "user011",
//           "1TTPPKT": "true",
//           "30GC": "Mã EPC được thay thế",
//           "18MT": recallData?.WarehouseRentalDistributionDescription ?? "ERROR_0000",
//           "8ME": epcReplace.EPC ?? "A",
//           "13ME": "${epcReplace.EPC}_$formattedTimestamp",
//           "3MPPKT": recallData?.WarehouseRentalDistributionCode ?? "DN20246400098",
//           "31NT": recallData?.WarehouseRentalDistributionScanDate ?? "$postDate",
//           "33MSP": recallData?.ProductCode ?? "",
//           "18MTK": recallData?.WarehouseRentalDistributionAccountCode ?? "user033",
//           "3SĐQ": 1,
//           "2SQTC": 1,
//           "3SGTC": 1,
//           "2SLĐQ": 1,
//           "4SGTC": 1,
//           "3SQTC": 1
//         };
//         print(apiUrl);
//         print(data);
//         try {
//           final response = await http.put(
//             Uri.parse(apiUrl),
//             headers: {'Content-Type': 'application/json; charset=UTF-8'},
//             body: jsonEncode(data),
//           );
//
//           if (response.statusCode == 200) {
//             sentTags.add(epcString);
//             await secureLTHStorage.write(key: key, value: jsonEncode(sentTags));
//             final responseData = json.decode(response.body);
//             if (responseData["success"] == true) {
//               successCount++;
//             } else {
//               failCount++;
//             }
//           } else {
//             failCount++;
//           }
//         } on SocketException {
//           networkErrorOccurred = true;
//           break;
//         } catch (e) {
//           print("Error occurred while posting data for EPC $epcString: $e");
//           failCount++;
//         }
//       }
//     }
//
//     Navigator.pop(context);
//
//     if (networkErrorOccurred) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Mất kết nối!", style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold)),
//             content: Text("Vui lòng kiểm tra kết nối mạng.", style: TextStyle(fontSize: 18, color: AppColor.mainText)),
//             actions: <Widget>[
//               TextButton(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//                   ),
//                   fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
//                 ),
//                 child: Text("OK", style: TextStyle(color: Colors.white)),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Đồng bộ thành công", style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold)),
//             actions: <Widget>[
//               TextButton(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//                   ),
//                   fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
//                 ),
//                 child: Text("OK", style: TextStyle(color: Colors.white)),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   Navigator.pop(context, true);
//                   Navigator.pop(context, true);
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//
//     final dbHelper = CalendarRecallReplacementDatabaseHelper();
//     await dbHelper.syncEvent(event);
//     saveCountsToStorage(eventId, successCount, failCount, DateFormat('dd/MM/yyyy').format(ngayPost));
//   }
//
//
//   Future<List<TagEpcLBD>> getTagEpcList(String key) async {
//     return await loadData(event.idLTHTT);
//   }
//
//   Future<String> formatDataForFileWithTags(String key) async {
//     StringBuffer buffer = StringBuffer();
//     // Dữ liệu từ các thông tin khác
//     buffer.writeln("Nội dung thu hồi: ${event.ghiChuLTHTT}");
//     buffer.writeln("Số lượng quét: $tagCount");
//     buffer.writeln("Ngày tạo lịch: ${event.ngayTaoLTHTT}");
//     // Lấy danh sách TagEpcLBD từ loadData
//     List<TagEpcLBD> tagEpcList = await getTagEpcList(event.idLTHTT);
//     buffer.writeln("Mã EPC:");
//     // Duyệt qua danh sách và thêm từng EPC vào chuỗi
//     for (var tag in tagEpcList) {
//       String epcString = CommonFunction().hexToString(tag.epc);
//       buffer.writeln(epcString); // Giả định `epc` là trường trong TagEpcLBD
//     }
//     return buffer.toString();
//   }
//   //
//   Future<void> saveFileToDownloads(String data, String fileName) async {
//     try {
//       final downloadDirectory = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
//       final filePath = '$downloadDirectory/$fileName';
//       final file = File(filePath);
//       await file.writeAsString(data); // Viết dữ liệu vào tệp
//       print('File saved to Downloads: $filePath');
//     } catch (e) {
//       print('Failed to save file: $e');
//       // Xử lý lỗi khi không thể ghi file
//     }
//   }
//
//   Future<void> saveDataWithTags(String key, String baseFileName) async {
//     var permissionStatus = await Permission.storage.request();
//     if (permissionStatus.isGranted) {
//       String formattedData = await formatDataForFileWithTags(event.idLTHTT); // Lấy chuỗi định dạng
//       String timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//       String fileName = '$baseFileName\_$timeStamp.txt'; // Tạo tên file với dấu thời gian
//       await saveFileToDownloads(formattedData, fileName); // Ghi dữ liệu vào tệp với tên duy nhất
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Tệp đã được lưu vào mục Download: $fileName'),
//           backgroundColor: Color(0xFF4EB47D),
//           duration: Duration(seconds: 3), // Thời gian hiển thị SnackBar
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Quyền truy cập bị từ chối. Không thể lưu tệp.'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 3),
//           )
//       );
//     }
//   }
//
//   void _showScanMethodDialog() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setStateModal) {
//             return AlertDialog(
//               title: Text(
//                 "Vui lòng chọn hình thức quét!",
//                 style: TextStyle(
//                   color: AppColor.mainText,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               content: Container(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     GestureDetector(
//                       onTap: () {
//                         setStateModal(() {
//                           _selectedScanningMethod = "rfid";
//                         });
//                       },
//                       child: Row(
//                         children: <Widget>[
//                           Radio<String>(
//                             value: "rfid",
//                             groupValue: _selectedScanningMethod,
//                             onChanged: (String? value) {
//                               setStateModal(() {
//                                 _selectedScanningMethod = value!;
//                               });
//                             },
//                           ),
//                           Text("Quét mã RFID"),
//                         ],
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setStateModal(() {
//                           _selectedScanningMethod = "qr";
//                         });
//                       },
//                       child: Row(
//                         children: <Widget>[
//                           Radio<String>(
//                             value: "qr",
//                             groupValue: _selectedScanningMethod,
//                             onChanged: (String? value) {
//                               setStateModal(() {
//                                 _selectedScanningMethod = value!;
//                               });
//                             },
//                           ),
//                           Text("Quét QR code"),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   child: Text("OK"),
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Đóng hộp thoại
//
//                     // Dựa trên lựa chọn của người dùng, điều hướng đến trang tương ứng
//                     if (_selectedScanningMethod == "rfid") {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => RfidScanningPage(
//                             event: widget.event, // Truyền event qua lớp RfidScanningPage
//                               isRecallScan: isRecallScan,
//                           ),
//                         ),
//                       );
//                     } else if (_selectedScanningMethod == "qr") {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => QrCodeScanningPage(
//                           event: widget.event,
//                           isRecallScan: isRecallScan,
//
//                         )), // Điều hướng đến trang QrCodeScanningPage
//                       );
//                     }
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//
//   void _showScanRecallReplaceMethodDialog() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setStateModal) {
//             return AlertDialog(
//               title: Text(
//                 "Vui lòng chọn hình thức quét!",
//                 style: TextStyle(
//                   color: AppColor.mainText,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               content: Container(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     GestureDetector(
//                       onTap: () {
//                         setStateModal(() {
//                           _selectedScanningMethod = "rfid";
//                         });
//                       },
//                       child: Row(
//                         children: <Widget>[
//                           Radio<String>(
//                             value: "rfid",
//                             groupValue: _selectedScanningMethod,
//                             onChanged: (String? value) {
//                               setStateModal(() {
//                                 _selectedScanningMethod = value!;
//                               });
//                             },
//                           ),
//                           Text("Quét mã RFID"),
//                         ],
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setStateModal(() {
//                           _selectedScanningMethod = "qr";
//                         });
//                       },
//                       child: Row(
//                         children: <Widget>[
//                           Radio<String>(
//                             value: "qr",
//                             groupValue: _selectedScanningMethod,
//                             onChanged: (String? value) {
//                               setStateModal(() {
//                                 _selectedScanningMethod = value!;
//                               });
//                             },
//                           ),
//                           Text("Quét QR code"),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   child: Text("OK"),
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Đóng hộp thoại
//
//                     // Dựa trên lựa chọn của người dùng, điều hướng đến trang tương ứng
//                     if (_selectedScanningMethod == "rfid") {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => RfidScanningPage(
//                           event: widget.event,
//                           isRecallScan: isRecallScan,
//
//                         )), // Điều hướng đến trang RfidScanningPage
//                       );
//                     } else if (_selectedScanningMethod == "qr") {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => QrCodeScanningPage(
//                           event: widget.event,
//                           isRecallScan: isRecallScan,
//
//                         )), // Điều hướng đến trang QrCodeScanningPage
//                       );
//                     }
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return WillPopScope(
//         onWillPop: () async {
//           if (dadongbo = true) {
//             // Hành động cụ thể khi tagCount > 0
//             Navigator.pop(context, true); // Quay trở lại màn hình trước và gửi giá trị true
//             return false; // Trả về false để ngăn việc tự động pop, vì đã xử lý pop
//           } else {
//             return true; // Cho phép người dùng thoát nếu không có điều kiện nào được thỏa mãn
//           }
//         },
//         child:
//         Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             toolbarHeight: screenHeight * 0.12, // Chiều cao thanh công cụ
//             backgroundColor: const Color(0xFFE9EBF1),
//             elevation: 4,
//             shadowColor: Colors.blue.withOpacity(0.5),
//             leading: Padding(
//               padding: EdgeInsets.only(left: screenWidth * 0.03), // Khoảng cách từ mép trái
//               child: Container(
//                 width: screenWidth * 0.2, // Chiều rộng logo
//                 height: screenHeight * 0.15, // Chiều cao logo
//                 child: Image.asset(
//                   'assets/image/logoJVF_RFID.png',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             title: Text(
//               'Lịch thu hồi',
//               style: TextStyle(
//                 fontSize: screenWidth * 0.07, // Kích thước chữ
//                 fontWeight: FontWeight.bold,
//                 color: AppColor.mainText,
//               ),
//             ),
//             actions: [
//               Padding(
//                 padding: EdgeInsets.only(right: screenWidth * 0.03), // Khoảng cách từ mép phải
//                 child: Row(
//                   children: [
//                     InkWell(
//                       onTap: () async {
//                         saveDataWithTags(event.idLTHTT, "${event.ghiChuLTHTT}");
//                       },
//                       child: Image.asset(
//                         'assets/image/download.png',
//                         width: screenWidth * 0.1, // Chiều rộng hình ảnh
//                         height: screenHeight * 0.1, // Chiều cao hình ảnh
//                       ),
//                     ),
//                     SizedBox(width: screenWidth * 0.03), // Khoảng cách giữa hai nút
//                     InkWell(
//                       onTap: () {
//                         showDialog<void>(
//                           context: context,
//                           barrierDismissible: false,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: Text('Xác nhận xóa',
//                                 style: TextStyle(color: AppColor.mainText,
//                                     fontWeight: FontWeight.bold
//                                 ),
//                               ),
//                               content: Text("Bạn có chắc chắn muốn xóa lịch này không?",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: AppColor.mainText,
//                                   )
//                               ),
//                               actions: <Widget>[
//                                 TextButton(
//                                   style: ButtonStyle(
//                                     backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
//                                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                                       RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
//                                       ),
//                                     ),
//                                     fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
//                                   ),
//                                   child: Text('Hủy',
//                                       style:TextStyle(
//                                         color: Colors.white,
//                                       )
//                                   ),
//                                   onPressed: () async {
//                                     Navigator.of(context).pop();
//                                     setState(() {
//                                     });
//                                   },
//                                 ),
//                                 SizedBox(width: 8,),
//                                 TextButton(
//                                   style: ButtonStyle(
//                                     backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
//                                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                                       RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
//                                       ),
//                                     ),
//                                     fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
//                                   ),
//                                   child: Text('Xác Nhận',
//                                       style:TextStyle(
//                                         color: Colors.white,
//                                       )
//                                   ),
//                                   onPressed: () async {
//                                     deleteEventFromCalendar();
//                                     Navigator.pop(context, true);
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       child: Image.asset(
//                         'assets/image/thungrac1.png',
//                         width: screenWidth * 0.1, // Chiều rộng hình ảnh
//                         height: screenHeight * 0.1, // Chiều cao hình ảnh
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           body: Column(
//             children: <Widget>[
//               Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.012, 0, screenHeight * 0.012),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFFAFAFA),
//                     border: Border(
//                       bottom: BorderSide(
//                         color: Colors.grey.withOpacity(0.5), // Màu sắc của đường viền dưới
//                         width: 2, // Độ dày của đường viền dưới
//                       ),
//                     ),
//                   ),
//                   child:
//                   RichText(
//                     text: TextSpan(
//                       style: TextStyle(
//                         // fontSize: 24,
//                         fontSize: screenWidth * 0.065,
//                         color: AppColor.mainText,
//                       ),
//                       children: [
//                         TextSpan(
//                           text: 'Nội dung thu hồi\n',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             // fontSize: 24,
//                             fontSize: screenWidth * 0.065,
//                           ),
//                         ),
//                         TextSpan(
//                           text: '${event.ghiChuLTHTT}',
//                         ),
//                       ],
//                     ),
//                   )
//               ),
//               GestureDetector(
//                 onTap: () {
//
//                   // if (_selectedScanningMethod.isNotEmpty) {
//                   //   // Dựa trên phương thức quét, khởi tạo KeyEventChannel với sự kiện tương ứng
//                   //   if (_selectedScanningMethod == "rfid") {
//                   //     _showChipInformation(context);
//                   //   } else if (_selectedScanningMethod == "qr") {
//                   //    _showRecallReplaceChipInformation(context);
//                   //   }
//                   // }
//
//                 },
//                 child: Container(
//                   // padding: EdgeInsets.fromLTRB(20, 15, 0, 12),
//                   padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.012, 0, screenHeight * 0.012),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFFAFAFA),
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: RichText(
//                           text: TextSpan(
//                             style: TextStyle( fontSize: screenWidth * 0.065, color: AppColor.mainText),
//                             children: [
//                               TextSpan(
//                                 text: 'Mã thu hồi\n ',
//                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.065),
//                               ),
//                               TextSpan(
//                                 text: tagsList.isNotEmpty
//                                     ? tagsList.map((epc) {
//                                   // Kiểm tra nếu là chuỗi hex (chỉ có ký tự hợp lệ và độ dài hợp lý)
//                                   if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(epc) && epc.length % 2 == 0) {
//                                     return CommonFunction().hexToString(epc); // Chuyển hex sang chuỗi
//                                   } else {
//                                     return epc; // Đã ở dạng chuỗi, giữ nguyên
//                                   }
//                                 }).join('\n') // Hiển thị trên từng dòng
//                                     : '', // Nếu chưa có mã
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Icon(Icons.navigate_next, color: AppColor.mainText, size: 30.0),
//                     ],
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//
//                   // if (_selectedScanningMethod.isNotEmpty) {
//                   //   // Dựa trên phương thức quét, khởi tạo KeyEventChannel với sự kiện tương ứng
//                   //   if (_selectedScanningMethod == "rfid") {
//                   //     _showChipInformation(context);
//                   //   } else if (_selectedScanningMethod == "qr") {
//                   //     _showRecallReplaceChipInformation(context);
//                   //   }
//                   // }
//
//                 },
//                 child: Container(
//                   // padding: EdgeInsets.fromLTRB(20, 15, 0, 12),
//                   padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.012, 0, screenHeight * 0.012),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFFAFAFA),
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: RichText(
//                           text: TextSpan(
//                             style: TextStyle( fontSize: screenWidth * 0.065, color: AppColor.mainText),
//                             children: [
//                               TextSpan(
//                                 text: 'Mã thay thế\n ',
//                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.065),
//                               ),
//                               TextSpan(
//                                 text: tagRecallReplaceList.isNotEmpty
//                                     ? tagRecallReplaceList.map((epc) {
//                                   // Kiểm tra nếu là chuỗi hex (chỉ có ký tự hợp lệ và độ dài hợp lý)
//                                   if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(epc) && epc.length % 2 == 0) {
//                                     return CommonFunction().hexToString(epc); // Chuyển hex sang chuỗi
//                                   } else {
//                                     return epc; // Đã ở dạng chuỗi, giữ nguyên
//                                   }
//                                 }).join('\n') // Hiển thị trên từng dòng
//                                     : '', // Nếu chưa có mã
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Icon(Icons.navigate_next, color: AppColor.mainText, size: 30.0),
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.012, 0, screenHeight * 0.012),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFFAFAFA),
//                     border: Border(
//                       bottom: BorderSide(
//                         color: Colors.grey.withOpacity(0.5), // Màu sắc của đường viền dưới
//                         width: 2, // Độ dày của đường viền dưới
//                       ),
//                     ),
//                   ),
//                   child:
//                   RichText(
//                     text: TextSpan(
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.065,
//                         color: AppColor.mainText,
//                       ),
//                       children: [
//                         TextSpan(
//                           text: 'Ngày tạo lịch\n',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: screenWidth * 0.065,
//                           ),
//                         ),
//                         TextSpan(
//                           text: '${event.ngayTaoLTHTT}',
//                         ),
//                       ],
//                     ),
//                   )
//               ),
//             ],
//           ),
//             bottomNavigationBar: BottomAppBar(
//               height: screenHeight * 0.23, // Tăng chiều cao để đủ chỗ cho 3 nút
//               color: Colors.transparent,
//               child: Container(
//                 color: Colors.transparent,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center, // Đảm bảo các nút nằm giữa
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         // Nút "Quét mã thu hồi"
//                         // Nút "Quét mã thu hồi"
//                         ElevatedButton(
//                           onPressed: () {
//                             isRecallScan = true; // Đặt cờ cho biết đây là quét mã thu hồi
//                             if (!_isScanningStarted) {
//                               _showScanMethodDialog(); // Hiển thị hộp thoại chọn phương thức quét
//                             }
//                           },
//                           child: Text(
//                             'Quét mã thu hồi', // Hiển thị nhãn dựa trên trạng thái
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: screenWidth * 0.05, // Điều chỉnh cỡ chữ phù hợp
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _isScanningStarted ? AppColor.mainText : AppColor.mainText, // Thay đổi màu nút dựa trên trạng thái
//                             padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                             fixedSize: Size(160.0, 50.0), // Kích thước cố định
//                           ),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             isRecallScan = false; // Đặt cờ cho biết đây là quét mã thay thế
//                             _showScanRecallReplaceMethodDialog(); // Hiển thị hộp thoại chọn phương thức quét
//                           },
//                           child: Text(
//                             'Quét mã thay thế', // Hiển thị nhãn dựa trên trạng thái
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: screenWidth * 0.05, // Điều chỉnh cỡ chữ phù hợp
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _isScanningRecallReplaceStarted ? AppColor.mainText : AppColor.mainText, // Thay đổi màu nút dựa trên trạng thái
//                             padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                             fixedSize: Size(165.0, 50.0), // Kích thước cố định
//                           ),
//                         ),
//
//                       ],
//                     ),
//
//                     // Nút "Đồng bộ" nằm dưới hai nút trên
//                     SizedBox(height: 10), // Thêm khoảng cách giữa hai hàng
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFFd5a529), // Màu vàng
//                         padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.0),
//                         ),
//                         fixedSize: Size(350.0, 50.0), // Kích thước cố định
//                       ),
//                       onPressed: () {
//                         showModal();
//                       },
//                       child: const Text(
//                         'Đồng bộ',
//                         style: TextStyle(fontSize: 22, color: Colors.white),
//                       ),
//                     ),
//
//                   ],
//                 ),
//               ),
//             )
//         )
//     );
//   }
//
// }
//
