import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:intl/intl.dart'; // Import thư viện intl
import 'model_information_package.dart';
import '../Distribution_Module/model.dart';

class CalendarDistributionInfDatabaseHelper {
  static Database? _database;

  DatabaseHelper() {
    initDatabase();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'bangdlLDB24042024.db');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE CalendarDistributionInf(
            idLDB TEXT PRIMARY KEY,
            maLDB TEXT,
            sanPhamLDB TEXT,
            ghiChuLDB INTEGER,
            ngayTaoLDB INTEGER,
            taiKhoanID INTEGER,
            isRemove INTEGER DEFAULT 0,
            isSync INTEGER DEFAULT 0
          );
      ''');

        await db.execute('''
        CREATE TABLE EPC_data (
          KEY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          KEY_EPC TEXT,
          CalendarDistributionInfID INTEGER, -- Thêm trường foreign key
          FOREIGN KEY (CalendarDistributionInfID) REFERENCES CalendarDistributionInf(id) 
        );
        ''');
              },
      version: 1,
    );
  }

  
  Future<void> updateEventById(String idLDB, CalendarDistributionInf updatedEvent) async {
    final db = await database;
    await db.update(
      'CalendarDistributionInf',
      updatedEvent.toMap(),
      where: 'idLDB = ?',
      whereArgs: [idLDB],
    );
  }

  Future<void> updateHistoryEventById(String idLDB, int maDaDongBao, int maChuaKichHoat, int saiSanPham, int maKhongTonTai, int dongBaoThanhCong, int dongBaoThatbai) async {
    final db = await database;
    await db.update(
      'CalendarDistributionInf',
      {
        'maDaDongBao': maDaDongBao,
        'maChuaKichHoat': maChuaKichHoat,
        'saiSanPham': saiSanPham,
        'maKhongTonTai': maKhongTonTai,
        'dongBaoThanhCong': dongBaoThanhCong,
        'dongBaoThatbai': dongBaoThatbai,
      },
      where: 'idLDB = ?',
      whereArgs: [idLDB],
    );
  }

  Future<CalendarDistributionInf?> getEventById(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện truy vấn lấy dữ liệu từ bảng 'CalendarDistributionInf' dựa vào eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarDistributionInf',
      where: 'idLDB = ?',
      whereArgs: [eventId],
      limit: 1, // Giới hạn kết quả truy vấn chỉ lấy một bản ghi
    );
    if (maps.isNotEmpty) {
      // Chuyển đổi kết quả truy vấn thành đối tượng CalendarDistributionInf nếu tìm thấy
      return CalendarDistributionInf.fromMap(maps.first);
    }
    // Trả về null nếu không tìm thấy bản ghi nào
    return null;
  }

  Future<List<CalendarDistributionInf>> getEventsByDateAndAccount(DateTime selectedDate, String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Lấy ngày dưới dạng chuỗi
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho ngày cụ thể và tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarDistributionInf',
      where: 'time LIKE ? AND taiKhoanID = ?',
      whereArgs: ['$formattedDate%', accountName],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarDistributionInf
    return List.generate(maps.length, (i) {
      return CalendarDistributionInf(
        idLDB: maps[i]['idLDB'],
        maLDB: maps[i]['maLDB'],
        sanPhamLDB: maps[i]['sanPhamLDB'],
        ghiChuLDB: maps[i]['ghiChuLDB'],
        taiKhoanID: maps[i]['taiKhoanID'],
        ngayTaoLDB: maps[i]['ngayTaoLDB'],
      );
    });
  }

  Future<void> insertEvent(CalendarDistributionInf event, String taiKhoan) async {
    final db = await database;
    var eventMap = event.toMap();
    eventMap['taiKhoanID'] = taiKhoan;
    await db.insert(
      'CalendarDistributionInf',
      eventMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> printCalendarDistributionInfData() async {
    final db = await database;
    final List<Map<String, dynamic>> CalendarDistributionInfs = await db.query('CalendarDistributionInf');
    if (CalendarDistributionInfs.isNotEmpty) {
      CalendarDistributionInfs.forEach((CalendarDistributionInf) {
        print('CalendarDistributionInf ID: ${CalendarDistributionInf['idLDB']}');
        print('Mã lịch đóng bao: ${CalendarDistributionInf['tenDaiLy']}');
        print('Tên sản phẩm: ${CalendarDistributionInf['maLDB']}');
        print('Sản phẩm đóng bao: ${CalendarDistributionInf['sanPhamLDB']}');
        print('Ghi chú: ${CalendarDistributionInf['ghiChu']}');
        print('Tài khoản ID: ${CalendarDistributionInf['taiKhoanID']}');
        print('Thời gian: ${CalendarDistributionInf['time']}');
        print('----------------------------------------');
      });
      return CalendarDistributionInfs;
    } else {
      print('Bảng CalendarDistributionInf không có dữ liệu.');
      return [];
    }
  }

  Future<List<CalendarDistributionInf>> getEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarDistributionInf',
      where: 'taiKhoanID = ? AND isRemove = ? AND isSync = ? ',
      whereArgs: [accountName, 0, 0],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallEntry
    return List.generate(maps.length, (i) {
      return CalendarDistributionInf(
        idLDB: maps[i]['idLDB'],
        maLDB: maps[i]['maLDB'],
        sanPhamLDB: maps[i]['sanPhamLDB'],
        ghiChuLDB: maps[i]['ghiChuLDB']?.toString() ?? " ",
        taiKhoanID: maps[i]['taiKhoanID'],
        ngayTaoLDB: maps[i]['ngayTaoLDB'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }

  Future<List<CalendarDistributionInf>> getDeletedEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarDistributionInf',
      where: 'taiKhoanID = ? AND isRemove = ?',
      whereArgs: [accountName, 1],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallEntry
    return List.generate(maps.length, (i) {
      return CalendarDistributionInf(
        idLDB: maps[i]['idLDB'],
        maLDB: maps[i]['maLDB'],
        sanPhamLDB: maps[i]['sanPhamLDB'],
        ghiChuLDB: maps[i]['ghiChuLDB'],
        taiKhoanID: maps[i]['taiKhoanID'],
        ngayTaoLDB: maps[i]['ngayTaoLDB'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }


  Future<List<CalendarDistributionInf>> getHistoryEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarDistributionInf',
      where: 'taiKhoanID = ? AND isSync = ? ',
      whereArgs: [accountName, 1],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallEntry
    return List.generate(maps.length, (i) {
      return CalendarDistributionInf(
        idLDB: maps[i]['idLDB'],
        maLDB: maps[i]['maLDB'],
        sanPhamLDB: maps[i]['sanPhamLDB'],
        ghiChuLDB: maps[i]['ghiChuLDB'],
        taiKhoanID: maps[i]['taiKhoanID'],
        ngayTaoLDB: maps[i]['ngayTaoLDB'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }

  Future<List<CalendarDistributionInf>> getAllEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarDistributionInf',
      where: 'taiKhoanID = ?',
      whereArgs: [accountName],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarDistributionInfEntry
    return List.generate(maps.length, (i) {
      return CalendarDistributionInf(
        idLDB: maps[i]['idLDB'],
        maLDB: maps[i]['maLDB'],
        sanPhamLDB: maps[i]['sanPhamLDB'],
        ghiChuLDB: maps[i]['ghiChuLDB'],
        taiKhoanID: maps[i]['taiKhoanID'],
        ngayTaoLDB: maps[i]['ngayTaoLDB'],
      );
    });
  }

  Future<void> insertRFIDData(TagEpcLDB data, String CalendarDistributionInfId) async {
    final db = await database;
    // Tạo một map mới từ đối tượng TagEpcLBD để phù hợp với cấu trúc của bảng EPC_data
    Map<String, dynamic> epcDataMap = {
      'KEY_EPC': data.epc,
      'CalendarDistributionInfID': CalendarDistributionInfId,
    };
    // Chèn dữ liệu vào bảng EPC_data
    await db.insert(
      'EPC_data', // Tên bảng
      epcDataMap,
      conflictAlgorithm: ConflictAlgorithm.replace, // Xử lý xung đột dữ liệu bằng cách thay thế
    );
  }

  Future<List<TagEpcLDB>> getListRFIDDataByEventId(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện truy vấn lấy dữ liệu từ bảng EPC_data dựa vào eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'EPC_data',
      where: 'CalendarDistributionInfID = ?',
      whereArgs: [eventId],
    );
    // Khai báo biến TagEpcLBD trước khi sử dụng
    List<TagEpcLDB> tagEpcList = [];
    // Chuyển đổi kết quả truy vấn thành danh sách các đối tượng TagEpcLBD
    for (var map in maps) {
      TagEpcLDB tagEpcLBD = TagEpcLDB(
        epc: map['KEY_EPC'],
      );
      print('TagEpcLBD: ${tagEpcLBD.epc}'); // In dữ liệu từ bảng ra
      tagEpcList.add(tagEpcLBD); // Thêm vào danh sách
    }
    return tagEpcList;
  }

  Future<List<TagEpcLDB>> getRFIDDataByEventId(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện truy vấn lấy dữ liệu từ bảng EPC_data dựa vào eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'EPC_data',
      where: 'CalendarDistributionInfID = ?',
      whereArgs: [eventId],
    );
    // Chuyển đổi kết quả truy vấn thành danh sách các đối tượng TagEpcLBD
    return List.generate(maps.length, (i) {
      return TagEpcLDB(
        epc: maps[i]['KEY_EPC'],
      );
    });
  }

  Future<void> updateEPCDataByEventId(String eventId, List<TagEpcLDB> epcData) async {
    final db = await database;
    // Xóa tất cả các bản ghi EPC hiện tại cho lịch này
    await db.delete(
      'EPC_data',
      where: 'CalendarDistributionInfID = ?',
      whereArgs: [eventId],
    );

    // Thêm lại danh sách EPC mới cho lịch này
    for (var epc in epcData) {
      await db.insert(
        'EPC_data',
        {
          'KEY_EPC': epc.epc,
          'CalendarDistributionInfID': eventId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteRFIDData(String epc, String eventId) async {
    final db = await database;
    // Thực hiện xóa dữ liệu EPC dựa trên giá trị EPC và ID của sự kiện (event)
    await db.delete(
      'EPC_data', // Tên bảng chứa dữ liệu EPC
      where: 'KEY_EPC = ? AND CalendarDistributionInfID = ?', // Điều kiện để xác định dòng dữ liệu cần xóa
      whereArgs: [epc, eventId], // Giá trị thực tế cho điều kiện truy vấn
    );
  }

  Future<int> countRemainingTags(String eventId) async {
    final db = await database;

    int? remainingTagsCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM EPC_data WHERE CalendarDistributionInfID = ?',
      [eventId],
    ));

    return remainingTagsCount ?? 0; // Trả về 0 nếu remainingTagsCount là null
  }

  Future<void> deleteEvent(CalendarDistributionInf event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'CalendarDistributionInf', // Tên bảng chứa sự kiện
      {'isRemove': 1}, // Đánh dấu là đã xóa
      where: 'idLDB = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLDB], // Tham số cho điều kiện
    );
  }

  // Hàm xóa vĩnh viễn sự kiện khỏi bảng CalendarDistributionInf
  Future<void> deleteEventPermanently(String idLDB) async {
    final db = await database; // Đảm bảo cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện xóa vĩnh viễn bản ghi khỏi bảng CalendarDistributionInf dựa trên idLDB
    await db.delete(
      'CalendarDistributionInf', // Tên bảng
      where: 'idLDB = ?', // Điều kiện để xác định bản ghi cần xóa
      whereArgs: [idLDB], // Giá trị idLDB của sự kiện cần xóa
    );
    // Thực hiện xóa vĩnh viễn tất cả các bản ghi liên quan trong bảng EPC_data
    await db.delete(
      'EPC_data', // Tên bảng
      where: 'CalendarDistributionInfID = ?', // Điều kiện để xác định bản ghi cần xóa
      whereArgs: [idLDB], // Giá trị idLDB của sự kiện cần xóa
    );
    print('Event $idLDB deleted permanently.');
  }

  Future<void> unDeleteEvent(CalendarDistributionInf event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'CalendarDistributionInf', // Tên bảng chứa sự kiện
      {'isRemove': 0}, // Đánh dấu khoi phuc
      where: 'idLDB = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLDB], // Tham số cho điều kiện
    );
  }

  Future<void> syncEvent(CalendarDistributionInf event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'CalendarDistributionInf', // Tên bảng chứa sự kiện
      {'isSync': 1}, // Đánh dấu là đã xóa
      where: 'idLDB = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLDB], // Tham số cho điều kiện
    );
  }
  Future<void> updateTimeById(CalendarDistributionInf event, String newTime) async {
    final db = await database; // Lấy đối tượng cơ sở dữ liệu
    await db.update(
      'CalendarDistributionInf', // Tên bảng
      {'ngayTaoLDB': newTime}, // Dữ liệu cần cập nhật
      where: 'idLDB = ?', // Điều kiện để chọn bản ghi cần cập nhật
      whereArgs: [event.idLDB], // Giá trị ID của sự kiện cần cập nhật
    );
  }

  Future<void> insertAccount(TaiKhoan account) async {
    final db = await database;
    await db.insert(
      'account',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getTaiKhoanTable() async {
    Database db = await database;
    if (await isTableNotExists()) {
      return [];
    }
    return await db.query('account');
  }

  Future<bool> isTableNotExists() async {
    Database db = await database;
    var result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='account'");
    return result.isEmpty;
  }
}

