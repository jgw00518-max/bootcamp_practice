const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const docsDir = __dirname;
const outputDir = path.join(docsDir, 'screen_plans');
fs.mkdirSync(outputDir, { recursive: true });

// 전체 구성도에 그려진 화면 간 화살표와 라벨은 개별 화면 이미지에서 제외한다.
const cleanSourceSvg = fs.readFileSync(path.join(docsDir, 'todolist_asset_layout_map.svg'), 'utf8')
  .replace(/<path[^>]*class="route[^"]*"[^>]*\/>/g, '')
  .replace(/<rect[^>]*class="tag"\/><text[^>]*class="tagtext"[^>]*>.*?<\/text>/g, '')
  .replace(/<text[^>]*class="fn">tab [1-4][^<]*<\/text>/g, '');

const slideWidth = 1920;
const slideHeight = 1080;
const cropWidth = 650;
const cropHeight = 950;
const screenHeight = 860;
const screenWidth = Math.round(cropWidth * screenHeight / cropHeight);
const screenLeft = 150;
const screenTop = 125;

const screens = [
  {
    file: '01_list_screen.png', title: '01. 목록 화면', subtitle: '할 일 조회 · 검색 · 필터 · 등록 · 메인 화면 이동',
    crop: { left: 65, top: 160 },
    badges: [
      ['A', 610, 730, 'right'], ['B', 600, 55, 'right'], ['C', 175, 865, 'bottom'], ['D', 285, 865, 'bottom'], ['E', 395, 865, 'bottom'], ['F', 505, 865, 'bottom'],
    ],
    links: [
      ['A', '새 할 일 / 수정 화면', 'Home FAB → Get.to(TaskFormPage)'],
      ['B', '휴지통 화면', '휴지통 버튼 → Get.to(TrashPage)'],
      ['C', '캘린더 화면', 'NavigationBar의 캘린더 탭'],
      ['D', '루틴 화면', 'NavigationBar의 루틴 탭'],
      ['E', '집중 화면', 'NavigationBar의 집중 탭'],
      ['F', '통계 화면', 'NavigationBar의 통계 탭'],
    ],
    functions: [
      ['_showDetailedFilters()', '상태·카테고리·우선순위 필터 표시'],
      ['toggle()', '할 일의 완료 상태 변경'],
      ['openTodoEditor()', '저장된 값으로 수정 화면 열기'],
      ['deleteTodoWithScope()', '삭제 대상과 반복 적용 범위 확인'],
    ],
    initialization: [
      'TodoController.onInit() → loadTodos()',
      'selectedTab = 0 · statusFilter = today',
      'Obx가 할 일·검색·필터 상태를 화면에 반영',
    ],
  },
  {
    file: '02_task_form_screen.png', title: '02. 새 할 일 / 수정 화면', subtitle: '할 일과 반복 루틴의 입력 · 검증 · 저장',
    crop: { left: 1000, top: 160 },
    badges: [['A', 12, 470, 'left']],
    links: [
      ['A', '목록 · 캘린더 · 루틴 화면', '추가 또는 수정 동작으로 진입'],
    ],
    functions: [
      ['_save()', '입력값을 검증한 뒤 할 일 또는 루틴 저장'],
      ['_validateTitle()', '필수 제목과 입력 조건 검증'],
      ['_pickDate()', '마감 날짜 선택 창 표시'],
      ['_pickTime()', '마감 시간 선택 창 표시'],
      ['_showRepeatOptions()', '반복 주기와 종료 조건 설정'],
      ['addTodo() / updateTodo()', '일반 할 일을 등록하거나 수정'],
      ['addRoutine() / updateRoutine()', '반복 루틴을 등록하거나 수정'],
    ],
    initialization: [
      'initState() → Todo·Routine 저장값 또는 기본값 주입',
      '기본값: 1시간 뒤 · 높음 · 업무 · 30분',
      '일반 등록은 반복 없음 · 루틴 등록은 반복 활성',
    ],
  },
  {
    file: '03_trash_screen.png', title: '03. 휴지통 화면', subtitle: '삭제한 할 일 조회 · 복구 · 영구 삭제',
    crop: { left: 1940, top: 160 }, badges: [['B', 12, 110, 'left']],
    links: [['B', '목록 화면', '휴지통 버튼으로 진입 · 뒤로 가기로 복귀']],
    functions: [
      ['_restore()', '선택한 할 일의 복구 처리 시작'],
      ['restoreTodo(id)', '삭제 데이터를 일반 목록으로 복원'],
      ['_confirmPermanentDelete()', '영구 삭제 확인 창 표시'],
      ['permanentlyDeleteTodo(id)', '선택한 데이터를 완전히 삭제'],
    ],
    initialization: [
      '별도 initState() 없음 · TodoController 상태 공유',
      'loadTodos()에서 deletedTodos를 SQLite로부터 조회',
      'Obx(deletedTodos)가 목록·빈 상태를 자동 갱신',
    ],
  },
  {
    file: '04_calendar_screen.png', title: '04. 캘린더 화면', subtitle: '날짜별 일정 조회 · 검색 · 필터 · 할 일 등록',
    crop: { left: 2885, top: 160 }, badges: [['C', 80, 865, 'bottom'], ['A', 610, 760, 'right']],
    links: [
      ['C', '목록 화면', 'NavigationBar의 캘린더 탭으로 이동'],
      ['A', '새 할 일 / 수정 화면', 'Home FAB 또는 일정 수정으로 진입'],
    ],
    functions: [
      ['_showFilters()', '캘린더 검색 조건과 필터 표시'],
      ['calendarTodosFor()', '날짜와 조건에 맞는 일정 조회'],
      ['toggle()', '선택 일정의 완료 상태 변경'],
      ['openTodoEditor()', '선택 일정을 수정 화면으로 전달'],
    ],
    initialization: [
      '별도 initState() 없음 · selectedDay = DateTime.now()',
      '검색창 닫힘 · 캘린더 필터는 전체 상태',
      'Obx가 선택 날짜와 검색·필터 결과를 반영',
    ],
  },
  {
    file: '05_routine_screen.png', title: '05. 루틴 화면', subtitle: '반복 일정 조회 · 활성화 · 등록 · 수정 · 삭제',
    crop: { left: 65, top: 1280 }, badges: [['D', 80, 865, 'bottom'], ['A', 610, 610, 'right']],
    links: [
      ['D', '목록 화면', 'NavigationBar의 루틴 탭으로 이동'],
      ['A', '새 할 일 / 수정 화면', 'Home FAB 또는 루틴 카드 수정으로 진입'],
    ],
    functions: [
      ['toggleRoutine()', '루틴의 활성·비활성 상태 변경'],
      ['_confirmDelete()', '루틴 삭제 여부를 확인'],
    ],
    initialization: [
      '별도 initState() 없음 · loadTodos()에서 routines 조회',
      'Obx가 전체·활성·비활성 개수와 루틴 목록 반영',
    ],
  },
  {
    file: '06_focus_screen.png', title: '06. 집중 화면', subtitle: '집중 대상 선택 · 타이머 실행 · 집중 기록 저장',
    crop: { left: 1000, top: 1280 }, badges: [['E', 80, 865, 'bottom']],
    links: [['E', '목록 화면', 'NavigationBar의 집중 탭으로 이동']],
    functions: [
      ['focusSecondsForTodo()', '할 일별 누적 집중 시간 계산'],
      ['remainingEstimatedSecondsFor()', '예상 시간에서 남은 시간 계산'],
      ['_tick()', '진행 중인 타이머 값을 갱신'],
      ['_syncTicker()', '저장된 세션과 타이머 상태 동기화'],
      ['_toggleTimer()', '타이머 시작·일시정지·재개'],
      ['_complete()', '현재 집중 세션의 완료 처리 시작'],
      ['_finishAndPrompt()', '집중 기록 저장 후 다음 행동 안내'],
    ],
    initialization: [
      'initState() → Get.find<TodoController>() · observer 등록',
      'ever(activeWorkSession)로 세션 변경 감지',
      '_syncTicker()로 실행 중 타이머를 즉시 복구',
    ],
  },
  {
    file: '07_statistics_screen.png', title: '07. 통계 화면', subtitle: '생성·완료·마감·집중 데이터를 주간 단위로 분석',
    crop: { left: 1940, top: 1280 }, badges: [['F', 80, 865, 'bottom']],
    links: [['F', '목록 화면', 'NavigationBar의 통계 탭으로 이동']],
    functions: [
      ['weeklyCreatedCountsFor()', '주간 할 일 생성 건수 집계'],
      ['weeklyCompletedCountsFor()', '주간 완료 건수 집계'],
      ['categoryCompletionStats', '카테고리별 완료율 getter'],
      ['priorityCompletionStats', '우선순위별 완료율 getter'],
      ['completedOnTimeCount', '기한 내 완료 건수 getter'],
      ['delayedCount', '기한이 지난 할 일 건수 getter'],
      ['weeklyFocusSecondsFor()', '주간 실제 집중 시간 집계'],
    ],
    initialization: [
      '별도 initState() 없음 · TodoController 데이터 공유',
      'Obx build 시 이번 주·지난주 통계를 다시 계산',
    ],
  },
];

