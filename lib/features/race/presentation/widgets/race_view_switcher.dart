import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum RaceViewType { list, map }

class RaceViewSwitcher extends StatelessWidget {
  final RaceViewType selectedView;
  final ValueChanged<RaceViewType>? onViewChanged;

  const RaceViewSwitcher({
    super.key,
    required this.selectedView,
    this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              'List',
              RaceViewType.list,
              Icons.list,
            ),
          ),
          Expanded(
            child: _buildTab(
              context,
              'Map',
              RaceViewType.map,
              Icons.map,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    RaceViewType viewType,
    IconData icon,
  ) {
    final isSelected = selectedView == viewType;
    
    return GestureDetector(
      onTap: () => onViewChanged?.call(viewType),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryOrange : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primaryOrange : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
