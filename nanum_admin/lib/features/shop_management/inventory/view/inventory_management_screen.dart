// nanum_admin/lib/features/shop_management/inventory/view/inventory_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/main_layout.dart';
import 'inventory_dashboard_screen.dart';
import 'inventory_logs_screen.dart';

class InventoryManagementScreen extends ConsumerStatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  ConsumerState<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState
    extends ConsumerState<InventoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // ✅ 탭 변경 시 화면 업데이트
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Column(
        children: [
          // ✅ 헤더
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // ✅ 제목 (왼쪽)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '재고 관리',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '재고 현황과 변경 내역을 관리합니다',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ✅ 탭 바 (오른쪽, 적절한 크기)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false, // ✅ false로 변경
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicator: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    dividerColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    indicatorPadding: const EdgeInsets.all(4),
                    tabs: [
                      // ✅ 대시보드 탭
                      Tab(
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dashboard_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text('대시보드'),
                          ],
                        ),
                      ),
                      // ✅ 변경 내역 탭
                      Tab(
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text('변경 내역'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ 탭 뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                InventoryDashboardScreen(),
                InventoryLogsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}