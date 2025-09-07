// user_app/lib/features/user/auth/view/signup_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../../../services/juso_address_service.dart';
import '../../../../core/errors/app_exception.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 필수 입력 필드 (레벨 1)
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // 선택 입력 필드 (레벨 2용)
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  
  // 주소 검색 관련
  List<JusoAddressModel> _addressSearchResults = [];
  bool _isSearchingAddress = false;
  bool _showAddressResults = false;
  String? _selectedZipCode;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  // 주소 검색 메서드
  Future<void> _searchAddress(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        _addressSearchResults = [];
        _showAddressResults = false;
      });
      return;
    }

    setState(() {
      _isSearchingAddress = true;
      _showAddressResults = true;
    });

    try {
      final results = await JusoAddressService.searchAddress(keyword);
      setState(() {
        _addressSearchResults = results;
        _isSearchingAddress = false;
      });
    } catch (e) {
      setState(() {
        _addressSearchResults = [];
        _isSearchingAddress = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('주소 검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 주소 선택 메서드
  void _selectAddress(JusoAddressModel address) {
    setState(() {
      _addressController.text = address.roadAddr;
      _selectedZipCode = address.zipNo;
      _showAddressResults = false;
      _detailAddressController.clear();
    });
    
    FocusScope.of(context).requestFocus(FocusNode());
  }

 // 올바른 메시지와 동작으로 수정
void _showAlreadyRegisteredDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline, 
                color: Colors.orange.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '이미 가입된 회원',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '이미 가입된 이메일입니다.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '로그인 페이지로 이동합니다.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                
                // 약간의 지연 후 페이지 이동 (더 확실하게)
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (context.mounted) {
                    context.go('/login');
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    },
  );
}


  void _submit() {
    if (_formKey.currentState!.validate()) {

      print('🔍 회원가입 폼 데이터:');
    print('  - 전화번호 컨트롤러: "${_phoneController.text}"');
    print('  - 전화번호 trim: "${_phoneController.text.trim()}"');
    print('  - 전화번호 isEmpty: ${_phoneController.text.trim().isEmpty}');
    
    final phoneToSend = _phoneController.text.trim().isNotEmpty 
        ? _phoneController.text.trim() 
        : null;
    print('  - 전송할 전화번호: $phoneToSend');
    
      // 전체 주소 조합
      String fullAddress = _addressController.text.trim();
      if (_detailAddressController.text.trim().isNotEmpty) {
        fullAddress += ' ${_detailAddressController.text.trim()}';
      }
      if (_selectedZipCode != null && _selectedZipCode!.isNotEmpty) {
        fullAddress = '($_selectedZipCode) $fullAddress';
      }
      
      // 레벨 결정
      final hasOptionalInfo = _phoneController.text.trim().isNotEmpty && 
                             _addressController.text.trim().isNotEmpty;
      final level = hasOptionalInfo ? 2 : 1;
      
      ref.read(authViewModelProvider.notifier).signUp(
        fullName: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
        address: fullAddress.isNotEmpty ? fullAddress : null,
        level: level,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState is AsyncLoading;

    // signup_screen.dart의 ref.listen 부분에서 에러 처리 수정

ref.listen<AsyncValue<void>>(authViewModelProvider, (previous, next) {
  next.when(
    data: (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.mark_email_read, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '인증 이메일 발송 완료!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('📧 ${_emailController.text}'),
                const Text('위 이메일로 인증 링크를 발송했습니다.'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📌 다음 단계:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('1️⃣ 이메일 앱을 열어주세요'),
                      Text('2️⃣ "나눔마켓" 인증 메일을 찾아주세요'),
                      Text('3️⃣ 이메일 안의 "인증하기" 버튼을 클릭하세요'),
                      Text('4️⃣ 인증 완료 후 로그인해주세요'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
    },
    error: (error, _) {
      if (error is AuthenticationException) {
        // ⭐️ 중요: 정확한 메시지 체크
        if (error.message.contains('이미 가입된 이메일입니다')) {
          _showAlreadyRegisteredDialog(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(error.message)),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        // 기타 에러 처리...
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    loading: () {},
  );
});


    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '나눔마켓에 오신 것을 환영합니다!', 
                    style: Theme.of(context).textTheme.headlineSmall
                  ),
                  const SizedBox(height: 24),
                  
                  // 레벨 선택 안내
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '회원 등급 안내',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 레벨 1: 기본 정보만 입력 (구매 가능)\n• 레벨 2: 배송 정보까지 입력 (빠른 주문 가능/포인트 적립)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 필수 입력 필드들
                  Text(
                    '필수 정보',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? '필수 항목입니다.' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: '닉네임',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? '필수 항목입니다.' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || !value.contains('@'))
                        ? '유효한 이메일을 입력해주세요.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) => (value == null || value.length < 6)
                        ? '6자 이상 입력해주세요.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호 확인',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) => (value != _passwordController.text)
                        ? '비밀번호가 일치하지 않습니다.'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  
                  // 선택 정보 섹션 - 주소 검색 기능 포함
                  Card(
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          const Text('선택 정보 (레벨 2 회원)'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '추천',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: const Text('배송 정보를 미리 등록하여 빠른 주문이 가능합니다'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: '전화번호',
                                  border: OutlineInputBorder(),
                                  hintText: '010-1234-5678',
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              
                              // 주소 검색 필드
                              Text(
                                '주소',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              TextFormField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: '도로명주소 검색',
                                  border: const OutlineInputBorder(),
                                  hintText: '예: 테헤란로 123',
                                  suffixIcon: _isSearchingAddress 
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      )
                                    : const Icon(Icons.search),
                                ),
                                onChanged: (value) {
                                  Future.delayed(const Duration(milliseconds: 500), () {
                                    if (_addressController.text == value) {
                                      _searchAddress(value);
                                    }
                                  });
                                },
                                onTap: () {
                                  if (_addressController.text.isNotEmpty) {
                                    setState(() {
                                      _showAddressResults = true;
                                    });
                                  }
                                },
                              ),
                              
                              // 주소 검색 결과 리스트
                              if (_showAddressResults)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  child: _addressSearchResults.isEmpty
                                      ? Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            _isSearchingAddress 
                                                ? '주소를 검색하고 있습니다...'
                                                : '검색 결과가 없습니다.',
                                            style: TextStyle(color: Colors.grey.shade600),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _addressSearchResults.length,
                                          itemBuilder: (context, index) {
                                            final address = _addressSearchResults[index];
                                            return ListTile(
                                              dense: true,
                                              title: Text(
                                                address.roadAddr,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                              subtitle: Text(
                                                '(${address.zipNo}) ${address.jibunAddr}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              onTap: () => _selectAddress(address),
                                            );
                                          },
                                        ),
                                ),
                              
                              // 상세주소 입력 필드
                              if (_addressController.text.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _detailAddressController,
                                  decoration: const InputDecoration(
                                    labelText: '상세주소',
                                    border: OutlineInputBorder(),
                                    hintText: '동, 호수 등 상세주소를 입력해주세요',
                                  ),
                                ),
                              ],
                              
                              // 우편번호 표시
                              if (_selectedZipCode != null && _selectedZipCode!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, 
                                          color: Colors.green.shade600, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        '우편번호: $_selectedZipCode',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 가입하기 버튼
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
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
                        : const Text(
                            '가입하기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 로그인 페이지로 이동
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('이미 계정이 있으신가요?'),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('로그인'),
                      ),
                    ],
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