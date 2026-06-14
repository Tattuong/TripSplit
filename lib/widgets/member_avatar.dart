import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/member.dart';

class MemberAvatar extends StatelessWidget {
  final Member member;
  final int index;
  final double size;
  final bool showBorder;

  const MemberAvatar({
    super.key,
    required this.member,
    required this.index,
    this.size = 40,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = member.color(index);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: color, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}

class MemberAvatarStack extends StatelessWidget {
  final List<Member> members;
  final double size;
  final int maxVisible;

  const MemberAvatarStack({
    super.key,
    required this.members,
    this.size = 32,
    this.maxVisible = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visible = members.take(maxVisible).toList();
    final extra = members.length - visible.length;

    return SizedBox(
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < visible.length; i++)
            Transform.translate(
              offset: Offset(i > 0 ? -size * 0.3 : 0, 0),
              child: MemberAvatar(member: visible[i], index: members.indexOf(visible[i]), size: size),
            ),
          if (extra > 0)
            Transform.translate(
              offset: Offset(-size * 0.3, 0),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Text('+$extra', style: TextStyle(fontSize: size * 0.3, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}
