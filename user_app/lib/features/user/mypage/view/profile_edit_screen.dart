// user_app/lib/features/user/mypage/view/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../../../providers/user_provider.dart';
import '../../../order/widgets/juso_address_search_widget.dart';
import '../viewmodel/profile_edit_viewmodel.dart';



class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();

  bool _isInitialized = false;
  bool _isLevelUpgradeMode = false;
  

  @override
  void dispose() {
    _nicknameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _postcodeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProvider);
    final editState = ref.watch(profileEditViewModelProvider);

    // 사용자 정보 로딩 후 필드 초기화
    userProfileAsync.whenData((profile) {
      if (!_isInitialized && profile != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeFields(profile);
          _isLevelUpgradeMode = profile.level == 1;
          _isInitialized = true;
        });
      }
    });

    // 상태 변화 감지
    ref.listen<ProfileEditState>(profileEditViewModelProvider, (
      previous,
      next,
    ) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  _isLevelUpgradeMode ? '레벨 2로 업그레이드되었습니다!' : '프로필이 업데이트되었습니다!',
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLevelUpgradeMode ? '레벨 업그레이드' : '프로필 편집'),
        backgroundColor: _isLevelUpgradeMode ? Colors.orange : Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: userProfileAsync.when(
        data: (profile) => _buildContent(profile, editState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('프로필 정보를 불러올 수 없습니다: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(dynamic profile, ProfileEditState editState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 레벨 업그레이드 안내
            if (_isLevelUpgradeMode) _buildLevelUpgradeGuide(),

            // 기본 정보 섹션
            _buildSectionHeader('기본 정보'),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _fullNameController,
              label: '이름',
              hint: '실명을 입력해주세요',
              icon: Icons.person,
              isRequired: _isLevelUpgradeMode,
              validator: _isLevelUpgradeMode
                  ? (v) => v!.isEmpty ? '이름은 필수 항목입니다' : null
                  : null,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _nicknameController,
              label: '닉네임',
              hint: '사용할 닉네임을 입력해주세요',
              icon: Icons.badge,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _phoneController,
              label: '전화번호',
              hint: '010-1234-5678',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              isRequired: _isLevelUpgradeMode,
              // inputFormatters: [PhoneInputFormatter()],
              validator: (value) {
    if (_isLevelUpgradeMode && (value == null || value.isEmpty)) {
      return '전화번호는 필수 항목입니다';
    }
    if (value != null && value.isNotEmpty && !PhoneNumberUtils.isValidPhoneNumber(value)) {
      return '올바른 전화번호 형식이 아닙니다';
    }
    return null;
  },
            ),

            const SizedBox(height: 24),

            // 배송 정보 섹션
            _buildSectionHeader(
              _isLevelUpgradeMode ? '배송 정보 (레벨 2 필수)' : '배송 정보',
            ),
            const SizedBox(height: 16),

            // 우편번호 + 주소 찾기
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _postcodeController,
                    label: '우편번호',
                    hint: '12345',
                    icon: Icons.markunread_mailbox,
                    readOnly: true,
                    isRequired: _isLevelUpgradeMode,
                    validator: _isLevelUpgradeMode
                        ? (v) => v!.isEmpty ? '주소를 검색해주세요' : null
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openAddressSearch,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('주소 찾기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLevelUpgradeMode
                          ? Colors.orange
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _addressController,
              label: '기본 주소',
              hint: '주소 검색을 통해 자동 입력됩니다',
              icon: Icons.location_on,
              readOnly: true,
              isRequired: _isLevelUpgradeMode,
              validator: _isLevelUpgradeMode
                  ? (v) => v!.isEmpty ? '주소를 검색해주세요' : null
                  : null,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _detailAddressController,
              label: '상세 주소',
              hint: '동/호수를 입력하세요 (예: 101동 1201호)',
              icon: Icons.home,
              isRequired: _isLevelUpgradeMode,
              validator: _isLevelUpgradeMode
                  ? (v) => v!.isEmpty ? '상세 주소를 입력해주세요' : null
                  : null,
            ),

            const SizedBox(height: 32),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: editState.isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLevelUpgradeMode
                      ? Colors.orange
                      : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: editState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isLevelUpgradeMode ? '레벨 2로 업그레이드' : '저장하기',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelUpgradeGuide() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                '레벨 2 회원 혜택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '✓ 주문 시 배송정보 자동입력\n✓ 포인트 적립 혜택\n✓ 우선 고객지원\n✓ 특별 할인 혜택',
            style: TextStyle(color: Colors.orange.shade700, height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 정보를 모두 입력하면 자동으로 레벨 2로 업그레이드됩니다.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool isRequired = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _isLevelUpgradeMode ? Colors.orange : Colors.blue,
            width: 2,
          ),
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade50 : null,
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }

  // ✅ 전화번호 필드에 포맷터 적용
  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: '전화번호',
      hint: '010-1234-5678',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      isRequired: _isLevelUpgradeMode,
      inputFormatters: [PhoneInputFormatter()], // 포맷터 적용
      validator: (value) {
        if (_isLevelUpgradeMode && (value == null || value.isEmpty)) {
          return '전화번호는 필수 항목입니다';
        }
        if (value != null && value.isNotEmpty && !PhoneNumberUtils.isValidPhoneNumber(value)) {
          return '올바른 전화번호 형식이 아닙니다';
        }
        return null;
      },
    );
  }

  void _initializeFields(dynamic profile) {
    print('🔍 Profile 데이터 확인:');
  print('- Phone Number: ${profile?.phoneNumber}');

    if (profile == null) return;
  setState(() {
    // 기본 정보 초기화
    _nicknameController.text = profile?.nickname ?? '';
    _fullNameController.text = profile?.fullName ?? '';
    
    /// ✅ 안전한 전화번호 포맷팅
      final phoneNumber = profile.phoneNumber;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        try {
          _phoneController.text = PhoneNumberUtils.formatPhoneNumber(phoneNumber);
        } catch (e) {
          print('전화번호 포맷팅 에러: $e');
          _phoneController.text = phoneNumber; // 에러 시 원본 사용
        }
      } else {
        _phoneController.text = '';
      }
    
    // ✅ 우편번호 별도 초기화
    if (profile?.postcode != null && profile!.postcode!.isNotEmpty) {
      _postcodeController.text = profile.postcode!;
    } else {
      _postcodeController.text = '';
    }
    
    // ✅ 주소 처리 - 기존 데이터가 "(우편번호) 주소" 형태일 수 있으므로 파싱
    if (profile?.address != null && profile!.address!.isNotEmpty) {
      _parseAndFillAddress(profile.address!);
    } else {
      _addressController.text = '';
      _detailAddressController.text = '';
    }
  });
}


