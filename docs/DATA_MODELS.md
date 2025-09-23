# Runner Tips - Modelos de Dados

## 🗃 Schema do Banco de Dados

### Tabelas Principais

#### 1. Users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    profile_image_url TEXT,
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    location JSONB, -- {city, state, country, coordinates}
    specializations TEXT[], -- ['marathon', 'trail', 'city', 'ultra']
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    preferences JSONB, -- notification settings, privacy, etc.
    stats JSONB -- total_tips, helpful_tips, reputation_points, etc.
);
```

#### 2. Races
```sql
CREATE TABLE races (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    location JSONB NOT NULL, -- {city, state, country, coordinates, address}
    distance DECIMAL(5,2) NOT NULL, -- in kilometers
    difficulty VARCHAR(20), -- 'easy', 'moderate', 'hard', 'extreme'
    elevation DECIMAL(8,2), -- total elevation gain in meters
    image_urls TEXT[],
    organizer VARCHAR(255),
    price DECIMAL(10,2),
    registration_url TEXT,
    categories TEXT[], -- ['marathon', 'half', '10k', '5k', 'trail']
    amenities TEXT[], -- ['medal', 't_shirt', 'timing', 'photos', 'food']
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);
```

#### 3. Cities
```sql
CREATE TABLE cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    country VARCHAR(100) NOT NULL,
    coordinates JSONB NOT NULL, -- {latitude, longitude}
    timezone VARCHAR(50),
    currency VARCHAR(10),
    language VARCHAR(10),
    image_urls TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);
```

#### 4. Tips
```sql
CREATE TABLE tips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    race_id UUID REFERENCES races(id) ON DELETE SET NULL,
    city_id UUID REFERENCES cities(id) ON DELETE SET NULL,
    type VARCHAR(20) NOT NULL, -- 'race', 'travel', 'general'
    category VARCHAR(30) NOT NULL, -- 'climate', 'elevation', 'accommodation', etc.
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    images TEXT[],
    tags TEXT[],
    metadata JSONB, -- additional structured data
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false
);
```

#### 5. Reviews
```sql
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    race_id UUID REFERENCES races(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    ratings JSONB NOT NULL, -- {overall: 5, organization: 4, course: 5, etc.}
    images TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false
);
```

#### 6. Comments
```sql
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    tip_id UUID REFERENCES tips(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    parent_id UUID REFERENCES comments(id) -- for replies
);
```

#### 7. Interactions
```sql
CREATE TABLE interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    target_type VARCHAR(20) NOT NULL, -- 'tip', 'review', 'comment'
    target_id UUID NOT NULL,
    interaction_type VARCHAR(20) NOT NULL, -- 'like', 'helpful', 'save', 'share'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, target_type, target_id, interaction_type)
);
```

#### 8. User Reputation
```sql
CREATE TABLE user_reputation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(30) NOT NULL, -- 'marathon', 'trail', 'travel', etc.
    points INTEGER DEFAULT 0,
    level VARCHAR(20) DEFAULT 'beginner', -- 'beginner', 'intermediate', 'expert', 'guru'
    badges TEXT[],
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, category)
);
```

### Índices para Performance
```sql
-- Índices principais
CREATE INDEX idx_tips_race_id ON tips(race_id);
CREATE INDEX idx_tips_city_id ON tips(city_id);
CREATE INDEX idx_tips_user_id ON tips(user_id);
CREATE INDEX idx_tips_category ON tips(category);
CREATE INDEX idx_tips_created_at ON tips(created_at DESC);
CREATE INDEX idx_tips_type ON tips(type);

CREATE INDEX idx_reviews_race_id ON reviews(race_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_created_at ON reviews(created_at DESC);

CREATE INDEX idx_comments_tip_id ON comments(tip_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);

CREATE INDEX idx_interactions_target ON interactions(target_type, target_id);
CREATE INDEX idx_interactions_user ON interactions(user_id);

-- Índices para busca
CREATE INDEX idx_tips_search ON tips USING GIN(to_tsvector('english', title || ' ' || content));
CREATE INDEX idx_races_search ON races USING GIN(to_tsvector('english', name || ' ' || description));
```

## 🏗 Modelos Dart

### 1. User Model
```dart
class User {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime lastActive;
  final UserLocation? location;
  final List<String> specializations;
  final bool isVerified;
  final bool isActive;
  final UserPreferences preferences;
  final UserStats stats;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    required this.lastActive,
    this.location,
    this.specializations = const [],
    this.isVerified = false,
    this.isActive = true,
    required this.preferences,
    required this.stats,
  });
}

