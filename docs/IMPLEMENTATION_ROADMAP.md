# 🗺️ Roadmap de Implementação - Runner Tips

## 📋 Visão Geral

Este documento apresenta o plano detalhado de implementação das novas funcionalidades do Runner Tips, organizado em fases priorizadas.

---

## 🎯 Fase 1: Infraestrutura Base (Semanas 1-2)

### Objetivo
Configurar a infraestrutura necessária: Supabase, pgvector, n8n workflows.

### Tarefas

#### 1.1 Configuração do Supabase
- [ ] Criar projeto no Supabase
- [ ] Instalar extensão pgvector
- [ ] Criar schema completo do PostgreSQL
- [ ] Configurar índices HNSW
- [ ] Testar conexão

**Arquivos:**
- `docs/supabase_schema.sql`

#### 1.2 Configuração do n8n
- [ ] Criar workflow de busca NLP
- [ ] Configurar integração com OpenAI
- [ ] Configurar integração com Supabase
- [ ] Testar geração de embeddings
- [ ] Testar busca vetorial

**Arquivos:**
- `n8n/workflows/nlp_search.json`
- `n8n/workflows/generate_embeddings.json`

#### 1.3 Configuração do OpenAI
- [ ] Criar conta e obter API key
- [ ] Configurar modelos (ada-002, gpt-4)
- [ ] Configurar rate limits
- [ ] Testar APIs

**Documentação:**
- `docs/OPENAI_SETUP.md`

---

## 🎯 Fase 2: Modelos e Serviços Backend (Semanas 3-4)

### Objetivo
Criar modelos Dart e serviços para as novas funcionalidades.

### Tarefas

#### 2.1 Modelos Dart
- [ ] `TipModel` - Dicas (hotel, restaurante, etc.)
- [ ] `ReviewModel` - Avaliações de experiências
- [ ] `CityModel` - Cidades
- [ ] `RouteMapModel` - Mapas de trajeto
- [ ] `CommentModel` - Comentários
- [ ] `ModerationModel` - Moderação

**Arquivos:**
- `lib/core/models/tip_model.dart`
- `lib/core/models/review_model.dart`
- `lib/core/models/city_model.dart`
- `lib/core/models/route_map_model.dart`
- `lib/core/models/comment_model.dart`

#### 2.2 Serviços Backend
- [ ] `TipService` - CRUD de dicas
- [ ] `ReviewService` - CRUD de reviews
- [ ] `VectorSearchService` - Busca vetorial
- [ ] `ModerationService` - Moderação automática
- [ ] `ContentValidator` - Validação de conteúdo

**Arquivos:**
- `lib/core/services/tip_service.dart`
- `lib/core/services/review_service.dart`
- `lib/core/services/vector_search_service.dart`
- `lib/core/services/moderation_service.dart`
- `lib/core/utils/content_validator.dart`

#### 2.3 Integração n8n
- [ ] Serviço de chamada ao n8n para busca NLP
- [ ] Serviço de geração de embeddings
- [ ] Tratamento de erros e retry
- [ ] Cache de resultados

**Arquivos:**
- `lib/core/services/nlp_search_service.dart`
- `lib/core/services/embedding_service.dart`

---

## 🎯 Fase 3: Features Core - Busca NLP (Semanas 5-6)

### Objetivo
Implementar a busca em linguagem natural.

### Tarefas

#### 3.1 Tela de Busca NLP
- [ ] Campo de busca com sugestões
- [ ] Indicador de processamento
- [ ] Exibição de resultados
- [ ] Filtros contextuais

**Arquivos:**
- `lib/features/search/presentation/pages/natural_language_search_screen.dart`
- `lib/features/search/presentation/widgets/search_results_widget.dart`
- `lib/features/search/presentation/providers/nlp_search_provider.dart`

#### 3.2 Validação de Query
- [ ] Validação de conteúdo esportivo
- [ ] Mensagens de erro amigáveis
- [ ] Sugestões de correção

**Arquivos:**
- `lib/core/utils/query_validator.dart`

