import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/iap_constants.dart';
import '../../providers/shop_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/ticket_card.dart';
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.t(context, 'appName'),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            AppStrings.t(context, 'tripsTitle'),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                        ],
                      ),
                    ),
                    const CoinBalanceChip(),
                  ],
                ),
              ),
            ),
            if (trips.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (trips.trips.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(onCreate: () => _openCreate(context)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final trip = trips.trips[i];
                      return TicketCard(
                        trip: trip,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: trip.id)),
                        ),
                        onDelete: () => _confirmDelete(context, trip.id),
                      );
                    },
                    childCount: trips.trips.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: trips.trips.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openCreate(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(AppStrings.t(context, 'createTrip')),
            ),
    );
  }

  void _openCreate(BuildContext context) {
    final trips = context.read<TripProvider>();
    final shop = context.read<ShopProvider>();
    if (!trips.canCreateTrip(hasUnlimited: shop.hasUnlimitedTrips)) {
      _showLimitDialog(context);
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTripScreen()));
  }

  void _showLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(ctx, 'tripLimitReached')),
        content: Text(AppStrings.t(ctx, 'tripLimitDesc', {'limit': '${IapConstants.freeTripLimit}'})),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.t(ctx, 'cancel'))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.t(ctx, 'goToShop')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String tripId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(ctx, 'confirmDelete')),
        content: Text(AppStrings.t(ctx, 'confirmDeleteDesc')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(ctx, 'cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t(ctx, 'delete')),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<TripProvider>().deleteTrip(tripId);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.luggage_outlined, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.t(context, 'tripsEmpty'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.t(context, 'tripsEmptyDesc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: Text(AppStrings.t(context, 'createTrip')),
          ),
        ],
      ),
    );
  }
}
