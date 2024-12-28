import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rfid_c72_plugin/rfid_c72_plugin.dart';
import '../utils/common_functions.dart';
import '../Distribution_Module/model.dart';
import '../Utils/DeviceActivities/DataProcessing.dart';
import '../utils/app_config.dart';
import 'goods_Information_model.dart';
import '../utils/key_event_channel.dart';

class GoodsInformation extends StatefulWidget {
  @override
  _GoodsInformationState createState() => new _GoodsInformationState();
}

class _GoodsInformationState extends State<GoodsInformation> {
  String _platformVersion = 'Unknown';
  final bool _isHaveSavedData = false;
  final bool _isStarted = false;
  final bool _isEmptyTags = false;
  bool _isConnected = false;
  bool _isLoading = true;
  int _totalEPC = 0, _invalidEPC = 0, _scannedEPC = 0;
  final GlobalKey webViewKey = GlobalKey();
  bool isLoadingAboutBlank = false;
  bool _showHeader = false;
  String scannedCode = '';
  String globalScannedCode = '';
  bool isScan = false;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  String defaultUrl = "about:blank";
  String? _lastScannedCode;
  bool _hasData = false;
  bool _scanAttempted = false;
  // String IP = 'http://192.168.19.69:5088';
  // String IP = 'http://192.168.19.180:5088';
  // String IP = 'http://192.168.19.180:5057';
  // String IP = 'https://jvf-admin.rynansaas.com';


  @override
  void initState() {
    super.initState();
    initPlatformState();
    KeyEventChannel(
      onKeyReceived: scanSingleTagAndUpdateWebView,
    ).initialize();
  }


