import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rfid_c72_plugin/rfid_c72_plugin.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'dart:collection';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rfid_c72_plugin_example/utils/app_config.dart';
import 'package:rfid_c72_plugin_example/utils/common_functions.dart';
import 'dart:async';
import '../UserDatatypes/user_datatype.dart';
import '../Utils/DeviceActivities/DataProcessing.dart';
import '../Utils/DeviceActivities/DataReadOptions.dart';
import '../Utils/DeviceActivities/connectionNotificationRSeries.dart';
import '../Utils/app_color.dart';
import '../main.dart';
import 'model_information_package.dart';
import 'database_package_inf.dart';
import 'dart:convert';
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../utils/scan_count_modal.dart';
import '../utils/key_event_channel.dart';
import 'package_schedule_list.dart';
import 'wearhouse_import_code_list.dart';
/*Assign packing information*/

class SendDistributionInf extends StatefulWidget {

  final CalendarDistributionInf event;
  final Function(CalendarDistributionInf) onDeleteEvent;

  const SendDistributionInf({Key? key, required this.event, required this.onDeleteEvent}) : super(key: key);

  @override
  State<SendDistributionInf> createState() => _SendDistributionInfState();
}

class _SendDistributionInfState extends State<SendDistributionInf> {
  final StreamController<int> _updateStreamController = StreamController<int>.broadcast(); // Tạo StreamController
  late CalendarDistributionInf event;
  final CalendarDistributionInfDatabaseHelper databaseHelper = CalendarDistributionInfDatabaseHelper();
  String _platformVersion = 'Unknown';
  final bool _isHaveSavedData = false;
  final bool _isStarted = false;
  final bool _isEmptyTags = false;
  bool _isConnected = false;
  bool _isLoading = true;
  int _totalEPC = 0, _invalidEPC = 0, _scannedEPC = 0;
  int currentPage = 0;
  int itemsPerPage = 5;
  late CalendarDistributionInfDatabaseHelper _databaseHelper;
  List<TagEpcLDB> paginatedData = [];
  int targetTotalEPC = 100;
  late Timer _timer;
  TextEditingController _agencyNameController = TextEditingController();
  TextEditingController _goodsNameController = TextEditingController();
  String _selectedAgencyName = '';
  String _selectedGoodsName = '';
  String _selectedMsp = '';
  String _selectedMSPLDB = '';
  TextEditingController _MSPLDB = TextEditingController();
  bool dadongbo = false;
  List<TagEpcLDB> _data = [];
  final List<String> _EPC = [];
  List<TagEpcLDB> _successfulTags = [];
  int totalTags = 0;
  static int _value  = 0;
  int successfullySaved = 0;
  int previousSavedCount = 0;
  bool isScanning = false;
  Queue<List<TagEpcLDB>> p = Queue<List<TagEpcLDB>>();
  bool _isNotified = false;
  bool _isShowModal = false;
  Queue<List<TagEpcLDB>> _queue = Queue<List<TagEpcLDB>>();
  List<TagEpcLDB> newData = [];
  int saveCount = 0;
  int a = 0;
  int TotalScan = 0;
  int scannedTagsCount = 0;
  final _storage = const FlutterSecureStorage();
  bool _dataSaved = false;
  int tagCount = 0;
  bool _isContinuousCall = false;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool confirm = false;
  List<Dealer> dealers = [];
  bool showModalSync = false;
  String? _MSPisSelect = '';
  bool _isSnackBarDisplayed = false;
  Stream<int> get updateStream => _updateStreamController.stream;
  bool _isDialogShown = false;
  bool showConfirmationDialog = false;
  final securePackageStorage = const FlutterSecureStorage();
  bool dadongbao = false;
  bool dataSyncedSuccessfully = false;
  final secureLDBStorage = const FlutterSecureStorage();
  int successCountPackageInf = 0;
  int failCountPackageInf = 0;
  final packageInfStorage = const FlutterSecureStorage();
  bool _isShowSyncModal = false;
  int successfulSends = 0;
  int alreadyDistributed = 0;
  int notActivated = 0;
  int wrongDistribution = 0;
  int failSend = 0;
  int completSchedule = 0;
  int notalreadyDistribution = 0;
  int codeRecalled = 0;
  int cantscan = 0;
  int otherCase = 0;
  int SyncCode = 0;
  // String IP = 'http://192.168.19.69:5088';
  // String IP = 'http://192.168.19.180:5088';
  // String IP = 'https://jvf-admin.rynansaas.com';
  List<TagEpcLDB> r5_resultTags = [];
  bool scanStatusR5 = false;


  @override
  void initState() {
    super.initState();
    event = widget.event;
    _databaseHelper = CalendarDistributionInfDatabaseHelper();
    _initDatabase();
    initPlatformState();
    loadSuccessfullySaved(event.idLDB);
    _agencyNameController.text = _selectedAgencyName;
    _goodsNameController.text = _selectedGoodsName;
    _MSPLDB.text = _selectedMSPLDB;
    loadTagCount();
    KeyEventChannel(
      onKeyReceived: _toggleScanningForC5,
    ).initialize();
    uhfBLERegister();
  }
  //#region R_Series Register Tag Read
  Future<void> checkCurrentDevice() async {
    if (currentDevice == Device.cSeries) {
      await _toggleScanningForC5();
    } else if (currentDevice == Device.rSeries) {
      await  _toggleScanningForR5();
    } else if (currentDevice == Device.cameraBarcodes) {
      await _toggleScanningForC5();
    }
  }
  void uhfBLERegister() {
    UHFBlePlugin.setMultiTagCallback((tagList) { // Listen data from R5
      setState(() async {
        if(currentDevice != Device.rSeries) return;
        List<TagEpcLDB> currentTags = await loadData(event.idLDB);
        r5_resultTags = DataProcessing.ConvertToTagEpcLDBList(tagList);

        DataProcessing.ProcessDataLDB(r5_resultTags,currentTags, _data,_playScanSound); // Filter
        print('Data from R5: ${r5_resultTags.length}');
        updateStatusAndCountResult();
      });
    });
    UHFBlePlugin.setScanningStatusCallback((scanStatus) {
      scanStatusR5 = scanStatus;
      _toggleScanningForR5();
    });
  }
//#endregion R_Series Register Tag Read

  Future<void> _initDatabase() async {
    await _databaseHelper.initDatabase();
  }

  @override
  void dispose() {
    super.dispose();
    _updateStreamController.close();
    closeAll();
  }

