import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'model.dart';
import 'database.dart';
import 'edit_celendar.dart';
import 'EPC_sync_list.dart';

class HistoryDistribution extends StatefulWidget {
  final String taiKhoan;
  const HistoryDistribution({Key? key, required this.taiKhoan}) : super(key: key);

  @override
  State<HistoryDistribution> createState() => _HistoryDistributionState();
}

class _HistoryDistributionState extends State<HistoryDistribution> {
  late Calendar event;
  final TextEditingController _searchController = TextEditingController();
  final _storage = FlutterSecureStorage();
  List<Calendar> currentEvents = [];
  Future<List<Calendar>>? _eventListFuture;
  Map<String, bool> daQuetMap = {};

  @override
  void initState() {
    super.initState();
    _initializeEventList();
    // _loadDaQuetMap();
  }

  Future<List<TagEpc>> loadData(String key) async {
    String? dataString = await _storage.read(key: key);
    if (dataString != null) {
      // Sử dụng parseTags để chuyển đổi chuỗi JSON thành danh sách TagEpcLBD
      return TagEpc.parseTags(dataString);
    }
    return [];
  }

  Future<void> _initializeEventList() async {
    var events = await CalendarDatabaseHelper().getHistoryEvents(widget.taiKhoan!);
    for (var event in events) {
      var tags = await loadData(event.id); // Sử dụng phương thức loadData
      event.soLuongQuett = tags.length;  // Cập nhật số lượng quét
    }

    for (var event in events) {
      // Lấy các giá trị từ bộ nhớ an toàn cho event cụ thể
      var counts = await loadCountsDistributionStorage(event.id);
      // Gán các giá trị từ 'counts' cho các thuộc tính của 'event'
      event.phanPhoiThatBai = counts['failSend'] ?? 0;
      event.phanPhoiThanhCong = counts['successfulSends'] ?? 0;
      event.saiSPPhanPhoi = counts['wrongDistribution'] ?? 0;
      event.maKhongTonTai = counts['makhongtontai'] ?? 0;
      event.spDaPhanPhoi = counts['alreadyDistributed'] ?? 0;
      event.maChuaDongBao = counts['notPackage'] ?? 0;
      event.dadongbo = counts['SyncCode'] ?? 0;
      event.maChuaKichHoat = counts['notActivated'] ?? 0;
      event.orthercase = counts['orthercase'] ?? 0;
      event.lichDaHoanThanh = counts['completSchedule'] ?? 0;
      event.machuappkt = counts['notwarehouseDistributionYet'] ?? 0;
      event.madathuhoi= counts['recallCode'] ?? 0;
      event.syncDate = counts['syncDateFormat'] ?? '';
    }
    setState(() {
      currentEvents = events;
      _eventListFuture = Future.value(currentEvents);
    });
  }


  final distributionStorage = FlutterSecureStorage();
  String getKey( String eventId, String id) {
    return '$eventId-$id';
  }

