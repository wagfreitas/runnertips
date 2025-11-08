import 'package:flutter/material.dart';
import '../../../../shared/widgets/navigation/bottom_navigation.dart';
import '../../../race/presentation/pages/races_screen.dart';
import '../../../tips/presentation/pages/tips_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BottomNavItem _selectedItem = BottomNavItem.races;
  final PageStorageBucket _bucket = PageStorageBucket();

  void _onItemSelected(BottomNavItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: BottomNavItem.values.indexOf(_selectedItem),
          children: BottomNavItem.values.map(_buildPage).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        selectedItem: _selectedItem,
        onItemSelected: _onItemSelected,
      ),
    );
  }

  Widget _buildPage(BottomNavItem item) {
    switch (item) {
      case BottomNavItem.community:
        return _buildPlaceholder(
          title: 'Comunidade',
          description:
              'Em breve você poderá acompanhar dicas e discussões da comunidade.',
        );
      case BottomNavItem.races:
        return const RacesScreen();
      case BottomNavItem.tips:
        return const TipsScreen();
      case BottomNavItem.profile:
        return const ProfileScreen();
    }
  }

  Widget _buildPlaceholder({
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

