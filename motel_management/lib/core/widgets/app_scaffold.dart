import 'package:flutter/material.dart';
import 'package:rental_management/core/widgets/theme_toggle_button.dart';

/// Standard application scaffold with consistent padding, app bar, and safe area handling.
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;
  final bool showThemeToggle;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.leading,
    this.showBackButton = true,
    this.onBack,
    this.bottom,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              leading: leading ??
                  (showBackButton && Navigator.of(context).canPop()
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: onBack ?? () => Navigator.of(context).pop(),
                        )
                      : null),
              actions: [
                if (showThemeToggle) const ThemeToggleButton(),
                ...?actions,
              ],
              bottom: bottom,
            )
          : null,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
