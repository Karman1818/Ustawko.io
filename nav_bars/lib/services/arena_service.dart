import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/arena.dart';

class ArenaService {
  final Random _random = Random();

  Future<Arena> generateRandomArena() async {
    // 1. Próba pobrania prawdziwej lokacji z Overpass API (OpenStreetMap)
    Map<String, dynamic>? arenaData;

    try {
      const String overpassUrl = 'https://overpass-api.de/api/interpreter';
      // Szukamy lasów (landuse=forest lub natural=wood) w Polsce
      const String query = '''
[out:json][timeout:25];
area["name:pl"="Polska"]->.searchArea;
(
  nwr["landuse"="forest"](area.searchArea);
  nwr["natural"="wood"](area.searchArea);
);
out center 50;
''';

      final response = await http.post(Uri.parse(overpassUrl), body: query);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List elements = data['elements'] ?? [];
        if (elements.isNotEmpty) {
          final element = elements[_random.nextInt(elements.length)];
          double lat;
          double lon;
          
          if (element['center'] != null) {
            lat = (element['center']['lat'] as num).toDouble();
            lon = (element['center']['lon'] as num).toDouble();
          } else {
            lat = (element['lat'] as num).toDouble();
            lon = (element['lon'] as num).toDouble();
          }
          String name = element['tags']?['name'] ?? 'Uroczysko (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})';
          
          arenaData = {
            'name': name,
            'lat': lat,
            'lng': lon,
          };
        }
      }
    } catch (e) {
      debugPrint('Błąd Overpass API: $e');
    }

    // Fallback do listy statycznej jeśli API zawiedzie
    arenaData ??= AppConstants.forestArenas[_random.nextInt(AppConstants.forestArenas.length)];

    final String name = arenaData['name'];
    final double lat = arenaData['lat'];
    final double lng = arenaData['lng'];

    // 2. Pobranie pogody z Open-Meteo
    final String url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current_weather=true';
    
    double temperature = 15.0; // Wartość domyślna w razie awarii
    int weatherCode = 0; // Wartość domyślna (czyste niebo)

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['current_weather'] != null) {
          temperature = (data['current_weather']['temperature'] as num).toDouble();
          weatherCode = data['current_weather']['weathercode'] as int;
        }
      }
    } catch (e) {
      debugPrint('Błąd pobierania pogody: $e');
    }

    // 3. Generowanie satyrycznego "Raportu Warunków Bitewnych"
    final String report = _generateBattleReport(temperature, weatherCode);

    return Arena(
      name: name,
      lat: lat,
      lng: lng,
      temperature: temperature,
      weatherReport: report,
    );
  }

  String _generateBattleReport(double temp, int code) {
    String baseDesc = '';
    
    // Według kodów WMO (World Meteorological Organization)
    if (code == 0) {
      baseDesc = 'Czyste niebo. Żadnych wymówek dla słabej widoczności.';
    } else if (code >= 1 && code <= 3) {
      baseDesc = 'Lekkie zachmurzenie. Słońce nie będzie razić w oczy przy ciosach.';
    } else if (code == 45 || code == 48) {
      baseDesc = 'Gęsta mgła. Idealne warunki na taktyczną partyzantkę w krzakach.';
    } else if (code >= 51 && code <= 67) {
      baseDesc = 'Pada deszcz. Będzie potężne błoto. Zaleca się wkręty w korkach i uważanie na poślizgi.';
    } else if (code >= 71 && code <= 77) {
      baseDesc = 'Śnieg. W rzucaniu śnieżkami byścielibyście lepsi, ale trudno...';
    } else if (code >= 95) {
      baseDesc = 'Burza! Pioruny trzaskają. Epicka sceneria prosto z Valhalli!';
    } else {
      baseDesc = 'Pogoda niepewna. Gotowość na wszystko!';
    }

    String tempDesc = '';
    if (temp < 0) {
      tempDesc = 'Mróz szczypie w uszy (-$temp°C).';
    } else if (temp < 10) {
      tempDesc = 'Rześko ($temp°C). Dobrze na rozgrzewkę.';
    } else if (temp < 25) {
      tempDesc = 'Optymalna temperatura ($temp°C) na wysiłek fizyczny.';
    } else {
      tempDesc = 'Upał ($temp°C). Zadbajcie o nawodnienie... albo i nie.';
    }

    return '$tempDesc $baseDesc';
  }
}
