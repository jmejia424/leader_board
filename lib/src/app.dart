import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader_board/src/localization/string_hardcoded.dart';
import 'package:leader_board/src/routing/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    // clear the mode to reset to ModeStatus.unassigned();
    // ref.read(settingsServiceProvider).clearMode();
    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      onGenerateTitle: (BuildContext context) => 'Leader Board'.hardcoded,
      theme: ThemeData(
        // * Use this to toggle Material 3 (defaults to true since Flutter 3.16)
        useMaterial3: true,
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // background (button) color
            foregroundColor: Colors.white, // foreground (text) color
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black, // background (button) color
          foregroundColor: Colors.white, // foreground (text) color
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigo),
          ),
        ),
      ),
    );
  }
}
