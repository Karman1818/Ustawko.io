import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ustawka.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Stream wszystkich ustawek (Realtime)
  Stream<List<Ustawka>> getUstawkiStream() {
    return _client
        .from('ustawki')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Ustawka.fromMap(json)).toList());
  }

  // Tworzenie nowej ustawki
  Future<void> createUstawka(Ustawka ustawka) async {
    await _client.from('ustawki').insert(ustawka.toMap());
  }

  // Dołączanie do ustawki
  Future<void> joinUstawka(String ustawkaId, String clubName) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Musisz być zalogowany, by dołączyć do walki!');

    // Sprawdzenie L4 przed dołączeniem
    try {
      final profile = await _client.from('profiles').select().eq('id', userId).single();
      if (profile['is_on_l4'] == true) {
        throw Exception('Lekarz zabronił! Jesteś na L4. Kuruj się wojowniku!');
      }
    } catch (e) {
      if (e.toString().contains('Lekarz zabronił')) {
        rethrow;
      }
      // Ignorujemy błędy pobierania profilu, żeby nie blokować całkiem aplikacji jeśli profil nie istnieje
    }

    await _client.from('participants').insert({
      'ustawka_id': ustawkaId,
      'user_id': userId,
      'user_club': clubName,
    });
  }

  // Stream mojego profilu
  Stream<Map<String, dynamic>?> getMyProfileStream() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value(null);

    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  // Zmiana statusu L4
  Future<void> toggleL4Status(bool isOnL4) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Zaloguj się!');

    await _client.from('profiles').update({
      'is_on_l4': isOnL4,
      'l4_until': isOnL4 ? DateTime.now().add(const Duration(hours: 24)).toIso8601String() : null,
    }).eq('id', userId);
  }

  // Stream moich ustawek
  Stream<List<Ustawka>> getMyBattlesStream() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    // Streamujemy tabelę participants dla danego użytkownika
    return _client
        .from('participants')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((participantsData) async {
          if (participantsData.isEmpty) return [];
          
          final ids = participantsData.map((p) => p['ustawka_id'] as String).toList();
          
          // Pobieramy szczegóły ustawek dla tych ID
          final response = await _client
              .from('ustawki')
              .select()
              .inFilter('id', ids)
              .order('created_at', ascending: false);
          
          return response.map((json) => Ustawka.fromMap(json)).toList();
        });
  }

  // Pobieranie liczby uczestników per klub (dla balansu sił)
  Stream<Map<String, int>> getParticipantCounts(String ustawkaId) {
    return _client
        .from('participants')
        .stream(primaryKey: ['id'])
        .eq('ustawka_id', ustawkaId)
        .map((data) {
          final counts = <String, int>{};
          for (var row in data) {
            final club = row['user_club'] as String;
            counts[club] = (counts[club] ?? 0) + 1;
          }
          return counts;
        });
  }

  // --- Raportowanie wyników i Tabela Liderów ---

  // Oddawanie głosu (wywołanie RPC)
  Future<void> submitVote(String ustawkaId, String votedForClub) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Zaloguj się!');

    await _client.rpc('submit_vote_and_resolve', params: {
      'p_ustawka_id': ustawkaId,
      'p_voted_for_club': votedForClub,
    });
  }

  // Sprawdzanie czy użytkownik już głosował
  Future<bool> hasVoted(String ustawkaId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _client
        .from('votes')
        .select()
        .eq('ustawka_id', ustawkaId)
        .eq('user_id', userId)
        .maybeSingle();

    return response != null;
  }

  // Pobieranie rankingu (Leaderboard)
  Stream<List<Map<String, dynamic>>> getLeaderboardStream() {
    return _client
        .from('clubs_leaderboard')
        .stream(primaryKey: ['club'])
        .order('wins', ascending: false);
  }
}
