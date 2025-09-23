import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/widgets/auth_wrapper.dart';
import '../widgets/race_search_bar.dart';
import '../widgets/race_filter_button.dart';
import '../widgets/race_view_switcher.dart';
import '../widgets/race_card.dart';
import '../widgets/race_suggestions_widget.dart';
import '../providers/race_provider.dart';
import '../pages/race_detail_screen.dart';
import '../../../../shared/widgets/navigation/bottom_navigation.dart';

class RacesScreen extends StatefulWidget {
  const RacesScreen({super.key});

  @override
  State<RacesScreen> createState() => _RacesScreenState();
}

class _RacesScreenState extends State<RacesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SessionService _sessionService = SessionService();
  late final RaceProvider _raceProvider;
  String _selectedFilter = 'none';
  RaceViewType _selectedView = RaceViewType.list;


  @override
  void initState() {
    super.initState();
    _raceProvider = RaceProvider();
    _raceProvider.loadRaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sessionService.dispose();
    _raceProvider.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _sessionService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthWrapper(),
          ),
        );
      }
    }
  }

  void _onRaceTap(race) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RaceDetailScreen(race: race),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _raceProvider.searchRaces(value);
  }

  void _onSuggestionSelected(suggestion) {
    _raceProvider.addSuggestedRace(suggestion);
  }

  Widget _buildRaceList() {
    final races = _raceProvider.races;
    
    if (races.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma corrida encontrada',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tente buscar por termos diferentes',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: races.length,
      itemBuilder: (context, index) {
        final race = races[index];
        return RaceCard(
          imageUrl: race.imageUrl,
          date: race.formattedDate,
          name: race.name,
          location: race.location,
          status: race.status,
          distance: race.distance,
          onTap: () => _onRaceTap(race),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SizedBox(width: 40), // Balance the logout button
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Races',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _handleLogout,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RaceSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
          ),

          // Filter Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  RaceFilterButton(
                    text: 'Location',
                    icon: Icons.location_on,
                    isSelected: _selectedFilter == 'location',
                    onPressed: () {
                      setState(() {
                        _selectedFilter = _selectedFilter == 'location' ? 'none' : 'location';
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  RaceFilterButton(
                    text: 'Date',
                    icon: Icons.calendar_today,
                    isSelected: _selectedFilter == 'date',
                    onPressed: () {
                      setState(() {
                        _selectedFilter = _selectedFilter == 'date' ? 'none' : 'date';
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  RaceFilterButton(
                    text: 'Distance',
                    icon: Icons.straighten,
                    isSelected: _selectedFilter == 'distance',
                    onPressed: () {
                      setState(() {
                        _selectedFilter = _selectedFilter == 'distance' ? 'none' : 'distance';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // View Switcher
          RaceViewSwitcher(
            selectedView: _selectedView,
            onViewChanged: (viewType) {
              setState(() {
                _selectedView = viewType;
              });
            },
          ),

          // Content
          Expanded(
            child: ListenableBuilder(
              listenable: _raceProvider,
              builder: (context, child) {
                if (_raceProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_raceProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _raceProvider.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _raceProvider.loadRaces(),
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Lista de corridas ou sugestões
                    Expanded(
                      child: _selectedView == RaceViewType.list
                          ? _buildRaceList()
                          : const Center(
                              child: Text(
                                'Map view coming soon!',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),

                    // Sugestões de corridas
                    if (_raceProvider.showSuggestions)
                      RaceSuggestionsWidget(
                        suggestions: _raceProvider.suggestions,
                        onSuggestionSelected: _onSuggestionSelected,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        selectedItem: BottomNavItem.races,
        onItemSelected: (item) {
          // TODO: Handle navigation to other tabs
          switch (item) {
            case BottomNavItem.community:
              // Navigate to community
              break;
            case BottomNavItem.races:
              // Already on races
              break;
            case BottomNavItem.training:
              // Navigate to training
              break;
            case BottomNavItem.profile:
              // Navigate to profile
              break;
          }
        },
      ),
    );
  }
}
