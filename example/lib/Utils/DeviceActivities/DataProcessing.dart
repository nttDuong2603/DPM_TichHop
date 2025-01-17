import 'dart:collection';
import 'dart:ui';

import '../../Assign_Packing_Information/model_information_package.dart';
import '../../Models/model.dart';

class DataProcessing {
  static void ProcessData(List<TagEpc> inputData, List<TagEpc> outputData,VoidCallback playSound) {
    List<TagEpc> uniqueData = inputData
        .where((newTag) =>
            !outputData.any((existingTag) => existingTag.epc == newTag.epc))
        .toList(); // Find all tags that are not in the output list
    if(uniqueData.isNotEmpty){
      playSound();
    }
    outputData.addAll(uniqueData); // Add all unique tags to the output list
  }

  static void ProcessDataLDB(
      List<TagEpcLDB> newData,
      List<TagEpcLDB> currentTags,
      List<TagEpcLDB> outputData,
      void Function() playScanSound) {
    // Tìm các thẻ duy nhất (không có trong currentTags và outputData)
    List<TagEpcLDB> uniqueData = newData.where((newTag) =>
    !currentTags.any((savedTag) => savedTag.epc == newTag.epc) &&
        !outputData.any((existingTag) => existingTag.epc == newTag.epc)).toList();

    // Cập nhật thời gian quét cho từng thẻ
    uniqueData.forEach((tag) {
      tag.scanDate = DateTime.now();
    });

    // Nếu tìm thấy thẻ mới, phát âm thanh
    if (uniqueData.isNotEmpty) {
      playScanSound();
    }

    // Thêm các thẻ mới vào danh sách outputData
    outputData.addAll(uniqueData);
  }

  static void ProcessDataQueue(List<TagEpc> newData, List<TagEpc> data,
      Queue<TagEpc> tagsToProcess, VoidCallback processNextTag) {
    // Lọc dữ liệu duy nhất
    List<TagEpc> uniqueData = newData
        .where((newTag) =>
    !data.any((existingTag) => existingTag.epc == newTag.epc))
        .toList();

    if (uniqueData.isNotEmpty) {
      tagsToProcess.addAll(uniqueData); // Thêm vào hàng đợi
      processNextTag(); // Tiếp tục xử lý
    }
  }

  static List<TagEpc> ConvertToTagEpcList(List<Map<String, String>> data) {
    return data.map((tag) {
      return TagEpc(
        epc: tag['tagEpc'] ?? '',
        // Nếu `tag['tagEpc']` null, sử dụng chuỗi rỗng
        count: tag['tagCount'],
        user: tag['tagUser'],
        rssi: tag['tagRssi'],
        tid: tag['tagTid'],
      );
    }).toList();
  }

  static List<TagEpcLDB> ConvertToTagEpcLDBList(
      List<Map<String, String>> data) {
    return data.map((tag) {
      return TagEpcLDB(
        epc: tag['tagEpc'] ?? '',
        // Nếu `tag['tagEpc']` null, sử dụng chuỗi rỗng
        count: tag['tagCount'],
        user: tag['tagUser'],
        rssi: tag['tagRssi'],
        tid: tag['tagTid'],
      );
    }).toList();
  }

}
