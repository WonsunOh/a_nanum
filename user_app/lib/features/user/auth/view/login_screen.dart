import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router.dart';
import '../viewmodel/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // authViewModelProvider의 상태를 감시(watch)합니다.
    ref.listen(authViewModelProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString())),
        );
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: '이메일'),
                validator: (value) => (value == null || value.isEmpty) ? '이메일을 입력해주세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) => (value == null || value.isEmpty) ? '비밀번호를 입력해주세요' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : () {
                  if (_formKey.currentState!.validate()) {
                    ref.read(authViewModelProvider.notifier).signInWithEmail(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );
                  }
                },
                child: isLoading ? const CircularProgressIndicator() : const Text('로그인'),
              ),
              TextButton(
                onPressed: () => context.goNamed(AppRoute.signup.name),
                child: const Text('아직 회원이 아니신가요? 회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}