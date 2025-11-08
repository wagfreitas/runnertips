import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/widgets/auth_wrapper.dart';
=======
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../../scripts/seed_races.dart';
>>>>>>> 210d463 (feat: login, pesquisa prontos)
import '../widgets/race_search_bar.dart';
import '../widgets/race_filter_button.dart';
import '../widgets/race_view_switcher.dart';
import '../widgets/race_card.dart';
import '../widgets/race_suggestions_widget.dart';
import '../providers/race_provider.dart';
import '../pages/race_detail_screen.dart';
<<<<<<< HEAD
import '../../../../shared/widgets/navigation/bottom_navigation.dart';
=======
>>>>>>> 210d463 (feat: login, pesquisa prontos)

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
<<<<<<< HEAD
=======
    // TEMPORÁRIO: Executar seed de corridas (apenas uma vez)
    _runSeedOnce();
  }

  Future<void> _runSeedOnce() async {
    // Verifica se já executou o seed (usando shared preferences)
    final prefs = await SharedPreferences.getInstance();
    final hasSeeded = prefs.getBool('has_seeded_races') ?? false;
    
    if (!hasSeeded) {
      try {
        // Importa e executa o seed
        await seedRaces();
        await prefs.setBool('has_seeded_races', true);
        // Recarrega as corridas após o seed
        _raceProvider.loadRaces();
      } catch (e) {
        print('Erro ao executar seed: $e');
      }
    }
>>>>>>> 210d463 (feat: login, pesquisa prontos)
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sessionService.dispose();
    _raceProvider.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
<<<<<<< HEAD
=======
    print('🔴 Logout button clicked');
    
    if (!mounted) {
      print('⚠️ Widget not mounted');
      return;
    }

>>>>>>> 210d463 (feat: login, pesquisa prontos)
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
<<<<<<< HEAD
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
=======
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
>>>>>>> 210d463 (feat: login, pesquisa prontos)
            child: const Text('Sair'),
          ),
        ],
      ),
    );

<<<<<<< HEAD
    if (shouldLogout == true) {
      await _sessionService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthWrapper(),
          ),
        );
      }
=======
    print('🔴 Dialog result: $shouldLogout');

    if (shouldLogout == true) {
      print('🔴 Starting logout process...');
      
      if (!mounted) {
        print('⚠️ Widget not mounted before logout');
        return;
      }

      try {
        // Mostrar loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Fazer logout no serviço
        print('🔴 Calling sessionService.logout()...');
        await _sessionService.logout();
        print('✅ Logout completed in sessionService');

        if (!mounted) {
          print('⚠️ Widget not mounted after logout');
          return;
        }

        // Fechar o loading
        Navigator.of(context, rootNavigator: true).pop();

        // Aguardar um frame para garantir que o dialog foi fechado
        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) {
          print('⚠️ Widget not mounted before navigation');
          return;
        }

        print('🔴 Navigating to LoginScreen...');
        
        // Navegar para a tela de login na raiz, removendo todas as rotas anteriores
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false, // Remove todas as rotas anteriores
        );
        
        print('✅ Navigation completed');
      } catch (e, stackTrace) {
        print('❌ Error during logout: $e');
        print('Stack trace: $stackTrace');
        
        // Fechar o loading se ainda estiver aberto
        if (mounted) {
          try {
            Navigator.of(context, rootNavigator: true).pop();
          } catch (_) {}
          
          // Ainda assim navegar para login
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
        }
      }
    } else {
      print('🔴 Logout cancelled by user');
>>>>>>> 210d463 (feat: login, pesquisa prontos)
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
<<<<<<< HEAD
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
=======
                GestureDetector(
                  onTap: () {
                    print('🔴 Logout button tapped');
                    _handleLogout();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.logout,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
>>>>>>> 210d463 (feat: login, pesquisa prontos)
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

<<<<<<< HEAD
                if (_raceProvider.errorMessage != null) {
=======
                // Mostra mensagem de sucesso via SnackBar se houver
                if (_raceProvider.successMessage != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_raceProvider.successMessage!),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  });
                }

                // Se não há resultados e há uma busca ativa, mostra opção de buscar com IA
                if (_raceProvider.races.isEmpty && 
                    _raceProvider.searchQuery.trim().isNotEmpty && 
                    !_raceProvider.isSearching) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma corrida encontrada',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tente buscar por termos diferentes\nou use IA para encontrar mais corridas',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _raceProvider.isLoading 
                              ? null 
                              : () => _raceProvider.searchExternalRaces(),
                          icon: const Icon(Icons.auto_awesome, size: 20),
                          label: const Text('Buscar usando IA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Mostra erro apenas se houver mensagem de erro específica
                if (_raceProvider.errorMessage != null && 
                    _raceProvider.searchQuery.trim().isEmpty) {
>>>>>>> 210d463 (feat: login, pesquisa prontos)
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
<<<<<<< HEAD
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
=======
>>>>>>> 210d463 (feat: login, pesquisa prontos)
    );
  }
}
