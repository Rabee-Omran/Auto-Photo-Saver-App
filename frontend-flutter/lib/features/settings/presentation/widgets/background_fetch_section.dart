import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/background_service.dart';
import '../../../../core/services/shared_prefs_service.dart';

class BackgroundFetchSection extends StatefulWidget {
  const BackgroundFetchSection({super.key});

  @override
  State<BackgroundFetchSection> createState() => _BackgroundFetchSectionState();
}

class _BackgroundFetchSectionState extends State<BackgroundFetchSection> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _enabled = SharedPrefsService.instance.backgroundFetchEnabled;
  }

  Future<void> _onChanged(bool enabled) async {
    setState(() {
      _enabled = enabled;
    });

    final prefs = SharedPrefsService.instance;
    await prefs.setBackgroundFetchEnabled(enabled);

    if (enabled) {
      await BackgroundService.startService();
    } else {
      await BackgroundService.stopService();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SwitchListTile(
          title: Text(strings.backgroundFetch),
          value: _enabled,
          onChanged: _onChanged,
        ),
      ],
    );
  }
}
