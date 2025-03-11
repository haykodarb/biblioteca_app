import 'package:communal/backend/user_preferences.dart';
import 'package:communal/dark_theme.dart';
import 'package:communal/localization.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:communal/light_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting();

  await Hive.initFlutter();

  const String supabaseURL = 'https://supabase.communal.ar';
  const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzQxNDAyODAwLAogICJleHAiOiAxODk5MTY5MjAwCn0.8_DqM1X4Orb-1v8f5GPdCpdTOsyBmI6PL1N5AoAla4M';

  await Supabase.initialize(
    url: supabaseURL,
    anonKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  const SvgAssetLoader loader = SvgAssetLoader('assets/crow.svg');

  svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));

  GoogleFonts.config.allowRuntimeFetching = false;
  GoRouter.optionURLReflectsImperativeAPIs = true;

  final bool welcomeShown = await UserPreferences.getWelcomeScreenShown();

  final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: GlobalKey<NavigatorState>(),
    routes: routes,
    onException: (_, GoRouterState state, GoRouter router) {
      if (Supabase.instance.client.auth.currentUser != null) {
        router.go(RouteNames.communityListPage);
      } else {
        router.go(RouteNames.startPage);
      }
    },
    initialLocation: Supabase.instance.client.auth.currentUser == null
        ? (welcomeShown ? RouteNames.startPage : RouteNames.landingPage)
        : RouteNames.communityListPage,
  );

  runApp(
    MyApp(
      themeMode: await UserPreferences.getSelectedThemeMode(),
      locale: await UserPreferences.getSelectedLocale(),
      router: router,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.themeMode,
    required this.locale,
    required this.router,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'Communal',
      theme: lightTheme,
      translations: LocalizationText(),
      smartManagement: SmartManagement.full,
      scrollBehavior: const ScrollBehavior().copyWith(
        overscroll: false,
        physics: const ClampingScrollPhysics(),
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      darkTheme: darkTheme,
      themeMode: themeMode,
      color: Theme.of(context).colorScheme.surface,
    );
  }
}
