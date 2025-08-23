import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/user_provider.dart';
import '../../user/auth/viewmodel/auth_viewmodel.dart';
import '../../user/mypage/view/mypage_screen.dart';
import '../viewmodel/home_viewmodel.dart';
import '../widgets/product_card.dart';
import 'select_product_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // groupBuysProvider를 watch하여 데이터 상태를 가져옵니다.
    final groupBuysAsyncValue = ref.watch(homeViewModelProvider);
    final userProfileAsync = ref.watch(userProvider);
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('공동구매 목록'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 검색 기능 구현 시 연결
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
        drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer 상단 헤더
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal, // 앱의 테마 색상과 맞춥니다.
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // 마이페이지 메뉴
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('마이페이지'),
              onTap: () {
                // Drawer를 닫고 마이페이지로 이동
                Navigator.pop(context); // Drawer 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPageScreen()),
                );
              },
            ),
            // 로그아웃 메뉴
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃'),
              onTap: () {
                Navigator.pop(context); // Drawer 닫기
                if (context.mounted) {
                  ref.read(authViewModelProvider.notifier).signOut();
                }
              },
            ),
          ],
        ),
      ),
      body: groupBuysAsyncValue.when(
        // 로딩 중일 때 보여줄 UI
        loading: () => const Center(child: CircularProgressIndicator()),
        // 에러 발생 시 보여줄 UI
        error: (error, stackTrace) => Center(child: Text('에러 발생: $error')),
        // 데이터가 성공적으로 로드되었을 때 보여줄 UI
        data: (groupBuys) {
          if (groupBuys.isEmpty) {
            return const Center(child: Text('진행 중인 공동구매가 없습니다.'));
          }
          return ListView.builder(
            itemCount: groupBuys.length,
            itemBuilder: (context, index) {
              final groupBuy = groupBuys[index];
              return ProductCard(groupBuy: groupBuy);
            },
          );
        },
      ),
      floatingActionButton: userProfileAsync.when(
        // 💡 1. 데이터가 성공적으로 로드되었을 때
        data: (userProfile) => FloatingActionButton(
          onPressed: () {
            if (userProfile != null && userProfile.level >= 5) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SelectProductScreen()),
              );
            } else {
              // 💡 이제 실제 신청 화면으로 이동합니다.
        context.go('/propose-group-buy');
            }
          },
          child: const Icon(Icons.add),
        ),
        // 💡 2. 데이터 로딩 중일 때는 비활성화된 버튼을 보여줍니다.
        loading: () => FloatingActionButton(
          onPressed: null,
          backgroundColor: Colors.grey,
          child: Container(
            width: 24,
            height: 24,
            padding: const EdgeInsets.all(2.0),
            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ),
        ),
        // 💡 3. 에러 발생 시 에러 아이콘 버튼을 보여줍니다.
        error: (err, stack) => FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('사용자 정보 로딩 실패: $err')),
            );
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.error),
        ),
      ),
    );
  }
}