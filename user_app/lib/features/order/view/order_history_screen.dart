// user_app/lib/features/order/view/order_history_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/order_history_model.dart';
import '../../../data/repositories/partial_cancel_repository.dart';
import '../viewmodel/order_history_viewmodel.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderHistoryAsync = ref.watch(orderHistoryViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('주문내역'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(orderHistoryViewModelProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: orderHistoryAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '주문내역이 없습니다',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text('상품을 둘러보세요!', style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/shop'),
                    child: const Text('쇼핑하러가기'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 주문 헤더
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderNumber,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('yyyy.MM.dd HH:mm').format(order.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        _buildStatusChip(order.status),
                            ],
                          ),
                           const Divider(height: 24),

                    // 상품 목록 표시
                    Column(
                      children: order.items.map((item) => _buildOrderItem(item)).toList(),
                    ),

                    const SizedBox(height: 12),

                    // 배송 정보
                    _buildInfoRow('받는분', order.recipientName),
                    _buildInfoRow('연락처', order.recipientPhone),
                    _buildInfoRow('배송지', order.shippingAddress),
                    if (order.trackingNumber != null)
                      _buildInfoRow('송장번호', order.trackingNumber!),

                    const Divider(height: 24),

                    // 총 금액
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '총 주문금액',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${NumberFormat('#,###').format(order.totalAmount)}원',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 버튼들
                    Row(
                      children: [
                        // 🔥🔥🔥 수정: '부분취소' 버튼 제거, '주문취소' 버튼만 남김
                        if (_canCancelOrder(order.status))
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _showCancelDialog(context, order, ref);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('주문취소'),
                            ),
                          ),
                        if (!_canCancelOrder(order.status)) const Spacer(),
                        
                        const SizedBox(width: 8),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (order.items.isNotEmpty) {
                                context.go('/shop/${order.items.first.productId}');
                              }
                            },
                            child: const Text('상품보기'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('주문내역을 불러오는 중 오류가 발생했습니다'),
              const SizedBox(height: 8),
              Text('$error', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(orderHistoryViewModelProvider.notifier).refresh(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );
      },
    ),
  );
}

  // 부분취소 요청 제출 메서드 (변경 없음)
  Future<void> _submitPartialCancellationRequest(
    BuildContext context,
    Map<int, int> selectedItems,
    String reason,
    String detail,
    WidgetRef ref,
  ) async {
    try {
      final repository = ref.read(partialCancelRepositoryProvider);

      for (final entry in selectedItems.entries) {
        final orderItemId = entry.key;
        final cancelQuantity = entry.value;

        await repository.requestPartialCancellation(
          orderItemId: orderItemId,
          cancelReason: reason,
          cancelDetail: detail.isEmpty ? null : detail,
          cancelQuantity: cancelQuantity,
        );
      }

      if (context.mounted) {
        ref.invalidate(orderHistoryViewModelProvider);

        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            ref.read(orderHistoryViewModelProvider.notifier).refresh();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedItems.length}개 상품에 대한 부분취소 요청이 제출되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('부분취소 요청 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


Widget _buildStatusChip(String status) {
  Color color = _getStatusColor(status);
  String label = _getStatusText(status);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'confirmed':
      return Colors.blue;
    case 'preparing':
      return Colors.purple;
    case 'shipped':
      return Colors.green;
    case 'delivered':
      return Colors.grey[600]!;
    case 'cancelled':
      return Colors.red;
    case 'cancellation_requested':
      return Colors.orange[700]!;
    case 'refunded':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

String _getStatusText(String status) {
  switch (status) {
    case 'pending':
      return '결제대기';
    case 'confirmed':
      return '결제완료';
    case 'preparing':
      return '상품준비중';
    case 'shipped':
      return '배송중';
    case 'delivered':
      return '배송완료';
    case 'cancelled':
      return '주문취소';
    case 'cancellation_requested':
      return '취소요청';
    case 'refunded':
      return '환불완료';
    default:
      return status;
  }
}

Color _getPartialCancelStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'approved':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _getPartialCancelStatusText(String status) {
  switch (status) {
    case 'pending':
      return '취소대기';
    case 'approved':
      return '취소승인';
    case 'rejected':
      return '취소거부';
    default:
      return status;
  }
}

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥🔥🔥 전체 수정: 취소/부분취소 통합 다이얼로그
void _showCancelDialog(BuildContext context, OrderHistoryModel order, WidgetRef ref) {
  Map<int, int> cancelQuantities = {}; // orderItemId -> 취소할 수량
  
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          // 총 취소 금액 계산
          int totalCancelAmount = 0;
          int totalCancelQuantity = 0;
          
          for (final entry in cancelQuantities.entries) {
            final item = order.items.firstWhere((i) => i.orderItemId == entry.key);
            totalCancelAmount += item.pricePerItem * entry.value;
            totalCancelQuantity += entry.value;
          }
          
          // 전체 취소 여부 확인
          bool isFullCancel = order.items.every((item) => 
            cancelQuantities[item.orderItemId] == item.quantity);
          
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.status == 'confirmed' ? '주문 취소' : '주문 취소 요청'),
                if (totalCancelQuantity > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFullCancel ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isFullCancel ? '전체취소' : '부분취소',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 안내 메시지
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: order.status == 'confirmed' 
                          ? Colors.blue.shade50 
                          : Colors.orange.shade50,
                        border: Border.all(
                          color: order.status == 'confirmed' 
                            ? Colors.blue 
                            : Colors.orange
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline, 
                            color: order.status == 'confirmed' 
                              ? Colors.blue.shade700 
                              : Colors.orange.shade700
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.status == 'confirmed'
                                ? '결제완료 상태의 주문은 즉시 취소됩니다.'
                                : '상품준비중 이후 상태는 관리자 확인 후 처리됩니다.',
                              style: TextStyle(
                                color: order.status == 'confirmed' 
                                  ? Colors.blue.shade700 
                                  : Colors.orange.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 빠른 선택 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '취소할 상품 선택:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  // 전체 선택
                                  for (final item in order.items) {
                                    cancelQuantities[item.orderItemId] = item.quantity;
                                  }
                                });
                              },
                              child: const Text('전체선택', style: TextStyle(fontSize: 12)),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  cancelQuantities.clear();
                                });
                              },
                              child: const Text('선택해제', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 상품 목록
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: order.items.length,
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          final cancelQuantity = cancelQuantities[item.orderItemId] ?? 0;
                          
                          return Card(
                            color: cancelQuantity > 0 ? Colors.red.shade50 : null,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // 상품 이미지
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: Colors.grey[300],
                                        ),
                                        child: item.productImageUrl != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Image.network(
                                                  item.productImageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(Icons.image, color: Colors.grey[600], size: 20);
                                                  },
                                                ),
                                              )
                                            : Icon(Icons.image, color: Colors.grey[600], size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      
                                      // 상품 정보
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${NumberFormat('#,###').format(item.pricePerItem)}원 × ${item.quantity}개',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // 취소 수량 선택
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('취소 수량:', style: TextStyle(fontSize: 13)),
                                      Row(
                                        children: [
                                          // 감소 버튼
                                          IconButton(
                                            onPressed: cancelQuantity > 0 ? () {
                                              setState(() {
                                                if (cancelQuantity == 1) {
                                                  cancelQuantities.remove(item.orderItemId);
                                                } else {
                                                  cancelQuantities[item.orderItemId] = cancelQuantity - 1;
                                                }
                                              });
                                            } : null,
                                            icon: const Icon(Icons.remove_circle_outline),
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          
                                          // 수량 표시
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey[300]!),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '$cancelQuantity개',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: cancelQuantity > 0 ? Colors.red : Colors.black,
                                              ),
                                            ),
                                          ),
                                          
                                          // 증가 버튼
                                          IconButton(
                                            onPressed: cancelQuantity < item.quantity ? () {
                                              setState(() {
                                                cancelQuantities[item.orderItemId] = cancelQuantity + 1;
                                              });
                                            } : null,
                                            icon: const Icon(Icons.add_circle_outline),
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                  if (cancelQuantity > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '취소 금액: ${NumberFormat('#,###').format(item.pricePerItem * cancelQuantity)}원',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // 총 취소 금액
                    if (totalCancelQuantity > 0) ...[
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '총 환불 예정 금액:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${NumberFormat('#,###').format(totalCancelAmount)}원',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('닫기'),
              ),
              ElevatedButton(
  onPressed: totalCancelQuantity == 0 ? null : () async {
    Navigator.of(dialogContext).pop();
    
    // 전체 취소인 경우
    if (isFullCancel) {
      try {
        await ref
          .read(orderHistoryViewModelProvider.notifier)
          .requestCancellation(
            orderNumber: order.orderNumber,
            reason: '고객 요청',
            totalAmount: order.totalAmount
          );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(order.status == 'confirmed' 
                ? '주문이 즉시 취소되었습니다.' 
                : '취소 요청이 접수되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('주문 취소 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } 
    // 부분 취소인 경우
    else {
      try {

        print('🔥 부분취소 시작: ${cancelQuantities.length}개 항목');
    print('🔥 주문 상태: ${order.status}');
    print('🔥 취소 항목: $cancelQuantities');

        final repository = ref.read(partialCancelRepositoryProvider);
        
        // 부분 취소 처리 부분 수정
if (order.status == 'confirmed') {
  print('✅ confirmed 상태 - 즉시 부분취소 처리');
  
  int? processedOrderId;
  
  for (final entry in cancelQuantities.entries) {
    final orderItemId = entry.key;
    final cancelQuantity = entry.value;
    final item = order.items.firstWhere((i) => i.orderItemId == orderItemId);
    
    print('📦 처리중: orderItemId=$orderItemId, 취소수량=$cancelQuantity, 원래수량=${item.quantity}');
    
    // order_items 테이블 업데이트하고 orderId 받기
    processedOrderId = await repository.processCancelledItem(
      orderItemId: orderItemId,
      cancelQuantity: cancelQuantity,
      isFullCancel: cancelQuantity == item.quantity,
    );
  }
  
  if (processedOrderId != null) {
    print('✅ 주문 상태 업데이트 시작: orderId=$processedOrderId');
    // 전체 주문 상태 확인 및 업데이트
    await repository.updateOrderStatusAfterPartialCancel(processedOrderId);
  }
  
  print('✅ 모든 부분취소 처리 완료');
  
  if (context.mounted) {
    // 먼저 스낵바 표시
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('선택한 상품이 즉시 취소되었습니다.'),
      backgroundColor: Colors.green,
    ),
  );
  
  // invalidate 후 바로 refresh 호출
  ref.invalidate(orderHistoryViewModelProvider);
  
  // 약간의 딜레이 후 다시 한번 refresh
  Future.delayed(const Duration(milliseconds: 300), () {
    if (context.mounted) {
      ref.read(orderHistoryViewModelProvider.notifier).refresh();
    }
  });
}
}
        // preparing 이상 상태: 부분취소 요청 생성
        else {
           print('✅ ${order.status} 상태 - 부분취소 요청 생성');
          for (final entry in cancelQuantities.entries) {
            final orderItemId = entry.key;
            final cancelQuantity = entry.value;

            print('📦 요청중: orderItemId=$orderItemId, 취소수량=$cancelQuantity');
            
            await repository.requestPartialCancellation(
              orderItemId: orderItemId,
              cancelReason: '고객 요청',
              cancelDetail: null,
              cancelQuantity: cancelQuantity,
            );
          }
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${cancelQuantities.length}개 상품에 대한 부분취소 요청이 접수되었습니다.'),
                backgroundColor: Colors.green,
              ),
            );
            ref.invalidate(orderHistoryViewModelProvider);
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('부분취소 처리 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: order.status == 'confirmed' ? Colors.blue : Colors.red,
  ),
  child: Text(
    totalCancelQuantity == 0 
      ? '상품을 선택하세요'
      : isFullCancel 
        ? '전체 취소하기'
        : '선택 상품 취소하기 ($totalCancelQuantity개)',
  ),
),
            ],
          );
        },
      );
    },
  );
}


  // 🔥🔥🔥 추가: 전체 취소 확인 및 사유 입력 다이얼로그 분리
  void _showFullCancelConfirmDialog(BuildContext context, OrderHistoryModel order, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _buildFullCancelDialog(context, order, ref, fromChoice: true);
      },
    );
  }

  void _showPartialCancelDialogForConfirmed(BuildContext context, OrderHistoryModel order, WidgetRef ref) {
  Map<int, int> selectedItems = {}; // orderItemId -> cancelQuantity

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('부분취소 (즉시처리)'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '선택한 상품/수량만 즉시 취소됩니다.',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    const Text('취소할 상품 선택:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: order.items.length,
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          final isSelected = selectedItems.containsKey(item.orderItemId);
                          final cancelQuantity = selectedItems[item.orderItemId] ?? 1;
                          
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedItems[item.orderItemId] = 1;
                                            } else {
                                              selectedItems.remove(item.orderItemId);
                                            }
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              '${NumberFormat('#,###').format(item.pricePerItem)}원 × ${item.quantity}개',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  if (isSelected && item.quantity > 1) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text('취소 수량: '),
                                        SizedBox(
                                          width: 100,
                                          child: DropdownButton<int>(
                                            value: cancelQuantity,
                                            isExpanded: true,
                                            onChanged: (int? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  selectedItems[item.orderItemId] = newValue;
                                                });
                                              }
                                            },
                                            items: List.generate(item.quantity, (i) => i + 1)
                                                .map((quantity) => DropdownMenuItem(
                                                      value: quantity,
                                                      child: Text('${quantity}개'),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: selectedItems.isEmpty
                    ? null
                    : () async {
                        Navigator.of(dialogContext).pop();
                        
                        // TODO: confirmed 상태의 부분취소 처리 로직 구현
                        // 이 부분은 partial_cancel_repository에 새로운 메서드를 추가해야 합니다
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('부분취소가 처리되었습니다.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text('부분취소 (${selectedItems.length}개)'),
              ),
            ],
          );
        },
      );
    },
  );
}

  // 🔥🔥🔥 추가: 전체 취소 다이얼로그 위젯
  Widget _buildFullCancelDialog(BuildContext context, OrderHistoryModel order, WidgetRef ref, {bool fromChoice = false}) {
    final reasons = ['단순 변심', '더 저렴한 상품 발견', '배송 지연 우려', '상품 정보 오류', '기타'];
    String selectedReason = reasons.first;
    String detail = '';
    
    // StatefulBuilder를 사용하여 다이얼로그 내부 상태 관리
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(fromChoice ? '전체 주문취소' : '주문취소 요청'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.orange.shade50,
    border: Border.all(color: Colors.orange),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Icon(Icons.info_outline, color: Colors.orange.shade700),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          order.status == 'confirmed' 
            ? '결제완료 상태의 주문은 즉시 취소되며, 결제하신 금액은 환불 처리됩니다.'
            : '\'상품준비중\' 이후 상태는 관리자 확인 후 처리됩니다.',
          style: TextStyle(
            color: Colors.orange.shade700,
            fontSize: 12,
          ),
        ),
      ),
    ],
  ),
),
                const SizedBox(height: 16),
                const Text('취소 사유를 선택해주세요'),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedReason,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value!;
                    });
                  },
                  items: reasons.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: '상세 사유 (선택사항)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    detail = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                    .read(orderHistoryViewModelProvider.notifier)
                    .requestCancellation(
                      orderNumber: order.orderNumber,
                      reason: '$selectedReason ${detail.isNotEmpty ? '($detail)' : ''}',
                      totalAmount: order.totalAmount
                    );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('취소 요청이 정상적으로 접수되었습니다.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('취소 요청 실패: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('취소 요청 제출'),
            ),
          ],
        );
      }
    );
  }

  Widget _buildOrderItem(OrderHistoryItemModel item) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Row(
      children: [
        // 상품 이미지
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: item.productImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.productImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, color: Colors.grey[600]);
                    },
                  ),
                )
              : Icon(Icons.image, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        
        // 상품 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${NumberFormat('#,###').format(item.pricePerItem)}원 × ${item.effectiveQuantity}개',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              
              // 부분취소 정보 표시
              if (item.partialCancellations?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: item.partialCancellations!.map((pc) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPartialCancelStatusColor(pc.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_getPartialCancelStatusText(pc.status)} ${pc.cancelQuantity}개 (${NumberFormat('#,###').format(pc.refundAmount)}원)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        
        // 금액
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${NumberFormat('#,###').format(item.totalPrice)}원',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (item.totalCancelledQuantity > 0) ...[
              const SizedBox(height: 2),
              Text(
                '취소: ${item.totalCancelledQuantity}개',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

// 취소 가능 여부 확인 메서드
bool _canCancelOrder(String status) {
  return ['pending', 'confirmed', 'preparing'].contains(status);
}
}

