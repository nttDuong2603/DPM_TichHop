import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rfid_c72_plugin/rfid_c72_plugin.dart';
import 'package:rfid_c72_plugin_example/utils/common_functions.dart';
import '../DevicesConfiguration/chainway_R5_RFID/uhfManager.dart';
import '../Distribution_Module/database.dart';
import '../Distribution_Module/model.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/DataProcessing.dart';
import '../utils/scan_count_modal.dart';
import '../utils/key_event_channel.dart';
import 'history_check_inventory.dart';

class CheckInventory extends StatefulWidget {
  final String taiKhoan;
  const CheckInventory({Key? key, required this.taiKhoan}) : super(key: key);
  @override
  State<CheckInventory> createState() => _CheckInventoryState();
}

class _CheckInventoryState extends State<CheckInventory> {

  //#region Variables
  final TextEditingController _searchController = TextEditingController();
  DateTime? selectedDate;
  final CalendarDatabaseHelper _databaseHelper = CalendarDatabaseHelper();
  late AudioPlayer _audioPlayer;
  List<Calendar> _events = [];
  bool isSelected = false;
  bool isAllSelected = false;
  final StreamController<int> _updateStreamController = StreamController<int>.broadcast(); // Tạo StreamController
  final CalendarDatabaseHelper databaseHelper = CalendarDatabaseHelper();
  String _platformVersion = 'Unknown';
  final bool _isHaveSavedData = false;
  final bool _isStarted = false;
  final bool _isEmptyTags = false;
  bool _isConnected = false;
  bool _isLoading = true;
  int _totalEPC = 0, _invalidEPC = 0, _scannedEPC = 0;
  int currentPage = 0;
  int itemsPerPage = 5;
  List<TagEpc> paginatedData = [];
  int targetTotalEPC = 100;
  String? _selectedEventId;
  Calendar? selectedEvent;
  late FocusNode _focusNode;
  bool shouldRequestFocus = true;
  bool synchronized = false;
  List<TagEpc> _data = [];
  final List<String> _EPC = [];
  List<TagEpc> _successfulTags = [];
  int totalTags = 0;
  static int _value  = 0;
  int successfullySaved = 0;
  int previousSavedCount = 0;
  bool isScanning = false;
  bool _isNotified = false;
  bool _isShowModal = false;
  List<TagEpc> newData = [];
  int saveCount = 0;
  int a = 0;
  int TotalScan = 0;
  int scannedTagsCount = 0;
  final _storage = FlutterSecureStorage();
  String _selectedAgencyName = '';
  String _selectedGoodsName = '';
  bool _dataSaved = false;
  bool _isContinuousCall = false;
  List<DeletionInfo> deletionHistory = [];
  List<String> _processedEventIds = [];
  List<String> _scannedEvents = [];
  Map<String, DeletionInfo> deletionInfoMap = {};
  bool isProcessedEventsPageOpen = false;
  bool _isDialogShown = false;
  bool isShowModal = false;
  Stream<int> get updateStream => _updateStreamController.stream;
  bool _isSnackBarDisplayed = false;


  final UHFManager _uhfManager = UHFManager();
  List<TagEpc> r5_resultTags = [];
  //#endregion Variables


  @override
  void initState() {
    super.initState();
    _initDatabase();
    _audioPlayer = AudioPlayer();
    initPlatformState();
    _loadProcessedEventsFromStorage();
    loadDeletionInfoFromStorage().then((_) {
      setState(() {});
    });
    _focusNode = FocusNode();
    KeyEventChannel(
      onKeyReceived: _toggleScanning,
    ).initialize();
    uhfbleRegister();
  }


  void uhfbleRegister(){
    _uhfManager.setMultiTagCallback((tagList) { // Listen data from R5
      setState(() {
        r5_resultTags =DataProcessing.ConvertToTagEpcList(tagList);
        DataProcessing.ProcessData(r5_resultTags, _data); // Filter
        print('Data from R5: ${r5_resultTags.length}');
        updateStatusAndCountResult();
      });
    });
  }

//#region Data Handle
  Future<void> _initDatabase() async {
    await _databaseHelper.initDatabase();
    final DateTime now = DateTime.now();
    await _loadEventsWithEpcData(now); // Load events with non-empty epcData for today
  }

