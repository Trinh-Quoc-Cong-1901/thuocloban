import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thuoc_lo_ban_app/features/thuoc_lo_ban/bindings/thuoc_lo_ban_binding.dart';
import 'package:thuoc_lo_ban_app/features/thuoc_lo_ban/views/thuoc_lo_ban_screen.dart';
import 'package:thuoc_lo_ban_app/features/thuoc_lo_ban/views/guide_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Thước Lỗ Ban',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/thuoc-lo-ban',
      getPages: [
        GetPage(
          name: '/thuoc-lo-ban',
          page: () => const ThuocLoBanScreen(),
          binding: ThuocLoBanBinding(),
        ),
        GetPage(
          name: '/thuoc-lo-ban/guide',
          page: () => const GuideScreen(),
        ),
      ],
    );
  }
}