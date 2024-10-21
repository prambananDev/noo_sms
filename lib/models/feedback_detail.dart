class FeedbackDetail {
  final int? feedbackId;
  final String? feedbackName;
  final String? notes;

  FeedbackDetail({
    required this.feedbackId,
    required this.feedbackName,
    required this.notes,
  });

  factory FeedbackDetail.fromJson(Map<String, dynamic> json) {
    return FeedbackDetail(
      feedbackId: json['feedbackId'] as int?,
      feedbackName: json['feedbackName'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
}
