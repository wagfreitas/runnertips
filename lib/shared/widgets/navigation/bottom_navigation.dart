import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum BottomNavItem { community, races, training, profile }

class BottomNavigation extends StatelessWidget {
  final BottomNavItem selectedItem;
  final ValueChanged<BottomNavItem>? onItemSelected;

  const BottomNavigation({
    super.key,
    required this.selectedItem,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.groups,
                'Community',
                BottomNavItem.community,
              ),
              _buildNavItem(
                context,
                Icons.emoji_events,
                'Races',
                BottomNavItem.races,
                isSelected: true,
              ),
              _buildNavItem(
                context,
                Icons.fitness_center,
                'Training',
                BottomNavItem.training,
              ),
              _buildNavItem(
                context,
                Icons.person,
                'Profile',
                BottomNavItem.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    BottomNavItem item, {
    bool isSelected = false,
  }) {
    final isActive = selectedItem == item || isSelected;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelected?.call(item),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive ? AppColors.primaryOrange : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.primaryOrange : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
