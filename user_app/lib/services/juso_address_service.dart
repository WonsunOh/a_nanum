// user_app/lib/services/juso_address_service.dart (전체 교체)

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';

class JusoAddressService {
  static const String _baseUrl = 'https://business.juso.go.kr/addrlink/addrLinkApi.do';

  /// 도로명주소 검색
  static Future<List<JusoAddressModel>> searchAddress(String keyword) async {
    if (keyword.trim().isEmpty) return [];
    
    try {
      print('🔍 검색 키워드: $keyword');
      
      // API 키 확인
      final apiKey = AppConfig.jusoApiKey;
      print('🔑 API Key 존재 여부: ${apiKey.isNotEmpty}');
      print('🔑 API Key 길이: ${apiKey.length}자리');
      print('🔑 API Key 앞 5자리: ${apiKey.length > 5 ? apiKey.substring(0, 5) : apiKey}...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'confmKey': apiKey,
        'currentPage': '1',
        'countPerPage': '10',
        'keyword': keyword.trim(),
        'resultType': 'json',
      });

      print('🌐 API 요청 URL: $uri');

      final response = await http.get(uri);
      
      print('📡 HTTP 상태 코드: ${response.statusCode}');
      print('📄 응답 내용 길이: ${response.body.length}자');
      print('📄 응답 내용: ${response.body}');
      
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final results = decodedData['results'];
        
        print('📊 API 결과 구조: ${results.keys}');
        print('📊 common 섹션: ${results['common']}');
        
        // 에러 체크
        final errorCode = results['common']['errorCode'];
        final errorMessage = results['common']['errorMessage'];
        
        print('⚠️ 에러 코드: $errorCode');
        print('⚠️ 에러 메시지: $errorMessage');
        
        if (errorCode != '0') {
          throw Exception('API 오류 [$errorCode]: $errorMessage');
        }
        
        // 검색 결과가 있는 경우
        final jusoData = results['juso'];
        print('📭 juso 데이터 존재 여부: ${jusoData != null}');
        
        if (jusoData != null) {
          final jusoList = jusoData as List;
          print('✅ 검색 결과 개수: ${jusoList.length}');
          
          if (jusoList.isNotEmpty) {
            print('📍 첫 번째 결과: ${jusoList.first}');
          }
          
          return jusoList
              .map((item) => JusoAddressModel.fromJson(item))
              .toList();
        } else {
          print('📭 검색 결과가 null입니다');
        }
      } else {
        print('🔴 HTTP 요청 실패: ${response.statusCode}');
        print('🔴 응답 내용: ${response.body}');
      }
      
      return [];
    } catch (e, stackTrace) {
      print('💥 주소 검색 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }
}

/// 도로명주소 모델
class JusoAddressModel {
  final String roadAddr;      // 도로명주소
  final String jibunAddr;     // 지번주소  
  final String zipNo;         // 우편번호
  final String admCd;         // 행정구역코드
  final String rnMgtSn;       // 도로명코드
  final String bdMgtSn;       // 건물관리번호
  final String detBdNmList;   // 상세건물명
  final String bdNm;          // 건물명
  final String bdKdcd;        // 공동주택여부
  final String siNm;          // 시도명
  final String sggNm;         // 시군구명
  final String emdNm;         // 읍면동명
  final String liNm;          // 리명
  final String rn;            // 도로명
  final String udrtYn;        // 지하여부
  final String buldMnnm;      // 건물본번
  final String buldSlno;      // 건물부번
  final String mtYn;          // 산여부
  final String lnbrMnnm;      // 지번본번
  final String lnbrSlno;      // 지번부번
  final String emdNo;         // 읍면동일련번호

  JusoAddressModel({
    required this.roadAddr,
    required this.jibunAddr,
    required this.zipNo,
    required this.admCd,
    required this.rnMgtSn,
    required this.bdMgtSn,
    required this.detBdNmList,
    required this.bdNm,
    required this.bdKdcd,
    required this.siNm,
    required this.sggNm,
    required this.emdNm,
    required this.liNm,
    required this.rn,
    required this.udrtYn,
    required this.buldMnnm,
    required this.buldSlno,
    required this.mtYn,
    required this.lnbrMnnm,
    required this.lnbrSlno,
    required this.emdNo,
  });

  factory JusoAddressModel.fromJson(Map<String, dynamic> json) {
    return JusoAddressModel(
      roadAddr: json['roadAddr'] ?? '',
      jibunAddr: json['jibunAddr'] ?? '',
      zipNo: json['zipNo'] ?? '',
      admCd: json['admCd'] ?? '',
      rnMgtSn: json['rnMgtSn'] ?? '',
      bdMgtSn: json['bdMgtSn'] ?? '',
      detBdNmList: json['detBdNmList'] ?? '',
      bdNm: json['bdNm'] ?? '',
      bdKdcd: json['bdKdcd'] ?? '',
      siNm: json['siNm'] ?? '',
      sggNm: json['sggNm'] ?? '',
      emdNm: json['emdNm'] ?? '',
      liNm: json['liNm'] ?? '',
      rn: json['rn'] ?? '',
      udrtYn: json['udrtYn'] ?? '',
      buldMnnm: json['buldMnnm'] ?? '',
      buldSlno: json['buldSlno'] ?? '',
      mtYn: json['mtYn'] ?? '',
      lnbrMnnm: json['lnbrMnnm'] ?? '',
      lnbrSlno: json['lnbrSlno'] ?? '',
      emdNo: json['emdNo'] ?? '',
    );
  }

  // 표시용 주소 (건물명 포함)
  String get displayAddress {
    String address = roadAddr;
    if (bdNm.isNotEmpty && !address.contains(bdNm)) {
      address += ' ($bdNm)';
    }
    return address;
  }
}