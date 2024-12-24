import 'package:just_audio/just_audio.dart';
import 'dart:async';


class CommonFunction{
  // AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer audioPlayer = AudioPlayer();

  String hexToString(String hex) {
    String result = '';
    for (int i = 0; i < hex.length; i += 2) {
      String part = hex.substring(i, i + 2);
      int charCode = int.parse(part, radix: 16);
      result += String.fromCharCode(charCode);
    }
    return result;
  }

  // Future<void> playScanSound() async {
  //   try {
  //     await audioPlayer.play(AssetSource('sound/Bip.mp3')); // Dùng AssetSource để phát âm thanh từ asset
  //   } catch (e) {
  //     print("$e");
  //   }
  // }
}