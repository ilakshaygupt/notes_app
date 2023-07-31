import 'package:flutter/material.dart';

class Note {
  late final String title;
  late final String body;

  Note({
    required this.title,
    required this.body,
  });

  Note.fromString(String noteString) {
    final parts = noteString.split('\n');
    title = parts[0];
    body = parts.sublist(1).join('\n');
  }

  @override
  String toString() {
    return '$title\n$body';
  }
}
