package com.example.rfid_c72_plugin_example.fragment;


import android.util.Log;
import android.os.SystemClock;
import android.os.Message;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.example.rfid_c72_plugin_example.Utils;
import com.example.rfid_c72_plugin_example.tool.CheckUtils;
import com.example.rfid_c72_plugin_example.tool.NumberTool;
import com.rscja.deviceapi.RFIDWithUHFBLE;

import com.rscja.deviceapi.entity.UHFTAGInfo;
import com.rscja.deviceapi.interfaces.ConnectionStatus;
import com.rscja.deviceapi.interfaces.KeyEventCallback;
import com.rscja.deviceapi.interfaces.IUHFInventoryCallback;
import io.flutter.plugin.common.MethodChannel;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.TimerTask;
import java.util.Timer;

/*
Creator: NMC97
Date: 12/2024
Description: R5 Read Tags
*/
public class TagsRead {
    private List<EventListener> listeners = new ArrayList<>();
    private RFIDWithUHFBLE uhfble;
    final int FLAG_UPDATE_TIME = 12;
    final int FLAG_TIME_OVER = 14;
    final int FLAG_START = 0;
    final int FLAG_UHFINFO = 13;
    final int FLAG_SUCCESS = 10;
    final int FLAG_STOP = 1;
    final int FLAG_UHFINFO_LIST = 5;
    private long mStrTime;
    int maxRunTime = 99999999;
    final int FLAG_FAIL = 11;
    String time = "1"; // time to read tag loop
    private ArrayList<HashMap<String, String>> tagList = new ArrayList<>();
    private List<UHFTAGInfo> tempDatas = new ArrayList<UHFTAGInfo>();
    public static final String TAG_COUNT = "tagCount";
    public static final String TAG_DATA = "tagData";
    public static final String TAG_EPC = "tagEpc";
    public static final String TAG_TID = "tagTid";
    public static final String TAG_USER = "tagUser";
    public static final String TAG_RSSI = "tagRssi";
    public boolean isScanning = false;
    public boolean isSupportRssi = false;
    private boolean isExit = false;
    public static boolean isKeyDownUP = false;
    private MethodChannel methodChannel;
    private TimerTask continuousSendTask;
    private Timer continuousTimer;

    public TagsRead(RFIDWithUHFBLE uhfble,MethodChannel methodChannel) {
        this.uhfble = uhfble;
        this.methodChannel =  methodChannel;
        isExit = false;
        // Handle the data reading event when pressing the scan button on the RFID scanning device
        this.uhfble.setKeyEventCallback(new KeyEventCallback() {
            @Override
            public void onKeyDown(int keycode) {
                if (!isExit && uhfble.getConnectStatus() == ConnectionStatus.CONNECTED) {
                    Log.i("MINHCHAULOG", "Key Down: " + keycode);
                    if (keycode == 3) {
                        isKeyDownUP = true;
                        startInventoryScan();
                    } else {
                        if (!isKeyDownUP) {
                            if (keycode == 1) {
                                if (isScanning) {
                                    stop();
                                } else {
                                    startInventoryScan();
                                }
                            }
                        }
                    }
                    if (keycode == 2) {
                        if (isScanning) {
                            stop();
                            SystemClock.sleep(100);
                        }
                        //MR20
                        inventory();
                    }
                }
            }
            @Override
            public void onKeyUp(int keycode) {
                if (keycode == 4) {
                    stop();
                }
            }
        });
    }

    // Hàm xử lý khi nhấn nút
    public void onButtonManualPress(boolean isStart) {
        try {
            if (uhfble.getConnectStatus() != ConnectionStatus.CONNECTED) return;
            if(isStart){
                Log.i("MINHCHAULOG", "Start inventory scan");
                if (isScanning) {
                    stop();
                    startInventoryScan();
                } else {
                    startInventoryScan();
                }
            } else {
                Log.i("MINHCHAULOG", "Stop inventory scan");
                if (isScanning) {
                    stop();
                }
            }

        }
        catch (Exception e) {
            Log.e("MINHCHAULOG", "Error onButtonManualPress: " + e.getMessage());
        }

    }
    public void addListener(EventListener listener) {
        if (!listeners.contains(listener)) {
            listeners.add(listener);
            Log.d("MINHCHAULOG", "Listener added. Total listeners: " + listeners.size());
        }
    }

    public void removeListener(EventListener listener) {
        if (listeners.contains(listener)) {
            listeners.remove(listener);
            Log.d("MINHCHAULOG", "Listener removed. Remaining listeners: " + listeners.size());
        }
    }

