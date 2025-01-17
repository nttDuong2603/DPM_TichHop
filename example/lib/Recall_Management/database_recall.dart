import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:intl/intl.dart'; // Import thư viện intl
import 'model_recall_manage.dart';
import '../Models/model.dart';

class CalendarRecallDatabaseHelper {
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
    String path = join(await getDatabasesPath(), 'bangdulieulichthuhoimoinhat.db');
    // print('path: $path');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE CalendarRecall(
            idLTH TEXT PRIMARY KEY,
            ghiChuLTH TEXT,
            ngayTaoLTH TEXT,
            taiKhoanID TEXT,
            isRemove INTEGER DEFAULT 0,
            isSync INTEGER DEFAULT 0
          );
      ''');

        await db.execute('''
        CREATE TABLE EPC_data (
          KEY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          KEY_EPC TEXT,
          CalendarRecallID INTEGER, -- Thêm trường foreign key
          FOREIGN KEY (CalendarRecallID) REFERENCES CalendarRecall(id) 
        );
        ''');
      },
      version: 1,
    );
  }

  Future<void> updateEventById(String idLTH, CalendarRecall updatedEvent) async {
    final db = await database;
    await db.update(
      'CalendarRecall',
      updatedEvent.toMap(),
      where: 'idLTH = ?',
      whereArgs: [idLTH],
    );
  }

  Future<CalendarRecall?> getEventById(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecall',
      where: 'idLTH = ?',
      whereArgs: [eventId],
      limit: 1, // Giới hạn kết quả truy vấn chỉ lấy một bản ghi
    );
    if (maps.isNotEmpty) {
      // Chuyển đổi kết quả truy vấn thành đối tượng CalendarRecall nếu tìm thấy
      return CalendarRecall.fromMap(maps.first);
    }
    // Trả về null nếu không tìm thấy bản ghi nào
    return null;
  }

  Future<List<CalendarRecall>> getEventsByDateAndAccount(DateTime selectedDate, String accountName, int isRemove) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Lấy ngày dưới dạng chuỗi
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho ngày cụ thể và tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecall',
      where: 'time LIKE ? AND taiKhoanID = ? AND isRemove = ?',
      whereArgs: ['$formattedDate%', accountName, isRemove],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecall
    return List.generate(maps.length, (i) {
      return CalendarRecall(
        idLTH: maps[i]['idLTH'],
        ghiChuLTH: maps[i]['ghiChuLTH'],
        taiKhoanID: maps[i]['taiKhoanID'],
        ngayTaoLTH: maps[i]['ngayTaoLTH'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }

  Future<void> insertEvent(CalendarRecall event, String taiKhoan) async {
    final db = await database;
    var eventMap = event.toMap();
    eventMap['taiKhoanID'] = taiKhoan;
    await db.insert(
      'CalendarRecall',
      eventMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> printCalendarRecallData() async {
    final db = await database;
    final List<Map<String, dynamic>> CalendarRecalls = await db.query('CalendarRecall');
    if (CalendarRecalls.isNotEmpty) {
      CalendarRecalls.forEach((CalendarRecall) {
        print('CalendarRecall ID: ${CalendarRecall['idLTH']}');
        print('Ghi chú: ${CalendarRecall['ghiChuLTH']}');
        print('Tài khoản ID: ${CalendarRecall['taiKhoanID']}');
        print('Thời gian: ${CalendarRecall['ngayTaoLTH']}');
        print('----------------------------------------');
      });
      return CalendarRecalls;
    } else {
      print('Bảng CalendarRecall không có dữ liệu.');
      return [];
    }
  }
  //
  Future<List<CalendarRecall>> getEventss(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecall',
      where: 'taiKhoanID = ? AND isRemove = ? ',
      whereArgs: [accountName, 0],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallEntry
    return List.generate(maps.length, (i) {
      return CalendarRecall(
        idLTH: maps[i]['idLTH'],
        ghiChuLTH: maps[i]['ghiChuLTH'],
        taiKhoanID: maps[i]['taiKhoanID'],
        ngayTaoLTH: maps[i]['ngayTaoLTH'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }

  Future<List<CalendarRecall>> getEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecall',
      where: 'taiKhoanID = ? AND isRemove = ? AND isSync = ? ',
      whereArgs: [accountName, 0, 0],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallEntry
    return List.generate(maps.length, (i) {
      return CalendarRecall(
        idLTH: maps[i]['idLTH'],
        ghiChuLTH: maps[i]['ghiChuLTH'],
        taiKhoanID: maps[i]['taiKhoanID'],
        ngayTaoLTH: maps[i]['ngayTaoLTH'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }

  Future<List<CalendarRecall>> getDeletedEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecall',
      where: 'taiKhoanID = ? AND isRemove = ?',
      whereArgs: [accountName, 1],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallEntry
    return List.generate(maps.length, (i) {
      return CalendarRecall(
        idLTH: maps[i]['idLTH'],
        ghiChuLTH: maps[i]['ghiChuLTH'],
        taiKhoanID: maps[i]['taiKhoanID'],
        ngayTaoLTH: maps[i]['ngayTaoLTH'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }

  Future<List<CalendarRecall>> getHistoryEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'CalendarRecall',
      where: 'taiKhoanID = ? AND isSync = ? ',
      whereArgs: [accountName, 1],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallEntry
    return List.generate(maps.length, (i) {
      return CalendarRecall(
        idLTH: maps[i]['idLTH'],
        ghiChuLTH: maps[i]['ghiChuLTH'],
        taiKhoanID: maps[i]['taiKhoanID'],
        ngayTaoLTH: maps[i]['ngayTaoLTH'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }

  Future<void> insertRFIDData(TagEpcLTH data, String CalendarRecallId) async {
    final db = await database;
    // Tạo một map mới từ đối tượng TagEpcLTH để phù hợp với cấu trúc của bảng EPC_data
    Map<String, dynamic> epcDataMap = {
      'KEY_EPC': data.epc,
      'CalendarRecallID': CalendarRecallId,
    };
    // Chèn dữ liệu vào bảng EPC_data
    await db.insert(
      'EPC_data', // Tên bảng
      epcDataMap,
      conflictAlgorithm: ConflictAlgorithm.replace, // Xử lý xung đột dữ liệu bằng cách thay thế
    );
  }

  Future<List<TagEpcLTH>> getListRFIDDataByEventId(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện truy vấn lấy dữ liệu từ bảng EPC_data dựa vào eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'EPC_data',
      where: 'CalendarRecallID = ?',
      whereArgs: [eventId],
    );
    // Khai báo biến TagEpcLTH trước khi sử dụng
    List<TagEpcLTH> tagEpcList = [];
    // Chuyển đổi kết quả truy vấn thành danh sách các đối tượng TagEpcLTH
    for (var map in maps) {
      TagEpcLTH tagEpcLTH = TagEpcLTH(
        epc: map['KEY_EPC'],
      );
      print('TagEpcLTH: ${tagEpcLTH.epc}'); // In dữ liệu từ bảng ra
      tagEpcList.add(tagEpcLTH); // Thêm vào danh sách
    }
    return tagEpcList;
  }

  Future<List<TagEpcLTH>> getRFIDDataByEventId(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện truy vấn lấy dữ liệu từ bảng EPC_data dựa vào eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'EPC_data',
      where: 'CalendarRecallID = ?',
      whereArgs: [eventId],
    );
    // Chuyển đổi kết quả truy vấn thành danh sách các đối tượng TagEpcLTH
    return List.generate(maps.length, (i) {
      return TagEpcLTH(
        epc: maps[i]['KEY_EPC'],
      );
    });
  }

  Future<void> updateEPCDataByEventId(String eventId, List<TagEpcLTH> epcData) async {
    final db = await database;
    // Xóa tất cả các bản ghi EPC hiện tại cho lịch này
    await db.delete(
      'EPC_data',
      where: 'CalendarRecallID = ?',
      whereArgs: [eventId],
    );
    // Thêm lại danh sách EPC mới cho lịch này
    for (var epc in epcData) {
      await db.insert(
        'EPC_data',
        {
          'KEY_EPC': epc.epc,
          'CalendarRecallID': eventId,
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
      where: 'KEY_EPC = ? AND CalendarRecallID = ?', // Điều kiện để xác định dòng dữ liệu cần xóa
      whereArgs: [epc, eventId], // Giá trị thực tế cho điều kiện truy vấn
    );
  }

  Future<int> countRemainingTags(String eventId) async {
    final db = await database;

    int? remainingTagsCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM EPC_data WHERE CalendarRecallID = ?',
      [eventId],
    ));
    return remainingTagsCount ?? 0; // Trả về 0 nếu remainingTagsCount là null
  }

  Future<void> deleteEvent(CalendarRecall event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'CalendarRecall', // Tên bảng chứa sự kiện
      {'isRemove': 1}, // Đánh dấu là đã xóa
      where: 'idLTH = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLTH], // Tham số cho điều kiện
    );
  }

  Future<void> unDeleteEvent(CalendarRecall event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'CalendarRecall', // Tên bảng chứa sự kiện
      {'isRemove': 0}, // Đánh dấu là đã xóa
      where: 'idLTH = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLTH], // Tham số cho điều kiện
    );
  }

  Future<void> deleteEventPermanently(CalendarRecall event) async {
    final db = await database; // Đảm bảo cơ sở dữ liệu đã được khởi tạo và kết nối
    await db.delete(
      'CalendarRecall', // Tên bảng chứa sự kiện
      where: 'idLTH = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLTH], // Tham số cho điều kiện
    );
  }
  Future<void> syncEvent(CalendarRecall event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'CalendarRecall', // Tên bảng chứa sự kiện
      {'isSync': 1}, // Đánh dấu là đã xóa
      where: 'idLTH = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.idLTH], // Tham số cho điều kiện
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

