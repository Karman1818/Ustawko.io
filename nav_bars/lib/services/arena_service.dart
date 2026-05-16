import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/arena.dart';

class ArenaService {
  final Random _random = Random();

  final List<String> _overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  Future<Arena> generateRandomArena() async {
    Map<String, dynamic>? arenaData;
    String? lastError;

    for (var endpoint in _overpassEndpoints) {
      try {
        arenaData = await _fetchFromOverpass(endpoint);
        if (arenaData != null) break; 
      } catch (e) {
        lastError = e.toString();
        debugPrint('Mirror $endpoint zawiódł: $e');
      }
    }

    if (arenaData == null) {
      return Arena(
        name: "RADAR ZAKŁÓCONY: ${lastError ?? 'Błąd połączenia'}",
        lat: 52.23,
        lng: 21.01,
        temperature: 0,
        weatherReport: "System nie mógł połączyć się z satelitą. Spróbuj za chwilę.",
      );
    }

    final double lat = arenaData['lat'];
    final double lng = arenaData['lng'];

    // Pobieramy najbliższą miejscowość z Multi-Mirror
    String? townName = await _getNearestTownName(lat, lng);
    String displayName;
    
    if (townName != null) {
      displayName = townName.toUpperCase();
    } else {
      // Fallback: Jeśli nie ma miasta, dajemy śmieszną nazwę, żeby nie było nudno
      final adjectives = [
        'MROCZNE', 'HONOROWE', 'KRWAWE', 'DZIKIE', 'TAJNE', 
        'ZAPLUTE', 'ŚMIERDZĄCE', 'AGRESYWNE', 'PATOLOGICZNE',
        'ZASZCANE', 'PIJANE', 'WŚCIEKŁE', 'ZABŁOCONE', 'SZLACHECKIE'
      ];
      displayName = '${adjectives[_random.nextInt(adjectives.length)]} UROCZYSKO';
    }

    final weather = await _fetchWeather(lat, lng);

    return Arena(
      name: "$displayName [${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}]",
      lat: lat,
      lng: lng,
      temperature: weather['temp'],
      weatherReport: _generateBattleReport(weather['temp'], weather['code']),
    );
  }

  Future<Map<String, dynamic>?> _fetchFromOverpass(String endpoint) async {
    final double searchLat = 49.5 + _random.nextDouble() * 4.5;
    final double searchLng = 14.5 + _random.nextDouble() * 8.5;
    
    final String query = '''
[out:json][timeout:60];
//seed: ${_random.nextInt(1000000)}
(
  nwr["landuse"="forest"](around:60000,$searchLat,$searchLng);
  nwr["natural"="wood"](around:60000,$searchLat,$searchLng);
);
out center 100;
''';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'User-Agent': 'UstawkaIO/1.0',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'data': query},
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final List elements = data['elements'] ?? [];
    if (elements.isEmpty) return null;

    final element = elements[_random.nextInt(elements.length)];
    double eLat;
    double eLon;

    if (element['center'] != null) {
      eLat = (element['center']['lat'] as num).toDouble();
      eLon = (element['center']['lon'] as num).toDouble();
    } else if (element['lat'] != null) {
      eLat = (element['lat'] as num).toDouble();
      eLon = (element['lat'] as num).toDouble();
    } else {
      return null;
    }
    
    return {'lat': eLat, 'lng': eLon};
  }

  Future<String?> _getNearestTownName(double lat, double lng) async {
    final query = '[out:json][timeout:15];nwr[place~"city|town|village"](around:50000,$lat,$lng);out center 1;';
    
    for (var endpoint in _overpassEndpoints) {
      try {
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {
            'User-Agent': 'UstawkaIO/1.0',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'data': query},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List elements = data['elements'] ?? [];
          if (elements.isNotEmpty) {
            return elements[0]['tags']?['name'];
          }
        }
      } catch (e) {
        debugPrint('Mirror $endpoint zawiódł przy szukaniu miasta: $e');
        continue;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _fetchWeather(double lat, double lng) async {
    try {
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current_weather=true';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'temp': (data['current_weather']['temperature'] as num).toDouble(),
          'code': data['current_weather']['weathercode'] as int,
        };
      }
    } catch (e) {
      debugPrint('Błąd pogody: $e');
    }
    return {'temp': 15.0, 'code': 0};
  }

  String _generateBattleReport(double temp, int code) {
    String baseDesc = 'Pogoda niepewna. Gotowość na wszystko!';
    if (code == 0) {
      baseDesc = 'Czyste niebo. Żadnych wymówek dla słabej widoczności.';
    } else if (code >= 1 && code <= 3) {
      baseDesc = 'Lekkie zachmurzenie. Słońce nie będzie razić w oczy przy ciosach.';
    } else if (code == 45 || code == 48) {
      baseDesc = 'Gęsta mgła. Idealne warunki na taktyczną partyzantkę w krzakach.';
    } else if (code >= 51 && code <= 67) {
      baseDesc = 'Pada deszcz. Będzie potężne błoto. Zaleca się wkręty w korkach.';
    } else if (code >= 71 && code <= 77) {
      baseDesc = 'Śnieg. W rzucaniu śnieżkami byścielibyście lepsi...';
    } else if (code >= 95) {
      baseDesc = 'Burza! Pioruny trzaskają. Epicka sceneria prosto z Valhalli!';
    }

    String tempDesc = temp < 0 ? 'Mróz szczypie w uszy (-$temp°C).' : 
                      temp < 10 ? 'Rześko ($temp°C). Dobrze na rozgrzewkę.' :
                      temp < 25 ? 'Optymalna temperatura ($temp°C) na wysiłek fizyczny.' :
                      'Upał ($temp°C). Zadbajcie o nawodnienie...';

    return '$tempDesc $baseDesc';
  }
}