class UserLocation {
  final String city;
  final String? state;
  final String country;
  final double? latitude;
  final double? longitude;

  const UserLocation({
    required this.city,
    this.state,
    required this.country,
    this.latitude,
    this.longitude,
  });
}

class UserPreferences {
  final bool notificationsEnabled;
  final bool locationSharingEnabled;
  final String preferredUnits; // 'metric' or 'imperial'
  final List<String> interests;
  final Map<String, bool> privacySettings;

  const UserPreferences({
    this.notificationsEnabled = true,
    this.locationSharingEnabled = false,
    this.preferredUnits = 'metric',
    this.interests = const [],
    this.privacySettings = const {},
  });
}

class UserStats {
  final int totalTips;
  final int helpfulTips;
  final int racesParticipated;
  final int countriesVisited;
  final double averageRating;
  final int reputationPoints;
  final String level;

  const UserStats({
    this.totalTips = 0,
    this.helpfulTips = 0,
    this.racesParticipated = 0,
    this.countriesVisited = 0,
    this.averageRating = 0.0,
    this.reputationPoints = 0,
    this.level = 'beginner',
  });
}
```

### 2. Race Model
```dart
class Race {
  final String id;
  final String name;
  final String? description;
  final DateTime date;
  final RaceLocation location;
  final double distance;
  final String? difficulty;
  final double? elevation;
  final List<String> imageUrls;
  final String? organizer;
  final double? price;
  final String? registrationUrl;
  final List<String> categories;
  final List<String> amenities;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final RaceStats stats;

  const Race({
    required this.id,
    required this.name,
    this.description,
    required this.date,
    required this.location,
    required this.distance,
    this.difficulty,
    this.elevation,
    this.imageUrls = const [],
    this.organizer,
    this.price,
    this.registrationUrl,
    this.categories = const [],
    this.amenities = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    required this.stats,
  });
}

class RaceLocation {
  final String city;
  final String? state;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? address;

  const RaceLocation({
    required this.city,
    this.state,
    required this.country,
    this.latitude,
    this.longitude,
    this.address,
  });
}

class RaceStats {
  final double averageRating;
  final int totalReviews;
  final int totalTips;
  final Map<String, double> categoryRatings;
  final int totalParticipants;

  const RaceStats({
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.totalTips = 0,
    this.categoryRatings = const {},
    this.totalParticipants = 0,
  });
}
```

### 3. Tip Model
```dart
class Tip {
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

