import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Utils/app_color.dart';
import 'model_information_package.dart';

class SelectMLNKPage extends StatefulWidget {
  final List<WearHouseTypeList> mlNKList;
  final void Function(WearHouseTypeList) onSelect;

  const SelectMLNKPage({
    Key? key,
    required this.mlNKList,
    required this.onSelect,
  }) : super(key: key);

  @override
  _SelectMLNKPageState createState() => _SelectMLNKPageState();
}

class _SelectMLNKPageState extends State<SelectMLNKPage> {
  List<WearHouseTypeList> _filteredMLNKList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredMLNKList = widget.mlNKList; // Khởi tạo danh sách ban đầu
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose(); // Giải phóng tài nguyên khi không còn cần thiết
    super.dispose();
  }

  void _onSearchTextChanged() {
    String keyword = _searchController.text.toLowerCase();
    setState(() {
      _filteredMLNKList = widget.mlNKList
          .where((item) => item.tenLNK.toLowerCase().contains(keyword))
          .toList();
    });
  }

  // Hàm hiển thị modal xác nhận
  void _showLNKConfirmationDialog(BuildContext context, WearHouseTypeList selectedMLNK) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Xác nhận Loại Nhâp kho?',
            style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold),
          ),
          content: Text('Bạn có chắc chắn muốn chọn loại nhập kho: ${selectedMLNK.tenLNK}?',
            style: const TextStyle(color: AppColor.mainText),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                  ),
                ),
                fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
              ),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng modal mà không làm gì
              },
            ),
            const SizedBox(width: 8), // Khoảng cách giữa các nút
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                  ),
                ),
                fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng modal
                widget.onSelect(selectedMLNK); // Trả về giá trị đã chọn
                // Navigator.pop(context); // Đóng trang chọn MLNK
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            width: 100,
            height: 100,
          ),
        ),
        title: const Text(
          'Chọn Loại nhập kho!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColor.mainText,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
        color: const Color(0xFFFAFAFA),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Nhập tìm kiếm',
                  hintStyle: const TextStyle(
                    color: Color(0xFFA2A4A8),
                    fontWeight: FontWeight.normal,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
                  filled: true,
                  fillColor: const Color(0xFFEBEDEC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColor.mainText),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColor.mainText),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColor.mainText),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearchTextChanged();
                    },
                    icon: const Icon(Icons.clear, color: AppColor.mainText),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredMLNKList.length,
                itemBuilder: (context, index) {
                  WearHouseTypeList mlNK = _filteredMLNKList[index];
                  Padding(
                    padding: const EdgeInsets.only(top: 00.0),  // Khoảng cách phía trên
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,  // Căn giữa các widget trong Row
                      children: <Widget>[
                        Image.asset(
                          'assets/image/canhbao1.png',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(height: 10),  // Khoảng cách giữa icon và văn bản
                        const Text(
                          "Vui lòng kiểm tra kết nối",
                          style: TextStyle(
                            fontSize: 18,  // Đặt kích thước chữ
                            color: AppColor.mainText,  // Màu chữ
                          ),
                        ),
                      ],
                    ),
                  );
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        mlNK.tenLNK,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColor.mainText,
                        ),
                      ),
                      subtitle: Text(
                        'Mã Loại nhập kho: ${mlNK.maLNK}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColor.mainText,
                        ),
                      ),
                      onTap: () {
                        // Gọi hàm hiển thị modal xác nhận khi người dùng chọn một mục
                        _showLNKConfirmationDialog(context, mlNK);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}