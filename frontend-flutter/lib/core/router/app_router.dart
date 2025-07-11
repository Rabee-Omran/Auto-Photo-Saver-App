import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../di/di.dart';
import '../../features/photo/presentation/bloc/photo_cubit/photo_cubit.dart';
import '../../features/photo/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/photo/presentation/bloc/websocket_cubit/websocket_cubit.dart';
import '../theme/theme_cubit.dart';

class Routes {
  static final String home = '/';
  static final String settings = '/settings';
}

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<PhotoCubit>()),
          BlocProvider(create: (context) => sl<WebSocketCubit>()),
        ],
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: Routes.settings,
      name: 'settings',
      builder: (context, state) => BlocProvider.value(
        value: BlocProvider.of<ThemeCubit>(context),
        child: const SettingsPage(),
      ),
    ),
  ],
);
