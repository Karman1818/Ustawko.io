import 'package:flutter/material.dart';

class Post {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const Post({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = Colors.blueAccent,
  });
}
