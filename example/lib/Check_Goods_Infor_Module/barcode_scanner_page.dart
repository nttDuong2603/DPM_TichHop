import 'package:flutter/material.dart';

class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  void _showDeviceSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Device to Scan Barcode",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text("Camera"),
                subtitle: const Text("Use your device's camera to scan a barcode."),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  print("Camera Selected");
                  // Navigate or call the camera scanner logic here
                },
              ),
              ListTile(
                leading: const Icon(Icons.usb, color: Colors.green),
                title: const Text("External Device"),
                subtitle: const Text("Use an external device to scan a barcode."),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  print("External Device Selected");
                  // Navigate or call the external device scanner logic here
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the modal
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode Scanner"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showDeviceSelectionModal(context),
          child: const Text("Select Scanner Device"),
        ),
      ),
    );
  }
}
