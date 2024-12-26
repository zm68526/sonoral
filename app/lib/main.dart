import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonoral_app/config.dart';
import 'package:sonoral_app/studio/studio.dart';
import 'package:sonoral_app/studio/studio_splash.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await initializeHive();
  await initializeSoLoud();
  runApp(SonoralApp());
}

Future<void> initializeHive() async {
  if (!kIsWeb) {
    String path = (await getApplicationDocumentsDirectory()).path;
    Hive.init('$path/hive');
  }

  await Hive.openBox('savedCompositions');
  final box = Hive.box('savedCompositions');
  if (box.get('scripts') == null) {
    await box.put('scripts', <String>['']);
  }
}

Future<void> initializeSoLoud() async {
  final soloud = SoLoud.instance;
  await soloud.init();
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
// final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

// The root of the app
class SonoralApp extends StatelessWidget {
  SonoralApp({super.key});

  // The main router for the app
  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/studio',
                builder: (context, state) => const StudioSplash(),
                routes: [
                  GoRoute(
                    path: '/project/:id',
                    builder: (context, state) {
                      return StudioWidget(
                          id: int.tryParse(state.pathParameters['id']!));
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // wrap in futurebuilder until audio engine and hive initialized?
    return MaterialApp.router(
      title: 'Sonoral',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// The main scaffold for the app, contains the navigation shell and the bottom navigation bar
class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12.5,
        showSelectedLabels: showBottomNavigationBarLabels,
        showUnselectedLabels: showBottomNavigationBarLabels,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.create), label: 'Studio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
