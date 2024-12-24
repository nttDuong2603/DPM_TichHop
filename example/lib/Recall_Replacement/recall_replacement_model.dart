import 'dart:convert';
import 'package:uuid/uuid.dart';

class CalendarRecallReplacement {
  final String idLTHTT;
  final String ghiChuLTHTT;
  final String ngayTaoLTHTT;
  final String taiKhoanTTID;
  final int isTTRemove;
  int isTTSync ;
  List<TagEpcLTHTT> spcLTHTT;
  int thuHoiTTThanhCong;
  int thuHoiTTThatBai;
  int soluongquetTT;
  String ngayThuHoiTT;


  CalendarRecallReplacement({
    required this.idLTHTT,
    required this.ghiChuLTHTT,
    required this.ngayTaoLTHTT,
    required this.taiKhoanTTID,
    this.isTTRemove = 0,
    this.isTTSync = 0,
    this.spcLTHTT = const [],
    this.thuHoiTTThanhCong = 0,
    this.thuHoiTTThatBai = 0,
    this.soluongquetTT = 0,
    this.ngayThuHoiTT ='',
  });

  factory CalendarRecallReplacement.create({
    required String ghiChuLTHTT,
    required String taiKhoanTTID,
  }) {
    String idLTHTT = Uuid().v4();
    return CalendarRecallReplacement(
      idLTHTT: idLTHTT,
      ghiChuLTHTT: ghiChuLTHTT,
      taiKhoanTTID: taiKhoanTTID,
      ngayTaoLTHTT: DateTime.now().toString(),
    );
  }

  factory CalendarRecallReplacement.fromMap(Map<String, dynamic> map) {
    return CalendarRecallReplacement(
      idLTHTT: map['idLTHTT'],
      ghiChuLTHTT: map['ghiChuLTHTT'],
      ngayTaoLTHTT: map['ngayTaoLTHTT'],
      taiKhoanTTID: map['taiKhoanTTID'],
      spcLTHTT: (map['spcLTHTT'] as List<dynamic>?)
          ?.map((e) => TagEpcLTHTT.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idLTHTT': idLTHTT,
      'ghiChuLTHTT': ghiChuLTHTT,
      'ngayTaoLTHTT': ngayTaoLTHTT,
      'taiKhoanTTID': taiKhoanTTID,
    };
  }
}


class TagEpcLTHTT{

  final String epc;
  TagEpcLTHTT({required this.epc});
  // Chuyển đổi JSON Map thành đối tượng TagEpcLBD
  factory TagEpcLTHTT.fromMap(Map<String, dynamic> json) => TagEpcLTHTT(
    epc: json["KEY_EPC"],
  );
  // Chuyển đối tượng TagEpcLBD thành JSON Map
  Map<String, dynamic> toJson() => {
    "KEY_EPC": epc,
  };

  factory TagEpcLTHTT.fromJson(Map<String, dynamic> json) => TagEpcLTHTT(
    epc: json['epc'],
  );

  // Phân tích chuỗi JSON thành danh sách các TagEpcLBD
  static List<TagEpcLTHTT> parseTags(String str) =>
      List<TagEpcLTHTT>.from(json.decode(str).map((x) => TagEpcLTHTT.fromMap(x)));

  // Chuyển danh sách các TagEpcLBD thành chuỗi JSON
  static String tagsToJson(List<TagEpcLTHTT> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}

// "TenSanPham": "$15SP.10TSP",
// "MaLichDongBao":"$1CTĐBMR.3MLĐB",
// "TinhTrangDongBao": "$1CTĐBMR.1TTĐB",
// "MotaDongBao":"$1CTĐBMR.16MT",
// "NgayQuetDongBao":"$1CTĐBMR.30NT",
// "MaTaiKhoanDongBao":"$1CTĐBMR.17MTK",
class EPCInforRecall {
  final String EPC;
  final String? EPCStatus;
  final String? ProductCode;
  final String? PackageCode;
  final String? PackageStatus;
  final String? PackagingDescription;
  final String? PackageScanDate;
  final String? PackageAccountCode;
  final String? DistributionCode;
  final String? DistributionStatus;
  final String? DistributionDescription;
  final String? DistributionScanDate;
  final String? DistributionAccountCode;
  final String? WarehouseRentalDistributionCode;
  final String? WarehouseRentalDistributionStatus;
  final String? WarehouseRentalDistributionDescription;
  final String? WarehouseRentalDistributionScanDate;
  final String? WarehouseRentalDistributionAccountCode;


  EPCInforRecall({
    required this.EPC,
    required this.EPCStatus,
    required this.ProductCode,
    this.PackageCode,
    this.PackagingDescription,
    this.PackageStatus,
    this.PackageScanDate,
    this.PackageAccountCode,
    this.DistributionAccountCode,
    this.DistributionCode,
    this.DistributionDescription,
    this.DistributionScanDate,
    this.DistributionStatus,
    this.WarehouseRentalDistributionAccountCode,
    this.WarehouseRentalDistributionCode,
    this.WarehouseRentalDistributionDescription,
    this.WarehouseRentalDistributionScanDate,
    this.WarehouseRentalDistributionStatus,
  });
}


