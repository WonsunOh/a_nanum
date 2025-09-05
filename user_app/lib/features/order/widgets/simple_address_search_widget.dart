// user_app/lib/features/order/widgets/simple_address_search_widget.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleAddressSearchWidget extends StatefulWidget {
  final Function(Map<String, String>) onAddressSelected;

  const SimpleAddressSearchWidget({
    super.key,
    required this.onAddressSelected,
  });

  @override
  State<SimpleAddressSearchWidget> createState() => _SimpleAddressSearchWidgetState();
}

class _SimpleAddressSearchWidgetState extends State<SimpleAddressSearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 검색'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '아래 버튼을 눌러 Daum 우편번호 서비스를 이용하여 주소를 검색하세요.',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    '주소 검색',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '정확한 배송을 위해 주소를 검색해주세요',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _showAddressInputDialog,
                    icon: const Icon(Icons.search),
                    label: const Text('주소 검색하기'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressInputDialog() {
    final zipcodeController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주소 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Daum 우편번호 서비스나 네이버 지도에서 검색한 주소를 입력하세요.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: zipcodeController,
              decoration: const InputDecoration(
                labelText: '우편번호',
                hintText: '12345',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: '기본 주소',
                hintText: '서울특별시 강남구 테헤란로 123',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (zipcodeController.text.isNotEmpty && addressController.text.isNotEmpty) {
                final addressData = {
                  'zonecode': zipcodeController.text,
                  'roadAddress': addressController.text,
                  'jibunAddress': addressController.text,
                };
                
                widget.onAddressSelected(addressData);
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(); // 주소 검색 화면 닫기
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('우편번호와 주소를 모두 입력해주세요.')),
                );
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}