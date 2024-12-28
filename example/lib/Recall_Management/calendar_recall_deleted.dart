import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Assign_Packing_Information/model_information_package.dart';
import 'dart:async';
import 'model_recall_manage.dart';
import 'database_recall.dart';
import 'recall_manage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OfflineRecallManageDeleted extends StatefulWidget {
  final String taiKhoan;
  const OfflineRecallManageDeleted({
    Key? key,
    required this.taiKhoan,
  }) : super(key: key);

  @override
  State<OfflineRecallManageDeleted> createState() => OfflineRecallManageDeletedState();
}

class OfflineRecallManageDeletedState extends State<OfflineRecallManageDeleted> {
  final _storage = FlutterSecureStorage();
  Future<List<CalendarRecall>>? _eventListFuture;
  int selectIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeEventList();
  }

  Future<void> _initializeEventList() async {
    var events = await CalendarRecallDatabaseHelper().getDeletedEvents(widget.taiKhoan!);
    for (var event in events) {
      var tags = await loadData(event.idLTH); // Sử dụng phương thức loadData
      event.soluongquet = tags.length;  // Cập nhật số lượng quét
    }
    setState(() {
      _eventListFuture = Future.value(events);
    });
  }

  void updateEvent( CalendarRecall updatedEvent) {
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

  Future<List<TagEpcLBD>> loadData(String key) async {
    String? dataString = await _storage.read(key: key);
    if (dataString != null) {
      // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpcLBD
      return TagEpcLBD.parseTags(dataString);
    }
    return [];
  }

  Future<void> unDeleteEventFromCalendar(CalendarRecall event) async {
    try {
      final dbHelper = CalendarRecallDatabaseHelper();
      await dbHelper.unDeleteEvent(event); // Cập nhật sự kiện trong cơ sở dữ liệu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Khôi phục lịch thành công'),
          backgroundColor: Color(0xFF4EB47D),
          duration: Duration(seconds: 2),
        ),
      );
      // Cập nhật danh sách sự kiện
      setState(() {
        _eventListFuture = CalendarRecallDatabaseHelper().getDeletedEvents(widget.taiKhoan);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi khi khôi phục lịch!'),
          backgroundColor: Color(0xFF4EB47D),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
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
            MaterialPageRoute(builder: (context) => OfflineRecallManage(taiKhoan: widget.taiKhoan)), // Giả sử bạn truyền taiKhoan vào HomePage
                (Route<dynamic> route) => false, // Xóa tất cả các routes khác khỏi stack
          );
          return false; // Ngăn không cho hành động pop mặc định
        },
        child:Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFE9EBF1),
            shadowColor: Colors.blue.withOpacity(0.5),
            leading: Container(
            ),
            centerTitle: true,
            title: Text(
              'Lịch thu hồi đã xóa',
              style: TextStyle(
                fontSize: screenWith * 0.065,
                fontWeight: FontWeight.bold,
                color: Color(0xFF097746),
              ),
            ),
          ),
          body: Padding (
            padding: EdgeInsets.only(top: 8.0),
            child: _eventListFuture == null ? Padding(
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
            ) : FutureBuilder<List<CalendarRecall>>(
              future: _eventListFuture!,
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
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
                      padding: EdgeInsets.fromLTRB(30, 220, 30, 0),
                      constraints: BoxConstraints.expand(),
                      color: Color(0xFFFAFAFA),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/image/canhbao1.png',
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Chưa có lịch thu hồi được xóa',
                              style: TextStyle(fontSize: 22, color: Color(0xFF097746)),
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
                        final color = index % 2 == 0 ? Color(0xFFFAFAFA) : Color(0xFFFAFAFA);
                        return
                          Dismissible(
                              key: Key(event.idLTH),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  bool confirm = await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Xác nhận khôi phục lịch',
                                          style: TextStyle(color: Color(0xFF097746), fontWeight: FontWeight.bold),
                                        ),
                                        content: Text(
                                          "Bạn có chắc chắn muốn khôi phục lịch này không?",
                                          style: TextStyle(fontSize: 18, color: Color(0xFF097746)),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF097746)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
                                            ),
                                            child: Text(
                                              'Hủy',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop(false); // Trả về false khi hủy
                                            },
                                          ),
                                          SizedBox(width: 8),
                                          TextButton(
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF097746)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
                                            ),
                                            child: Text(
                                              'Xác Nhận',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            onPressed: () async {
                                              await unDeleteEventFromCalendar(event); // Chờ cho việc khôi phục hoàn tất
                                              Navigator.of(context).pop(true); // Trả về true khi xác nhận
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return confirm; // Trả về giá trị của confirmDismiss cho Dismissible
                                }
                                return false;
                              },
                              background: Container(
                                color: Color(0xFFB3D1C0), // Màu nền khi trượt
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Icon(Icons.restore_from_trash_outlined, color: Color(0xFF097746)),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  // Hiển thị hộp thoại xác nhận trước khi xóa
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    barrierDismissible: false, // Ngăn đóng hộp thoại khi nhấn ra ngoài
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Xác nhận xóa lịch vĩnh viễn',
                                            style: TextStyle(
                                                color: Color(0xFF097746), fontWeight: FontWeight.bold)),
                                        content: Text("Bạn có chắc chắn muốn xóa lịch này vĩnh viễn không?",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Color(0xFF097746),
                                            )),
                                        actions: <Widget>[
                                          TextButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                              MaterialStateProperty.all<Color>(Color(0xFF097746)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
                                            ),
                                            child: Text('Hủy',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                )),
                                            onPressed: () {
                                              Navigator.of(context).pop(false); // Trả về giá trị false
                                            },
                                          ),
                                          SizedBox(width: 8),
                                          TextButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                              MaterialStateProperty.all<Color>(Color(0xFF097746)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
                                            ),
                                            child: Text('Xác Nhận',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                )),
                                            onPressed: () {
                                              Navigator.of(context).pop(true); // Trả về giá trị true
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  // Nếu người dùng xác nhận xóa, gọi hàm xóa vĩnh viễn
                                  if (confirmDelete) {
                                    try {
                                      final dbHelper = CalendarRecallDatabaseHelper();
                                      await dbHelper.deleteEventPermanently(event); // Gọi hàm xóa sự kiện
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Xóa lịch thành công!'),
                                          backgroundColor: Color(0xFF4EB47D),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      setState(() {
                                        // Cập nhật lại danh sách sự kiện sau khi xóa
                                        _eventListFuture = dbHelper.getDeletedEvents(widget.taiKhoan);
                                      });
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Đã xảy ra lỗi khi xóa lịch!'),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
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
                                  padding: EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 1.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Sắp xếp theo chiều ngang
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, // Sắp xếp văn bản theo chiều dọc
                                          children: [
                                            Text('${event.ghiChuLTH}',
                                              style: TextStyle(
                                                  color: Color(0xFF097746),
                                                  fontSize: screenWith*0.055,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Text(
                                              'Số lượng quét: ${event.soluongquet}',
                                              style: TextStyle(
                                                color: Color(0xFF097746),
                                                fontSize: screenWith*0.05,
                                              ),
                                            ),
                                            Text(
                                              'Ngày tạo: ${event.ngayTaoLTH}',
                                              style: TextStyle(
                                                color: Color(0xFF097746),
                                                fontSize: screenWith*0.05,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.delete_outline,
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
        )
    );
  }
}