  Future<Map<String, dynamic>> loadCountsDistributionStorage(
      String eventId) async {
    final distributionStorage = FlutterSecureStorage();
    // Tạo một map để lưu các giá trị
    final Map<String, dynamic> data = {};
    // Lấy các giá trị từ bộ nhớ an toàn
    final successfulSends = await distributionStorage.read(key: getKey("successfulSends", eventId));
    final failSend = await distributionStorage.read(key: getKey("failSend", eventId));
    final alreadyDistributed = await distributionStorage.read(key: getKey("alreadyDistributed", eventId));
    final notActivated = await distributionStorage.read(key: getKey("notActivated", eventId));
    final wrongDistribution = await distributionStorage.read(key: getKey("wrongDistribution", eventId));
    final makhongtontai = await distributionStorage.read(key: getKey("makhongtontai", eventId));
    final notPackage = await distributionStorage.read(key: getKey("notPackage", eventId));
    final SyncCode = await distributionStorage.read(key: getKey("SyncCode", eventId));
    final recallCode = await distributionStorage.read(key: getKey("recallCode", eventId));
    final completSchedule = await distributionStorage.read(key: getKey("completSchedule", eventId));
    final orthercase = await distributionStorage.read(key: getKey("orthercase", eventId));
    final notwarehouseDistributionYet = await distributionStorage.read(key: getKey("notwarehouseDistributionYet", eventId));
    final syncDateFormat = await distributionStorage.read(key: getKey("syncDateFormat", eventId));


    // Chuyển đổi giá trị thành số nguyên và lưu vào map
    data['successfulSends'] = int.tryParse(successfulSends ?? '0') ?? 0;
    data['failSend'] = int.tryParse(failSend ?? '0') ?? 0;
    data['alreadyDistributed'] = int.tryParse(alreadyDistributed ?? '0') ?? 0;
    data['notActivated'] = int.tryParse(notActivated ?? '0') ?? 0;
    data['wrongDistribution'] = int.tryParse(wrongDistribution ?? '0') ?? 0;
    data['makhongtontai'] = int.tryParse(makhongtontai ?? '0') ?? 0;
    data['notPackage'] = int.tryParse(notPackage ?? '0') ?? 0;
    data['SyncCode'] = int.tryParse(SyncCode ?? '0') ?? 0;
    data['recallCode'] = int.tryParse(recallCode ?? '0') ?? 0;
    data['completSchedule'] = int.tryParse(completSchedule ?? '0') ?? 0;
    data['orthercase'] = int.tryParse(orthercase ?? '0') ?? 0;
    data['notwarehouseDistributionYet'] = int.tryParse(notwarehouseDistributionYet ?? '0') ?? 0;
    data['syncDateFormat'] = syncDateFormat;

    return data;
  }