#### 3.3 Integração Completa
- [ ] Conectar frontend com n8n
- [ ] Processar respostas
- [ ] Exibir resultados formatados
- [ ] Tratamento de erros

---

## 🎯 Fase 4: Features Core - Dicas (Semanas 7-8)

### Objetivo
Implementar sistema completo de dicas.

### Tarefas

#### 4.1 Tela de Listagem de Dicas
- [ ] Lista de dicas por categoria
- [ ] Filtros (tipo, corrida, cidade)
- [ ] Busca e ordenação
- [ ] Paginação

**Arquivos:**
- `lib/features/tips/presentation/pages/tips_screen.dart`
- `lib/features/tips/presentation/widgets/tip_card.dart`
- `lib/features/tips/presentation/widgets/tip_filters.dart`

#### 4.2 Tela de Criar Dica
- [ ] Formulário dinâmico por tipo
- [ ] Upload de imagens
- [ ] Validação em tempo real
- [ ] Preview antes de publicar

**Arquivos:**
- `lib/features/tips/presentation/pages/create_tip_screen.dart`
- `lib/features/tips/presentation/widgets/tip_form.dart`

#### 4.3 Tela de Detalhes da Dica
- [ ] Visualização completa
- [ ] Interações (like, save, share)
- [ ] Comentários
- [ ] Informações do autor

**Arquivos:**
- `lib/features/tips/presentation/pages/tip_detail_screen.dart`

---

## 🎯 Fase 5: Features Core - Avaliações (Semanas 9-10)

### Objetivo
Implementar sistema de avaliações de experiências.

### Tarefas

#### 5.1 Tela de Avaliações
- [ ] Lista de avaliações de uma corrida
- [ ] Filtros (ano, rating, útil)
- [ ] Ordenação
- [ ] Estatísticas agregadas

**Arquivos:**
- `lib/features/reviews/presentation/pages/reviews_screen.dart`
- `lib/features/reviews/presentation/widgets/review_card.dart`

#### 5.2 Tela de Criar Avaliação
- [ ] Formulário de avaliação
- [ ] Ratings por categoria
- [ ] Pontos positivos/negativos
- [ ] Upload de fotos

**Arquivos:**
- `lib/features/reviews/presentation/pages/create_review_screen.dart`
- `lib/features/reviews/presentation/widgets/review_form.dart`

---

## 🎯 Fase 6: Features Core - Mapas (Semanas 11-12)

### Objetivo
Implementar mapas interativos com altimetria.

### Tarefas

#### 6.1 Tela de Mapa de Trajeto
- [ ] Mapa interativo (Google Maps / Mapbox)
- [ ] Exibição do trajeto
- [ ] Marcadores (largada, chegada, postos)
- [ ] Controles (zoom, tipo de mapa)

**Arquivos:**
- `lib/features/race/presentation/pages/race_route_map_screen.dart`
- `lib/features/race/presentation/widgets/route_map_widget.dart`

#### 6.2 Gráfico de Altimetria
- [ ] Gráfico de elevação
- [ ] Interatividade (hover, zoom)
- [ ] Informações de distância/elevação
- [ ] Download de dados

**Arquivos:**
- `lib/features/race/presentation/widgets/elevation_chart_widget.dart`

#### 6.3 Download de Arquivos
- [ ] Download de GPX
- [ ] Download de KML
- [ ] Compartilhamento

**Arquivos:**
- `lib/core/services/route_file_service.dart`

---

## 🎯 Fase 7: Moderação (Semanas 13-14)

### Objetivo
Implementar sistema completo de moderação.

### Tarefas

#### 7.1 Moderação Automática
- [ ] Integração com OpenAI Moderation API
- [ ] Detecção de toxicidade
- [ ] Verificação de relevância
- [ ] Detecção de spam

**Arquivos:**
- `lib/core/services/auto_moderation_service.dart`

#### 7.2 Dashboard de Moderação
- [ ] Lista de conteúdo pendente
- [ ] Filtros e ordenação
- [ ] Ações (aprovar, rejeitar, editar)
- [ ] Histórico

