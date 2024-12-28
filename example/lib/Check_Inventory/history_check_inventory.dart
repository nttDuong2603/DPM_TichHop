import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/common_functions.dart';
import '../Distribution_Module/model.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ProcessedEventsPage extends StatefulWidget {
  final List<Calendar> events;
  final List<DeletionInfo> deletionHistory;

  ProcessedEventsPage({Key? key, required this.events, required this.deletionHistory}) : super(key: key);

  @override
  _ProcessedEventsPageState createState() => _ProcessedEventsPageState();
}

class _ProcessedEventsPageState extends State<ProcessedEventsPage> {
  TextEditingController _searchController = TextEditingController();
  List<Calendar> _filteredEvents = [];
  bool isShowModal = true;

  @override
  void initState() {
    super.initState();
    _filteredEvents = widget.events; // Khởi tạo _filteredEvents với danh sách sự kiện ban đầu
    _searchController.addListener(_filterEvents); // Thêm listener để lọc sự kiện khi text thay đổi
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterEvents); // Loại bỏ listener khi không cần thiết nữa
    _searchController.dispose();
    super.dispose();
  }

  List<DeletionInfo> deletionHistory = [];
  final _storage = FlutterSecureStorage();


  Future<void> loadDeletionInfoFromStorage() async {
    try {
      String? encodedData = await _storage.read(key: 'deletionInfo');
      if (encodedData != null) {
        Iterable jsonData = jsonDecode(encodedData);
        deletionHistory = jsonData.map((item) => DeletionInfo.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('Error loading deletion info: $e');
    }
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEvents = widget.events;
      }
    });
  }
  void _showDeletionDetailsModal(BuildContext context, DeletionInfo deletionInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Chi tiết mã thu hồi", style: TextStyle(
            color: Color(0xFF097746),
          ),
          ),
          content: Container(
            width: double.maxFinite,
            child:
            ListView.builder(
              shrinkWrap: true,
              itemCount: deletionInfo.deletedTagList.length,
              itemBuilder: (BuildContext context, int index) {
                String epcString = CommonFunction().hexToString(deletionInfo.deletedTagList[index]);
                // Thêm số thứ tự trước mỗi chip
                return ListTile(
                  leading: Text("${index + 1}.", style: TextStyle(
                    color: Color(0xFF097746),
                  ),
                  ),
                  title: Text(epcString, style: TextStyle(
                    color: Color(0xFF097746),
                  ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF097746)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Điều chỉnh độ cong của góc
                  ),
                ),
                fixedSize: MaterialStateProperty.all<Size>(Size(100.0, 30.0)),
              ),
              child: Text("Đóng", style: TextStyle(
                color: Colors.white,
              ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lịch sử kiểm kho",
          style: TextStyle(color: Color(0xFF097746),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFFFAFAFA),
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: TextField(
              controller: _searchController,
              // onChanged: onSearchTextChanged,
              decoration: InputDecoration(
                hintText: 'Nhập tìm kiếm',
                hintStyle: TextStyle(
                  color: Color(0xFFA2A4A8),
                  fontWeight: FontWeight.normal,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
                filled: true,
                fillColor: Color(0xFFEBEDEC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Color(0xFF097746)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF097746)),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF097746)),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/image/search_icon.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: FutureBuilder<void>(
              future: loadDeletionInfoFromStorage(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading data'));
                } else {
                  return ListView.builder(
                    itemCount: deletionHistory.length,
                    itemBuilder: (BuildContext context, int index) {
                      deletionHistory.sort((a, b) => b.deletionDate.compareTo(a.deletionDate));
                      final deletionInfo = deletionHistory[index];
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              _showDeletionDetailsModal(context, deletionInfo);
                            },
                            title: Text(
                              "Lệnh giao hàng ${deletionInfo.lenhPhanPhoi}: \n"
                                  "Mã kiểm kho 000000${deletionInfo.deletedId}: \n"
                                  "Số lượng đã thu hồi: ${deletionInfo.deletedTagsCount}\n"
                                  "Ngày thu hồi: ${DateFormat('dd/MM/yyyy').format(deletionInfo.deletionDate)}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF097746),
                              ),
                            ),
                            trailing: Icon(
                              Icons.navigate_next,
                              color: Color(0xFF097746),
                              size: 30.0,
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1.0,
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}