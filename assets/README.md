# Assets do Runner Tips

Este diretório contém todos os assets estáticos da aplicação.

## 📁 Estrutura de Pastas

```
assets/
├── README.md
├── images/           # Imagens da aplicação
│   ├── logos/        # Logos e marcas
│   ├── backgrounds/  # Imagens de fundo
│   ├── illustrations/ # Ilustrações e ícones customizados
│   └── avatars/      # Avatares padrão
├── icons/            # Ícones customizados
│   ├── app_icons/    # Ícones do aplicativo
│   ├── category/     # Ícones de categorias
│   └── social/       # Ícones de redes sociais
└── animations/       # Animações e Lottie files
    ├── lottie/       # Arquivos .json do Lottie
    └── gif/          # GIFs animados
```

## 🎯 Organização por Categoria

### **Imagens (`assets/images/`)**
- **Logos**: Logo da aplicação, variações de marca
- **Backgrounds**: Imagens de fundo para telas
- **Illustrations**: Ilustrações customizadas, onboarding
- **Avatars**: Avatares padrão para usuários

### **Ícones (`assets/icons/`)**
- **App Icons**: Ícones específicos da aplicação
- **Category**: Ícones para categorias de dicas (clima, altimetria, etc.)
- **Social**: Ícones de redes sociais e compartilhamento

### **Animações (`assets/animations/`)**
- **Lottie**: Arquivos JSON para animações Lottie
- **GIF**: GIFs animados quando necessário

## 📱 Convenções de Nomenclatura

### **Imagens**
```
- snake_case para nomes de arquivos
- Prefixos descritivos:
  - logo_app.png
  - bg_login.png
  - illustration_onboarding_1.png
  - avatar_default.png
```

### **Ícones**
```
- snake_case para nomes de arquivos
- Prefixos por categoria:
  - ic_category_climate.png
  - ic_category_elevation.png
  - ic_social_facebook.png
  - ic_app_settings.png
```

### **Animações**
```
- snake_case para nomes de arquivos
- Prefixos descritivos:
  - loading_spinner.json
  - success_checkmark.json
  - error_warning.json
```

## 🎨 Especificações Técnicas

### **Imagens**
- **Formato**: PNG (transparência), JPG (fotografias), WebP (otimização)
- **Resolução**: 2x e 3x para diferentes densidades de tela
- **Tamanho**: Otimizadas para mobile (máximo 2MB por imagem)

### **Ícones**
- **Formato**: PNG com transparência
- **Tamanho**: 24x24px (1x), 48x48px (2x), 72x72px (3x)
- **Estilo**: Consistente com Material Design

### **Animações**
- **Lottie**: Arquivos JSON otimizados
- **GIF**: Máximo 5MB, otimizados para web
- **Duração**: Máximo 3 segundos para UX

## 🔧 Como Usar

### **No código Flutter**
```dart
// Imagens
Image.asset('assets/images/logo_app.png')

// Ícones
Image.asset('assets/icons/ic_category_climate.png')

// Animações Lottie
Lottie.asset('assets/animations/lottie/loading_spinner.json')
```

### **Adicionando novos assets**
1. Adicione o arquivo na pasta apropriada
2. Execute `flutter pub get` para atualizar
3. Use no código com o caminho correto

## 📋 Checklist de Assets Necessários

### **MVP (Fase 1)**
- [ ] Logo da aplicação
- [ ] Ícone de corrida (directions_run)
- [ ] Avatares padrão
- [ ] Ilustrações de onboarding

### **Fase 2**
- [ ] Ícones de categorias
- [ ] Animações de loading
- [ ] Ícones de redes sociais
- [ ] Backgrounds customizados

### **Fase 3**
- [ ] Animações de sucesso/erro
- [ ] Ilustrações de estados vazios
- [ ] Ícones de funcionalidades premium

## 🚀 Otimização

- Use ferramentas como `flutter_launcher_icons` para gerar ícones
- Comprima imagens com ferramentas online
- Considere usar WebP para melhor compressão
- Otimize arquivos Lottie removendo frames desnecessários

## 📝 Notas Importantes

1. **Sempre** execute `flutter pub get` após adicionar assets
2. **Mantenha** a estrutura de pastas organizada
3. **Use** nomenclatura consistente
4. **Otimize** assets para performance mobile
5. **Teste** em diferentes densidades de tela

---

**Última atualização**: Janeiro 2025  
**Responsável**: Equipe de Desenvolvimento
