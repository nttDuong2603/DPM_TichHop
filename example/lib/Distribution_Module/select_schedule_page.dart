import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'model.dart';

class SelectSchedulePage extends StatefulWidget {
  final Future<List<Dealer>> Function() fetchPXKData;
  final void Function(Dealer) onSelect;

  const SelectSchedulePage({
    Key? key,
    required this.fetchPXKData,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<SelectSchedulePage> createState() => _SelectSchedulePageState();
}

class _SelectSchedulePageState extends State<SelectSchedulePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Dealer> _dealers = [];

  @override
  void initState() {
    super.initState();
    widget.fetchPXKData().then((dealers) {
      setState(() {
        _dealers = dealers; // Cập nhật danh sách các đại lý
      });
    });
  }

  List<Dealer> filterDealers(String keyword) {
    keyword = keyword.toLowerCase();
    return _dealers.where((dealer) => dealer.MPX.toLowerCase().contains(keyword) || dealer.MPX.toLowerCase().contains(keyword)).toList();
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
          ),
        ),
        title: Container(
          // margin: EdgeInsets.only(left: 16.0),
          child: const Text(
            'Danh sách lịch phân phối',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF097746),
            ),
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
                    borderSide: const BorderSide(color: Color(0xFF097746)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF097746)),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF097746)),
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
                  future: widget.fetchPXKData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                          padding: EdgeInsets.all(20.0), // Thêm padding xung quanh CircularProgressIndicator
                          child: Center(
                            child: SizedBox(
                              width: 30, // Giới hạn kích thước của CircularProgressIndicator
                              height: 30,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097746)),
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
                                color: Color(0xFF097746),  // Màu chữ
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
                                dealer.MPX,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF097746),
                                ),
                              ),
                              subtitle:Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Văn bản căn trái
                                  children: [
                                    Text(
                                      'Lệnh giao hàng: ${dealer.LXH}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: Color(0xFF097746),
                                      ),
                                    ),
                                    Text('Tên đại lý/kho: ${dealer.TSP}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: Color(0xFF097746),
                                      ),
                                    ),
                                    Text('Phiếu xuất kho: ${dealer.PXK ?? ''}  ',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: Color(0xFF097746),
                                      ),
                                    ),
                                    Text('Số bao cần xuất: ${dealer.SBCX}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: Color(0xFF097746),
                                      ),
                                    ),
                                    Text('Ghi chú: ${dealer.ghiChu ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: Color(0xFF097746),
                                      ),
                                    )
                                  ]
                              ),
                              onTap: () {
                                // widget.onSelect(_dealers[index]);
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