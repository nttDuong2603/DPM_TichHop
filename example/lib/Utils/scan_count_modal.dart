import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class SavedTagsModal extends StatefulWidget {
  final Stream<int> updateStream; // Stream để nhận các sự kiện cập nhật

  const SavedTagsModal({Key? key, required this.updateStream}) : super(key: key);

  @override
  _SavedTagsModalState createState() => _SavedTagsModalState();
}

class _SavedTagsModalState extends State<SavedTagsModal> {
  int savedTagsCount = 0;
  late Timer _timer;
  bool _isBlue = true;
  int _elapsedTime = 0;


  @override
  void initState() {
    super.initState();
    // Đăng ký lắng nghe Stream để nhận giá trị mới của successfullySaved
    widget.updateStream.listen((newValue) {
      // Kiểm tra xem widget có được mount không trước khi gọi setState
      if (mounted) {
        setState(() {
          savedTagsCount = newValue; // Cập nhật giá trị savedTagsCount khi nhận được giá trị mới của successfullySaved
        });
      }
    });
    _startTimer();
  }



  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { // Đổi thành đếm mỗi giây
      setState(() {
        _isBlue = !_isBlue;
        _elapsedTime++; // Tăng thời gian đã trôi qua
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Container(

        child: Column( // Sắp xếp các widget theo cột
          mainAxisAlignment: MainAxisAlignment.center, // Canh giữa theo chiều dọc
          children: [
            Text(
              'Đang quét...',
              style: TextStyle(
                // color: Colors.lightBlueAccent,
                color: _isBlue ? Colors.white : Colors.lightBlue[200], // Thay đổi màu sắc dựa vào biến _isBlue
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$savedTagsCount',
              style: const TextStyle(
                color: Color(0xFF1C88FF),
                fontSize: 104,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Tạo khoảng cách giữa các widget
            Text(
              'Thời gian: $_elapsedTime giây', // Hiển thị thời gian
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      );
  }
}