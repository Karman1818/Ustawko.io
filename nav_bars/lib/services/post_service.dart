import 'package:supabase_flutter/supabase_flutter.dart';


class PostService {
  final SupabaseClient _client = Supabase.instance.client;

  // Pobieranie postów w czasie rzeczywistym
  Stream<List<Map<String, dynamic>>> getPostsStream() {
    return _client
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  // Tworzenie nowego posta
  Future<void> createPost(String content) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Użytkownik nie jest zalogowany');

    final authorName = user.userMetadata?['full_name'] ?? 'Użytkownik';

    await _client.from('posts').insert({
      'content': content,
      'user_id': user.id,
      'author_name': authorName,
    });
  }

  // Usuwanie posta
  Future<void> deletePost(String postId) async {
    if (postId.isEmpty) throw Exception('Post ID nie może być pusty');
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Użytkownik nie jest zalogowany');

    await _client.from('posts').delete().eq('id', postId);
  }

  // Głosowanie na post
  Future<void> toggleVote(String postId, bool isLike) async {
    if (postId.isEmpty) throw Exception('Post ID nie może być pusty');
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Użytkownik nie jest zalogowany');

    final data = await _client.from('posts').select('liked_by, disliked_by').eq('id', postId).single();
    
    List<String> likedBy = data['liked_by'] is List 
        ? List<String>.from((data['liked_by'] as List).map((e) => e.toString())) 
        : [];
    List<String> dislikedBy = data['disliked_by'] is List 
        ? List<String>.from((data['disliked_by'] as List).map((e) => e.toString())) 
        : [];

    final userId = user.id;

    if (isLike) {
      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
        dislikedBy.remove(userId);
      }
    } else {
      if (dislikedBy.contains(userId)) {
        dislikedBy.remove(userId);
      } else {
        dislikedBy.add(userId);
        likedBy.remove(userId);
      }
    }

    final updateResponse = await _client.from('posts').update({
      'liked_by': likedBy,
      'disliked_by': dislikedBy,
    }).eq('id', postId).select();

    if (updateResponse.isEmpty) {
      throw Exception("Brak uprawnień do edycji bazy (sprawdź polityki RLS w Supabase)");
    }
  }
}
