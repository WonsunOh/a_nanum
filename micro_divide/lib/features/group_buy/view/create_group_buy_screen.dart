import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../mypages/viewmodel/mypage_viewmodel.dart';
import '../viewmodel/create_group_buy_viewmodel.dart';

// 선택된 이미지 파일을 담아둘 Provider
final selectedImageProvider = StateProvider.autoDispose<XFile?>((ref) => null);

class CreateGroupBuyScreen extends ConsumerWidget {
  const CreateGroupBuyScreen({super.key});

  // 갤러리에서 이미지를 선택하는 함수
  Future<void> _pickImage(WidgetRef ref) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      ref.read(selectedImageProvider.notifier).state = pickedImage;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      // 폼 관리를 위한 컨트롤러들
    final formKey = GlobalKey<FormState>();
    final nameController = ref.watch(nameControllerProvider);
    final priceController = ref.watch(priceControllerProvider);
    final participantsController = ref.watch(participantsControllerProvider);
    
    final selectedImage = ref.watch(selectedImageProvider);
    final isLoading = ref.watch(createGroupBuyViewModelProvider).isLoading;


    ref.listen<AsyncValue<void>>(createGroupBuyViewModelProvider, (previous, current) {
      // 1. 에러가 발생한 경우
      if (current.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: ${current.error}')),
        );
      }
      // 2. 이전 상태는 로딩 중이었는데, 현재 상태는 로딩이 아니고 에러도 없는 경우
      //    이것이 바로 '성공'한 시점입니다.
      if (previous is AsyncLoading && !current.isLoading && !current.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('새로운 공동구매가 등록되었습니다!')),
        );
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('새로운 공구 열기')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ... (이미지 선택 UI는 그대로)
            GestureDetector(
              onTap: () => _pickImage(ref),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: selectedImage != null
                      ? kIsWeb
                          // 웹에서 실행 중일 경우: Image.network 사용
                          ? Image.network(selectedImage.path, fit: BoxFit.cover)
                          // 모바일에서 실행 중일 경우: 기존 Image.file 사용
                          : Image.file(File(selectedImage.path), fit: BoxFit.cover)
                      // ------------------------------------
                      : const Center(
                          child: Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
      
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '상품명'),
              validator: (value) => (value == null || value.isEmpty) ? '상품명을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: '총 상품 가격 (숫자만)'),
              keyboardType: TextInputType.number,
              validator: (value) => (value == null || value.isEmpty) ? '가격을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: participantsController,
              decoration: const InputDecoration(labelText: '모집 인원 (숫자만)'),
              keyboardType: TextInputType.number,
              validator: (value) => (value == null || value.isEmpty) ? '모집 인원을 입력해주세요' : null,
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                 final viewModel = ref.read(createGroupBuyViewModelProvider.notifier);
    if (formKey.currentState!.validate()) {
      // 💡 각 Provider에서 값을 읽어와 파라미터로 전달
      final image = ref.read(selectedImageProvider);
      if (image != null) {
        viewModel.createGroupBuy(
          name: ref.read(nameControllerProvider).text,
          totalPrice: int.parse(ref.read(priceControllerProvider).text),
          targetParticipants: int.parse(ref.read(participantsControllerProvider).text),
          image: image,
          description: ref.read(descriptionControllerProvider).text,
          categoryId: ref.read(categoryIdProvider),
        );
      }
    }
  },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('공구 등록하기'),
            ),
          ],
        ),
      ),
    );
  }
}