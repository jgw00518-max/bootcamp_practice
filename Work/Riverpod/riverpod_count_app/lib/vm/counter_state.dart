class CounterState {
  /*
  - 전체 계산 상태를 저장하는 데이터 모델
  - 계산에 필요한 모든 숫자 데이터를 final로 선언
  - Riverpod은 상태 변경 시 새로운 객체를 만들어야 하기 때문에 불변 객체로 설계
  */
  final int count;
  final int totalClick;

  /*
  - 초기 상태 지정
  */
  const CounterState({
    this.count = 0,
    this.totalClick = 0
  });
  
  /*
  - 특정 값만 변경된 새 상태 객체를 만들 때 사용
  : copyWith()의 목적은 상태의 일부만 바꾸기 위해 사용.
  Riverpod에서는 상태를 직접 수정할 수 없고, 항상 새로운 상태 객체를 만들어야 한다.
  */

  CounterState copyWith({
    int? count,
    int? totalClick,
  }){
    return CounterState(
      count: count ?? this.count,
      totalClick: totalClick ?? this.totalClick
    );
  }
}