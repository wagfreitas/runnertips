import 'package:flutter/material.dart';
import '../../../../core/services/tip_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/race_service.dart';
import '../../../../core/models/tip_model.dart';
import '../../../../core/models/race_model.dart';
import '../../../../core/constants/app_colors.dart';

class CreateTipScreen extends StatefulWidget {
  final String? raceId;
  final String? cityId;

  const CreateTipScreen({
    super.key,
    this.raceId,
    this.cityId,
  });

  @override
  State<CreateTipScreen> createState() => _CreateTipScreenState();
}

class _CreateTipScreenState extends State<CreateTipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  final TipService _tipService = TipService();
  final AuthService _authService = AuthService();
  final RaceService _raceService = RaceService();
  
  TipType? _selectedType;
  TipCategory? _selectedCategory;
  String? _selectedRaceId;
  List<RaceModel> _races = [];
  bool _isLoadingRaces = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedRaceId = widget.raceId;
    _loadRaces();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadRaces() async {
    setState(() => _isLoadingRaces = true);
    try {
      final races = await _raceService.getAllRaces();
      
      // Remover duplicatas (caso existam)
      final uniqueRaces = <String, RaceModel>{};
      for (final race in races) {
        uniqueRaces[race.id] = race;
      }
      final cleanRaces = uniqueRaces.values.toList();
      
      setState(() {
        _races = cleanRaces;
        
        // Verificar se o raceId inicial existe na lista
        // Se não existir, definir como null para evitar erro no dropdown
        if (_selectedRaceId != null) {
          final raceExists = cleanRaces.any((race) => race.id == _selectedRaceId);
          if (!raceExists) {
            _selectedRaceId = null;
          }
        }
        
        _isLoadingRaces = false;
      });
    } catch (e) {
      setState(() {
        _races = [];
        _selectedRaceId = null; // Garantir que não há valor inválido
        _isLoadingRaces = false;
      });
    }
  }

  void _updateCategoryBasedOnType() {
    if (_selectedType == null) {
      _selectedCategory = null;
      return;
    }

    // Definir categoria padrão baseada no tipo
    switch (_selectedType!) {
      case TipType.hotel:
        _selectedCategory = TipCategory.accommodation;
        break;
      case TipType.restaurant:
        _selectedCategory = TipCategory.food;
        break;
      case TipType.transport:
        _selectedCategory = TipCategory.transportation;
        break;
      case TipType.tourism:
        _selectedCategory = TipCategory.tourism;
        break;
      case TipType.raceTip:
        _selectedCategory = TipCategory.general;
        break;
      case TipType.general:
        _selectedCategory = TipCategory.general;
        break;
    }
    setState(() {});
  }

  Future<void> _saveTip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o tipo de dica'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a categoria da dica'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obter usuário atual
    final user = await _authService.getCurrentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para criar uma dica'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      // Processar tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Criar dica
      final tip = TipModel(
        id: '', // Será gerado pelo Firestore
        userId: user.id,
        raceId: _selectedRaceId,
        cityId: widget.cityId,
        type: _selectedType!,
        category: _selectedCategory!,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stats: const TipStats(),
      );

      final tipId = await _tipService.createTip(tip);

      if (tipId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dica criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retorna true para indicar sucesso
      } else {
        setState(() {
          _error = 'Erro ao criar dica. Tente novamente.';
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao criar dica: $e';
        _isSaving = false;
      });
    }
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
        title: const Text('Criar Nova Dica'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveTip,
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Tipo de Dica
            Text(
              'Tipo de Dica *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TipType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(_getTipTypeLabel(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type : null;
                      _updateCategoryBasedOnType();
                    });
                  },
                  selectedColor: AppColors.primaryOrange.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryOrange,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Categoria
            Text(
              'Categoria *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TipCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Selecione a categoria',
              ),
              items: TipCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryLabel(category)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecione uma categoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Corrida Relacionada
            Text(
              'Corrida Relacionada (Opcional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (_isLoadingRaces)
              const CircularProgressIndicator()
            else if (_races.isEmpty)
              const Text(
                'Nenhuma corrida disponível',
                style: TextStyle(color: Colors.grey),
              )
            else
              DropdownButtonFormField<String?>(
                // Garantir que o value só é usado se existir na lista
                value: _races.any((r) => r.id == _selectedRaceId) 
                    ? _selectedRaceId 
                    : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Selecione uma corrida (opcional)',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                isExpanded: true, // Permite que o dropdown use toda a largura
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'Nenhuma corrida específica',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ..._races.map((race) {
                    // Criar texto mais curto para evitar overflow
                    String displayText;
                    final name = race.name.length > 25 
                        ? '${race.name.substring(0, 25)}...' 
                        : race.name;
                    final location = race.location.length > 15 
                        ? '${race.location.substring(0, 15)}...' 
                        : race.location;
                    displayText = '$name - $location';
                    
                    // Garantir que o texto não ultrapasse 50 caracteres
                    if (displayText.length > 50) {
                      displayText = '${displayText.substring(0, 47)}...';
                    }
                    
                    return DropdownMenuItem<String?>(
                      value: race.id,
                      child: Tooltip(
                        message: '${race.name} - ${race.location}',
                        child: Text(
                          displayText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRaceId = value;
                  });
                },
              ),
            const SizedBox(height: 24),

            // Título
            Text(
              'Título *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: Restaurante La Pasta - Excelente para carb loading',
                labelText: 'Título da dica',
              ),
              maxLength: 255,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O título é obrigatório';
                }
                if (value.trim().length < 5) {
                  return 'O título deve ter pelo menos 5 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Conteúdo
            Text(
              'Conteúdo *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Descreva sua dica em detalhes...',
                labelText: 'Conteúdo da dica',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              maxLength: 5000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O conteúdo é obrigatório';
                }
                if (value.trim().length < 20) {
                  return 'O conteúdo deve ter pelo menos 20 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Tags
            Text(
              'Tags (Opcional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: massa, carb loading, próximo à largada',
                labelText: 'Tags (separadas por vírgula)',
                helperText: 'Separe as tags por vírgula',
              ),
            ),
            const SizedBox(height: 24),

            // Informação sobre validação
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sua dica será validada automaticamente para garantir que está relacionada a eventos esportivos.',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

