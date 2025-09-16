// user_app/lib/features/order/view/order_history_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/order_item_model.dart';
import '../../../data/repositories/order_cancellation_repository.dart';
import '../../../data/repositories/partial_cancel_repository.dart';
import '../viewmodel/order_history_viewmodel.dart';
import '../widgets/partial_cancel_dialog.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderHistoryAsync = ref.watch(orderHistoryViewModelProvider);
    // 취소 가능한 상태들 정의
    bool _canCancelOrder(String status) {
      return ['pending', 'confirmed', 'preparing'].contains(status);
    }

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
          print('주문 목록 빌드: ${orders.length}개');
          for (final order in orders) {
            print('주문 ${order.orderId}: ${order.status}');
          }

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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'yyyy.MM.dd HH:mm',
                                ).format(order.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          // 주문 상태 배지
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _getStatusText(order.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 주문 상품 목록
                      ...order.items
                          .map(
                            (item) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.productImageUrl ?? '',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey[400],
                                                  size: 20,
                                                ),
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${NumberFormat('#,###').format(item.pricePerItem)}원 × ${item.quantity}개',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${NumberFormat('#,###').format(item.totalPrice)}원',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),

                      const Divider(),

                      // 주문 요약 정보
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              '총 주문금액',
                              '${NumberFormat('#,###').format(order.totalAmount)}원',
                            ),
                            _buildInfoRow('받는분', order.recipientName),
                            _buildInfoRow('연락처', order.recipientPhone),
                            _buildInfoRow('배송지', order.shippingAddress),
                            if (order.trackingNumber != null)
                              _buildInfoRow('송장번호', order.trackingNumber!),
                          ],
                        ),
                      ),

                      // 하단 버튼들
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (_canCancelOrder(order.status)) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _showCancelDialog(
                                    context,
                                    order.orderId,
                                    ref,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: Text(_getCancelButtonText(order.status)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _showPartialCancelDialog(context, order, ref);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: const BorderSide(color: Colors.orange),
                                ),
                                child: const Text('부분취소'),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (order.status == 'cancel_requested') ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pending,
                                    color: Colors.orange.shade600,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '취소 처리 중',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (order.items.isNotEmpty) {
                                  context.go(
                                    '/shop/${order.items.first.productId}',
                                  );
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
                Text('주문내역을 불러오는 중 오류가 발생했습니다'),
                const SizedBox(height: 8),
                Text('$error', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(orderHistoryViewModelProvider.notifier)
                      .refresh(),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ 부분취소 다이얼로그 메서드
  void _showPartialCancelDialog(
    BuildContext context,
    dynamic order,
    WidgetRef ref,
  ) {
    final reasons = ['단순 변심', '더 저렴한 상품 발견', '배송 지연 우려', '상품 정보 오류', '기타'];

    String selectedReason = reasons.first;
    String detail = '';
    Map<int, int> selectedItems = {}; // orderItemId -> 취소할 수량

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('부분취소 요청'),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
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
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '취소할 상품과 수량을 선택해주세요.',
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

                    Text(
                      '선택된 상품: ${selectedItems.length}개',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: ListView.builder(
                        itemCount: order.items.length,
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          final orderItemId = item.orderItemId;
                          final isSelected = selectedItems.containsKey(
                            orderItemId,
                          );

                          return Card(
                            key: ValueKey('item_$orderItemId'),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedItems[orderItemId] = 1;
                                  } else {
                                    selectedItems.remove(orderItemId);
                                  }
                                });
                              },
                              title: Text(item.productName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${NumberFormat('#,###').format(item.pricePerItem)}원 × ${item.quantity}개',
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text('취소 수량: '),
                                        DropdownButton<int>(
                                          value:
                                              selectedItems[orderItemId] ?? 1,
                                          items:
                                              List.generate(
                                                    item.quantity,
                                                    (i) => i + 1,
                                                  )
                                                  .map(
                                                    (qty) => DropdownMenuItem(
                                                      value: qty,
                                                      child: Text('$qty개'),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedItems[orderItemId] =
                                                  value!;
                                            });
                                          },
                                        ),
                                        const Spacer(),
                                        Text(
                                          '취소금액: ${NumberFormat('#,###').format(item.pricePerItem * (selectedItems[orderItemId] ?? 1))}원',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              secondary: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  item.productImageUrl ?? '',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

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

                    const SizedBox(height: 8),

                    TextField(
                      decoration: const InputDecoration(
                        labelText: '상세 사유 (선택사항)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        detail = value;
                      },
                    ),
                  ],
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
                          try {
                            await _submitPartialCancellationRequest(
                              context,
                              selectedItems,
                              selectedReason,
                              detail,
                              ref,
                            );

                            if (context.mounted && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          } catch (e) {
                            if (context.mounted && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('부분취소 요청 (${selectedItems.length}개)'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ 부분취소 요청 제출 메서드
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

        final result = await repository.requestPartialCancellation(
          orderItemId: orderItemId,
          cancelReason: reason,
          cancelDetail: detail.isEmpty ? null : detail,
          cancelQuantity: cancelQuantity,
        );

        print('부분취소 요청 성공 - OrderItemID: $orderItemId, 수량: $cancelQuantity');
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
      print('부분취소 요청 실패: $e');
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

  String _getCancelButtonText(String status) {
    switch (status) {
      case 'pending':
        return '결제취소';
      case 'confirmed':
      case 'preparing':
        return '주문취소';
      default:
        return '취소';
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
      case 'cancel_requested': // ✅ 추가
        return Colors.orange[700]!;
      case 'refunded': // ✅ 추가
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
        return '주문확인';
      case 'preparing':
        return '상품준비중';
      case 'shipped':
        return '배송중';
      case 'delivered':
        return '배송완료';
      case 'cancelled':
        return '주문취소';
      case 'cancel_requested': // ✅ 추가
        return '취소요청중';
      case 'refunded': // ✅ 추가
        return '환불완료';
      default:
        return status;
    }
  }

  // _showCancelDialog 메서드에 상태별 안내 추가

  void _showCancelDialog(BuildContext context, int orderId, WidgetRef ref) {
    final reasons = ['단순 변심', '더 저렴한 상품 발견', '배송 지연 우려', '상품 정보 오류', '기타'];

    String selectedReason = reasons.first;
    String detail = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // dialogContext로 명확히 구분
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('주문취소 요청'),
              content: Column(
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
                            '상품 준비 전에는 즉시 취소, 준비 중이면 관리자 확인 후 처리됩니다.',
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // ✅ 다이얼로그를 닫기 전에 취소 요청 처리
                    try {
                      // 로딩 표시 (선택사항)
                      setState(() {});

                      await _submitCancellationRequest(
                        context, // 원래 화면의 context 사용
                        orderId,
                        selectedReason,
                        detail,
                        ref,
                      );

                      // ✅ 처리 완료 후 다이얼로그 닫기
                      if (context.mounted && dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    } catch (e) {
                      // 에러 시에도 다이얼로그 닫기
                      if (context.mounted && dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('취소 요청'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 취소 요청 제출
  Future<void> _submitCancellationRequest(
    BuildContext context,
    int orderId,
    String reason,
    String detail,
    WidgetRef ref,
  ) async {
    try {
      final repository = ref.read(orderCancellationRepositoryProvider);
      final cancellationId = await repository.requestCancellation(
        orderId: orderId,
        reason: reason,
        detail: detail.isEmpty ? null : detail,
      );

      print('취소 요청 성공 - ID: $cancellationId');

      if (context.mounted) {
        // ✅ 여러 방법으로 새로고침 시도
        ref.invalidate(orderHistoryViewModelProvider);

        // 약간의 지연 후 한 번 더 시도
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            ref.read(orderHistoryViewModelProvider.notifier).refresh();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('취소 요청이 제출되었습니다. 관리자 승인 후 처리됩니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('취소 요청 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('취소 요청 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
