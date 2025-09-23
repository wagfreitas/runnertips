# Estrutura de Desenvolvimento - Runner Tips

## Visão Geral da Arquitetura

Este projeto segue os princípios da **Clean Architecture**, organizando o código em camadas bem definidas com responsabilidades específicas e dependências unidirecionais.

## 📁 Estrutura de Pastas

```
lib/
├── core/                          # Componentes centrais reutilizáveis
│   ├── models/                    # Modelos de dados globais
│   ├── services/                  # Serviços de negócio
│   ├── constants/                 # Constantes da aplicação
│   ├── theme/                     # Tema e estilos
│   ├── utils/                     # Utilitários e helpers
│   └── errors/                    # Tratamento de erros
├── features/                      # Funcionalidades do app
│   └── [feature_name]/
│       ├── data/                  # Camada de dados
│       │   ├── data_sources/      # Fontes de dados (API, Local)
│       │   ├── models/            # Modelos específicos da feature
│       │   └── repositories/      # Implementação dos repositórios
│       ├── domain/                # Camada de domínio
│       │   ├── entities/          # Entidades de negócio
│       │   ├── repositories/      # Interfaces dos repositórios
│       │   └── use_cases/         # Casos de uso
│       └── presentation/          # Camada de apresentação
│           ├── pages/             # Telas/Views
│           ├── providers/         # Gerenciamento de estado
│           └── widgets/           # Componentes reutilizáveis
└── shared/                        # Componentes compartilhados
    ├── models/                    # Modelos compartilhados
    ├── providers/                 # Providers globais
    └── widgets/                   # Widgets compartilhados
```

## 🏗️ Camadas da Arquitetura

### 1. **Core Layer** (Camada Central)

#### **Models** (`lib/core/models/`)
- **Propósito**: Modelos de dados globais reutilizáveis em toda a aplicação
- **Responsabilidades**:
  - Definir estrutura de dados
  - Serialização/Deserialização
  - Validação básica
  - Comparação de objetos (Equatable)

**Exemplo**: `UserModel`
```dart
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  // ... outros campos
  
  Map<String, dynamic> toMap() { /* serialização */ }
  factory UserModel.fromMap(Map<String, dynamic> map) { /* deserialização */ }
}
```

#### **Services** (`lib/core/services/`)
- **Propósito**: Serviços de negócio que orquestram operações complexas
- **Responsabilidades**:
  - Implementar regras de negócio
  - Coordenar múltiplos repositórios
  - Validar dados de entrada
  - Retornar resultados estruturados

**Exemplo**: `RegisterUserService`
```dart
class RegisterUserService {
  final AuthRepository _authRepository;
  
  Future<RegisterResult> call({
    required String name,
    required String email,
    required String password,
    required String experience,
  }) async {
    // 1. Criar usuário no Firebase Auth
    // 2. Atualizar nome do usuário
    // 3. Criar documento no Firestore
    // 4. Retornar resultado
  }
}
```

### 2. **Features Layer** (Camada de Funcionalidades)

#### **Data Layer** (`lib/features/[feature]/data/`)

##### **Data Sources** (`data_sources/`)
- **Propósito**: Interface direta com fontes de dados externas
- **Responsabilidades**:
  - Chamadas para APIs
  - Operações no banco de dados
  - Tratamento de erros de rede
  - Mapeamento de dados brutos

**Exemplo**: `AuthRemoteDataSource`
```dart
class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Implementação direta com Firebase
  }
}
```

##### **Repositories Implementation** (`repositories/`)
- **Propósito**: Implementação concreta dos contratos de repositório
- **Responsabilidades**:
  - Implementar interfaces do domain
  - Coordenar múltiplas fontes de dados
  - Estratégias de cache e sincronização
  - Transformar dados entre camadas
  - Fallback entre fontes de dados

**Exemplo**: `AuthRepositoryImpl` (Multi-fonte)
```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthPostgresDataSource _postgresDataSource;
  final AuthLocalDataSource _localDataSource;
  
  @override
  Future<UserModel> getCurrentUser() async {
    try {
      // 1. Tenta cache local primeiro (instantâneo)
      final cachedUser = await _localDataSource.getCachedUser(userId);
      if (cachedUser != null) return cachedUser;
      
      // 2. Tenta PostgreSQL (rápido)
      final postgresUser = await _postgresDataSource.getUser(userId);
      if (postgresUser != null) {
        await _localDataSource.cacheUser(postgresUser);
        return postgresUser;
      }
      
      // 3. Firebase como último recurso
      final firebaseUser = await _remoteDataSource.getUser(userId);
      await _postgresDataSource.saveUser(firebaseUser);
      await _localDataSource.cacheUser(firebaseUser);
      return firebaseUser;
      
    } catch (e) {
      // Fallback: usa cache local mesmo se desatualizado
      return await _localDataSource.getCachedUser(userId) ?? throw e;
    }
  }
}
```

