import 'package:flutter/material.dart';
import 'dart:typed_data';

class ProductImageSelector extends StatelessWidget {
  final List<String> existingImageUrls;
  final List<Uint8List> selectedImageBytes;
  final VoidCallback onPickSingleImage;
  final VoidCallback onPickMultipleImages;
  final Function(int, bool) onRemoveImage;

  const ProductImageSelector({
    super.key,
    required this.existingImageUrls,
    required this.selectedImageBytes,
    required this.onPickSingleImage,
    required this.onPickMultipleImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('상품 이미지', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('첫 번째 이미지가 대표 이미지로 사용됩니다.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        
        if (existingImageUrls.isNotEmpty || selectedImageBytes.isNotEmpty)
          _buildImageGrid(context)
        else
          _buildEmptyState(context),
        
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickSingleImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('이미지 추가'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickMultipleImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('여러 이미지 선택'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: existingImageUrls.length + selectedImageBytes.length + 1,
        itemBuilder: (context, index) {
          if (index < existingImageUrls.length) {
            return _buildImageTile(
              context,
              networkUrl: existingImageUrls[index],
              index: index,
              isMainImage: index == 0,
              onRemove: () => onRemoveImage(index, true),
            );
          }
          
          final newImageIndex = index - existingImageUrls.length;
          if (newImageIndex < selectedImageBytes.length) {
            return _buildImageTile(
              context,
              memoryBytes: selectedImageBytes[newImageIndex],
              index: index,
              isMainImage: index == 0,
              onRemove: () => onRemoveImage(newImageIndex, false),
            );
          }
          
          return _buildAddButton(context);
        },
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, {
    String? networkUrl,
    Uint8List? memoryBytes,
    required int index,
    required bool isMainImage,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: networkUrl != null
                ? Image.network(networkUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildErrorWidget())
                : Image.memory(memoryBytes!, fit: BoxFit.cover),
          ),
        ),
        if (isMainImage)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('대표', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.broken_image, size: 32, color: Colors.grey.shade500),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: onPickSingleImage,
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text('이미지 추가', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return InkWell(
      onTap: onPickMultipleImages,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 64, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text('이미지를 선택하세요', style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('여러 이미지를 한번에 선택할 수 있습니다', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}