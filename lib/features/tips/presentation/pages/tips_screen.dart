import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/services/tip_service.dart';
import '../../../../core/models/tip_model.dart';
import '../../../../core/constants/app_colors.dart';
import 'create_tip_screen.dart';

class TipsScreen extends StatefulWidget {
  final String? raceId;
  final String? cityId;

  const TipsScreen({
    super.key,
    this.raceId,
    this.cityId,
  });

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final TipService _tipService = TipService();
  final TextEditingController _searchController = TextEditingController();

  List<TipModel> _tips = [];
  bool _isLoading = true;
  String? _error;
  TipType? _selectedType;
  TipCategory? _selectedCategory;
  TipSortOption _selectedSort = TipSortOption.recent;
  Timer? _searchDebounce;
  Map<TipType, int> _tipsCountByType = {};
  bool _showCategories = false;

  @override
  void initState() {
    super.initState();
    // Se há filtro por corrida, mostrar categorias
    _showCategories = widget.raceId != null || widget.cityId != null;
    _loadTips();
    if (_showCategories) {
      _loadTipsCount();
    }
  }
  
  Future<void> _loadTipsCount() async {
    try {
      final counts = await _tipService.getTipsCountByType(
        raceId: widget.raceId,
        cityId: widget.cityId,
      );
      if (mounted) {
        setState(() {
          _tipsCountByType = counts;
        });
      }
    } catch (e) {
      print('Erro ao carregar contagem de dicas: $e');
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTips({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final tips = await _tipService.getTips(
        raceId: widget.raceId,
        cityId: widget.cityId,
        type: _selectedType,
        category: _selectedCategory,
        sortOption: _selectedSort,
        searchTerm: _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _tips = tips;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar dicas: $e';
        _isLoading = false;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedCategory = null;
      _selectedSort = TipSortOption.recent;
      _searchController.clear();
    });
    _loadTips();
  }

  void _onTypeSelected(TipType type, bool selected) {
    setState(() {
      _selectedType = selected ? type : null;
    });
    _loadTips();
  }

  void _onCategorySelected(TipCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadTips();
  }

  void _onSortSelected(TipSortOption? option) {
    if (option == null) return;
    setState(() {
      _selectedSort = option;
    });
    _loadTips(showLoading: false);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _loadTips(showLoading: false);
    });
  }

  String _getTipTypeLabel(TipType type) {
    switch (type) {
      case TipType.hotel:
        return '🏨 Hotel';
      case TipType.restaurant:
        return '🍝 Restaurante';
      case TipType.transport:
        return '🚗 Transporte';
      case TipType.tourism:
        return '🏛️ Turismo';
      case TipType.raceTip:
        return '🏃 Dica de Corrida';
      case TipType.general:
        return '📝 Geral';
    }
  }

  String _getCategoryLabel(TipCategory category) {
    switch (category) {
      case TipCategory.accommodation:
        return 'Hospedagem';
      case TipCategory.food:
        return 'Alimentação';
      case TipCategory.transportation:
        return 'Transporte';
      case TipCategory.tourism:
        return 'Turismo';
      case TipCategory.climate:
        return 'Clima';
      case TipCategory.elevation:
        return 'Altimetria';
      case TipCategory.organization:
        return 'Organização';
      case TipCategory.logistics:
        return 'Logística';
      case TipCategory.nutrition:
        return 'Nutrição';
      case TipCategory.general:
        return 'Geral';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dicas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTips,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateTipScreen(
                raceId: widget.raceId,
                cityId: widget.cityId,
              ),
            ),
          );
          
