import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class Member {
  final String id;
  final String name;

  const Member({required this.id, required this.name});

  Color color(int index) => AppColors.memberPalette[index % AppColors.memberPalette.length];

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  Member copyWith({String? name}) => Member(id: id, name: name ?? this.name);
}
