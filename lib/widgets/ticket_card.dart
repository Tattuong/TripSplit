import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../models/trip.dart';
import '../providers/shop_provider.dart';
import 'member_avatar.dart';

class TicketCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TicketCard({super.key, required this.trip, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = shop.activeBackground.gradient;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipPath(
          clipper: _TicketClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(Icons.confirmation_number, size: 120, color: Colors.white.withValues(alpha: 0.08)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              trip.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          if (onDelete != null)
                            IconButton(
                              onPressed: onDelete,
                              icon: Icon(Icons.delete_outline, color: Colors.white.withValues(alpha: 0.7), size: 20),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          MemberAvatarStack(members: trip.members),
                          const Spacer(),
                          _StatChip(
                            icon: Icons.people_outline,
                            label: AppStrings.t(context, 'membersCount', {'count': '${trip.members.length}'}),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.t(context, 'totalSpent'),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                            ),
                            Text(
                              _formatAmount(trip.totalSpent, trip.currency),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.t(context, 'expensesCount', {'count': '${trip.expenses.length}'}),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CustomPaint(
                    size: const Size(double.infinity, 8),
                    painter: _PerforationPainter(isDark: isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatAmount(double amount, String currency) {
    if (currency == 'VND') {
      return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
    }
    return '${amount.toStringAsFixed(2)} $currency';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 20.0;
    const notchRadius = 10.0;
    final notchY = size.height * 0.72;

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius));
    path.lineTo(size.width, notchY - notchRadius);
    path.arcToPoint(Offset(size.width, notchY + notchRadius), radius: const Radius.circular(notchRadius), clockwise: false);
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height), radius: const Radius.circular(radius));
    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius), radius: const Radius.circular(radius));
    path.lineTo(0, notchY + notchRadius);
    path.arcToPoint(Offset(0, notchY - notchRadius), radius: const Radius.circular(notchRadius), clockwise: false);
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _PerforationPainter extends CustomPainter {
  final bool isDark;

  _PerforationPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = (isDark ? AppColors.darkBackground : AppColors.background);
    const dashWidth = 6.0;
    const gap = 4.0;
    var x = 8.0;
    while (x < size.width) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, dashWidth, 3), const Radius.circular(1.5)),
        paint,
      );
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
