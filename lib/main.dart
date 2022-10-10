import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gorouter_nested_navigator/screens/detailed_screen.dart';
import 'package:gorouter_nested_navigator/screens/root_screen.dart';

void main() {
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);

  runApp(const MyApp());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// this is simpler than beamer but it cannot hold the state for nested navigation
// currently there is a PR to fix this

final _goRouter = GoRouter(
  initialLocation: '/a',
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ScaffoldWithBottomNavBar(child: child),
      routes: [
        GoRoute(
          path: '/a',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const RootScreen(label: 'A', detailsPath: '/a/details'),
          ),
          routes: [
            GoRoute(
              path: 'details',
              builder: (context, state) => const DetailsScreen(label: 'A'),
            )
          ],
        ),
        GoRoute(
          path: '/b',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const RootScreen(label: 'B', detailsPath: '/b/details'),
          ),
          routes: [
            GoRoute(
              path: 'details',
              builder: (context, state) => const DetailsScreen(label: 'B'),
            )
          ],
        )
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _goRouter);
  }
}

const tabs = [
  ScaffoldWithNavBarTabItem(
    initialLocation: '/a',
    icon: Icon(Icons.home),
    label: 'Section A',
  ),
  ScaffoldWithNavBarTabItem(
    initialLocation: '/b',
    icon: Icon(Icons.settings),
    label: 'Section B',
  ),
];

class ScaffoldWithBottomNavBar extends StatefulWidget {
  final Widget child;
  const ScaffoldWithBottomNavBar({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  int get _currentIndex => _locationToTabIndex(GoRouter.of(context).location);

  int _locationToTabIndex(String location) {
    final index = tabs.indexWhere((element) => location.startsWith(element.initialLocation));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: tabs,
        onTap: (index) {
          if (index != _currentIndex) {
            context.go(tabs[index].initialLocation);
          }
        },
      ),
    );
  }
}

class ScaffoldWithNavBarTabItem extends BottomNavigationBarItem {
  final String initialLocation;

  const ScaffoldWithNavBarTabItem({
    Key? key,
    required this.initialLocation,
    required super.icon,
    super.label,
  });
}
