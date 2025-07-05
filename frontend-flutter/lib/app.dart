import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/network/network_cubit.dart';
import 'di/di.dart';

class AutoPhotoSaverApp extends StatelessWidget {
  const AutoPhotoSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..loadTheme()),
        BlocProvider(create: (_) => LocaleCubit()..loadLocale()),
        BlocProvider(create: (_) => sl<NetworkCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (context) => AppStrings.of(context).appTitle,
                locale: locale,
                supportedLocales: const [
                  Locale('en'),
                  Locale('de'),
                  Locale('ar'),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                localeResolutionCallback: (locale, supportedLocales) {
                  if (context.read<LocaleCubit>().state != null) {
                    return context.read<LocaleCubit>().state;
                  }
                  if (locale == null) return supportedLocales.first;
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale.languageCode) {
                      return supportedLocale;
                    }
                  }
                  return supportedLocales.first;
                },
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                routerConfig: appRouter,
              );
            },
          );
        },
      ),
    );
  }
}
