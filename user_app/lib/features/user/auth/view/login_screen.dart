// user_app/lib/features/user/auth/view/login_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'signup_screen.dart'; // 회원가입 화면 import

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
    ref.listen<AsyncValue>(authViewModelProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (!state.hasError &&
          !state.isLoading &&
          state.valueOrNull != null) {
        final fromPath = GoRouterState.of(context).uri.queryParameters['from'];
        context.go(fromPath ?? '/shop');
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '다시 만나서 반가워요!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
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
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          ref
                              .read(authViewModelProvider.notifier)
                              .signInWithPassword(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('로그인'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('또는'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24.0,
                    ),
                    label: const Text('Google 계정으로 로그인'),
                    onPressed: isLoading
                        ? null
                        : () {
                            ref
                                .read(authViewModelProvider.notifier)
                                .signInWithGoogle();
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12), // 버튼 사이 간격 추가
                OutlinedButton.icon(
                  icon: Image.asset(
                    'assets/images/kakao_logo.png',
                    height: 24.0,
                  ), // ⭐️ 카카오 로고
                  label: const Text('카카오 계정으로 로그인'),
                  onPressed: isLoading
                      ? null
                      : () {
                          ref
                              .read(authViewModelProvider.notifier)
                              .signInWithKakao();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('아직 회원이 아니신가요?'),
                    TextButton(
                      onPressed: () {
                        // TODO: 회원가입 페이지 경로 확인 및 이동
                        context.go('/signup');
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (_) => const SignupScreen(),
                        //   ),
                        // );
                      },
                      child: const Text('회원가입'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