### **⚠️ Quando Repository é Necessário vs Over-Engineering**

#### **✅ Repository é ESSENCIAL quando:**
1. **Múltiplas fontes de dados** (Firebase + PostgreSQL + Cache)
2. **Estratégias de cache** (local, remoto, sincronização)
3. **Fallback strategies** (offline/online, backup)
4. **Transformações complexas** de dados
5. **Sincronização** entre fontes

#### **❌ Repository é OVER-ENGINEERING quando:**
1. **Uma única fonte simples** (só Firebase, sem cache)
2. **Repository que só repassa** chamadas
3. **Projeto pequeno** (3-5 telas)
4. **Funcionalidade muito simples**

#### **🎯 Regra de Ouro:**
- **Comece simples**: Service + Data Source
- **Adicione Repository** quando realmente precisar
- **Não force** arquitetura complexa em projeto simples

#### **Domain Layer** (`lib/features/[feature]/domain/`)

##### **Entities** (`entities/`)
- **Propósito**: Objetos de negócio puros (sem dependências externas)
- **Responsabilidades**:
  - Representar conceitos do negócio
  - Conter regras de domínio
  - Ser independente de frameworks

##### **Repositories** (`repositories/`)
- **Propósito**: Contratos/Interfaces para acesso a dados
- **Responsabilidades**:
  - Definir operações de dados
  - Abstrair fontes de dados
  - Permitir inversão de dependência

**Exemplo**: `AuthRepository`
```dart
abstract class AuthRepository {
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  Future<void> updateUserDisplayName(String name);
  Future<void> createUserDocument(UserModel userModel);
  User? getCurrentUser();
  Future<void> signOut();
}
```

#### **Presentation Layer** (`lib/features/[feature]/presentation/`)

##### **Pages** (`pages/`)
- **Propósito**: Telas/Views da aplicação
- **Responsabilidades**:
  - Definir layout da tela
  - Gerenciar ciclo de vida
  - Coordenar widgets
  - Navegação entre telas

**Exemplo**: `RegisterScreen`
```dart
class RegisterScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          RegisterHeader(),
          RegisterForm(authProvider: _authProvider),
          RegisterFooter(),
        ],
      ),
    );
  }
}
```

##### **Providers** (`providers/`)
- **Propósito**: Gerenciamento de estado da aplicação
- **Responsabilidades**:
  - Manter estado da tela
  - Chamar serviços/casos de uso
  - Notificar mudanças de estado
  - Tratar loading e erros

**Exemplo**: `AuthProvider`
```dart
class AuthProvider extends ChangeNotifier {
  final RegisterUserService _registerUserService;
  
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;
  
  Future<RegisterResult> registerUser({...}) async {
    _setLoading(true);
    final result = await _registerUserService(...);
    _setLoading(false);
    notifyListeners();
  }
}
```

##### **Widgets** (`widgets/`)
- **Propósito**: Componentes reutilizáveis específicos da feature
- **Responsabilidades**:
  - Encapsular lógica de UI
  - Ser reutilizável
  - Receber dados via parâmetros
  - Comunicar eventos via callbacks

**Estrutura de Widgets Separados**:
- **Prefira widgets separados** em arquivos individuais
- **Nomenclatura**: `[nome]_[função].dart` (ex: `login_header.dart`, `register_form.dart`)
- **Organização**: Um widget por arquivo para melhor manutenibilidade
- **Reutilização**: Widgets específicos podem ser reutilizados em outras telas

**Exemplo de Estrutura**:
```
widgets/
├── login_header.dart      # Cabeçalho da tela de login
├── login_form.dart        # Formulário de login
├── login_footer.dart      # Rodapé da tela de login
├── register_header.dart   # Cabeçalho da tela de registro
├── register_form.dart     # Formulário de registro
└── register_footer.dart   # Rodapé da tela de registro
```

## 🎨 Sistema de Tema

### **AppTheme** (`lib/core/theme/app_theme.dart`)
- **Propósito**: Centralizar configurações visuais
- **Responsabilidades**:
  - Definir cores, tipografia, espaçamentos
  - Temas claro e escuro
  - Consistência visual

### **AppColors** (`lib/core/constants/app_colors.dart`)
- **Propósito**: Paleta de cores centralizada
- **Responsabilidades**:
  - Definir cores primárias, secundárias
  - Cores de status (sucesso, erro, aviso)
  - Cores de texto e fundo

## 🔄 Fluxo de Dados

### **Padrão de Comunicação Básico**:
```
UI (Pages/Widgets) 
    ↓ (chama)
Providers 
    ↓ (chama)
Services/Use Cases 
    ↓ (chama)
Repositories 
    ↓ (chama)
Data Sources 
    ↓ (retorna dados)
Repositories 
    ↓ (transforma dados)
Services/Use Cases 
    ↓ (processa lógica)
Providers 
    ↓ (atualiza estado)
UI (atualiza interface)
```

