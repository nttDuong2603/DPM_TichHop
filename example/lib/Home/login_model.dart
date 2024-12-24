class AccountInf {
  final String? maLNPP;
  final String? tenLNPP;
  final String maTK;
  final String? maKho;
  final String? tenKho;
  final String? maNPP;
  final String? tenNPP;
  final String? maQuyen;

  AccountInf({
    required this.maLNPP,
    required this.tenLNPP,
    required this.maTK,
    required this.maKho,
    required this.maNPP,
    required this.tenNPP,
    required this.tenKho,
    required this.maQuyen,
  });
}

class ChucNangTaiKhoan{
  final String? maCN;

  ChucNangTaiKhoan({
    this.maCN,
  });
}