    public void inventorySingleTag() {
        UHFTAGInfo info = uhfble.inventorySingleTag(); //Identify tag in single mode
        if (info != null) {
            Message msg = handler.obtainMessage(FLAG_UHFINFO);
            msg.obj = info;
            handler.sendMessage(msg); // Send message to handler
        }
    }

    public ArrayList<HashMap<String, String>> getTagList() {
        return tagList;
    }

    public void startInventoryScan() {
        //If scanning is already started, return
        if (isScanning) {
            return;
        }
        maxRunTime =1215751192;
        Log.i("MINHCHAULOG", "maxRunTime: "+maxRunTime);

        // Register callback to handle messages
        uhfble.setInventoryCallback(new IUHFInventoryCallback() {
            @Override
            public void callback(UHFTAGInfo uhftagInfo) {
                if (uhftagInfo != null) {
                    Log.i("MINHCHAULOG", "TAG Info Received: " + uhftagInfo.getEPC());
                    handler.sendMessage(handler.obtainMessage(FLAG_UHFINFO, uhftagInfo));
                } else {
                    Log.e("MINHCHAULOG", "No TAG Info received.");
                }
            }
        });
        isScanning = true;
        Message msg = handler.obtainMessage(FLAG_START);
        Log.i("MINHCHAUTAG", "startInventoryTag() 1");
        if (uhfble.startInventoryTag()) {
            mStrTime = System.currentTimeMillis();
            msg.arg1 = FLAG_SUCCESS;
            handler.sendEmptyMessage(FLAG_UPDATE_TIME);
            handler.removeMessages(FLAG_TIME_OVER);
            handler.sendEmptyMessageDelayed(FLAG_TIME_OVER, maxRunTime);
        } else {
            msg.arg1 = FLAG_FAIL;
            isScanning = false;
        }
        handler.sendMessage(msg);
    }

    public void triggerInventorySingleTagEvent() {
        ArrayList<HashMap<String, String>> dataList = getTagList();
       // sendDataToFlutter(dataList);
        Log.d("MINHCHAULOG", "List data feedback: " + dataList.size());

        // Call events and pass data
        for (EventListener listener : listeners) {
            try {
                listener.onEventOccurred(dataList);
            } catch (Exception e) {
                Log.e("MINHCHAULOG", "Error in listener: " + e.getMessage());
            }
        }
    }

