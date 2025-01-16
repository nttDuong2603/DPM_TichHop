import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../Utils/app_color.dart';
import 'model_information_package.dart';
import 'package:intl/intl.dart';

class PackageScheduleList extends StatefulWidget {
  final Future<List<Dealer>> Function() fetch1MLDB;
  final void Function(Dealer) onSelect;

  const PackageScheduleList({
    Key? key,
    required this.fetch1MLDB,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<PackageScheduleList> createState() => _PackageScheduleListState();
}

class _PackageScheduleListState extends State<PackageScheduleList> {
  final TextEditingController _searchController = TextEditingController();
  List<Dealer> _dealers = [];

  @override
  void initState() {
    super.initState();
    widget.fetch1MLDB().then((dealers) {
      setState(() {
        _dealers = dealers; // Cập nhật danh sách các đại lý
      });
    });
  }

  List<Dealer> filterDealers(String keyword) {
    keyword = keyword.toLowerCase();
    return _dealers.where((dealer) => dealer.maLDB.toLowerCase().contains(keyword)).toList();
  }

  void onSearchTextChanged(String text) {
    setState(() {
      // Gọi lại FutureBuilder để cập nhật danh sách đại lý/kho theo từ khóa tìm kiếm mới
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text(
          'Danh sách lịch đóng bao',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColor.mainText,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
        constraints: const BoxConstraints.expand(),
        color: const Color(0xFFFAFAFA),
        child: Column(
          children: [
            Container(

              color: const Color(0xFFFAFAFA),
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TextField(
                controller: _searchController,
                onChanged: onSearchTextChanged,
                decoration: InputDecoration(
                  hintText: 'Nhập tìm kiếm',
                  hintStyle: const TextStyle(color: Color(0xFFA2A4A8),
                    fontWeight: FontWeight.normal,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
                  filled: true,
                  fillColor:  const Color(0xFFEBEDEC),
                  border:
                  OutlineInputBorder(
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
                    },
                    icon: Image.asset(
                      'assets/image/search_icon.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                child:
                FutureBuilder<List<Dealer>>(
                  future: widget.fetch1MLDB(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                          padding: EdgeInsets.all(20.0), // Thêm padding xung quanh CircularProgressIndicator
                          child: Center(
                            child: SizedBox(
                              width: 30, // Giới hạn kích thước của CircularProgressIndicator
                              height: 30,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColor.mainText),
                              ),
                            ),
                          )
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
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
                    } else if (snapshot.hasData) {
                      List<Dealer> filteredDealers = snapshot.data!;
                      if (_searchController.text.isNotEmpty) {
                        filteredDealers = filterDealers(_searchController.text);
                      }
                      return ListView.builder(
                        itemCount: filteredDealers.length,
                        itemBuilder: (context, index) {
                          Dealer dealer = filteredDealers[index];
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
                                dealer.maLDB,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.mainText,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Văn bản căn trái
                                children: [
                                  Text(
                                    'Mã Sản Phẩm: ${dealer.maSP}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: AppColor.mainText,
                                    ),
                                  ),
                                  Text(
                                    'Tên Sản Phẩm: ${dealer.tenSP ?? ' '}' ,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: AppColor.mainText,
                                    ),
                                  ),
                                  Text(
                                    'Số bao cần sản xuất: ${dealer.SBCSX ?? ' '}' ,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: AppColor.mainText,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Text("Ngày sản xuất: ",  style: TextStyle(
                                        fontSize: 18,
                                        color: AppColor.mainText,
                                      )),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                            DateFormat('dd/MM/yyyy').format(DateTime.parse(dealer.ngaySX!)),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: AppColor.mainText,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                widget.onSelect(dealer);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return const Text('Không có dữ liệu');
                    }
                  },
                )
            ),
          ],
        ),
      ),
    );
  }
}