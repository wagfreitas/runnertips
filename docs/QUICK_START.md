# 🚀 Quick Start - Por Onde Começar

## 📋 Visão Geral

Este guia apresenta um caminho prático e incremental para começar o desenvolvimento, começando pelas tarefas mais simples e evoluindo gradualmente.

---

## 🎯 Estratégia de Desenvolvimento Incremental

### Fase 0: Preparação (Hoje - 1 dia)
**Objetivo:** Preparar ambiente e criar base de código

### Fase 1: Modelos e Estrutura Base (Semana 1)
**Objetivo:** Criar modelos Dart e serviços básicos (sem depender de infraestrutura externa)

### Fase 2: Infraestrutura (Semana 2)
**Objetivo:** Configurar Supabase, n8n e OpenAI

### Fase 3: Integração (Semana 3-4)
**Objetivo:** Conectar tudo e fazer funcionar end-to-end

---

## 🔥 FASE 0: Preparação (Hoje)

### 1. Adicionar Dependências Necessárias

Adicione ao `pubspec.yaml`:

```yaml
dependencies:
  # ... dependências existentes ...
  
  # Para Supabase
  supabase_flutter: ^2.0.0
  
  # Para gerenciamento de estado (se ainda não tiver)
  provider: ^6.1.1  # ou riverpod se preferir
  
  # Para validação
  validator: ^3.0.0
  
  # Para mapas (depois)
  google_maps_flutter: ^2.5.0
  # ou
  # mapbox_maps_flutter: ^1.0.0
```

Execute:
```bash
flutter pub get
```

### 2. Criar Estrutura de Pastas

```bash
mkdir -p lib/core/models
mkdir -p lib/core/services
mkdir -p lib/core/utils
mkdir -p lib/features/tips
mkdir -p lib/features/reviews
mkdir -p lib/features/search
```

---

## 🏗️ FASE 1: Modelos e Estrutura Base (Semana 1)

**Por que começar aqui?**
- Não depende de infraestrutura externa
- Pode testar localmente
- Cria base sólida para o resto

### Passo 1: Criar Modelos Dart Básicos

#### 1.1 Tip Model

```dart
// lib/core/models/tip_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TipType {
  hotel,
  restaurant,
  transport,
  tourism,
  raceTip,
  general
}

enum TipCategory {
  accommodation,
  food,
  transportation,
  tourism,
  climate,
  elevation,
  organization,
  logistics,
  nutrition,
  general
}

class TipModel extends Equatable {
  final String id;
  final String userId;
  final String? raceId;
  final String? cityId;
  final TipType type;
  final TipCategory category;
  final String title;
  final String content;
  final List<String> images;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isVerified;
  final TipStats stats;

  const TipModel({
    required this.id,
    required this.userId,
    this.raceId,
    this.cityId,
    required this.type,
    required this.category,
    required this.title,
    required this.content,
    this.images = const [],
    this.tags = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isVerified = false,
    required this.stats,
  });

  factory TipModel.fromMap(Map<String, dynamic> map) {
    return TipModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      raceId: map['raceId'],
      cityId: map['cityId'],
      type: TipType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TipType.general,
      ),
      category: TipCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TipCategory.general,
      ),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      metadata: map['metadata'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      isVerified: map['isVerified'] ?? false,
      stats: TipStats.fromMap(map['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'raceId': raceId,
      'cityId': cityId,
      'type': type.name,
      'category': category.name,
      'title': title,
      'content': content,
      'images': images,
      'tags': tags,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'isVerified': isVerified,
      'stats': stats.toMap(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        raceId,
        cityId,
        type,
        category,
        title,
        content,
        images,
        tags,
        metadata,
        createdAt,
        updatedAt,
        isActive,
        isVerified,
        stats,
      ];
}

class TipStats extends Equatable {
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final double helpfulness;
  final int views;

  const TipStats({
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.helpfulness = 0.0,
    this.views = 0,
  });

  factory TipStats.fromMap(Map<String, dynamic> map) {
    return TipStats(
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      shares: map['shares'] ?? 0,
      saves: map['saves'] ?? 0,
      helpfulness: (map['helpfulness'] ?? 0.0).toDouble(),
      views: map['views'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'saves': saves,
      'helpfulness': helpfulness,
      'views': views,
    };
  }

  @override
  List<Object?> get props => [likes, comments, shares, saves, helpfulness, views];
}
```

