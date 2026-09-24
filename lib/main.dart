import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'pages/home_page.dart';
import 'pages/bypass_page.dart';

void main() {
  runApp(const DeltaBypassApp());
}

class DeltaBypassApp extends StatelessWidget {
  const DeltaBypassApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MiuixSystemTheme 自动跟随系统明暗模式并应用 Miuix 配色
    return MiuixSystemTheme(
      child: Builder(
        builder: (context) {
          final theme = MiuixTheme.of(context);
          return MaterialApp(
            title: 'Delta Bypass',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: theme.colors.primary,
                brightness: theme.brightness,
              ),
              brightness: theme.brightness,
            ),
            home: const MainShell(),
          );
        },
      ),
    );
  }
}

/// 底部悬浮导航容器
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomePage(),
    BypassPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MiuixScaffold(
      content: (padding) => IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomBar: MiuixFloatingNavigationBar(
        children: [
          MiuixFloatingNavigationBarItem(
            selected: _index == 0,
            onPressed: () => setState(() => _index = 0),
            icon: const Icon(Icons.home_outlined, size: 24),
            label: '主页',
          ),
          MiuixFloatingNavigationBarItem(
            selected: _index == 1,
            onPressed: () => setState(() => _index = 1),
            icon: const Icon(Icons.bolt_outlined, size: 24),
            label: '绕过',
          ),
        ],
      ),
    );
  }
}