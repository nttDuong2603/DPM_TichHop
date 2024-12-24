import 'package:flutter/material.dart';
import 'dart:async';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../Assign_Packing_Information/database_package_inf.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'recall_replacement_model.dart';
import 'recall_replacement_database.dart';
import 'recall_replacement_offline_list.dart';

class CreateCalendarRecallReplacement extends StatefulWidget {
  final String taiKhoan;
  const CreateCalendarRecallReplacement({
    Key? key,
    required this.taiKhoan,
  }) : super(key: key);

  @override
  State<CreateCalendarRecallReplacement> createState() => _CreateCalendarRecallReplacementState();
}

class _CreateCalendarRecallReplacementState extends State<CreateCalendarRecallReplacement> {

  final dbHelper = CalendarRecallReplacementDatabaseHelper();
  final TextEditingController _ghiChuController = TextEditingController();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ghiChuController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thêm lịch thu hồi thành công!'),
        backgroundColor: Color(0xFF4EB47D),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void navigateToOfflineRecallManage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OfflineRecallReplacemantList(taiKhoan: widget.taiKhoan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE9EBF1),
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.5),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {},
              child: Image.asset(
                'assets/image/logoJVF_RFID.png',
                width: 120,
                height: 120,
              ),
            ),
          ),
        ),
        title: Text(
          'Tạo lịch',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF097746),
          ),
        ),
        actions: [],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 15, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Color(0xFFFAFAFA),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(
                'Nhập thông tin lịch',
                style: TextStyle(
                  fontSize: 26,
                  color: Color(0xFF097746),
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: 320,
                child: TextField(
                  controller: _ghiChuController,
                  decoration: InputDecoration(
                    labelText: 'Nội dung thu hồi',
                    labelStyle: TextStyle(
                        color: Color(0xFFA2A4A8),
                        fontWeight: FontWeight.normal,
                        fontSize: 22

                    ),
                    filled: true,
                    fillColor: Color(0xFFEBEDEC),
                    border: OutlineInputBorder(
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
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 0, 0),
                      child: Text(
                        '(*)',
                        style: TextStyle(color: Colors.red[300]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: ElevatedButton(
            onPressed: () {
              // Xử lý sự kiện khi nút "Thêm" được nhấn
              if (_ghiChuController.text.isNotEmpty ) {
                _addEvent(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vui lòng nhập đủ thông tin.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF097746),
              padding: EdgeInsets.symmetric(horizontal: 70.0, vertical: 6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              fixedSize: Size(320.0, 40.0),
            ),
            child: const Text(
              'Thêm',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addEvent(BuildContext context) async {
    final DateTime now = DateTime.now(); // Lấy thời gian hiện tại
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    // Tạo một UUID ngẫu nhiên
    String idLTHTT = Uuid().v4();
    final event = CalendarRecallReplacement(
      idLTHTT: idLTHTT,
      ghiChuLTHTT: _ghiChuController.text,
      taiKhoanTTID: widget.taiKhoan,
      ngayTaoLTHTT: formattedTime,
    );
    await dbHelper.insertEvent(event, widget.taiKhoan);
    _showSuccessMessage(context);
    navigateToOfflineRecallManage(context);
  }

  void someFunction() async {
    CalendarDistributionInfDatabaseHelper dbHelper = CalendarDistributionInfDatabaseHelper();
    await dbHelper.printCalendarDistributionInfData();
  }

}
