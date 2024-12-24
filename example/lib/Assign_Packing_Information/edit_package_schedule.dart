import 'package:flutter/material.dart';
import 'model_information_package.dart';
import 'database_package_inf.dart';

class EditPackageCalendarPage extends StatefulWidget {
  final CalendarDistributionInf event;
  final Function(CalendarDistributionInf)? onUpdateEvent;

  const EditPackageCalendarPage({Key? key, required this.event, this.onUpdateEvent}) : super(key: key);

  @override
  _EditPackgageCalendarPageState createState() => _EditPackgageCalendarPageState();
}

class _EditPackgageCalendarPageState extends State<EditPackageCalendarPage> {
  late TextEditingController _maLichDongBaoController;
  late TextEditingController _tenSanPhamController;
  late TextEditingController _ghiChuController;

  @override
  void initState() {
    super.initState();
    _maLichDongBaoController = TextEditingController(text: widget.event.maLDB);
    _tenSanPhamController = TextEditingController(text: widget.event.sanPhamLDB);
    _ghiChuController = TextEditingController(text: widget.event.ghiChuLDB);
  }

  @override
  void dispose() {
    // Dispose controllers when not needed
    _maLichDongBaoController.dispose();
    _tenSanPhamController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  void _updateEvent() {
    // Lưu các thay đổi cho sự kiện
    final String tenDaiLy = _maLichDongBaoController.text;
    final String tenSanPham = _tenSanPhamController.text;
    final String ghiChu = _ghiChuController.text;
    final String taiKhoanID = widget.event.taiKhoanID;
    // final String time = DateTime.now().toString();
    final String time = widget.event.ngayTaoLDB;
    // Cập nhật sự kiện với dữ liệu mới
    final updatedEvent = CalendarDistributionInf(
      // Truyền id từ sự kiện gốc
      idLDB: widget.event.idLDB,
      taiKhoanID: taiKhoanID,
      ngayTaoLDB: time,
      maLDB: tenDaiLy,
      sanPhamLDB: tenSanPham,
      ghiChuLDB: ghiChu,
    );

    // Gọi hàm updateEventById từ CalendarDatabaseHelper
    CalendarDistributionInfDatabaseHelper().updateEventById(widget.event.idLDB, updatedEvent);

    // Tùy chọn, bạn có thể hiển thị một snackbar hoặc điều hướng đến màn hình khác
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cập nhật lịch thành công'),
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
        backgroundColor: Color(0xFFE9EBF1),
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
        title: Text(
          'Cập nhật lịch',
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
                'Nhập thông tin',
                style: TextStyle(
                  fontSize: 26,
                  color: Color(0xFF097746),
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: 320,
                child: TextField(
                  controller: _maLichDongBaoController,
                  decoration: InputDecoration(
                    labelText: 'Mã lịch đóng bao',
                    labelStyle: TextStyle(
                        color: Color(0xFFA2A4A8),
                        fontWeight: FontWeight.normal,
                        fontSize: 20
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
                        fontSize: 20
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
                          backgroundColor: Color(0xFF097746),
                          padding: EdgeInsets.symmetric(horizontal: 70.0, vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          fixedSize: Size(320.0, 50.0),
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