#### 1.2 Review Model

```dart
// lib/core/models/review_model.dart
// (Similar ao TipModel, seguindo o mesmo padrão)
```

#### 1.3 City Model

```dart
// lib/core/models/city_model.dart
// (Modelo simples para cidades)
```

### Passo 2: Criar Validador de Conteúdo

```dart
// lib/core/utils/content_validator.dart
class ContentValidator {
  static final List<String> sportKeywords = [
    'maratona', 'marathon', 'corrida', 'race', 'triatlo', 'triathlon',
    'ironman', 'duatlo', 'duathlon', 'meia maratona', 'half marathon',
    'ultramaratona', 'ultra', 'trail', 'caminhada', 'walk', 'run',
    'corredor', 'runner', 'atleta', 'athlete', 'largada', 'start',
    'chegada', 'finish', 'prova', 'competition', 'evento', 'event',
  ];

  static bool isSportsRelated(String content) {
    final lowerContent = content.toLowerCase();
    return sportKeywords.any((keyword) => lowerContent.contains(keyword));
  }

  static ValidationResult validateTip(TipModel tip) {
    // Validar título
    if (!isSportsRelated(tip.title)) {
      return ValidationResult(
        valid: false,
        reason: 'O título deve estar relacionado a eventos esportivos',
      );
    }

    // Validar conteúdo
    if (!isSportsRelated(tip.content)) {
      return ValidationResult(
        valid: false,
        reason: 'O conteúdo deve estar relacionado a eventos esportivos',
      );
    }

    // Validar se está vinculado a uma corrida ou cidade
    if (tip.raceId == null && tip.cityId == null) {
      return ValidationResult(
        valid: false,
        reason: 'A dica deve estar vinculada a uma corrida ou cidade',
      );
    }

    return ValidationResult(valid: true);
  }
}

class ValidationResult {
  final bool valid;
  final String? reason;

  ValidationResult({required this.valid, this.reason});
}
```

### Passo 3: Criar Serviço Básico (Firestore por enquanto)

```dart
// lib/core/services/tip_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tip_model.dart';
import '../utils/content_validator.dart';

class TipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tips';

  Future<String?> createTip(TipModel tip) async {
    try {
      // Validar conteúdo
      final validation = ContentValidator.validateTip(tip);
      if (!validation.valid) {
        throw Exception(validation.reason);
      }

      // Adicionar timestamps
      final tipData = tip.toMap();
      tipData['createdAt'] = FieldValue.serverTimestamp();
      tipData['updatedAt'] = FieldValue.serverTimestamp();

      // Salvar no Firestore
      final docRef = await _firestore.collection(_collection).add(tipData);
      return docRef.id;
    } catch (e) {
      print('Erro ao criar dica: $e');
      return null;
    }
  }

  Future<List<TipModel>> getTips({
    String? raceId,
    String? cityId,
    TipType? type,
    TipCategory? category,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (raceId != null) {
        query = query.where('raceId', isEqualTo: raceId);
      }
      if (cityId != null) {
        query = query.where('cityId', isEqualTo: cityId);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      query = query.where('isActive', isEqualTo: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TipModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('Erro ao buscar dicas: $e');
      return [];
    }
  }

  Future<TipModel?> getTipById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return TipModel.fromMap({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      print('Erro ao buscar dica: $e');
      return null;
    }
  }
}
```

### Passo 4: Criar Tela Básica de Dicas