          // Se a dica foi criada com sucesso, recarrega a lista
          if (result == true) {
            _loadTips();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Criar nova dica',
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTips,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // Se há filtro por corrida e não há tipo selecionado, mostrar categorias
    if (_showCategories && _selectedType == null && _selectedCategory == null) {
      return Column(
        children: [
          Expanded(
            child: _buildCategoriesView(),
          ),
        ],
      );
    }

    // Caso contrário, mostrar lista de dicas com filtros
    return Column(
      children: [
        // Botão para voltar às categorias se está filtrado por tipo
        if (_showCategories && _selectedType != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedType = null;
                  _selectedCategory = null;
                });
                _loadTips();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar às categorias'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        _buildFilters(),
        if (widget.raceId != null || widget.cityId != null)
          _buildContextBadges(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadTips();
              if (_showCategories) {
                await _loadTipsCount();
              }
            },
            child: _tips.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _tips.length,
                    itemBuilder: (context, index) {
                      final tip = _tips[index];
                      return _buildTipCard(tip);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesView() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadTipsCount();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.raceId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Categorias de Dicas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          _buildCategoryCard(TipType.tourism, 'Turismo', Icons.landscape),
          const SizedBox(height: 12),
          _buildCategoryCard(TipType.hotel, 'Hotéis', Icons.hotel),
          const SizedBox(height: 12),
          _buildCategoryCard(TipType.raceTip, 'Corrida', Icons.directions_run),
          const SizedBox(height: 12),
          _buildCategoryCard(TipType.restaurant, 'Restaurantes', Icons.restaurant),
          const SizedBox(height: 12),
          _buildCategoryCard(TipType.transport, 'Transporte', Icons.directions_transit),
          const SizedBox(height: 12),
          _buildCategoryCard(TipType.general, 'Geral', Icons.info_outline),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(TipType type, String label, IconData icon) {
    final count = _tipsCountByType[type] ?? 0;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
          _loadTips();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: count > 0 
                      ? AppColors.primaryOrange.withOpacity(0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: count > 0 
                        ? AppColors.primaryOrange
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma dica encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.raceId != null
                ? 'Seja o primeiro a compartilhar uma dica!'
                : 'Comece criando sua primeira dica.',
            style: const TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar dicas por título, conteúdo ou tags',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadTips();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TipType.values.map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(_getTipTypeLabel(type)),
                    onSelected: (selected) =>
                        _onTypeSelected(type, selected),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TipCategory?>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<TipCategory?>(
                      value: null,
                      child: Text('Todas as categorias'),
                    ),
                    ...TipCategory.values.map((category) {
                      return DropdownMenuItem<TipCategory>(
                        value: category,
                        child: Text(_getCategoryLabel(category)),
                      );
                    }),
                  ],
                  onChanged: _onCategorySelected,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<TipSortOption>(
                  value: _selectedSort,
                  decoration: const InputDecoration(
                    labelText: 'Ordenar por',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: TipSortOption.recent,
                      child: Text('Mais recentes'),
                    ),
                    DropdownMenuItem(
                      value: TipSortOption.mostHelpful,
                      child: Text('Mais úteis'),
                    ),
                    DropdownMenuItem(
                      value: TipSortOption.mostViewed,
                      child: Text('Mais visualizadas'),
                    ),
                    DropdownMenuItem(
                      value: TipSortOption.mostLiked,
                      child: Text('Mais curtidas'),
                    ),
                  ],
                  onChanged: _onSortSelected,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Limpar filtros'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (widget.raceId != null)
            Chip(
              avatar: const Icon(Icons.emoji_events, size: 18),
              label: Text(
                'Filtrando dicas para a corrida (ID: ${widget.raceId})',
              ),
              backgroundColor: Colors.orange.shade50,
            ),
          if (widget.cityId != null)
            Chip(
              avatar: const Icon(Icons.location_on, size: 18),
              label: Text(
                'Filtrando dicas para a cidade (ID: ${widget.cityId})',
              ),
              backgroundColor: Colors.blue.shade50,
            ),
        ],
      ),
    );
  }

  Widget _buildTipCard(TipModel tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(_getTipTypeLabel(tip.type)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tip.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            if (tip.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: tip.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    labelStyle: const TextStyle(fontSize: 12),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _getCategoryLabel(tip.category),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${tip.stats.likes}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.visibility, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${tip.stats.views}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.workspace_premium,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${(tip.stats.helpfulness * 100).toStringAsFixed(0)}% útil',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(
                    tip.userId.isNotEmpty ? tip.userId[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Autor: ${tip.userId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  _formatDate(tip.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 30) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    if (difference.inDays >= 1) {
      return 'Há ${difference.inDays} dia${difference.inDays == 1 ? '' : 's'}';
    }
    if (difference.inHours >= 1) {
      return 'Há ${difference.inHours} hora${difference.inHours == 1 ? '' : 's'}';
    }
    if (difference.inMinutes >= 1) {
      return 'Há ${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'}';
    }
    return 'Agora mesmo';
  }
}

