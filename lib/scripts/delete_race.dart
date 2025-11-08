import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Script temporário para deletar uma corrida específica do Firestore
/// 
/// Para executar: flutter run -t lib/scripts/delete_race.dart

Future<void> main() async {
  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('🗑️  Deletando Maratona de Assunção do banco...\n');

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference racesCollection = firestore.collection('races');

  try {
    // Busca corridas que contenham "Assunção" ou "Asunción" no nome ou localização
    final QuerySnapshot snapshot = await racesCollection
        .where('name', isGreaterThanOrEqualTo: '')
        .get();

    int deletedCount = 0;
    
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['name'] ?? '').toString().toLowerCase();
      final location = (data['location'] ?? '').toString().toLowerCase();
      
      // Verifica se contém "assunção" ou variações
      if (name.contains('assun') || 
          name.contains('asuncion') ||
          location.contains('assun') ||
          location.contains('asuncion') ||
          name.contains('paraguai') ||
          location.contains('paraguai')) {
        print('🗑️  Deletando: ${data['name']} (${doc.id})');
        await doc.reference.delete();
        deletedCount++;
      }
    }

    print('\n✅ Concluído!');
    print('   🗑️  Corridas deletadas: $deletedCount');
    
    if (deletedCount == 0) {
      print('   ⚠️  Nenhuma corrida encontrada com "Assunção" no nome ou localização');
      print('   💡 Verificando todas as corridas...');
      
      // Lista todas as corridas para debug
      final allRaces = await racesCollection.get();
      print('\n📋 Corridas no banco:');
      for (final doc in allRaces.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('   - ${data['name']} (${doc.id})');
      }
    }
    
  } catch (e) {
    print('❌ Erro ao deletar: $e');
  } finally {
    await Firebase.app().delete();
  }
}

