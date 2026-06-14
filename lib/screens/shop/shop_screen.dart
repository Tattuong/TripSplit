import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/iap_config_service.dart';
import '../../models/app_theme_preset.dart';
import '../../models/shop_item.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/coin_purchase_sheet.dart';

enum _ShopCategory { all, premium, themes, backgrounds, features }

class ShopScreen extends StatefulWidget {
  final bool embedded;

  const ShopScreen({super.key, this.embedded = false});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  _ShopCategory _category = _ShopCategory.all;

  List<ShopItem> _filteredItems() {
    return switch (_category) {
      _ShopCategory.all => ShopCatalog.items,
      _ShopCategory.premium => ShopCatalog.items.where((i) => i.category == ShopItemCategory.premium).toList(),
      _ShopCategory.themes => ShopCatalog.items.where((i) => i.category == ShopItemCategory.themes).toList(),
      _ShopCategory.backgrounds => ShopCatalog.items.where((i) => i.category == ShopItemCategory.backgrounds).toList(),
      _ShopCategory.features => ShopCatalog.items.where((i) => i.category == ShopItemCategory.features).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _filteredItems();

    final content = SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(widget.embedded ? 20 : 8, widget.embedded ? 16 : 8, 20, 0),
              child: Row(
                children: [
                  if (!widget.embedded)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  Expanded(
                    child: Text(
                      AppStrings.t(context, 'shopTitle'),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (shop.configStatus == IapConfigStatus.timeout || shop.configStatus == IapConfigStatus.networkError)
            SliverToBoxAdapter(child: _ConfigStatusBar(status: shop.configStatus)),
          SliverToBoxAdapter(child: _WalletHeader(shop: shop)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                AppStrings.t(context, 'shopBrowse'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _CategoryMenu(selected: _category, onSelect: (c) => setState(() => _category = c))),
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  AppStrings.t(context, 'shopEmptyCategory'),
                  style: const TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: i < items.length - 1 ? 12 : 0),
                    child: _ShopItemCard(item: items[i]),
                  ),
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.embedded) return content;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: content,
    );
  }
}

class _WalletHeader extends StatelessWidget {
  final ShopProvider shop;

  const _WalletHeader({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: shop.activeTheme.headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.t(context, 'yourWallet'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD54F), size: 36),
              const SizedBox(width: 8),
              Text(
                '${shop.coins}',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  AppStrings.t(context, 'coinsLabel'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.t(context, 'earnCoinsDesc'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          _EarnSteps(shop: shop),
          const SizedBox(height: 12),
          _ClaimRewardsRow(shop: shop),
          if (!shop.isBillingDisabled) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => CoinPurchaseSheet.show(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(AppStrings.t(context, 'buyCoins'), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EarnSteps extends StatelessWidget {
  final ShopProvider shop;

  const _EarnSteps({required this.shop});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: shop.hasClaimedDailyToday(),
      builder: (context, snapshot) {
        final dailyDone = snapshot.data == true;
        final steps = [
          dailyDone ? AppStrings.t(context, 'dailyRewardDone') : AppStrings.t(context, 'earnStepDaily'),
          AppStrings.t(context, 'earnStepSettlement'),
          if (!shop.isBillingDisabled) AppStrings.t(context, 'earnStepBuy'),
        ];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.t(context, 'earnCoins'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 8),
              for (final step in steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(step, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, height: 1.35)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ClaimRewardsRow extends StatefulWidget {
  final ShopProvider shop;

  const _ClaimRewardsRow({required this.shop});

  @override
  State<_ClaimRewardsRow> createState() => _ClaimRewardsRowState();
}

class _ClaimRewardsRowState extends State<_ClaimRewardsRow> {
  late Future<bool> _statusFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _statusFuture = widget.shop.hasClaimedDailyToday();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _statusFuture,
      builder: (context, snapshot) {
        final dailyDone = snapshot.data ?? false;

        if (!dailyDone) {
          return _ClaimButton(
            label: AppStrings.t(context, 'claimDailyButton'),
            onPressed: () async {
              final claimed = await widget.shop.claimDailyReward();
              if (!mounted) return;
              setState(_reload);
              if (!claimed) {
                AppToast.show(context, title: AppStrings.t(context, 'dailyRewardDone'), icon: Icons.info_outline);
              }
            },
          );
        }
        return _DoneChip(label: AppStrings.t(context, 'dailyRewardDone'));
      },
    );
  }
}

class _ClaimButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ClaimButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _DoneChip extends StatelessWidget {
  final String label;

  const _DoneChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CategoryMenu extends StatelessWidget {
  final _ShopCategory selected;
  final ValueChanged<_ShopCategory> onSelect;

  const _CategoryMenu({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final entries = <(_ShopCategory, IconData, String)>[
      (_ShopCategory.all, Icons.apps_rounded, 'shopMenuAll'),
      (_ShopCategory.premium, Icons.workspace_premium_outlined, 'shopMenuPremium'),
      (_ShopCategory.themes, Icons.palette_outlined, 'shopMenuThemes'),
      (_ShopCategory.backgrounds, Icons.style_outlined, 'shopMenuCards'),
      (_ShopCategory.features, Icons.auto_awesome_outlined, 'shopMenuFeatures'),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final (cat, icon, labelKey) = entries[i];
          final active = selected == cat;
          return Material(
            color: active ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSelect(cat),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: active ? Colors.white : AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.t(context, labelKey),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConfigStatusBar extends StatelessWidget {
  final IapConfigStatus status;

  const _ConfigStatusBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final text = status == IapConfigStatus.timeout
        ? AppStrings.t(context, 'configTimeout')
        : AppStrings.t(context, 'configNetworkError');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.warning))),
        ],
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final ShopItem item;

  const _ShopItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final owned = shop.ownsItem(item.id);
    final isActive = _isActive(shop, item);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ItemPreview(item: item),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, item.nameKey), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(AppStrings.t(context, item.descKey), style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (owned && (item.type == ShopItemType.theme || item.type == ShopItemType.background))
                  Expanded(child: _OwnedThemeActions(item: item, isActive: isActive))
                else if (owned)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                        const SizedBox(width: 6),
                        Text(AppStrings.t(context, 'owned'), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  )
                else
                  Expanded(child: _BuyButton(item: item)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isActive(ShopProvider shop, ShopItem item) {
    if (item.type == ShopItemType.theme) return shop.activeThemeId == item.id;
    if (item.type == ShopItemType.background) return shop.activeBackgroundId == item.id;
    return shop.ownsItem(item.id);
  }
}

class _ItemPreview extends StatelessWidget {
  final ShopItem item;

  const _ItemPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.type == ShopItemType.theme) {
      final preset = AppThemePresets.byId[item.id];
      if (preset != null) {
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: preset.headerGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.palette_outlined, color: Colors.white),
        );
      }
    }
    if (item.type == ShopItemType.background) {
      final bg = DashboardBackground.byId[item.id];
      if (bg != null) {
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: bg.gradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 22),
        );
      }
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(item.icon, color: AppColors.primary),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final ShopItem item;

  const _BuyButton({required this.item});

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopProvider>();
    final canAfford = shop.coins >= item.price;

    return FilledButton(
      onPressed: () => _purchase(context, shop),
      style: FilledButton.styleFrom(
        backgroundColor: canAfford ? AppColors.warning : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
        foregroundColor: canAfford ? Colors.white : AppColors.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, size: 18),
          const SizedBox(width: 6),
          Text('${item.price}', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  void _purchase(BuildContext context, ShopProvider shop) {
    final result = shop.buyWithCoins(item.id);
    switch (result) {
      case ShopPurchaseResult.success:
        final applied = item.type == ShopItemType.theme || item.type == ShopItemType.background;
        AppToast.show(
          context,
          title: AppStrings.t(context, applied ? 'applied' : 'purchaseSuccess'),
          message: applied ? AppStrings.t(context, item.nameKey) : null,
        );
      case ShopPurchaseResult.insufficientCoins:
        AppToast.show(context, title: AppStrings.t(context, 'insufficientCoins'), icon: Icons.warning_amber_rounded, color: AppColors.warning);
        if (!shop.isBillingDisabled) CoinPurchaseSheet.show(context);
      case ShopPurchaseResult.alreadyOwned:
        AppToast.show(context, title: AppStrings.t(context, 'alreadyOwned'));
      case ShopPurchaseResult.notFound:
      case ShopPurchaseResult.error:
        AppToast.show(context, title: AppStrings.t(context, 'purchaseFailed'));
    }
  }
}

class _OwnedThemeActions extends StatelessWidget {
  final ShopItem item;
  final bool isActive;

  const _OwnedThemeActions({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopProvider>();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (isActive)
          Chip(
            avatar: const Icon(Icons.check, size: 16, color: AppColors.primary),
            label: Text(AppStrings.t(context, 'active'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            side: BorderSide.none,
          )
        else
          OutlinedButton(
            onPressed: () {
              if (item.type == ShopItemType.theme) {
                shop.selectTheme(item.id);
              } else {
                shop.selectBackground(item.id);
              }
              AppToast.show(context, title: AppStrings.t(context, 'applied'));
            },
            child: Text(AppStrings.t(context, 'apply')),
          ),
        if (isActive)
          TextButton(
            onPressed: () async {
              if (item.type == ShopItemType.theme) {
                await shop.resetThemeToDefault();
              } else {
                await shop.resetBackgroundToDefault();
              }
              AppToast.show(context, title: AppStrings.t(context, 'resetToDefault'));
            },
            child: Text(AppStrings.t(context, 'resetDefault'), style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}
