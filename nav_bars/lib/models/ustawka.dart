class Ustawka {
  final String? id;
  final String initiatorClub;
  final String targetClub;
  final String arenaName;
  final double? arenaLat;
  final double? arenaLng;
  final String? weatherInfo;
  final DateTime battleDate;
  final Map<String, dynamic> rulesJson;
  final String status;
  final String? winner;
  final DateTime? createdAt;

  Ustawka({
    this.id,
    required this.initiatorClub,
    required this.targetClub,
    required this.arenaName,
    this.arenaLat,
    this.arenaLng,
    this.weatherInfo,
    required this.battleDate,
    this.rulesJson = const {},
    this.status = 'pending',
    this.winner,
    this.createdAt,
  });

  factory Ustawka.fromMap(Map<String, dynamic> json) {
    return Ustawka(
      id: json['id'] as String?,
      initiatorClub: json['initiator_club'] as String,
      targetClub: json['target_club'] as String,
      arenaName: json['arena_name'] as String,
      arenaLat: (json['arena_lat'] as num?)?.toDouble(),
      arenaLng: (json['arena_lng'] as num?)?.toDouble(),
      weatherInfo: json['weather_info'] as String?,
      battleDate: DateTime.parse(json['battle_date'] as String),
      rulesJson: json['rules_json'] as Map<String, dynamic>? ?? {},
      status: json['status'] as String? ?? 'pending',
      winner: json['winner'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'initiator_club': initiatorClub,
      'target_club': targetClub,
      'arena_name': arenaName,
      if (arenaLat != null) 'arena_lat': arenaLat,
      if (arenaLng != null) 'arena_lng': arenaLng,
      if (weatherInfo != null) 'weather_info': weatherInfo,
      'battle_date': battleDate.toIso8601String(),
      'rules_json': rulesJson,
      'status': status,
      if (winner != null) 'winner': winner,
    };
  }
}

