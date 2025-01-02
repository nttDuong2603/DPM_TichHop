import 'package:flutter/material.dart';
import 'calendar_package_inf.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'database_package_inf.dart';
import 'model_information_package.dart';
import 'send_package_inf.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'edit_package_schedule.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'history_package_schedule.dart';
import '../Home/homepage.dart';
import 'offline_package_schedule_deleted_list.dart';


class OfflineInformationDistribution extends StatefulWidget {
  final String taiKhoan;

  const OfflineInformationDistribution({
    Key? key,
    required this.taiKhoan,
  }) : super(key: key);

  @override
  State<OfflineInformationDistribution> createState() => _OfflineInformationDistributionState();

}

class _OfflineInformationDistributionState extends State<OfflineInformationDistribution> {
  final _storage = const FlutterSecureStorage();
  Map<String, bool> danhdaudaQuetMap = {};
  Future<List<CalendarDistributionInf>>? _eventListFuture;
  int selectIndex = 0;


  void _navigateToCreateCalendarDistributionInf(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateCalendarDistributionInf(taiKhoan: widget.taiKhoan!)),
    );
  }

  void _navigateToHistoryPackage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPackgage(taiKhoan: widget.taiKhoan!)),
    );
  }
  void _navigateToOfflinePackageScheduleDeletedList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OfflinePackageScheduleDeletedList(taiKhoan: widget.taiKhoan!)),
    );
  }

  void _onItemTap(int index) {
    // Kiểm tra chỉ số (index) và điều hướng đến trang tương ứng
    if (index == 0) {
      // Điều hướng đến trang "Tạo lịch phân phối mới"
      _navigateToCreateCalendarDistributionInf(context);
    }
    else  if (index == 1) {
      // Điều hướng đến trang "Lịch sử phân phối"
      _navigateToHistoryPackage(context);

    } else if (index == 2) {
      // Điều hướng đến trang "Lịch đã xóa"
      _navigateToOfflinePackageScheduleDeletedList(context);
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
        return CreateCalendarDistributionInf(taiKhoan: widget.taiKhoan);
      case 1:
      // Trang "Lịch sử phân phối"
        return HistoryPackgage(taiKhoan: widget.taiKhoan);
      case 2:
      // Trang "Lịch đã xóa"
        return OfflinePackageScheduleDeletedList(taiKhoan: widget.taiKhoan);
      default:
      // Mặc định quay lại trang chính
        return HomePage(taiKhoan: widget.taiKhoan);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeEventList();
    // _loadDaQuetMap();
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
    var events = await CalendarDistributionInfDatabaseHelper().getEvents(widget.taiKhoan!);
    for (var event in events) {
      var tags = await loadData(event.idLDB); // Sử dụng phương thức loadData
      event.soLuongQuet = tags.length;  // Cập nhật số lượng quét
    }
    setState(() {
      _eventListFuture = Future.value(events);
    });
  }

  void updateEventList(CalendarDistributionInf deletedEvent) {
    if (_eventListFuture != null) {
      setState(() {
        _eventListFuture = _eventListFuture!.then((eventList) {
          eventList.removeWhere((event) => event.idLDB == deletedEvent.idLDB);
          return eventList;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateEvent( CalendarDistributionInf updatedEvent) {
    if (_eventListFuture != null && mounted) {
      setState(() {
        _eventListFuture = _eventListFuture!.then((eventList) {
          // Tìm và cập nhật sự kiện trong danh sách bằng cách so sánh id của các sự kiện
          for (int i = 0; i < eventList.length; i++) {
            if (eventList[i].idLDB == updatedEvent.idLDB) {
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
  Widget build(BuildContext context) {
    final screenWith = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
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
                  'Lịch đóng bao',
                  style: TextStyle(
                    fontSize: screenWith * 0.065,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF097746),
                  ),
                ),
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
                )  : FutureBuilder<List<CalendarDistributionInf>>(
                  future: _eventListFuture!,
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return
                          const Padding(
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
                                  'Chưa có lịch đóng bao',
                                  style: TextStyle(fontSize: 22, color: Color(0xFF097746)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        eventList.sort((a, b) => DateTime.parse(b.ngayTaoLDB).compareTo(DateTime.parse(a.ngayTaoLDB)));
                        return ListView.builder(
                          itemCount: eventList.length,
                          itemBuilder: (context, index) {
                            final event = eventList[index];
                            final color = index % 2 == 0 ? const Color(0xFFFAFAFA) : const Color(0xFFFAFAFA);
                            return
                              Dismissible(
                                  key: Key(event.idLDB),
                                  direction: event.soLuongQuet <= 0 ? DismissDirection.endToStart : DismissDirection.none,
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.endToStart) {
                                      if (event.soLuongQuet <= 0) {
                                        // Thực hiện chuyển hướng tới trang EditPackageCalendarPage
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditPackageCalendarPage(event: event, onUpdateEvent: updateEvent),
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
                                        builder: (context) => SendDistributionInf (
                                          event: event,
                                          onDeleteEvent: updateEventList,
                                        ),
                                      ),
                                    );
                                    if (result != null) {
                                      // danhDauDaQuet(event.idLDB, result);
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
                                      padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
                                      child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Sắp xếp theo chiều ngang
                                      children: [
                                        // Phần văn bản
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start, // Sắp xếp văn bản theo chiều dọc
                                            children: [
                                              Text(
                                                event.maLDB,
                                                style: TextStyle(
                                                    color: const Color(0xFF097746),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: screenWith*0.05
                                                ),
                                              ),
                                              Text(
                                                'Sản phẩm: ${event.sanPhamLDB}',
                                                style: TextStyle(
                                                    color: const Color(0xFF097746),
                                                    fontSize: screenWith*0.05
                                                ),
                                              ),
                                              Text(
                                                'Số lượng quét: ${event.soLuongQuet}',
                                                style: TextStyle(
                                                    color: const Color(0xFF097746),
                                                    fontSize: screenWith*0.05
                                                ),
                                              ),
                                              Text(
                                                'Ghi chú: ${event.ghiChuLDB}',
                                                style: TextStyle(
                                                    color: const Color(0xFF097746),
                                                    fontSize: screenWith*0.05
                                                ),
                                              ),
                                              Text(
                                                'Ngày Tạo: ${event.ngayTaoLDB}',
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
                              )
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
                label: 'Lịch sử đóng bao',
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