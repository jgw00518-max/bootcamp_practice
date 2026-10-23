main(){
  checkVersion();
  print('end Process');
}

Future<void> checkVersion() async{      // async 처리를 해주면 다른 cpu가 실행(삼항 연산자도 마찬가지)
  var version = await lookupVersion();  // 따라서 순서대로가 아닌 동시에 실행
  print(version);                       // ex) 앱을 키면 화면 구성 + 데이터 불러오기 동시에 실행
}

int lookupVersion(){
  return 12;
} 