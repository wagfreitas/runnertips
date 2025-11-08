import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../core/models/tip_model.dart';
import '../core/services/tip_service.dart';

void main() async {
  print('🚀 Iniciando teste do TipService...\n');

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado\n');
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e');
    return;
  }

  final tipService = TipService();

  // Teste 1: Criar uma dica
  print('📝 Teste 1: Criar uma dica...');
  final testTip = TipModel(
    id: '', // Será gerado pelo Firestore
    userId: 'test_user_123',
    raceId: 'test_race_456',
    type: TipType.restaurant,
    category: TipCategory.food,
    title: 'Restaurante La Pasta - Excelente para carb loading antes da maratona',
    content: 'Este restaurante é perfeito para quem vai correr a Maratona de São Paulo. Serve massas deliciosas e está próximo à largada. Recomendo reservar com antecedência.',
    tags: ['massa', 'carb loading', 'próximo à largada'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    stats: const TipStats(),
  );

  final tipId = await tipService.createTip(testTip);
  if (tipId != null) {
    print('✅ Dica criada com sucesso! ID: $tipId\n');
  } else {
    print('❌ Falha ao criar dica\n');
    return;
  }

  // Teste 2: Buscar dica por ID
  print('🔍 Teste 2: Buscar dica por ID...');
  final foundTip = await tipService.getTipById(tipId);
  if (foundTip != null) {
    print('✅ Dica encontrada: ${foundTip.title}\n');
  } else {
    print('❌ Dica não encontrada\n');
  }

  // Teste 3: Buscar todas as dicas
  print('📋 Teste 3: Buscar todas as dicas...');
  final allTips = await tipService.getTips();
  print('✅ ${allTips.length} dica(s) encontrada(s)\n');

  // Teste 4: Buscar dicas por corrida
  print('🏃 Teste 4: Buscar dicas por corrida...');
  final raceTips = await tipService.getTips(raceId: 'test_race_456');
  print('✅ ${raceTips.length} dica(s) encontrada(s) para a corrida\n');

  // Teste 5: Buscar dicas por tipo
  print('🍝 Teste 5: Buscar dicas de restaurante...');
  final restaurantTips = await tipService.getTips(type: TipType.restaurant);
  print('✅ ${restaurantTips.length} dica(s) de restaurante encontrada(s)\n');

  // Teste 6: Busca por texto
  print('🔎 Teste 6: Buscar por texto "massa"...');
  final searchResults = await tipService.searchTips('massa');
  print('✅ ${searchResults.length} resultado(s) encontrado(s)\n');

  print('✨ Todos os testes concluídos!');
}

