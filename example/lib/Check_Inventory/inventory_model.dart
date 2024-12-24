class EventDetail {
  final int deletedTagsCount;
  final int remainingTagsCount;
  final DateTime scanDate;

  EventDetail({
    required this.deletedTagsCount,
    required this.remainingTagsCount,
    required this.scanDate,
  });

  Map<String, dynamic> toJson() => {
    'deletedTagsCount': deletedTagsCount,
    'remainingTagsCount': remainingTagsCount,
    'scanDate': scanDate.toIso8601String(),
  };

  static EventDetail fromJson(Map<String, dynamic> json) => EventDetail(
    deletedTagsCount: json['deletedTagsCount'],
    remainingTagsCount: json['remainingTagsCount'],
    scanDate: DateTime.parse(json['scanDate']),
  );
}