import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rfid_c72_plugin_example/Assign_Packing_Information/model_information_package.dart';
import 'dart:async';
import '../Utils/app_color.dart';
import 'model_recall_manage.dart';
import 'database_recall.dart';
import 'send_data-recall.dart';
import 'celendar_recall.dart';
import 'history_recall.dart';
import '../Home/homepage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'edit_recall_schedule.dart';
import 'calendar_recall_deleted.dart';

class RecallToCancel extends StatefulWidget {
  final String taiKhoan;

  const RecallToCancel({
    Key? key,
    required this.taiKhoan,
  }) : super(key: key);

  @override
  State<RecallToCancel> createState() => OfflineRecallManageState();
}

class OfflineRecallManageState extends State<RecallToCancel> {
  final _storage = const FlutterSecureStorage();
  Future<List<CalendarRecall>>? _eventListFuture;
  int selectIndex = 0;

  void _navigateToCreateCalendarRecall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CreateCalendarRecall(taiKhoan: widget.taiKhoan, isRecallCancel: true,)),
    );
  }

  void _navigateToHistoryCalendarRecall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              HistoryRecallManage(taiKhoan: widget.taiKhoan, isRecallCancel: true ,)),
    );
  }

  void _navigateToOfflineRecallManageDeleted(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              OfflineRecallManageDeleted(taiKhoan: widget.taiKhoan,isRecallCancel: true)),
    );
  }

  void _onItemTap(int index) {
    // Kiểm tra chỉ số (index) và điều hướng đến trang tương ứng
    if (index == 0) {
      _navigateToCreateCalendarRecall(context);
    } else if (index == 1) {
      // Điều hướng đến trang "Lịch sử phân phối"
      _navigateToHistoryCalendarRecall(context);
    } else if (index == 2) {
      // Điều hướng đến trang "Lịch đã xóa"
      _navigateToOfflineRecallManageDeleted(context);
    }

    // Đặt lại selectIndex để cập nhật trạng thái BottomNavigationBar
    setState(() {
      selectIndex = index;
    });
  }

  // Widget _build() {
  //   switch (selectIndex) {
  //     case 0:
  //     // Trang "Tạo lịch phân phối mới"
  //       return CreateCalendarRecall(taiKhoan: widget.taiKhoan, isRecallCancel: true,);
  //     case 1:
  //     // Trang "Lịch sử phân phối"
  //       return HistoryRecallManage(taiKhoan: widget.taiKhoan);
  //     case 2:
  //     // Trang "Lịch đã xóa"
  //       return OfflineRecallManageDeleted(taiKhoan: widget.taiKhoan);
  //     default:
  //     // Mặc định quay lại trang chính
  //       return HomePage(taiKhoan: widget.taiKhoan);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _initializeEventList();
  }

  Future<void> _initializeEventList() async {
    var events =
    await CalendarRecallDatabaseHelper().getEvents(widget.taiKhoan!);
    for (var event in events) {
      var tags = await loadData(event.idLTH); // Sử dụng phương thức loadData
      event.soluongquet = tags.length; // Cập nhật số lượng quét
    }
    setState(() {
      _eventListFuture = Future.value(events);
    });
  }

  void updateEvent(CalendarRecall updatedEvent) {
    if (_eventListFuture != null && mounted) {
      setState(() {
        _eventListFuture = _eventListFuture!.then((eventList) {
          // Tìm và cập nhật sự kiện trong danh sách bằng cách so sánh id của các sự kiện
          for (int i = 0; i < eventList.length; i++) {
            if (eventList[i].idLTH == updatedEvent.idLTH) {
              eventList[i] = updatedEvent;
              break;
            }
          }
          return eventList;
        });
      });
    }
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

  Future<List<TagEpcLDB>> loadData(String key) async {
    String? dataString = await _storage.read(key: key);
    if (dataString != null) {
      // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpcLBD
      return TagEpcLDB.parseTags(dataString);
    }
    return [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWith = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(taiKhoan: widget.taiKhoan)),
                (Route<dynamic> route) => false,
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFE9EBF1),
            shadowColor: Colors.blue.withOpacity(0.5),
            leading: IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(taiKhoan: widget.taiKhoan)),
                      (Route<dynamic> route) => false,
                );
              },
              icon: const Icon(Icons.arrow_back),
            ),
            centerTitle: true,
            title: Text(
              'Lịch thu hồi hủy bỏ',
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
                : FutureBuilder<List<CalendarRecall>>(
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
                              'Chưa có lịch thu hồi',
                              style: TextStyle(
                                  fontSize: 22, color: AppColor.mainText),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    eventList.sort((a, b) => DateTime.parse(b.ngayTaoLTH)
                        .compareTo(DateTime.parse(a.ngayTaoLTH)));
                    return ListView.builder(
                      itemCount: eventList.length,
                      itemBuilder: (context, index) {
                        final event = eventList[index];
                        final color = index % 2 == 0
                            ? const Color(0xFFFAFAFA)
                            : const Color(0xFFFAFAFA);
                        return Dismissible(
                            key: Key(event.idLTH),
                            direction: event.soluongquet <= 0
                                ? DismissDirection.endToStart
                                : DismissDirection.none,
                            confirmDismiss: (direction) async {
                              if (direction ==
                                  DismissDirection.endToStart) {
                                if (event.soluongquet <= 0) {
                                  // Thực hiện chuyển hướng tới trang EditPackageCalendarPage
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditRecallCalendarPage(
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
                                    builder: (context) => SendDataRecall(
                                      event: event,
                                      onDeleteEvent: updateEventList, isSurplusGoodRecall: true,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  _initializeEventList();
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
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 1.0, 8.0, 1.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  // Sắp xếp theo chiều ngang
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        // Sắp xếp văn bản theo chiều dọc
                                        children: [
                                          Text(
                                            '${event.ghiChuLTH}',
                                            style: TextStyle(
                                                color: AppColor.mainText,
                                                fontSize:
                                                screenWith * 0.055,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                          Text(
                                            'Số lượng quét: ${event.soluongquet}',
                                            style: TextStyle(
                                              color:
                                              AppColor.contentText,
                                              fontSize: screenWith * 0.05,
                                            ),
                                          ),
                                          Text(
                                            'Ngày tạo: ${event.ngayTaoLTH}',
                                            style: TextStyle(
                                              color:
                                              AppColor.contentText,
                                              fontSize: screenWith * 0.05,
                                            ),
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
                            ));
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
                label: 'Lịch sử thu hồi',
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
            // showSelectedLabels: false, // Ẩn nhãn mục được chọn
            // showUnselectedLabels: false, // Ẩn nhãn mục chưa được chọn
            selectedItemColor: AppColor.mainText,
            // Màu của mục đang chọn
            unselectedItemColor:
            AppColor.mainText, // Màu của mục chưa chọn
          ),
        ));
  }
}
