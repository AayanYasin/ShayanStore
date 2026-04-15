import 'package:flutter/material.dart';
import 'dart:ui';
import 'core/theme.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const EcomApp());
}

class EcomApp extends StatelessWidget {
  const EcomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shayan Mart',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse, 
          PointerDeviceKind.touch, 
          PointerDeviceKind.stylus, 
          PointerDeviceKind.unknown
        },
      ),
      theme: AppTheme.lightTheme,
      home: const AuthScreen(),
    );
  }
}
