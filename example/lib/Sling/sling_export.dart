import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rfid_c72_plugin_example/Sling/sling_send_data.dart';
import '../Helpers/calendar_database_helper.dart';
import '../Distribution_Module/calendar_deleted.dart';
import '../Distribution_Module/celendar.dart';
import '../Distribution_Module/edit_celendar.dart';
import '../Distribution_Module/history_distribution.dart';
import '../Models/model.dart';
import '../Distribution_Module/send_data.dart';
import '../Utils/app_color.dart';
import '../Home/homepage.dart';
import 'create_sling_export_schedule.dart';
import 'deleted_sling_export_schedule.dart';
import 'history_sling_export_schedule.dart';


class SlingExport extends StatefulWidget {
  final String taiKhoan;

  const SlingExport({
    Key? key,
    required this.taiKhoan,
  }) : super(key: key);

  @override
  State<SlingExport> createState() => _SlingExportState();
}

class _SlingExportState extends State<SlingExport> {
  late Calendar event;
  Future<List<Calendar>>? _eventListFuture;
  final _storage = const FlutterSecureStorage();
  Map<String, bool> daQuetMap = {};
  int selectIndex = 0;

  //#region navigation page
  void _navigateToCreateCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateSlingExportSchedule(taiKhoan: widget.taiKhoan)),
    );
  }

  void _navigateToHistoryCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              HistorySlingExportSchedule(taiKhoan: widget.taiKhoan)),
    );
  }

  void navigateToCalendarDeleted(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DeletedSlingExportSchedule(taiKhoan: widget.taiKhoan)),
    );
  }
  //#endregion navigation page

  void _onItemTap(int index) {
    if (index == 0) {
      _navigateToCreateCalendar(context);
    } else if (index == 1) {
      _navigateToHistoryCalendar(context);
    } else if (index == 2) {
      navigateToCalendarDeleted(context);
    }
    setState(() {
      selectIndex = index;
    });
  }


  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("Chuyen sang lic phan phoi");
    }
    _initializeEventList();
    _loadDaQuetMap();
  }

  Future<List<TagEpc>> loadData(String key) async {
    String? dataString = await _storage.read(key: key);
    if (dataString != null) {
      // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpcLBD
      return TagEpc.parseTags(dataString);
    }
    return [];
  }

  Future<void> _initializeEventList() async {
    try{
      var events = await CalendarDatabaseHelper().getEvents(widget.taiKhoan,tableName: "Sling");
      for (var event in events) {
        var tags = await loadData(event.id); // Sử dụng phương thức loadData
        event.soLuongQuett = tags.length; // Cập nhật số lượng quét
      }
      if (mounted) {
        setState(() {
          _eventListFuture = Future.value(events);
        });
      }
    }catch(e){
      if(kDebugMode){
        print("Error: can not get sling schedule ! $e");
      }
    }

  }

  void navigateToUpdate(BuildContext context) async {
    final isCalendarUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCalendarPage(event: event),
      ),
    );
    // Kiểm tra xem liệu dữ liệu lịch đã được cập nhật từ trang EditCalendarPage hay không
    if (isCalendarUpdated == true) {
      setState(() {
        // Cập nhật lại danh sách sự kiện với dữ liệu mới
        _eventListFuture = CalendarDatabaseHelper().getEvents(widget.taiKhoan,tableName: "Sling");
      });
    }
  }

  void updateEventList(Calendar deletedEvent) {
    if (_eventListFuture != null) {
      setState(() {
        _eventListFuture = _eventListFuture!.then((eventList) {
          eventList.removeWhere((event) => event.id == deletedEvent.id);
          return eventList;
        });
      });
    }
  }

  void updateEvent(Calendar updatedEvent) {
    if (_eventListFuture != null && mounted) {
      setState(() {
        _eventListFuture = _eventListFuture!.then((eventList) {
          for (int i = 0; i < eventList.length; i++) {
            if (eventList[i].id == updatedEvent.id) {
              eventList[i] = updatedEvent;
              break;
            }
          }
          return eventList;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> danhDauDaQuet(String eventId, bool daQuet) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool(eventId, daQuet);
    setState(() {
      daQuetMap[eventId] = daQuet;
    });
  }

  // Hàm cập nhật mới cho loadDaQuetMap
  Future<void> _loadDaQuetMap() async {
    // final prefs = await SharedPreferences.getInstance();
    final List<Calendar>? events =
    await _eventListFuture; // Chờ _eventListFuture hoàn tất và lấy giá trị

    if (events != null) {
      Map<String, bool> tempMap = {};
      for (Calendar event in events) {
        // bool daQuet = prefs.getBool(event.id) ?? false;
        // tempMap[event.id] = daQuet;
      }
      if (mounted) {
        setState(() {
          daQuetMap = tempMap;
        });
      }
    }
  }

/*  LIST OF DISTRIBUTION SCHEDULE*/
  @override
  Widget build(BuildContext context) {
    final screenWith = MediaQuery.of(context).size.width;

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            print("did pop");
            return;
          }
          print("dieu huong den homepage");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage(taiKhoan: widget.taiKhoan)),
                (Route<dynamic> route) => false,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFE9EBF1),
            elevation: 4,
            shadowColor: Colors.blue.withOpacity(0.5),
            leading: IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(taiKhoan: widget.taiKhoan)),
                      (Route<dynamic> route) => false,
                );
              },
              icon: const Icon(Icons.arrow_back),
            ),
            centerTitle: true,
            title: Text(
              'Lịch xuất Sling',
              style: TextStyle(
                fontSize: screenWith * 0.065,
                fontWeight: FontWeight.bold,
                color: AppColor.mainText,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _eventListFuture == null
                ? const Padding(
              padding: EdgeInsets.all(20.0),
              // Thêm padding xung quanh CircularProgressIndicator
              child: Center(
                child: SizedBox(
                  width: 30,
                  // Giới hạn kích thước của CircularProgressIndicator
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(AppColor.mainText),
                  ),
                ),
              ),
            )
                : FutureBuilder<List<Calendar>>(
              future: _eventListFuture!,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    // Thêm padding xung quanh CircularProgressIndicator
                    child: Center(
                      child: SizedBox(
                        width: 30,
                        // Giới hạn kích thước của CircularProgressIndicator
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.mainText),
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError && snapshot.error != null) {
                  return Center(
                    child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                  );
                } else {
                  final eventList = snapshot.data!;
                  if (eventList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(0, 220, 0, 0),
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
                              'Chưa có lịch xuất Sling',
                              style: TextStyle(
                                  fontSize: 22, color: AppColor.mainText),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    eventList.sort((a, b) => DateTime.parse(b.time)
                        .compareTo(DateTime.parse(a.time)));
                    return ListView.builder(
                      itemCount: eventList.length,
                      itemBuilder: (context, index) {
                        final event = eventList[index];
                        final color = index % 2 == 0
                            ? const Color(0xFFFAFAFA)
                            : const Color(0xFFFAFAFA);
                        return Dismissible(
                          key: Key(event.id),
                          direction: event.soLuongQuett <= 0
                              ? DismissDirection.endToStart
                              : DismissDirection.none,
                          confirmDismiss: (direction) async {
                            if (direction ==
                                DismissDirection.endToStart) {
                              if (event.soLuongQuett <= 0) {
                                // Thực hiện chuyển hướng tới trang EditPackageCalendarPage
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditCalendarPage(
                                            event: event,
                                            onUpdateEvent: updateEvent),
                                  ),
                                );
                                // Không dismiss sau khi chuyển hướng
                                return false;
                              } else {
                                // Nếu điều kiện không thỏa mãn, hiển thị thông báo lỗi
                                return false; // Không cho phép trượt
                              }
                            }
                            return false; // Không cho phép trượt trong các trường hợp khác
                          },
                          background: Container(
                            color: const Color(0xFFB3D1C0),
                            // Màu nền khi trượt
                            alignment: Alignment.centerLeft,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Icon(Icons.edit,
                                  color: AppColor.mainText),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SlingSendData(
                                    event: event,
                                    onDeleteEvent: updateEventList,
                                  ),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  _initializeEventList(); // Cập nhật giao diện
                                });
                              }
                            },
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
                              padding: const EdgeInsets.only(
                                  left: 12.0, top: 8.0, bottom: 8.0),
                              // Kiểm soát khoảng cách
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Sắp xếp theo chiều ngang
                                children: [
                                  // Phần văn bản
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      // Sắp xếp văn bản theo chiều dọc
                                      children: [
                                        Text(
                                          '${event.tenDaiLy}',
                                          style: TextStyle(
                                              color:
                                              AppColor.mainText,
                                              fontSize: screenWith * 0.05,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        Text(
                                          'Thông tin sản phẩm: ${event.tenSanPham}',
                                          style: TextStyle(
                                            color:
                                            AppColor.contentText,
                                            fontSize: screenWith * 0.05,
                                          ),
                                        ),
                                        Text(
                                          'Lệnh giao hàng: ${event.lenhPhanPhoi}',
                                          style: TextStyle(
                                              color:
                                              AppColor.contentText,
                                              fontSize:
                                              screenWith * 0.05),
                                        ),
                                        Text(
                                          'Phiếu xuất kho: ${event.phieuXuatKho}',
                                          style: TextStyle(
                                              color:
                                              AppColor.contentText,
                                              fontSize:
                                              screenWith * 0.05),
                                        ),
                                        Text(
                                          'Số lượng cần xuất: ${event.soLuong}',
                                          style: TextStyle(
                                              color:
                                              AppColor.contentText,
                                              fontSize:
                                              screenWith * 0.05),
                                        ),


                                        Text(
                                          'Ghi chú: ${event.ghiChu}',
                                          style: TextStyle(
                                              color:
                                              AppColor.contentText,
                                              fontSize:
                                              screenWith * 0.05),
                                        ),
                                        Text(
                                          "Số lượng quét SLING: ${event.soLuongQuetSlingt}",
                                          style: TextStyle(
                                              color:
                                              AppColor.contentText,
                                              fontSize:
                                              screenWith * 0.05),
                                        ),

                                        Text(
                                          "Số lượng quét RFID: ${event.soLuongQuett}",
                                          style: TextStyle(
                                              color:
                                              AppColor.contentText,
                                              fontSize:
                                              screenWith * 0.05),
                                        ),

                                        Text(
                                          'Ngày Tạo: ${event.time}',
                                          style: TextStyle(
                                              color:
                                              AppColor.contentText,
                                              fontSize:
                                              screenWith * 0.05),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Biểu tượng điều hướng
                                  const Icon(
                                    Icons.navigate_next,
                                    size: 30.0,
                                    color: AppColor.mainText,
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
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                  color: AppColor.mainText,
                  size: 35,
                ),
                label: 'Tạo lịch',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.history,
                  color: AppColor.mainText,
                  size: 35,
                ),
                label: 'Lịch sử xuất Sling',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.auto_delete_outlined,
                  color: AppColor.mainText,
                  size: 35,
                ),
                label: 'Lịch đã xóa',
              ),
            ],
            currentIndex: selectIndex,
            // Chỉ số hiện tại
            onTap: _onItemTap,
            // Gọi hàm _onItemTap khi chọn một mục
            selectedItemColor: AppColor.mainText,
            // Màu của mục đang chọn
            unselectedItemColor:
            AppColor.mainText, // Màu của mục chưa chọn
          ),
        )
    );

  }
}
