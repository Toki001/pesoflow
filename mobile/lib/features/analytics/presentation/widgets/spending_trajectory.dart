import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../domain/analytics_report.dart';

class SpendingTrajectory extends StatelessWidget {
  const SpendingTrajectory(this.report, {super.key});
  final AnalyticsReport report;
  Future<void> showPoints(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending trajectory', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text(
              report.selection.includesOctoberSnapshot
                  ? 'Demo aggregate with an illustrative October trajectory. Points between reference dates are interpolated; session edits apply dated changes.'
                  : 'Cumulative net expenses from the available demo records. Refunds reduce expense; transfers and pending records are excluded.',
              style: AppTypography.bodySmall,
            ),
            for (final point in report.points)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Text(DateFormat('MMM d, yyyy').format(point.date)),
                      Text(MoneyFormatter.php(point.amount)),
                    ],
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final target = report.target;
    final projected = report.projectedExpense;
    final below = report.belowTargetPercent;
    final pace = below == null
        ? 'Target pace is not set for this period.'
        : below >= 0
        ? 'Your spending pace is $below% below your monthly target.'
        : 'Your spending pace is ${below.abs()}% above your monthly target.';
    final legend = Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Actual',
              style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
            ),
          ],
        ),
        if (target != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 10, height: 2, color: c.mutedInk),
              const SizedBox(width: 4),
              Text(
                'Target',
                style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
              ),
            ],
          ),
      ],
    );
    final start = report.selection.start;
    final last = report.selection.end.subtract(const Duration(days: 1));
    final ticks = report.selection.period == AnalyticsPeriod.day
        ? [start]
        : report.selection.period == AnalyticsPeriod.month
        ? [
            DateTime(start.year, start.month, 1),
            DateTime(start.year, start.month, 8),
            DateTime(start.year, start.month, 15),
            DateTime(start.year, start.month, math.min(24, last.day)),
            last,
          ]
        : [
            start,
            DateTime(
              start.year,
              start.month,
              start.day + report.selection.days ~/ 2,
            ),
            last,
          ];
    return FinanceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending Trajectory', style: AppTypography.headlineSmall),
          const SizedBox(height: 2),
          LayoutBuilder(
            builder: (context, constraints) {
              final subtitle = Text(
                target == null
                    ? 'Cumulative net expense'
                    : 'Cumulative spend vs planned target pace',
                style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
              );
              return constraints.maxWidth < 290 ||
                      MediaQuery.textScalerOf(context).scale(14) > 19
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [subtitle, const SizedBox(height: 8), legend],
                    )
                  : Row(
                      children: [
                        Expanded(child: subtitle),
                        const SizedBox(width: 8),
                        legend,
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label:
                'Spending chart. Net expense ${MoneyFormatter.php(report.totalExpense)}. ${target == null ? 'No target.' : 'Target ${MoneyFormatter.php(target)}.'} Tap for dated values.',
            child: InkWell(
              onTap: () => showPoints(context),
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    SizedBox(
                      height: 144,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _TrajectoryPainter(report, c),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final tick in ticks)
                          Flexible(
                            child: Text(
                              DateFormat(
                                report.selection.period == AnalyticsPeriod.year
                                    ? 'MMM'
                                    : 'MMM d',
                              ).format(tick),
                              style: AppTypography.labelSmall.copyWith(
                                color:
                                    tick.day == 24 &&
                                        report.selection.period ==
                                            AnalyticsPeriod.month
                                    ? c.primary
                                    : c.mutedInk,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.mutedSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights, size: 20, color: c.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$pace${projected == null ? '' : ' Projected end-of-month spend: ${MoneyFormatter.php(projected, decimals: false)}.'}',
                    style: AppTypography.bodySmall.copyWith(
                      color: c.secondaryInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrajectoryPainter extends CustomPainter {
  _TrajectoryPainter(this.report, this.colors);
  final AnalyticsReport report;
  final FinancePalette colors;
  @override
  void paint(Canvas canvas, Size size) {
    final points = report.points;
    if (points.isEmpty) return;
    final maxAmount = math.max(
      1,
      math.max(
        report.target ?? 0,
        points.map((p) => p.amount).reduce(math.max),
      ),
    );
    final minAmount = math.min(0, points.map((p) => p.amount).reduce(math.min));
    final range = maxAmount - minAmount;
    double y(int amount) =>
        size.height - (amount - minAmount) / range * (size.height - 16);
    final span = math.max(1, report.selection.days - 1);
    double x(DateTime date) =>
        DateTime.utc(date.year, date.month, date.day)
            .difference(
              DateTime.utc(
                report.selection.start.year,
                report.selection.start.month,
                report.selection.start.day,
              ),
            )
            .inDays /
        span *
        size.width;
    final grid = Paint()
      ..color = colors.border.withValues(alpha: .45)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final height = i * size.height / 3;
      for (double left = 0; left < size.width; left += 5) {
        canvas.drawLine(
          Offset(left, height),
          Offset(math.min(left + 2, size.width), height),
          grid,
        );
      }
    }
    if (report.target case final target?) {
      final first = Offset(0, y(0));
      final last = Offset(size.width, y(target));
      final targetPaint = Paint()
        ..color = colors.mutedInk
        ..strokeWidth = 1.5;
      final distance = (last - first).distance;
      for (double n = 0; n < distance; n += 8) {
        canvas.drawLine(
          Offset.lerp(first, last, n / distance)!,
          Offset.lerp(first, last, math.min(n + 4, distance) / distance)!,
          targetPaint,
        );
      }
    }
    final line = Path()..moveTo(x(points.first.date), y(points.first.amount));
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      final midpoint = (x(a.date) + x(b.date)) / 2;
      line.cubicTo(
        midpoint,
        y(a.amount),
        midpoint,
        y(b.amount),
        x(b.date),
        y(b.amount),
      );
    }
    // A single-day data point still has a visible marker.
    final area = Path.from(line)
      ..lineTo(x(points.last.date), y(0))
      ..lineTo(x(points.first.date), y(0))
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: .25),
            AppColors.primary.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = colors.isDark ? colors.primary : AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    final end = Offset(x(points.last.date), y(points.last.amount));
    for (double top = end.dy; top < size.height; top += 4) {
      canvas.drawLine(
        Offset(end.dx, top),
        Offset(end.dx, math.min(top + 2, size.height)),
        Paint()
          ..color = colors.primary
          ..strokeWidth = 1,
      );
    }
    canvas.drawCircle(end, 4.5, Paint()..color = colors.surface);
    canvas.drawCircle(
      end,
      3.5,
      Paint()..color = colors.isDark ? colors.primary : AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(_TrajectoryPainter oldDelegate) =>
      oldDelegate.report != report ||
      oldDelegate.colors.isDark != colors.isDark;
}
