// admin_web/lib/features/auth/view/login_screen.dart (새 파일)

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // ⭐️ 2. authViewModelProvider의 상태 변화를 '감시'하는 리스너 추가
    ref.listen<AsyncValue>(authViewModelProvider, (_, state) {
      // 에러가 없고, 로딩 중도 아니라면 -> 로그인 성공 상태!
      if (!state.isLoading && !state.hasError) {
        // 대시보드로 즉시 화면을 이동시킵니다.
        context.go('/dashboard');
      }
      // 에러가 있다면 (이전 단계에서 추가한) 스낵바를 보여줍니다.
      else if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // ViewModel의 상태를 감시하여 로딩 중일 때 버튼을 비활성화
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('관리자 로그인', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: '이메일'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              ref.read(authViewModelProvider.notifier).signInWithPassword(
                                   _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                            },
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('로그인'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}