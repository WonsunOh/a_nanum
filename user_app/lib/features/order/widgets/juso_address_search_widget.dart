// user_app/lib/features/order/widgets/juso_address_search_widget.dart

import 'package:flutter/material.dart';
import '../../../services/juso_address_service.dart';

class JusoAddressSearchWidget extends StatefulWidget {
  final Function(Map<String, String>) onAddressSelected;

  const JusoAddressSearchWidget({
    super.key,
    required this.onAddressSelected,
  });

  @override
  State<JusoAddressSearchWidget> createState() => _JusoAddressSearchWidgetState();
}

class _JusoAddressSearchWidgetState extends State<JusoAddressSearchWidget> {
  final _searchController = TextEditingController();
  final _detailController = TextEditingController();
  
  List<JusoAddressModel> _searchResults = [];
  JusoAddressModel? _selectedAddress;
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _isSearching = true;
      _showResults = false;
    });

    try {
      final results = await JusoAddressService.searchAddress(keyword);
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _showResults = true;
        _selectedAddress = null;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _showResults = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('주소 검색 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectAddress(JusoAddressModel address) {
    setState(() {
      _selectedAddress = address;
      _showResults = false;
    });
  }

  void _submitAddress() {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('주소를 선택해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final fullAddress = _detailController.text.trim().isNotEmpty
        ? '${_selectedAddress!.roadAddr} ${_detailController.text.trim()}'
        : _selectedAddress!.roadAddr;

    final addressData = {
      'zonecode': _selectedAddress!.zipNo,
      'roadAddress': fullAddress,
      'jibunAddress': _selectedAddress!.jibunAddr,
    };

    widget.onAddressSelected(addressData);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 검색'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      centerTitle: true, // 제목 가운데 정렬
      elevation: 1, // 그림자 줄이기
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색 입력 필드
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '도로명, 건물명, 지번을 입력하세요',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _searchAddress(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  child: _isSearching 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('검색'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 검색 결과 또는 선택된 주소
            Expanded(
              child: _showResults
                  ? _buildSearchResults()
                  : _selectedAddress != null
                      ? _buildSelectedAddress()
                      : _buildInitialState(),
            ),

            // 하단 버튼
            if (_selectedAddress != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '주소 확정',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '주소를 검색해주세요',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            '도로명, 건물명, 지번 등으로 검색할 수 있습니다',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '검색 결과 (${_searchResults.length}건)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final address = _searchResults[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    address.displayAddress,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (address.jibunAddr.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '지번: ${address.jibunAddr}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '우편번호: ${address.zipNo}',
                        style: TextStyle(color: Colors.blue.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectAddress(address),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '선택된 주소',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedAddress!.roadAddr,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '우편번호: ${_selectedAddress!.zipNo}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              if (_selectedAddress!.jibunAddr.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '지번: ${_selectedAddress!.jibunAddr}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // const Text(
        //   '상세주소',
        //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
        // const SizedBox(height: 8),
        // TextField(
        //   controller: _detailController,
        //   decoration: InputDecoration(
        //     hintText: '동, 호수 등 상세주소를 입력하세요',
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //   ),
        // ),
        
        // const SizedBox(height: 20),
        
        TextButton(
          onPressed: () {
            setState(() {
              _selectedAddress = null;
              _showResults = true;
            });
          },
          child: const Text('다른 주소 선택'),
        ),
      ],
    );
  }
}