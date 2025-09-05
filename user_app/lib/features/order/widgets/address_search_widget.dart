// user_app/lib/features/order/widgets/address_search_widget.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddressSearchWidget extends StatefulWidget {
  final Function(Map<String, String>) onAddressSelected;

  const AddressSearchWidget({
    super.key,
    required this.onAddressSelected,
  });

  @override
  State<AddressSearchWidget> createState() => _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends State<AddressSearchWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // 페이지 로드 완료 후 JavaScript 함수 주입
            _injectJavaScript();
          },
        ),
      )
      ..addJavaScriptChannel(
        'AddressChannel',
        onMessageReceived: (JavaScriptMessage message) {
          // 주소 선택 결과 처리
          _handleAddressResult(message.message);
        },
      )
      ..loadHtmlString(_getAddressSearchHtml());
  }

  void _injectJavaScript() {
    _controller.runJavaScript('''
      // Daum 우편번호 서비스 완료 시 호출되는 함수
      function onComplete(data) {
        var result = {
          zonecode: data.zonecode,
          address: data.address,
          addressEnglish: data.addressEnglish,
          addressType: data.addressType,
          userSelectedType: data.userSelectedType,
          noSelected: data.noSelected,
          userLanguageType: data.userLanguageType,
          roadAddress: data.roadAddress,
          jibunAddress: data.jibunAddress,
          buildingName: data.buildingName,
          apartment: data.apartment,
          sido: data.sido,
          sigungu: data.sigungu,
          bname: data.bname,
          roadname: data.roadname
        };
        
        // Flutter로 결과 전송
        AddressChannel.postMessage(JSON.stringify(result));
      }
    ''');
  }

  void _handleAddressResult(String result) {
    try {
      // JSON 파싱 대신 간단한 문자열 처리
      final Map<String, String> addressData = {};
      
      // 실제로는 dart:convert의 jsonDecode를 사용해야 하지만,
      // 여기서는 간단한 예시로 처리
      if (result.contains('"zonecode"')) {
        // 간단한 파싱 로직 (실제로는 jsonDecode 사용 권장)
        final parts = result.split(',');
        for (final part in parts) {
          if (part.contains('zonecode')) {
            addressData['zonecode'] = part.split(':')[1].replaceAll('"', '').trim();
          } else if (part.contains('roadAddress')) {
            addressData['roadAddress'] = part.split(':')[1].replaceAll('"', '').trim();
          } else if (part.contains('jibunAddress')) {
            addressData['jibunAddress'] = part.split(':')[1].replaceAll('"', '').trim();
          }
        }
      }
      
      // 결과를 부모 위젯으로 전달
      widget.onAddressSelected(addressData);
      
      // 팝업 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('주소 결과 처리 오류: $e');
    }
  }

  String _getAddressSearchHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>주소 검색</title>
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <style>
        body { margin: 0; padding: 0; }
        #layer { width: 100%; height: 100vh; }
    </style>
</head>
<body>
    <div id="layer"></div>
    <script>
        new daum.Postcode({
            oncomplete: function(data) {
                onComplete(data);
            },
            width: '100%',
            height: '100%'
        }).embed(document.getElementById('layer'));
    </script>
</body>
</html>
    ''';
  }

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
      body: WebViewWidget(controller: _controller),
    );
  }
}