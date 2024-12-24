package com.example.rfid_c72_plugin_example.fragment;
import java.util.ArrayList;
import java.util.HashMap;
public interface EventListener {
    void onEventOccurred(ArrayList<HashMap<String, String>> data);
}
