main(){
  // Map : Key와 Value로 구성된 Collection
  Map fruits = {
    'apple' : '사과',
    'grape' : '포도',
    'watermelon' : '수박',
  };

  print(fruits);

  // key에 해당하는 데이터 불러오기
  print(fruits['apple']);

  // key에 해당하는 데이터 수정하기
  fruits['watermelon'] = "시원한 수박";
  print(fruits);

  // 데이터 추가하기
  fruits['banana'] = "바나나";
  print(fruits);

  // Generic을 선언하여 map 구성하기
  Map<String, int> fruitsPrice = {
    'apple' : 1000,
    'grape' : 2000,
    'watermelon' : 3000,
  };
  print(fruitsPrice['apple']);

  // 사과의 가격은 ___입니다.
  print("사과의 가격은 ${fruitsPrice['apple']} 입니다.");

  Map<String, List<int>> score = {
    'James' : [90, 80, 70], // 국어, 영어, 수학
    'Cathy' : [50, 60, 70]
  };

  // James와 Cathy의 영어 점수의 평균 구하기
  print((score['James']![1] + score['Cathy']![1]) / 2);
  
}