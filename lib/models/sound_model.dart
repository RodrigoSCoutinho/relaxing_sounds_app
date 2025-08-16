import 'package:flutter/material.dart';

class SoundModel {
  final String id;
  final String title;
  final String fileName;
  final IconData icon;
  final String description;

  SoundModel({
    required this.id,
    required this.title,
    required this.fileName,
    required this.icon,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fileName': fileName,
      'description': description,
    };
  }

  factory SoundModel.fromJson(Map<String, dynamic> json) {
    return SoundModel(
      id: json['id'],
      title: json['title'],
      fileName: json['fileName'],
      icon: Icons.music_note, // Default icon
      description: json['description'],
    );
  }
}
