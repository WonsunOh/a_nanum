import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
   authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
    // ⭐️ 세션 만료 시간 설정 (초 단위, 30분 = 1800초)
    autoRefreshToken: true,
  ),
  );

  
  
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
   Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // ⭐️ 앱 전체에 새로운 스크롤 동작 적용
      scrollBehavior: MyCustomScrollBehavior(),
      title: '나눔 관리자',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
      ),
      // ⭐️ 2. localizationsDelegates에 FlutterQuillLocalizations.delegate를 추가합니다.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate, // 이 줄 추가
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어 지원
        Locale('en', 'US'), // 영어 지원 (기본)
      ],
      locale: const Locale('ko'), // 기본 언어를 한국어로 설정
    );
  }
}