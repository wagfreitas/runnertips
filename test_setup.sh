#!/bin/bash

echo "🔍 DIAGNÓSTICO DO PROJETO RUNNER TIPS"
echo "======================================"
echo ""

echo "📋 1. Git Status"
echo "----------------"
git status
echo ""

echo "📋 2. Branch Atual"
echo "----------------"
git branch --show-current
echo ""

echo "📋 3. Últimos Commits"
echo "----------------"
git log --oneline -5
echo ""

echo "📋 4. Flutter Version"
echo "----------------"
flutter --version 2>&1 || echo "❌ Flutter não encontrado no PATH"
echo ""

echo "📋 5. Instalando Dependências"
echo "----------------"
flutter pub get 2>&1 || echo "❌ Erro ao rodar flutter pub get"
echo ""

echo "📋 6. Analisando Código"
echo "----------------"
flutter analyze 2>&1 || echo "❌ Erro ao analisar código"
echo ""

echo "📋 7. Verificando Dependências Críticas"
echo "----------------"
flutter pub deps 2>&1 | grep -E "riverpod|go_router|google_maps|cached_network|dio|hive|crashlytics" || echo "❌ Erro ao verificar deps"
echo ""

echo "✅ DIAGNÓSTICO COMPLETO!"
echo "========================"
echo ""
echo "Cole TODO esse output para o Claude Code analisar!"
