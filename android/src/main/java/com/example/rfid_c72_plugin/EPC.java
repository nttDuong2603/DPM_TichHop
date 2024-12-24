package com.example.rfid_c72_plugin;

public class EPC {
    private String count;
    private String epc;
    private String id;
    private String rssi;

    private boolean isFind;

    public boolean isFind() {
        return this.isFind;
    }

    public void setFind(boolean isFind2) {
        this.isFind = isFind2;
    }

    public String getId() {
        return this.id;
    }

    public void setId(String id2) {
        this.id = id2;
    }

    public String getEpc() {
        return this.epc;
    }

    public void setEpc(String epc2) {
        this.epc = epc2;
    }

    public String getCount() {
        return this.count;
    }

    public void setCount(String count2) {
        this.count = count2;
    }

    public String getRssi() {
        return this.rssi;
    }

    public void setRssi(String rssi2) {
        this.rssi = rssi2;
    }

    public String toString() {
        return "EPC [id=" + this.id + ", epc=" + this.epc + ", count=" + this.count + "]";
    }
}


//
//    public UHFHelper(Context context) {
//        this.context = context;
//    }
//    private static final int BATCH_SIZE = 1;
//    private int totalTags = 0;
////    private int TagCount = 0;
//
//
//    private void addEPCToList(String epc, String rssi) {
//        if (!TextUtils.isEmpty(epc)) {
//            synchronized (this) {
//                EPC tag = new EPC();
//                tag.setId("");
//                tag.setEpc(epc);
//                tag.setCount(String.valueOf(1));
//                tag.setRssi(rssi);
//
////                EPC existingTag = tagList.get(epc);
////                if (existingTag != null) {
////                    int tagCount = Integer.parseInt(existingTag.getCount()) + 1;
////                    tag.setCount(String.valueOf(tagCount));
////                }
//
//                if (tagList.containsKey(epc)) {
//                    int tagCount = Integer.parseInt(Objects.requireNonNull(tagList.get(epc)).getCount()) + 1;
//                    tag.setCount(String.valueOf(tagCount));
//                }
//                tagList.put(epc, tag);
////
////                try {
////                    DatabaseManager.getInstance(context).addTagToDatabase(tag.getEpc(), tag.getRssi());
////
////
////                } catch (Exception e) {
////                    e.printStackTrace();
////                }
//
//                totalTags++;
//
//                System.out.println("Total Tags: " + totalTags);
//
//                if (totalTags >= BATCH_SIZE) {
//                    processBatch();
//                    totalTags = 0;
////                    totalTags++;
//
//
//                }
////                TagCount = tagList.size();
//            }
//        }
//    }
//
//    private void processBatch() {
//        final JSONArray jsonArray = new JSONArray();
//        synchronized (this) {
//            for (EPC epcTag : tagList.values()) {
//                JSONObject json = new JSONObject();
//                try {
//                    json.put(TagKey.ID, Objects.requireNonNull(epcTag).getId());
//                    json.put(TagKey.EPC, epcTag.getEpc());
//                    json.put(TagKey.RSSI, epcTag.getRssi());
////                     json.put(TagKey.COUNT, epcTag.getCount());
//                    jsonArray.put(json);
//                } catch (JSONException e) {
//                    e.printStackTrace();
//                }
//            }
//        }
//
//        if (jsonArray.length() > 0 && uhfListener != null) {
//            uhfListener.onRead(jsonArray.toString());
//        }
////        tagList.clear();
//
//    }
//
////
////    private void addEPCToList(String epc, String rssi) {
////        if (!TextUtils.isEmpty(epc)) {
////            EPC tag = new EPC();
////            tag.setId("");
////            tag.setEpc(epc);
////            tag.setCount(String.valueOf(1));
////            tag.setRssi(rssi);
////
////            if (tagList.containsKey(epc)) {
////                int tagCount = Integer.parseInt(Objects.requireNonNull(tagList.get(epc)).getCount()) + 1;
////                tag.setCount(String.valueOf(tagCount));
////            }
////            tagList.put(epc, tag);
////            try {
////                    DatabaseManager.getInstance(context).addTagToDatabase(tag.getEpc(), tag.getRssi());
////
////
////                } catch (Exception e) {
////                    e.printStackTrace();
////                }
////
////            final JSONArray jsonArray = new JSONArray();
////
////            for (EPC epcTag : tagList.values()) {
////                JSONObject json = new JSONObject();
////                try {
////                    json.put(TagKey.ID, Objects.requireNonNull(epcTag).getId());
////                    json.put(TagKey.EPC, epcTag.getEpc());
////                    json.put(TagKey.RSSI, epcTag.getRssi());
////                    json.put(TagKey.COUNT, epcTag.getCount());
////                    jsonArray.put(json);
////                } catch (JSONException e) {
////                    e.printStackTrace();
////                }
////
////            }
////            uhfListener.onRead(jsonArray.toString());
////
////        }
////    }