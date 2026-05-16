import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nav_bars/classses/post_class.dart';
import 'package:nav_bars/widgets/add_post_dialog.dart';
import 'package:nav_bars/widgets/custom_card_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _customKey = 'custom_posts';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Post> _posts = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_customKey) ?? [];
    setState(() {
      _posts = raw.map((s) {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return Post(
          title: m['title'] as String,
          subtitle: m['subtitle'] as String,
          icon: IconData(
            m['iconCode'] as int,
            fontFamily: m['fontFamily'] as String,
          ),
          iconColor: Color(m['colorValue'] as int),
        );
      }).toList();
      _loaded = true;
    });
  }

  Future<void> _savePosts(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _customKey,
      posts
          .map(
            (p) => jsonEncode({
              'title': p.title,
              'subtitle': p.subtitle,
              'iconCode': p.icon.codePoint,
              'fontFamily': p.icon.fontFamily ?? 'MaterialIcons',
              'colorValue': p.iconColor.value,
            }),
          )
          .toList(),
    );
  }

  Future<void> _addPost(Post post) async {
    final updated = [..._posts, post];
    setState(() => _posts = updated);
    await _savePosts(updated);
  }

  Future<void> _deletePost(int index) async {
    final updated = [..._posts]..removeAt(index);
    setState(() => _posts = updated);
    await _savePosts(updated);
  }

  Future<void> _showAddPostDialog() async {
    final Post? newPost = await showDialog<Post>(
      context: context,
      builder: (ctx) => const AddPostDialog(),
    );

    if (newPost != null) {
      _addPost(newPost);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: _posts.isEmpty
          ? const Center(
              child: Text(
                'Ups, tu niczego nie ma',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Dismissible(
                  key: ValueKey(post),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deletePost(index);
                  },
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: CustomCardWidget(
                    post: post,
                    onDeletePressed: () => _deletePost(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
