import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../Configuration/device_configuration.dart';
import '../Distribution_Module/offline_distribution.dart';
import '../Check_Inventory/check_inventory.dart';
import '../Assign_Packing_Information/information_package.dart';
import '../Recall_Management/recall_manage.dart';
import '../Check_Goods_Infor_Module/goods_information.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Recall_Replacement/recall_replacement_offline_list.dart';
import '../UserDatatypes/user_datatype.dart';
import '../main.dart';
import '../utils/app_config.dart';
import 'package:marquee/marquee.dart';

import '../Configuration/configuration_page.dart';

class HomePage extends StatefulWidget {
  final String taiKhoan;

  const HomePage({
    Key? key,
    required this.taiKhoan,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> licenseCode = [];
  final _storageAcountCode = FlutterSecureStorage();
  final storage = FlutterSecureStorage();
  String? connectedDeviceName;
  String? connectedDeviceMac;
  String? selectedDevice;
  @override
  void initState() {
    super.initState();
    _loadSelectedDevice();
    _initCodes();  // Hàm lấy cả mã quyền và mã chức năng
  }

  // Đọc mã quyền và mã chức năng từ Secure Storage
  // Future<void> _initCodes() async {
  //   licenseCode = await _storageAcountCode.read(key: 'maQuyen');
  //   print('License Code: $licenseCode');
  //   setState(() {});
  // }

  // Future<void> _initCodes() async {
  //   licenseCode = await _storageAcountCode.read(key: 'maCN');
  //   print('License Code: $licenseCode');
  //   setState(() {});
  // }
  Future<void> _initCodes() async {
    // Đọc danh sách mã chức năng từ Secure Storage
    String? maCNListString = await _storageAcountCode.read(key: 'maCNList');
    if (maCNListString != null) {
      // Chuyển chuỗi thành danh sách các mã chức năng
      List<String> maCNList = maCNListString.split(',');
      print('Danh sách mã chức năng: $maCNList');

      // Giữ danh sách mã chức năng vào state
      setState(() {
        licenseCode = maCNList; // Bạn có thể điều chỉnh nếu muốn xử lý nhiều mã
        print('danh sách: $licenseCode');
      });
    }
  }

  Future<void> _loadSelectedDevice() async {
    String? savedDevice = await storage.read(key: 'selected_device'); // Lấy thiết bị từ storage
    String? savedDeviceName = await storage.read(key: 'connected_device_name');
    String? savedDeviceMac = await storage.read(key: 'connected_device_mac');

    setState(() {
      selectedDevice = savedDevice ?? 'C5'; // Nếu không có, mặc định là 'C5'
      connectedDeviceName = savedDeviceName;
      connectedDeviceMac = savedDeviceMac;

      if(selectedDevice == 'C5'){
        currentDevice = Device.C_Series;
      }
      else if(selectedDevice == 'R5'){
        currentDevice = Device.R_Series;

      }else if(selectedDevice == 'Camera'){
        currentDevice = Device.Camera_Barcodes;
      }

      AppConfig.device = selectedDevice;
      AppConfig.connectedDeviceName = connectedDeviceName;
      AppConfig.connectedDeviceMac = connectedDeviceMac;
    });
    print('Saved bluetooth name: ${AppConfig.connectedDeviceName}');
    print('Saved Bluetooth Mac: ${AppConfig.connectedDeviceMac}');
    print('Device type: ${AppConfig.device}');
  }

  void navigateToOfflineDistribution(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OfflineDistribution(taiKhoan: widget.taiKhoan)),
    );
  }

