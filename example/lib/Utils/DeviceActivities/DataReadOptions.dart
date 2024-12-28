import 'package:rfid_c72_plugin/rfid_c72_plugin.dart';

import '../../UserDatatypes/user_datatype.dart';
import '../../main.dart';

class DataReadOptions {
  static Future<void> readTagsAsync(bool isStart,Device device) async {
    switch(device){
      case Device.C_Series:
        if(isStart){
          await RfidC72Plugin.startContinuous;

        } else{
          await RfidC72Plugin.stop;
        }
        break;
      case Device.R_Series:
        if(isStart){
          print("bat dau doc R5");
          await UHFBlePlugin.manualRead(true);
        } else{
          await UHFBlePlugin.manualRead(false);
        }
        break;
      default:
        break;
    }
  }
}