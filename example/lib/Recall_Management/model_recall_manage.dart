import 'dart:convert';
import 'package:uuid/uuid.dart';

class CalendarRecall {
  final String idLTH;
  final String ghiChuLTH;
  final String ngayTaoLTH;
  final String taiKhoanID;
  final int isRemove;
  int isSync ;
  List<TagEpcLTH> spcLTH;
  int thuHoiThanhCong;
  int thuHoiThatBai;
  int soluongquet;
  String ngayThuHoi;


  CalendarRecall({
    required this.idLTH,
    required this.ghiChuLTH,
    required this.ngayTaoLTH,
    required this.taiKhoanID,
    this.isRemove = 0,
    this.isSync = 0,
    this.spcLTH = const [],
    this.thuHoiThanhCong = 0,
    this.thuHoiThatBai = 0,
    this.soluongquet = 0,
    this.ngayThuHoi ='',
  });

  factory CalendarRecall.create({
    required String ghiChuLTH,
    required String taiKhoanID,
  }) {
    String idLTH = const Uuid().v4();
    return CalendarRecall(
      idLTH: idLTH,
      ghiChuLTH: ghiChuLTH,
      taiKhoanID: taiKhoanID,
      ngayTaoLTH: DateTime.now().toString(),
    );
  }

  factory CalendarRecall.fromMap(Map<String, dynamic> map) {
    return CalendarRecall(
      idLTH: map['idLTH'],
      ghiChuLTH: map['ghiChuLTH'],
      ngayTaoLTH: map['ngayTaoLTH'],
      taiKhoanID: map['taiKhoanID'],
      spcLTH: (map['spcLTH'] as List<dynamic>?)
          ?.map((e) => TagEpcLTH.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idLTH': idLTH,
      'ghiChuLTH': ghiChuLTH,
      'ngayTaoLTH': ngayTaoLTH,
      'taiKhoanID': taiKhoanID,
    };
  }
}


class TagEpcLTH {

  final String epc;
  TagEpcLTH({required this.epc});
  // Chuyển đổi JSON Map thành đối tượng TagEpcLBD
  factory TagEpcLTH.fromMap(Map<String, dynamic> json) => TagEpcLTH(
    epc: json["KEY_EPC"],
  );
  // Chuyển đối tượng TagEpcLBD thành JSON Map
  Map<String, dynamic> toJson() => {
    "KEY_EPC": epc,
  };

  factory TagEpcLTH.fromJson(Map<String, dynamic> json) => TagEpcLTH(
    epc: json['epc'],
  );

  // Phân tích chuỗi JSON thành danh sách các TagEpcLBD
  static List<TagEpcLTH> parseTags(String str) =>
      List<TagEpcLTH>.from(json.decode(str).map((x) => TagEpcLTH.fromMap(x)));

  // Chuyển danh sách các TagEpcLBD thành chuỗi JSON
  static String tagsToJson(List<TagEpcLTH> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}

