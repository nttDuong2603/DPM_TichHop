import 'dart:convert';
import 'package:uuid/uuid.dart';

class DeletionInfo {
  final int deletedId;
  final int deletedTagsCount;
  final String eventId;
  final DateTime deletionDate;
  final List<String> deletedTagList;
  final String lenhPhanPhoi;

  DeletionInfo({
    required this.deletedId,
    required this.deletedTagsCount,
    required this.eventId,
    required this.deletionDate,
    required this.deletedTagList,
    required this.lenhPhanPhoi
  });

  Map<String, dynamic> toJson() => {
    'deletedId': deletedId,
    'deletedTagsCount': deletedTagsCount,
    'eventId': eventId,
    'deletionDate': deletionDate.toIso8601String(),
    'deletedTagList': deletedTagList,
    'lenhPhanPhoi': lenhPhanPhoi
  };

   static DeletionInfo fromJson(Map<String, dynamic> json) => DeletionInfo(
     deletedId: json['deletedId'],
    deletedTagsCount: json['deletedTagsCount'],
    eventId: json['eventId'],
    deletionDate: DateTime.parse(json['deletionDate']),
       deletedTagList: List<String>.from(json['deletedTagList']),
     lenhPhanPhoi: json['lenhPhanPhoi'],
  );
}

class Calendar {
  final String id;
  final String tenDaiLy;
  final String tenSanPham;
  final int soLuong;
  final int soLuongQuet;
  final String lenhPhanPhoi;
  final String phieuXuatKho;
  final String ghiChu;
  final String taiKhoanID;
  final String time;
  bool isSelected;
  final int isRemove;
  int isSync;
  List<TagEpc> epcData;
  int soLuongQuett;
  int phanPhoiThanhCong;
  int phanPhoiThatBai;
  int spDaPhanPhoi;
  int saiSPPhanPhoi;
  int maKhongTonTai;
  int maChuaDongBao;
  int dadongbo;
  int maChuaKichHoat;
  int madathuhoi;
  int machuappkt;
  int lichDaHoanThanh;
  int orthercase;
  String syncDate;
  // recallCode, completSchedule, orthercase, SyncCode, notwarehouseDistributionYet

  Calendar({
    required this.id,
    required this.tenDaiLy,
    required this.tenSanPham,
    required this.soLuong,
    required this.soLuongQuet,
    required this.lenhPhanPhoi,
    required this.phieuXuatKho,
    required this.ghiChu,
    required this.taiKhoanID,
    required this.time,
    this.isSelected = false,
    this.isRemove =  0,
    this.isSync = 0,
    this.epcData = const [],
    this.soLuongQuett = 0,
    this.spDaPhanPhoi = 0,
    this.maKhongTonTai = 0,
    this.phanPhoiThanhCong = 0,
    this.phanPhoiThatBai = 0,
    this.saiSPPhanPhoi = 0,
    this.maChuaDongBao = 0,
    this.dadongbo = 0,
    this.maChuaKichHoat = 0,
    this.madathuhoi = 0,
    this.machuappkt = 0,
    this.lichDaHoanThanh = 0,
    this.orthercase = 0,
    this.syncDate = '',
  });

  factory Calendar.create({
    required String tenDaiLy,
    required String tenSanPham,
    required int soLuong,
    required int soLuongQuet,
    required String lenhPhanPhoi,
    required String phieuXuatKho,
    required String ghiChu,
    required String taiKhoanID,
  }) {
    // Tạo một UUID ngẫu nhiên
    String id = Uuid().v4();
    // Trả về một thể hiện của lớp Calendar với ID tự động và các giá trị khác được cung cấp
    return Calendar(
      id: id,
      tenDaiLy: tenDaiLy,
      tenSanPham: tenSanPham,
      soLuong: soLuong,
      soLuongQuet: soLuongQuet,
      lenhPhanPhoi: lenhPhanPhoi,
      phieuXuatKho: phieuXuatKho,
      ghiChu: ghiChu,
      taiKhoanID: taiKhoanID,
      time: DateTime.now().toString(),
    );
  }

  factory Calendar.fromMap(Map<String, dynamic> map) {
    return Calendar(
      id: map['id'],
      tenDaiLy: map['tenDaiLy'],
      tenSanPham: map['tenSanPham'],
      soLuong: map['soLuong'],
      soLuongQuet: map['soLuongQuet'] ?? 0, // Giả sử rằng soLuongQuet có thể không tồn tại trong map
      lenhPhanPhoi: map['lenhPhanPhoi'],
      phieuXuatKho: map['phieuXuatKho'],
      ghiChu: map['ghiChu'],
      taiKhoanID: map['taiKhoanID'],
      time: map['time'],
      epcData: (map['epcData'] as List<dynamic>?)?.map((e) => TagEpc.fromMap(e)).toList() ?? [],
      soLuongQuett: map['soLuongQuett'] ?? 0,
    );
  }
  // Phương thức chuyển đổi đối tượng Calendar thành một bản đồ (map) dữ liệu
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenDaiLy': tenDaiLy,
      'tenSanPham': tenSanPham,
      'soLuong': soLuong,
      'soLuongQuet': soLuongQuet,
      'lenhPhanPhoi': lenhPhanPhoi,
      'phieuXuatKho': phieuXuatKho,
      'ghiChu': ghiChu,
      'taiKhoanID': taiKhoanID,
      'time': time,
    };
  }
}

