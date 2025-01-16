import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rfid_c72_plugin_example/Assign_Packing_Information/model_information_package.dart';
import 'dart:async';
import '../Utils/app_color.dart';
import 'model_recall_manage.dart';
import 'database_recall.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HistoryRecallManage extends StatefulWidget {
  final String taiKhoan;
  final bool isRecallCancel;
  const HistoryRecallManage({Key? key, required this.taiKhoan, required this.isRecallCancel}) : super(key: key);

  @override
  State<HistoryRecallManage> createState() => HistoryRecallManageState();
}

class HistoryRecallManageState extends State<HistoryRecallManage> {

  Future<List<CalendarRecall>>? _eventListFuture;
  final _storage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeEventList();
  }

  Future<List<TagEpcLDB>> loadData(String key) async {
    String? dataString = await _storage.read(key: key);
    if (dataString != null) {
      // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpcLBD
      return TagEpcLDB.parseTags(dataString);
    }
    return [];
  }

  Future<void> _initializeEventList() async {
    var events = await CalendarRecallDatabaseHelper().getHistoryEvents(widget.taiKhoan!);
    for (var event in events) {
      var tags = await loadData(event.idLTH); // Sử dụng phương thức loadData
      event.soluongquet = tags.length;  // Cập nhật số lượng quét
    }
    for (var event in events) {
      // Lấy các giá trị từ bộ nhớ an toàn cho event cụ thể
      var counts = await loadCountsHistoryRecallFromStorage(event.idLTH);
      // Gán các giá trị từ 'counts' cho các thuộc tính của 'event'
      event.thuHoiThanhCong = counts['successCount'] ?? 0;
      event.thuHoiThatBai = counts['failCount'] ?? 0;
      event.ngayThuHoi = counts['currentDate'] ?? '';
    }
    setState(() {
      _eventListFuture = Future.value(events);
    });
  }

  String getKey( String eventId, String id) {
    return '$eventId-$id';
  }

  Future<Map<String, dynamic>> loadCountsHistoryRecallFromStorage(String eventId) async {
    final secureRecallStorage = const FlutterSecureStorage();
    // Tạo một map để lưu các giá trị
    final Map<String, dynamic> data = {};
    // Lấy các giá trị từ bộ nhớ an toàn
    final successCount = await secureRecallStorage.read(key: getKey("successCount", eventId));
    final failCount = await secureRecallStorage.read(key: getKey("failCount", eventId));
    final currentDate = await secureRecallStorage.read(key: getKey("currentDate", eventId));
    // Chuyển đổi giá trị thành số nguyên và lưu vào map
    data['successCount'] = int.tryParse(successCount ?? '0') ?? 0;
    data['failCount'] = int.tryParse(failCount ?? '0') ?? 0;
    data['currentDate'] = currentDate;
    return data;
  }

  void updateEventList(CalendarRecall deletedEvent) {
    if (_eventListFuture != null) {
      setState(() {
        _eventListFuture = _eventListFuture!.then((eventList) {
          eventList.removeWhere((event) => event.idLTH == deletedEvent.idLTH);
          return eventList;
        });
      });
    }
  }

  void onSearchTextChanged(String text) async {
    // If there's no text, simply reload the original event list
    if (text.isEmpty) {
      _initializeEventList();
      return;
    }
    var originalEvents = await _eventListFuture!;
    var filteredEvents = originalEvents.where((event) =>
    event.ghiChuLTH.toLowerCase().contains(text.toLowerCase()) ||
        event.ngayThuHoi.toLowerCase().contains(text.toLowerCase())).toList();
    setState(() {
      // Replace the current Future with a new one containing only filtered events
      _eventListFuture = Future.value(filteredEvents);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWith = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return  Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFE9EBF1),
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.5),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.arrow_back)),
          title: Text(
           widget.isRecallCancel ? 'Lịch sử thu hồi huỷ bỏ' : 'Lịch sử thu hồi xuất dư' ,
            style: TextStyle(
              fontSize: screenWith * 0.07,
              fontWeight: FontWeight.bold,
              color: AppColor.mainText,
            ),
          ),
        ),
        body: Column(
            children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
            child: Container(
              color: const Color(0xFFFAFAFA),
              child: TextField(
                controller: _searchController,
                onChanged: onSearchTextChanged,
                decoration: InputDecoration(
                  hintText: 'Nhập tìm kiếm',
                  hintStyle: const TextStyle(
                    color: Color(0xFFA2A4A8),
                    fontWeight: FontWeight.normal,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
                  filled: true,
                  fillColor: const Color(0xFFEBEDEC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColor.mainText),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColor.mainText),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColor.mainText),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      onSearchTextChanged(_searchController.text);
                    },
                    icon: Image.asset(
                      'assets/image/search_icon.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
            ),
        ),
          Expanded(
                // padding: EdgeInsets.only(top: 8.0),
                child: _eventListFuture == null ? const Padding(
                  padding: EdgeInsets.all(20.0), // Thêm padding xung quanh CircularProgressIndicator
                  child: Center(
                    child: SizedBox(
                      width: 30, // Giới hạn kích thước của CircularProgressIndicator
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColor.mainText),
                      ),
                    ),
                  ),
                ) : FutureBuilder<List<CalendarRecall>>(
                  future: _eventListFuture!,
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                          padding: EdgeInsets.all(20.0), // Thêm padding xung quanh CircularProgressIndicator
                          child: Center(
                            child: SizedBox(
                              width: 30, // Giới hạn kích thước của CircularProgressIndicator
                              height: 30,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColor.mainText),
                              ),
                            ),
                          )
                          );
                    } else if (snapshot.hasError && snapshot.error != null) {
                      return Center(
                        child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                      );
                    } else {
                      final eventList = snapshot.data!;
                      if (eventList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(30, 220, 30, 0),
                          constraints: const BoxConstraints.expand(),
                          color: const Color(0xFFFAFAFA),
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                  'assets/image/canhbao1.png',
                                  width: 50,
                                  height: 50,
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  'Chưa có lịch sử thu hồi',
                                  style: TextStyle(fontSize: 22, color: AppColor.mainText),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        eventList.sort((a, b) => DateTime.parse(b.ngayTaoLTH).compareTo(DateTime.parse(a.ngayTaoLTH)));
                        return ListView.builder(
                          itemCount: eventList.length,
                          itemBuilder: (context, index) {
                            final event = eventList[index];
                            final color = index % 2 == 0 ? const Color(0xFFFAFAFA) : const Color(0xFFFAFAFA);
                            return GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 1.0),
                                child: ListTile(
                                  title: Text(
                                    '${event.ghiChuLTH}',
                                    style: const TextStyle(
                                        color: AppColor.mainText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Số lượng thu hồi: ${event.thuHoiThanhCong}',
                                        style: const TextStyle(
                                            color: AppColor.contentText,
                                            fontSize: 22
                                        ),
                                      ),
                                      Text(
                                        'Ngày thu hồi: ${event.ngayThuHoi}',
                                        style: const TextStyle(
                                            color: AppColor.contentText,
                                            fontSize: 22
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              )
            ]
        )
    );
  }
}