**Arquivos:**
- `lib/features/moderation/presentation/pages/moderation_dashboard_screen.dart`

#### 7.3 Sistema de Reports
- [ ] Widget de reportar conteúdo
- [ ] Processamento de reports
- [ ] Notificações

**Arquivos:**
- `lib/features/moderation/presentation/widgets/report_content_widget.dart`

---

## 🎯 Fase 8: Polimento e Otimização (Semanas 15-16)

### Objetivo
Melhorar UX, performance e qualidade.

### Tarefas

#### 8.1 UX/UI
- [ ] Animações e transições
- [ ] Loading states
- [ ] Mensagens de erro amigáveis
- [ ] Feedback visual

#### 8.2 Performance
- [ ] Otimização de queries
- [ ] Cache de resultados
- [ ] Lazy loading
- [ ] Compressão de imagens

#### 8.3 Testes
- [ ] Testes unitários
- [ ] Testes de integração
- [ ] Testes E2E
- [ ] Testes de carga

#### 8.4 Documentação
- [ ] Documentação de API
- [ ] Guia do usuário
- [ ] Documentação técnica
- [ ] README atualizado

---

## 📊 Checklist de Implementação

### Infraestrutura
- [ ] Supabase configurado
- [ ] pgvector instalado
- [ ] n8n workflows criados
- [ ] OpenAI configurado

### Backend
- [ ] Modelos Dart criados
- [ ] Serviços implementados
- [ ] APIs funcionando
- [ ] Testes passando

### Frontend
- [ ] Telas criadas
- [ ] Navegação funcionando
- [ ] Estado gerenciado
- [ ] UI polida

### Integração
- [ ] n8n integrado
- [ ] Busca vetorial funcionando
- [ ] Moderação automática ativa
- [ ] Upload de arquivos funcionando

### Qualidade
- [ ] Testes escritos
- [ ] Bugs corrigidos
- [ ] Performance otimizada
- [ ] Documentação completa

---

## 🚀 Cronograma Resumido

| Fase | Semanas | Duração | Prioridade |
|------|---------|---------|------------|
| 1. Infraestrutura | 1-2 | 2 semanas | 🔴 Crítica |
| 2. Modelos/Serviços | 3-4 | 2 semanas | 🔴 Crítica |
| 3. Busca NLP | 5-6 | 2 semanas | 🔴 Crítica |
| 4. Dicas | 7-8 | 2 semanas | 🟡 Alta |
| 5. Avaliações | 9-10 | 2 semanas | 🟡 Alta |
| 6. Mapas | 11-12 | 2 semanas | 🟡 Alta |
| 7. Moderação | 13-14 | 2 semanas | 🟢 Média |
| 8. Polimento | 15-16 | 2 semanas | 🟢 Média |

**Total: 16 semanas (4 meses)**

---

## 🎯 Próximos Passos Imediatos

### Esta Semana
1. ✅ Revisar arquitetura completa
2. [ ] Configurar Supabase
3. [ ] Criar schema do banco
4. [ ] Configurar n8n básico

### Próxima Semana
1. [ ] Implementar modelos Dart básicos
2. [ ] Criar serviços de conexão
3. [ ] Testar integração Supabase-Flutter
4. [ ] Começar workflow n8n de busca NLP

---

## 📝 Notas Importantes

### Priorização
- **Crítica**: Infraestrutura, Busca NLP (diferencial principal)
- **Alta**: Dicas, Avaliações, Mapas (features core)
- **Média**: Moderação, Polimento (importante mas pode esperar)

### Riscos
- Complexidade da busca vetorial
- Custo da API OpenAI
- Performance do pgvector
- Integração n8n-Flutter

### Mitigações
- Começar simples e iterar
- Monitorar custos da API
- Testes de performance desde o início
- Documentar tudo

---

*Documento criado em: Janeiro 2024*
*Versão: 1.0*
*Última atualização: Janeiro 2024*

