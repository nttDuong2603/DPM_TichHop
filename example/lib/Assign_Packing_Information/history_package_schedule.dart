import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'database_package_inf.dart';
import 'model_information_package.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'EPC_package_list.dart';

class HistoryPackgage extends StatefulWidget {
  final String taiKhoan;
  const HistoryPackgage({Key? key, required this.taiKhoan}) : super(key: key);

  @override
  State<HistoryPackgage> createState() => _HistoryPackgageState();
}

class _HistoryPackgageState extends State<HistoryPackgage> {
  final TextEditingController _searchController = TextEditingController();

  Future<List<CalendarDistributionInf>>? _eventListFuture;
  final _storage = const FlutterSecureStorage();
  List<CalendarDistributionInf> currentEvents = [];
  final packageInfStorage = const FlutterSecureStorage();
  Map<String, bool> danhdaudaQuetMap = {};

  @override
  void initState() {
    super.initState();
    _initializeEventList();
    // _loadDaQuetMap();
  }

  Future<List<TagEpcLDB>> loadData(String key) async {
    String? dataString = await _storage.read(key: key);
    if (dataString != null) {
      return TagEpcLDB.parseTags(dataString);
    }
    return [];
  }

  Future<void> _initializeEventList() async {
    var events = await CalendarDistributionInfDatabaseHelper().getHistoryEvents(widget.taiKhoan!);
    for (var event in events) {
      var tags = await loadData(event.idLDB); // Sử dụng phương thức loadData
      event.soLuongQuet = tags.length;  // Cập nhật số lượng quét
    }
    for (var event in events) {
      // Lấy các giá trị từ bộ nhớ an toàn cho event cụ thể
      var counts = await loadCountsPackageInfFromStorage(event.idLDB);

      // Gán các giá trị từ 'counts' cho các thuộc tính của 'event'
      event.dongBaoThatbai = counts['failCount'] ?? 0;
      event.dongBaoThanhCong = counts['successCount'] ?? 0;
      event.maDaDongBao = counts['alreadyDistributed'] ?? 0;
      event.maKhongTonTai = counts['notAlreadyDistribution'] ?? 0;
      event.maChuaKichHoat = counts['notActivated'] ?? 0;
      event.saiSanPham = counts['wrongDistribution'] ?? 0;
      event.dadongbo = counts['SyncCode'] ?? 0;
      event.completSchedule = counts['completSchedule'] ?? 0;
      event.otherCase = counts['otherCase'] ?? 0;
      event.dathuhoi = counts['codeRecalled'] ?? 0;
      event.syncDate = counts['syncDateFormat'] ?? '';
    }


    setState(() {
      currentEvents = events;  // Cập nhật danh sách sự kiện hiện tại
      _eventListFuture = Future.value(currentEvents);
    });
  }

  String getKey( String eventId, String id) {
    return '$eventId-$id';
  }

  Future<Map<String, dynamic>> loadCountsPackageInfFromStorage(
      String eventId) async {
    final storage = const FlutterSecureStorage();

    // Tạo một map để lưu các giá trị
    final Map<String, dynamic> data = {};

    // Lấy các giá trị từ bộ nhớ an toàn
    final successCount = await storage.read(key: getKey("successCountPackageInf", eventId));
    final failCount = await storage.read(key: getKey("failCountPackageInf", eventId));
    final notActivated = await storage.read(key: getKey("notActivated", eventId));
    final wrongDistribution = await storage.read(key: getKey("wrongDistribution", eventId));
    final alreadyDistributed = await storage.read(key: getKey("alreadyDistributed", eventId));
    final notAlreadyDistribution = await storage.read(key: getKey("notalreadyDistribution", eventId));
    final SyncCode = await storage.read(key: getKey("SyncCode", eventId));
    final completSchedule = await storage.read(key: getKey("completSchedule", eventId));
    final otherCase = await storage.read(key: getKey("otherCase", eventId));
    final codeRecalled = await storage.read(key: getKey("codeRecalled", eventId));
    final syncDateFormat = await storage.read(key: getKey("syncDateFormat", eventId));


    // Chuyển đổi giá trị thành số nguyên và lưu vào map
    data['successCount'] = int.tryParse(successCount ?? '0') ?? 0;
    data['failCount'] = int.tryParse(failCount ?? '0') ?? 0;
    data['notActivated'] = int.tryParse(notActivated ?? '0') ?? 0;
    data['wrongDistribution'] = int.tryParse(wrongDistribution ?? '0') ?? 0;
    data['alreadyDistributed'] = int.tryParse(alreadyDistributed ?? '0') ?? 0;
    data['notAlreadyDistribution'] = int.tryParse(notAlreadyDistribution ?? '0') ?? 0;
    data['SyncCode'] = int.tryParse(SyncCode ?? '0') ?? 0;
    data['completSchedule'] = int.tryParse(completSchedule ?? '0') ?? 0;
    data['otherCase'] = int.tryParse(otherCase ?? '0') ?? 0;
    data['codeRecalled'] = int.tryParse(codeRecalled ?? '0') ?? 0;
    data['syncDateFormat'] = syncDateFormat;

    return data;
  }

