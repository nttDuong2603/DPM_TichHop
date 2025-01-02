import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart'; // Import thư viện intl
import 'database_package_inf.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'model_information_package.dart';
import 'information_package.dart';

class CreateCalendarDistributionInf extends StatefulWidget {
  final String taiKhoan;
  const CreateCalendarDistributionInf({
    Key? key,
    required this.taiKhoan,
  }) : super(key: key);

  @override
  State<CreateCalendarDistributionInf> createState() => _CreateCalendarDistributionInfState();
}

class _CreateCalendarDistributionInfState extends State<CreateCalendarDistributionInf> {

  final dbHelper = CalendarDistributionInfDatabaseHelper();
  final TextEditingController _maLDBController = TextEditingController();
  final TextEditingController _sanPhamLDBController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _maLDBController.dispose();
    _sanPhamLDBController.dispose();
    _ghiChuController.dispose();
    super.dispose();

  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thêm lịch thành công!'),
        backgroundColor: Color(0xFF4EB47D),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void navigateToOfflineInformationDistribution(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OfflineInformationDistribution(taiKhoan: widget.taiKhoan)),
    );
  }

  Future<void> _addEvent(BuildContext context) async {
    final DateTime now = DateTime.now(); // Lấy thời gian hiện tại
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    // Tạo một UUID ngẫu nhiên
    String idLDB = const Uuid().v4();

    final event = CalendarDistributionInf(
      idLDB: idLDB,
      maLDB: _maLDBController.text,
      sanPhamLDB: _sanPhamLDBController.text,
      ghiChuLDB: _ghiChuController.text,
      taiKhoanID: widget.taiKhoan,
      ngayTaoLDB: formattedTime,
    );

    await dbHelper.insertEvent(event, widget.taiKhoan);
    _showSuccessMessage(context);
    navigateToOfflineInformationDistribution(context);
  }

  void someFunction() async {
    CalendarDistributionInfDatabaseHelper dbHelper = CalendarDistributionInfDatabaseHelper();
    await dbHelper.printCalendarDistributionInfData();
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () {},
              child:
                Container(
                    width: 100,
                    height: 100,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Tạo lịch',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF097746),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
        constraints: const BoxConstraints.expand(),
        color: const Color(0xFFFAFAFA),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Text(
                'Nhập thông tin lịch',
                style: TextStyle(
                  fontSize: 26,
                  color: Color(0xFF097746),
                ),
              ),
              const SizedBox(height: 13),
              Container(
                width: 320,
                child: TextField(
                  controller: _maLDBController,
                  decoration: InputDecoration(
                    labelText: 'Mã lệnh đóng bao',
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
              const SizedBox(height: 15),
              Container(
                width: 320,
                child: TextField(
                  controller: _sanPhamLDBController,
                  decoration: InputDecoration(
                    labelText: 'Tên sản phẩm',
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: ElevatedButton(
            onPressed: () {
              // Xử lý sự kiện khi nút "Thêm" được nhấn
              if (_maLDBController.text.isNotEmpty &&
                  _sanPhamLDBController.text.isNotEmpty) {
                    _addEvent(context);
                } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập đủ thông tin.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF097746),
              padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              fixedSize: const Size(320.0, 40.0),
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
}
