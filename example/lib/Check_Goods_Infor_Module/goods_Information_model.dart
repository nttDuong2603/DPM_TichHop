
class PackageScheduleDetail {
  final String? ngaySX;
  final String? ngayHeHan;
  final String? soLOT;
  final String? moTa;

  PackageScheduleDetail({
    required this.ngaySX,
    required this.ngayHeHan,
    required this.soLOT,
    required this.moTa,
  });
}

class DistributionScheduleDetail {

  final String? ngayPP;
  final String? lenhXH;
  final String? phanPhoiBoi;
  final String? phanPhoiDen;
  final String? khuVuc;

  DistributionScheduleDetail({
    required this.khuVuc,
    required this.lenhXH,
    required this.ngayPP,
    required this.phanPhoiBoi,
    required this.phanPhoiDen,
  });
}

class WareHouseDistributionScheduleDetail {

  final String? KTngayPP;
  final String? KTlenhXH;
  final String? KTphanPhoiBoi;
  final String? KTphanPhoiDen;
  final String? KTkhuVuc;

  WareHouseDistributionScheduleDetail({
    required this.KTkhuVuc,
    required this.KTlenhXH,
    required this.KTngayPP,
    required this.KTphanPhoiBoi,
    required this.KTphanPhoiDen,
  });
}

class RFIDCodeManagement {
  final String? nhaSanXuat;
  final String? diaChi;
  final String? SDT;
  final String? email;
  final String? website;
  final String? gioiThieu;
  final String? thongTinSP;
  final String? tenSP;
  final String? maSP;
  final String? xuatXu;
  final List<dynamic>? hinhAnhSP;
  final String? trangThai;


  RFIDCodeManagement({
    required this.diaChi,
    required this.email,
    required this.gioiThieu,
    required this.nhaSanXuat,
    required this.SDT,
    required this.website,
    required this.thongTinSP,
    required this.tenSP,
    required this.maSP,
    required this.xuatXu,
    required this.hinhAnhSP,
    required this.trangThai,
  });
}

class CombinedProductDetails {
  final List<PackageScheduleDetail> packageDetails;
  final List<DistributionScheduleDetail> distributionDetails;
  final List<WareHouseDistributionScheduleDetail> warehouseDetails;
  final List<RFIDCodeManagement> rfidDetails;

  CombinedProductDetails({
    required this.packageDetails,
    required this.distributionDetails,
    required this.warehouseDetails,
    required this.rfidDetails,
  });
}

