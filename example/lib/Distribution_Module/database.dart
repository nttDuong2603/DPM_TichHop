import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:intl/intl.dart'; // Import thư viện intl
import 'model.dart';

class CalendarDatabaseHelper {
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
    String path = join(await getDatabasesPath(), 'BDLLPP24042024.db');
    // print('path: $path');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE calendar(
            id TEXT PRIMARY KEY,
            tenDaiLy TEXT,
            tenSanPham TEXT,
            soLuong INTEGER,
            soLuongQuet INTEGER,
            lenhPhanPhoi TEXT,
            phieuXuatKho TEXT,
            ghiChu TEXT,
            taiKhoanID INTEGER, 
            time TEXT,
            isRemove INTEGER DEFAULT 0,
            isSync INTEGER DEFAULT 0,
            FOREIGN KEY (taiKhoanID) REFERENCES account(ID) 
          );
      ''');

        await db.execute('''
        CREATE TABLE account(
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          taiKhoan TEXT,
          matKhau TEXT,
          quyen TEXT,
          danhsachChucNang TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE EPC_data (
          KEY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          KEY_EPC TEXT,
          calendarID INTEGER, -- Thêm trường foreign key
          FOREIGN KEY (calendarID) REFERENCES calendar(id) 
        );
        ''');

        await db.execute('''
        CREATE TABLE SLQ (
          KEY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          SLQ INTEGER,
          phieuXuatKho TEXT,
          calendarID INTEGER, 
          FOREIGN KEY (calendarID) REFERENCES calendar(id) 
        );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Add the 'quyen' column if it does not exist
          await db.execute("ALTER TABLE account ADD COLUMN danhsachChucNang TEXT");
        }
      },
      version: 3,
    );
  }

  Future<void> updateEventById(String id, Calendar updatedEvent) async {
    final db = await database;
    await db.update(
      'calendar',
      updatedEvent.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Calendar?> getEventById(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện truy vấn lấy dữ liệu từ bảng 'calendar' dựa vào eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'calendar',
      where: 'id = ?',
      whereArgs: [eventId],
      limit: 1, // Giới hạn kết quả truy vấn chỉ lấy một bản ghi
    );
    if (maps.isNotEmpty) {
      // Chuyển đổi kết quả truy vấn thành đối tượng Calendar nếu tìm thấy
      return Calendar.fromMap(maps.first);
    }
    // Trả về null nếu không tìm thấy bản ghi nào
    return null;
  }

  Future<List<Calendar>> getEventsByDateAndAccount(DateTime selectedDate, String accountName, int isRemove, int isSync) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Lấy ngày dưới dạng chuỗi
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho ngày cụ thể và tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'calendar',
      where: 'time LIKE ? AND taiKhoanID = ? AND isRemove = ? AND isSync = ?',
      whereArgs: ['$formattedDate%', accountName, isRemove, isSync],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng Calendar
    return List.generate(maps.length, (i) {
      return Calendar(
        id: maps[i]['id'],
        tenDaiLy: maps[i]['tenDaiLy'],
        tenSanPham: maps[i]['tenSanPham'],
        soLuong: maps[i]['soLuong'],
        soLuongQuet: maps[i]['soLuongQuet'],
        lenhPhanPhoi: maps[i]['lenhPhanPhoi'],
        phieuXuatKho: maps[i]['phieuXuatKho'],
        ghiChu: maps[i]['ghiChu'],
        taiKhoanID: maps[i]['taiKhoanID'],
        time: maps[i]['time'],
        isRemove: maps[i]['isRemove'],
        isSync: maps[i]['isSync'], // Đảm bảo rằng bạn có trường này trong đối tượng Calendar của bạn
      );
    });
  }

  // This method uses the getEventsByDateAndAccount method to fetch events and then prints their details
  Future<void> printEventsByDateAndAccount(DateTime selectedDate, String accountName, int isRemove, int isSync) async {
    try {
      // Calling the method to get a list of Calendar events
      List<Calendar> events = await getEventsByDateAndAccount(selectedDate, accountName, isRemove, isSync);

      // Check if the list of events is not empty
      if (events.isNotEmpty) {
        // Loop through each event and print its details
        for (Calendar event in events) {
          print('ID: ${event.id}');
          print('Tên đại lý: ${event.tenDaiLy}');
          print('Tên sản phẩm: ${event.tenSanPham}');
          print('Số lượng: ${event.soLuong}');
          print('Số lượng quét: ${event.soLuongQuet}');
          print('Lệnh phân phối: ${event.lenhPhanPhoi}');
          print('Phiếu xuất kho: ${event.phieuXuatKho}');
          print('Ghi chú: ${event.ghiChu}');
          print('Tài khoản ID: ${event.taiKhoanID}');
          print('Thời gian: ${event.time}');
          print('Đã xóa: ${event.isRemove}');
          print('Đã đồng bộ: ${event.isSync}');
          print('----------------------------------------');
        }
      } else {
        // Print a message if no events are found
        print('Không có sự kiện nào được tìm thấy cho ngày và tài khoản đã chọn.');
      }
    } catch (e) {
      // Handle any errors that might occur during the database operation
      print('Lỗi khi truy xuất sự kiện: $e');
    }
  }

  Future<void> insertEvent(Calendar event, String taiKhoan) async {
    final db = await database;
    var eventMap = event.toMap();
    eventMap['taiKhoanID'] = taiKhoan;
    await db.insert(
      'calendar',
      eventMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> printCalendarData() async {
    final db = await database;
    final List<Map<String, dynamic>> calendars = await db.query('calendar');
    if (calendars.isNotEmpty) {
      calendars.forEach((calendar) {
        print('Calendar ID: ${calendar['id']}');
        print('Tên đại lý: ${calendar['tenDaiLy']}');
        print('Tên sản phẩm: ${calendar['tenSanPham']}');
        print('Số lượng: ${calendar['soLuong']}');
        print('Số lượng quét: ${calendar['soLuongQuet']}');
        print('Lệnh phân phối: ${calendar['lenhPhanPhoi']}');
        print('Phiếu xuất kho: ${calendar['phieuXuatKho']}');
        print('Ghi chú: ${calendar['ghiChu']}');
        print('Tài khoản ID: ${calendar['taiKhoanID']}');
        print('Thời gian: ${calendar['time']}');
        print('----------------------------------------');
      });
      return calendars;
    } else {
      print('Bảng calendar không có dữ liệu.');
      return [];
    }
  }

  Future<List<Calendar>> getEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'calendar',
      where: 'taiKhoanID = ? AND isRemove = ? AND isSync = ?',
      whereArgs: [accountName, 0, 0],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarEntry
    return List.generate(maps.length, (i) {
      return Calendar(
        id: maps[i]['id'],
        tenDaiLy: maps[i]['tenDaiLy'],
        tenSanPham: maps[i]['tenSanPham'],
        soLuong: maps[i]['soLuong'],
        soLuongQuet: maps[i]['soLuongQuet'],
        lenhPhanPhoi: maps[i]['lenhPhanPhoi'],
        phieuXuatKho: maps[i]['phieuXuatKho'],
        ghiChu: maps[i]['ghiChu'],
        taiKhoanID: maps[i]['taiKhoanID'],
        time: maps[i]['time'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }

  Future<List<Calendar>> getEventsDeleted(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'calendar',
      where: 'taiKhoanID = ? AND isRemove = ? ',
      whereArgs: [accountName, 1],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarEntry
    return List.generate(maps.length, (i) {
      return Calendar(
        id: maps[i]['id'],
        tenDaiLy: maps[i]['tenDaiLy'],
        tenSanPham: maps[i]['tenSanPham'],
        soLuong: maps[i]['soLuong'],
        soLuongQuet: maps[i]['soLuongQuet'],
        lenhPhanPhoi: maps[i]['lenhPhanPhoi'],
        phieuXuatKho: maps[i]['phieuXuatKho'],
        ghiChu: maps[i]['ghiChu'],
        taiKhoanID: maps[i]['taiKhoanID'],
        time: maps[i]['time'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }

  Future<List<Calendar>> getHistoryEvents(String accountName) async {
    // Nhận đối tượng cơ sở dữ liệu
    final Database db = await database;
    // Truy vấn cơ sở dữ liệu để lấy danh sách các bản ghi lịch cho tài khoản cụ thể
    final List<Map<String, dynamic>> maps = await db.query(
      'calendar',
      where: 'taiKhoanID = ? AND isSync = ? ',
      whereArgs: [accountName, 1],
    );
    // Chuyển đổi danh sách các Map thành danh sách các đối tượng CalendarRecallEntry
    return List.generate(maps.length, (i) {
      return Calendar(
        id: maps[i]['id'],
        tenDaiLy: maps[i]['tenDaiLy'],
        tenSanPham: maps[i]['tenSanPham'],
        soLuong: maps[i]['soLuong'],
        soLuongQuet: maps[i]['soLuongQuet'],
        lenhPhanPhoi: maps[i]['lenhPhanPhoi'],
        phieuXuatKho: maps[i]['phieuXuatKho'],
        ghiChu: maps[i]['ghiChu'],
        taiKhoanID: maps[i]['taiKhoanID'],
        time: maps[i]['time'],
        isRemove: maps[i]['isRemove'],
      );
    });
  }

  Future<void> insertRFIDData(TagEpc data, String calendarId) async {
    final db = await database;
    // Tạo một map mới từ đối tượng TagEpc để phù hợp với cấu trúc của bảng EPC_data
    Map<String, dynamic> epcDataMap = {
      'KEY_EPC': data.epc,
      'calendarID': calendarId,
    };
    // Chèn dữ liệu vào bảng EPC_data
    await db.insert(
      'EPC_data', // Tên bảng
      epcDataMap,
      conflictAlgorithm: ConflictAlgorithm.replace, // Xử lý xung đột dữ liệu bằng cách thay thế
    );
    print('Data inserted successfully!');
  }

  Future<List<TagEpc>> getListRFIDDataByEventId(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện truy vấn lấy dữ liệu từ bảng EPC_data dựa vào eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'EPC_data',
      where: 'calendarID = ?',
      whereArgs: [eventId],
    );
    // Chuyển đổi kết quả truy vấn thành danh sách các đối tượng TagEpc
    return List.generate(maps.length, (i) {
      TagEpc tagEpc = TagEpc(
        epc: maps[i]['KEY_EPC'],
      );
      print('TagEpc $i: ${tagEpc.epc}'); // In dữ liệu từ bảng ra
      return tagEpc;
    });
  }

  Future<List<TagEpc>> getRFIDDataByEventId(String eventId) async {
    final db = await database; // Đảm bảo rằng cơ sở dữ liệu đã được khởi tạo và kết nối
    // Thực hiện truy vấn lấy dữ liệu từ bảng EPC_data dựa vào eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'EPC_data',
      where: 'calendarID = ?',
      whereArgs: [eventId],
    );
    // Chuyển đổi kết quả truy vấn thành danh sách các đối tượng TagEpc
    return List.generate(maps.length, (i) {
      return TagEpc(
        epc: maps[i]['KEY_EPC'],
      );
    });
  }

  Future<void> updateEPCDataByEventId(String eventId, List<TagEpc> epcData) async {
    final db = await database;
    // Xóa tất cả các bản ghi EPC hiện tại cho lịch này
    await db.delete(
      'EPC_data',
      where: 'calendarID = ?',
      whereArgs: [eventId],
    );
    // Thêm lại danh sách EPC mới cho lịch này
    for (var epc in epcData) {
      await db.insert(
        'EPC_data',
        {
          'KEY_EPC': epc.epc,
          'calendarID': eventId,
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
      where: 'KEY_EPC = ? AND calendarID = ?', // Điều kiện để xác định dòng dữ liệu cần xóa
      whereArgs: [epc, eventId], // Giá trị thực tế cho điều kiện truy vấn
    );
  }

  Future<int> countRemainingTags(String eventId) async {
    final db = await database;
    int? remainingTagsCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM EPC_data WHERE calendarID = ?',
      [eventId],
    ));
    return remainingTagsCount ?? 0; // Trả về 0 nếu remainingTagsCount là null
  }

  Future<void> deleteEvent(Calendar event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'calendar', // Tên bảng chứa sự kiện
      {'isRemove': 1}, // Đánh dấu là đã xóa
      where: 'id = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.id], // Tham số cho điều kiện
    );
  }

  Future<void> unDeleteEvent(Calendar event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'calendar', // Tên bảng chứa sự kiện
      {'isRemove': 0}, // Đánh dấu là đã xóa
      where: 'id = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.id], // Tham số cho điều kiện
    );
  }

  Future<void> deleteEventPermanently(String eventId) async {
    final db = await database; // Đảm bảo cơ sở dữ liệu đã được khởi tạo và kết nối
    await db.delete(
      'calendar', // Tên bảng chứa sự kiện
      where: 'id = ?', // Điều kiện để xác định sự kiện cần xóa
      whereArgs: [eventId], // Tham số ID của sự kiện cần xóa
    );
    print('Sự kiện đã được xóa vĩnh viễn!');
  }


  Future<void> syncEvent(Calendar event) async {
    final db = await database; // Giả sử bạn đã có đối tượng database
    await db.update(
      'calendar', // Tên bảng chứa sự kiện
      {'isSync': 1}, // Đánh dấu là đã xóa
      where: 'id = ?', // Điều kiện để tìm sự kiện cần xóa
      whereArgs: [event.id], // Tham số cho điều kiện
    );
  }

  Future<void> updateTimeById(String id, String newTime) async {
    final db = await database; // Lấy đối tượng cơ sở dữ liệu
    await db.update(
      'calendar', // Tên bảng
      {'time': newTime}, // Dữ liệu cần cập nhật
      where: 'id = ?', // Điều kiện để chọn bản ghi cần cập nhật
      whereArgs: [id], // Giá trị ID của sự kiện cần cập nhật
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

  Future<void> updateAccountQuyen(String taiKhoan, String newQuyen) async {
    final db = await database;
    await db.update(
      'account',
      {'quyen': newQuyen},
      where: 'taiKhoan = ?',
      whereArgs: [taiKhoan],
    );
  }

  Future<void> updateAccountCN(String taiKhoan, List<String> danhsachChucNang) async {
    final db = await database;

    // Chuyển List<String> thành chuỗi JSON
    String danhsachChucNangJson = jsonEncode(danhsachChucNang);

    // Cập nhật bảng 'account' với chuỗi JSON
    await db.update(
      'account',
      {'danhsachChucNang': danhsachChucNangJson},
      where: 'taiKhoan = ?',
      whereArgs: [taiKhoan],
    );
  }

  Future<void> checkUpdatedQuyen(String taiKhoan) async {
    final db = await database;
    final result = await db.query(
      'account',
      where: 'taiKhoan = ?',
      whereArgs: [taiKhoan],
    );

    if (result.isNotEmpty) {
      print("Quyền hiện tại của $taiKhoan: ${result[0]['quyen']}");
    } else {
      print("Không tìm thấy tài khoản $taiKhoan");
    }
  }

  // Future<List<Map<String, dynamic>>> getTaiKhoanTable() async {
  //   Database db = await database;
  //   if (await isTableNotExists()) {
  //     return [];
  //   }
  //   return await db.query('account');
  // }
  Future<List<TaiKhoan>> getTaiKhoanTable() async {
    Database db = await database;

    // Kiểm tra xem bảng có tồn tại không
    if (await isTableNotExists()) {
      return [];
    }

    // Truy vấn tất cả các bản ghi từ bảng 'account'
    List<Map<String, dynamic>> result = await db.query('account');

    // Chuyển đổi các bản ghi Map thành đối tượng TaiKhoan
    List<TaiKhoan> taiKhoanList = result.map((map) {
      // Tạo một Map sao chép từ bản gốc để tránh sửa đổi trực tiếp QueryRow
      Map<String, dynamic> accountMap = Map.from(map);

      // Tạo đối tượng TaiKhoan từ Map đã sửa
      return TaiKhoan.fromMap(accountMap);
    }).toList();

    return taiKhoanList;
  }




  // Future<List<Map<String, dynamic>>> getTaiKhoanTable() async {
  //   Database db = await database;
  //
  //   // Kiểm tra nếu bảng không tồn tại
  //   if (await isTableNotExists()) {
  //     return [];
  //   }
  //
  //   // Truy vấn tất cả các cột từ bảng account (bao gồm cả cột 'quyen')
  //   return await db.query('account', columns: ['taiKhoan', 'matKhau', 'quyen', 'danhsachChucNang']);
  // }


  Future<bool> isTableNotExists() async {
    Database db = await database;
    var result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='account'");
    return result.isEmpty;
  }
}

