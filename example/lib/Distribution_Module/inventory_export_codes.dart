import 'package:flutter/material.dart';
import '../Utils/app_color.dart';
import '../utils/app_config.dart';
import 'model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectExportCodesPage extends StatefulWidget {
  final String selectedPXK; // Mã PXK đã chọn
  final String pTien;
  final Function(List<ExportCode>) onConfirm;

  const SelectExportCodesPage({Key? key,
    required this.selectedPXK,
    required this.pTien,
    required this.onConfirm
  }) : super(key: key);

  @override
  State<SelectExportCodesPage> createState() => _SelectExportCodesPageState();
}

class _SelectExportCodesPageState extends State<SelectExportCodesPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<ExportCode> _exportCodes = [];
  // String IP = 'http://192.168.19.180:5088/api';
  // String IP = 'https://jvf-admin.rynansaas.com/api';

  @override
  void initState() {
    super.initState();
    fetchExportCodes(widget.selectedPXK); // Gọi hàm fetch để lấy danh sách ExportCodes theo PXK đã chọn
  }

  Future<void> fetchExportCodes(String maPXK) async {
    List<ExportCode> exportCodes = await fetchmaPPData(maPXK);
    setState(() {
      _exportCodes = exportCodes;
      _isLoading = false;
    });
  }

  Future<List<ExportCode>> fetchmaPPData(String maPXK) async {
    int startAt = 0;
    const int dataAmount = 1000;
    bool hasMore = true;
    while (hasMore) {
      final response = await http.get(
        Uri.parse('${AppConfig.IP}/api/F2BA4953EAA6481086144DD0508466C2/$maPXK'),
        headers: {
          'Content-Type': 'application/json',
          'start-at': '$startAt',
          'Data-Amount': '$dataAmount',
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];
        if (data.isNotEmpty) {
          for (var item in data) {
            _exportCodes.add(
              ExportCode(
                maPP: item["MaPhanPhoi"],
                congthuc: item[""],
                lenhGiaoHang: item["MaLenhGiaoHang"],
                tenDaiLy: item["TenNhaPhanPhoiDen"],
                maSanPham: item["MaSanPham"],
                soHoaDon: item["SoHoaDon"],
                soBaoCanXuat: item["SoLuongCanXuat"],
                soTanCanXuat: item[""],
                ghiChu: item["GhiChu"],
            ));
          }
          // Chỉ tiếp tục gọi API nếu số lượng dữ liệu trả về = 1000
          if (data.length == dataAmount) {
            startAt += dataAmount; // Cập nhật chỉ số bắt đầu cho lần yêu cầu tiếp theo
          } else {
            hasMore = false; // Dừng vòng lặp nếu số lượng dữ liệu trả về < 1000
          }
        } else {
          hasMore = false; // Dừng vòng lặp nếu không còn dữ liệu
        }
      } else {
        throw Exception('Failed to load data');
      }
    }
    return _exportCodes;
  }

  List<ExportCode> _selectedExportCodes = [];

  List<ExportCode> filterExportCodes(String keyword) {
    keyword = keyword.toLowerCase();
    return _exportCodes.where((code) =>
    code.lenhGiaoHang!.toLowerCase().contains(keyword) ||
        code.maSanPham!.toLowerCase().contains(keyword) ||
        code.soHoaDon!.toLowerCase().contains(keyword)).toList();
  }

  void onSearchTextChanged(String text) {
    setState(() {});
  }
  void onExportCodeSelected(ExportCode exportCode) {
    setState(() {
      if (_selectedExportCodes.isEmpty) {
        // Nếu danh sách rỗng thì thêm phiếu xuất kho mới
        _selectedExportCodes.add(exportCode);
      } else {
        // Kiểm tra xem tất cả các phiếu xuất kho đã chọn có cùng mã sản phẩm và tên đại lý không
        bool isSameProductAndAgency = _selectedExportCodes.every((code) =>
        code.maSanPham == exportCode.maSanPham && code.tenDaiLy == exportCode.tenDaiLy);

        if (isSameProductAndAgency) {
          // Nếu giống nhau, cho phép thêm hoặc xóa phiếu xuất kho
          if (_selectedExportCodes.contains(exportCode)) {
            _selectedExportCodes.remove(exportCode);
          } else {
            _selectedExportCodes.add(exportCode);
          }
        } else {
          // Nếu khác nhau, hiển thị modal cảnh báo
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  "Lỗi",
                  style: TextStyle(
                    color: AppColor.mainText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  "Vui lòng chọn các Lệnh giao hàng có cùng Sản phẩm và Đại lý.",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColor.mainText,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Đóng", style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColor.mainText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        }
      }
    });
  }

  void onConfirmSelection() {
    // Trả về danh sách các phiếu xuất kho đã chọn khi nhấn nút "Xác nhận"
    Navigator.pop(context, _selectedExportCodes);
  }

  void showSelectedCodesPreview() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of the screen width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Xác nhận mã Lệnh giao hàng đã chọn?',
                style: TextStyle(
                  color: AppColor.mainText,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                // textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _selectedExportCodes.map((code) => Column(
                      children: [
                        ListTile(
                          title: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Số Lệnh giao hàng: ',
                                  style: TextStyle(
                                    color: AppColor.mainText,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: '${code.lenhGiaoHang} \n${code.maPP}',
                                  style: const TextStyle(
                                    color: AppColor.mainText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Sản phẩm: ',
                                  style: TextStyle(
                                    color: AppColor.mainText,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: '${code.maSanPham}\n',
                                  style: const TextStyle(
                                    color: AppColor.mainText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Số hóa đơn: ',
                                  style: TextStyle(
                                    color: AppColor.mainText,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: '${code.soHoaDon}\n',
                                  style: const TextStyle(
                                    color: AppColor.mainText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // TextSpan(
                                //   text: 'Tên đại lý: ',
                                //   style: TextStyle(
                                //     color: AppColor.mainText,
                                //     fontSize: 18,
                                //   ),
                                // ),
                                // TextSpan(
                                //   text: '${code.tenDaiLy}\n',
                                //   style: TextStyle(
                                //     color: AppColor.mainText,
                                //     fontSize: 18,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                const TextSpan(
                                  text: 'Số bao cần xuất: ',
                                  style: TextStyle(
                                    color: AppColor.mainText,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: '${code.soBaoCanXuat}\n',
                                  style: const TextStyle(
                                    color: AppColor.mainText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // TextSpan(
                                //   text: 'Số tấn cần xuất: ',
                                //   style: TextStyle(
                                //     color: AppColor.mainText,
                                //     fontSize: 18,
                                //   ),
                                // ),
                                // TextSpan(
                                //   text: '${code.soTanCanXuat}\n',
                                //   style: TextStyle(
                                //     color: AppColor.mainText,
                                //     fontSize: 18,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                const TextSpan(
                                  text: 'Ghi chú: ',
                                  style: TextStyle(
                                    color: AppColor.mainText,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: '${code.ghiChu}',
                                  style: const TextStyle(
                                    color: AppColor.mainText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1.5,
                        ),
                      ],
                    )).toList(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainText),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(const Size(100.0, 30.0)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(_selectedExportCodes);
                      onConfirmSelection();
                    },
                    child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ExportCode> filteredExportCodes = _searchController.text.isNotEmpty
        ? filterExportCodes(_searchController.text)
        : _exportCodes;

    // Check if _exportCodes is not empty before accessing the first element
    ExportCode? commonExportCode = _exportCodes.isNotEmpty ? _exportCodes[0] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách Lệnh giao hàng',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColor.mainText,
          ),
        ),
      ),
      body: Theme(
        data: ThemeData(
          checkboxTheme: CheckboxThemeData(
            checkColor: MaterialStateProperty.all(Colors.white),
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColor.mainText; // Color when checked
              }
              return Colors.white; // Color when unchecked
            }),
            side: MaterialStateBorderSide.resolveWith(
                    (states) => const BorderSide(color: AppColor.mainText, width: 2.0)),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFFFAFAFA),
          child: Column(
            children: [
              // Phần tìm kiếm
              Container(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: onSearchTextChanged,
                  decoration: InputDecoration(
                    hintText: 'Nhập tìm kiếm',
                    hintStyle: const TextStyle(
                      color: Color(0xFFA2A4A8),
                      fontWeight: FontWeight.normal,
                    ),
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
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
                        onSearchTextChanged('');
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
              // Phần hiển thị thông tin chung
            Container(
              alignment: Alignment.topLeft,
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 0), // Căn chỉnh sát trái
              child: commonExportCode != null ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mã PXK: ${widget.selectedPXK}', // Hiển thị Mã PXK
                    style: const TextStyle(fontSize: 18, color: AppColor.mainText, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Phương tiện: ${widget.pTien}', // Hiển thị Phương tiện
                    style: const TextStyle(fontSize: 18, color: AppColor.mainText, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tên Đại Lý: ${commonExportCode.tenDaiLy}', // Hiển thị Tên Đại lý
                    style: const TextStyle(fontSize: 18, color: AppColor.mainText, fontWeight: FontWeight.bold),
                  ),
                ],
              ) : const SizedBox(), // Empty widget when commonExportCode is null
            ),
              const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              // Danh sách các lệnh giao hàng
              Expanded(
                child: ListView.builder(
                  itemCount: filteredExportCodes.length,
                  itemBuilder: (context, index) {
                    ExportCode exportCode = filteredExportCodes[index];
                    bool isSelected = _selectedExportCodes.contains(exportCode);
                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(left: 8.0, right: 0.0),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child:  Row(
                                children: [
                                  const Text(
                                    'Lệnh giao hàng: ', // Không in đậm
                                    style: TextStyle(
                                      color: AppColor.mainText,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    '${exportCode.lenhGiaoHang}', // In đậm lệnh giao hàng
                                    style: const TextStyle(
                                      color: AppColor.mainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Padding(
                            //   padding: EdgeInsets.only(left: 120.0, top: 0, bottom: 0), // Căn lề bằng với chiều dài của 'Lệnh giao hàng: '
                            //    child:
                               Text(
                                '(${exportCode.maPP})', // Mã phân phối
                                style: const TextStyle(
                                  color: AppColor.mainText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            // ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Sản phẩm: ', // Không in đậm
                                    style: TextStyle(
                                      color: AppColor.mainText,
                                      fontSize: 18,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${exportCode.maSanPham}', // In đậm
                                    style: const TextStyle(
                                      color: AppColor.mainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Số hóa đơn: ', // Không in đậm
                                    style: TextStyle(
                                      color: AppColor.mainText,
                                      fontSize: 18,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${exportCode.soHoaDon}', // In đậm
                                    style: const TextStyle(
                                      color: AppColor.mainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Số bao cần xuất: ', // Không in đậm
                                    style: TextStyle(
                                      color: AppColor.mainText,
                                      fontSize: 18,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${exportCode.soBaoCanXuat ?? ''} ', // In đậm
                                    style: const TextStyle(
                                      color: AppColor.mainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // RichText(
                            //   text: TextSpan(
                            //     children: [
                            //       TextSpan(
                            //         text: 'Số tấn cần xuất: ', // Không in đậm
                            //         style: TextStyle(
                            //           color: AppColor.mainText,
                            //           fontSize: 18,
                            //         ),
                            //       ),
                            //       TextSpan(
                            //         text: '${exportCode.soTanCanXuat}', // In đậm
                            //         style: TextStyle(
                            //           color: AppColor.mainText,
                            //           fontSize: 18,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Ghi chú: ', // Không in đậm
                                    style: TextStyle(
                                      color: AppColor.mainText,
                                      fontSize: 18,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${exportCode.ghiChu ?? ''}', // In đậm
                                    style: const TextStyle(
                                      color: AppColor.mainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.only(left: 0.0, right: 0.0), // Giảm padding bên phải của Checkbox
                          child: Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                onExportCodeSelected(exportCode);
                              },
                            ),
                          ),
                        ),
                        onTap: () {
                          onExportCodeSelected(exportCode);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.mainText,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            fixedSize: const Size(150.0, 50.0),
          ),
          onPressed: _selectedExportCodes.isNotEmpty ? showSelectedCodesPreview : null,
          child: const Text(
            'Tiếp tục',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