```dart
// lib/features/tips/presentation/pages/tips_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/services/tip_service.dart';
import '../../../../core/models/tip_model.dart';

class TipsScreen extends StatefulWidget {
  final String? raceId;
  final String? cityId;

  const TipsScreen({super.key, this.raceId, this.cityId});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final TipService _tipService = TipService();
  List<TipModel> _tips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    setState(() => _isLoading = true);
    final tips = await _tipService.getTips(
      raceId: widget.raceId,
      cityId: widget.cityId,
    );
    setState(() {
      _tips = tips;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dicas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tips.isEmpty
              ? const Center(child: Text('Nenhuma dica encontrada'))
              : ListView.builder(
                  itemCount: _tips.length,
                  itemBuilder: (context, index) {
                    final tip = _tips[index];
                    return ListTile(
                      title: Text(tip.title),
                      subtitle: Text(tip.content),
                      trailing: Text(tip.type.name),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para tela de criar dica
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 🏗️ FASE 2: Infraestrutura (Semana 2)

### Passo 1: Configurar Supabase

1. Criar conta em [supabase.com](https://supabase.com)
2. Criar novo projeto
3. Instalar extensão pgvector:

```sql
-- No SQL Editor do Supabase
CREATE EXTENSION IF NOT EXISTS vector;
```

4. Criar schema básico (ver `docs/ARCHITECTURE_COMPLETE.md`)

### Passo 2: Configurar n8n

1. Acessar n8n (já tem configurado)
2. Criar workflow básico de busca NLP
3. Configurar webhook

### Passo 3: Configurar OpenAI

1. Criar conta em [platform.openai.com](https://platform.openai.com)
2. Obter API key
3. Configurar no n8n

---

## 🔗 FASE 3: Integração (Semanas 3-4)

### Passo 1: Integrar Supabase no Flutter

```dart
// lib/core/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
```

### Passo 2: Criar Serviço de Busca Vetorial

```dart
// lib/core/services/vector_search_service.dart
// Implementar busca vetorial usando Supabase
```

### Passo 3: Integrar n8n para Busca NLP

```dart
// lib/core/services/nlp_search_service.dart
// Implementar chamada ao n8n para busca NLP
```

---

## 📋 Checklist de Progresso

### Fase 0: Preparação
- [ ] Adicionar dependências ao pubspec.yaml
- [ ] Criar estrutura de pastas
- [ ] Configurar ambiente

### Fase 1: Modelos e Estrutura
- [ ] Criar TipModel
- [ ] Criar ReviewModel
- [ ] Criar CityModel
- [ ] Criar ContentValidator
- [ ] Criar TipService (Firestore)
- [ ] Criar tela básica de dicas
- [ ] Testar criação e listagem de dicas

### Fase 2: Infraestrutura
- [ ] Configurar Supabase
- [ ] Instalar pgvector
- [ ] Criar schema do banco
- [ ] Configurar n8n workflows
- [ ] Configurar OpenAI
- [ ] Testar integrações

### Fase 3: Integração
- [ ] Integrar Supabase no Flutter
- [ ] Criar serviço de busca vetorial
- [ ] Integrar n8n para busca NLP
- [ ] Testar busca end-to-end
- [ ] Implementar moderação básica

---

## 🎯 Próximo Passo Imediato

**Comece AGORA:**

1. **Adicione as dependências** ao `pubspec.yaml`
2. **Crie o TipModel** (`lib/core/models/tip_model.dart`)
3. **Crie o ContentValidator** (`lib/core/utils/content_validator.dart`)
4. **Crie o TipService** (`lib/core/services/tip_service.dart`)
5. **Teste criando uma dica** no Firestore

Isso te dará uma base sólida e você poderá ver progresso imediato!

---

## 💡 Dicas

### Comece Simples
- Não tente fazer tudo de uma vez
- Comece com Firestore (já está configurado)
- Migre para Supabase depois

### Teste Incrementalmente
- Crie um modelo → teste
- Crie um serviço → teste
- Crie uma tela → teste

### Use o que já existe
- Aproveite o sistema de autenticação existente
- Use a estrutura de pastas atual
- Reutilize widgets existentes

---

## 🆘 Se tiver Dúvidas

1. Consulte `docs/ARCHITECTURE_COMPLETE.md` para detalhes técnicos
2. Consulte `docs/VECTOR_SEARCH_IMPLEMENTATION.md` para busca vetorial
3. Consulte `docs/IMPLEMENTATION_ROADMAP.md` para roadmap completo

---

*Documento criado em: Janeiro 2024*
*Versão: 1.0*

