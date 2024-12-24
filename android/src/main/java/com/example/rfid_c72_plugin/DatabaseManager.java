//duong.nguyen
package com.example.rfid_c72_plugin;


import android.content.ContentValues;
import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.database.Cursor;

public class DatabaseManager {
    private static DatabaseManager instance;
    private static SQLiteOpenHelper dbHelper;
    private static SQLiteDatabase database;

    private DatabaseManager() {
        // Khởi tạo cơ sở dữ liệu SQLite
    }

    //    public static synchronized DatabaseManager getInstance(Context context) {
////        if (instance == null) {
////            instance = new DatabaseManager();
////            dbHelper = new DatabaseHelper(context);
////            database = dbHelper.getWritableDatabase();
////        }
////        return instance;
////    }
    public static synchronized DatabaseManager getInstance(Context context) {
        if (instance == null) {
            instance = new DatabaseManager();
            dbHelper = new DatabaseHelper(context);
            database = dbHelper.getWritableDatabase();
        } else if (database == null || !database.isOpen()) {
            database = dbHelper.getWritableDatabase();
        }
        return instance;
    }

    public synchronized void addTagToDatabase(String epc, String rssi) {
        ContentValues values = new ContentValues();
        values.put(DatabaseContract.COLUMN_EPC, epc);
        values.put(DatabaseContract.COLUMN_RSSI, rssi);
//        values.put(DatabaseContract.COLUMN_COUNT, Integer.parseInt(count));


        database.insert(DatabaseContract.TABLE_NAME, null, values);
    }

}
