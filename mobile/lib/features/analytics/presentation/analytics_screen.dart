import 'package:pesoflow/core/time/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/features/notifications/presentation/widgets/notification_button.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/widgets/category_icon.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/features/analytics/application/analytics_provider.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/analytics/presentation/widgets/analytics_controls.dart';
import 'package:pesoflow/features/analytics/presentation/widgets/expense_hero.dart';
import 'package:pesoflow/features/analytics/presentation/widgets/spending_trajectory.dart';
import 'package:pesoflow/features/analytics/presentation/widgets/category_breakdown.dart';
import 'package:pesoflow/features/analytics/presentation/widgets/top_merchants.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool percentage = false;
  Future<void> pickDate() async {
    final selection = ref.read(analyticsSelectionProvider);
    final selected = await showDatePicker(
      context: context,
      initialDate: selection.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12, 31),
      helpText: 'Choose an analytics date',
    );
    if (selected != null && mounted) {
      ref.read(analyticsSelectionProvider.notifier).selectDate(selected);
    }
  }

  void preview(AnalyticsReport report) => showModalBottomSheet<void>(
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
            Text('Analytics summary', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            SelectableText(
              'PesoFlow · ${DateFormat('MMM d, yyyy').format(report.selection.start)} – ${DateFormat('MMM d, yyyy').format(report.selection.end.subtract(const Duration(days: 1)))}\n'
              'Net expenses: ${MoneyFormatter.php(report.totalExpense)}\nDaily average: ${MoneyFormatter.php(report.dailyAverage)}\n'
              '${report.categories.map((c) => '${analyticsCategoryName(c.category)}: ${MoneyFormatter.php(c.amount)}').join('\n')}',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'This is a selectable summary. File export and system sharing are not available yet.',
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
    final state = ref.watch(analyticsProvider);
    final selection = ref.watch(analyticsSelectionProvider);
    final dateLabel = switch (selection.period) {
      AnalyticsPeriod.day => DateFormat('MMM d, yyyy').format(selection.date),
      AnalyticsPeriod.week =>
        '${DateFormat('MMM d').format(selection.start)} – ${DateFormat('MMM d').format(selection.end.subtract(const Duration(days: 1)))}',
      AnalyticsPeriod.month => DateFormat('MMMM yyyy').format(selection.date),
      AnalyticsPeriod.year => '${selection.date.year}',
    };
    final periodControl = AnalyticsSegments<AnalyticsPeriod>(
      options: const {
        AnalyticsPeriod.day: 'Day',
        AnalyticsPeriod.week: 'Week',
        AnalyticsPeriod.month: 'Month',
        AnalyticsPeriod.year: 'Year',
      },
      selected: selection.period,
      onSelected: ref.read(analyticsSelectionProvider.notifier).selectPeriod,
    );
    final dateControl = TextButton(
      onPressed: pickDate,
      style: TextButton.styleFrom(
        backgroundColor: c.mutedSurface,
        foregroundColor: c.ink,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: const Size(48, 48),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(dateLabel, style: AppTypography.labelMedium)),
          const SizedBox(width: 4),
          Icon(Icons.expand_more, size: 16, color: c.mutedInk),
        ],
      ),
    );
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(bottom: BorderSide(color: c.border)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: c.soft(
                          c.primary,
                          AppColors.primarySoft,
                        ),
                        child: Text(
                          'PF',
                          style: AppTypography.labelSmall.copyWith(
                            color: c.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Analytics',
                          style: AppTypography.headlineSmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Share Analytics',
                        onPressed: state.value == null
                            ? null
                            : () => preview(state.value!),
                        icon: Icon(
                          Icons.ios_share,
                          size: 20,
                          color: c.mutedInk,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Calendar History',
                        onPressed: pickDate,
                        icon: Icon(
                          Icons.calendar_month_outlined,
                          size: 20,
                          color: c.mutedInk,
                        ),
                      ),
                      NotificationButton(color: c.mutedInk),
                    ],
                  ),
                ),
                Divider(height: 1, color: c.border),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: LayoutBuilder(
                    builder: (context, bounds) =>
                        bounds.maxWidth < 350 ||
                            MediaQuery.textScalerOf(context).scale(14) > 19
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              dateControl,
                              const SizedBox(height: 8),
                              periodControl,
                            ],
                          )
                        : Row(
                            children: [
                              Flexible(flex: 4, child: dateControl),
                              const SizedBox(width: 12),
                              Flexible(flex: 6, child: periodControl),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => Semantics(
                label: 'Loading analytics',
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final height in [140.0, 340.0, 200.0])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FinanceCard(
                          child: SizedBox(
                            height: height,
                            child: ColoredBox(color: c.mutedSurface),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              error: (_, _) => Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "We couldn't load your analytics.",
                        style: AppTypography.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please try again. Your saved records are still available.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.invalidate(analyticsProvider),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (report) => !report.hasActivity
                  ? Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 32,
                              color: c.mutedInk,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No spending in this period',
                              style: AppTypography.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add an expense or choose another period to view your spending.',
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(analyticsSelectionProvider.notifier)
                                    .selectDate(ref.read(clockProvider)());
                                ref
                                    .read(analyticsSelectionProvider.notifier)
                                    .selectPeriod(AnalyticsPeriod.month);
                              },
                              child: const Text('View this month'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      key: const PageStorageKey('analytics-scroll'),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      child: Column(
                        children: [
                          ExpenseHero(report),
                          const SizedBox(height: 16),
                          SpendingTrajectory(report),
                          const SizedBox(height: 16),
                          _Intelligence(report),
                          const SizedBox(height: 16),
                          CategoryBreakdown(
                            report,
                            percentage: percentage,
                            onPercentage: (value) =>
                                setState(() => percentage = value),
                          ),
                          const SizedBox(height: 16),
                          TopMerchants(report),
                          const SizedBox(height: 16),
                          Text(
                            'Based on your saved, posted transactions up to today.',
                            style: AppTypography.bodySmall.copyWith(
                              color: c.mutedInk,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Intelligence extends StatelessWidget {
  const _Intelligence(this.report);
  final AnalyticsReport report;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final below = report.belowTargetPercent;
    final title = below == null
        ? 'Period Overview'
        : below >= 0
        ? 'Pacing Well'
        : 'Review Your Pace';
    final copy =
        'Your net expenses are ${MoneyFormatter.php(report.totalExpense)} this period. ${report.comparison.change <= 0 ? 'Spending is lower or unchanged from the previous period.' : 'Spending is higher than the previous period.'}';
    return FinanceCard(
      color: c.insight,
      borderColor: c.accentBorder,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryIcon(
            Icons.auto_awesome_outlined,
            foreground: c.accent,
            background: c.surface,
            size: 36,
            iconSize: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMedium.copyWith(
                        color: c.accent,
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: c.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      'Financial Intelligence',
                      style: AppTypography.labelSmall.copyWith(
                        color: c.mutedInk,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  copy,
                  style: AppTypography.bodySmall.copyWith(height: 1.65),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