  Future<void> initPlatformState() async {
    String platformVersion;
    print('StrDebug: initPlatformState');
    try {
      platformVersion = (await RfidC72Plugin.platformVersion)!;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    RfidC72Plugin.connectedStatusStream
        .receiveBroadcastStream()
        .listen(updateIsConnected);
    RfidC72Plugin.tagsStatusStream.receiveBroadcastStream().listen(updateTags);
    await RfidC72Plugin.connect;
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
      print('Connection successful');
      _isLoading = false;
    });
  }

  void updateIsConnected(dynamic isConnected) {
    _isConnected = isConnected;
  }

  List<TagEpc> _data = [];
  final List<String> _EPC = [];
  bool _is2dscanCall = false;

  @override
  void dispose() {
    super.dispose();
    scanSingleTagAndUpdateWebView();
  }

  // void updateTags(dynamic result) {
  //   setState(() {
  //     _data = TagEpc.parseTags(result);
  //     _totalEPC = _data.toSet().toList().length;
  //     if (_data.isNotEmpty) {
  //
  //     }
  //   });
  // }
  void updateTags(dynamic result) {
    setState(() {
      List<TagEpc> newData = TagEpc.parseTags(result); //Convert to TagEpc list
      DataProcessing.ProcessData(newData, _data); // Filter
      _totalEPC = _data.toSet().toList().length;
    });
  }

  void scanSingleTagAndUpdateWebView() async {
    StreamSubscription<dynamic>? subscription;
    try {
      // Tạo một biến để lắng nghe kết quả quét
      StreamSubscription<dynamic>? subscription = RfidC72Plugin.tagsStatusStream.receiveBroadcastStream().listen(null);

      // Đăng ký nghe kết quả từ luồng
      subscription.onData((result) async {
        if (result.isNotEmpty) {
          // Lấy dữ liệu từ thẻ đầu tiên được quét
          String rawScannedCode = TagEpc.parseTags(result).first.epc;
          scannedCode = CommonFunction().hexToString(rawScannedCode);

          setState(() {
            //globalScannedCode = scannedCode;
             globalScannedCode = 'RJVD24000047GQML';
          });
          print('mã được quét: $globalScannedCode');
          // Hủy đăng ký sau khi xử lý kết quả đầu tiên
          subscription.cancel();
        }
      });
      setState(() {
        isScan = true;
        _scanAttempted = true; // Mark that a scan has been attempted

      });
      // Bắt đầu quét một thẻ RFID
      await RfidC72Plugin.startSingle;

    } catch (e) {
      print("Error when scanning RFID: $e");
    }
  }

  Future<void> loadInformationFromScannedCode(String scannedCode) async {
    try {
      // Giả sử đây là hàm gọi API để lấy thông tin sản phẩm dựa trên mã quét
      await getGoodsInformationAccordingToPackageScheduleDetail(scannedCode);
    } catch (e) {
      print("Error loading data for scanned code: $e");
    }
  }

  Future<List<PackageScheduleDetail>> getGoodsInformationAccordingToPackageScheduleDetail(String scannedCode) async {
    print('Fetching package schedule details');
    List<PackageScheduleDetail> dealers = [];
    final response = await http.get(
      Uri.parse('${AppConfig.IP}/api/7C96C8E10A004D53AF6727D03DD17004/$scannedCode'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];
      for (var item in data) {
        if ( item["16MT"] == "ERROR_0000") {
          dealers.add(PackageScheduleDetail(ngaySX: item["11NSX"], ngayHeHan: item["3HSD"], soLOT: item["7SL"], moTa: item["16MT"]));
        }
      }
    } else {
      throw Exception('Failed to load data: HTTP status ${response.statusCode}');
    }
    return dealers;
  }

  Future<List<DistributionScheduleDetail>> getGoodsInformationAccordingToDistributionDetail(String scannedCode) async {
    // print('Fetching distribution details');
    List<DistributionScheduleDetail> dealers = [];

    final response = await http.get(
      Uri.parse('${AppConfig.IP}/api/BBC047CCA9AB4CA888817F7E5EF51385/$scannedCode'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];
      for (var item in data) {
        if (item["15MT"] == "ERROR_0000") {
          dealers.add(DistributionScheduleDetail(khuVuc: item["2TKV"], lenhXH: item["4LXH"], ngayPP: item["7NPP"], phanPhoiDen: item["2TNPP"], phanPhoiBoi: item["2TNPPB"]));
        }
      }
    } else {
      throw Exception('Failed to load data: HTTP status ${response.statusCode}');
    }
    return dealers;
  }


  Future<List<WareHouseDistributionScheduleDetail>> getGoodsInformationAccordingToWareHouseDistributionCode(String scannedCode) async {
    print('Fetching distribution details');
    List<WareHouseDistributionScheduleDetail> dealers = [];

    final response = await http.get(
      Uri.parse('${AppConfig.IP}/api/87670F9F2DCB4844A657DBA72AFA2782/$scannedCode'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];
      for (var item in data) {
        if (item["18MT"] == "ERROR_0000") {
          dealers.add(WareHouseDistributionScheduleDetail(KTkhuVuc: item["2TKV"], KTlenhXH: item["4LXH"], KTngayPP: item["7NPP"], KTphanPhoiDen: item["2TNPP"], KTphanPhoiBoi: item["2TNPPB"]));
        }
      }
    } else {
      throw Exception('Failed to load data: HTTP status ${response.statusCode}');
    }
    return dealers;
  }


  Future<List<RFIDCodeManagement>> getGoodsInformationAccordingToRFIDCodeManagement(String scannedCode) async {
    print('Starting data fetch');
    List<RFIDCodeManagement> dealers = [];

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.IP}/api/6480825C17ED4B7C9CC69D4A2DC462A7/$scannedCode'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];
        for (var item in data) {
          dealers.add(RFIDCodeManagement(
              diaChi: item["10ĐC"],
              email: item["11E"],
              SDT: item["3ĐT"],
              nhaSanXuat: item["3TNSX"],
              website: item["2W"],
              gioiThieu: item["5GT"],
              thongTinSP: item["1TTSP"],
              xuatXu: item["2XX"],
              tenSP: item["10TSP"],
              maSP: item["29MSP"],
              hinhAnhSP: item["2HẢ"],
              trangThai: item["30TT"],
          ));
        }
        print(data);
      } else {
        print('Failed to load data: HTTP status ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error fetching data: $e');
    }

    return dealers;
  }

  Future<CombinedProductDetails> fetchAllProductDetails(String scannedCode) async {
    try {
      // Execute all fetch operations concurrently
      var packageFuture = getGoodsInformationAccordingToPackageScheduleDetail(scannedCode);
      var distributionFuture = getGoodsInformationAccordingToDistributionDetail(scannedCode);
      var warehouseFuture = getGoodsInformationAccordingToWareHouseDistributionCode(scannedCode);
      var rfidFuture = getGoodsInformationAccordingToRFIDCodeManagement(scannedCode);

      // Wait for all futures to complete
      await Future.wait([
        packageFuture,
        distributionFuture,
        warehouseFuture,
        rfidFuture,
      ]);

      // Collect results
      var packageDetails = await packageFuture;
      var distributionDetails = await distributionFuture;
      var warehouseDetails = await warehouseFuture;
      var rfidDetails = await rfidFuture;

      return CombinedProductDetails(
        packageDetails: packageDetails,
        distributionDetails: distributionDetails,
        warehouseDetails: warehouseDetails,
        rfidDetails: rfidDetails,
      );
    } catch (e) {
      throw Exception('Failed to fetch all data: $e');
    }
  }


  Widget buildDetailSections(CombinedProductDetails data) {
    List<Widget> widgets = [];
    widgets.addAll(data.rfidDetails.map((item) {
      List<String> imageUrls = item.hinhAnhSP != null && item.hinhAnhSP!.isNotEmpty
          ? item.hinhAnhSP!.map((img) => '${AppConfig.IP}' + img).toList()
          : [];

      PageController _pageController = PageController(initialPage: 0);
      Timer? _timer;

      // Khởi tạo timer để tự động chuyển trang
      void _startAutoSlide() {
        if (imageUrls.length > 1) {
          _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
            if (_pageController.hasClients) {
              int nextPage = _pageController.page!.toInt() + 1;
              if (nextPage >= imageUrls.length) {
                nextPage = 0;
              }
              _pageController.animateToPage(
                nextPage,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      }

      // Hủy timer khi không cần thiết để tránh rò rỉ bộ nhớ
      void _stopAutoSlide() {
        _timer?.cancel();
      }

      // Bắt đầu tự động trượt khi widget được khởi tạo
      if (imageUrls.length > 1) {
        _startAutoSlide();
      }

      return Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Color(0xFFEEEEEE),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrls.isEmpty
                    ? Center(
                  heightFactor: 10,
                  child: Text(
                    'Không có hình ảnh',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : Stack(
                  children: [
                    Container(
                      height: 300, // Adjust height as needed
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          String imageUrl = imageUrls[index];
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097746)),
                                ),
                              );
                            },
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Center(
                                child: Text(
                                  'Hình ảnh xảy ra lỗi',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (imageUrls.length > 1) ...[
                      Positioned(
                        left: 0,
                        top: 130,
                        bottom: 130,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
                          onPressed: () {
                            _stopAutoSlide();
                            if (_pageController.hasClients) {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                            _startAutoSlide();
                          },
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 130,
                        bottom: 130,
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          onPressed: () {
                            _stopAutoSlide();
                            if (_pageController.hasClients) {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                            _startAutoSlide();
                          },
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }));

      widgets.add(Container(
      padding: EdgeInsets.all(10), // Khoảng cách bên trong giữa viền và hình ảnh
      margin: EdgeInsets.fromLTRB(15, 0, 15,0), // Khoảng cách bên ngoài giữa container và các widget xung quanh
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền của container, nên thiết lập để đổ bóng hiển thị rõ ràng
        border: Border.all(
          color: Color(0xFFEEEEEE), // Màu viền
          width: 1.0, // Độ dày của viền
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Màu đổ bóng
            spreadRadius: 1, // Phạm vi mà đổ bóng sẽ lan rộng
            blurRadius: 10, // Độ mờ của đổ bóng
            offset: Offset(0, 5), // Vị trí đổ bóng, x và y
          ),
        ],
        borderRadius: BorderRadius.circular(5), // Bo góc của container
      ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...data.rfidDetails.map((item) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${item.tenSP ?? ' ' } (${item.maSP ?? ' '})",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF379BD1)
                    )
                ),
                Text(
                    "(Mã EPC: $globalScannedCode)",
                    style: TextStyle(
                        fontSize: 18,
                        // fontWeight: FontWeight.bold,
                        color: Colors.grey
                    )
                ),
              ],
            )),
            if (data.packageDetails.isNotEmpty)
              ...data.packageDetails.map((item) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  // Giả sử ngaySX là chuỗi đúng định dạng
                children: [

                  Row(
                    children: [
                      Text("Ngày sản xuất: ", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            item.ngaySX != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(item.ngaySX!)) : '',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text("Ngày hết hạn:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
                      SizedBox(width: 10),
                      Expanded(child: Text("Xem trên bao bì", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Số lô:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
                      SizedBox(width: 10),
                      Expanded(
                          child: Text(item.soLOT ?? ' ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Xuất Xứ:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
                      SizedBox(width: 10),
                      Expanded(child: Text("Việt Nam", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              )),
            if (data.packageDetails.isEmpty )
              ...data.packageDetails.map((item) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Ngày sản xuất: ", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
                      SizedBox(width: 10),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Ngày hết hạn:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
                      SizedBox(width: 10),
                      Expanded(child: Text("Xem trên bao bì", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Số lô:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
                      SizedBox(width: 10),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Xuất Xứ:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
                      SizedBox(width: 10),
                      Expanded(child: Text("Việt Nam", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ),
              )
          ],
        )

    ));

    widgets.addAll(data.distributionDetails.map((item) => Container(
      padding: EdgeInsets.all(10), // Khoảng cách bên trong giữa viền và hình ảnh
      margin: EdgeInsets.fromLTRB(15, 5, 15,0),// Khoảng cách bên ngoài giữa container và các widget xung quanh
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền của container, nên thiết lập để đổ bóng hiển thị rõ ràng
        border: Border.all(
          color: Color(0xFFEEEEEE), // Màu viền
          width: 1.0, // Độ dày của viền
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Màu đổ bóng
            spreadRadius: 1, // Phạm vi mà đổ bóng sẽ lan rộng
            blurRadius: 10, // Độ mờ của đổ bóng
            offset: Offset(0, 5), // Vị trí đổ bóng, x và y
          ),
        ],
        borderRadius: BorderRadius.circular(5), // Bo góc của container
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PHÂN PHỐI", style: TextStyle(fontSize: 20, color: Color(0xFF379BD1))),
          Text(
            "Ngày phân phối: " + (item.ngayPP != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(item.ngayPP!)) : ' '),
            style: TextStyle(fontSize: 16, color: Color(0xFF777777)),
          ),
          Row(
            children: [
              Text("Lệnh giao hàng:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
              SizedBox(width: 10),
              Expanded(child: Text(" ${item.lenhXH}", style: TextStyle(fontSize: 16, color: Color(0xFF337ab7))),
              )
            ],
          ),
          Row(
            children: [
              Text("Phân phối bởi:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
              SizedBox(width: 10),
              Expanded(child: Text(item.phanPhoiBoi ?? '', style: TextStyle(fontSize: 16, color: Color(0xFF337ab7))),
              )
            ],
          ),
          Row(
            children: [
              Text("Phân phối đến:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
              SizedBox(width: 10),
              Expanded(child: Text(item.phanPhoiDen ?? '', style: TextStyle(fontSize: 16, color: Color(0xFF337ab7))),
              )
            ],
          ),
          Row(
            children: [
              Text("Khu vực:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
              SizedBox(width: 10),
              Expanded(child: Text(item.khuVuc ?? '', style: TextStyle(fontSize: 16, color: Color(0xFF337ab7))),
              )
            ],
          ),

        ],
      ),
    )));
    //
    widgets.addAll(data.warehouseDetails.map((item) => Container(
      padding: EdgeInsets.all(10), // Khoảng cách bên trong giữa viền và hình ảnh
      margin: EdgeInsets.fromLTRB(15, 5, 15,0), // Khoảng cách bên ngoài giữa container và các widget xung quanh
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền của container, nên thiết lập để đổ bóng hiển thị rõ ràng
        border: Border.all(
          color: Color(0xFFEEEEEE), // Màu viền
          width: 1.0, // Độ dày của viền
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Màu đổ bóng
            spreadRadius: 1, // Phạm vi mà đổ bóng sẽ lan rộng
            blurRadius: 10, // Độ mờ của đổ bóng
            offset: Offset(0, 5), // Vị trí đổ bóng, x và y
          ),
        ],
        borderRadius: BorderRadius.circular(5), // Bo góc của container
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text("PHÂN PHỐI KHO THUÊ", style: TextStyle(fontSize: 20, color: Color(0xFF379BD1))),
          Row(
            children: [
              Text("Ngày phân phối:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
              SizedBox(width: 10),
              Expanded(child: Text(
                 (item.KTngayPP != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(item.KTngayPP!)) : ''),
                style: TextStyle(fontSize: 16, color: Color(0xFF777777)),
              ),
              ),
            ],
          ),
          Row(
            children: [
              Text("Lệnh giao hàng:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
              SizedBox(width: 10),
              Expanded(child: Text(item.KTlenhXH ?? '', style: TextStyle(fontSize: 16, color: Color(0xFF337ab7))),
              )
            ],
          ),
          Row(
            children: [
              Text("Phân phối bởi :", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
              SizedBox(width: 10),
              Expanded(child: Text(item.KTphanPhoiBoi ?? '', style: TextStyle(fontSize: 16, color: Color(0xFF337ab7))),

              )
            ],
          ),
          Row(
            children: [
              Text("Phân phối đến:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
              SizedBox(width: 10),
              Expanded(child: Text(item.KTphanPhoiDen ?? '', style: TextStyle(fontSize: 16, color: Color(0xFF337ab7))),
              )
            ],
          ),
          Row(
            children: [
              Text("Khu vực:", style: TextStyle(fontSize: 16, color: Color(0xFF777777))),
              SizedBox(width: 10),
              Expanded(child: Text(item.KTkhuVuc ?? '', style: TextStyle(fontSize: 16, color: Color(0xFF337ab7))),
              )
            ],
          ),
        ],
      ),
    )));

    Widget htmlContent(String htmlData) {
      return Html(
        data: htmlData,
        style: {
          "p": Style(
            textAlign: TextAlign.justify,
            fontSize: FontSize(16.0),
            color: Colors.black,
          ),
          "strong": Style(fontWeight: FontWeight.bold),
          "span": Style(color: Colors.black),
        },
      );
    }

    widgets.addAll(data.rfidDetails.map((item) => Container(
      padding: EdgeInsets.all(10), // Khoảng cách bên trong giữa viền và hình ảnh
      margin: EdgeInsets.fromLTRB(15, 5, 15,0), // Khoảng cách bên ngoài giữa container và các widget xung quanh
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền của container, nên thiết lập để đổ bóng hiển thị rõ ràng
        border: Border.all(
          color: Color(0xFFEEEEEE), // Màu viền
          width: 1.0, // Độ dày của viền
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Màu đổ bóng
            spreadRadius: 1, // Phạm vi mà đổ bóng sẽ lan rộng
            blurRadius: 10, // Độ mờ của đổ bóng
            offset: Offset(0, 5), // Vị trí đổ bóng, x và y
          ),
        ],
        borderRadius: BorderRadius.circular(5), // Bo góc của container
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("THÔNG TIN SẢN PHẨM", style: TextStyle(fontSize: 20, color: Color(0xFF379BD1))),
          htmlContent(item.thongTinSP ?? ''), // Đây là widget Html, không phải widget Text
        ],
      ),
    )));

    widgets.addAll(data.rfidDetails.map((item) => Container(
      padding: EdgeInsets.all(10), // Khoảng cách bên trong giữa viền và hình ảnh
      margin: EdgeInsets.fromLTRB(15,5, 15,0), // Khoảng cách bên ngoài giữa container và các widget xung quanh
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền của container, nên thiết lập để đổ bóng hiển thị rõ ràng
        border: Border.all(
          color: Color(0xFFEEEEEE), // Màu viền
          width: 1.0, // Độ dày của viền
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Màu đổ bóng
            spreadRadius: 1, // Phạm vi mà đổ bóng sẽ lan rộng
            blurRadius: 10, // Độ mờ của đổ bóng
            offset: Offset(0, 5), // Vị trí đổ bóng, x và y
          ),
        ],
        borderRadius: BorderRadius.circular(5), // Bo góc của container
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("CÔNG TY SẢN XUẤT", style: TextStyle(fontSize: 20, color: Color(0xFF379BD1))),
          SizedBox(height: 10,),

          Text(item.nhaSanXuat ?? '', style: TextStyle(fontSize: 16, color: Color(0xFF379BD1), fontWeight: FontWeight.bold)),
          SizedBox(height: 10,),

          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Color(0xFF379BD1)),
              SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Địa chỉ: ",
                        style: TextStyle(fontSize: 16, color: Color(0xFF777777)), // Set color for label
                      ),
                      TextSpan(
                        text: item.diaChi ?? '',
                        style: TextStyle(fontSize: 16, color: Color(0xFF1f2b3d)), // Set a different color for email
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),

          Row(
            children: [
              Icon(Icons.phone_outlined, color: Color(0xFF379BD1)),
              SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Số điện thoại: ",
                        style: TextStyle(fontSize: 16, color: Color(0xFF777777)), // Set color for label
                      ),
                      TextSpan(
                        text: item.SDT ?? '',
                        style: TextStyle(fontSize: 16, color: Color(0xFF379BD1)), // Set a different color for email
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Icon(Icons.email_outlined,color: Color(0xFF379BD1)),
              SizedBox(width: 10),
              // Expanded(child: Text("Email: ${item.email}", style: TextStyle(fontSize: 16))),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Email: ",
                        style: TextStyle(fontSize: 16, color: Color(0xFF777777)), // Set color for label
                      ),
                      TextSpan(
                        text: item.email ?? '',
                        style: TextStyle(fontSize: 16, color: Color(0xFF379BD1)), // Set a different color for email
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),

          Row(
            children: [
              Icon(Icons.web, color: Color(0xFF379BD1)),
              SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Website: ",
                        style: TextStyle(fontSize: 16, color: Color(0xFF777777)), // Set color for label
                      ),
                      TextSpan(
                        text: item.website ?? '',
                        style: TextStyle(fontSize: 16, color: Color(0xFF379BD1)), // Set a different color for email
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )));
    return Column(children: widgets);
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thông tin sản phẩm",
          style: TextStyle(
            color: Color(0xFF097746),
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.07,
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/image/scan_noBG.png'),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              scanSingleTagAndUpdateWebView();

              Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  _isLoading = false;
                });
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          if(isScan)
            Container(
              height: screenHeight * 0.1,
              color: Color(0xFF274452),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Image.asset('assets/image/logoJVF_RFID.png',
                      width: screenWidth * 0.14, // 50% của chiều rộng màn hình
                      height: screenHeight * 0.8,
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'CÔNG TY PHÂN BÓN\n',
                            style: TextStyle(
                              color: Color(0xFF888787),
                              fontSize: 18,
                            ),
                          ),
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                            ),
                          ),
                          TextSpan(
                            text: 'VIỆT NHẬT (JVF)',
                            style: TextStyle(
                              color: Color(0xFF19C37B),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          FutureBuilder<CombinedProductDetails>(
            future: fetchAllProductDetails(globalScannedCode),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097746)),
                ));
              }
              else if (snapshot.hasError) {
                String errorMessage = "Đã xảy ra lỗi. Vui lòng thử lại.";
                if (snapshot.error.toString().contains("SocketException")) {
                  // errorMessage = "Không có kết nối Internet. Vui lòng kiểm tra lại kết nối của bạn.";
                  return Container(
                    margin: EdgeInsets.only(top: 50), // Adjust top margin as needed
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Makes the column's height fit its children
                        children: <Widget>[
                          Text(
                              'KHÔNG CÓ INTERNET.',
                              style: TextStyle(fontSize: 18, color: Colors.grey)
                          ),
                          Text(
                              'VUI LÒNG KIỂM TRA LẠI KẾT NỐI!',
                              style: TextStyle(fontSize: 18, color: Colors.grey)
                          )
                        ],
                      ),
                    ),
                  );
                }
                return Container(
                  margin: EdgeInsets.only(top: 50),  // Adjust the top margin as needed
                  child: Center(
                    child: Text("KHÔNG TÌM THẤY THÔNG TIN", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ),
                );
              } else if (snapshot.hasData) {
                bool hasContent = snapshot.data!.packageDetails.isNotEmpty ||
                    snapshot.data!.distributionDetails.isNotEmpty ||
                    snapshot.data!.warehouseDetails.isNotEmpty || snapshot.data!.rfidDetails.any((item) => item.maSP != null && item.maSP!.isNotEmpty );
                bool hasValidMaSP = snapshot.data!.rfidDetails.any((item) => item.maSP != null && item.maSP!.isNotEmpty);
                bool hasValidRecallStatus = snapshot.data!.rfidDetails.any((item) => item.trangThai == "TT012");
                bool hasValidReplaceStatus = snapshot.data!.rfidDetails.any((item) => item.trangThai == "TT017");
                if (hasValidRecallStatus){
                  return Container(
                    margin: EdgeInsets.only(top: 50),  // Adjust the top margin as needed
                    child: Center(
                      child: Text("Mã vạch đã thu hồi", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ),
                  );
                }else if (hasValidReplaceStatus){
                  return Container(
                    margin: EdgeInsets.only(top: 50),  // Adjust the top margin as needed
                    child: Center(
                      child: Text("Mã vạch đã thu hồi thay thế", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ),
                  );
                }
                else if (hasContent) {
                  return SingleChildScrollView(
                    child: buildDetailSections(snapshot.data!),
                  );
                } else if (_scanAttempted && !hasValidMaSP) {
                  return Container(
                    margin: EdgeInsets.only(top: 50),  // Adjust the top margin as needed
                    child: Center(
                      child: Text("KHÔNG TÌM THẤY THÔNG TIN", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ),
                  );
                }
              }
              return Container();
            },
          )

        ],
      ),
    );
  }
}
