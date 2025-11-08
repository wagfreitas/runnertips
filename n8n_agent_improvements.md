# Melhorias para o Agente n8n - Priorizar Site Oficial

## Problema Identificado

O agente atual não está priorizando o site oficial da corrida. Por exemplo, para "Maratona Internacional de Assunção", o agente trouxe Wikipedia mas existe um site oficial: https://www.maratondeasuncion.com.py/

## Soluções Implementadas

### 1. Prompt Melhorado do AI Agent

**Arquivo**: `n8n_improved_prompt.txt`

**Mudanças principais**:
- Instruções claras para buscar PRIMEIRO o site oficial
- Priorização explícita: site oficial > federações > Wikipedia
- Campo `is_official` nos results para identificar fontes oficiais
- Campo `website` na conclusion com URL do site oficial
- Instrução para usar nome CURTO no campo "what" (não descrição longa)

### 2. Query de Busca Otimizada

**Arquivo**: `n8n_improved_search_query.txt`

**Mudanças principais**:
- Query atualizada para incluir termos "site oficial", "página oficial"
- Priorização de buscas por domínios específicos
- Estrutura de múltiplas buscas (se necessário)

### 3. Estratégia de Busca em Camadas

**Recomendado no n8n**:

1. **Busca 1 (Obrigatória)**: `{query_text} "site oficial" OR "página oficial"`
   - Prioridade máxima
   - Se encontrar, usar como fonte primária

2. **Busca 2 (Fallback)**: `{query_text} inscrições OR registro`
   - Apenas se Busca 1 não encontrar site oficial
   - Foca em sites de registro/inscrição

3. **Busca 3 (Último recurso)**: `{query_text}`
   - Busca geral
   - Usa Wikipedia e outras fontes apenas se não encontrar site oficial

## Como Implementar

### Passo 1: Atualizar o Prompt do AI Agent

1. Abra o workflow no n8n
2. Clique no node "AI Agent"
3. Substitua o prompt atual pelo conteúdo de `n8n_improved_prompt.txt`
4. Salve

### Passo 2: Melhorar a Query de Busca

**Opção A - Query Única (Mais Simples)**:
1. Abra o node "HTTP Request (SearchApi.io)"
2. No parâmetro `q`, use:
   ```
   ={{$json.query_text}} "site oficial" OR "página oficial" OR inscrições
   ```

**Opção B - Múltiplas Buscas (Mais Eficaz)**:
1. Duplique o node "HTTP Request (SearchApi.io)"
2. Renomeie para "HTTP Request (Site Oficial)"
3. Configure a query: `={{$json.query_text}} "site oficial"`
4. Mantenha o node original como fallback
5. Configure o AI Agent para usar ambas as ferramentas

### Passo 3: Ajustar o Processamento dos Resultados

O código de parse já está preparado para processar o novo formato. O agente deve retornar:

```json
{
  "query_text": "Maratona Internacional de Assunção",
  "race_type": "marathon",
  "location": "Assunção, Paraguai",
  "results": [
    {
      "title": "Maratón Internacional de Asunción - Site Oficial",
      "summary": "...",
      "url": "https://www.maratondeasuncion.com.py/",
      "is_official": true
    }
  ],
  "conclusion": {
    "what": "Maratona Internacional de Assunção",
    "when": "30 de Agosto, 2026",
    "where": "Costanera de Asunción | Asunción, Paraguay",
    "distance": "42km / 21Km",
    "registration": "https://www.maratondeasuncion.com.py/inscripciones",
    "website": "https://www.maratondeasuncion.com.py/",
    "organizer": "PMC"
  }
}
```

## Benefícios

✅ **Priorização clara**: Site oficial sempre vem primeiro  
✅ **Informações mais precisas**: Dados direto da fonte  
✅ **Melhor experiência**: Links corretos para inscrição  
✅ **Confiança maior**: Informações oficiais são mais confiáveis  

## Validação

Após implementar, teste com:
- "Maratona Internacional de Assunção" → deve encontrar https://www.maratondeasuncion.com.py/
- "Maratona de São Paulo" → deve encontrar site oficial
- "Boston Marathon" → deve encontrar baa.org

## Notas Importantes

1. O campo `website` na conclusion será usado pelo app Flutter
2. O campo `what` deve ser curto (não descrição completa)
3. O agente deve indicar claramente quando não encontrar site oficial
4. Sempre priorizar sites com domínios específicos da corrida