### **Padrão Multi-Fonte (Com Cache e PostgreSQL)**:
```
UI → Provider → Service → Repository → [Cache Local → PostgreSQL → Firebase]
                                    ↓ (estratégia de fallback)
                               [Cache Local ← PostgreSQL ← Firebase]
```

## 📊 Estratégias de Dados

### **Quando Usar Cada Fonte:**

#### **🗄️ Cache Local (SQLite/Hive)**
- **✅ Performance**: Dados instantâneos
- **✅ Offline**: Funciona sem internet
- **✅ Dados temporários**: Sessão atual, preferências
- **❌ Limitação**: Espaço limitado, dados podem ficar desatualizados

#### **🐘 PostgreSQL**
- **✅ Dados estruturados**: Relatórios, analytics
- **✅ Backup**: Dados importantes e confiáveis
- **✅ Queries complexas**: JOINs, agregações
- **✅ Escalabilidade**: Suporta muitos usuários
- **❌ Limitação**: Não é tempo real

#### **🔥 Firebase**
- **✅ Tempo real**: Chat, notificações, status
- **✅ Autenticação**: Login/logout seguro
- **✅ Dados dinâmicos**: Status em tempo real
- **✅ Fácil integração**: SDK pronto
- **❌ Limitação**: Queries limitadas, custo por uso

### **Estratégia de Sincronização:**

#### **1. Sincronização em Tempo Real**
```dart
// Quando app abre
Future<void> syncData() async {
  final firebaseData = await _firebaseDataSource.getData();
  await _postgresDataSource.saveData(firebaseData);
  await _localDataSource.cacheData(firebaseData);
}
```

#### **2. Sincronização Offline**
```dart
// Quando voltar online
Future<void> syncOfflineData() async {
  final localData = await _localDataSource.getOfflineData();
  for (final data in localData) {
    await _firebaseDataSource.saveData(data);
    await _postgresDataSource.saveData(data);
  }
}
```

## 📋 Convenções de Nomenclatura

### **Arquivos**:
- **Models**: `user_model.dart`, `race_model.dart`
- **Services**: `register_user_service.dart`, `auth_service.dart`
- **Data Sources**: `auth_remote_data_source.dart`
- **Repositories**: `auth_repository_impl.dart`
- **Providers**: `auth_provider.dart`
- **Pages**: `login_screen.dart`, `register_screen.dart`
- **Widgets**: `login_form.dart`, `race_card.dart`

### **Classes**:
- **Models**: `UserModel`, `RaceModel`
- **Services**: `RegisterUserService`, `AuthService`
- **Data Sources**: `AuthRemoteDataSource`
- **Repositories**: `AuthRepository`, `AuthRepositoryImpl`
- **Providers**: `AuthProvider`, `RaceProvider`
- **Pages**: `LoginScreen`, `RegisterScreen`
- **Widgets**: `LoginForm`, `RaceCard`

## 🛠️ Padrões de Desenvolvimento

### **1. Injeção de Dependência**
- Usar factory methods para criar providers
- Injetar dependências via construtores
- Evitar dependências hardcoded

### **2. Tratamento de Erros**
- Usar exceptions customizadas
- Mapear erros para mensagens amigáveis
- Log de erros para debugging

### **3. Validação**
- Validar dados na camada de apresentação
- Revalidar no serviço/caso de uso
- Usar validators centralizados

### **4. Estado**
- Usar ChangeNotifier para estado simples
- Manter estado mínimo necessário
- Separar estado de UI do estado de negócio

### **5. Estratégia de Dados (Multi-Fonte)**
- **Cache Local**: Performance e offline
- **PostgreSQL**: Dados estruturados e relatórios
- **Firebase**: Autenticação e tempo real
- **Repository**: Coordena múltiplas fontes

### **6. Organização de Widgets**
- **Widgets separados**: Um widget por arquivo
- **Nomenclatura clara**: `[feature]_[função].dart`
- **Responsabilidade única**: Cada widget tem uma função específica
- **Reutilização**: Widgets podem ser usados em múltiplas telas
- **Manutenibilidade**: Fácil localizar e editar componentes específicos

## 🧪 Testes

### **Estrutura de Testes**:
```
test/
├── unit/                          # Testes unitários
│   ├── models/                    # Testes de modelos
│   ├── services/                  # Testes de serviços
│   └── providers/                 # Testes de providers
├── widget/                        # Testes de widgets
└── integration/                   # Testes de integração
```

## 📝 Checklist de Desenvolvimento

