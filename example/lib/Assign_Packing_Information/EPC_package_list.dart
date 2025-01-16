import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Utils/app_color.dart';
import 'model_information_package.dart';
import 'database_package_inf.dart';
import '../utils/common_functions.dart';

class EPCPackgaeList extends StatefulWidget {
  final String eventId;
  EPCPackgaeList({Key? key, required this.eventId}) : super(key: key);

  @override
  _EPCPackgaeListState createState() => _EPCPackgaeListState();
}

class _EPCPackgaeListState extends State<EPCPackgaeList> {
  late CalendarDistributionInfDatabaseHelper _databaseHelper;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _databaseHelper = CalendarDistributionInfDatabaseHelper();
    _initDatabase(); // Gọi hàm khởi tạo cơ sở dữ liệu
    print('object');
  }

  Future<void> _initDatabase() async {
    await _databaseHelper.initDatabase();
  }

  Future<List<TagEpcLDB>> loadData(String key) async {
    String? dataString = await _storage.read(key: key);
    if (dataString != null) {
      // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpcLBD
      return TagEpcLDB.parseTags(dataString);
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
            color: AppColor.mainText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<TagEpcLDB>>(
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
                     // String epcString = CommonFunction().hexToString(snapshot.data![index].epc);
                      String? epcString = CommonFunction().hexToString(snapshot.data![index].epc);
                      return ListTile(
                        title: Text(
                          '${index + 1}. ${epcString ?? ''}',
                          style: const TextStyle(
                            color: AppColor.mainText,
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
                        style: TextStyle(fontSize: 22, color: AppColor.mainText),
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