void _parseAndFillAddress(String fullAddress) {
  print('🔍 주소 파싱 시작: $fullAddress');
  
  // 1단계: 우편번호 분리
  final regexWithPostcode = RegExp(r'\((\d{5})\)\s*(.+)');
  final match = regexWithPostcode.firstMatch(fullAddress);
  
  String remainingAddress = fullAddress;
  
  if (match != null) {
    /// 우편번호가 이미 별도 필드에 있다면 덮어쓰지 않음
    if (_postcodeController.text.isEmpty) {
      _postcodeController.text = match.group(1) ?? '';
    }
    
    remainingAddress = match.group(2)?.trim() ?? '';
  }
  
  print('📮 우편번호: ${_postcodeController.text}');
  print('🏠 남은 주소: $remainingAddress');
  
  // 2단계: 상세주소 분리 (여러 패턴 시도)
  String baseAddress = remainingAddress;
  String detailAddress = '';
  
  // 패턴 1: "동/호" 형태의 상세주소 (예: "101동 1201호", "A동 501호")
  final pattern1 = RegExp(r'^(.+?)\s+([A-Za-z]?\d+동\s*\d+호)$');
  final match1 = pattern1.firstMatch(remainingAddress);
  
  if (match1 != null) {
    baseAddress = match1.group(1)?.trim() ?? '';
    detailAddress = match1.group(2)?.trim() ?? '';
    print('✅ 패턴1 매칭: 동/호');
  } else {
    // 패턴 2: "호수" 형태의 상세주소 (예: "1201호", "501호")
    final pattern2 = RegExp(r'^(.+?)\s+(\d+호)$');
    final match2 = pattern2.firstMatch(remainingAddress);
    
    if (match2 != null) {
      baseAddress = match2.group(1)?.trim() ?? '';
      detailAddress = match2.group(2)?.trim() ?? '';
      print('✅ 패턴2 매칭: 호수');
    } else {
      // 패턴 3: "층" 형태의 상세주소 (예: "3층", "지하1층")
      final pattern3 = RegExp(r'^(.+?)\s+(지하\d+층|\d+층)$');
      final match3 = pattern3.firstMatch(remainingAddress);
      
      if (match3 != null) {
        baseAddress = match3.group(1)?.trim() ?? '';
        detailAddress = match3.group(2)?.trim() ?? '';
        print('✅ 패턴3 매칭: 층');
      } else {
        // 패턴 4: "건물명 + 동/호/층" (예: "엘지트윈타워 A동 1201호")
        final pattern4 = RegExp(r'^(.+?)\s+([A-Za-z]?\d*[동층호]\s*[A-Za-z]?\d*[동층호]?)$');
        final match4 = pattern4.firstMatch(remainingAddress);
        
        if (match4 != null) {
          baseAddress = match4.group(1)?.trim() ?? '';
          detailAddress = match4.group(2)?.trim() ?? '';
          print('✅ 패턴4 매칭: 건물명+상세');
        } else {
          // 패턴 5: 마지막 공백 이후를 상세주소로 판단 (숫자로 시작하는 경우)
          final parts = remainingAddress.split(' ');
          if (parts.length >= 2) {
            final lastPart = parts.last;
            // 마지막 부분이 숫자로 시작하고 "동", "호", "층" 중 하나를 포함하는 경우
            if (RegExp(r'^\d+.*[동호층]').hasMatch(lastPart) || 
                RegExp(r'^[A-Za-z]\d+.*[동호층]').hasMatch(lastPart)) {
              detailAddress = lastPart;
              baseAddress = parts.sublist(0, parts.length - 1).join(' ');
              print('✅ 패턴5 매칭: 마지막 부분');
            }
          }
        }
      }
    }
  }
  
  // 결과가 비어있으면 전체를 기본주소로 처리
  if (baseAddress.isEmpty) {
    baseAddress = remainingAddress;
    detailAddress = '';
  }
  
  setState(() {
    _addressController.text = baseAddress;
    _detailAddressController.text = detailAddress;
  });
  
  print('🏗️ 기본주소: $baseAddress');
  print('🏠 상세주소: $detailAddress');
}

  void _openAddressSearch() {
    final isWideScreen = MediaQuery.of(context).size.width > 768;

    if (isWideScreen) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 100,
            vertical: 40,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: JusoAddressSearchWidget(
              onAddressSelected: _onAddressSelected,
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: JusoAddressSearchWidget(onAddressSelected: _onAddressSelected),
        ),
      );
    }
  }

  void _onAddressSelected(Map<String, String> addressData) {
    setState(() {
      _postcodeController.text = addressData['zonecode'] ?? '';
      final roadAddress = addressData['roadAddress'] ?? '';
      final jibunAddress = addressData['jibunAddress'] ?? '';
      _addressController.text = roadAddress.isNotEmpty
          ? roadAddress
          : jibunAddress;
    });

    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    // ✅ 전체 주소 정보를 올바르게 구성
    final postcode = _postcodeController.text.trim();
    final address = _addressController.text.trim();
    final detailAddress = _detailAddressController.text.trim();

    // ✅ 전화번호에서 숫자만 추출
  final phoneNumber = PhoneNumberUtils.extractDigits(_phoneController.text);

    // 기본 주소 + 상세 주소 합치기
    final fullAddress = detailAddress.isNotEmpty
        ? '$address $detailAddress'
        : address;

    if (_isLevelUpgradeMode) {
      ref
          .read(profileEditViewModelProvider.notifier)
          .upgradeToLevel2(
            fullName: _fullNameController.text,
            phoneNumber: _phoneController.text,
            address: fullAddress, // ✅ 전체 주소 (기본주소 + 상세주소)
            postcode: postcode, // ✅ 우편번호
            nickname: _nicknameController.text.isNotEmpty
                ? _nicknameController.text
                : null,
          );
    } else {
      ref
          .read(profileEditViewModelProvider.notifier)
          .updateProfile(
            nickname: _nicknameController.text.isNotEmpty
                ? _nicknameController.text
                : null,
            fullName: _fullNameController.text.isNotEmpty
                ? _fullNameController.text
                : null,
            phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
            address: fullAddress.isNotEmpty ? fullAddress : null, // ✅ 전체 주소
            postcode: postcode.isNotEmpty ? postcode : null, // ✅ 우편번호
          );
    }
  }
}
