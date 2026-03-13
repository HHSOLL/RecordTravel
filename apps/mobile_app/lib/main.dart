import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'bootstrap/mobile_app_bootstrap.dart';
import 'bootstrap/mobile_app_runtime_loader.dart';
import 'shell/mobile_app_shell.dart';

Future<void> main() async {
  final runtime = await loadMobileAppRuntime();
  runApp(MobileAppBootstrap(runtime: runtime, child: const TravelAtlasApp()));
}

class TravelAtlasApp extends StatelessWidget {
  const TravelAtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Atlas',
      debugShowCheckedModeBanner: false,
      theme: AtlasTheme.buildTheme(),
      home: const MobileAppShell(),
    );
  }
}
