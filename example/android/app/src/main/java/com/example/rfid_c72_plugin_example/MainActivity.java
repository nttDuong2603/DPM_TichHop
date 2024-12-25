package com.example.rfid_c72_plugin_example;

import com.google.gson.Gson;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterActivity;

import com.example.rfid_c72_plugin_example.fragment.EventListener;
import com.example.rfid_c72_plugin_example.fragment.TagsRead;
import com.example.rfid_c72_plugin_example.fragment.Connections;
import com.example.rfid_c72_plugin_example.Activities.DeviceListActivity;

import com.rscja.deviceapi.RFIDWithUHFBLE;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.HashMap;

/*
Creator: NMC97
Date: 12/2024
Description: C72 and RFID R5
*/
public class MainActivity extends FlutterActivity {
    private TagsRead tagsRead;
    private DeviceListActivity deviceListActivity;
    private static final String CHANNEL = "rfid_r5_plugin";
    private static final String CHANNEL_C_Series = "rfid_c72_plugin";
    public RFIDWithUHFBLE uhfble;
    private static final int ACCESS_FINE_LOCATION_PERMISSION_REQUEST = 100;
    private static final int PERMISSION_REQUEST_CODE = 101;
    private static final int BLUETOOTH_REQUEST_ENABLE = 102;
    public static final int LOCATION_REQUEST_ENABLE = 124; //The code requires Location to be enabled
    private MethodChannel channel;
    public boolean isScanning = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Require access ble and location
        Connections.requestBluetoothPermissions(this, PERMISSION_REQUEST_CODE);
        Connections.checkAndEnableBluetooth(this, BLUETOOTH_REQUEST_ENABLE);
        Connections.requestLocationPermissions(this, ACCESS_FINE_LOCATION_PERMISSION_REQUEST);
        Connections.checkAndEnableLocation(this, LOCATION_REQUEST_ENABLE);
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Initialize the MethodChannel
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        uhfble = RFIDWithUHFBLE.getInstance();
        uhfble.init(getApplicationContext());
        channel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL);
        tagsRead = new TagsRead(uhfble, channel);

        tagsRead.addListener(new EventListener() {
            @Override
            public void onEventOccurred(ArrayList<HashMap<String, String>> data) {
                Gson gson = new Gson();
                String jsonData = gson.toJson(data);
                Log.d("MINHCHAULOG", "Event occurred with data: " + data.size());
                //Send data through Flutter via MethodChannel
                runOnUiThread(() -> {
                    channel.invokeMethod("inventoryMultiTag", jsonData, new MethodChannel.Result() {
                        @Override
                        public void success(Object result) {
                            Log.d("MINHCHAULOG", "Data sent successfully to Flutter.");
                        }
                        @Override
                        public void error(String errorCode, String errorMessage, Object errorDetails) {
                            Log.e("MINHCHAULOG", "Error sending data to Flutter: " + errorMessage);
                        }
                        @Override
                        public void notImplemented() {
                            Log.e("MINHCHAULOG", "Flutter method not implemented.");
                        }
                    });
                });
            }
        });

        deviceListActivity = new DeviceListActivity(this, uhfble, channel);

        // Set up the MethodChannel handler
        channel.setMethodCallHandler((call, result) -> {
            switch (call.method) {

                case "scanDevices": //Scan bluetooth RFID devices
                    boolean enable = call.argument("enable");
                    android.util.Log.d("MINHCHAULOG", "Start scan command from flutter");
                    deviceListActivity.scanBLEDevice(enable);
                    result.success("Scanning started");
                    break;

                case "connect": // Connect to device
                    String mac = call.argument("mac");
                    deviceListActivity.connect(mac);
                    result.success(true);
                    break;

                case "manualRead": // Manual scan
                    android.util.Log.d("MINHCHAULOG", "Manual read command from flutter");
                    boolean isStart = call.argument("isStart");
                    if (tagsRead != null) {
                        if(isStart){
                            tagsRead.onButtonManualPress(true);
                        } else {
                            tagsRead.onButtonManualPress(false);
                        }

                       // ArrayList<HashMap<String, String>> dataList = tagsRead.getTagList();
                        result.success("Manual Read Started !");
                    } else {
                        result.error("TAG_READ_ERROR", "TagsRead is not initialized", null);
                    }
                    break;

                case "inventorySingleTag": // Read single tag list
                    android.util.Log.d("MINHCHAULOG", "inventorySingleTag processing...");
                    if (tagsRead != null) {
                        tagsRead.inventorySingleTag();
                        ArrayList<HashMap<String, String>> dataList = tagsRead.getTagList();
                        result.success(dataList);
                    } else {
                        result.error("TAG_READ_ERROR", "TagsRead is not initialized", null);
                    }
                    break;
                default:
                    result.notImplemented(); // If the method is not supported
                    break;
            }
        });
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        Connections.handleBluetoothPermissionsResult(requestCode, permissions, grantResults); // xử lý kết quả cấp quyền bluetooth
        Connections.handleLocationPermissionsResult(requestCode, permissions, grantResults);    // Xử lý kết quả yêu cầu quyền vị trí
    }

    // Key Down for C72
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL_C_Series)
                .invokeMethod("onKeyDown", keyCode);
        android.util.Log.d("MINHCHAULOG", "C72 key down: " + keyCode);
        return super.onKeyDown(keyCode, event);
    }
    // Key Up for C72
    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL_C_Series)
                .invokeMethod("onKeyUp", keyCode);
        android.util.Log.d("MINHCHAULOG", "C72 key up: " + keyCode);
        return super.onKeyUp(keyCode, event);
    }
}







