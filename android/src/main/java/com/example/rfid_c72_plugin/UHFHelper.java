package com.example.rfid_c72_plugin;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.os.SystemClock;
import android.view.InputDevice;
import android.view.InputEvent;
import android.view.KeyEvent;
import android.app.Instrumentation;

import com.rscja.barcode.BarcodeDecoder;
import com.rscja.barcode.BarcodeFactory;
import com.rscja.barcode.BarcodeUtility;
import com.rscja.deviceapi.RFIDWithUHFUART;
import com.rscja.deviceapi.entity.BarcodeEntity;
import com.rscja.deviceapi.entity.UHFTAGInfo;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Objects;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;


public class UHFHelper {

    private static UHFHelper instance;
    public RFIDWithUHFUART mReader;

    String TAG="MainActivity_2D";

    public BarcodeDecoder barcodeDecoder;
    Handler handler;
    private UHFListener uhfListener;
    private BarcodeListener barcodeListener;
    private boolean isStart = false;
    private boolean isConnect = false;
    private boolean isSingleRead = false;
    private HashMap<String, EPC> tagList;

    private String scannedBarcode;

    private Context context;

//    private UHFHelper() {
//
//    }

    public static UHFHelper getInstance() {
        if (instance == null)
            instance = new UHFHelper();
        return instance;
    }
    // Thiết lập BarcodeListener cho mã vạch
    public void setBarcodeListener(BarcodeListener barcodeListener) {
        this.barcodeListener = barcodeListener;
    }

    public RFIDWithUHFUART getReader() {
       return mReader;
    }

    public static boolean isEmpty(CharSequence cs) {
        return cs == null || cs.length() == 0;
    }

    public void setUhfListener(UHFListener uhfListener) {
        this.uhfListener = uhfListener;
    }

    public void init(Context context) {
        this.context = context;
//        this.uhfListener = uhfListener;
        tagList = new HashMap<String, EPC>();
        clearData();
        handler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                String result = msg.obj + "";
                String[] strs = result.split("@");
                addEPCToList(strs[0], strs[1]);
            }
        };

    }

    public String readBarcode(){
        if(scannedBarcode != null) {
            return scannedBarcode;
        }else{
            return "FAIL";
        }
    }

    public boolean connect() {
        try {
            mReader = RFIDWithUHFUART.getInstance();
        } catch (Exception ex) {
            uhfListener.onConnect(false, 0);
            return false;
        }
        if (mReader != null) {
            isConnect = mReader.init(context);
//            mReader.setFrequencyMode(2);
//            mReader.setPower(29);
            uhfListener.onConnect(isConnect, 0);
            return isConnect;
        }
        uhfListener.onConnect(false, 0);
        return false;
    }
//public boolean connect() {
//    if (barcodeDecoder != null && isBarcodeConnected) {
//        closeScan();  // Đóng kết nối mã vạch
//        isBarcodeConnected = false;  // Cập nhật trạng thái sau khi đóng
//        Log.i(TAG, "Barcode connection closed before initializing RFID.");
//    }
//    // Khởi tạo và kết nối với RFID
//    try {
//        mReader = RFIDWithUHFUART.getInstance();
//    } catch (Exception ex) {
//        uhfListener.onConnect(false, 0);
//        return false;
//    }
//
//    if (mReader != null) {
//        isConnect = mReader.init(context);
//        uhfListener.onConnect(isConnect, 0);
//        return isConnect;
//    }
//
//    uhfListener.onConnect(false, 0);
//    return false;
//}