function esc(value) {
  return value.replace(/[&<>]/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[ch]));
}

function overlaySvg(screen) {
  const badgeScaleX = screenWidth / cropWidth;
  const badgeScaleY = screenHeight / cropHeight;
  const badges = screen.badges.map(([letter, x, y, side]) => {
    const anchorX = screenLeft + x * badgeScaleX;
    const anchorY = screenTop + y * badgeScaleY;
    let cx = anchorX;
    let cy = anchorY;
    let line = '';
    if (side === 'left') {
      cx = screenLeft - 25;
      line = `<line x1="${cx + 22}" y1="${cy}" x2="${screenLeft + 8}" y2="${anchorY}" class="badgeLine"/>`;
    } else if (side === 'right') {
      cx = screenLeft + screenWidth + 25;
      line = `<line x1="${screenLeft + screenWidth - 8}" y1="${anchorY}" x2="${cx - 22}" y2="${cy}" class="badgeLine"/>`;
    } else if (side === 'bottom') {
      cy = screenTop + screenHeight + 27;
      line = `<line x1="${anchorX}" y1="${screenTop + screenHeight - 8}" x2="${cx}" y2="${cy - 22}" class="badgeLine"/>`;
    }
    return `${line}<circle cx="${cx}" cy="${cy}" r="21" class="screenBadgeCircle"/><text x="${cx}" y="${cy + 8}" text-anchor="middle" class="screenBadgeLetter">${letter}</text>`;
  }).join('');

  const linkRows = screen.links.map(([letter, target, comment], index) => {
    const y = 300 + index * 84;
    return `<circle cx="910" cy="${y}" r="25" class="linkCircle"/><text x="910" y="${y + 8}" text-anchor="middle" class="linkLetter">${letter}</text><text x="955" y="${y - 5}" class="target">${esc(target)}</text><text x="955" y="${y + 27}" class="comment">${esc(comment)}</text>`;
  }).join('');

  const functionRows = screen.functions.map(([name, comment], index) => {
    const y = 295 + index * 72;
    return `<text x="1370" y="${y}" class="functionName">${esc(name)}</text><text x="1370" y="${y + 29}" class="functionComment">${esc(comment)}</text>`;
  }).join('');

  const initializationRows = screen.initialization.map((line, index) =>
    `<text x="1050" y="${846 + index * 25}" class="initText">• ${esc(line)}</text>`,
  ).join('');

  return Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${slideWidth}" height="${slideHeight}">
    <style>
      .title{font:700 42px 'Malgun Gothic',sans-serif;fill:#171a25}.subtitle{font:22px 'Malgun Gothic',sans-serif;fill:#70798c}
      .panelTitle{font:700 26px 'Malgun Gothic',sans-serif;fill:#292e3b}.target{font:700 20px 'Malgun Gothic',sans-serif;fill:#292e3b}
      .comment{font:16px 'Malgun Gothic',sans-serif;fill:#70798c}.functionName{font:700 17px Consolas,'Malgun Gothic',monospace;fill:#555dd6}.functionComment{font:16px 'Malgun Gothic',sans-serif;fill:#70798c}.linkLetter{font:700 25px Arial,sans-serif;fill:#fff}
      .initTitle{font:700 20px 'Malgun Gothic',sans-serif;fill:#292e3b}.initText{font:15px 'Malgun Gothic',sans-serif;fill:#596273}
      .screenBadgeLetter{font:700 23px Arial,sans-serif;fill:#555dd6}.screenBadgeCircle{fill:#fff;stroke:#626cf5;stroke-width:4}.badgeLine{stroke:#8a91f8;stroke-width:3}
      .linkCircle{fill:#626cf5}.line{stroke:#d9dcef;stroke-width:2}.note{font:18px 'Malgun Gothic',sans-serif;fill:#8b93a3}
    </style>
    <text x="70" y="62" class="title">${esc(screen.title)}</text><text x="70" y="94" class="subtitle">${esc(screen.subtitle)}</text>
    <rect x="815" y="155" width="1035" height="790" rx="28" fill="#fff" stroke="#d9dcef" stroke-width="2"/>
    <text x="865" y="225" class="panelTitle">화면 연결</text><text x="1370" y="225" class="panelTitle">주요 함수</text>
    <line x1="865" y1="250" x2="1800" y2="250" class="line"/><line x1="1320" y1="195" x2="1320" y2="790" class="line"/>
    <line x1="865" y1="790" x2="1800" y2="790" class="line"/><text x="865" y="846" class="initTitle">초기 화면 구성</text>
    ${badges}${linkRows}${functionRows}${initializationRows}
  </svg>`);
}

async function main() {
  const source = sharp(Buffer.from(cleanSourceSvg));
  for (const screen of screens) {
    const crop = await source.clone().extract({ left: screen.crop.left, top: screen.crop.top, width: cropWidth, height: cropHeight }).resize({ width: screenWidth, height: screenHeight }).png().toBuffer();
    await sharp({ create: { width: slideWidth, height: slideHeight, channels: 4, background: '#fafbfc' } })
      .composite([{ input: crop, left: screenLeft, top: screenTop }, { input: overlaySvg(screen), left: 0, top: 0 }])
      .png().toFile(path.join(outputDir, screen.file));
  }
}

main().catch((error) => { console.error(error); process.exitCode = 1; });
