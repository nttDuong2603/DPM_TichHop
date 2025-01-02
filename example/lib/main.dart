import 'package:flutter/material.dart';
import 'DevicesConfiguration/chainway_R5_RFID/uhfManager.dart';
import 'Home/login_database.dart';
import 'UserDatatypes/user_datatype.dart';
// import 'barcode_test.dart';

// Step 1: Define a global variable
final UHFBlePlugin = UHFManager() ;
Device currentDevice =  Device.rSeries;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      // home: RfidScanner(),
    );
  }
}