  Future<void> _loadEventsWithEpcData(DateTime selectedDate) async {
    print('loda');
    final events = await _databaseHelper.getEventsByDateAndAccount(selectedDate, widget.taiKhoan, 0, 0);
    print('aaa$events');
    print(widget.taiKhoan);
    final List<Calendar> eventsWithEpcData = [];
    for (final event in events) {
      print(event.id);
      // final List<TagEpc> epcData = await _databaseHelper.getRFIDDataByEventId(event.id);
      final List<TagEpc> epcData = await loadData(event.id);
      // print(epcData);
      if (epcData.isNotEmpty) {
        event.epcData = epcData;
        print(event.epcData);
        eventsWithEpcData.add(event);
      }
    }
    setState(() {
      _events = eventsWithEpcData;
    });
  }

  Future<List<TagEpc>> loadData(String key) async {
    String? dataString = await _storage.read(key: key);
    if (dataString != null) {
      // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpc
      return TagEpc.parseTags(dataString);
    }
    return [];
  }

  Future<void> saveData(String key, List<TagEpc> data) async {
    String dataString = jsonEncode(data.map((e) => e.toJson()).toList());
    await _storage.write(key: key, value: dataString);
  }

  Future<void> deleteData(String epc, String eventId) async {
    try {
      // Assuming each tag is stored with a key that combines the event ID and the EPC
      String key = 'event_${eventId}_epc_$epc';
      await _storage.delete(key: key);
      print("Tag successfully deleted for EPC: $epc in Event ID: $eventId");
    } catch (e) {
      print("Error deleting tag for EPC: $epc in Event ID: $eventId, Error: $e");
      throw Exception("Failed to delete tag for EPC: $epc in Event ID: $eventId");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF097746), // Màu nền của header
              onPrimary: Color(0xFFFAFAFA), // Màu chữ của header
              onSurface: Color(0xFF097746), // Màu chữ của nội dung
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF097746),
                foregroundColor: Color(0xFFFAFAFA),// Màu chữ của nút
                  minimumSize: Size(100, 20), // Kích thước tối thiểu của nút
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Khoảng cách giữa chữ và biên của nút
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Đường viền của nút
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDate = picked;
        _searchController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      await _loadEventsWithEpcData(picked); // Load events for the selected date with epcData
    }
  }