  closeAll() {
    RfidC72Plugin.close;
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = (await RfidC72Plugin.platformVersion)!;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    RfidC72Plugin.connectedStatusStream
        .receiveBroadcastStream()
        .listen(updateIsConnected);
    RfidC72Plugin.tagsStatusStream.receiveBroadcastStream().listen(updateTags);
    await RfidC72Plugin.connect;
    await _initDatabase();
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
      _isLoading = false;
    });
  }
  Future<void> _playScanSound() async {
    try {
      await _audioPlayer.setAsset('assets/sound/Bip.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print("$e");
    }
  }


//.....................................22.03.24.15:59..............................//
  void updateTags(dynamic result) async {
     List<TagEpcLDB> currentTags = await loadData(event.idLDB);
    List<TagEpcLDB> newData = TagEpcLDB.parseTags(result);
    DataProcessing.ProcessDataLDB(newData,currentTags, _data,_playScanSound); // Filter
    updateStatusAndCountResult();

    // List<TagEpcLBD> currentTags = await loadData(event.idLDB);
    // List<TagEpcLBD> uniqueData = newData.where((newTag) =>
    // !currentTags.any((savedTag) => savedTag.epc == newTag.epc) &&
    //     !_data.any((existingTag) => existingTag.epc == newTag.epc)).toList();
    //
    // uniqueData.forEach((tag) {
    //   tag.scanDate = DateTime.now();  // Gán thời gian quét cho thẻ
    // });
    // if (!uniqueData.isEmpty) {
    //   _playScanSound();
    // }
    // _data.addAll(uniqueData);

    // setState(() {
    //   isScanning = true;
    //   successfullySaved = _data.length; // Cập nhật trạng thái
    // });
    // sendUpdateEvent(successfullySaved);

  }

  void updateStatusAndCountResult() {
    setState(() {
      isScanning = true;
      successfullySaved = _data.length; // Cập nhật trạng thái
    });
    sendUpdateEvent(successfullySaved);
  }

  Future<void> saveSuccessfullySaved(String eventId, int value) async {
    final secureStorage = const FlutterSecureStorage();
    await secureStorage.write(key: '${eventId}_length', value: value.toString());
  }

  Future<void> loadSuccessfullySaved(String eventId) async {
    String? savedLength = await _storage.read(key: '${eventId}_length');
    if (savedLength != null) {
      setState(() {
        successfullySaved = int.parse(savedLength);
      });
    }
  }

  void sendUpdateEvent(int value) {
    _updateStreamController.add(value);
  }

  void onDataReceived(int newData) {
    sendUpdateEvent(newData);
  }

  Future<void> saveData(String key, List<TagEpcLDB> data) async {
    String dataString = TagEpcLDB.tagsToJson(data);
    await _storage.write(key: key, value: dataString);
  }

  Future<List<TagEpcLDB>> loadData(String key) async {
    String? dataString = await _storage.read(key: key);
    if (dataString != null) {
      // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpcLBD
      return TagEpcLDB.parseTags(dataString);
    }
    return [];
  }

  Future<void> stopScanning() async {
    if (!_isSnackBarDisplayed) {
      await RfidC72Plugin.stop;
      _showSnackBar('Đã đạt đủ số lượng');
      _isSnackBarDisplayed = true;
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void updateIsConnected(dynamic isConnected) {
    _isConnected = isConnected;
  }

  void navigateToPackageScheduleList(BuildContext context) async {
    final selectedSchedule = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PackageScheduleList(
        fetch1MLDB: fetch1MLDB, // Sửa lại tên hàm nếu cần
        onSelect: (Dealer selectedDealer) {
          setState(() {
            _selectedMsp = selectedDealer.maLDB;
            _goodsNameController.text = _selectedMsp;
            _MSPisSelect = selectedDealer.maSP;
          });
        },
      )),
    );
  }
  Future<String?> _navigateToSelectMLNKPage(BuildContext context) async {
    List<WearHouseTypeList> mlNKList = await fetchMLNK();
    if (mlNKList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải danh sách MLNK.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
    // Điều hướng tới trang SelectMLNKPage và đợi giá trị trả về
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectMLNKPage(
          mlNKList: mlNKList,
          onSelect: (selectedMLNK) {
            // Trả về giá trị MLNK đã chọn
            Navigator.pop(context, selectedMLNK.maLNK);
          },
        ),
      ),
    );
  }

  void deleteEventFromCalendar() async {
    try {
      final dbHelper = CalendarDistributionInfDatabaseHelper();
      await dbHelper.deleteEvent(event);
      widget.onDeleteEvent(event);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa lịch thành công!'),
          backgroundColor: Color(0xFF4EB47D),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      // print('Lỗi khi xóa lịch: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi khi xóa lịch!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showChipInformation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin chip',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColor.mainText,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<TagEpcLDB>>(
                  future: loadData(event.idLDB), // Sử dụng loadData với event.id
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          String epcString = CommonFunction().hexToString(snapshot.data![index].epc);
                          DateTime? saveDateString = snapshot.data![index].scanDate;
                          String scanDate = saveDateString != null
                              ? DateFormat('dd/MM/yyyy hh:mm:ss').format(saveDateString)
                              : '';
                          return ListTile(
                            title: Text(
                              '${index + 1}. $epcString',
                              style: const TextStyle(
                                color: AppColor.mainText,
                              ),
                            ),
                            subtitle: Text(
                              '- $scanDate',
                              style: const TextStyle(
                                color: AppColor.mainText,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Không có dữ liệu',
                          style: TextStyle(
                            color: AppColor.mainText,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void loadTagCount() async {
    if (widget.event.idLDB != null) { // Giả sử widget.event là sự kiện được chọn và có thuộc tính id
      List<TagEpcLDB> tags = await loadData(event.idLDB);
      setState(() {
        tagCount = tags.length; // Cập nhật số lượng tags vào biến trạng thái
      });
    }
  }

  Future<void> saveTagsToSecureStorage(String calendarId, List<TagEpcLDB> tags) async {
    // Serialize danh sách tag thành chuỗi JSON
    List<Map<String, dynamic>> jsonTags = tags.map((tag) => tag.toJson()).toList();
    String jsonString = jsonEncode(jsonTags);
    // Sử dụng ID lịch như một phần của key khi lưu
    await _storage.write(key: 'saved_tags_$calendarId', value: jsonString);
  }

  Future<List<TagEpcLDB>> loadTagsFromSecureStorage(String calendarId) async {
    String? jsonString = await _storage.read(key: 'saved_tags_$calendarId');
    if (jsonString == null) return [];

    List<dynamic> jsonTags = jsonDecode(jsonString);
    List<TagEpcLDB> tags = jsonTags.map((jsonTag) => TagEpcLDB.fromJson(jsonTag)).toList();

    return tags;
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lưu mã chip?',
            style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 20),
                Container(
                  height: 200, // Hoặc một giá trị phù hợp với nhu cầu của bạn
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      String tagepc = CommonFunction().hexToString(_data[index].epc);
                      return ListTile(
                        title:
                        Text(
                            '${index+1}.$tagepc',
                          style: const TextStyle(color: AppColor.mainText),
                        ) ,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                  ),
                ),
                fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
              ),
              child: const Text('Hủy Bỏ',
                  style:TextStyle(
                    color: Colors.white,
                  )
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await RfidC72Plugin.clearData;
                setState(() {
                  // successfullySaved = tagCount;
                  _data.clear();
                  showConfirmationDialog = false;
                  successfullySaved = 0;
                });
              },
            ),
            const SizedBox(width: 8,),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                  ),
                ),
                fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
              ),
              child: const Text('Xác Nhận',
                  style:TextStyle(
                    color: Colors.white,
                  )
              ),
              onPressed: () async {
                // Đầu tiên, tải danh sách tag hiện tại từ lưu trữ
                List<TagEpcLDB> currentTags = await loadData(event.idLDB);
                // Lọc ra những tag mới chưa có trong currentTags
                List<TagEpcLDB> newUniqueTags = _data.where((newTag) =>
                !currentTags.any((savedTag) => savedTag.epc == newTag.epc)).toList();
                // Thêm các tag mới vào danh sách hiện tại và loại bỏ các tag trùng lặp
                currentTags.addAll(newUniqueTags);
                currentTags = currentTags.toSet().toList(); // Sử dụng Set để loại bỏ các tag trùng lặp
                // Lưu danh sách đã cập nhật vào lưu trữ
                await saveData(event.idLDB, currentTags);
                await _storage.write(key: '${event.idLDB}_length', value: _data.length.toString());
                Navigator.of(context).pop();
                setState(() {
                  loadTagCount();
                  showConfirmationDialog = false;
                });
              },
            ),
          ],
        );
      },
    ).then((_) async {
      _isDialogShown = false;
      await DataReadOptions.readTagsAsync(false, currentDevice);
      checkCurrentDevice();
    });
  }

  void onAgencySelected(String selectedAgencyName) {
  }

  //#region ScanRFID
  // Future<void> _toggleScanningForC5() async {
  //   print("MinhChauLog: Start Toggle Scanning for C5!");
  //   if (_isShowSyncModal  || currentDevice != Device.C_Series) {
  //     return;
  //   }
  //   if (_isContinuousCall) {
  //     DataReadOptions.readTagsAsync(false, currentDevice);
  //     _isContinuousCall = false;
  //     if (_isDialogShown) {
  //       Navigator.of(context, rootNavigator: true).pop('dialog');
  //     }
  //   }
  //   else {
  //     DataReadOptions.readTagsAsync(true, currentDevice);
  //     _isContinuousCall = true;
  //     if (!_isDialogShown)
  //     {
  //       _showScanningModal();
  //     }
  //   }
  //   setState(() {
  //     _isShowModal = _isContinuousCall;
  //   });
  // }
  // Future<void> _toggleScanningForR5() async {
  //   print("MinhChauLog: Start Toggle Scanning for R5!");
  //   if (_isShowSyncModal || currentDevice != Device.R_Series) {
  //     return;
  //   }
  //   if (_isContinuousCall) {
  //     if(!scanStatusR5){
  //       DataReadOptions.readTagsAsync(false, currentDevice); //Start by internal device key or software button
  //     }
  //     _isContinuousCall = false;
  //     if (_isDialogShown) {
  //       Navigator.of(context, rootNavigator: true).pop('dialog');
  //     }
  //   }
  //   else
  //   {
  //     if(!scanStatusR5){
  //       DataReadOptions.readTagsAsync(true, currentDevice);  //Stop by internal device key or software button
  //     }
  //     _isContinuousCall = true;
  //     if (!_isDialogShown)
  //     {
  //       _showScanningModal();
  //     }
  //   }
  //   setState(() {
  //     _isShowModal = _isContinuousCall;
  //     scanStatusR5=false;
  //   });
  // }
  // void _showScanningModal() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       // Trả về widget dialog
  //       return Center(
  //         child: Dialog(
  //           elevation: 0,
  //           backgroundColor: Colors.transparent,
  //           child: Container(
  //             // Nội dung dialog
  //             child: SavedTagsModal(
  //               updateStream: _updateStreamController.stream,
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   ).then((_) => _isDialogShown = false); // Cập nhật trạng thái khi dialog đóng
  //   _isDialogShown = true;
  // }
