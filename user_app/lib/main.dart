import 'package:a_micro_divide/core/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- 👇 여기가 핵심 수정 부분 ---
  // Firebase 앱을 초기화하고, 완료될 때까지 기다립니다.
  // DefaultFirebaseOptions.currentPlatform는 firebase_options.dart 파일에 정의되어 있습니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  // ⭐️ 카카오 SDK 초기화
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

  // ⭐️ 2. Supabase 초기화 코드를 여기에 추가합니다.
  // .env 파일에 저장된 URL과 ANON KEY를 사용하여 Supabase와 연결합니다.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );




  runApp(
    const ProviderScope( // Riverpod 사용을 위한 ProviderScope
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // routerProvider를 사용하여 라우터 설정을 MaterialApp에 적용합니다.
    final router = ref.watch(routerProvider);
    

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: '나눔 스토어',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
    );
  }
}
