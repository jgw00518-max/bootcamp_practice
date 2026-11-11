import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/address_result.dart';

/// 카카오 우편번호 페이지에서 선택한 결과를 앱으로 전달하는 검색 화면이다.
class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'AddressSelection',
        onMessageReceived: _receiveAddress,
      )
      ..loadHtmlString(
        _postcodeHtml,
        baseUrl: 'https://postcode.map.kakao.com/',
      );
  }

  /// JavaScript oncomplete 콜백의 주소 데이터를 앱의 결과 모델로 변환한다.
  void _receiveAddress(JavaScriptMessage message) {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    final roadAddress = data['roadAddress'] as String;
    Navigator.of(context).pop(
      AddressResult(
        address: roadAddress.isNotEmpty
            ? roadAddress
            : data['jibunAddress'] as String,
        zoneCode: data['zonecode'] as String,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('다음 주소 검색 API')),
    body: WebViewWidget(controller: _controller),
  );
}

/// 카카오 우편번호 서비스의 선택 결과를 Flutter JavaScript 채널로 전달한다.
const _postcodeHtml =
    r'''<!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>html,body,#postcode{margin:0;height:100%;}</style></head><body><div id="postcode"></div><script src="https://t1.kakaocdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script><script>new kakao.Postcode({oncomplete:function(data){AddressSelection.postMessage(JSON.stringify({roadAddress:data.roadAddress||'',jibunAddress:data.jibunAddress||'',zonecode:data.zonecode||''}));},width:'100%',height:'100%'}).embed(document.getElementById('postcode'));</script></body></html>''';
