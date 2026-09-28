import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/app/theme/theme_provider.dart';

/// Interactive button to toggle or select application ThemeMode (Light / Dark / System).
class ThemeToggleButton extends ConsumerWidget {
  final bool showLabel;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final IconData icon = switch (themeMode) {
      ThemeMode.system => isDark ? Icons.brightness_auto_rounded : Icons.brightness_auto_outlined,
      ThemeMode.dark => Icons.light_mode_rounded,
      ThemeMode.light => Icons.dark_mode_outlined,
    };

    final String tooltip = switch (themeMode) {
      ThemeMode.system => isDark
          ? 'Hệ thống (Đang tối) - Bấm để chuyển sáng'
          : 'Hệ thống (Đang sáng) - Bấm để chuyển tối',
      ThemeMode.dark => 'Giao diện tối - Bấm để chuyển sáng',
      ThemeMode.light => 'Giao diện sáng - Bấm để chuyển tối',
    };

    final Color iconColor = isDark ? const Color(0xFFFFD54F) : theme.colorScheme.onSurfaceVariant;

    if (showLabel) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(context),
        onLongPress: () => showThemeModeSelectionDialog(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: anim,
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: Icon(icon, key: ValueKey('$themeMode-$isDark'), color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                isDark ? 'Giao diện tối' : 'Giao diện sáng',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Tooltip(
      message: '$tooltip (Nhấn giữ để chọn chế độ)',
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: anim,
            child: ScaleTransition(scale: anim, child: child),
          ),
          child: Icon(
            icon,
            key: ValueKey('$themeMode-$isDark'),
            color: iconColor,
          ),
        ),
        onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(context),
        onLongPress: () => showThemeModeSelectionDialog(context, ref),
      ),
    );
  }

  /// Opens an interactive modal dialog allowing explicit selection of theme mode.
  static Future<void> showThemeModeSelectionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final currentMode = ref.read(themeModeProvider);
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Giao diện hiển thị'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile(
                context: dialogContext,
                title: 'Giao diện Sáng',
                subtitle: 'Tông màu sáng, dễ nhìn vào ban ngày',
                icon: Icons.light_mode_rounded,
                iconColor: Colors.amber.shade700,
                isSelected: currentMode == ThemeMode.light,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                  Navigator.of(dialogContext).pop();
                },
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                context: dialogContext,
                title: 'Giao diện Tối',
                subtitle: 'Dịu mắt, tiết kiệm pin ban đêm',
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFFFFD54F),
                isSelected: currentMode == ThemeMode.dark,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                  Navigator.of(dialogContext).pop();
                },
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                context: dialogContext,
                title: 'Theo hệ thống',
                subtitle: 'Tự động đồng bộ theo cài đặt thiết bị',
                icon: Icons.brightness_auto_rounded,
                iconColor: theme.colorScheme.primary,
                isSelected: currentMode == ThemeMode.system,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
