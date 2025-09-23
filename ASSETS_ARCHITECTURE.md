# Runner Tips - Arquitetura de Assets

## 📁 Estrutura Completa do Projeto

```
runner_tips/
├── lib/                          # Código fonte Dart
│   ├── core/                     # Configurações e utilitários
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── app_colors.dart
│   │   │   ├── api_endpoints.dart
│   │   │   └── app_assets.dart   # ✨ Constantes dos assets
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   ├── features/                 # Features organizadas por domínio
│   ├── shared/                   # Componentes compartilhados
│   └── main.dart
├── assets/                       # ✨ Assets estáticos
│   ├── images/                   # Imagens da aplicação
│   │   ├── logos/                # Logos e marcas
│   │   ├── backgrounds/          # Imagens de fundo
│   │   ├── illustrations/        # Ilustrações customizadas
│   │   └── avatars/              # Avatares padrão
│   ├── icons/                    # Ícones customizados
│   │   ├── app_icons/            # Ícones do aplicativo
│   │   ├── category/             # Ícones de categorias
│   │   └── social/               # Ícones de redes sociais
│   └── animations/               # Animações
│       ├── lottie/               # Arquivos .json do Lottie
│       └── gif/                  # GIFs animados
├── fonts/                        # Fontes personalizadas
│   └── README.md
├── pubspec.yaml                  # ✨ Configuração dos assets
└── README.md
```

## 🎯 Por que esta Estrutura?

### **1. Separação Clara de Responsabilidades**
- **`lib/`**: Código Dart/Flutter
- **`assets/`**: Recursos estáticos (imagens, ícones, animações)
- **`fonts/`**: Fontes personalizadas

### **2. Organização por Tipo de Asset**
- **Imagens**: Organizadas por categoria (logos, backgrounds, etc.)
- **Ícones**: Separados por funcionalidade (app, categoria, social)
- **Animações**: Por tipo (Lottie, GIF)

### **3. Facilita Manutenção**
- Fácil localização de assets
- Convenções de nomenclatura consistentes
- Constantes centralizadas em `app_assets.dart`

## 🔧 Configuração no pubspec.yaml

```yaml
flutter:
  # Fonts
  fonts:
    - family: Spline Sans
      fonts:
        - asset: fonts/SplineSans-Regular.ttf
          weight: 400
        # ... outros pesos

  # Assets - Configurado por subpasta
  assets:
    - assets/images/logos/
    - assets/images/backgrounds/
    - assets/images/illustrations/
    - assets/images/avatars/
    - assets/icons/app_icons/
    - assets/icons/category/
    - assets/icons/social/
    - assets/animations/lottie/
    - assets/animations/gif/
```

## 📱 Como Usar Assets no Código

### **1. Usando Constantes (Recomendado)**
```dart
import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(AppAssets.logoApp);
  }
}
```

### **2. Usando Caminhos Diretos**
```dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logos/logo_app.png');
  }
}
```

### **3. Lottie Animations**
```dart
import 'package:lottie/lottie.dart';
import '../../core/constants/app_assets.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(AppAssets.lottieLoading);
  }
}
```

## 🎨 Convenções de Nomenclatura

### **Imagens**
```
✅ Correto:
- logo_app.png
- bg_login.png
- illustration_onboarding_1.png
- avatar_default.png

❌ Evitar:
- LogoApp.png
- background_login.png
- onboarding1.png
```

### **Ícones**
```
✅ Correto:
- ic_category_climate.png
- ic_social_facebook.png
- ic_app_settings.png

❌ Evitar:
- category_climate_icon.png
- facebook.png
- settings-icon.png
```

### **Animações**
```
✅ Correto:
- loading_spinner.json
- success_checkmark.json
- error_warning.json

❌ Evitar:
- LoadingSpinner.json
- success.json
- warning_error.json
```

## 🚀 Vantagens desta Arquitetura

### **1. Escalabilidade**
- Fácil adicionar novos tipos de assets
- Organização clara para equipes grandes
- Separação por contexto de uso

### **2. Performance**
- Assets carregados sob demanda
- Organização otimizada para build
- Fácil identificação de assets não utilizados

### **3. Manutenibilidade**
- Constantes centralizadas
- Convenções consistentes
- Documentação clara

### **4. Colaboração**
- Estrutura intuitiva para novos desenvolvedores
- Separação clara de responsabilidades
- Fácil localização de assets

## 📋 Checklist de Implementação

### **✅ Implementado**
- [x] Estrutura de pastas criada
- [x] Configuração no pubspec.yaml
- [x] Constantes centralizadas (app_assets.dart)
- [x] Documentação completa
- [x] Convenções de nomenclatura definidas

### **🔄 Próximos Passos**
- [ ] Adicionar assets reais (logos, ícones)
- [ ] Implementar sistema de cache de imagens
- [ ] Configurar otimização automática de assets
- [ ] Implementar lazy loading para animações

## 🛠 Ferramentas Recomendadas

### **Para Otimização**
- **TinyPNG**: Comprimir imagens
- **Lottie Files**: Otimizar animações JSON
- **flutter_launcher_icons**: Gerar ícones do app

### **Para Gerenciamento**
- **flutter_gen**: Gerar código para assets
- **flutter_svg**: Suporte a SVG
- **cached_network_image**: Cache de imagens

## 📝 Notas Importantes

1. **Sempre** execute `flutter pub get` após modificar assets
2. **Use** as constantes de `app_assets.dart` para referenciar assets
3. **Mantenha** a estrutura de pastas organizada
4. **Otimize** assets para performance mobile
5. **Teste** em diferentes densidades de tela

---

**Status**: ✅ **IMPLEMENTADO** - Estrutura de assets completa e configurada  
**Próximo**: Adicionar assets reais e implementar sistema de cache
