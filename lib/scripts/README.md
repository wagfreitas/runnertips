# Scripts de Seed e Utilidades

## 📋 Script de Seed de Corridas

### Descrição
Script para popular o Firestore com corridas de exemplo. Inclui corridas brasileiras e internacionais famosas.

### Como Executar

#### Opção 1: Executar como Script Flutter
```bash
flutter run -t lib/scripts/seed_races.dart
```

#### Opção 2: Usar no Código
Você pode importar e chamar a função `seedRaces()` em qualquer lugar do código:

```dart
import 'package:runner_tips/scripts/seed_races.dart';

// Em algum lugar do seu código (ex: tela de admin ou debug)
await seedRaces();
```

#### Opção 3: Executar via Dart CLI (requer configuração adicional)
```bash
dart run lib/scripts/seed_races.dart
```

### Corridas Incluídas

O script adiciona **13 corridas de exemplo**:

#### Corridas Brasileiras:
- ✅ Maratona de São Paulo
- ✅ Corrida de São Silvestre
- ✅ Maratona do Rio de Janeiro
- ✅ Meia Maratona de Florianópolis
- ✅ Corrida Internacional de Revezamento
- ✅ São Paulo 10K
- ✅ Corrida da Mulher
- ✅ Night Run São Paulo

#### Corridas Internacionais:
- ✅ Boston Marathon
- ✅ New York City Marathon
- ✅ Berlin Marathon
- ✅ London Marathon
- ✅ Tokyo Marathon

### Características

- ✅ Verifica se a corrida já existe antes de adicionar (evita duplicatas)
- ✅ Usa o `RaceService` para garantir consistência
- ✅ Tratamento de erros robusto
- ✅ Logs detalhados do processo
- ✅ Resumo final com estatísticas

### Notas Importantes

1. **Firebase Configurado**: Certifique-se de que o Firebase está configurado corretamente no projeto
2. **Permissões**: O usuário precisa ter permissão para escrever no Firestore
3. **Duplicatas**: O script verifica duplicatas por nome, então pode ser executado múltiplas vezes sem problemas
4. **Modo Debug**: Recomenda-se executar apenas em ambiente de desenvolvimento

### Exemplo de Saída

```
🚀 Iniciando seed de corridas...

✅ Adicionada: Maratona de São Paulo (ID: abc123...)
✅ Adicionada: Corrida de São Silvestre (ID: def456...)
⏭️  Corrida já existe: Boston Marathon
✅ Adicionada: Berlin Marathon (ID: ghi789...)

📊 Resumo:
   ✅ Sucesso: 11
   ⏭️  Puladas: 2
   ❌ Erros: 0
   📝 Total processado: 13

✨ Seed concluído!
```

### Estrutura dos Dados

Cada corrida inclui:
- Nome e localização
- Distância e data
- Descrição detalhada
- Preço e website
- Organizador
- Categorias
- Status (Open, Closed, Upcoming)
- URLs de imagens (placeholders do Unsplash)

### Próximos Passos

Após executar o seed:
1. ✅ Verifique as corridas no console do Firebase
2. ✅ Teste a busca no app
3. ✅ Verifique se todas as informações estão corretas
4. ✅ Adicione mais corridas conforme necessário

