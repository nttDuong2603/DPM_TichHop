import 'dart:convert';
import 'package:uuid/uuid.dart';

class CalendarDistributionInf {
  final String idLDB;
  final String maLDB;
  final String sanPhamLDB;
  final String ghiChuLDB;
  final String ngayTaoLDB;
  final String taiKhoanID;
  List<TagEpcLDB> spcLDB;
  int soLuongQuet;
  int isSync;
  int maDaDongBao;
  int maChuaKichHoat;
  int saiSanPham;
  int maKhongTonTai;
  int dongBaoThanhCong;
  int dongBaoThatbai;
  final int isRemove;
  int dadongbo;
  int dathuhoi;
  int completSchedule;
  int otherCase;
  String? syncDate;

  CalendarDistributionInf({
    required this.idLDB,
    required this.maLDB,
    required this.sanPhamLDB,
    required this.ghiChuLDB,
    required this.ngayTaoLDB,
    required this.taiKhoanID,
    this.spcLDB = const [],
    this.soLuongQuet = 0, // khởi tạo mặc định là 0
    this.isSync = 0,
    this.isRemove = 0,
    this.maChuaKichHoat = 0,
    this.maDaDongBao = 0,
    this.maKhongTonTai = 0,
    this.saiSanPham = 0,
    this.dongBaoThanhCong = 0,
    this.dongBaoThatbai = 0,
    this.dadongbo = 0,
    this.dathuhoi = 0,
    this.completSchedule = 0,
    this.otherCase = 0,
    this.syncDate = '',
  });

  factory CalendarDistributionInf.create({
    required String maLDB,
    required String sanPhamLDB,
    required String ghiChuLDB,
    required String taiKhoanID,
  }) {
    return CalendarDistributionInf(
      idLDB: const Uuid().v4(),
      maLDB: maLDB,
      sanPhamLDB: sanPhamLDB,
      ghiChuLDB: ghiChuLDB,
      ngayTaoLDB: DateTime.now().toString(),
      taiKhoanID: taiKhoanID,
    );
  }

  factory CalendarDistributionInf.fromMap(Map<String, dynamic> map) {
    return CalendarDistributionInf(
      idLDB: map['idLDB'],
      maLDB: map['maLDB'],
      sanPhamLDB: map['sanPhamLDB'],
      ghiChuLDB: map['ghiChuLDB'],
      ngayTaoLDB: map['ngayTaoLDB'],
      taiKhoanID: map['taiKhoanID'],
      spcLDB: (map['spcLDB'] as List<dynamic>?)
          ?.map((e) => TagEpcLDB.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      soLuongQuet: map['soLuongQuet'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idLDB': idLDB,
      'maLDB': maLDB,
      'sanPhamLDB': sanPhamLDB,
      'ghiChuLDB': ghiChuLDB,
      'ngayTaoLDB': ngayTaoLDB,
      'taiKhoanID': taiKhoanID,
    };
  }
}

class TagEpcLDB {
  final String epc;
  DateTime? scanDate;
  // add new for R5
  final String? count;
  final String? user;
  final String? rssi;
  final String? tid;

  TagEpcLDB({
    required this.epc,
    this.scanDate,
    this.count,
    this.user,
    this.rssi,
    this.tid,
  });

  // Chuyển đổi JSON Map thành đối tượng TagEpcLBD
  factory TagEpcLDB.fromMap(Map<String, dynamic> json) => TagEpcLDB(
    epc: json["KEY_EPC"],
    scanDate: json['scanDate'] != null ? DateTime.parse(json['scanDate']) : null,
  );
  // Chuyển đối tượng TagEpcLBD thành Map (dùng cho toMap)
  Map<String, dynamic> toMap() => {
    "KEY_EPC": epc,
    "scanDate": scanDate?.toIso8601String(),
  };

  // Chuyển đối tượng TagEpcLBD thành JSON Map
  Map<String, dynamic> toJson() => {
    "KEY_EPC": epc,
    "scanDate": scanDate?.toIso8601String(),
  };

  factory TagEpcLDB.fromJson(Map<String, dynamic> json) => TagEpcLDB(
    epc: json['epc'],
    scanDate: json['scanDate'] != null ? DateTime.parse(json['scanDate']) : null,
  );

  // Phân tích chuỗi JSON thành danh sách các TagEpcLBD
  static List<TagEpcLDB> parseTags(String str) =>
      List<TagEpcLDB>.from(json.decode(str).map((x) => TagEpcLDB.fromMap(x)));

  // Chuyển danh sách các TagEpcLBD thành chuỗi JSON
  static String tagsToJson(List<TagEpcLDB> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}


class WearHouseTypeList {
  final String maLNK;
  final String tenLNK;

  WearHouseTypeList({
    required this.maLNK,
    required this.tenLNK
  });
}

class SGTCLDB{
  final String SGTC;

  SGTCLDB({
    required this.SGTC,
  });
}

class Dealer {
  final String maLDB;
  final String? tenSP;
  final String? maSP;
  final String? ngaySX;
  final int? SBCSX;
  Dealer({
    required this.maLDB,
    required this.tenSP,
    required this.maSP,
    required this.ngaySX,
    required this.SBCSX
  });
}
class PackageCodeIsSync {
  final String isSyncCode;

  PackageCodeIsSync({
    required this.isSyncCode
  });
}


