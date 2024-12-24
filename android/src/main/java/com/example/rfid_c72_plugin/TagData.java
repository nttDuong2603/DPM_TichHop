public class TagData {
    private String epc;
    private String rssi;
    private long timestamp;

    public TagData(String epc, String rssi, long timestamp) {
        this.epc = epc;
        this.rssi = rssi;
        this.timestamp = timestamp;
    }

    public String getEpc() {
        return epc;
    }

    public void setEpc(String epc) {
        this.epc = epc;
    }

    public String getRssi() {
        return rssi;
    }

    public void setRssi(String rssi) {
        this.rssi = rssi;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }
}
