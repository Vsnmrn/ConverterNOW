import 'package:converterpro/models/order.dart';
import 'package:converterpro/models/settings.dart';
import 'package:converterpro/pages/error_page.dart';
import 'package:converterpro/pages/reorder_units_page.dart';
import 'package:converterpro/pages/conversion_page.dart';
import 'package:converterpro/pages/reorder_properties_page.dart';
import 'package:converterpro/pages/settings_page.dart';
import 'package:converterpro/pages/splash_screen.dart';
import 'package:converterpro/utils/app_scaffold.dart';
import 'package:converterpro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translations/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => const SplashScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return AppScaffold(
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/conversions/:property',
              pageBuilder: (context, state) {
                final String property = state.params['property']!;
                final int? pageNumber = pageNumberMap[property];
                if (pageNumber == null) {
                  throw Exception('property not found: $property');
                } else {
                  return NoTransitionPage(child: ConversionPage(pageNumber));
                }
              },
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SettingsPage()),
              routes: [
                GoRoute(
                  path: 'reorder-properties',
                  name: 'reorder-properties',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: ReorderPropertiesPage()),
                ),
                GoRoute(
                  path: 'reorder-units',
                  name: 'reorder-units',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: ChoosePropertyPage()),
                  routes: [
                    GoRoute(
                      path: ':property',
                      pageBuilder: (context, state) {
                        final String property = state.params['property']!;
                        final int? pageNumber = pageNumberMap[property];
                        if (pageNumber == null) {
                          throw Exception('property not found: $property');
                        } else {
                          return NoTransitionPage(
                            child: ChoosePropertyPage(
                              selectedProperty: pageNumber,
                              isPropertySelected: true,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        // Bypass splashscreen if variables are already loaded
        if (state.location == '/') {
          final List<int>? conversionsOrderDrawer = ref
              .watch(PropertiesOrderNotifier.provider)
              .maybeWhen(data: (data) => data, orElse: () => null);
          final bool isConversionsLoaded = ref
              .watch(UnitsOrderNotifier.provider)
              .maybeWhen(data: (data) => true, orElse: () => false);

          if (isConversionsLoaded && conversionsOrderDrawer != null) {
            return '/conversions/${reversePageNumberListMap[conversionsOrderDrawer.indexWhere((val) => val == 0)]}';
          }
        }
        return null;
      },
      errorBuilder: (context, state) => const ErrorPage(),
    );

    bool deviceLocaleSetted = false;

    const Color fallbackColorSchemeSeed = Colors.blue;

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightColorScheme;
      ColorScheme darkColorScheme;
      if (lightDynamic != null && darkDynamic != null) {
        lightColorScheme = lightDynamic.harmonized();
        darkColorScheme = darkDynamic.harmonized();
      } else {
        // Otherwise, use fallback schemes.
        lightColorScheme = ColorScheme.fromSeed(
          seedColor: fallbackColorSchemeSeed,
        );
        darkColorScheme = ColorScheme.fromSeed(
          seedColor: fallbackColorSchemeSeed,
          brightness: Brightness.dark,
        );
      }

      ThemeData lightTheme = ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      );
      ThemeData darkTheme = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: darkColorScheme,
      );
      ThemeData amoledTheme = darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        drawerTheme: const DrawerThemeData(backgroundColor: Colors.black),
      );

      return Builder(builder: (BuildContext context) {
        return MaterialApp.router(
          routeInformationProvider: _router.routeInformationProvider,
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
          debugShowCheckedModeBanner: false,
          title: 'Converter NOW',
          themeMode: ref.watch(CurrentThemeMode.provider),
          theme: lightTheme,
          darkTheme: ref.watch(IsDarkAmoled.provider) ? amoledTheme : darkTheme,
          supportedLocales: mapLocale.keys,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          localeResolutionCallback:
              (Locale? deviceLocale, Iterable<Locale> supportedLocales) {
            if (!deviceLocaleSetted) {
              //context.read<AppModel>().deviceLocale = deviceLocale;
              deviceLocaleSetted = true;
            }
            if (supportedLocales
                .map((Locale locale) => locale.languageCode)
                .contains(deviceLocale?.languageCode)) {
              return deviceLocale;
            }
            return const Locale('en');
          },
          locale: ref.watch(CurrentLocale.provider),
        );
      });
    });
  }
}
