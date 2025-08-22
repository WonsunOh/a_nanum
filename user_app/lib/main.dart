import 'package:a_micro_divide/core/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  // --- 👆 여기까지 ---

  await Supabase.initialize(
    url: 'https://oyoznvosuyxhgxmbfaow.supabase.co', // Supabase 프로젝트 URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im95b3pudm9zdXl4aGd4bWJmYW93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU0Mzg4OTIsImV4cCI6MjA3MTAxNDg5Mn0.0BdGBHUK_Q64ZWhsyia_7toDwC42zM0xLzi7yPx6V4s', // Supabase Anon Key
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
      title: '소규모 공구 플랫폼',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
    );
  }
}
