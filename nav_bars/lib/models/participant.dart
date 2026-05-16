class Participant {
  final String? id;
  final String ustawkaId;
  final String userId;
  final String userClub;
  final DateTime? createdAt;

  Participant({
    this.id,
    required this.ustawkaId,
    required this.userId,
    required this.userClub,
    this.createdAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as String?,
      ustawkaId: json['ustawka_id'] as String,
      userId: json['user_id'] as String,
      userClub: json['user_club'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ustawka_id': ustawkaId,
      'user_id': userId,
      'user_club': userClub,
    };
  }
}
