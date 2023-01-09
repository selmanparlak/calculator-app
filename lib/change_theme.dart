import 'package:calculator_app/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeThemeButtonWidget extends StatelessWidget {
  const ChangeThemeButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return IconButton(
        splashRadius: 24,
        onPressed: () {
          if (themeProvider.isDarkMode == true) {
            var provider = Provider.of<ThemeProvider>(context, listen: false);
            provider.toggleTheme(false);
          } else {
            var provider = Provider.of<ThemeProvider>(context, listen: false);
            provider.toggleTheme(true);
          }
        },
        icon: themeProvider.isDarkMode == true
            ? const Icon(CupertinoIcons.brightness_solid)
            : const Icon(CupertinoIcons.brightness));
  }
}