  const Tip({
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
}

enum TipType {
  race,    // Dica sobre corrida específica
  travel,  // Dica de viagem
  general  // Dica geral de corrida
}

enum TipCategory {
  // Race categories
  climate,        // Clima e condições
  elevation,      // Altimetria e dificuldade
  organization,   // Organização da prova
  logistics,      // Estrutura e logística
  nutrition,      // Hidratação e alimentação
  timing,         // Cronometragem
  awards,         // Premiação
  
  // Travel categories
  accommodation,  // Hospedagem
  transportation, // Transporte
  food,          // Alimentação
  tourism,       // Turismo
  shopping,      // Compras
  general        // Geral
}

class TipStats {
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final double helpfulness; // 0.0 - 1.0
  final int views;

  const TipStats({
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.helpfulness = 0.0,
    this.views = 0,
  });
}
```

### 4. Review Model
```dart
class Review {
  final String id;
  final String userId;
  final String raceId;
  final String content;
  final Map<TipCategory, double> ratings;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isVerified;
  final ReviewStats stats;

  const Review({
    required this.id,
    required this.userId,
    required this.raceId,
    required this.content,
    required this.ratings,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isVerified = false,
    required this.stats,
  });
}

class ReviewStats {
  final int helpfulVotes;
  final int totalVotes;
  final int likes;
  final int comments;

  const ReviewStats({
    this.helpfulVotes = 0,
    this.totalVotes = 0,
    this.likes = 0,
    this.comments = 0,
  });
}
```

### 5. Comment Model
```dart
class Comment {
  final String id;
  final String userId;
  final String tipId;
  final String content;
  final DateTime createdAt;
  final bool isActive;
  final String? parentId; // for replies
  final CommentStats stats;

  const Comment({
    required this.id,
    required this.userId,
    required this.tipId,
    required this.content,
    required this.createdAt,
    this.isActive = true,
    this.parentId,
    required this.stats,
  });
}

class CommentStats {
  final int likes;
  final int replies;

  const CommentStats({
    this.likes = 0,
    this.replies = 0,
  });
}
```

### 6. Interaction Model
```dart
class Interaction {
  final String id;
  final String userId;
  final String targetType;
  final String targetId;
  final InteractionType type;
  final DateTime createdAt;

  const Interaction({
    required this.id,
    required this.userId,
    required this.targetType,
    required this.targetId,
    required this.type,
    required this.createdAt,
  });
}

enum InteractionType {
  like,
  helpful,
  save,
  share,
  report
}
```

## 🔄 Relacionamentos

### Relacionamentos Principais
- **User** → **Tips** (1:N) - Um usuário pode criar várias dicas
- **User** → **Reviews** (1:N) - Um usuário pode escrever várias reviews
- **User** → **Comments** (1:N) - Um usuário pode fazer vários comentários
- **Race** → **Tips** (1:N) - Uma corrida pode ter várias dicas
- **Race** → **Reviews** (1:N) - Uma corrida pode ter várias reviews
- **City** → **Tips** (1:N) - Uma cidade pode ter várias dicas de viagem
- **Tip** → **Comments** (1:N) - Uma dica pode ter vários comentários

### Relacionamentos de Interação
- **User** → **Interactions** (1:N) - Um usuário pode ter várias interações
- **Tip/Review/Comment** → **Interactions** (1:N) - Conteúdo pode ter várias interações

## 📊 Agregações e Views

### View: User Reputation Summary
```sql
CREATE VIEW user_reputation_summary AS
SELECT 
    u.id,
    u.display_name,
    u.profile_image_url,
    COALESCE(SUM(ur.points), 0) as total_points,
    COUNT(DISTINCT t.id) as total_tips,
    COUNT(DISTINCT r.id) as total_reviews,
    COALESCE(AVG(t.stats->>'helpfulness'), 0) as avg_helpfulness
FROM users u
LEFT JOIN user_reputation ur ON u.id = ur.user_id
LEFT JOIN tips t ON u.id = t.user_id AND t.is_active = true
LEFT JOIN reviews r ON u.id = r.user_id AND r.is_active = true
GROUP BY u.id, u.display_name, u.profile_image_url;
```

### View: Race Statistics
```sql
CREATE VIEW race_statistics AS
SELECT 
    r.id,
    r.name,
    r.date,
    r.location->>'city' as city,
    r.location->>'country' as country,
    COUNT(DISTINCT t.id) as total_tips,
    COUNT(DISTINCT rev.id) as total_reviews,
    COALESCE(AVG((rev.ratings->>'overall')::float), 0) as avg_rating,
    COUNT(DISTINCT CASE WHEN t.category = 'climate' THEN t.id END) as climate_tips,
    COUNT(DISTINCT CASE WHEN t.category = 'elevation' THEN t.id END) as elevation_tips,
    COUNT(DISTINCT CASE WHEN t.category = 'organization' THEN t.id END) as organization_tips
FROM races r
LEFT JOIN tips t ON r.id = t.race_id AND t.is_active = true
LEFT JOIN reviews rev ON r.id = rev.race_id AND rev.is_active = true
GROUP BY r.id, r.name, r.date, r.location;
```

---

**Próximos Passos:**
1. Implementar modelos Dart no Flutter
2. Configurar repositórios e data sources
3. Criar serviços de API
4. Implementar cache local
