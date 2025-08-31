import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router.dart';

void main() async {

  // 💡 1. Flutter 바인딩 및 .env 파일 로드를 보장합니다.
  WidgetsFlutterBinding.ensureInitialized();
  
 // 💡 main 함수를 async로 변경하고, dotenv.load()를 호출합니다.
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
   url: dotenv.env['SUPABASE_URL']!,
   anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // ======================================================= //
  // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼ 아래 디버깅 코드를 추가하세요 ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼ //
  // ======================================================= //
  print('--- SUPABASE DEBUG INFO ---');
  print('✅ Initialized URL: ${dotenv.env['SUPABASE_URL']}');
  // 보안을 위해 Anon Key는 앞 10자리만 출력합니다.
  print('✅ Initialized Anon Key: ${dotenv.env['SUPABASE_ANON_KEY']?.substring(0, 10)}... ');
  print('👤 Current User: ${Supabase.instance.client.auth.currentUser}');
  print('--- END DEBUG INFO ---');
  // ======================================================= //
  // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲ //
  // ======================================================= //
  
  runApp(const ProviderScope(child: MyApp()));
}

// ⭐️ 모든 기기에서 드래그 스크롤을 가능하게 하는 클래스
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // ⭐️ 앱 전체에 새로운 스크롤 동작 적용
      scrollBehavior: MyCustomScrollBehavior(),
      title: '나눔 어드민',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}