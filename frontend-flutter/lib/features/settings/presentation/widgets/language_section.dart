import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/locale_cubit.dart';
import '../../../../core/localization/app_strings.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) {
        return ListTile(
          title: Text(strings.language),
          trailing: DropdownButton<String>(
            focusColor: Colors.transparent,
            value: locale?.languageCode ?? 'en',
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text(strings.languageEnglish),
              ),
              DropdownMenuItem(
                value: 'ar',
                child: Text(strings.languageArabic),
              ),
              DropdownMenuItem(
                value: 'de',
                child: Text(strings.languageGerman),
              ),
            ],
            onChanged: (lang) {
              if (lang != null) {
                context.read<LocaleCubit>().setLocale(Locale(lang));
              }
            },
          ),
        );
      },
    );
  }
}
