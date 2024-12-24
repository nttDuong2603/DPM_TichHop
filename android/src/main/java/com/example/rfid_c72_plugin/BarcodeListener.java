package com.example.rfid_c72_plugin;

public abstract class BarcodeListener {
    abstract void onBarcodeScanned(String barcodeData);
}
