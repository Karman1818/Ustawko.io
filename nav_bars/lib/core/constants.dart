class AppConstants {
  static const List<String> popularClubs = [
    'Legia Warszawa',
    'Lech Poznań',
    'Wisła Kraków',
    'Widzew Łódź',
    'Ruch Chorzów',
    'Górnik Zabrze',
    'Lechia Gdańsk',
    'Pogoń Szczecin',
  ];

  static const List<Map<String, dynamic>> equipmentRules = [
    {
      'id': 'no_equipment',
      'label': 'CZYSTE RĘCE (BEZ SPRZĘTU)',
      'value': false,
    },
    {
      'id': 'with_equipment',
      'label': 'PEŁEN ARSENAŁ (ZE SPRZĘTEM)',
      'value': true,
    },
  ];

  // Hardkodowane współrzędne kilku przykładowych lokacji do losowania
  static const List<Map<String, dynamic>> forestArenas = [
    {
      'name': 'Lasy Kabackie (Warszawa)',
      'lat': 52.1289,
      'lng': 21.0478,
    },
    {
      'name': 'Puszcza Niepołomicka (Kraków)',
      'lat': 50.0433,
      'lng': 20.3541,
    },
    {
      'name': 'Wielkopolski Park Narodowy (Poznań)',
      'lat': 52.2619,
      'lng': 16.7972,
    },
    {
      'name': 'Las Łagiewnicki (Łódź)',
      'lat': 51.8344,
      'lng': 19.4678,
    },
    {
      'name': 'Trójmiejski Park Krajobrazowy',
      'lat': 54.4167,
      'lng': 18.4667,
    },
  ];
}
