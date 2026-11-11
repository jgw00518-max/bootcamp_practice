import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/theme/app_theme.dart';

/// Todo 생성·완료 시각과 집중 세션을 실제 주간 통계로 요약합니다.
class StatisticsPage extends GetView<TodoController> {
  const StatisticsPage({super.key});

  static const _days = ['월', '화', '수', '목', '금', '토', '일'];
  static const _panelGap = 20.0;

  @override
  Widget build(BuildContext context) => Obx(() {
    final created = controller.weeklyCreatedCountsFor(0);
    final completed = controller.weeklyCompletedCountsFor(0);
    final lastCompleted = controller.weeklyCompletedCountsFor(-1);
    final focus = controller.weeklyFocusSecondsFor(0);
    final lastFocus = controller.weeklyFocusSecondsFor(-1);
    final createdTotal = _sum(created);
    final completedTotal = _sum(completed);
    final lastCompletedTotal = _sum(lastCompleted);
    final focusTotal = _sum(focus);
    final lastFocusTotal = _sum(lastFocus);
    final visiblePriorityStats = controller.priorityCompletionStats.entries
        .where((entry) => entry.value.total > 0)
        .toList();
    final maxTodoCount = [
      ...created,
      ...completed,
    ].fold<int>(0, (max, value) => value > max ? value : max);
    final maxFocus = focus.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        18,
        AppDimensions.screenPadding,
        100,
      ),
      children: [
        Row(
          children: [
            Text('통계', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            const Text('이번 주', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: _panelGap),
        Row(
          children: [
            Expanded(
              child: _Metric(label: '생성', value: '$createdTotal'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(label: '완료', value: '$completedTotal'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(
                label: '현재 미완료',
                value: '${controller.todos.length - controller.completedCount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: _panelGap),
        _Panel(
          title: '날짜별 생성·완료 건수',
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _Legend(color: AppColors.primary, label: '생성'),
                  SizedBox(width: 12),
                  _Legend(color: AppColors.green, label: '완료'),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 136,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    7,
                    (index) => _TodoDayBar(
                      day: _days[index],
                      created: created[index],
                      completed: completed[index],
                      maxValue: maxTodoCount,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _panelGap),
        _Panel(
          title: '카테고리별 완료율',
          child: controller.categoryCompletionStats.isEmpty
              ? const _NoData()
              : Column(
                  children: controller.categoryCompletionStats.entries
                      .map(
                        (entry) => _RateRow(
                          key: ValueKey('category_rate_${entry.key}'),
                          label: entry.key,
                          completed: entry.value.completed,
                          total: entry.value.total,
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: _panelGap),
        _Panel(
          title: '우선순위별 완료율',
          child: visiblePriorityStats.isEmpty
              ? const _NoData()
              : Column(
                  children: visiblePriorityStats.map((entry) {
                    final label = switch (entry.key) {
                      2 => '높음',
                      1 => '보통',
                      _ => '낮음',
                    };
                    return _RateRow(
                      key: ValueKey('priority_rate_${entry.key}'),
                      label: label,
                      completed: entry.value.completed,
                      total: entry.value.total,
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: _panelGap),
        _Panel(
          title: '기한 준수',
          child: Row(
            children: [
              Expanded(
                child: _DeadlineMetric(
                  icon: Icons.task_alt_rounded,
                  color: AppColors.green,
                  label: '기한 내 완료',
                  value: controller.completedOnTimeCount,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DeadlineMetric(
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.red,
                  label: '지연',
                  value: controller.delayedCount,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _panelGap),
        _Panel(
          title: '실제 집중 시간',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDuration(focusTotal),
                key: const ValueKey('weekly_focus_total'),
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 124,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    7,
                    (index) => _FocusBar(
                      day: _days[index],
                      seconds: focus[index],
                      maxSeconds: maxFocus,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _panelGap),
        _Panel(
          key: const ValueKey('weekly_comparison_panel'),
          title: '이번 주와 지난주 비교',
          child: Column(
            children: [
              _ComparisonRow(
                label: '완료한 할 일',
                current: '$completedTotal건',
                previous: '$lastCompletedTotal건',
                change: _changeText(completedTotal, lastCompletedTotal),
              ),
              const Divider(height: 26),
              _ComparisonRow(
                label: '실제 집중 시간',
                current: _formatDuration(focusTotal),
                previous: _formatDuration(lastFocusTotal),
                change: _changeText(focusTotal, lastFocusTotal),
              ),
            ],
          ),
        ),
      ],
    );
  });

  static int _sum(List<int> values) =>
      values.fold(0, (sum, value) => sum + value);

  static String _changeText(int current, int previous) {
    if (previous == 0) return current == 0 ? '변화 없음' : '이번 주 새 기록';
    final change = ((current - previous) / previous * 100).round();
    if (change == 0) return '변화 없음';
    return change > 0 ? '+$change%' : '$change%';
  }

  static String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes분';
    final remainder = minutes % 60;
    return remainder == 0
        ? '${minutes ~/ 60}시간'
        : '${minutes ~/ 60}시간 $remainder분';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 92,
    child: Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
          ),
        ],
      ),
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppDimensions.cardPadding),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    super.key,
    required this.label,
    required this.completed,
    required this.total,
  });

  final String label;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0.0 : completed / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: AppColors.surface,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 74,
            child: Text(
              '$completed/$total  ${(rate * 100).round()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeadlineMetric extends StatelessWidget {
  const _DeadlineMetric({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text(
                '$value건',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TodoDayBar extends StatelessWidget {
  const _TodoDayBar({
    required this.day,
    required this.created,
    required this.completed,
    required this.maxValue,
  });

  final String day;
  final int created;
  final int completed;
  final int maxValue;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        '$created/$completed',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BarBlock(
            color: AppColors.primary,
            height: maxValue == 0 ? 0 : 76 * created / maxValue,
          ),
          const SizedBox(width: 3),
          _BarBlock(
            color: AppColors.green,
            height: maxValue == 0 ? 0 : 76 * completed / maxValue,
          ),
        ],
      ),
      const SizedBox(height: 7),
      Text(day, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
    ],
  );
}

class _FocusBar extends StatelessWidget {
  const _FocusBar({
    required this.day,
    required this.seconds,
    required this.maxSeconds,
  });

  final String day;
  final int seconds;
  final int maxSeconds;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        '${seconds ~/ 60}',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      _BarBlock(
        color: AppColors.primary,
        height: maxSeconds == 0 ? 0 : 76 * seconds / maxSeconds,
        width: 12,
      ),
      const SizedBox(height: 7),
      Text(day, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
    ],
  );
}

class _BarBlock extends StatelessWidget {
  const _BarBlock({required this.color, required this.height, this.width = 8});

  final Color color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
    ],
  );
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.change,
  });

  final String label;
  final String current;
  final String previous;
  final String change;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '이번 주 $current',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(
            '지난주 $previous · $change',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    ],
  );
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) =>
      const Text('집계할 데이터가 없어요.', style: TextStyle(color: AppColors.muted));
}
