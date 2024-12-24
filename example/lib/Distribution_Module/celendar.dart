import 'package:flutter/material.dart';
import 'dart:async';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

import 'model.dart';
import 'database.dart';
import 'offline_distribution.dart';

class CreateCalendar extends StatefulWidget {

  final String taiKhoan;
  const CreateCalendar({
    Key? key,
    required this.taiKhoan,
  }) : super(key: key);

  @override
  State<CreateCalendar> createState() => _CreateCalendarState();
}


class _CreateCalendarState extends State<CreateCalendar> {

  final dbHelper = CalendarDatabaseHelper();
  final TextEditingController _tenDaiLyController = TextEditingController();
  final TextEditingController _tenSanPhamController = TextEditingController();
  final TextEditingController _soLuongController = TextEditingController();
  final TextEditingController _soLuongQuetController = TextEditingController();
  final TextEditingController _lenhPhanPhoiController = TextEditingController();
  final TextEditingController _phieuXuatKhoController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tenDaiLyController.dispose();
    _tenSanPhamController.dispose();
    _soLuongController.dispose();
    _soLuongQuetController.dispose();
    _lenhPhanPhoiController.dispose();
    _phieuXuatKhoController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thêm lịch thành công!'),
        backgroundColor: Color(0xFF4EB47D),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void navigateToOfflineDistribution(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OfflineDistribution(taiKhoan: widget.taiKhoan)),
    );
  }


  Future<void> _addEvent(BuildContext context) async {
    final DateTime now = DateTime.now(); // Lấy thời gian hiện tại
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    // Tạo một UUID ngẫu nhiên
    String id = Uuid().v4();

    final event = Calendar(
      id: id,
      tenDaiLy: _tenDaiLyController.text,
      tenSanPham: _tenSanPhamController.text,
      soLuong: int.tryParse(_soLuongController.text) ?? 0,
      soLuongQuet: int.tryParse(_soLuongQuetController.text) ?? 0,
      lenhPhanPhoi: _lenhPhanPhoiController.text,
      phieuXuatKho: _phieuXuatKhoController.text,
      ghiChu: _ghiChuController.text,
      taiKhoanID: widget.taiKhoan,
      time: formattedTime,
    );

    await dbHelper.insertEvent(event, widget.taiKhoan);
    _showSuccessMessage(context);
    navigateToOfflineDistribution(context);
  }

  void someFunction() async {
    CalendarDatabaseHelper dbHelper = CalendarDatabaseHelper();
    await dbHelper.printCalendarData();
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
          child:
          Container(
              width: 100,
            height: 100,
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
              SizedBox(height: 13),
              Container(
                width: 320,
                child: TextField(
                  controller: _tenDaiLyController,
                  decoration: InputDecoration(
                    labelText: 'Tên đại lý/Kho thuê',
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
              SizedBox(height: 15),
              Container(
                width: 320,
                child: TextField(
                  controller: _tenSanPhamController,
                  decoration: InputDecoration(
                    labelText: 'Tên sản phẩm',
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
              SizedBox(height: 15),
              Container(
                width: 320,
                child: TextField(
                  controller: _soLuongController,
                  decoration: InputDecoration(
                    labelText: 'Số lượng (Tối đa 100.000 tem)',
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
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: 320,
                child: TextField(
                  controller: _lenhPhanPhoiController,
                  decoration: InputDecoration(
                    labelText: 'Lệnh giao hàng',
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
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: 320,
                child: TextField(
                  controller: _phieuXuatKhoController,
                  decoration: InputDecoration(
                    labelText: 'Phiếu xuất kho',
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
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: 320,
                child: TextField(
                  controller: _ghiChuController,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
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
              if (_tenDaiLyController.text.isNotEmpty &&
                  _tenSanPhamController.text.isNotEmpty &&
                  _lenhPhanPhoiController.text.isNotEmpty) {
                if (_soLuongController.text.isNotEmpty) {
                  int soLuong = int.tryParse(_soLuongController.text) ?? 0;
                  if (soLuong > 0 && soLuong <= 100000) {
                    _addEvent(context);
                  } else {
                    // Hiển thị thông báo lỗi khi giá trị nhập vào không hợp lệ
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Số lượng phải là một số từ 1 đến 100,000.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  // Hiển thị thông báo lỗi khi trường số lượng không được để trống
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Vui lòng nhập số lượng.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
}
