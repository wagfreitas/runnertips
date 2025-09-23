# Runner Tips - Arquitetura do Sistema

## 🎯 Visão Geral

**Runner Tips** é uma comunidade focada em compartilhar dicas práicas sobre corridas e viagens relacionadas. O foco principal é conectar corredores que compartilham experiências detalhadas sobre provas e cidades.

## 🏗 Arquitetura do Sistema

### Frontend (Flutter)
```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
├─────────────────────────────────────────────────────────────┤
│  Screens                    │  Widgets                     │
│  ├── Auth                   │  ├── Cards                   │
│  ├── Community              │  ├── Forms                   │
│  ├── Race Tips              │  ├── Lists                   │
│  ├── Travel Tips            │  └── Navigation              │
│  ├── Profile                │                             │
│  └── Search                 │                             │
├─────────────────────────────────────────────────────────────┤
│                 Business Logic Layer                        │
├─────────────────────────────────────────────────────────────┤
│  Services                   │  Models                      │
│  ├── Auth Service           │  ├── User                    │
│  ├── Tips Service           │  ├── Race                    │
│  ├── Community Service      │  ├── Tip                     │
│  ├── Search Service         │  ├── Review                  │
│  └── Storage Service        │  └── Location                │
├─────────────────────────────────────────────────────────────┤
│                   Data Layer                                │
├─────────────────────────────────────────────────────────────┤
│  Repositories               │  Data Sources                │
│  ├── Auth Repository        │  ├── Firebase Auth           │
│  ├── Tips Repository        │  ├── Firestore               │
│  ├── Community Repository   │  ├── PostgreSQL              │
│  └── Search Repository      │  └── Local Storage           │
└─────────────────────────────────────────────────────────────┘
```

### Backend (Firebase + PostgreSQL)
```
┌─────────────────────────────────────────────────────────────┐
│                    Firebase Services                        │
├─────────────────────────────────────────────────────────────┤
│  Authentication    │  Firestore (Real-time)                │
│  Storage           │  Cloud Functions                      │
│  Analytics         │  Push Notifications                   │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    PostgreSQL Database                      │
├─────────────────────────────────────────────────────────────┤
│  Users             │  Race Tips                            │
│  Races             │  Travel Tips                          │
│  Reviews           │  Comments                             │
│  Locations         │  User Interactions                    │
└─────────────────────────────────────────────────────────────┘
```

## 📱 Features Principais

### 1. 🏃‍♂️ Race Tips Hub
**Descrição:** Centro de dicas específicas sobre corridas

**Funcionalidades:**
- **Dicas por Categoria:**
  - Clima e condições
  - Altimetria e dificuldade
  - Organização da prova
  - Estrutura e logística
  - Premiação e cronometragem
  - Hidratação e alimentação

- **Sistema de Reviews:**
  - Rating por categoria
  - Fotos e vídeos
  - Dicas práticas
  - Experiências pessoais

### 2. 🌍 Travel Tips Hub
**Descrição:** Dicas de viagem para cidades das corridas

**Funcionalidades:**
- **Hospedagem:**
  - Hotéis próximos ao evento
  - Airbnbs recomendados
  - Dicas de localização

- **Alimentação:**
  - Restaurantes para carb loading
  - Cafés da manhã pré-prova
  - Opções vegetarianas/veganas

- **Turismo:**
  - O que visitar na cidade
  - Tours recomendados
  - Atrações próximas

- **Logística:**
  - Transporte do aeroporto
  - Aluguel de carro
  - Passagens aéreas
  - Deslocamento na cidade

### 3. 👥 Community Features
**Descrição:** Sistema de comunidade e reputação

**Funcionalidades:**
- **Sistema de Reputação:**
  - Pontos por dicas úteis
  - Badges por especialidade
  - Ranking da comunidade

- **Sistema Social:**
  - Seguir usuários experientes
  - Feed personalizado
  - Comentários e discussões

- **Busca Inteligente:**
  - Filtros por localização
  - Filtros por tipo de dica
  - Busca por palavras-chave

### 4. 🔍 Search & Discovery
**Descrição:** Sistema avançado de busca e descoberta

**Funcionalidades:**
- **Busca por Corrida:**
  - Nome da prova
  - Cidade/país
  - Data
  - Distância

- **Busca por Dicas:**
  - Categoria específica
  - Palavras-chave
  - Usuário específico
  - Rating mínimo

## 🗃 Modelo de Dados

### Principais Entidades

#### User
```dart
class User {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final UserStats stats;
  final UserReputation reputation;
  final List<String> specializations; // ['marathon', 'trail', 'city']
  final UserLocation? location;
  final bool isVerified;
}

class UserStats {
  final int totalTips;
  final int helpfulTips;
  final int racesParticipated;
  final int countriesVisited;
  final double averageRating;
}

class UserReputation {
  final int points;
  final String level; // 'beginner', 'intermediate', 'expert', 'guru'
  final List<String> badges;
  final Map<String, int> categoryPoints;
}
```

#### Race
```dart
class Race {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final RaceLocation location;
  final double distance;
  final String difficulty;
  final double? elevation;
  final List<String> imageUrls;
  final RaceDetails details;
  final List<RaceTip> tips;
  final RaceStats stats;
}

class RaceDetails {
  final String organizer;
  final double price;
  final String registrationUrl;
  final List<String> categories; // ['marathon', 'half', '10k']
  final Map<String, dynamic> logistics;
  final List<String> amenities;
}

class RaceStats {
  final double averageRating;
  final int totalReviews;
  final int totalTips;
  final Map<String, double> categoryRatings;
}
```