//    public boolean connectBarcode() {
//        if (barcodeDecoder == null) {
//            barcodeDecoder = BarcodeFactory.getInstance().getBarcodeDecoder();
//        }
//        barcodeDecoder.open(context);
//
//        //BarcodeUtility.getInstance().enablePlaySuccessSound(context, true);
//
//        barcodeDecoder.setDecodeCallback(new BarcodeDecoder.DecodeCallback() {
//            @Override
//            public void onDecodeComplete(BarcodeEntity barcodeEntity) {
//                Log.e(TAG,"BarcodeDecoder==========================:"+barcodeEntity.getResultCode());
//                if(barcodeEntity.getResultCode() == BarcodeDecoder.DECODE_SUCCESS){
//                    scannedBarcode = barcodeEntity.getBarcodeData();
//                    Log.e(TAG,"Data==========================:"+barcodeEntity.getBarcodeData());
//                }else{
//                    scannedBarcode = "quét barcode FAIL";
//                }
//            }
//        });
//        return true;
//    }
//public boolean connectBarcode() {
//    if (barcodeDecoder == null) {
//        barcodeDecoder = BarcodeFactory.getInstance().getBarcodeDecoder();
//    }
//    barcodeDecoder.open(context);
//
//    barcodeDecoder.setDecodeCallback(new BarcodeDecoder.DecodeCallback() {
//        @Override
//        public void onDecodeComplete(BarcodeEntity barcodeEntity) {
//            if (barcodeEntity.getResultCode() == BarcodeDecoder.DECODE_SUCCESS) {
//                scannedBarcode = barcodeEntity.getBarcodeData();
//                Log.e(TAG,"Data==========================:"+barcodeEntity.getBarcodeData());
//                if (uhfListener != null) {
//                    uhfListener.onBarcodeScanned(scannedBarcode); // Gọi callback khi quét thành công
//                }
//            } else {
//                scannedBarcode = "quét barcode FAIL";
//            }
//        }
//    });
//    return true;
//}


//    public boolean scanBarcode() {
//        barcodeDecoder.startScan();
//        Log.i(TAG, "Calling scan code");
//        return true;
//    }

    public boolean emulatePhysicalButtonPress() {
        try {
            Instrumentation instrumentation = new Instrumentation();
            // Mô phỏng sự kiện phím xuống
            instrumentation.sendKeyDownUpSync(139);
            Log.i(TAG, "Simulated key press for physical scanner button");
            return true;

        } catch (Exception e) {
            Log.e(TAG, "Error emulating physical button press: ", e);
            return false;
        }
    }

    private boolean isBarcodeConnected = false; // Trạng thái để theo dõi kết nối

    public boolean connectBarcode() {
        try {
            if (barcodeDecoder == null) {
                barcodeDecoder = BarcodeFactory.getInstance().getBarcodeDecoder();
            }

            // Đóng máy quét trước khi mở để tránh xung đột
//            barcodeDecoder.close();

            boolean opened = barcodeDecoder.open(context);
            isBarcodeConnected = opened; // Cập nhật trạng thái kết nối
            Log.i(TAG, "Barcode decoder opened: " + opened);

            if (opened) {
                barcodeDecoder.setDecodeCallback(new BarcodeDecoder.DecodeCallback() {
                    @Override
                    public void onDecodeComplete(BarcodeEntity barcodeEntity) {
                        if (barcodeEntity.getResultCode() == BarcodeDecoder.DECODE_SUCCESS) {
                            scannedBarcode = barcodeEntity.getBarcodeData();
                            Log.e(TAG, "Data==========================:" + barcodeEntity.getBarcodeData());
                            if (barcodeListener != null) {
                                barcodeListener.onBarcodeScanned(scannedBarcode); // Gọi callback khi quét thành công
                            }
                        } else {
                            scannedBarcode = "quét barcode FAIL";
                            Log.e(TAG, "Barcode scan failed");
                        }
                    }
                });
            } else {
                Log.e(TAG, "Failed to open barcode decoder");
            }

            return opened;
        } catch (Exception e) {
            Log.e(TAG, "Error in connectBarcode: ", e);
            return false;
        }
    }

    public boolean scanBarcode() {
        if (!isBarcodeConnected) {
            boolean connected = connectBarcode();
            if (!connected) {
                Log.e(TAG, "Cannot scan barcode. Connection failed.");
                return false;
            }
        }

        try {
            new Thread(() -> {
                try {
                    if (!isBarcodeConnected) {
                        boolean connected = connectBarcode();
                        if (!connected) {
                            Log.e(TAG, "Cannot scan barcode. Connection failed.");
                            return;
                        }
                    }

                    barcodeDecoder.setDecodeCallback(new BarcodeDecoder.DecodeCallback() {
                        @Override
                        public void onDecodeComplete(BarcodeEntity barcodeEntity) {
                            if (barcodeEntity.getResultCode() == BarcodeDecoder.DECODE_SUCCESS) {
                                scannedBarcode = barcodeEntity.getBarcodeData();
                                Log.e(TAG, "Data==========================:" + barcodeEntity.getBarcodeData());
                                if (barcodeListener != null) {
                                    barcodeListener.onBarcodeScanned(scannedBarcode); // Gọi callback khi quét thành công
                                }

                                // Gọi hàm stopScan sau khi quét xong
//                                barcodeDecoder.stopScan();
                            } else {
                                scannedBarcode = "quét barcode FAIL";
                                Log.e(TAG, "Barcode scan failed");
                            }
                        }
                    });

                    barcodeDecoder.startScan();
                    Log.i(TAG, "Calling scan code through emulated button press");
                } catch (Exception e) {
                    Log.e(TAG, "Error starting barcode scan: ", e);
                }
            }).start();

            Log.i(TAG, "Calling scan code through emulated button press");
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Error in scanBarcode: ", e);
            return false;
        }
    }