  void updateEventList(CalendarDistributionInf deletedEvent) {
    if (_eventListFuture != null) {
      setState(() {
        _eventListFuture = _eventListFuture!.then((eventList) {
          eventList.removeWhere((event) => event.idLDB == deletedEvent.idLDB);
          return eventList;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateEvent(CalendarDistributionInf updatedEvent) {
    if (_eventListFuture != null && mounted) {
      setState(() {
        _eventListFuture = _eventListFuture!.then((eventList) {
          for (int i = 0; i < eventList.length; i++) {
            if (eventList[i].idLDB == updatedEvent.idLDB) {
              eventList[i] = updatedEvent;
              break;
            }
          }
          return eventList;
        });
      });
    }
  }

  List<CalendarDistributionInf> filterEvents(String keyword) {
    keyword = keyword.toLowerCase();
    return currentEvents.where((event) =>
    event.maLDB.toLowerCase().contains(keyword) ||
        event.sanPhamLDB.toLowerCase().contains(keyword)).toList();
  }

  void onSearchTextChanged(String text) {
    var filteredEvents = filterEvents(text);
    setState(() {
      _eventListFuture = Future.value(filteredEvents);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWith = MediaQuery.of(context).size.width;
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
              onTap: () {},
              child: Image.asset(
                'assets/image/logoJVF_RFID.png',
                width: screenWith * 0.15,
                height: screenHeight * 0.15,
              ),
            ),
          ),
        ),
        title: Text(
          'Lịch sử đóng bao',
          style: TextStyle(
            fontSize: screenWith * 0.07,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF097746),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
            child: Container(
              color: const Color(0xFFFAFAFA),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
                  filled: true,
                  fillColor: const Color(0xFFEBEDEC),
                  border: OutlineInputBorder(
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
                      onSearchTextChanged(_searchController.text);
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
          ),
          Expanded(
            child: _eventListFuture == null
                ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097746)),
                  ),
                ),
              ),
            )
                : FutureBuilder<List<CalendarDistributionInf>>(
                  future: _eventListFuture!,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097746)),
                              ),
                            ),
                          )
                      );
                    } else if (snapshot.hasError && snapshot.error != null) {
                      return Center(
                        child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                      );
                    } else {
                      final eventList = snapshot.data!;
                      if (eventList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(30, 220, 30, 0),
                          constraints: const BoxConstraints.expand(),
                          color: const Color(0xFFFAFAFA),
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                  'assets/image/canhbao1.png',
                                  width: 50,
                                  height: 50,
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  'Chưa có lịch sử đóng bao',
                                  style: TextStyle(fontSize: 22, color: Color(0xFF097746)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Không tìm thấy kết quả',
                            style: TextStyle(fontSize: 16, color: Color(0xFF097746)),
                          ),
                        );
                      } else {
                        eventList.sort((a, b) => DateTime.parse(b.ngayTaoLDB).compareTo(DateTime.parse(a.ngayTaoLDB)));
                        return ListView.builder(
                          itemCount: eventList.length,
                          itemBuilder: (context, index) {
                            final event = eventList[index];
                            final color = index % 2 == 0 ? const Color(0xFFFAFAFA) : const Color(0xFFFAFAFA);
                            return GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 1.0),
                                child: ListTile(
                                  title: Text(
                                    event.maLDB,
                                    style: TextStyle(
                                      color: const Color(0xFF097746),
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWith * 0.05,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sản phẩm: ${event.sanPhamLDB}',
                                        style: TextStyle(
                                          color: const Color(0xFF097746),
                                          fontSize: screenWith * 0.05,
                                        ),
                                      ),
                                      Text(
                                        'Số lượng quét: ${event.soLuongQuet}',
                                        style: TextStyle(
                                          color: const Color(0xFF097746),
                                          fontSize: screenWith * 0.05,
                                        ),
                                      ),
                                      Text(
                                        'Ngày tạo lịch: ${event.ngayTaoLDB}',
                                        style: TextStyle(
                                          color: const Color(0xFF097746),
                                          fontSize: screenWith * 0.05,
                                        ),
                                      ),
                                      Text(
                                        'Ngày đồng bộ : ${event.syncDate}',
                                        style: TextStyle(
                                          color: const Color(0xFF097746),
                                          fontSize: screenWith * 0.05,
                                        ),
                                      ),
                                      Text(
                                        'Đóng bao thành công: ${event.dongBaoThanhCong}',
                                        style: TextStyle(
                                          color: const Color(0xFF097746),
                                          fontSize: screenWith * 0.05,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ExpansionTile(
                                            title: Text(
                                              'Đóng bao thất bại: ${event.dongBaoThatbai}',
                                              style: TextStyle(
                                                color: const Color(0xFF097746),
                                                fontSize: screenWith * 0.05,
                                              ),
                                            ),
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 16.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    event.maDaDongBao > 0
                                                    ?
                                                    Text(
                                                      '- Mã đã đóng bao: ${event.maDaDongBao}',
                                                      style: TextStyle(
                                                        color: const Color(0xFF097746),
                                                        fontSize: screenWith * 0.045,
                                                      ),
                                                    ): const SizedBox.shrink(),
                                                    event.maChuaKichHoat > 0
                                                    ?
                                                    Text(
                                                      '- Mã chưa kích hoạt: ${event.maChuaKichHoat}',
                                                      style: TextStyle(
                                                        color: const Color(0xFF097746),
                                                        fontSize: screenWith * 0.045,
                                                      ),
                                                    ) : const SizedBox.shrink(),
                                                    event.saiSanPham > 0
                                                    ?
                                                    Text(
                                                      '- Sai sản phẩm: ${event.saiSanPham}',
                                                      style: TextStyle(
                                                        color: const Color(0xFF097746),
                                                        fontSize: screenWith * 0.045,
                                                      ),
                                                    )  : const SizedBox.shrink(),
                                                    event.maKhongTonTai > 0
                                                    ?
                                                    Text(
                                                      '- Mã không tồn tại:${event.maKhongTonTai} ',
                                                      style: TextStyle(
                                                        color: const Color(0xFF097746),
                                                        fontSize: screenWith * 0.045,
                                                      ),
                                                    ): const SizedBox.shrink(),
                                                    event.dadongbo > 0
                                                    ?
                                                    Text(
                                                      '- Mã đã đồng bộ:${event.dadongbo} ',
                                                      style: TextStyle(
                                                        color: const Color(0xFF097746),
                                                        fontSize: screenWith * 0.045,
                                                      ),
                                                    )
                                                        : const SizedBox.shrink(),
                                                    event.dathuhoi > 0 ?
                                                    Text(
                                                      '- Mã đã được thu hồi:${event.dathuhoi} ',
                                                      style: TextStyle(
                                                        color: const Color(0xFF097746),
                                                        fontSize: screenWith * 0.045,
                                                      ),
                                                    ) : const SizedBox.shrink(),
                                                    event.completSchedule > 0 ?
                                                    Text(
                                                      '- Lịch đã hoàn thành đóng bao:${event.completSchedule} ',
                                                      style: TextStyle(
                                                        color: const Color(0xFF097746),
                                                        fontSize: screenWith * 0.045,
                                                      ),
                                                    ) : const SizedBox.shrink(),
                                                    event.otherCase > 0 ?
                                                    Text(
                                                      '- Mã lỗi khác:${event.otherCase} ',
                                                      style: TextStyle(
                                                        color: const Color(0xFF097746),
                                                        fontSize: screenWith * 0.045,
                                                      ),
                                                    ) : const SizedBox.shrink(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Container(
                                        child: GestureDetector(
                                          onTap: () {
                                            // Điều hướng đến trang EPCSyncList khi bấm vào
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EPCPackgaeList(eventId: event.idLDB), // Truyền eventId sang trang mới
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Mã đã đồng bộ: ',
                                                  style: TextStyle(
                                                    color: const Color(0xFF097746),
                                                    fontSize: screenWith * 0.05,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.navigate_next, // Biểu tượng mũi tên
                                                  color: const Color(0xFF097746),
                                                  size: screenWith * 0.06, // Kích thước của biểu tượng
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
              ),
            )
          ],
        ),
    );
  }
}
