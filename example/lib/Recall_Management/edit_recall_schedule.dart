import 'package:flutter/material.dart';
import '../Utils/app_color.dart';
import 'model_recall_manage.dart';
import 'database_recall.dart';

class EditRecallCalendarPage extends StatefulWidget {
  final CalendarRecall event;
  final Function(CalendarRecall)? onUpdateEvent;

  const EditRecallCalendarPage({Key? key, required this.event, this.onUpdateEvent}) : super(key: key);

  @override
  _EditRecallCalendarPageState createState() => _EditRecallCalendarPageState();
}

class _EditRecallCalendarPageState extends State<EditRecallCalendarPage> {
  late TextEditingController _ghiChuController;
  @override
  void initState() {
    super.initState();
    _ghiChuController = TextEditingController(text: widget.event.ghiChuLTH);
  }

  @override
  void dispose() {
    _ghiChuController.dispose();
    super.dispose();
  }

  void _updateEvent() {
    // Lưu các thay đổi cho sự kiện
    final String ghiChu = _ghiChuController.text;
    final String taiKhoanID = widget.event.taiKhoanID;
    // final String time = DateTime.now().toString();
    final String time = widget.event.ngayTaoLTH;
    // Cập nhật sự kiện với dữ liệu mới
    final updatedEvent = CalendarRecall(
      // Truyền id từ sự kiện gốc
      idLTH: widget.event.idLTH,
      taiKhoanID: taiKhoanID,
      ngayTaoLTH: time,
      ghiChuLTH: ghiChu,
    );
    // Gọi hàm updateEventById từ CalendarDatabaseHelper
    CalendarRecallDatabaseHelper().updateEventById(widget.event.idLTH, updatedEvent);
    // Tùy chọn, bạn có thể hiển thị một snackbar hoặc điều hướng đến màn hình khác
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cập nhật lịch thành công'),
        backgroundColor: Color(0xFF4EB47D),
      ),
    );
    if (widget.onUpdateEvent != null) {
      widget.onUpdateEvent!(updatedEvent);
    }
    // Điều hướng trở lại màn hình trước đó
    // Navigator.pop(context, updatedEvent);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFE9EBF1),
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.5),
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                },
                child: Image.asset(
                  'assets/image/logoJVF_RFID.png',
                  width: 120,
                  height: 120,
                ),
              ),
            ),
          ),
          title: const Text(
            'Cập nhật lịch',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColor.mainText,
            ),
          ),
          actions: [],
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFFFAFAFA),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Text(
                  'Nhập thông tin',
                  style: TextStyle(
                    fontSize: 26,
                    color: AppColor.mainText,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: 320,
                  child: TextField(
                    controller: _ghiChuController,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú',
                      labelStyle: const TextStyle(
                          color: Color(0xFFA2A4A8),
                          fontWeight: FontWeight.normal,
                          fontSize: 22
                      ),
                      filled: true,
                      fillColor: const Color(0xFFEBEDEC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Color(0xFFEBEDEC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFEBEDEC)),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFEBEDEC)),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    ),
                  ),
                ),
              ],
            ),
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
                        onPressed: () {
                          if (_updateEvent != null) { // Kiểm tra _updateEvent có null không
                            _updateEvent(); // Sử dụng _updateEvent sau khi đã kiểm tra
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColor.mainText,
                          padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          fixedSize: const Size(320.0, 50.0),
                        ),
                        child: const Text(
                          'Cập nhật',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ]
                )
            )
        )
    );
  }
}