//#endregion   Data Handle

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
    _updateStreamController.close();
    _focusNode.dispose();
    closeAll();
  }

  closeAll() {
    RfidC72Plugin.close;
  }

  /// Initialize the platform state for C Series Scanner
  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = (await RfidC72Plugin.platformVersion)!;
      print('MinhChauLog: initPlatformState success !');
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      print('MinhChauLog: initPlatformState Failed !');
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
      print('Connection successful');
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
  // Get tag by button and add to list
  void manualReadTags(bool isStart) async {
     await _uhfManager.manualRead(isStart);
  }

  void updateTags(dynamic result) async {
    List<TagEpc> newData = TagEpc.parseTags(result); //Convert to TagEpc list
   // print(newData[0].epc.toString());
   //  newData.forEach((tag) => print('EPC: ${tag.epc}'));
   //  print('MINCHAULOG: epc count ${newData.length}');
   //  print('MINCHAULOG: epc name ${newData.first.epc}');
   //  if (newData.isEmpty) {
   //    print('newData is empty!');
   //  }
    DataProcessing.ProcessData(newData, _data); // Filter

    // List<TagEpc> uniqueData = newData.where((newTag) =>
    //     !_data.any((existingTag) => existingTag.epc == newTag.epc)).toList();
    //
    // if (!uniqueData.isEmpty) {
    //   _playScanSound();
    // }
    // _data.addAll(uniqueData);

    updateStatusAndCountResult();

    // setState(() {
    //   isScanning = true;
    //   successfullySaved = _data.length; // Cập nhật trạng thái
    // });
    // sendUpdateEvent(successfullySaved);
  }
  void updateStatusAndCountResult(){
    setState(() {
      isScanning = true;
      successfullySaved = _data.length; // Cập nhật trạng thái
    });
    sendUpdateEvent(successfullySaved);
  }

  void _onEventSelected(Calendar event) {
    setState(() {
      selectedEvent = event;
      _selectedEventId = event.id;
    });
  }

  void showSuccessDialog(int numberOfTagsRemoved) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xóa Chip Thành Công", style: TextStyle(
            // fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF097746),
          ),
        ),
          content: Text("$numberOfTagsRemoved Chip trùng lặp đã được xóa thành công.",
            style: TextStyle(
            fontSize: 18,
            // fontWeight: FontWeight.bold,
            color: Color(0xFF097746),
          ),
        ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF097746)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                  ),
                ),
                fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
              ),
              child: Text("OK",
                style: TextStyle(
                color: Colors.white
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog khi người dùng bấm OK
              },
            ),
          ],
        );
      },
    );
  }

  void _showChipsInformation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin chip',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF097746),
                  ),
                ),
                // Kiểm tra nếu có dữ liệu
                _data.isNotEmpty
                    ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      String epcString = CommonFunction().hexToString(_data[index].epc);
                      // print(epcString);// Chuyển đổi EPC từ hex sang chuỗi
                      return ListTile(
                      title: Text(
                        '${index + 1}. $epcString', // Hiển thị EPC dưới dạng chuỗi
                        style: const TextStyle(
                          color: Color(0xFF097746),
                        ),
                      ),
                    );
                  },
                )
                    : const Center( // Hiển thị nếu không có dữ liệu
                      child: Text(
                        'Không có dữ liệu',
                        style: TextStyle(
                          color: Color(0xFF097746),
                        ),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<int> getNextDeletionId() async {
    // Đọc giá trị ID cuối cùng từ storage
    String? lastIdString = await _storage.read(key: 'lastDeletionId');
    int lastId = lastIdString != null ? int.parse(lastIdString) : 0;
    // Tăng ID lên 1
    int nextId = lastId + 1;
    // Lưu ID mới vào storage
    await _storage.write(key: 'lastDeletionId', value: nextId.toString());
    return nextId;
  }

  Future<void> updateDeletionInfoForEvent(String eventId, int deletedTagsCount, DateTime deletionDate, List<String> deletedTagList) async {
    int deletedId = await getNextDeletionId();  // Lấy ID tiếp theo cho lần xóa mới
    String lenhPhanPhoi = _events.firstWhere((event) => event.id == eventId).lenhPhanPhoi;  // Lấy lệnh phân phối từ sự kiện
    // Thêm bản ghi mới vào danh sách phẳng của các bản ghi thu hồi
    deletionHistory.add(DeletionInfo(
      deletedId: deletedId,
      eventId: eventId,
      lenhPhanPhoi: lenhPhanPhoi,
      deletionDate: deletionDate,
      deletedTagsCount: deletedTagsCount,
      deletedTagList: deletedTagList,
    ));
    // Lưu thông tin thu hồi
    await saveDeletionInfo();
  }

  Future<void> handleSave() async {
    List<String> selectedEventIds = _events.where((event) => event.isSelected).map((event) => event.id).toList();
    int totalRemovedTags = 0;
    if (selectedEventIds.isEmpty) {
      // Display a message if no events are selected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Không thể lưu", style: TextStyle(
              color: Color(0xFF097746),
              fontWeight: FontWeight.bold,
            ),
            ),
            content: Text("Vui lòng chọn lịch", style: TextStyle(
              color: Color(0xFF097746),
              fontSize: 18
            ),),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF097746)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
                ),
                child: Text("OK",style:TextStyle(
                        color: Colors.white,
                      )
                  ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }
    // Hiển thị cửa sổ loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097746)),
                ),
                SizedBox(width: 20),
                Text("Đang kiểm tra...", style: TextStyle(
                  color: Color(0xFF097746),
                ),),
              ],
            ),
          ),
        );
      },
    );
    int processedCount = 0;
    for (String eventId in selectedEventIds) {
      List<TagEpc> currentEpcData = await loadData(eventId);
      List<TagEpc> epcToRemove = [];
      for (var epc in currentEpcData) {
        if (_data.any((tag) => tag.epc == epc.epc)) {
          epcToRemove.add(epc);
        }
      }
      totalRemovedTags += epcToRemove.length;
      DateTime deletionDate = DateTime.now();
      if (epcToRemove.isNotEmpty) {
        for (var epc in epcToRemove) {
          await deleteData(epc.epc, eventId);
        }
        List<TagEpc> remainingTags = currentEpcData.where((tag) => !epcToRemove.contains(tag)).toList();
        await saveData(eventId, remainingTags); // Lưu lại các tag còn lại
        // Trước khi gọi updateDeletionInfoForEvent, tạo một danh sách các EPC từ epcToRemove
        List<String> deletedTagList = epcToRemove.map((tag) => tag.epc).toList();
        // Gọi updateDeletionInfoForEvent với tất cả các tham số
        updateDeletionInfoForEvent(eventId, epcToRemove.length, deletionDate, deletedTagList);
        if (!_scannedEvents.contains(eventId)) {
          _scannedEvents.add(eventId);
        }
        processedCount += 1;
      }
      await _saveProcessedEventsToStorage();
      List<TagEpc> updatedEpcData = await loadData(eventId);
      _events.firstWhere((event) => event.id == eventId).epcData = updatedEpcData;
    }
      // Tắt cửa sổ loading
      Navigator.of(context).pop();
    // Đặt thông báo tương ứng
    if (processedCount > 0 && totalRemovedTags > 0) {
      _data.clear();  // Xóa dữ liệu đã quét
      _events.forEach((event) => event.isSelected = false);
      successfullySaved = 0;
      showSuccessDialogForMultipleEvents(selectedEventIds.length);
    } else {
      // Hiển thị thông báo không có dữ liệu tag trùng để xóa
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Thông báo", style: TextStyle(
              color: Color(0xFF097746),
              fontWeight: FontWeight.bold,
              ),
            ),
            content: Text("Không tìm thấy sản phẩm trong lịch đã chọn.", style: TextStyle(
              color: Color(0xFF097746),
              fontSize: 18
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF097746)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
                ),
                child: Text("OK",style:TextStyle(
                  color: Colors.white,
                  )
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _saveProcessedEventsToStorage() async {
    // Đọc dữ liệu đã có từ flutter_secure_storage
    String? encodedData = await _storage.read(key: 'scannedEvents');
    List<String> existingData = [];
    if (encodedData != null) {
      existingData = List<String>.from(jsonDecode(encodedData));
    }
    // Gộp dữ liệu mới vào dữ liệu đã có (nếu có)
    _scannedEvents.forEach((eventId) {
      if (!existingData.contains(eventId)) {
        existingData.add(eventId);
      }
    });
    // Chuyển đổi và lưu dữ liệu mới
    String encodedMergedData = jsonEncode(existingData);
    await _storage.write(key: 'scannedEvents', value: encodedMergedData);
  }

  Future<List<String>> _loadProcessedEventsFromStorage() async {
    await _storage.delete(key: 'scannedEvents');
    String? encodedData = await _storage.read(key: 'scannedEvents');
    if (encodedData != null) {
      List<String> decodedData = List<String>.from(jsonDecode(encodedData));
      return decodedData;
    }
    return [];
  }

  Future<void> saveDeletionInfo() async {
    try {
      var encodedData = jsonEncode(deletionHistory.map((info) => info.toJson()).toList());
      await _storage.write(key: 'deletionInfo', value: encodedData);
    } catch (e) {
      print('Error saving deletion info: $e');
    }
  }

  Future<void> loadDeletionInfoFromStorage() async {
    try {
      String? encodedData = await _storage.read(key: 'deletionInfo');
      if (encodedData != null) {
        Iterable jsonData = jsonDecode(encodedData);
        deletionHistory = jsonData.map((item) => DeletionInfo.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('Error loading deletion info: $e');
    }
  }

  void showProcessedEventsPage() async {
    setState(() {
      isProcessedEventsPageOpen = true;
    });
    await loadDeletionInfoFromStorage();
    _scannedEvents = await _loadProcessedEventsFromStorage();
    List<Calendar?> events = await Future.wait(_scannedEvents.map((id) => _databaseHelper.getEventById(id)).toList());
    // Lọc ra các sự kiện null
    List<Calendar> nonNullEvents = events.whereType<Calendar>().toList();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessedEventsPage(events: nonNullEvents, deletionHistory: deletionHistory),
      ),
    ).then((_) {
      // This callback runs when ProcessedEventsPage is popped
      setState(() {
        isProcessedEventsPageOpen = false;
      });
    });
  }

  void showSuccessDialogForMultipleEvents(int numberOfEventsProcessed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hoàn Tất", style: TextStyle(
            color: Color(0xFF097746),
            fontWeight: FontWeight.bold,
          ),
          ),
          content: Text("$numberOfEventsProcessed lịch đã được xử lý và cập nhật.", style: TextStyle(
            color: Color(0xFF097746),
            fontSize: 18
          ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF097746)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                  ),
                ),
                fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
              ),
              child: Text("OK",style:TextStyle(
                color: Colors.white,
                )
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void sendUpdateEvent(int value) {
    _updateStreamController.add(value);
  }

  void onDataReceived(int newData) {
    sendUpdateEvent(newData);
  }

//#region ScanRFID

  Future<void> stopScanning() async {
    if (!_isSnackBarDisplayed) {
      await RfidC72Plugin.stop;
      // _showSnackBar('Đã đạt đủ số lượng');
      _isSnackBarDisplayed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
  }
  Future<void> _toggleScanning() async {
    print("MinhChauLog: Start Toggle Scanning !");
    if (isProcessedEventsPageOpen) {
      return;
    }

    if (_isContinuousCall) {
      print("MinhChauLog: Stop scan !");
      manualReadTags(false);
    //  await RfidC72Plugin.stop;
      _isContinuousCall = false;
      if (_isDialogShown) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      }
    }
    else
    {
      print("MinhChauLog: Start scan !");
    //  await RfidC72Plugin.startContinuous;
      manualReadTags(true);
      _isContinuousCall = true;
      if (!_isDialogShown)
      {
        _showScanningModal();
      }
    }
    setState(() {
      _isShowModal = _isContinuousCall;
    });
  }

//#endregion

  void updateIsConnected(dynamic isConnected) {
    _isConnected = isConnected;
    print('successful');
  }

  /// Show counting tag by modal
  void _showScanningModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Trả về widget dialog
        return Center(
          child: Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              // Nội dung dialog
              child: SavedTagsModal(
                updateStream: _updateStreamController.stream,
              ),
            ),
          ),
        );
      },
    ).then((_) => _isDialogShown = false); // Cập nhật trạng thái khi dialog đóng
    _isDialogShown = true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String currentDateString = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : DateFormat('dd/MM/yyyy').format(DateTime.now());
    return
    Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Container(
            width: 150,
            height: 150,
          ),
        ),
        centerTitle: true,
        title: const Text(
                    'Kiểm kho',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF097746),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history,color: Color(0xFF097746)),
            onPressed: () {
              // showProcessedEventsModal();
              showProcessedEventsPage();
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        constraints: BoxConstraints.expand(),
        color: Color(0xFFFAFAFA),
        child: Column(
          children: [
        Container(
        alignment: Alignment.topLeft,
          margin: EdgeInsets.only(left: 20),
          child: const Text('Chọn ngày phân phối',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF097746),
              )
          ),

        ),
        const SizedBox(height:10),
        Container(
          color: const Color(0xFFFAFAFA),
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),

          child: TextField(
            readOnly: true,
            // controller: _searchController,
            decoration: InputDecoration(
              hintText: currentDateString,
              hintStyle: const TextStyle(color: Color(0xFFA2A4A8),
                fontWeight: FontWeight.normal,
              ),
              isDense: true,

              contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
              filled: true,
              fillColor:  Color(0xFFEBEDEC),
              border:
              OutlineInputBorder(
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
              suffixIcon: GestureDetector(
                onTap: () {
                  _selectDate(context);
                },
                child: Icon(Icons.arrow_drop_down_sharp, color: Color(0xFF097746), size: 30.0),
              ),
            ),
          ),
        ),
        SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                _showChipsInformation(context);
                // print('đã bấm');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 15, 0, 12),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFA),
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
                          style: TextStyle(fontSize: 24, color: Color(0xFF097746)),
                          children: [
                            TextSpan(
                              text: 'Số lượng quét\n ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            TextSpan(
                              // Kiểm tra trạng thái quét để quyết định hiển thị giá trị nào
                              text:'$successfullySaved',
                              style: TextStyle(fontSize: 22),

                              //   text: '$synchronized ? $successfullySaved' : 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(Icons.navigate_next, color: Color(0xFF097746), size: 30.0),
                  ],
                ),
              ),
            ),
          SizedBox(height: 20,),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(20, 0, 0, 5),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isAllSelected = !isAllSelected;
                    // Đặt giá trị cờ isSelected của mỗi sự kiện bằng giá trị của cờ isAllSelected
                    _events.forEach((event) {
                      event.isSelected = isAllSelected;
                    });
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      isAllSelected ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                      color: Color(0xFF097746),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Chọn tất cả',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF097746),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                _onEventSelected(event);
                                event.isSelected = !event.isSelected;
                              },
                              child: Icon(
                                event.isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                color: Color(0xFF097746),
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  event.tenDaiLy,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF097746),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sản phẩm: ${event.tenSanPham}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF097746),
                                      ),
                                    ),
                                    Text(
                                      'Số lượng: ${event.soLuong}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF097746),
                                      ),
                                    ),
                                    Text(
                                      'Số lượng quét: ${event.epcData.length}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF097746),
                                      ),
                                    ),
                                    Text(
                                      'Lệnh giao hàng: ${event.lenhPhanPhoi}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF097746),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (index != _events.length - 1) Divider(color: Colors.grey), // Thêm Divider nếu không phải hàng cuối cùng
                      ],
                    ),
                  );
                },
              ),
            ),
          ]
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: (_isContinuousCall) ? Colors.red : Color(0xFF097746),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                fixedSize: Size(150.0, 50.0),
              ),
              onPressed: () async {

                _toggleScanning();
              },
              child: (_isContinuousCall)
                  ? Text('Dừng quét', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06))
                  : Text('Bắt đầu quét', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFd5a529),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                fixedSize: Size(150.0, 50.0),
              ),
              onPressed: () {
                handleSave();
              },
              child: Text('Thu hồi',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    // )
    );
  }
}





