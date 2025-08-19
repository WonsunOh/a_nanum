import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';

void main() async {
  // 💡 main 함수를 async로 변경하고, dotenv.load()를 호출합니다.
  await dotenv.load(fileName: ".env");
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: '공동구매 관리자 페이지',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
    );
  }
}