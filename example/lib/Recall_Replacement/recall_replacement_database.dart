import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:intl/intl.dart'; // Import thư viện intl
import 'recall_replacement_model.dart';

class CalendarRecallReplacementDatabaseHelper {
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
    String path = join(await getDatabasesPath(), 'thuhoithaythebangdulieumoi.db');
    // print('path: $path');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE CalendarRecallReplacement(
            idLTHTT TEXT PRIMARY KEY,
            ghiChuLTHTT TEXT,
            ngayTaoLTHTT TEXT,
            taiKhoanTTID TEXT,
            isTTRemove INTEGER DEFAULT 0,
            isTTSync INTEGER DEFAULT 0
          );
      ''');

        await db.execute('''
        CREATE TABLE EPC_data (
          KEY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          KEY_EPC TEXT,
          CalendarRecallReplacementID INTEGER, -- Thêm trường foreign key
          FOREIGN KEY (CalendarRecallReplacementID) REFERENCES CalendarRecallReplacement(id) 
        );
        ''');
      },
      version: 1,
    );
  }

  Future<void> updateEventById(String idLTHTT, CalendarRecallReplacement updatedEvent) async {
    final db = await database;
    await db.update(
      'CalendarRecallReplacement',
      updatedEvent.toMap(),
      where: 'idLTHTT = ?',
      whereArgs: [idLTHTT],
    );
  }

  Future<CalendarRecallReplacement?> getEventById(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecallReplacement',
      where: 'idLTHTT = ?',
      whereArgs: [eventId],
      limit: 1, // Giới hạn kết quả truy vấn chỉ lấy một bản ghi
    );
    if (maps.isNotEmpty) {
      // Chuyển đổi kết quả truy vấn thành đối tượng CalendarRecall nếu tìm thấy
      return CalendarRecallReplacement.fromMap(maps.first);
    }
    // Trả về null nếu không tìm thấy bản ghi nào
    return null;
  }

  Future<List<CalendarRecallReplacement>> getEventsByDateAndAccount(DateTime selectedDate, String accountName, int isTTRemove) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Lấy ngày dưới dạng chuỗi
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho ngày cụ thể và tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecallReplacement',
      where: 'time LIKE ? AND taiKhoanTTID = ? AND isTTRemove = ?',
      whereArgs: ['$formattedDate%', accountName, isTTRemove],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallReplacement
    return List.generate(maps.length, (i) {
      return CalendarRecallReplacement(
        idLTHTT: maps[i]['idLTHTT'],
        ghiChuLTHTT: maps[i]['ghiChuLTHTT'],
        taiKhoanTTID: maps[i]['taiKhoanTTID'],
        ngayTaoLTHTT: maps[i]['ngayTaoLTHTT'],
        isTTRemove: maps[i]['isTTRemove'],
      );
    });
  }

  Future<void> insertEvent(CalendarRecallReplacement event, String taiKhoan) async {
    final db = await database;
    var eventMap = event.toMap();
    eventMap['taiKhoanTTID'] = taiKhoan;
    await db.insert(
      'CalendarRecallReplacement',
      eventMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> printCalendarRecallReplacementData() async {
    final db = await database;
    final List<Map<String, dynamic>> CalendarRecallReplacements = await db.query('CalendarRecallReplacement');
    if (CalendarRecallReplacements.isNotEmpty) {
      CalendarRecallReplacements.forEach((CalendarRecallReplacement) {
        print('CalendarRecallReplacement ID: ${CalendarRecallReplacement['idLTHTT']}');
        print('Ghi chú: ${CalendarRecallReplacement['ghiChuLTHTT']}');
        print('Tài khoản ID: ${CalendarRecallReplacement['taiKhoanTTID']}');
        print('Thời gian: ${CalendarRecallReplacement['ngayTaoLTHTT']}');
        print('----------------------------------------');
      });
      return CalendarRecallReplacements;
    } else {
      print('Bảng CalendarRecallReplacement không có dữ liệu.');
      return [];
    }
  }
  //
  Future<List<CalendarRecallReplacement>> getEventss(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecallReplacement',
      where: 'taiKhoanTTID = ? AND isTTRemove = ? ',
      whereArgs: [accountName, 0],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallReplacementEntry
    return List.generate(maps.length, (i) {
      return CalendarRecallReplacement(
        idLTHTT: maps[i]['idLTHTT'],
        ghiChuLTHTT: maps[i]['ghiChuLTHTT'],
        taiKhoanTTID: maps[i]['taiKhoanTTID'],
        ngayTaoLTHTT: maps[i]['ngayTaoLTHTT'],
        isTTRemove: maps[i]['isTTRemove'],
      );
    });
  }

  Future<List<CalendarRecallReplacement>> getEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecallReplacement',
      where: 'taiKhoanTTID = ? AND isTTRemove = ? AND isTTSync = ? ',
      whereArgs: [accountName, 0, 0],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallReplacementEntry
    return List.generate(maps.length, (i) {
      return CalendarRecallReplacement(
        idLTHTT: maps[i]['idLTHTT'],
        ghiChuLTHTT: maps[i]['ghiChuLTHTT'],
        taiKhoanTTID: maps[i]['taiKhoanTTID'],
        ngayTaoLTHTT: maps[i]['ngayTaoLTHTT'],
        isTTRemove: maps[i]['isTTRemove'],
      );
    });
  }

  Future<List<CalendarRecallReplacement>> getDeletedEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecallReplacement',
      where: 'taiKhoanTTID = ? AND isTTRemove = ?',
      whereArgs: [accountName, 1],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallReplacementEntry
    return List.generate(maps.length, (i) {
      return CalendarRecallReplacement(
        idLTHTT: maps[i]['idLTHTT'],
        ghiChuLTHTT: maps[i]['ghiChuLTHTT'],
        taiKhoanTTID: maps[i]['taiKhoanTTID'],
        ngayTaoLTHTT: maps[i]['ngayTaoLTHTT'],
        isTTRemove: maps[i]['isTTRemove'],
      );
    });
  }

  Future<List<CalendarRecallReplacement>> getHistoryEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecallReplacement',
      where: 'taiKhoanTTID = ? AND isTTSync = ? ',
      whereArgs: [accountName, 1],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallReplacementEntry
    return List.generate(maps.length, (i) {
      return CalendarRecallReplacement(
        idLTHTT: maps[i]['idLTHTT'],
        ghiChuLTHTT: maps[i]['ghiChuLTHTT'],
        taiKhoanTTID: maps[i]['taiKhoanTTID'],
        ngayTaoLTHTT: maps[i]['ngayTaoLTHTT'],
        isTTRemove: maps[i]['isTTRemove'],
      );
    });
  }

  Future<void> insertRFIDData(TagEpcLTHTT data, String CalendarRecallReplacementId) async {
    final db = await database;
    // Tạo một map mới từ đối tượng TagEpcLTH để phù hợp với cấu trúc của bảng EPC_data
    Map<String, dynamic> epcDataMap = {
      'KEY_EPC': data.epc,
      'CalendarRecallReplacementID': CalendarRecallReplacementId,
    };
    // Chèn dữ liệu vào bảng EPC_data
    await db.insert(
      'EPC_data', // Tên bảng
      epcDataMap,
      conflictAlgorithm: ConflictAlgorithm.replace, // Xử lý xung đột dữ liệu bằng cách thay thế
    );
  }

  Future<List<TagEpcLTHTT>> getListRFIDDataByEventId(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện truy vấn lấy dữ liệu từ bảng EPC_data dựa vào eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'EPC_data',
      where: 'CalendarRecallReplacementID = ?',
      whereArgs: [eventId],
    );
    // Khai báo biến TagEpcLTH trước khi sử dụng
    List<TagEpcLTHTT> tagEpcList = [];
    // Chuyển đổi kết quả truy vấn thành danh sách các đối tượng TagEpcLTH
    for (var map in maps) {
      TagEpcLTHTT tagEpcLTHTT = TagEpcLTHTT(
        epc: map['KEY_EPC'],
      );
      print('TagEpcLTH: ${tagEpcLTHTT.epc}'); // In dữ liệu từ bảng ra
      tagEpcList.add(tagEpcLTHTT); // Thêm vào danh sách
    }
    return tagEpcList;
  }

  Future<List<TagEpcLTHTT>> getRFIDDataByEventId(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện truy vấn lấy dữ liệu từ bảng EPC_data dựa vào eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'EPC_data',
      where: 'CalendarRecallReplacementID = ?',
      whereArgs: [eventId],
    );
    // Chuyển đổi kết quả truy vấn thành danh sách các đối tượng TagEpcLTH
    return List.generate(maps.length, (i) {
      return TagEpcLTHTT(
        epc: maps[i]['KEY_EPC'],
      );
    });
  }

  Future<void> updateEPCDataByEventId(String eventId, List<TagEpcLTHTT> epcData) async {
    final db = await database;
    // Xóa tất cả các bản ghi EPC hiện tại cho lịch này
    await db.delete(
      'EPC_data',
      where: 'CalendarRecallReplacementID = ?',
      whereArgs: [eventId],
    );
    // Thêm lại danh sách EPC mới cho lịch này
    for (var epc in epcData) {
      await db.insert(
        'EPC_data',
        {
          'KEY_EPC': epc.epc,
          'CalendarRecallReplacementID': eventId,
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
      where: 'KEY_EPC = ? AND CalendarRecallReplacementID = ?', // Điều kiện để xác định dòng dữ liệu cần xóa
      whereArgs: [epc, eventId], // Giá trị thực tế cho điều kiện truy vấn
    );
  }

  Future<int> countRemainingTags(String eventId) async {
    final db = await database;

    int? remainingTagsCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM EPC_data WHERE CalendarRecallReplacementID = ?',
      [eventId],
    ));
    return remainingTagsCount ?? 0; // Trả về 0 nếu remainingTagsCount là null
  }

  Future<void> deleteEvent(CalendarRecallReplacement event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'CalendarRecallReplacement', // Tên bảng chứa sự kiện
      {'isTTRemove': 1}, // Đánh dấu là đã xóa
      where: 'idLTHTT = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLTHTT], // Tham số cho điều kiện
    );
  }

  Future<void> unDeleteEvent(CalendarRecallReplacement event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'CalendarRecallReplacement', // Tên bảng chứa sự kiện
      {'isTTRemove': 0}, // Đánh dấu là đã xóa
      where: 'idLTHTT = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLTHTT], // Tham số cho điều kiện
    );
  }

  Future<void> deleteEventPermanently(CalendarRecallReplacement event) async {
    final db = await database; // Đảm bảo cơ sở dữ liệu đã được khởi tạo và kết nối
    await db.delete(
      'CalendarRecallReplacement', // Tên bảng chứa sự kiện
      where: 'idLTHTT = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLTHTT], // Tham số cho điều kiện
    );
  }
  Future<void> syncEvent(CalendarRecallReplacement event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'CalendarRecallReplacement', // Tên bảng chứa sự kiện
      {'isTTSync': 1}, // Đánh dấu là đã xóa
      where: 'idLTHTT = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLTHTT], // Tham số cho điều kiện
    );
  }
}
