import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader_board/src/features/leaderboard/application/leaderboard_state_controller.dart';
import 'package:leader_board/src/features/leaderboard/domain/leaderboard.dart';

class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardStateControllerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PeriodChip(
            label: 'All Time',
            selected: state.selectedPeriod == LeaderboardPeriod.allTime,
            onTap: () {
              ref
                  .read(leaderboardStateControllerProvider.notifier)
                  .setSelectedPeriod(LeaderboardPeriod.allTime);
            },
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'Monthly',
            selected: state.selectedPeriod == LeaderboardPeriod.monthly,
            onTap: () {
              ref
                  .read(leaderboardStateControllerProvider.notifier)
                  .setSelectedPeriod(LeaderboardPeriod.monthly);
            },
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'Custom',
            selected: state.selectedPeriod == LeaderboardPeriod.custom,
            onTap: () async {
              final now = DateTime.now();
              final startDate = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(2020),
                lastDate: now,
                helpText: 'Select Start Date',
              );

              if (startDate != null && context.mounted) {
                final endDate = await showDatePicker(
                  context: context,
                  initialDate: startDate,
                  firstDate: startDate,
                  lastDate: now,
                  helpText: 'Select End Date',
                );

                if (endDate != null) {
                  final start = DateTime(
                    startDate.year,
                    startDate.month,
                    startDate.day,
                    0,
                    0,
                    0,
                  );
                  final end = DateTime(
                    endDate.year,
                    endDate.month,
                    endDate.day,
                    23,
                    59,
                    59,
                  );
                  ref
                      .read(leaderboardStateControllerProvider.notifier)
                      .setCustomDateRange(start, end);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
