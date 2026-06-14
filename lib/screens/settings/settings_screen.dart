import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/shop_item.dart';
import '../../providers/locale_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/coin_balance_chip.dart';
import '../privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  Future<void> _pickLanguage(LocaleProvider locale) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 22)),
              title: Text(AppStrings.t(context, 'english')),
              trailing: !locale.isVietnamese ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () async {
                await locale.setEnglish();
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('🇻🇳', style: TextStyle(fontSize: 22)),
              title: Text(AppStrings.t(context, 'vietnamese')),
              trailing: locale.isVietnamese ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () async {
                await locale.setVietnamese();
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBackup(TripProvider trips, ShopProvider shop) async {
    if (!shop.hasExportBackup) {
      AppToast.show(context, title: AppStrings.t(context, 'exportBackupLocked'), icon: Icons.lock_outline);
      return;
    }
    final data = trips.exportAllJson();
    await Clipboard.setData(ClipboardData(text: data));
    if (mounted) AppToast.show(context, title: AppStrings.t(context, 'exportSuccess'));
  }

  Future<void> _importBackup(TripProvider trips, ShopProvider shop) async {
    if (!shop.hasExportBackup) {
      AppToast.show(context, title: AppStrings.t(context, 'exportBackupLocked'), icon: Icons.lock_outline);
      return;
    }
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(ctx, 'importData')),
        content: TextField(
          controller: ctrl,
          maxLines: 6,
          decoration: const InputDecoration(hintText: 'JSON...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(ctx, 'cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(ctx, 'save'))),
        ],
      ),
    );
    if (ok == true && mounted) {
      final success = await trips.importFromJson(ctrl.text);
      AppToast.show(
        context,
        title: AppStrings.t(context, success ? 'importSuccess' : 'importFailed'),
        color: success ? AppColors.success : AppColors.error,
      );
    }
    ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();
    final trips = context.read<TripProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(AppStrings.t(context, 'settingsTitle'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              ),
              const CoinBalanceChip(),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(AppStrings.t(context, 'activeCustomization')),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: AppStrings.t(context, 'activeTheme'),
            subtitle: shop.activeThemeId == 'theme_default'
                ? AppStrings.t(context, 'resetDefault')
                : AppStrings.t(context, ShopCatalog.find(shop.activeThemeId)?.nameKey ?? 'active'),
          ),
          _SettingsTile(
            icon: Icons.style_outlined,
            title: AppStrings.t(context, 'activeBackground'),
            subtitle: shop.activeBackgroundId,
          ),
          const SizedBox(height: 16),
          _SectionTitle(AppStrings.t(context, 'appearance')),
          _SettingsTile(
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: AppStrings.t(context, 'darkMode'),
            trailing: Switch(value: theme.isDarkMode, onChanged: (_) => theme.toggleTheme()),
          ),
          const SizedBox(height: 16),
          _SectionTitle(AppStrings.t(context, 'language')),
          _SettingsTile(
            icon: Icons.translate_rounded,
            title: locale.isVietnamese ? AppStrings.t(context, 'vietnamese') : AppStrings.t(context, 'english'),
            subtitle: AppStrings.t(context, 'language'),
            onTap: () => _pickLanguage(locale),
          ),
          const SizedBox(height: 16),
          _SectionTitle(AppStrings.t(context, 'data')),
          _SettingsTile(
            icon: Icons.upload_outlined,
            title: AppStrings.t(context, 'exportBackup'),
            subtitle: shop.hasExportBackup ? null : AppStrings.t(context, 'exportBackupLocked'),
            onTap: () => _exportBackup(trips, shop),
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: AppStrings.t(context, 'importData'),
            subtitle: shop.hasExportBackup ? null : AppStrings.t(context, 'exportBackupLocked'),
            onTap: () => _importBackup(trips, shop),
          ),
          const SizedBox(height: 16),
          _SectionTitle(AppStrings.t(context, 'other')),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: AppStrings.t(context, 'privacyPolicy'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: AppStrings.t(context, 'about'),
            subtitle: '${AppStrings.t(context, 'version')} $_version · ${AppStrings.t(context, 'aboutDesc')}',
          ),
          const SizedBox(height: 24),
          Center(child: Text(AppStrings.t(context, 'copyright'), style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12))),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, fontSize: 13)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (subtitle != null)
                      Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