  void navigateToOfflineInformationDistribution(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OfflineInformationDistribution(taiKhoan: widget.taiKhoan)),
    );
  }

  void navigateToOfflineRecallManage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OfflineRecallManage(taiKhoan: widget.taiKhoan)),
    );
  }

  void navigateToOfflineRecallReplacemantList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OfflineRecallReplacemantList(taiKhoan: widget.taiKhoan)),
    );
  }

  void navigateToCheckInventory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckInventory(taiKhoan: widget.taiKhoan)),
    );
  }

  void navigateToGoodsDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoodsInformation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // return Scaffold(
    //   appBar: PreferredSize(
    //     preferredSize: Size.fromHeight(screenHeight * 0.12,),
    //     child: AppBar(
    //       backgroundColor: Colors.green,
    //       title: Row(
    //         children: [
    //           Image.asset(
    //             'assets/image/logoJVF_RFID.png',
    //             width: screenWidth * 0.35,
    //             height: screenHeight * 0.12,
    //           ),
    //           // InkWell(
    //           //   onTap: () {},
    //           //   child:
    //           // ),
    //           // SizedBox(width: 8),
    //           // Text(
    //           //   'PVFCCo RFID',
    //           //   style: TextStyle(
    //           //     fontSize: screenWidth * 0.06,
    //           //     fontWeight: FontWeight.bold,
    //           //     // color: AppColor
    //           //     color: AppColor.mainText,
    //           //   ),
    //           // ),
    //           Container(
    //             child: Column(
    //               // mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo trục dọc
    //               crossAxisAlignment: CrossAxisAlignment.start, // Căn giữa theo trục ngang
    //               children: [
    //                 Text(
    //                   'TẬP ĐOÀN DẦU KHÍ VIỆT NAM',
    //                   style: TextStyle(
    //                     fontSize: screenWidth * 0.03,
    //                     color: AppColor.logoText,
    //                   ),
    //                   textAlign: TextAlign.start, // Căn giữa chữ
    //                 ),
    //                 Padding(
    //                   padding: EdgeInsets.only(left: 0),
    //                   child: Text(
    //                     'TỔNG CÔNG TY',
    //                     style: TextStyle(
    //                       fontSize: screenWidth * 0.03,
    //                       fontWeight: FontWeight.bold,
    //                       color: AppColor.logoText,
    //                     ),
    //                     textAlign: TextAlign.start, // Căn giữa chữ
    //                   ),
    //                 ),
    //                 Text(
    //                   'PHÂN BÓN VÀ HÓA CHẤT DẦU KHÍ',
    //                   style: TextStyle(
    //                     fontSize: screenWidth * 0.03,
    //                     fontWeight: FontWeight.bold,
    //                     color: AppColor.logoText,
    //                   ),
    //                   textAlign: TextAlign.start, // Căn giữa chữ
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //
    //     ),
    //   ),
    //   // appBar: PreferredSize(
    //   //   preferredSize: Size.fromHeight(60.0), // Chiều cao AppBar
    //   //   child: AppBar(
    //   //     backgroundColor: AppColor.backgroundAppColor, // Làm nền AppBar trong suốt (nếu muốn)
    //   //     elevation: 0, // Loại bỏ bóng của AppBar
    //   //     flexibleSpace: Align(
    //   //       alignment: Alignment.centerLeft, // Căn về bên trái
    //   //       child: Padding(
    //   //         padding: EdgeInsets.only(left: 16.0), // Thêm khoảng cách từ trái nếu cần
    //   //         child: Image.asset(
    //   //           'assets/image/logo.png', // Đường dẫn hình ảnh
    //   //           width: screenWidth * 0.9, // Đặt kích thước chiều rộng
    //   //           height: screenHeight * 0.9, // Đặt kích thước chiều cao
    //   //           fit: BoxFit.contain, // Căn chỉnh hình ảnh
    //   //         ),
    //   //       ),
    //   //     ),
    //   //   ),
    //   // ),
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.12), // Chiều cao AppBar
        child: AppBar(
          backgroundColor: AppColor.backgroundAppColor, // Màu nền (có thể tùy chỉnh)
          elevation: 0, // Xóa bóng của AppBar
          flexibleSpace: Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.08, top: screenHeight * 0.02, bottom: screenHeight * 0.002), // Khoảng cách bên trong AppBar
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Căn giữa nội dung theo trục dọc
              children: [
                Image.asset(
                  'assets/image/logoJVF_RFID.png',
                  width: screenWidth * 0.215, // Chiều rộng của logo
                  height: screenHeight * 0.1,
                  fit: BoxFit.contain, // Đảm bảo logo không bị cắt xén
                ),
                SizedBox(width: screenWidth * 0.03), // Khoảng cách giữa logo và chữ
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end, // Căn giữa chữ theo trục dọc
                    crossAxisAlignment: CrossAxisAlignment.start, // Căn trái chữ
                    children: [
                      Text(
                        'TẬP ĐOÀN DẦU KHÍ VIỆT NAM',
                        style: TextStyle(
                          fontSize: screenWidth * 0.031,
                          color: AppColor.logoText,
                        ),
                      ),
                      Text(
                        'TỔNG CÔNG TY',
                        style: TextStyle(
                          fontSize: screenWidth * 0.031,
                          fontWeight: FontWeight.bold,
                          color: AppColor.logoText,
                        ),
                      ),
                      Text(
                        'PHÂN BÓN VÀ HÓA CHẤT DẦU KHÍ',
                        style: TextStyle(
                          fontSize: screenWidth * 0.031,
                          fontWeight: FontWeight.bold,
                          color: AppColor.logoText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                // Mở ConfigurationPage và nhận giá trị trả về
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeviceConfigurationPage()),
                );

                // Kiểm tra kết quả trả về từ ConfigurationPage
                if (result != null) {
                  setState(() {
                  });

                  print('Địa chỉ IP được chọn: ${AppConfig.IP}');
                  print('Thiết bị quét được chọn: $selectedDevice');
                }
              },
              icon: Icon(
                  Icons.settings_outlined,
                  color: AppColor.mainText
              ),
            ),
          ],
        ),
      ),
    body: Container(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.08, screenHeight * 0.01, screenWidth * 0.08, 0),
        constraints: BoxConstraints.expand(),
        color: AppColor.backgroundAppColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensure space between content and footer
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // if (licenseCode == 'MQ0002' ||
                  //     licenseCode == 'MQ0013' ||
                  //     licenseCode == 'MQ0018' ||
                  //     licenseCode == 'MQ0012' ||
                  //     licenseCode == 'MQ0009' ||
                  //     licenseCode == 'MQ0008') ...[
                  if (licenseCode != null && licenseCode!.contains('CNKTSP')) ...[
                    TextButton(
                      onPressed: () {
                        navigateToGoodsDetail(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColor.mainText,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.045, vertical: screenHeight * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/image/quetSP_logo.png',
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.13,
                          ),
                          SizedBox(width: screenWidth * 0.08),
                          Text(
                            'KIỂM TRA SẢN PHẨM',
                            style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                  if (licenseCode != null && licenseCode!.contains('CNPP')) ...[
                    // if (licenseCode == 'MQ0012' || licenseCode == 'MQ0008') ...[ // Hiển thị cho Quyền Phân Phối và Admin
                    TextButton(
                      onPressed: () {
                        navigateToOfflineDistribution(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColor.mainText,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.045, vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/image/phanphoi_logo.png',
                            width: screenWidth * 0.14,
                            height: screenWidth * 0.14,
                          ),
                          SizedBox(width: screenWidth * 0.15),
                          Text(
                            'PHÂN PHỐI',
                            style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                  if (licenseCode != null && licenseCode!.contains('CNKK')) ...[
                    // if (licenseCode == 'MQ0012' || licenseCode == 'MQ0008') ...[ // Hiển thị cho Quyền Kiểm Kho và Admin
                    TextButton(
                      onPressed: () {
                        navigateToCheckInventory(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColor.mainText,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.018),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/image/kiemkho_logo.png',
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                          ),
                          SizedBox(width: screenWidth * 0.18),
                          Text(
                            'KIỂM KHO',
                            style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                  if (licenseCode != null && licenseCode!.contains('CNDB')) ...[
                    // if (licenseCode == 'MQ0002' || licenseCode == 'MQ0013' || licenseCode == 'MQ0008' ) ...[// Hiển thị cho Quyền Đóng Bao và Admin
                    TextButton(
                      onPressed: () {
                        navigateToOfflineInformationDistribution(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColor.mainText,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.055, vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/image/gantt.png',
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                          ),
                          SizedBox(width: screenWidth * 0.1),
                          Text(
                            'GÁN THÔNG TIN \nĐÓNG BAO',
                            style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                  if (licenseCode != null && licenseCode!.contains('CNQLTH')) ...[
                    // if (licenseCode == 'MQ0008' || licenseCode == 'MQ0012') ...[ // Chỉ hiển thị cho Admin
                    TextButton(
                      onPressed: () {
                        navigateToOfflineRecallManage(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColor.mainText,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.055, vertical: screenHeight * 0.018),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/image/thuhoi.png',
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                          ),
                          SizedBox(width: screenWidth * 0.1),
                          Text(
                            'QUẢN LÝ THU HỒI',
                            style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                  if (licenseCode != null && licenseCode!.contains('CNTHTT')) ...[
                    // if (licenseCode == 'MQ0008' || licenseCode == 'MQ0012') ...[ // Chỉ hiển thị cho Admin
                    TextButton(
                      onPressed: () {
                        navigateToOfflineRecallReplacemantList(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColor.mainText,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.055, vertical: screenHeight * 0.018),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/image/recall_replace.png',
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                          ),
                          SizedBox(width: screenWidth * 0.1),
                          Text(
                            'THU HỒI THAY THẾ',
                            style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Column(
            //   children: [
            //     Text(
            //       'v1.0.0.5 IP: ${AppConfig.IP}',
            //       style: TextStyle(
            //         fontSize: screenWidth * 0.035,
            //         color: Colors.grey,
            //       ),
            //     ),
            //     // Text(
            //     //   'Thiết bị kết nối: ${AppConfig.device}',
            //     //   style: TextStyle(
            //     //     fontSize: screenWidth * 0.035,
            //     //     color: Colors.grey,
            //     //   ),
            //     // ),
            //     // Row(
            //     //   mainAxisAlignment: MainAxisAlignment.center,
            //     //   children: [
            //     //     Text(
            //     //       'Thiết bị kết nối: ${selectedDevice ?? 'C5' }',
            //     //       style: TextStyle(
            //     //         fontSize: screenWidth * 0.031,
            //     //         color: Colors.grey,
            //     //       ),
            //     //     ),
            //     //     if(selectedDevice == 'R5') ...[
            //     //       Text(
            //     //         ' (${connectedDeviceName ?? ''})',
            //     //         style: TextStyle(
            //     //           fontSize: screenWidth * 0.031,
            //     //           color: Colors.grey,
            //     //         ),
            //     //       ),
            //     //     ]
            //     //   ],
            //     // ),
            //     //  if(selectedDevice == 'R5') ...[
            //     //     Text(
            //     //       'Địa chỉ MAC: ${connectedDeviceMac ?? ''}',
            //     //       style: TextStyle(
            //     //         fontSize: screenWidth * 0.031,
            //     //         color: Colors.grey,
            //     //       ),
            //     //     ),
            //     //   ]
            //     // Container(
            //     //   height: screenHeight * 0.04, // Chiều cao của phần marquee
            //     //   child: Marquee(
            //     //     text: 'Thiết bị kết nối: ${AppConfig.device}', // Nội dung chạy ngang
            //     //     style: TextStyle(
            //     //       fontSize: screenWidth * 0.035,
            //     //       color: Colors.grey,
            //     //     ),
            //     //     scrollAxis: Axis.horizontal, // Cuộn theo chiều ngang
            //     //     blankSpace: 200.0, // Khoảng cách giữa các lần cuộn
            //     //     velocity: 30.0, // Tốc độ cuộn
            //     //     pauseAfterRound: Duration(seconds: 2), // Tạm dừng sau mỗi vòng
            //     //     startPadding: 10.0, // Khoảng cách bắt đầu
            //     //   ),
            //     // ),
            //   ],
            // )
            Align(
              alignment: Alignment.center,
              child:
              Padding(
                  padding: EdgeInsets.only(left: 0),
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'v1.0.0.5',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'IP: ${AppConfig.IP}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}