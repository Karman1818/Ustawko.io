class Arena {
  final String name;
  final double lat;
  final double lng;
  final String weatherReport;
  final double temperature;

  Arena({
    required this.name,
    required this.lat,
    required this.lng,
    required this.weatherReport,
    required this.temperature,
  });

  factory Arena.fromJson(Map<String, dynamic> json) {
    return Arena(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      weatherReport: json['weather_report'] as String,
      temperature: (json['temperature'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
      'weather_report': weatherReport,
      'temperature': temperature,
    };
  }
}