    private void sendDataToFlutter(ArrayList<HashMap<String, String>> dataList) {
        if (dataList == null || dataList.isEmpty()) {
            Log.e("MINHCHAULOG", "Data list is empty, skipping invoke.");
            return;
        }

        Log.e("MINHCHAULOG", "Send data to Flutter: " + dataList.size());
        if (methodChannel != null) {
            methodChannel.invokeMethod("inventorySingleTag", dataList, new MethodChannel.Result() {
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
        } else {
            Log.e("MINHCHAULOG", "Error: MethodChannel is null.");
        }
    }

    public void stop() {
        handler.removeMessages(FLAG_TIME_OVER);
        if (isScanning) {
            stopInventory();
        }
        isScanning = false;
        cancelInventoryTask();
    }

    private TimerTask mInventoryPerMinuteTask;

    private  void cancelInventoryTask() {
        if (mInventoryPerMinuteTask != null) {
            mInventoryPerMinuteTask.cancel();
            mInventoryPerMinuteTask = null;
        }
    }

    public void stopInventory() {
        Log.i("MINCHAULOG", "stopInventory() 2");
        ConnectionStatus connectionStatus = uhfble.getConnectStatus();
        if (connectionStatus != ConnectionStatus.CONNECTED) {
            return;
        }
        boolean result = false;
        result = uhfble.stopInventory();
        Message msg = handler.obtainMessage(FLAG_STOP);
        if (!result && connectionStatus == ConnectionStatus.CONNECTED) {
            msg.arg1 = FLAG_FAIL;
        } else {
            msg.arg1 = FLAG_SUCCESS;
        }
        handler.sendMessage(msg);
    }

    public void inventory() { //Read each tag
        UHFTAGInfo info = uhfble.inventorySingleTag();
        if (info != null) {
            Message msg = handler.obtainMessage(FLAG_UHFINFO);
            msg.obj = info;
            handler.sendMessage(msg);
        }
    }

    private void showTempDatasInfo() {
        try {
            if (tempDatas != null) {
                for (UHFTAGInfo info : tempDatas) {
                    if (info.getEPC() != null) {
                        Log.d("MINHCHAULOG", "EPC: " + info.getEPC());
                    }
                    if (info.getTid() != null) {
                        Log.d("MINHCHAULOG", "TID: " + info.getTid());
                    }
                    if (info.getUser() != null) {
                        Log.d("MINHCHAULOG", "USER: " + info.getUser());
                    }
                    if (info.getRssi() != null) {
                        Log.d("MINHCHAULOG", "RSSI: " + info.getRssi());
                    }
                }
            } else {
                Log.d("TEMP_DATAS_INFO", "TempDatas is null");
            }
        } catch (Exception e) {
            android.util.Log.i("MINHCHAULOG", "Error show temp data info " + e);
        }
    }

    private void insertTag(UHFTAGInfo info, int index, boolean exists) {
        try {
            String data = info.getEPC();
            if (!TextUtils.isEmpty(info.getTid())) {
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.append("EPC:");
                stringBuilder.append(info.getEPC());
                stringBuilder.append("\n");
                stringBuilder.append("TID:");
                stringBuilder.append(info.getTid());
                if (!TextUtils.isEmpty(info.getUser())) {
                    stringBuilder.append("\n");
                    stringBuilder.append("USER:");
                    stringBuilder.append(info.getUser());
                }
                data = stringBuilder.toString(); //Create template  EPC:...TID:...USER:...
                Log.d("MINHCHAULOG", "Data with TID: " + data);
            }
            HashMap<String, String> tagMap = null; // Use HashMap to store tag data and fast access
            if (exists) {
                tagMap = tagList.get(index); // Get tag data from tagList

                //The decimal system (base 10) has a radix of 10 and uses the digits 0 through 9.
                tagMap.put(TAG_COUNT, String.valueOf(Integer.parseInt(tagMap.get(TAG_COUNT), 10) + 1)); // Increase the count of the tag
            } else {
                tagMap = new HashMap<>();
                tagMap.put(TAG_EPC, info.getEPC());
                tagMap.put(TAG_COUNT, String.valueOf(1));
                tempDatas.add(index, info);  // Add tag data to tempDatas
                tagList.add(index, tagMap); // Add tag data to tagList
            }
            // Add another data to tagMap
            tagMap.put(TAG_USER, info.getUser());
            tagMap.put(TAG_DATA, data);
            tagMap.put(TAG_TID, info.getTid());
            tagMap.put(TAG_RSSI, info.getRssi() == null ? "" : info.getRssi());

            for (HashMap<String, String> tag : tagList) {
                Log.d("MINHCHAULOG", "Tag List : " + tag);
            }
            showTempDatasInfo();
        } catch (Exception e) {
            android.util.Log.i("MINHCHAULOG", "Error insert tag " + e);
        }
    }

    private void addEPCToList(List<UHFTAGInfo> list) {
        for (int k = 0; k < list.size(); k++) {
            boolean[] exists = new boolean[1];
            UHFTAGInfo info = list.get(k);
            int idx = CheckUtils.getInsertIndex(tempDatas, info, exists); // find the index to insert the tag
            insertTag(info, idx, exists[0]);
        }
    }

    Handler handler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case FLAG_STOP:
                    if (msg.arg1 == FLAG_SUCCESS) {
                    } else {
                        Utils.playSound(2);
                    }
                    break;
                case FLAG_UHFINFO_LIST:
                    List<UHFTAGInfo> list = (List<UHFTAGInfo>) msg.obj;
                    addEPCToList(list);
                    break;
                case FLAG_START:
                    if (msg.arg1 == FLAG_SUCCESS) {
                        //start read success
                    } else {
                        Utils.playSound(2);
                    }
                    break;
                case FLAG_UPDATE_TIME:
                    if (isScanning) {
                        float useTime = (System.currentTimeMillis() - mStrTime) / 1000.0F;
                        String useTimeCustom = NumberTool.getPointDouble(1, useTime) + "s";
                        handler.sendEmptyMessageDelayed(FLAG_UPDATE_TIME, 10);
                    } else {
                        handler.removeMessages(FLAG_UPDATE_TIME);
                    }
                    break;
                case FLAG_TIME_OVER:
                    Log.i("MINHCHAULOG", "FLAG_TIME_OVER =" + (System.currentTimeMillis() - mStrTime));
                    float useTime2 = (System.currentTimeMillis() - mStrTime) / 1000.0F;
                    String useTimeCustom2 = NumberTool.getPointDouble(1, useTime2) + "s";
                    break;
                case FLAG_UHFINFO:
                    UHFTAGInfo info = (UHFTAGInfo) msg.obj; // Get tag info from message
                    List<UHFTAGInfo> listTemp = new ArrayList<UHFTAGInfo>();
                    listTemp.add(info);
                    addEPCToList(listTemp);
                    triggerInventorySingleTagEvent();
                    break;
            }
        }
    };
}