#### Tip
```dart
class Tip {
  final String id;
  final String userId;
  final String raceId?;
  final String cityId?;
  final TipType type;
  final String title;
  final String content;
  final List<String> images;
  final List<String> tags;
  final TipCategory category;
  final DateTime createdAt;
  final TipStats stats;
  final Map<String, dynamic> metadata;
}

enum TipType {
  race,      // Dica sobre corrida específica
  travel,    // Dica de viagem
  general    // Dica geral de corrida
}

enum TipCategory {
  climate,
  elevation,
  organization,
  logistics,
  nutrition,
  accommodation,
  transportation,
  tourism,
  general
}

class TipStats {
  final int likes;
  final int comments;
  final int shares;
  final double helpfulness; // 0.0 - 1.0
  final bool isVerified;
}
```

#### Review
```dart
class Review {
  final String id;
  final String userId;
  final String raceId;
  final String content;
  final Map<TipCategory, double> ratings; // Rating por categoria
  final List<String> images;
  final DateTime createdAt;
  final ReviewStats stats;
}

class ReviewStats {
  final int helpfulVotes;
  final int totalVotes;
  final bool isVerified;
}
```

## 🛠 Stack Tecnológico

### Frontend
- **Framework:** Flutter 3.16+
- **State Management:** Riverpod
- **Routing:** GoRouter
- **HTTP Client:** Dio
- **Local Storage:** Hive
- **Maps:** Google Maps Flutter
- **Image Handling:** Cached Network Image

### Backend
- **Authentication:** Firebase Auth
- **Database:** PostgreSQL (primary) + Firestore (real-time)
- **Storage:** Firebase Storage
- **Push Notifications:** Firebase Cloud Messaging
- **Analytics:** Firebase Analytics
- **API:** Node.js/Express (REST)

### Integrações
- **Maps:** Google Maps API
- **Weather:** OpenWeather API
- **Translation:** Google Translate API
- **Image Processing:** Cloudinary

## 📁 Estrutura de Pastas Flutter

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_endpoints.dart
│   │   └── app_colors.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── helpers.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   └── errors/
│       ├── exceptions.dart
│       └── failures.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── data_sources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── use_cases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   ├── community/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── race_tips/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── travel_tips/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── search/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── inputs/
│   │   ├── cards/
│   │   └── loaders/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── race_model.dart
│   │   ├── tip_model.dart
│   │   └── review_model.dart
│   └── providers/
│       ├── auth_provider.dart
│       ├── theme_provider.dart
│       └── connectivity_provider.dart
└── main.dart
```

## 🎨 Design System

### Paleta de Cores
```css
/* Primary Colors - Running Theme */
--primary-orange: #FF6B35;      /* Energia e movimento */
--primary-dark: #D84315;        /* Profundidade */
--primary-light: #FFAB91;       /* Suavidade */

/* Secondary Colors */
--secondary-blue: #1976D2;      /* Confiança */
--secondary-green: #388E3C;     /* Sucesso e natureza */

/* Neutral Colors */
--gray-50: #FAFAFA;
--gray-100: #F5F5F5;
--gray-200: #EEEEEE;
--gray-300: #E0E0E0;
--gray-400: #BDBDBD;
--gray-500: #9E9E9E;
--gray-600: #757575;
--gray-700: #616161;
--gray-800: #424242;
--gray-900: #212121;

/* Status Colors */
--success: #4CAF50;
--warning: #FF9800;
--error: #F44336;
--info: #2196F3;
```

### Componentes Base
- **Cards:** Tip Card, Race Card, User Card
- **Buttons:** Primary, Secondary, Icon, Floating Action
- **Inputs:** Text Field, Search Bar, Filter Dropdown
- **Navigation:** Bottom Tab Bar, App Bar, Drawer
- **Feedback:** Toast, Snackbar, Loading States

## 🔄 Fluxos Principais

### 1. Fluxo de Criação de Dica
```
Usuário → Seleciona Tipo (Race/Travel) → 
Escolhe Corrida/Cidade → 
Preenche Categoria → 
Adiciona Conteúdo + Imagens → 
Publica → 
Comunidade Avalia
```

### 2. Fluxo de Busca
```
Usuário → Digite Termo → 
Aplica Filtros → 
Visualiza Resultados → 
Acessa Dica Detalhada → 
Avalia Utilidade
```

### 3. Fluxo de Descoberta
```
Usuário → Abre App → 
Feed Personalizado → 
Explora Categorias → 
Encontra Dicas Relevantes → 
Salva Favoritos
```

## 📊 Métricas de Sucesso

### Engajamento
- Dicas criadas por usuário/mês
- Taxa de dicas úteis (likes/views)
- Tempo médio de sessão
- Retenção de usuários

### Qualidade
- Rating médio das dicas
- Taxa de verificação de dicas
- NPS da comunidade
- Tempo de resposta a dúvidas

### Crescimento
- Novos usuários/mês
- Dicas por corrida/cidade
- Cobertura geográfica
- Parcerias com eventos

---

**Próximos Passos:**
1. Configurar estrutura base do Flutter
2. Implementar autenticação
3. Criar modelos de dados
4. Desenvolver telas principais
5. Implementar funcionalidades de comunidade
