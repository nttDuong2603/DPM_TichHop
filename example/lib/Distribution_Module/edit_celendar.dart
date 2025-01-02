import 'package:flutter/material.dart';
import 'model.dart';
import 'database.dart';

class EditCalendarPage extends StatefulWidget {
  final Calendar event;
  final Function(Calendar)? onUpdateEvent;
  const EditCalendarPage({Key? key, required this.event, this.onUpdateEvent}) : super(key: key);

  @override
  _EditCalendarPageState createState() => _EditCalendarPageState();
}

class _EditCalendarPageState extends State<EditCalendarPage> {
  late TextEditingController _tenDaiLyController;
  late TextEditingController _tenSanPhamController;
  late TextEditingController _soLuongController;
  late TextEditingController _soLuongQuetController;
  late TextEditingController _lenhPhanPhoiController;
  late TextEditingController _phieuXuatKhoController;
  late TextEditingController _ghiChuController;

  @override
  void initState() {
    super.initState();
    _tenDaiLyController = TextEditingController(text: widget.event.tenDaiLy);
    _tenSanPhamController = TextEditingController(text: widget.event.tenSanPham);
    _soLuongController = TextEditingController(text: widget.event.soLuong.toString());
    _soLuongQuetController = TextEditingController(text: widget.event.soLuongQuet.toString());
    _lenhPhanPhoiController = TextEditingController(text: widget.event.lenhPhanPhoi);
    _phieuXuatKhoController = TextEditingController(text: widget.event.phieuXuatKho);
    _ghiChuController = TextEditingController(text: widget.event.ghiChu);
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
            color: Color(0xFF097746),
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
                  color: Color(0xFF097746),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 320,
                child: TextField(
                  controller: _tenDaiLyController,
                  decoration: InputDecoration(
                    labelText: 'Tên đại lý/Kho thuê',
                    labelStyle: const TextStyle(
                      color: Color(0xFFA2A4A8),
                      fontWeight: FontWeight.normal,
                      fontSize: 20
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
                  controller: _tenSanPhamController,
                  decoration: InputDecoration(
                    labelText: 'Tên sản phẩm',
                    labelStyle: const TextStyle(
                      color: Color(0xFFA2A4A8),
                      fontWeight: FontWeight.normal,
                        fontSize: 20
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
                  controller: _soLuongController,
                  decoration: InputDecoration(
                    labelText: 'Số lượng (Tối đa 100.000 tem)',
                    labelStyle: const TextStyle(
                      color: Color(0xFFA2A4A8),
                      fontWeight: FontWeight.normal,
                        fontSize: 20
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
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 320,
                child: TextField(
                  controller: _lenhPhanPhoiController,
                  decoration: InputDecoration(
                    labelText: 'Lệnh giao hàng',
                    labelStyle: const TextStyle(
                      color: Color(0xFFA2A4A8),
                      fontWeight: FontWeight.normal,
                        fontSize: 20
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
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 320,
                child: TextField(
                  controller: _phieuXuatKhoController,
                  decoration: InputDecoration(
                    labelText: 'Phiếu xuất kho',
                    labelStyle: const TextStyle(
                      color: Color(0xFFA2A4A8),
                      fontWeight: FontWeight.normal,
                        fontSize: 20
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
                  keyboardType: TextInputType.number,
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
              const SizedBox(height: 20),
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
                      backgroundColor: const Color(0xFF097746),
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

  void _updateEvent() {
    // Lưu các thay đổi cho sự kiện
    final String tenDaiLy = _tenDaiLyController.text;
    final String tenSanPham = _tenSanPhamController.text;
    final int soLuong = int.tryParse(_soLuongController.text) ?? 0;
    final int soLuongQuet = int.tryParse(_soLuongQuetController.text) ?? 0;
    final String lenhPhanPhoi = _lenhPhanPhoiController.text;
    final String phieuXuatKho = _phieuXuatKhoController.text;
    final String ghiChu = _ghiChuController.text;
    final String taiKhoanID = widget.event.taiKhoanID;
    // final String time = DateTime.now().toString();
    final String time = widget.event.time;
    // Cập nhật sự kiện với dữ liệu mới
    final updatedEvent = Calendar(
      // Truyền id từ sự kiện gốc
      id: widget.event.id,
      taiKhoanID: taiKhoanID,
      time: time,
      tenDaiLy: tenDaiLy,
      tenSanPham: tenSanPham,
      soLuong: soLuong,
      soLuongQuet: soLuongQuet,
      lenhPhanPhoi: lenhPhanPhoi,
      phieuXuatKho: phieuXuatKho,
      ghiChu: ghiChu,
    );

    // Gọi hàm updateEventById từ CalendarDatabaseHelper
    CalendarDatabaseHelper().updateEventById(widget.event.id, updatedEvent);

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

}
