import 'dart:collection';
import 'dart:ui';

import '../../Assign_Packing_Information/model_information_package.dart';
import '../../Distribution_Module/model.dart';

class DataProcessing {
  static void ProcessData(List<TagEpc> inputData, List<TagEpc> outputData) {
    List<TagEpc> uniqueData = inputData
        .where((newTag) =>
            !outputData.any((existingTag) => existingTag.epc == newTag.epc))
        .toList(); // Find all tags that are not in the output list
    outputData.addAll(uniqueData); // Add all unique tags to the output list
  }

  static void ProcessDataLDB(
      List<TagEpcLDB> inputData, List<TagEpcLDB> outputData) {
    List<TagEpcLDB> uniqueData = inputData
        .where((newTag) =>
            !outputData.any((existingTag) => existingTag.epc == newTag.epc))
        .toList(); // Find all tags that are not in the output list
    uniqueData.forEach((tag) {
      tag.scanDate = DateTime.now(); // Gán thời gian quét cho thẻ
    });
    outputData.addAll(uniqueData); // Add all unique tags to the output list
  }

  static void ProcessDataQueue_OLD(List<TagEpc> newData, List<TagEpc> data,
      Queue<TagEpc> tagsToProcess, VoidCallback processNextTag) {
    List<TagEpc> uniqueData = newData
        .where((newTag) =>
            !data.any((existingTag) => existingTag.epc == newTag.epc))
        .toList();
    if (uniqueData.isNotEmpty) {
      //_playScanSound();
      tagsToProcess.addAll(uniqueData); // Thêm tất cả nhãn duy nhất vào queue
      processNextTag(); // Bắt đầu xử lý từ nhãn đầu tiên
    }
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