//    public boolean scanBarcode() {
//        if (!isBarcodeConnected) {
//            boolean connected = connectBarcode();
//            if (!connected) {
//                Log.e(TAG, "Cannot scan barcode. Connection failed.");
//                return false;
//            }
//        }
//
//        try {
//            barcodeDecoder.startScan();
//            Log.i(TAG, "Calling scan code");
//            return true;
//        } catch (Exception e) {
//            Log.e(TAG, "Error in scanBarcode: ", e);
//            return false;
//        }
//    }


    public boolean stopScan() {
        barcodeDecoder.stopScan();
        Log.i(TAG, "Calling stop scan");
        return true;
    }

//    public boolean start(boolean isSingleRead) {
//        if (!isStart) {
//            if (isSingleRead) {// Single Read
//                UHFTAGInfo strUII = mReader.inventorySingleTag();
//                if (strUII != null) {
//                    String strEPC = strUII.getEPC();
//                    addEPCToList(strEPC, strUII.getRssi());
//                    return true;
//                } else {
//                    return false;
//                }
//            } else {// Auto read multi  .startInventoryTag((byte) 0, (byte) 0))
//                //  mContext.mReader.setEPCTIDMode(true);
//                if (mReader.startInventoryTag()) {
//                    isStart = true;
//                    new TagThread().start();
//                    return true;
//                } else {
//                    return false;
//                }
//            }
//        }
//        return true;
//    }
public boolean start(boolean isSingleRead) {
    if (!isStart) {
        if (isSingleRead) {// Single Read
            UHFTAGInfo strUII = mReader.inventorySingleTag();
            if (strUII != null) {
                String strEPC = strUII.getEPC();
                addEPCToList(strEPC, strUII.getRssi());
                return true;
            } else {
                return false;
            }
        } else {// Auto read multi  .startInventoryTag((byte) 0, (byte) 0))
            //  mContext.mReader.setEPCTIDMode(true);
            if (mReader.startInventoryTag()) {
                isStart = true;
                new TagThread().start();
                return true;
            } else {
                return false;
            }
        }
    }
    return true;
}


    public void clearData() {
        tagList.clear();
    }

    public boolean stop() {
        if (isStart && mReader != null) {
            isStart = false;
            return mReader.stopInventory();
        }
        isStart = false;
        clearData();
        return false;
    }

    public void close() {
        isStart = false;
        if (mReader != null) {
            mReader.free();
            isConnect = false;
        }
        clearData();
    }
    public boolean setPowerLevel(String level) {
        //5 dBm : 30 dBm
        if (mReader != null) {
            return mReader.setPower(Integer.parseInt(level));
        }
        return false;
    }

    public boolean setWorkArea(String area) {
        //China Area 920~925MHz
        //Chin2a Area 840~845MHz
        //ETSI Area 865~868MHz
        //Fixed Area 915MHz
        //United States Area 902~928MHz
        //{ "1", "2" 4", "8", "22", "50", "51", "52", "128"}
        if (mReader != null)
            return mReader.setFrequencyMode(Integer.parseInt(area));
        return false;
    }
