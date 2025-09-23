# Fontes do Runner Tips

Este diretório contém as fontes utilizadas no aplicativo Runner Tips.

## Fontes Necessárias

Para que o aplicativo funcione corretamente, você precisa baixar e adicionar as seguintes fontes:

### Spline Sans
- **Fonte**: Spline Sans
- **Download**: [Google Fonts - Spline Sans](https://fonts.google.com/specimen/Spline+Sans)
- **Arquivos necessários**:
  - `SplineSans-Regular.ttf` (weight: 400)
  - `SplineSans-Medium.ttf` (weight: 500)
  - `SplineSans-Bold.ttf` (weight: 700)
  - `SplineSans-Black.ttf` (weight: 900)

## Como adicionar as fontes

1. Acesse o link do Google Fonts acima
2. Clique em "Download family"
3. Extraia o arquivo ZIP baixado
4. Copie os arquivos `.ttf` para esta pasta (`fonts/`)
5. Certifique-se de que os nomes dos arquivos correspondem exatamente aos especificados no `pubspec.yaml`

## Estrutura esperada

```
fonts/
├── README.md
├── SplineSans-Regular.ttf
├── SplineSans-Medium.ttf
├── SplineSans-Bold.ttf
└── SplineSans-Black.ttf
```

## Alternativa temporária

Se você não quiser baixar as fontes agora, pode comentar a seção `fonts:` no `pubspec.yaml` e o aplicativo usará as fontes padrão do sistema.

```yaml
# fonts:
#   - family: Spline Sans
#     fonts:
#       - asset: fonts/SplineSans-Regular.ttf
#         weight: 400
#       # ... outros pesos
```

## Licença

As fontes Spline Sans são licenciadas sob a Open Font License (OFL) e podem ser usadas livremente em projetos comerciais e pessoais.
