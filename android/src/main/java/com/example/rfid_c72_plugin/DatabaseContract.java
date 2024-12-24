//duong.nguyen
package com.example.rfid_c72_plugin;


import android.provider.BaseColumns;

public class DatabaseContract implements BaseColumns {
    public static final String TABLE_NAME = "tagList_database";
    public static final String COLUMN_EPC = "epc";
    public static final String COLUMN_RSSI = "rssi";
    public static final String COLUMN_COUNT = "count";


    public static final String CREATE_TABLE =
            "CREATE TABLE " + TABLE_NAME + " (" +
                    _ID + " INTEGER PRIMARY KEY," +
                    COLUMN_EPC + " TEXT," +
                    COLUMN_RSSI + " TEXT)"
                    +
                    COLUMN_COUNT + " TEXT)";

}
