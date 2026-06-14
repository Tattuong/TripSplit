import 'package:flutter/material.dart';

enum ShopItemType {
  theme,
  background,
  feature,
  removeAds,
}

enum ShopItemCategory {
  themes,
  backgrounds,
  features,
  premium,
}

class ShopItem {
  final String id;
  final String nameKey;
  final String descKey;
  final int price;
  final ShopItemType type;
  final ShopItemCategory category;
  final IconData icon;
  final bool oneTime;

  const ShopItem({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.type,
    required this.category,
    required this.icon,
    this.oneTime = true,
  });
}

class ShopCatalog {
  ShopCatalog._();

  static const String defaultThemeId = 'theme_default';
  static const String defaultBackgroundId = 'bg_default';

  static const List<ShopItem> items = [
    ShopItem(
      id: 'remove_ads',
      nameKey: 'shopRemoveAds',
      descKey: 'shopRemoveAdsDesc',
      price: 500,
      type: ShopItemType.removeAds,
      category: ShopItemCategory.premium,
      icon: Icons.block_outlined,
    ),
    ShopItem(
      id: 'theme_sunset',
      nameKey: 'shopThemeSunset',
      descKey: 'shopThemeSunsetDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.wb_twilight_outlined,
    ),
    ShopItem(
      id: 'theme_midnight',
      nameKey: 'shopThemeMidnight',
      descKey: 'shopThemeMidnightDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.nightlight_round,
    ),
    ShopItem(
      id: 'theme_tropical',
      nameKey: 'shopThemeTropical',
      descKey: 'shopThemeTropicalDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.beach_access_outlined,
    ),
    ShopItem(
      id: 'theme_sakura',
      nameKey: 'shopThemeSakura',
      descKey: 'shopThemeSakuraDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.local_florist_outlined,
    ),
    ShopItem(
      id: 'bg_ticket',
      nameKey: 'shopBgTicket',
      descKey: 'shopBgTicketDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.confirmation_number_outlined,
    ),
    ShopItem(
      id: 'bg_ocean',
      nameKey: 'shopBgOcean',
      descKey: 'shopBgOceanDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.waves_outlined,
    ),
    ShopItem(
      id: 'bg_mountain',
      nameKey: 'shopBgMountain',
      descKey: 'shopBgMountainDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.landscape_outlined,
    ),
    ShopItem(
      id: 'feat_unlimited_trips',
      nameKey: 'shopFeatUnlimited',
      descKey: 'shopFeatUnlimitedDesc',
      price: 300,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.all_inclusive,
    ),
    ShopItem(
      id: 'feat_export_backup',
      nameKey: 'shopFeatExport',
      descKey: 'shopFeatExportDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.backup_outlined,
    ),
    ShopItem(
      id: 'feat_share_settlement',
      nameKey: 'shopFeatShare',
      descKey: 'shopFeatShareDesc',
      price: 150,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.share_outlined,
    ),
    ShopItem(
      id: 'feat_custom_split',
      nameKey: 'shopFeatCustomSplit',
      descKey: 'shopFeatCustomSplitDesc',
      price: 250,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.pie_chart_outline,
    ),
    ShopItem(
      id: 'feat_multi_currency',
      nameKey: 'shopFeatMultiCurrency',
      descKey: 'shopFeatMultiCurrencyDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.currency_exchange_outlined,
    ),
    ShopItem(
      id: 'feat_expense_note',
      nameKey: 'shopFeatExpenseNote',
      descKey: 'shopFeatExpenseNoteDesc',
      price: 150,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.sticky_note_2_outlined,
    ),
  ];

  static ShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
