import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'model.dart';
import 'database.dart';
import '../utils/common_functions.dart';

class EPCSyncList extends StatefulWidget {
  final String eventId;
  EPCSyncList({Key? key, required this.eventId}) : super(key: key);

  @override
  _EPCSyncListState createState() => _EPCSyncListState();
}

class _EPCSyncListState extends State<EPCSyncList> {
  late CalendarDatabaseHelper _databaseHelper;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _databaseHelper = CalendarDatabaseHelper();
    _initDatabase(); // Gọi hàm khởi tạo cơ sở dữ liệu
  }

  Future<void> _initDatabase() async {
    await _databaseHelper.initDatabase();
  }

  Future<List<TagEpc>> loadData(String key) async {
    String? dataString = await _storage.read(key: key);
    if (dataString != null) {
      // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpcLBD
      return TagEpc.parseTags(dataString);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mã chip đã đồng bộ",
          style: TextStyle(
            color: Color(0xFF097746),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<TagEpc>>(
            future: loadData(widget.eventId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      String epcString = CommonFunction().hexToString(snapshot.data![index].epc);
                      DateTime? saveDateString = snapshot.data![index].saveDate;
                      String scanDate = saveDateString !=null ?
                      DateFormat('dd/MM/yyyy hh:mm:ss').format(saveDateString): '';
                      return ListTile(
                        title: Text(
                          '${index + 1}. $epcString',
                          style: const TextStyle(
                            color: Color(0xFF097746),
                          ),
                        ),
                        subtitle: Text(
                          '- Ngày quét: $scanDate',
                          style: const TextStyle(
                            color: Color(0xFF097746),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 100),

                      Image.asset(
                        'assets/image/canhbao1.png',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Không có dữ liệu',
                        style: TextStyle(fontSize: 22, color: Color(0xFF097746)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}