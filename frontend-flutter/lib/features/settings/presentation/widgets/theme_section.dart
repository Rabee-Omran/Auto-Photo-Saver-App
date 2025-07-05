import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/localization/app_strings.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return ListTile(
          title: Text(strings.theme),
          trailing: DropdownButton<ThemeMode>(
            focusColor: Colors.transparent,
            value: themeMode,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(strings.themeSystem),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text(strings.themeLight),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text(strings.themeDark),
              ),
            ],
            onChanged: (mode) {
              if (mode != null) {
                context.read<ThemeCubit>().setTheme(mode);
              }
            },
          ),
        );
      },
    );
  }
}
