import 'package:flutter/material.dart';
import '../../domain/enums/budget_activity.dart';
import '../../theme/app_theme.dart';

class ActivityBadge extends StatelessWidget {
  final BudgetActivity activity;
  final bool compact;

  const ActivityBadge({
    super.key,
    required this.activity,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppTheme.colorForActivity(activity, isDark: isDark);

    IconData icon;
    switch (activity) {
      case BudgetActivity.income:
        icon = Icons.arrow_downward_rounded;
        break;
      case BudgetActivity.expense:
        icon = Icons.arrow_upward_rounded;
        break;
      case BudgetActivity.saving:
        icon = Icons.savings_outlined;
        break;
      case BudgetActivity.investing:
        icon = Icons.trending_up_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.45 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            activity.displayName,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
