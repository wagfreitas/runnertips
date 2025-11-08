# Extração de Imagens do Site Oficial - n8n

## Estratégias para Obter Imagem do Site Oficial

### Opção 1: Busca Específica de Imagens (Recomendada)

Adicione uma nova ferramenta de busca de imagens no n8n:

**Node**: HTTP Request (SearchApi.io - Images)
- **URL**: `https://www.searchapi.io/api/v1/search`
- **Query**: `={{$json.query_text}} logo OR banner OR "site oficial"`
- **Parâmetros**:
  - `engine`: `google_images`
  - `q`: `={{$json.query_text}} logo site oficial`
  - `api_key`: sua chave

Isso retornará imagens relacionadas ao site oficial.

### Opção 2: Extrair do HTML do Site (Mais Complexa)

Usar um node de scraping ou HTTP Request para:
1. Buscar o HTML do site oficial
2. Extrair Open Graph image (`og:image`)
3. Ou extrair primeira imagem do banner/header

### Opção 3: Instruir o Agente a Buscar (Mais Simples)

Adicionar no prompt do agente instruções para:
- Buscar imagens do site oficial
- Usar Open Graph metadata
- Retornar URL da imagem principal

## Implementação Recomendada

### No Prompt do AI Agent, adicione:

```
Ao encontrar o site oficial, busque também:
- Logo da corrida
- Banner principal
- Imagem de capa do evento

Inclua no JSON:
"conclusion": {
  ...
  "image_url": "URL da imagem principal do site oficial"
}
```

### No código Flutter, o campo já está preparado:

O `RaceSuggestion` tem `imageUrl` e o código já processa:
- `conclusion['image_url']`
- Ou usa placeholder se não encontrar

## Exemplo de Resposta Esperada

```json
{
  "conclusion": {
    "what": "Maratona Internacional de Assunção",
    "when": "30 de Agosto, 2026",
    "where": "Asunción, Paraguay",
    "distance": "42km / 21Km",
    "website": "https://www.maratondeasuncion.com.py/",
    "image_url": "https://www.maratondeasuncion.com.py/images/logo.png"
  }
}
```