class TaiKhoan {
  final String taiKhoan;
  final String matKhau;
  final String quyen;
  List<String>danhsachChucNang;

  TaiKhoan({
    required this.taiKhoan,
    required this.matKhau,
    required this.quyen,
    required this.danhsachChucNang,
  });

  factory TaiKhoan.fromMap(Map<String, dynamic> map) {
    return TaiKhoan(
      taiKhoan: map['taiKhoan'],
      matKhau: map['matKhau'],
      quyen: map['quyen'],
      // Kiểm tra và đảm bảo rằng 'danhsachChucNang' là chuỗi JSON hợp lệ trước khi giải mã
      danhsachChucNang: map['danhsachChucNang'] != null
          ? List<String>.from(
          jsonDecode(map['danhsachChucNang']) is List
              ? jsonDecode(map['danhsachChucNang'])
              : [] // Nếu không phải mảng, có thể xử lý thêm hoặc gán mảng trống
      )
          : [], // Nếu không có trường 'danhsachChucNang', gán mảng rỗng
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'taiKhoan': taiKhoan,
      'matKhau': matKhau,
      'quyen': quyen,
      'danhsachChucNang': jsonEncode(danhsachChucNang),
    };
  }
}

class TagEpc {
  final String epc;
  bool isSent;
  DateTime? saveDate;

  // add new for R5
  final String? count;
  final String? user;
  final String? rssi;
  final String? tid;

  TagEpc({
    required this.epc,
    this.isSent = false,
    this.saveDate,
    this.count,
    this.user,
    this.rssi,
    this.tid,
  });

  factory TagEpc.fromMap(Map<String, dynamic> json) => TagEpc(
    epc: json["KEY_EPC"],
    isSent: json['isSent'] ?? false,
    saveDate: json['saveDate'] != null ? DateTime.parse(json['saveDate']) : null,
  );

  Map<String, dynamic> toMap() => {
    "KEY_EPC": epc,
    'isSent': isSent,
    'saveDate': saveDate?.toIso8601String(),
  };

  Map<String, dynamic> toJson() => {
    'KEY_EPC': epc,
    'isSent': isSent,
    'saveDate': saveDate?.toIso8601String(),
  };

  // static TagEpc fromJson(Map<String, dynamic> json) => TagEpc(
  //   epc: json['KEY_EPC'],
  //   isSent: json['isSent'] ?? false,
  //   saveDate: json['saveDate'] != null ? DateTime.parse(json['saveDate']) : null,
  // );

// Phương thức `fromJson` không thay đổi:
  static TagEpc fromJson(Map<String, dynamic> json) => TagEpc(
    epc: json['KEY_EPC'],
    isSent: json['isSent'] ?? false,
    saveDate: json['saveDate'] != null
        ? DateTime.parse(json['saveDate'])
        : null,
  );

  static List<TagEpc> parseTags(String str) {
    // Chuyển đổi chuỗi JSON thành List<TagEpc>
    return List<TagEpc>.from(json.decode(str).map((x) => TagEpc.fromMap(x)));
  }

  // static List<TagEpc> parseTags(String str) =>
  //     List<TagEpc>.from(json.decode(str).map((x) => TagEpc.fromMap(x)));

  static String tagEpcToJson(List<TagEpc> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toMap())));
}

class EventDetailInfo {
  final String lenhPhanPhoi;
  final int totalTags;
  final int deletedTags;
  final int remainingTags;
  final DateTime scanDate;

  EventDetailInfo({
    required this.lenhPhanPhoi,
    required this.totalTags,
    required this.deletedTags,
    required this.remainingTags,
    required this.scanDate,
  });
}

class Dealer {
  final String MPX;
  final String? TSP;
  final String? MSP;
  final String? TNPP;
  final String? MNPP;
  final int? PXK;
  final  String? LXH;
  final int SBCX;
  final String? ghiChu;

  Dealer({
    required this.MPX ,
    required this.TSP,
    required this.MSP,
    required this.TNPP,
    required this.MNPP,
    required this.PXK,
    required this.LXH,
    required this.SBCX,
    required this.ghiChu
  });
}

class ExportCode {
  final String? maPXK;
  final String maPP;
  final String? congthuc;
  final String lenhGiaoHang;
  final String maSanPham;
  final String tenDaiLy;
  final String? soHoaDon;
  final String? phuongTien;
  final int soBaoCanXuat;
  final int? soTanCanXuat;
  final String? ghiChu;

  ExportCode({
    this.maPXK,
    required this.maPP,
    this.congthuc,
    required this.lenhGiaoHang,
    required this.maSanPham,
    required this.tenDaiLy,
    required this.soHoaDon,
    this.phuongTien,
    required this.soBaoCanXuat,
    this.soTanCanXuat,
    this.ghiChu,
  });
}

class PXKCode {
  final String maPXK;
  final String? pTien;

  PXKCode({
    required this.maPXK,
    this.pTien,
  });
}