### **Ao criar uma nova feature**:
- [ ] Criar estrutura de pastas (data/domain/presentation)
- [ ] Definir entidades no domain
- [ ] Criar interfaces de repositório
- [ ] Implementar data sources
- [ ] Implementar repositórios
- [ ] Criar serviços/casos de uso
- [ ] Implementar providers
- [ ] Criar páginas e widgets
- [ ] Adicionar testes
- [ ] Documentar funcionalidade

### **Ao modificar uma feature existente**:
- [ ] Verificar impacto nas outras camadas
- [ ] Atualizar testes
- [ ] Manter compatibilidade com contratos
- [ ] Documentar mudanças

## 🚀 Benefícios desta Arquitetura

1. **Separação de Responsabilidades**: Cada camada tem uma responsabilidade específica
2. **Testabilidade**: Fácil de testar cada componente isoladamente
3. **Manutenibilidade**: Código organizado e fácil de manter
4. **Escalabilidade**: Fácil adicionar novas funcionalidades
5. **Reutilização**: Componentes podem ser reutilizados
6. **Flexibilidade**: Fácil trocar implementações (ex: API diferente)
7. **Inversão de Dependência**: Camadas externas dependem das internas, não o contrário
8. **Performance**: Cache local para dados instantâneos
9. **Confiabilidade**: Múltiplas fontes de dados com fallback
10. **Offline**: Funciona sem conexão com internet
11. **Organização de Widgets**: Fácil localizar e editar componentes específicos
12. **Desenvolvimento em Equipe**: Múltiplos desenvolvedores podem trabalhar simultaneamente
13. **Debugging**: Problemas específicos são isolados em arquivos individuais
14. **Versionamento**: Mudanças em widgets específicos são rastreadas facilmente

## 🎯 Decisões Arquiteturais

### **Quando Usar Repository:**
- ✅ **Múltiplas fontes de dados** (Firebase + PostgreSQL + Cache)
- ✅ **Estratégias de cache** complexas
- ✅ **Fallback strategies** (offline/online)
- ✅ **Sincronização** entre fontes
- ❌ **Uma única fonte simples** (só Firebase)
- ❌ **Projeto pequeno** (3-5 telas)

### **Estratégia de Dados Recomendada:**
- **Firebase**: Autenticação, notificações, dados em tempo real
- **PostgreSQL**: Dados estruturados, relatórios, analytics
- **Cache Local**: Performance, dados offline, sessão atual

### **Padrão de Desenvolvimento:**
1. **Comece simples**: Service + Data Source
2. **Adicione Repository** quando precisar de múltiplas fontes
3. **Implemente cache** para performance
4. **Adicione PostgreSQL** para dados estruturados
5. **Use Firebase** para tempo real

### **Regras de Negócio:**
- **Cache primeiro**: Sempre tenta cache local primeiro
- **Fallback inteligente**: Se uma fonte falhar, usa outra
- **Sincronização**: Mantém dados atualizados entre fontes
- **Offline**: Sempre funciona, mesmo sem internet

### **Organização de Widgets:**

#### **✅ Use Widgets Separados quando:**
1. **Widget reutilizável** em múltiplas telas
2. **Lógica complexa** específica do widget
3. **Responsabilidade única** bem definida
4. **Manutenibilidade** é importante
5. **Equipe grande** trabalhando no projeto

#### **❌ Use Arquivo Único quando:**
1. **Widget muito simples** (apenas UI básica)
2. **Uso único** em uma tela específica
3. **Prototipagem rápida**
4. **Projeto pequeno** (1-2 desenvolvedores)

#### **🎯 Padrão Recomendado:**
- **Sempre prefira widgets separados** para melhor organização
- **Nomenclatura**: `[feature]_[função].dart`
- **Exemplos**: `login_header.dart`, `register_form.dart`, `race_card.dart`
- **Estrutura**: Um widget por arquivo, responsabilidade única

#### **📁 Exemplo de Estrutura Completa:**
```
lib/features/auth/presentation/
├── pages/
│   ├── login_screen.dart          # Tela principal de login
│   └── register_screen.dart       # Tela principal de registro
├── widgets/
│   ├── login_header.dart          # Cabeçalho do login
│   ├── login_form.dart            # Formulário de login
│   ├── login_footer.dart          # Rodapé do login
│   ├── register_header.dart       # Cabeçalho do registro
│   ├── register_form.dart         # Formulário de registro
│   ├── register_footer.dart       # Rodapé do registro
│   └── password_field.dart        # Campo de senha reutilizável
└── providers/
    └── auth_provider.dart         # Gerenciamento de estado
```

#### **🔄 Fluxo de Widgets:**
```
Screen (login_screen.dart)
    ↓ (importa e usa)
Header (login_header.dart)
Form (login_form.dart)
Footer (login_footer.dart)
    ↓ (form usa)
PasswordField (password_field.dart)
```
