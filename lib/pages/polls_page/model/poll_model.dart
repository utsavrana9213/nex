class PollModel {
  final String id;
  final String question;
  final List<String> options;
  final List<int> votes;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String createdBy;

  const PollModel({
    required this.id,
    required this.question,
    required this.options,
    required this.votes,
    required this.createdAt,
    required this.expiresAt,
    this.createdBy = '',
  });

  int get totalVotes => votes.fold(0, (sum, v) => sum + v);
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory PollModel.fromMap(String id, Map<String, dynamic> map) {
    return PollModel(
      id: id,
      question: (map['question'] ?? '') as String,
      options: List<String>.from(map['options'] ?? const <String>[]),
      votes: List<int>.from(map['votes'] ?? const <int>[]),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (map['createdAt'] ?? 0) is int ? map['createdAt'] : 0),
      expiresAt: (map['expiresAt'] is int && map['expiresAt'] > 0)
          ? DateTime.fromMillisecondsSinceEpoch(map['expiresAt'])
          : null,
      createdBy: (map['createdBy'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'votes': votes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
      'createdBy': createdBy,
    };
  }
}