//
//    private void addEPCToList(String epc, String rssi) {
//        if (!TextUtils.isEmpty(epc)) {
//            EPC tag = new EPC();
//
////            tag.setId("");
//            tag.setEpc(epc);
////            tag.setCount(String.valueOf(1));
////            tag.setRssi(rssi);
//
//            if (tagList.containsKey(epc)) {
//                int tagCount = Integer.parseInt(Objects.requireNonNull(tagList.get(epc)).getCount()) + 1;
//                tag.setCount(String.valueOf(tagCount));
//            }
//            tagList.put(epc, tag);
//
//            final JSONArray jsonArray = new JSONArray();
//
//            for (EPC epcTag : tagList.values()) {
//                JSONObject json = new JSONObject();
//                try {
////                    json.put(TagKey.ID, Objects.requireNonNull(epcTag).getId());
//                    json.put(TagKey.EPC, epcTag.getEpc());
////                    json.put(TagKey.RSSI, epcTag.getRssi());
////                    json.put(TagKey.COUNT, epcTag.getCount());
//                    jsonArray.put(json);
//                } catch (JSONException e) {
//                    e.printStackTrace();
//                }
//
//            }
//            uhfListener.onRead(jsonArray.toString());
//
//        }
//    }
//đang sài
private List<String> processedTags = new ArrayList<>();
    public UHFHelper() {
        processedTags = new ArrayList<>();
    }


    public UHFHelper(Context context) {
        this.context = context;

    }
    private static final int BATCH_SIZE = 1;
    private int totalTags = 0;
    private int TagCount = 0;

//    private void addEPCToList(String epc, String rssi) {
//        if (!TextUtils.isEmpty(epc)) {
//            synchronized (this) {
//                EPC tag = tagList.get(epc);
//                if (tag == null) {
//                    tag = new EPC();
//                    tag.setEpc(epc);
//                    tag.setCount(String.valueOf(0)); // Khởi tạo count bằng 0
//                    tagList.put(epc, tag);
//                }
//                // Kiểm tra xem thẻ đã tồn tại trong danh sách phụ trước khi xóa
//                if (!processedTags.contains(epc)) {
//                    int tagCount = Integer.parseInt(tag.getCount()) + 1;
//                    tag.setCount(String.valueOf(tagCount));
//
//                    processedTags.add(epc); // Thêm thẻ vào danh sách phụ
//
//                    totalTags++;
//
//                    if (totalTags >= BATCH_SIZE) {
//                        processBatch();
//                        totalTags = 0;
//                    }
//                } else {
//                    // Nếu thẻ đã tồn tại trong danh sách phụ, không thực hiện bất kỳ thao tác nào
//                }
//            }
//        }
//    }
//
//    private void processBatch() {
//        final JSONArray jsonArray = new JSONArray();
//        synchronized (this) {
//            for (String epc : processedTags) {
//                EPC epcTag = tagList.get(epc);
//                if (epcTag != null) {
//                    JSONObject json = new JSONObject();
//                    try {
//                        json.put(TagKey.ID, Objects.requireNonNull(epcTag).getId());
//                        json.put(TagKey.EPC, epcTag.getEpc());
//                        json.put(TagKey.RSSI, epcTag.getRssi());
//                        jsonArray.put(json);
//                    } catch (JSONException e) {
//                        e.printStackTrace();
//                    }
//                }
//            }
//            processedTags.clear(); // Xóa danh sách phụ sau khi xử lý xong một lô
//        }
//
//        if (jsonArray.length() > 0 && uhfListener != null) {
//            uhfListener.onRead(jsonArray.toString());
//        }
//    }
//private void addEPCToList(String epc, String rssi) {
//    if (!TextUtils.isEmpty(epc)) {
//        EPC tag = new EPC();
//        tag.setId("");
//        tag.setEpc(epc);
//        tag.setCount("1");
//        tag.setRssi(rssi);
//
//        // Kiểm tra nếu danh sách tag đã chứa epc này thì tăng số lần đếm lên 1
//        if (tagList.containsKey(epc)) {
//            int tagCount = Integer.parseInt(tagList.get(epc).getCount()) + 1;
//            tag.setCount(String.valueOf(tagCount));
//        }
//
//        tagList.put(epc, tag);
//
//        // Xây dựng chuỗi JSON bằng StringBuilder
//        StringBuilder jsonBuilder = new StringBuilder();
//        jsonBuilder.append("[");
//
//        for (EPC epcTag : tagList.values()) {
//            if (epcTag != null) {
//                jsonBuilder.append("{");
//                jsonBuilder.append("\"").append(TagKey.ID).append("\": \"").append(epcTag.getId()).append("\", ");
//                jsonBuilder.append("\"").append(TagKey.EPC).append("\": \"").append(epcTag.getEpc()).append("\", ");
//                jsonBuilder.append("\"").append(TagKey.RSSI).append("\": \"").append(epcTag.getRssi()).append("\", ");
//                jsonBuilder.append("\"").append(TagKey.COUNT).append("\": \"").append(epcTag.getCount()).append("\"");
//                jsonBuilder.append("},");
//            }
//        }
//
//        // Loại bỏ dấu phẩy cuối cùng nếu có
//        if (jsonBuilder.charAt(jsonBuilder.length() - 1) == ',') {
//            jsonBuilder.deleteCharAt(jsonBuilder.length() - 1);
//        }
//
//        jsonBuilder.append("]");
//
//        uhfListener.onRead(jsonBuilder.toString());
//    }
//}
//sử dụng
//    private void addEPCToList(String epc, String rssi) {
//        if (!TextUtils.isEmpty(epc)) {
//            EPC tag = new EPC();
//
//            tag.setId("");
//            tag.setEpc(epc);
//            tag.setCount(String.valueOf(1));
//            tag.setRssi(rssi);
//
//            if (tagList.containsKey(epc)) {
//                int tagCount = Integer.parseInt(Objects.requireNonNull(tagList.get(epc)).getCount()) + 1;
//                tag.setCount(String.valueOf(tagCount));
//            }
//            tagList.put(epc, tag);
//
//            final JSONArray jsonArray = new JSONArray();
//
//            for (EPC epcTag : tagList.values()) {
//                JSONObject json = new JSONObject();
//                try {
//                    json.put(TagKey.ID, Objects.requireNonNull(epcTag).getId());
//                    json.put(TagKey.EPC, epcTag.getEpc());
//                    json.put(TagKey.RSSI, epcTag.getRssi());
//                    json.put(TagKey.COUNT, epcTag.getCount());
//                    jsonArray.put(json);
//                } catch (JSONException e) {
//                    e.printStackTrace();
//                }
//
//            }
//            uhfListener.onRead(jsonArray.toString());
//
//        }
//    }

