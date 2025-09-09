// user_app/lib/features/user/mypage/view/mypage_screen.dart (수정 버전)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/provider/auth_provider.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../../providers/user_provider.dart';

// 상수 정의
class _Constants {
  static const double profileCardPadding = 20;
  static const double avatarRadius = 40;
  static const double menuItemMargin = 8;
  static const double iconContainerPadding = 8;
  static const int baseFontSize = 16;
}

// 레벨 정보를 enum으로 관리
enum UserLevel {
  newbie(1, '신규회원', Colors.green),
  regular(2, '일반회원', Colors.blue),
  premium(5, '우수회원', Colors.purple),
  master(10, '공구장', Colors.orange);

  const UserLevel(this.level, this.name, this.color);

  final int level;
  final String name;
  final Color color;

  static UserLevel fromLevel(int level) {
    return UserLevel.values.firstWhere(
      (e) => e.level == level,
      orElse: () => UserLevel.regular,
    );
  }
}

// 메뉴 아이템을 별도 클래스로 정의
class MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? route;
  final VoidCallback? onTap;
  final bool isHighlight;
  final Color? highlightColor;

  const MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.route,
    this.onTap,
    this.isHighlight = false,
    this.highlightColor,
  });
}

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  // 메뉴 아이템들을 캐시해서 성능 최적화
  List<MenuItemData>? _cachedMenuItems;
  int? _lastUserLevel;

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateChangeProvider, (previous, next) {
      if (next.value?.event == AuthChangeEvent.signedOut) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/shop');
          }
        });
      }
    });

    final userProfileAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지'), centerTitle: true),
      body: userProfileAsync.when(
        data: (profile) => _buildContent(profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _buildErrorWidget(e),
      ),
    );
  }

  Widget _buildContent(dynamic profile) {
    // 레벨이 변경되었을 때만 메뉴 재생성
    if (_cachedMenuItems == null || _lastUserLevel != profile?.level) {
      _cachedMenuItems = _buildMenuItems(profile);
      _lastUserLevel = profile?.level;
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(profile),
            const SizedBox(height: 24),
            ..._buildMenuItemWidgets(_cachedMenuItems!),
          ],
        ),
      ),
    );
  }

  // 프로필 카드 개선
  Widget _buildProfileCard(dynamic profile) {
    final userLevel = UserLevel.fromLevel(profile?.level ?? 1);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(_Constants.profileCardPadding),
        child: Row(
          children: [
            Stack(
              children: [
                // 프로필 이미지 기능 완전 제거, 기본 아이콘만 사용
                CircleAvatar(
                  radius: _Constants.avatarRadius,
                  backgroundColor: userLevel.color.withValues(alpha: 0.1),
                  child: Icon(Icons.person, size: 50, color: userLevel.color),
                ),
                // 레벨 배지
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: userLevel.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '${userLevel.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.nickname ?? profile?.fullName ?? '사용자',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.fullName ?? '프로필 정보 없음',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  _buildLevelBadge(userLevel, profile?.points ?? 0),
                  if (userLevel.level >= 2) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getLevelBenefit(userLevel.level),
                      style: TextStyle(
                        fontSize: 11,
                        color: userLevel.color,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge(UserLevel userLevel, int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: userLevel.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: userLevel.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getLevelIcon(userLevel.level),
            size: 14,
            color: userLevel.color,
          ),
          const SizedBox(width: 4),
          Text(
            '레벨 ${userLevel.level} • ${userLevel.name} • ${points}P',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: userLevel.color,
            ),
          ),
        ],
      ),
    );
  }

  // 레벨별 아이콘 추가
  IconData _getLevelIcon(int level) {
    switch (level) {
      case 1:
        return Icons.eco; // 신규회원 - 친환경 아이콘
      case 2:
        return Icons.person; // 일반회원
      case 5:
        return Icons.star; // 우수회원
      case 10:
        return Icons.military_tech; // 공구장 - 메달 아이콘
      default:
        return Icons.person;
    }
  }

  // 레벨별 혜택 설명
  String _getLevelBenefit(int level) {
    switch (level) {
      case 2:
        return '배송정보 자동입력, 포인트 적립';
      case 5:
        return '우선 고객지원, 특별 할인 혜택';
      case 10:
        return '공구 개설 권한, 최고 등급 혜택';
      default:
        return '';
    }
  }

  List<MenuItemData> _buildMenuItems(dynamic profile) {
    final items = <MenuItemData>[
      // ✅ 1. 주문내역 (첫 번째로 이동)
      const MenuItemData(
        icon: Icons.receipt_long_outlined,
        title: '주문내역',
        subtitle: '구매한 상품 내역',
        route: '/shop/mypage/orders',
      ),
      // ✅ 2. 찜한목록 (두 번째)
      const MenuItemData(
        icon: Icons.favorite_border_outlined,
        title: '찜한목록',
        route: '/shop/mypage/wishlist',
      ),
      // ✅ 3. 내가쓴글 (세 번째)
      const MenuItemData(
        icon: Icons.edit_note_outlined,
        title: '내가쓴글',
        route: '/shop/mypage/posts',
      ),
      // ✅ 4. 프로필편집 (네 번째)
      const MenuItemData(
        icon: Icons.edit_outlined,
        title: '프로필편집',
        subtitle: '개인정보 및 배송지 수정',
        route: '/shop/mypage/profile-edit',
      ),
    ];

    // 레벨 1인 경우 업그레이드 안내 메뉴
    if (profile?.level == 1) {
      items.add(
        MenuItemData(
          icon: Icons.trending_up_outlined,
          title: '레벨 업그레이드',
          subtitle: '배송 정보 입력하고 레벨 2가 되세요!',
          route: '/shop/mypage/profile-edit', // 프로필 편집으로 직접 이동
          isHighlight: true,
          highlightColor: Colors.orange,
        ),
      );
    }

    items.add(
      MenuItemData(
        icon: Icons.logout_outlined,
        title: '로그아웃',
        onTap: () => _showLogoutDialog(context, ref),
      ),
    );

    return items;
  }

  List<Widget> _buildMenuItemWidgets(List<MenuItemData> items) {
    return items
        .map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: _Constants.menuItemMargin),
            child: Card(
              elevation: item.isHighlight ? 3 : 1,
              color: item.isHighlight
                  ? (item.highlightColor ?? Colors.blue).withValues(alpha: 0.05)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(
                    _Constants.iconContainerPadding,
                  ),
                  decoration: BoxDecoration(
                    color: item.isHighlight
                        ? (item.highlightColor ?? Colors.blue).withValues(
                            alpha: 0.1,
                          )
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isHighlight
                        ? (item.highlightColor ?? Colors.blue.shade700)
                        : Colors.grey.shade700,
                    size: 24,
                  ),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    color: item.isHighlight
                        ? (item.highlightColor ?? Colors.blue.shade700)
                        : null,
                    fontWeight: item.isHighlight
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: _Constants.baseFontSize.toDouble(),
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: TextStyle(
                          color: item.isHighlight
                              ? (item.highlightColor ?? Colors.blue.shade600)
                              : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      )
                    : null,
                trailing: item.isHighlight
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      )
                    : Icon(Icons.chevron_right, color: Colors.grey.shade400),
                onTap:
                    item.onTap ??
                    () {
                      if (item.route != null) {
                        context.go(item.route!);
                      }
                    },
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              '프로필 정보를 불러올 수 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(userProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(authViewModelProvider.notifier).signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }
}