//#endregion

  Future<void> _toggleScanningForC5() async {
    try{
    if(_isShowSyncModal ||
        currentDevice != Device.cSeries &&
        currentDevice !=  Device.cameraBarcodes ||
        _isDialogShown){
      if (_isDialogShown) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      }
      return;
    }
    if(currentDevice == Device.cameraBarcodes){
      ConnectionNotificationRSeries.showDeviceWaring(context, false);
      return;
    }
    if (_isContinuousCall) {

        DataReadOptions.readTagsAsync(false, currentDevice);
      _isContinuousCall = false;
      if (_isDialogShown) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      }
      // if (!showConfirmationDialog) {
      //   Future.delayed(const Duration(milliseconds: 100), () {
      //     _showConfirmationDialog();
      //     showConfirmationDialog = true;
      //   });
      // }
    } else {

      if(!showConfirmationDialog ){

          DataReadOptions.readTagsAsync(true, currentDevice);

        _data.clear();
        _isContinuousCall = true;
        if (!_isDialogShown) {
          _isDialogShown = true;
          _showScanningModal();
        }
      }
    }
    setState(() {
      _isShowModal = _isContinuousCall;
    });
  }catch(e){
  print('Error: $e');
  }
  }
  Future<void> _toggleScanningForR5() async {
    try{
      if(_isShowSyncModal || currentDevice != Device.rSeries || _isDialogShown){
        if (_isDialogShown) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
        return;
      }
      if(currentDevice == Device.cameraBarcodes){
        ConnectionNotificationRSeries.showDeviceWaring(context, false);
        return;
      }
      if (_isContinuousCall) {
        if(!scanStatusR5){
          DataReadOptions.readTagsAsync(false, currentDevice); //Start by internal device key or software button
        }
        _isContinuousCall = false;
        if (_isDialogShown) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
        // if (!showConfirmationDialog) {
        //   Future.delayed(const Duration(milliseconds: 100), () {
        //     _showConfirmationDialog();
        //     showConfirmationDialog = true;
        //   });
        // }
      } else {

        if(!showConfirmationDialog ){
          if(!scanStatusR5){
            DataReadOptions.readTagsAsync(true, currentDevice);  //Stop by internal device key or software button
          }
          _data.clear();
          _isContinuousCall = true;
          if (!_isDialogShown) {
            _isDialogShown = true;
            _showScanningModal();
          }
        }
      }
      setState(() {
        _isShowModal = _isContinuousCall;
        scanStatusR5=false;
      });
    }catch(e){
      print('Error: $e');
    }


  }

  bool _isCancelled = false;
  void _showScanningModal() {
    _isCancelled = false; // Reset trạng thái hủy
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return (_isShowModal)
            ? Center(
          child: Dialog(
            elevation: 0,
            backgroundColor: const Color.fromARGB(255, 43, 78, 128),
            child: SizedBox(
              height :300,
              child: Column(
                children: [
                  const Text("RFID",style: TextStyle(color: Colors.white)),
                  SavedTagsModal(
                    updateStream: _updateStreamController.stream,
                  ),
                ],
              ),
            ),
          ),
        ) : const SizedBox.shrink();  //một widget rỗng được hiển thị nếu _isShowModal = false
      },
    ).then((_)  {

      _showConfirmationDialog();
      _isCancelled = true; // Đánh dấu đã hủy
    }); // Cập nhật trạng thái khi dialog đóng



    // Đóng dialog sau 1 giây
    // Future.delayed(const Duration(seconds: 100), () {
    //   if (!_isCancelled && mounted && _isDialogShown) {  // dùng mounted để kiểm tra context còn tồn tại
    //     _isDialogShown = false;
    //
    //     Navigator.of(context).pop();
    //     _showConfirmationDialog();
    //   }
    // });
  }

  void updateMSP(String? msp) {
    String combinedValue = "$msp ";
    _MSPLDB.text= combinedValue;
  }

  Future<List<Dealer>> fetch1MLDB() async {
    List<Dealer> dealers = [];
    int startAt = 0;
    const int dataAmount = 1000;
    bool hasMore = true;

    while (hasMore) {
      final response = await http.get(
        Uri.parse('${AppConfig.IP}/api/8CE11A03D4B7417296C1C795E481C7F0/'),
        headers: {
          'Content-Type': 'application/json',
          'start-at': '$startAt',
          'Data-Amount': '$dataAmount',
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];

        if (data.isNotEmpty) {
          for (var item in data) {
            dealers.add(Dealer(maLDB: item["1MLĐB"], tenSP: item["10TSP"], maSP: item["23MSP"], ngaySX: item["11NSX"], SBCSX: item["2SCSX"]));
          }
          if (data.length == dataAmount) {
            startAt += dataAmount; // Cập nhật chỉ số bắt đầu cho lần yêu cầu tiếp theo
          } else {
            hasMore = false; // Dừng vòng lặp nếu số lượng dữ liệu trả về < 200
          }
        } else {
          hasMore = false; // Dừng vòng lặp nếu không còn dữ liệu
        }
      } else {
        throw Exception('Failed to load data');
      }
    }
    return dealers;
  }

  Future<bool> checkAndFetch1MLDB() async {
    try {
      // Lấy danh sách các Dealer
      List<Dealer> fiveMLDealers = await fetch1MLDB();

      for (var dealer in fiveMLDealers) {
        if (dealer.maLDB == event.maLDB) {
          _MSPisSelect = dealer.maSP; // Gán giá trị 23MSP cho _MSPisSelect
          return true; // Tìm thấy Dealer phù hợp
        }
      }
      return false; // Không tìm thấy Dealer phù hợp
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }


  void resetInputFields() {
    setState(() {
      _goodsNameController.text = '';
    });
  }

  Future<bool> shouldSendTag(String msp, String epcString) async {
    final String apiUrl = '${AppConfig.IP}/api/398AF12E74984D4298C59534E0F572D1/$msp/$epcString';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Kiểm tra nếu 'data' tồn tại và không rỗng
        if (responseData['data'] != null && responseData['data'].isNotEmpty) {
          for (var data in responseData['data']) {
            // print("ạhshdsh");
            if (data['16MT'] == 'ERROR_0000') {
              return false;
            }
          }
        }
      }
    } catch (e) {
      print('Lỗi khi kiểm tra trạng thái thẻ: $e');
    }
    return true; // Gửi nếu không tìm thấy ERROR_0000
  }

  Future<List<WearHouseTypeList>> fetchMLNK() async {
    List<WearHouseTypeList> wearHouseTypeList = [];
    int startAt = 0;
    const int dataAmount = 1000;
    bool hasMore = true;

    while (hasMore) {
      final response = await http.get(
        Uri.parse('${AppConfig.IP}/api/A65EA47989CF40E2AA155DF6A5263AEC/'),
        headers: {
          'Content-Type': 'application/json',
          'start-at': '$startAt',
          'Data-Amount': '$dataAmount',
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];

        if (data.isNotEmpty) {
          for (var item in data) {
            wearHouseTypeList.add(WearHouseTypeList(maLNK: item["1MLNK"], tenLNK: item["1TLNK"]));
          }
          if (data.length == dataAmount) {
            startAt += dataAmount; // Cập nhật chỉ số bắt đầu cho lần yêu cầu tiếp theo
          } else {
            hasMore = false; // Dừng vòng lặp nếu số lượng dữ liệu trả về < 200
          }
        } else {
          hasMore = false; // Dừng vòng lặp nếu không còn dữ liệu
        }
      } else {
        throw Exception('Failed to load data');
      }
    }
    return wearHouseTypeList;
  }

  Future<void> PutStatusToComplet(String? _MSPisSelect, String MLDB) async {
    // print('mã lịch đb: $MLDB');
    String? selectedMLNK = await _navigateToSelectMLNKPage(context);
    if (selectedMLNK == null) {
      return;
    }
    // String? ghiChu = await _showNoteInputDialog(context);
    // Lấy giá trị từ hộp thoại
    Map<String, String>? result = await _showNoteInputDialog(context);

    // Kiểm tra nếu người dùng đã nhập thông tin và nhấn OK
    if (result != null) {
      // Gán giá trị ghi chú và số lượng thực tế từ kết quả
      String ghiChu = result['note'] ?? '';
      String SLDBTT = result['quantity'] ?? '';

      print("Ghi chú: $ghiChu");
      print("Số lượng xuất thực tế: $SLDBTT");
    // int sgtcCount = await fetchSGTCCount(MLDB);
    // print("Số gán thành công $sgtcCount");
    String baseUrl = '${AppConfig.IP}/api/2D3024E2533843EDA2B352F302FEF4B9';
    String key = getSentTagsKey(event.idLDB); // Tạo khóa duy nhất dựa trên ID lịch
    String? sentTagsJson = await secureLDBStorage.read(key: key);
    List<String> sentTags = sentTagsJson != null ? List<String>.from(jsonDecode(sentTagsJson)) : [];
    String? maKho = await _getmaKhofromSecureStorage();
    String? maTK = await _getmaTKfromSecureStorage();
    final DateTime now = DateTime.now(); // Lấy thời gian hiện tại
    DateTime nowpost = DateTime.now();
    int milli = nowpost.millisecondsSinceEpoch;
    String ngayNhap = now.toIso8601String();
    String apiUrl = '$baseUrl/$MLDB';
    Map<String, dynamic> data = {
      "2SPN": 0,
      "13MK": maKho,
      "2MLNK": selectedMLNK,
      "2MLĐB": MLDB,
      "24MSP": _MSPisSelect,
      "1SLN": 0,
      "5NN": ngayNhap,
      "3MTK": maTK,
      "32GC" : ghiChu,
      "1SĐBTT": SLDBTT,
    };
    // print(apiUrl);
    print(data);
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        // Kiểm tra nếu trong results_of_update có "5MTT": "TT003"
        bool isSuccess = false;
        if (responseJson["results_of_update"] is List) {
          for (var result in responseJson["results_of_update"]) {
            if (result is Map && result["5MTT"] == "TT003") {
              isSuccess = true;
              break;
            }
          }
        }
        if (isSuccess) {
          _showSyncConfirmationDialog(context, "Lịch đã được xác nhận Hoàn thành thành công!", true);
        } else {
          _showSyncConfirmationDialog(context, "Cập nhật trạng thái không thành công!", false);
        }
      } else {
        _showSyncConfirmationDialog(context, "Đồng bộ thất bại! Vui lòng thử lại.", false);
      }
    } catch (e) {
      _showSyncConfirmationDialog(context, "Đã xảy ra lỗi khi khi xác nhận Hoàn thành. Vui lòng thử lại.", false);
    }
    }
  }

  void _showSyncConfirmationDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isSuccess ? "Thông báo" : "Thông báo",
            style: TextStyle(color: isSuccess ? AppColor.mainText : Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: isSuccess ? AppColor.mainText : AppColor.mainText,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                  ),
                ),
                fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendDataWithPutRequest() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.mainText),
                ),
                SizedBox(width: 20),
                Text("Đang đồng bộ...",
                  style: TextStyle(
                    color: AppColor.mainText,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    List<TagEpcLDB> allRFIDData = await loadData(event.idLDB);
    String baseUrl = '${AppConfig.IP}/api/7787F36F76C2408E96C4C2FE96D59A17';

    String key = getSentTagsKey(event.idLDB);
    String? sentTagsJson = await secureLDBStorage.read(key: key);
    List<String> sentTags = sentTagsJson != null ? List<String>.from(jsonDecode(sentTagsJson)) : [];
    Set<String> sentTagsSet = sentTags.toSet();
    String MLDB = "";
    String eventId = event.idLDB;
    bool networkErrorOccurred = false;
    final DateTime now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    DateTime syncDate = DateTime.now();
    String syncDateFormat = DateFormat('dd/MM/yyyy').format(syncDate);
    // print(syncDateFormat);
    int milli = now.millisecondsSinceEpoch;
    String milliString = milli.toString();
    String? maTK = await _getmaTKfromSecureStorage();
    String apiUrl = '';
    String formattedTimestamp = milliString.padLeft(18, '0');
    List<Future> apiRequests = []; // Danh sách để lưu trữ các yêu cầu API song song
    //
    // List<String>allTag=[
    //   "RJVD24000047CXML",
    //
    // ];
    // for (String epcString in allTag) {
      //Mã thực tế
      for (TagEpcLDB tag in allRFIDData) {
        if (networkErrorOccurred) break;
        String epcString = CommonFunction().hexToString(tag.epc);
        String scanDate = tag.scanDate?.toIso8601String() ?? '';
      if (!sentTagsSet.contains(epcString)) {
        bool shouldSend = await shouldSendTag(_selectedMsp.isNotEmpty ? _selectedMsp : event.maLDB, epcString);
        if (!shouldSend) {
          SyncCode++;
          failSend++;
        }
        else {
          if (_selectedMsp.isNotEmpty) {
            apiUrl = '$baseUrl/$_selectedMsp/$epcString';
            MLDB = "$_selectedMsp";
            // print(MLDB);
          } else {
            // apiUrl = '$baseUrl/${event.maLDB}/$epcString';
            // MLDB = "${event.maLDB}";
            apiUrl = '$baseUrl/${event.maLDB}/$epcString';
            MLDB = "${event.maLDB}";
            // print("MSP: $_MSPisSelect"); // In giá trị của _MSPisSelect để kiểm tra
          }
          Map<String, dynamic> data = {
            "1TTĐB": "true",
            "16MT": "",
            "2ME": epcString,
            "12ME": "${epcString}_${formattedTimestamp}",
            "30NT": scanDate,
            // "30NT": "2024-09-26T15:11:32.015188",
            "32MSP": _MSPisSelect,
            "17MTK": maTK,
            "3MLĐB": MLDB,
            "5MTT": "TT001",
            "3SĐQ": 1,
            "2SQTC": 1,
            "2SQTB": 0,
            "3SGTC": 0,
            "3SGTB": 0,
            "30TT": "TT001",
          };
          // print("url CTB: $apiUrl");
          // print("json: $data");
          apiRequests.add(Future(() async {
          try {
            final response = await http.put(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode(data),
            );

            if (response.statusCode == 200) {
              sentTags.add(epcString);
              await secureLDBStorage.write(
                key: key,
                value: jsonEncode(sentTags),
              );
              final responseJson = json.decode(response.body);
              for (var result in responseJson['results_of_update']) {
                if (result['16MT'] != null) {
                  String errorCode = result['16MT'];
                  switch (errorCode) {
                    case 'ERROR_0000':
                      successfulSends++;
                      break;
                    case 'ERROR_0006':
                      alreadyDistributed++;
                      failSend++;
                      break;
                    case 'ERROR_0002':
                      notActivated++;
                      failSend++;
                      break;
                    case 'ERROR_0003':
                      wrongDistribution++;
                      failSend++;
                      break;
                    case 'ERROR_0004':
                      failSend++;
                      notalreadyDistribution++;
                      break;
                    case 'ERROR_0008':
                      failSend++;
                      codeRecalled++;
                      break;
                    case 'ERROR_0010':
                      failSend++;
                      completSchedule++;
                      break;
                    default:
                      failSend++;
                      otherCase++;
                  }
                }
              }
            } else {
              failSend++;
            }
          } on SocketException {
            networkErrorOccurred = true;
          } catch (e) {
            failSend++;
            notalreadyDistribution++;
          }
        }));
        }
      }
    }
    await Future.wait(apiRequests);
    final dbHelper = CalendarDistributionInfDatabaseHelper();
    if (!networkErrorOccurred) {
      await dbHelper.syncEvent(event);
      await dbHelper.updateTimeById(event, formattedTime);
      resetInputFields();
      Navigator.pop(context);
    }

    Navigator.pop(context);
    dadongbo = true;
    if (networkErrorOccurred) {
      dataSyncedSuccessfully = true;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Mất kết nối!",
              style: TextStyle(
                color: AppColor.mainText,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text("Vui lòng kiểm tra kết nối mạng.",
              style: TextStyle(
                fontSize: 18,
                color: AppColor.mainText,
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
                ),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      dataSyncedSuccessfully = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Đồng bộ thành công",style: TextStyle(
              color: AppColor.mainText,
              fontWeight: FontWeight.bold,
            ),
            ),
            content: const Text("Bạn có muốn xác nhận hoàn thành Lịch Đóng bao này?",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColor.mainText,
                )
            ),
            actions: <Widget>[
              TextButton( style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                  ),
                ),
                fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
              ),
                child: const Text('Hủy',
                    style:TextStyle(
                      color: Colors.white,
                    )
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.pop(context, true);
                  setState(() {
                  });
                },
              ),
              TextButton( style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                  ),
                ),
                fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
              ),

                child: const Text("OK", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng cửa sổ
                  // String? ghiChu = await _showNoteInputDialog(context);
                  //
                  // if (ghiChu != null && ghiChu.isNotEmpty) {
                  //   // Gọi hàm PutStatusToComplet() với ghi chú
                  //   await PutStatusToComplet(_MSPisSelect, MLDB, ghiChu);
                  // }
                  // Navigator.pop(context, true);
                  PutStatusToComplet(_MSPisSelect, MLDB);
                  print(_MSPisSelect);
                  // print(MLDB);
                },
              )
            ],
          );
        },
      );
    }
    successCountPackageInf = successfulSends;
    failCountPackageInf = failSend;
    setState(() {
      saveCountsPackageInfToStorage(eventId, successfulSends, failSend, notActivated, wrongDistribution, alreadyDistributed, notalreadyDistribution, SyncCode, completSchedule, otherCase, codeRecalled, syncDateFormat);
    });
  }
  Future<Map<String, String>?> _showNoteInputDialog(BuildContext context) async {
    TextEditingController _noteController = TextEditingController();
    TextEditingController _quantityController = TextEditingController();
    return
      showDialog<Map<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Nhập thông tin',
              style: TextStyle(
                color: AppColor.mainText,
                fontWeight: FontWeight.bold,
              ),
            ),
            contentPadding: const EdgeInsets.only(top: 5, right: 20, left: 20, bottom: 5),
            content: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      // filled: true,
                      // // fillColor: Color(0xFFEBEDEC),
                      // labelText: "Nhập số lượng đóng bao thực tế",
                      // labelText: TextStyle(
                      //   color: Colors.grey,
                      //   fontWeight: FontWeight.normal,
                      // ),
                      labelText: 'Nhập số lượng đóng bao thực tế',
                      labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          // fontSize: 22
                      ),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF65a281)),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColor.mainText),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    ),
                  ),
                  const SizedBox(height: 20), // Tăng khoảng cách giữa các trường
                  TextField(
                    controller: _noteController,
                    minLines: 2, // Số dòng tối thiểu
                    maxLines: 4, // Số dòng tối đa, có thể điều chỉnh tùy ý
                    decoration: InputDecoration(
                      labelText: 'Nhập ghi chú',
                      labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          // fontSize: 22
                      ),
                      // fillColor: Color(0xFFEBEDEC),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF65a281)),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColor.mainText),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 7), // Loại bỏ padding giữa content và actions
            // buttonPadding: EdgeInsets.symmetric(horizontal: 8.0), // Giảm padding giữa các nút
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
                ),
                child: const Text('Hủy', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng hộp thoại mà không trả về giá trị gì
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop({
                    'note': _noteController.text, // Trả về ghi chú
                    'quantity': _quantityController.text // Trả về số lượng thực tế
                  });
                },
              ),
            ],
          );
        },
      );
  }


  final _storageAcountCode = const FlutterSecureStorage();

  Future<String?> _gettenKhofromSecureStorage() async {
    return await _storageAcountCode.read(key: 'tenKho');
  }
  Future<String?> _getmaKhofromSecureStorage() async {
    return await _storageAcountCode.read(key: 'maKho');
  }

  Future<String?> _getmaTKfromSecureStorage() async {
    return await _storageAcountCode.read(key: 'maTK');
  }

  Future<void> PutpackageWithAccountCode() async {
    List<TagEpcLDB> allRFIDData = await loadData(event.idLDB);
    String baseUrl = '${AppConfig.IP}/api/23E350A52834497D9E8EE8D316F11A8A';

    String key = getSentTagsKey(event.idLDB); // Tạo khóa duy nhất dựa trên ID lịch
    String? sentTagsJson = await secureLDBStorage.read(key: key);
    List<String> sentTags = sentTagsJson != null ? List<String>.from(jsonDecode(sentTagsJson)) : [];
    String? maKho = await _getmaKhofromSecureStorage();
    String? tenKho = await _gettenKhofromSecureStorage();
    String? maTK = await _getmaTKfromSecureStorage();
        String apiUrl = '$baseUrl/$_selectedMsp';
        Map<String, dynamic> data = {
          "5TK": tenKho,
          "14MTK": maTK,
          "21MK": maKho
        };
        try {
          final response = await http.put(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(data),
          );
          if (response.statusCode == 200) {
           print('thành công');
          } else {
            print('Failed.Status code: ${response.statusCode}');
          }
        } catch (e) {
          print('Error sending data for: $e');
        }
    }

  String getSentTagsKey(String eventId) {
    return 'sent_tags_$eventId';
  }

  Future<void> saveTagState(TagEpcLDB tag) async {
    final secureLDBStorage = const FlutterSecureStorage();
    String key = 'tag_${tag.epc}';
    String json = jsonEncode(tag.toJson());
    await secureLDBStorage.write(key: key, value: json);
  }

  String getKey(String eventId, String id) {
    return '$eventId-$id';
  }

  Future<void> saveCountsPackageInfToStorage(String eventId, int successCount, int failCount, int notActivated, int wrongDistribution, int alreadyDistributed, int notalreadyDistribution, int SyncCode, int completSchedule, int otherCase, int codeRecalled, String syncDateFormat ) async {
    List<String> keys = [
      "successCountPackageInf",
      "failCountPackageInf",
      "notActivated",
      "wrongDistribution",
      "alreadyDistributed",
      "notalreadyDistribution",
      "SyncCode",
      "completSchedule",
      "otherCase",
      "codeRecalled",
      "syncDateFormat",
    ];
    // Đọc giá trị hiện tại từ bộ nhớ và cộng dồn giá trị mới
    for (String key in keys) {
      String storageKey = getKey(key, eventId);
      String? value = await packageInfStorage.read(key: storageKey);
      int currentValue = int.tryParse(value ?? '') ?? 0; // Sử dụng 0 làm giá trị mặc định nếu không phải số
      // Cộng dồn giá trị mới với giá trị đã lưu
      switch (key) {
        case "successCountPackageInf":
          currentValue += successCount;
          break;
        case "failCountPackageInf":
          currentValue += failCount;
          break;
        case "notActivated":
          currentValue += notActivated;
          break;
        case "wrongDistribution":
          currentValue += wrongDistribution;
          break;
        case "alreadyDistributed":
          currentValue += alreadyDistributed;
          break;
        case "notalreadyDistribution":
          currentValue += notalreadyDistribution;
          break;
        case "SyncCode":
          currentValue += SyncCode;
          break;
        case "completSchedule":
          currentValue += completSchedule;
          break;
        case "otherCase":
          currentValue += otherCase;
          break;
        case "codeRecalled":
          currentValue += codeRecalled;
          break;
        case "syncDateFormat":
          await packageInfStorage.write(key: storageKey, value: syncDateFormat);
          continue; // Bỏ qua bước lưu số vì đã lưu chuỗi ngày
      }
      // Lưu giá trị đã cộng dồn trở lại vào bộ nhớ
      await packageInfStorage.write(key: storageKey, value: currentValue.toString());
    }

  }

  Future<List<Map<String, dynamic>>> loadAllPackageInf(String eventId) async {
    List<Map<String, dynamic>> allRecalls = [];
    final allKeys = (await packageInfStorage.readAll()).keys.where((key) => key.contains(eventId)).toList();
    // Tạo một cấu trúc dữ liệu để giữ thông tin thành công và thất bại cho mỗi postId
    Map<String, Map<String, int>> recallCounts = {};

    for (var key in allKeys) {
      var parts = key.split('-');
      var postId = parts[parts.length - 1]; // Giả sử postId là phần tử cuối cùng
      var value = await packageInfStorage.read(key: key);
      var count = int.tryParse(value ?? '0') ?? 0;

      recallCounts[postId] ??= {'successCountPackageInf': 0, 'failCountPackageInf': 0};

      if (key.contains("successCountPackageInf")) {
        recallCounts[postId]!['successCountPackageInf'] = count;
      } else if (key.contains("failCountPackageInf")) {
        recallCounts[postId]!['failCountPackageInf'] = count;
      }
    }
    // Chuyển đổi recallCounts thành danh sách cho allRecalls
    recallCounts.forEach((postId, counts) {
      allRecalls.add({
        'postId': int.tryParse(postId) ?? 0,
        ...counts // Sử dụng spread operator để thêm counts vào Map
      });
    });
    // Sắp xếp allRecalls dựa trên postId từ cũ đến mới
    allRecalls.sort((a, b) => a['postId'].compareTo(b['postId']));
    return allRecalls;
  }

  Future<List<TagEpcLDB>> getTagEpcList(String key) async {
    return await loadData(event.idLDB);
  }

  Future<String> formatDataForFileWithTags(String key) async {
    StringBuffer buffer = StringBuffer();
    // Dữ liệu từ các thông tin khác
    buffer.writeln("Mã lịch đóng bao: ${event.maLDB}");
    buffer.writeln("Sản phẩm: ${event.sanPhamLDB}");
    buffer.writeln("Số lượng quét: $tagCount");
    buffer.writeln("Ghi chú: ${event.ghiChuLDB}");
    buffer.writeln("Ngày tạo lịch: ${event.ngayTaoLDB}");
    // Lấy danh sách TagEpcLBD từ loadData
    List<TagEpcLDB> tagEpcList = await getTagEpcList(event.idLDB);
    buffer.writeln("Mã EPC:");
    // Duyệt qua danh sách và thêm từng EPC vào chuỗi
    for (var tag in tagEpcList) {
      String epcString = CommonFunction().hexToString(tag.epc);
      String scanDateString = tag.scanDate != null
      ? DateFormat('dd/MM/yyyy HH:mm:ss').format(tag.scanDate!)
      : " ";
      buffer.writeln('$epcString \n - $scanDateString \n'); // Giả định `epc` là trường trong TagEpcLBD
    }
    return buffer.toString();
  }

  Future<void> saveFileToDownloads(String data, String fileName) async {
    try {
      final downloadDirectory = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
      final filePath = '$downloadDirectory/$fileName';
      final file = File(filePath);
      await file.writeAsString(data); // Viết dữ liệu vào tệp
    } catch (e) {
      print('Failed to save file: $e');
    }
  }

  Future<void> saveDataWithTags(String key, String baseFileName) async {
    var permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted) {
      String formattedData = await formatDataForFileWithTags(event.idLDB); // Lấy chuỗi định dạng
      String timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String fileName = '$baseFileName\_$timeStamp.txt'; // Tạo tên file với dấu thời gian
      await saveFileToDownloads(formattedData, fileName); // Ghi dữ liệu vào tệp với tên duy nhất
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tệp đã được lưu vào mục Download: $fileName'),
          backgroundColor: const Color(0xFF4EB47D),
          duration: const Duration(seconds: 3), // Thời gian hiển thị SnackBar
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quyền truy cập bị từ chối. Không thể lưu tệp.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          )
          );
    }
  }

  void _closeModal() {
    setState(() {
      _isShowSyncModal = false;
    });
  }

 void isShowSyncModal() async{
   setState(() {
     _isShowSyncModal = true;
   });
   if(successfullySaved==0) {
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           title: const Text("Không thể đồng bộ",style: TextStyle(
             color: AppColor.mainText,
             fontWeight: FontWeight.bold,
           ),
           ),
           content: const Text("Vui lòng kiểm tra lại số lượng quét.",
               style: TextStyle(
                 fontSize: 18,
                 color: AppColor.mainText,
               )
           ),
           actions: <Widget>[
             TextButton( style: ButtonStyle(
               backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                 RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                 ),
               ),
               fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
             ),
               child: const Text("Đóng", style: TextStyle(color: Colors.white),),
               onPressed: () {
                 Navigator.of(context).pop(); // Đóng cửa sổ dialog
               },
             )
           ],
         );
       },
     ).then((_) {
       _closeModal();  // Gọi hàm để đóng modal và cập nhật trạng thái
     });;
   }else{
     bool isMatched = await checkAndFetch1MLDB();
     showModalBottomSheet(
       context: context,
       builder: (BuildContext context) {
         return SizedBox(
           height: MediaQuery.of(context).size.height * 0.4,
           width: 350,
           child: Container(
             child: Container(
               // color: Color(0xFFDDF6FF  ),
               alignment: Alignment.center,
               margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Container(
                         padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                         child: const Text(
                           'Chọn lịch đóng bao', // Tiêu đề
                           style: TextStyle(
                             fontSize: 20,
                             fontWeight: FontWeight.bold,
                             color: AppColor.mainText,
                           ),
                         ),
                       ),
                       Container(
                         alignment: Alignment.topRight,
                         child: IconButton(
                           icon: const Icon(
                             Icons.close,
                             color: AppColor.mainText,
                             size: 30.0,
                           ),
                           onPressed: () {
                             Navigator.pop(context);
                           },
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 20,),
                   Container(
                       padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                       height: 60,
                       child: TextField(
                         onTap: () async {
                           if (!isMatched) {
                             navigateToPackageScheduleList(context);
                           }
                           if (!dataSyncedSuccessfully) {
                           }
                         },
                         controller: _goodsNameController,
                         readOnly: true, // Đảm bảo rằng người dùng không thể sửa đổi giá trị trong TextField
                         decoration: InputDecoration(
                           labelText: isMatched ? '${event.maLDB}' : 'Vui lòng chọn mã lịch',
                           labelStyle: const TextStyle(
                             color: AppColor.mainText,
                             fontWeight: FontWeight.bold,
                             fontSize: 18,
                           ),
                           enabledBorder: const OutlineInputBorder(
                             borderSide: BorderSide(color: AppColor.mainText),
                           ),
                           focusedBorder: const OutlineInputBorder(
                             borderSide: BorderSide(color: AppColor.mainText),
                           ),
                           suffixIcon: !isMatched
                               ? const Icon(
                             Icons.navigate_next,
                             color: AppColor.mainText,
                             size: 30.0,
                           ) : null,
                         ),
                       )
                   ),
                   const SizedBox(height: 30),
                   Container(
                     alignment: Alignment.bottomCenter,
                     width: 350,
                     child: ElevatedButton(
                       style: TextButton.styleFrom(
                         backgroundColor: AppColor.mainText,
                         padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12.0),
                         ),
                         fixedSize: const Size(200.0, 40.0),
                       ),
                       onPressed: () {
                         if (_goodsNameController.text.isEmpty && !isMatched) {
                           // Hiển thị SnackBar nếu TextField rỗng
                           showDialog(
                             context: context,
                             builder: (BuildContext context) {
                               return AlertDialog(
                                 title: const Text("Không thể đồng bộ",style: TextStyle(
                                   color: AppColor.mainText,
                                   fontWeight: FontWeight.bold,
                                 ),
                                 ),
                                 content: const Text("Vui lòng chọn mã lịch cần đồng bộ.",
                                     style: TextStyle(
                                       fontSize: 18,
                                       color: AppColor.mainText,
                                     )
                                 ),
                                 actions: <Widget>[
                                   TextButton( style: ButtonStyle(
                                     backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                       RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                                       ),
                                     ),
                                     fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
                                   ),
                                     child: const Text("Đóng", style: TextStyle(color: Colors.white),),
                                     onPressed: () {
                                       Navigator.of(context).pop(); // Đóng cửa sổ dialog
                                     },
                                   )
                                 ],
                               );
                             },
                           );
                         } else{
                           PutpackageWithAccountCode();
                           sendDataWithPutRequest();
                         }
                       },
                       child: const Text(
                         'Bắt đầu đồng bộ',
                         style: TextStyle(fontSize: 18, color: Colors.white),
                       ),
                     ),
                   ),
                   // SizedBox(height: 20),
                 ],
               ),
             ),
           ),
         );
       },
     ).then((_) {
       _closeModal();  // Gọi hàm để đóng modal và cập nhật trạng thái
     });;;
   };
 }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () async {
      if (tagCount > 0 || dadongbo) {
        Navigator.pop(context, true);
        return false;
      } else {
        return true;
      }
    },
      child:Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: screenHeight * 0.12, // Chiều cao thanh công cụ
            backgroundColor: const Color(0xFFE9EBF1),
            elevation: 4,
            shadowColor: Colors.blue.withOpacity(0.5),
            leading: IconButton(
                onPressed: () {
                    Navigator.pop(context,true); // True => Update Statistic
                },
                icon: const Icon(Icons.arrow_back)),
            centerTitle: true,
            title: Text(
              'Lịch đóng bao',
              style: TextStyle(
                fontSize: screenWidth * 0.07, // Kích thước chữ
                fontWeight: FontWeight.bold,
                color: AppColor.mainText,
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.03), // Khoảng cách từ mép phải
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        saveDataWithTags(event.idLDB, "${event.maLDB}");
                      },
                      child: Image.asset(
                        'assets/image/download.png',
                        width: screenWidth * 0.08, // Chiều rộng hình ảnh
                        height: screenHeight * 0.08, // Chiều cao hình ảnh
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03), // Khoảng cách giữa hai nút
                    InkWell(
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Xác nhận xóa',
                                style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold),
                              ),
                              content: const Text("Bạn có chắc chắn muốn xóa lịch này không?",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColor.mainText,
                                  )
                              ),
                              actions: <Widget>[
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                                      ),
                                    ),
                                    fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
                                  ),
                                  child: const Text('Hủy',
                                      style:TextStyle(
                                        color: Colors.white,
                                      )
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    setState(() {
                                    });
                                  },
                                ),
                                const SizedBox(width: 8,),
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                                      ),
                                    ),
                                    fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
                                  ),
                                  child: const Text('Xác Nhận',
                                      style:TextStyle(
                                        color: Colors.white,

                                      )
                                  ),
                                  onPressed: () async {
                                    deleteEventFromCalendar();
                                    Navigator.pop(context, true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Image.asset(
                        'assets/image/thungrac1.png',
                        width: screenWidth * 0.08, // Chiều rộng hình ảnh
                        height: screenHeight * 0.08, // Chiều cao hình ảnh
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.02, 0, screenHeight * 0.012),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        color: AppColor.mainText,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Mã lịch đóng bao\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:  event.maLDB,
                          style: const TextStyle(color: AppColor.contentText)
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    width: double.infinity,
                    // padding: EdgeInsets.fromLTRB(20, 15, 0, 12),
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.012, 0, screenHeight * 0.012),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.5), // Màu sắc của đường viền dưới
                          width: 2, // Độ dày của đường viền dưới
                        ),
                      ),
                    ),
                    child:
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          // fontSize: 24,
                          fontSize: screenWidth * 0.065,
                          color: AppColor.mainText,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sản phẩm\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              // fontSize: 24,
                              fontSize: screenWidth * 0.065,
                            ),
                          ),
                          TextSpan(
                            text: '${event.sanPhamLDB}',
                              style: const TextStyle(color: AppColor.contentText)
                          ),
                        ],
                      ),
                    )
                ),
                GestureDetector(
                  onTap: () {
                    _showChipInformation(context);
                  },
                  child: Container(
                    // padding: EdgeInsets.fromLTRB(20, 15, 0, 12),
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.012, 0, screenHeight * 0.012),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle( fontSize: screenWidth * 0.065, color: AppColor.mainText),
                              children: [
                                TextSpan(
                                  text: 'Số lượng quét\n ',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.065),
                                ),
                                TextSpan(
                                  // Kiểm tra trạng thái quét để quyết định hiển thị giá trị nào
                                  // text: '$successfullySaved',
                                  text: '$tagCount',
                                    style: const TextStyle(color: AppColor.contentText)
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.navigate_next, color: AppColor.mainText, size: 30.0),
                      ],
                    ),
                  ),
                ),
                Container(
                    width: double.infinity,
                    // padding: EdgeInsets.fromLTRB(20, 15, 0, 12),
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.012, 0, screenHeight * 0.012),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.5), // Màu sắc của đường viền dưới
                          width: 2, // Độ dày của đường viền dưới
                        ),
                      ),
                    ),
                    child:
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: screenWidth * 0.065,
                          color: AppColor.mainText,
                        ),
                        children: [
                          TextSpan(
                            text: 'Ghi chú\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.065,
                            ),
                          ),
                          TextSpan(
                            text: '${event.ghiChuLDB}',
                              style: const TextStyle(color: AppColor.contentText)
                          ),
                        ],
                      ),
                    )
                ),
                Container(
                    width: double.infinity,
                    // padding: EdgeInsets.fromLTRB(20, 15, 0, 12),
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.012, 0, screenHeight * 0.012),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.5), // Màu sắc của đường viền dưới
                          width: 2, // Độ dày của đường viền dưới
                        ),
                      ),
                    ),
                    child:
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: screenWidth * 0.065,
                          color: AppColor.mainText,
                        ),
                        children: [
                          TextSpan(
                            text: 'Ngày tạo lịch\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.065,
                            ),
                          ),
                          TextSpan(
                            text: '${event.ngayTaoLDB}',
                              style: const TextStyle(color: AppColor.contentText)
                          ),
                        ],
                      ),
                    )
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            height: screenHeight*0.12,
            color: Colors.transparent,
            child: Container(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isContinuousCall) ? Colors.red : AppColor.mainText,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      fixedSize: const Size(150.0, 50.0),
                    ),
                    onPressed: () async {

                      await checkCurrentDevice();
                    },
                    child: (_isContinuousCall)
                        ? Text('Dừng quét', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06))
                        : Text('Bắt đầu quét', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFd5a529),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      fixedSize: const Size(150.0, 50.0),
                    ),
                    onPressed: () async {
                      isShowSyncModal();
                      },
                    child: const Text(
                      'Đồng bộ',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // )
    )
    );
  }
}