//
//
    private void addEPCToList(String epc, String rssi) {
        if (!TextUtils.isEmpty(epc)) {
            synchronized (this) {
                EPC tag = new EPC();
                tag.setId("");
                tag.setEpc(epc);
                tag.setCount(String.valueOf(1));
                tag.setRssi(rssi);

//                EPC existingTag = tagList.get(epc);
//                if (existingTag != null) {
//                    int tagCount = Integer.parseInt(existingTag.getCount()) + 1;
//                    tag.setCount(String.valueOf(tagCount));
//                }

//                if (tagList.containsKey(epc)) {
//                    int tagCount = Integer.parseInt(Objects.requireNonNull(tagList.get(epc)).getCount()) + 1;
//                    tag.setCount(String.valueOf(tagCount));
//                }
                tagList.put(epc, tag);
//
//                try {
//                    DatabaseManager.getInstance(context).addTagToDatabase(tag.getEpc(), tag.getRssi());
//
//
//                } catch (Exception e) {
//                    e.printStackTrace();
//                }

                totalTags++;

//                System.out.println("Total Tags: " + totalTags);

                if (totalTags >= BATCH_SIZE) {
                    processBatch();
                    totalTags = 0;
//                    totalTags++;


                }
//                TagCount = tagList.size();
            }
        }
    }

    private void processBatch() {
        final JSONArray jsonArray = new JSONArray();
        synchronized (this) {
            for (EPC epcTag : tagList.values()) {
                JSONObject json = new JSONObject();
                try {
                    json.put(TagKey.ID, Objects.requireNonNull(epcTag).getId());
                    json.put(TagKey.EPC, epcTag.getEpc());
                    json.put(TagKey.RSSI, epcTag.getRssi());
//                     json.put(TagKey.COUNT, epcTag.getCount());
                    jsonArray.put(json);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }

        if (jsonArray.length() > 0 && uhfListener != null) {
            uhfListener.onRead(jsonArray.toString());
        }
        tagList.clear();

    }

//
//    private void addEPCToList(String epc, String rssi) {
//        if (!TextUtils.isEmpty(epc)) {
//            EPC tag = new EPC();
//            tag.setId("");
//            tag.setEpc(epc);
//            tag.setCount(String.valueOf(1));
//            tag.setRssi(rssi);
//
//            if (tagList.containsKey(epc)) {
//                int tagCount = Integer.parseInt(Objects.requireNonNull(tagList.get(epc)).getCount()) + 1;
//                tag.setCount(String.valueOf(tagCount));
//            }
//            tagList.put(epc, tag);
//            try {
//                    DatabaseManager.getInstance(context).addTagToDatabase(tag.getEpc(), tag.getRssi());
//
//
//                } catch (Exception e) {
//                    e.printStackTrace();
//                }
//
//            final JSONArray jsonArray = new JSONArray();
//
//            for (EPC epcTag : tagList.values()) {
//                JSONObject json = new JSONObject();
//                try {
//                    json.put(TagKey.ID, Objects.requireNonNull(epcTag).getId());
//                    json.put(TagKey.EPC, epcTag.getEpc());
//                    json.put(TagKey.RSSI, epcTag.getRssi());
//                    json.put(TagKey.COUNT, epcTag.getCount());
//                    jsonArray.put(json);
//                } catch (JSONException e) {
//                    e.printStackTrace();
//                }
//
//            }
//            uhfListener.onRead(jsonArray.toString());
//
//        }
//    }

//    /Test

//    private Set<String> uniqueEpcs = new HashSet<>();
//    private void addEPCToList(String epc, String rssi) {
//        if (!TextUtils.isEmpty(epc)) {
//            synchronized (this) {
//                if (!uniqueEpcs.contains(epc)) {
//                    uniqueEpcs.add(epc);
//
//                    EPC tag = new EPC();
//                    tag.setId("");
//                    tag.setEpc(epc);
//                    tag.setCount(String.valueOf(1));
//                    tag.setRssi(rssi);
//
//                    final JSONArray jsonArray = new JSONArray();
//                    JSONObject json = new JSONObject();
//                    try {
//                        json.put(TagKey.ID, tag.getId());
//                        json.put(TagKey.EPC, tag.getEpc());
//                        json.put(TagKey.RSSI, tag.getRssi());
//                        json.put(TagKey.COUNT, tag.getCount());
//                        jsonArray.put(json);
//                    } catch (JSONException e) {
//                        e.printStackTrace();
//                    }
//
//                    uhfListener.onRead(jsonArray.toString());
//                }
////                uniqueEpcs.clear();
//            }
//        }
//    }


    public boolean isEmptyTags() {
        return tagList != null && !tagList.isEmpty();
    }

    public boolean isStarted() {
        return isStart;
    }

    public boolean isConnected() {
        return isConnect;
    }

    public boolean closeScan() {
        if (barcodeDecoder != null) {
            barcodeDecoder.close();
        }
        return true;
    }

    class TagThread extends Thread {
        public void run() {
            String strTid;
            String strResult;
            UHFTAGInfo res = null;
            while (isStart) {
                res = mReader.readTagFromBuffer();
                if (res != null) {
                    strTid = res.getTid();
                    if (strTid.length() != 0 && !strTid.equals("0000000" +
                            "000000000") && !strTid.equals("000000000000000000000000")) {
                        strResult = "TID:" + strTid + "\n";
                    } else {
                        strResult = "";
                    }
//                    Log.i("dataaaaaa", "c" + res.getEPC() + "|" + strResult);
                    Message msg = handler.obtainMessage();
//                    msg.obj = strResult + "EPC:" + res.getEPC() + "@" + res.getRssi();
                    msg.obj = strResult + res.getEPC() + "@" + res.getRssi();


                    handler.sendMessage(msg);
                }
            }
        }
    }

}
