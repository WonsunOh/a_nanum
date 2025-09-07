// user_app/lib/features/user/level_upgrade/view/level_upgrade_form_screen.dart (API 연동 버전)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/user_provider.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../services/juso_address_service.dart';

class LevelUpgradeFormScreen extends ConsumerStatefulWidget {
  const LevelUpgradeFormScreen({super.key});

  @override
  ConsumerState<LevelUpgradeFormScreen> createState() => _LevelUpgradeFormScreenState();
}

class _LevelUpgradeFormScreenState extends ConsumerState<LevelUpgradeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressSearchController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isUpgrading = false;
  bool _isSearching = false;
  List<JusoAddressModel> _searchResults = [];
  JusoAddressModel? _selectedAddress;
  bool _showSearchResults = false;

  @override
  void dispose() {
    _addressSearchController.dispose();
    _detailAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 주소 검색
  Future<void> _searchAddress() async {
    if (_addressSearchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('검색할 주소를 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = false;
    });

    try {
      final results = await JusoAddressService.searchAddress(_addressSearchController.text.trim());
      setState(() {
        _searchResults = results;
        _showSearchResults = true;
      });

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('검색 결과가 없습니다. 다른 키워드로 검색해보세요.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('주소 검색 실패: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  // 주소 선택
  void _selectAddress(JusoAddressModel address) {
    setState(() {
      _selectedAddress = address;
      _showSearchResults = false;
      _addressSearchController.clear();
    });
    
    // 상세주소 입력에 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  // 선택된 주소 제거
  void _clearSelectedAddress() {
    setState(() {
      _selectedAddress = null;
      _detailAddressController.clear();
    });
  }

 Future<void> _upgradeToLevel2() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedAddress == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('주소를 검색하여 선택해주세요.')),
    );
    return;
  }

  setState(() => _isUpgrading = true);

  try {
    final profileRepository = ref.read(profileRepositoryProvider);
    
    // 완성된 주소 생성
    final fullAddress = '${_selectedAddress!.roadAddr} ${_detailAddressController.text.trim()}'.trim();
    
    // ⭐️ 주소, 전화번호, 우편번호 모두 업데이트 + 레벨 2로 업그레이드
    await profileRepository.updateProfileAndLevel(
      address: fullAddress,
      postcode: _selectedAddress!.zipNo, // ⭐️ 우편번호 추가
      phoneNumber: _phoneController.text.trim(),
      newLevel: 2,
    );

    // userProvider 새로고침하여 최신 정보 반영
    ref.invalidate(userProvider);

    if (mounted) {
      _showUpgradeCompleteDialog();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('레벨 업그레이드 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isUpgrading = false);
  }
}

  void _showUpgradeCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.celebration,
          size: 64,
          color: Colors.blue.shade600,
        ),
        title: const Text('레벨 업그레이드 완료!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('축하합니다!'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '레벨 1 → 레벨 2 (일반회원)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '이제 더 많은 혜택을 이용할 수 있습니다!',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/shop/mypage');
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('레벨 업그레이드'),
        centerTitle: true,
      ),
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('에러: $e')),
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(child: Text('사용자 정보를 찾을 수 없습니다.'));
          }

          if (userProfile.level >= 2) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green.shade600),
                  const SizedBox(height: 16),
                  const Text('이미 레벨 2 이상입니다.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/shop/mypage'),
                    child: const Text('마이페이지로 돌아가기'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 레벨 업그레이드 헤더
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.blue.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up, size: 48, color: Colors.blue.shade600),
                        const SizedBox(height: 12),
                        const Text(
                          '레벨 2 업그레이드',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '레벨 1',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.arrow_forward, color: Colors.blue.shade600),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '레벨 2',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 주소 검색 섹션
                  const Text(
                    '배송 주소 *',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // 선택된 주소가 없는 경우: 주소 검색
                  if (_selectedAddress == null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _addressSearchController,
                            decoration: const InputDecoration(
                              hintText: '도로명 또는 건물명을 입력하세요',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(16),
                            ),
                            onFieldSubmitted: (_) => _searchAddress(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSearching ? null : _searchAddress,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          child: _isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('검색'),
                        ),
                      ],
                    ),
                    
                    // 검색 결과 리스트
                    if (_showSearchResults) ...[
                      const SizedBox(height: 16),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _searchResults.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(child: Text('검색 결과가 없습니다.')),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                                itemBuilder: (context, index) {
                                  final address = _searchResults[index];
                                  return ListTile(
                                    title: Text(
                                      address.roadAddr,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (address.jibunAddr.isNotEmpty)
                                          Text(
                                            address.jibunAddr,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        Text(
                                          '우편번호: ${address.zipNo}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _selectAddress(address),
                                  );
                                },
                              ),
                      ),
                    ],
                  ] else ...[
                    // 선택된 주소 표시
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                '선택된 주소',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _clearSelectedAddress,
                                icon: const Icon(Icons.close, size: 20),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedAddress!.roadAddr,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '우편번호: ${_selectedAddress!.zipNo}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 상세주소 입력
                    const Text(
                      '상세주소',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _detailAddressController,
                      decoration: const InputDecoration(
                        hintText: '동/호수를 입력하세요 (예: 101동 1201호)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '상세주소를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 전화번호 입력
                  const Text(
                    '전화번호 *',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '예: 010-1234-5678',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '전화번호를 입력해주세요.';
                      }
                      if (value.trim().length < 10) {
                        return '올바른 전화번호를 입력해주세요.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // 혜택 안내
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.green.shade600),
                            const SizedBox(width: 8),
                            Text(
                              '레벨 2 혜택',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('• 빠른 주문 (배송 정보 자동 입력)'),
                        const Text('• 포인트 적립 혜택'),
                        const Text('• 우선 구매 기회'),
                        const Text('• 특별 할인 이벤트 참여'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 업그레이드 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isUpgrading ? null : _upgradeToLevel2,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isUpgrading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('업그레이드 중...'),
                              ],
                            )
                          : const Text(
                              '레벨 2로 업그레이드하기',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}