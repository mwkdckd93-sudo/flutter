/// Question & Answer Model for Auction
class QuestionModel {
  final String id;
  final String? auctionId;
  final String? askerId;
  final String? askerName;
  final String? askerAvatar;
  final String question;
  final String? answer;
  final DateTime createdAt;
  final DateTime? answeredAt;

  const QuestionModel({
    required this.id,
    this.auctionId,
    this.askerId,
    this.askerName,
    this.askerAvatar,
    required this.question,
    this.answer,
    required this.createdAt,
    this.answeredAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      auctionId: json['auctionId']?.toString(),
      askerId: json['askerId']?.toString(),
      askerName: json['askerName']?.toString(),
      askerAvatar: json['askerAvatar']?.toString(),
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      answeredAt: json['answeredAt'] != null
          ? DateTime.tryParse(json['answeredAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auctionId': auctionId,
      'askerId': askerId,
      'askerName': askerName,
      'askerAvatar': askerAvatar,
      'question': question,
      'answer': answer,
      'createdAt': createdAt.toIso8601String(),
      'answeredAt': answeredAt?.toIso8601String(),
    };
  }

  bool get isAnswered => answer != null && answer!.isNotEmpty;
}