  void navigateToUpdate(BuildContext context) async {
    final isCalendarUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCalendarPage(event: event),
      ),
    );
    // Kiểm tra xem liệu dữ liệu lịch đã được cập nhật từ trang EditCalendarPage hay không
    if (isCalendarUpdated == true) {
      setState(() {
        // Cập nhật lại danh sách sự kiện với dữ liệu mới
        _eventListFuture = CalendarDatabaseHelper().getEvents(widget.taiKhoan!);
      });
    }
  }

  void updateEventList(Calendar deletedEvent) {
    if (_eventListFuture != null) {
      setState(() {
        _eventListFuture = _eventListFuture!.then((eventList) {
          eventList.removeWhere((event) => event.id == deletedEvent.id);
          return eventList;
        });
      });
    }
  }

  void updateEvent(Calendar updatedEvent) {
    if (_eventListFuture != null && mounted) {
      setState(() {
        _eventListFuture = _eventListFuture!.then((eventList) {
          // Tìm và cập nhật sự kiện trong danh sách bằng cách so sánh id của các sự kiện
          for (int i = 0; i < eventList.length; i++) {
            if (eventList[i].id == updatedEvent.id) {
              eventList[i] = updatedEvent;
              break;
            }
          }
          return eventList;
        });
      });
    }
  }

  List<Calendar> filterEvents(String keyword) {
    keyword = keyword.toLowerCase();
    return currentEvents.where((event) =>
    event.tenDaiLy.toLowerCase().contains(keyword) ||
        event.tenSanPham.toLowerCase().contains(keyword)).toList();
  }

  void onSearchTextChanged(String text) {
    var filteredEvents = filterEvents(text);
    setState(() {
      _eventListFuture = Future.value(filteredEvents);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWith = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return
      Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFE9EBF1),
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
              'Lịch sử phân phối',
              style: TextStyle(
                fontSize: screenWith * 0.07,
                fontWeight: FontWeight.bold,
                color: Color(0xFF097746),
              ),
            ),
          ),
          body: Column(
              children: [
            Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
              child: Container(
                color: Color(0xFFFAFAFA),
                child: TextField(
                  controller: _searchController,
                  onChanged: onSearchTextChanged,
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
              child: _eventListFuture == null ?  Padding(
              padding: EdgeInsets.all(20.0), // Thêm padding xung quanh CircularProgressIndicator
                child: Center(
                  child: SizedBox(
                  width: 30, // Giới hạn kích thước của CircularProgressIndicator
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097746)),
                  ),
                ),
              ),
            ) : FutureBuilder<List<Calendar>>(
              future: _eventListFuture!,
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
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
                } else if (snapshot.hasError && snapshot.error != null) {
                  return Center(
                    child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                  );
                } else {
                  final eventList = snapshot.data!;
                  if (eventList.isEmpty) {
                    return Container(
                      padding: EdgeInsets.fromLTRB(30, 200, 30, 0),
                      constraints: BoxConstraints.expand(),
                      color: Color(0xFFFAFAFA),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/image/canhbao1.png',
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Chưa có lịch sử phân phối',
                              style: TextStyle(fontSize: 22, color: Color(0xFF097746)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    eventList.sort((a, b) => DateTime.parse(b.time).compareTo(DateTime.parse(a.time)));
                    return ListView.builder(
                      itemCount: eventList.length,
                      itemBuilder: (context, index) {
                        final event = eventList[index];
                        final color = index % 2 == 0 ? Color(0xFFFAFAFA) : Color(0xFFFAFAFA);
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
                                  padding: EdgeInsets.fromLTRB(8.0, 1.0, 1.0, 1.0),
                                  child: ListTile(
                                    title: Text(
                                      event.tenDaiLy,
                                      style: TextStyle(
                                          color: Color(0xFF097746),
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWith*0.05
                                      ),
                                    ),
                                    subtitle: Column(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Thông tin sản phẩm: ${event.tenSanPham}',
                                          style: TextStyle(
                                              color: Color(0xFF097746),
                                              fontSize: screenWith*0.05
                                          ),
                                        ),
                                        Text(
                                          'Số lượng: ${event.soLuong}',
                                          style: TextStyle(
                                              color: Color(0xFF097746),
                                              fontSize: screenWith*0.05
                                          ),
                                        ),
                                        Text(
                                          "Số lượng quét: ${event.soLuongQuett}",
                                          style: TextStyle(
                                              color: Color(0xFF097746),
                                              fontSize: screenWith*0.05
                                          ),
                                        ),
                                        Text(
                                          'Phiếu xuất kho: ${event.phieuXuatKho}',
                                          style: TextStyle(
                                              color: Color(0xFF097746),
                                              fontSize: screenWith*0.05
                                          ),
                                        ),
                                        Text(
                                          'Lệnh giao hàng: ${event.lenhPhanPhoi}',
                                          style: TextStyle(
                                              color: Color(0xFF097746),
                                              fontSize: screenWith*0.05
                                          ),
                                        ),
                                        Text(
                                          'Ngày tạo lịch: ${event.time}',
                                          style: TextStyle(
                                              color: Color(0xFF097746),
                                              fontSize: screenWith*0.05
                                          ),
                                        ),
                                        Text(
                                          'Ngày đồng bộ: ${event.syncDate}',
                                          style: TextStyle(
                                              color: Color(0xFF097746),
                                              fontSize: screenWith*0.05
                                          ),
                                        ),
                                        Text(
                                          'Phân phối thành công: ${event.phanPhoiThanhCong}',
                                          style: TextStyle(
                                              color: Color(0xFF097746),
                                              fontSize: screenWith*0.05
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ExpansionTile(
                                              title: Text(
                                                'Phân phối lỗi:  ${event.phanPhoiThatBai}',
                                                style: TextStyle(
                                                  color: Color(0xFF097746),
                                                  fontSize: screenWith * 0.05,
                                                ),
                                              ),
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      event.spDaPhanPhoi > 0
                                                          ? Text(
                                                        '- Sản phẩm đã phân phối:  ${event.spDaPhanPhoi}',
                                                        style: TextStyle(
                                                          color: Color(0xFF097746),
                                                          fontSize: screenWith * 0.045,
                                                        ),
                                                      )
                                                          : SizedBox.shrink(),
                                                      event.saiSPPhanPhoi > 0
                                                      ? Text(
                                                        '- Sai sản phẩm:  ${event.saiSPPhanPhoi}',
                                                        style: TextStyle(
                                                          color: Color(0xFF097746),
                                                          fontSize: screenWith * 0.045,
                                                        ),
                                                      ) : SizedBox.shrink(),
                                                      event.maChuaDongBao > 0
                                                      ? Text(
                                                        '- Mã chưa được đóng bao:  ${event.maChuaDongBao}',
                                                        style: TextStyle(
                                                          color: Color(0xFF097746),
                                                          fontSize: screenWith * 0.045,
                                                        ),
                                                      ) : SizedBox.shrink(),
                                                      event.maKhongTonTai > 0
                                                      ? Text(
                                                        '- Mã không tồn tại:  ${event.maKhongTonTai}',
                                                        style: TextStyle(
                                                          color: Color(0xFF097746),
                                                          fontSize: screenWith * 0.045,
                                                        ),
                                                      ) : SizedBox.shrink(),
                                                      event.maChuaKichHoat > 0
                                                      ? Text(
                                                        '- Mã chưa được kích hoạt:  ${event.maChuaKichHoat}',
                                                        style: TextStyle(
                                                          color: Color(0xFF097746),
                                                          fontSize: screenWith * 0.045,
                                                        ),
                                                      ) : SizedBox.shrink(),
                                                      event.dadongbo > 0
                                                      ? Text(
                                                        '- Mã đã đồng bộ:  ${event.dadongbo}',
                                                        style: TextStyle(
                                                          color: Color(0xFF097746),
                                                          fontSize: screenWith * 0.045,
                                                        ),
                                                      ) : SizedBox.shrink(),
                                                      event.madathuhoi > 0
                                                      ? Text(
                                                        '- Mã đã được thu hồi:  ${event.madathuhoi}',
                                                        style: TextStyle(
                                                          color: Color(0xFF097746),
                                                          fontSize: screenWith * 0.045,
                                                        ),
                                                      ) : SizedBox.shrink(),
                                                      event.machuappkt > 0
                                                      ? Text(
                                                        '- Mã chưa được phân phối kho thuê:  ${event.machuappkt}',
                                                        style: TextStyle(
                                                          color: Color(0xFF097746),
                                                          fontSize: screenWith * 0.045,
                                                        ),
                                                      ) : SizedBox.shrink(),
                                                      event.lichDaHoanThanh > 0
                                                      ? Text(
                                                        '- Lich phân phối đã hoàn thành:  ${event.lichDaHoanThanh}',
                                                        style: TextStyle(
                                                          color: Color(0xFF097746),
                                                          fontSize: screenWith * 0.045,
                                                        ),
                                                      ) : SizedBox.shrink(),
                                                      event.orthercase > 0
                                                          ? Text(
                                                        '- Mã lỗi khác:  ${event.orthercase}',
                                                        style: TextStyle(
                                                          color: Color(0xFF097746),
                                                          fontSize: screenWith * 0.045,
                                                        ),
                                                      ) : SizedBox.shrink(),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          child: GestureDetector(
                                            onTap: () {
                                              // Điều hướng đến trang EPCSyncList khi bấm vào
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EPCSyncList(eventId: event.id), // Truyền eventId sang trang mới
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Mã đã đồng bộ: ',
                                                    style: TextStyle(
                                                      color: Color(0xFF097746),
                                                      fontSize: screenWith * 0.05,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.navigate_next, // Biểu tượng mũi tên
                                                    color: Color(0xFF097746),
                                                    size: screenWith * 0.06, // Kích thước của biểu tượng
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ]),
                                  ),
                                )
                              );
                            },
                        );
                      }
                   }
                 },
                ),
              )
            ]
          )
      );
  }
}