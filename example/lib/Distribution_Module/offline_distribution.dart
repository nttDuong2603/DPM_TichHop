import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'history_distribution.dart';
import '../Home/homepage.dart';
import 'send_data.dart';
import 'celendar.dart';
import 'model.dart';
import 'database.dart';
import 'edit_celendar.dart';
import 'calendar_deleted.dart';

class OfflineDistribution extends StatefulWidget {
  final String taiKhoan;
  const OfflineDistribution({
    Key? key,
    required this.taiKhoan,
  }) : super(key: key);

  @override
  State<OfflineDistribution> createState() => _OfflineDistributionState();
}

class _OfflineDistributionState extends State<OfflineDistribution> {
  late Calendar event;
  Future<List<Calendar>>? _eventListFuture;
  final _storage = const FlutterSecureStorage();
  Map<String, bool> daQuetMap = {};
  int selectIndex = 0;


  void _navigateToCreateCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateCalendar(taiKhoan: widget.taiKhoan!)),
    );
  }

  void _navigateToHistoryDistribution(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryDistribution(taiKhoan: widget.taiKhoan!)),
    );
  }
  void navigateToCalendarDeleted(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalendarDeleted(taiKhoan: widget.taiKhoan)),
    );
  }

  void _onItemTap(int index) {
    // Kiểm tra chỉ số (index) và điều hướng đến trang tương ứng
    if (index == 0) {
      // Điều hướng đến trang "Tạo lịch phân phối mới"
      _navigateToCreateCalendar(context);
    }
   else  if (index == 1) {
      // Điều hướng đến trang "Lịch sử phân phối"
      _navigateToHistoryDistribution(context);

  } else if (index == 2) {
      // Điều hướng đến trang "Lịch đã xóa"
      navigateToCalendarDeleted(context);
    }

    // Đặt lại selectIndex để cập nhật trạng thái BottomNavigationBar
    setState(() {
      selectIndex = index;
    });
  }


  Widget _build() {
    switch (selectIndex) {
      case 0:
      // Trang "Tạo lịch phân phối mới"
        return CreateCalendar(taiKhoan: widget.taiKhoan);
      case 1:
      // Trang "Lịch sử phân phối"
        return HistoryDistribution(taiKhoan: widget.taiKhoan);
      case 2:
      // Trang "Lịch đã xóa"
        return CalendarDeleted(taiKhoan: widget.taiKhoan);
      default:
      // Mặc định quay lại trang chính
        return HomePage(taiKhoan: widget.taiKhoan);
    }
  }


  @override
  void initState() {
    super.initState();
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
    var events = await CalendarDatabaseHelper().getEvents(widget.taiKhoan!);
    for (var event in events) {
      var tags = await loadData(event.id); // Sử dụng phương thức loadData
      event.soLuongQuett = tags.length;  // Cập nhật số lượng quét
    }
    setState(() {
      _eventListFuture = Future.value(events);
    });
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
        _eventListFuture = CalendarDatabaseHelper().getEvents(widget.taiKhoan!);
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
          // Tìm và cập nhật sự kiện trong danh sách bằng cách so sánh id của các sự kiện
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
    final List<Calendar>? events = await _eventListFuture; // Chờ _eventListFuture hoàn tất và lấy giá trị

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

  @override
  Widget build(BuildContext context) {
    final screenWith = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return  WillPopScope(
        onWillPop: () async {
          // Thay vì chỉ pop trang hiện tại, hãy sử dụng pushAndRemoveUntil để quay trực tiếp về HomePage
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage(taiKhoan: widget.taiKhoan)), // Giả sử bạn truyền taiKhoan vào HomePage
                (Route<dynamic> route) => false, // Xóa tất cả các routes khác khỏi stack
          );
          return false; // Ngăn không cho hành động pop mặc định
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFE9EBF1),
            elevation: 4,
            shadowColor: Colors.blue.withOpacity(0.5),
            leading: Container(
              ),
            centerTitle: true,
            title: Text(
              'Lịch phân phối ',
              style: TextStyle(
                fontSize: screenWith * 0.065,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF097746),
              ),
            ),
            // actions: [
            // Padding(
            //   padding: EdgeInsets.only(right: screenWith * 0.03),
            //   child: Row(
            //     children: [
            //       IconButton(
            //         icon: Icon(Icons.history,
            //           color: Color(0xFF097746),
            //         ),
            //         iconSize: screenWith * 0.1,
            //         onPressed: () {
            //           // _navigateToHistoryDistribution(context);
            //           navigateToCalendarDeleted(context);
            //         },
            //       ),
            //       InkWell(
            //         onTap: () {
            //           _navigateToCreateCalendar(context);
            //         },
            //         child: Image.asset(
            //           'assets/image/add.png',
            //           width: screenWith * 0.085, // Chiều rộng hình ảnh
            //           height: screenHeight * 0.085, // Chiều cao hình ảnh
            //         ),
            //       ),
            //     ]
            //   )
            // )
            // ],
          ),
          body: Padding (
            padding: const EdgeInsets.only(top: 8.0),
            child: _eventListFuture == null ? const Padding(
              padding: EdgeInsets.all(20.0), // Thêm padding xung quanh CircularProgressIndicator
              child: Center(
                child: SizedBox(
                  width: 30, // Giới hạn kích thước của CircularProgressIndicator
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097746)),
                  ),
                ),
              ),
            )  : FutureBuilder<List<Calendar>>(
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
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097746)),
                        ),
                      ),
                    ),
                  ) ;
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
                              'Chưa có lịch phân phối',
                              style: TextStyle(fontSize: 22, color: Color(0xFF097746)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    eventList.sort((a, b) => DateTime.parse(b.time).compareTo(DateTime.parse(a.time)));
                    return ListView.builder(
                      itemCount: eventList.length,
                      itemBuilder: (context, index) {
                        final event = eventList[index];
                        final color = index % 2 == 0 ? const Color(0xFFFAFAFA) : const Color(0xFFFAFAFA);
                        return
                          Dismissible(
                              key: Key(event.id),
                              direction: event.soLuongQuett <= 0 ? DismissDirection.endToStart : DismissDirection.none,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  if (event.soLuongQuett <= 0) {
                                    // Thực hiện chuyển hướng tới trang EditPackageCalendarPage
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditCalendarPage(event: event, onUpdateEvent: updateEvent),
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
                                color: const Color(0xFFB3D1C0), // Màu nền khi trượt
                                alignment: Alignment.centerLeft,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Icon(Icons.edit, color: Color(0xFF097746)),
                                ),
                              ),
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SendData(
                                      event: event,
                                      onDeleteEvent: updateEventList,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  _initializeEventList(); // Cập nhật danh sách sau khi trở về
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
                                padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0), // Kiểm soát khoảng cách
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Sắp xếp theo chiều ngang
                                  children: [
                                    // Phần văn bản
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start, // Sắp xếp văn bản theo chiều dọc
                                        children: [
                                          Text('${event.tenDaiLy}',
                                            style: TextStyle(
                                              color: const Color(0xFF097746),
                                              fontSize: screenWith*0.05,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          Text(
                                            'Thông tin sản phẩm: ${event.tenSanPham}',
                                            style: TextStyle(
                                                color: const Color(0xFF097746),
                                                fontSize: screenWith*0.05,
                                            ),
                                          ),
                                          Text(
                                            'Số lượng: ${event.soLuong}',
                                            style: TextStyle(
                                                color: const Color(0xFF097746),
                                                fontSize: screenWith*0.05
                                            ),
                                          ),
                                          Text(
                                            "Số lượng quét: ${event.soLuongQuett}",
                                            style: TextStyle(
                                                color: const Color(0xFF097746),
                                                fontSize: screenWith*0.05
                                            ),
                                          ),
                                          Text(
                                            'Lệnh giao hàng: ${event.lenhPhanPhoi}',
                                            style: TextStyle(
                                                color: const Color(0xFF097746),
                                                fontSize: screenWith*0.05
                                            ),
                                          ),

                                          Text(
                                            'Phiếu xuất kho: ${event.phieuXuatKho}',
                                            style: TextStyle(
                                                color: const Color(0xFF097746),
                                                fontSize: screenWith*0.05
                                            ),
                                          ),
                                          Text(
                                            'Ghi chú: ${event.ghiChu}',
                                            style: TextStyle(
                                                color: const Color(0xFF097746),
                                                fontSize: screenWith*0.05

                                            ),
                                          ),
                                          Text(
                                            'Ngày Tạo: ${event.time}',
                                            style: TextStyle(
                                                color: const Color(0xFF097746),
                                                fontSize: screenWith*0.05
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Biểu tượng điều hướng
                                    const Icon(
                                      Icons.navigate_next,
                                      size: 30.0,
                                      color: Color(0xFF097746),
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
                    color: Color(0xFF097746),
                  size: 35,
                ),
                label: 'Tạo lịch',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.history,
                  color: Color(0xFF097746),
                  size: 35,
                ),
                label: 'Lịch sử phân phối',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                    Icons.auto_delete_outlined,
                    color: Color(0xFF097746),
                  size: 35,
                ),
                label: 'Lịch đã xóa',
              ),
            ],
            currentIndex: selectIndex, // Chỉ số hiện tại
            onTap: _onItemTap, // Gọi hàm _onItemTap khi chọn một mục
            // showSelectedLabels: false, // Ẩn nhãn mục được chọn
            // showUnselectedLabels: false, // Ẩn nhãn mục chưa được chọn
            selectedItemColor: const Color(0xFF097746), // Màu của mục đang chọn
            unselectedItemColor: const Color(0xFF097746), // Màu của mục chưa chọn
          ),
        )
    );
  }
}