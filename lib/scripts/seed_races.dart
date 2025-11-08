import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../core/models/race_model.dart';
import '../core/services/race_service.dart';
import '../firebase_options.dart';

/// Script para popular o Firestore com corridas de exemplo
/// 
/// Para executar:
/// 1. Configure o Firebase no projeto
/// 2. Execute: flutter run -t lib/scripts/seed_races.dart
/// 
/// Ou chame a função seedRaces() diretamente no código

Future<void> main() async {
  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('🚀 Iniciando seed de corridas...\n');

  final RaceService raceService = RaceService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference racesCollection = firestore.collection('races');

  // Lista de corridas de exemplo
  final List<RaceModel> sampleRaces = _getSampleRaces();

  int successCount = 0;
  int errorCount = 0;
  int skippedCount = 0;

  for (final race in sampleRaces) {
    try {
      // Verifica se a corrida já existe (por nome)
      final existingRaces = await racesCollection
          .where('name', isEqualTo: race.name)
          .limit(1)
          .get();

      if (existingRaces.docs.isNotEmpty) {
        print('⏭️  Corrida já existe: ${race.name}');
        skippedCount++;
        continue;
      }

      // Adiciona a corrida usando o RaceService
      final String? id = await raceService.addRace(race);
      if (id != null) {
        print('✅ Adicionada: ${race.name} (ID: $id)');
        successCount++;
      } else {
        print('❌ Falha ao adicionar: ${race.name}');
        errorCount++;
      }
    } catch (e) {
      print('❌ Erro ao adicionar ${race.name}: $e');
      errorCount++;
    }
  }

  print('\n📊 Resumo:');
  print('   ✅ Sucesso: $successCount');
  print('   ⏭️  Puladas: $skippedCount');
  print('   ❌ Erros: $errorCount');
  print('   📝 Total processado: ${sampleRaces.length}');
  print('\n✨ Seed concluído!');
  
  // Fecha a conexão
  await Firebase.app().delete();
}

/// Função utilitária para popular corridas (pode ser chamada de outros lugares)
/// Esta função assume que o Firebase já foi inicializado
Future<void> seedRaces() async {
  print('🚀 Iniciando seed de corridas...\n');

  final RaceService raceService = RaceService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference racesCollection = firestore.collection('races');

  // Lista de corridas de exemplo
  final List<RaceModel> sampleRaces = _getSampleRaces();

  int successCount = 0;
  int errorCount = 0;
  int skippedCount = 0;

  for (final race in sampleRaces) {
    try {
      // Verifica se a corrida já existe (por nome)
      final existingRaces = await racesCollection
          .where('name', isEqualTo: race.name)
          .limit(1)
          .get();

      if (existingRaces.docs.isNotEmpty) {
        print('⏭️  Corrida já existe: ${race.name}');
        skippedCount++;
        continue;
      }

      // Adiciona a corrida usando o RaceService
      final String? id = await raceService.addRace(race);
      if (id != null) {
        print('✅ Adicionada: ${race.name} (ID: $id)');
        successCount++;
      } else {
        print('❌ Falha ao adicionar: ${race.name}');
        errorCount++;
      }
    } catch (e) {
      print('❌ Erro ao adicionar ${race.name}: $e');
      errorCount++;
    }
  }

  print('\n📊 Resumo:');
  print('   ✅ Sucesso: $successCount');
  print('   ⏭️  Puladas: $skippedCount');
  print('   ❌ Erros: $errorCount');
  print('   📝 Total processado: ${sampleRaces.length}');
  print('\n✨ Seed concluído!');
}

/// Retorna lista de corridas de exemplo
List<RaceModel> _getSampleRaces() {
  final DateTime now = DateTime.now();
  final DateTime nextYear = DateTime(now.year + 1);

  return [
    // Corridas Brasileiras
    RaceModel(
      id: '',
      name: 'Maratona de São Paulo',
      location: 'São Paulo, SP',
      distance: '42.195 km',
      month: 'June',
      year: '${nextYear.year}',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      description:
          'A maior maratona da América Latina. Percurso desafiador que passa pelos principais pontos turísticos da cidade. Organizada pela Corpore, é uma das corridas mais tradicionais do Brasil.',
      status: 'Open',
      eventDate: DateTime(nextYear.year, 6, 15),
      registrationDeadline: DateTime(nextYear.year, 6, 1),
      price: 250.00,
      website: 'https://www.corpore.com.br',
      organizer: 'Corpore',
      categories: ['Marathon', 'Half Marathon', '10K'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    RaceModel(
      id: '',
      name: 'Corrida de São Silvestre',
      location: 'São Paulo, SP',
      distance: '15 km',
      month: 'December',
      year: '${now.year}',
      imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=800',
      description:
          'A corrida mais tradicional do Brasil, realizada no último dia do ano. Percurso histórico pelas ruas de São Paulo com milhares de participantes.',
      status: 'Open',
      eventDate: DateTime(now.year, 12, 31),
      registrationDeadline: DateTime(now.year, 12, 15),
      price: 180.00,
      website: 'https://www.saosilvestre.com.br',
      organizer: 'Fundação Cásper Líbero',
      categories: ['15K'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    RaceModel(
      id: '',
      name: 'Maratona do Rio de Janeiro',
      location: 'Rio de Janeiro, RJ',
      distance: '42.195 km',
      month: 'August',
      year: '${nextYear.year}',
      imageUrl: 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?w=800',
      description:
          'Maratona com vista para o mar e percurso deslumbrante pela orla do Rio. Uma das corridas mais bonitas do mundo, passando por Copacabana, Ipanema e Leblon.',
      status: 'Open',
      eventDate: DateTime(nextYear.year, 8, 20),
      registrationDeadline: DateTime(nextYear.year, 8, 5),
      price: 280.00,
      website: 'https://www.maratonadorio.com.br',
      organizer: 'Rio Marathon',
      categories: ['Marathon', 'Half Marathon'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    RaceModel(
      id: '',
      name: 'Meia Maratona de Florianópolis',
      location: 'Florianópolis, SC',
      distance: '21.0975 km',
      month: 'September',
      year: '${nextYear.year}',
      imageUrl: 'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=800',
      description:
          'Meia maratona em uma das cidades mais bonitas do Brasil. Percurso pela orla de Floripa com paisagens paradisíacas.',
      status: 'Open',
      eventDate: DateTime(nextYear.year, 9, 10),
      registrationDeadline: DateTime(nextYear.year, 8, 25),
      price: 150.00,
      website: 'https://www.floriparun.com.br',
      organizer: 'Floripa Run',
      categories: ['Half Marathon', '10K', '5K'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    RaceModel(
      id: '',
      name: 'Corrida Internacional de Revezamento',
      location: 'São Paulo, SP',
      distance: '42.195 km (revezamento)',
      month: 'May',
      year: '${nextYear.year}',
      imageUrl: 'https://images.unsplash.com/photo-1513593771513-7b58b6c4af38?w=800',
      description:
          'Corrida de revezamento em equipes de 4 pessoas. Cada corredor completa aproximadamente 10.5 km. Evento divertido e descontraído.',
      status: 'Open',
      eventDate: DateTime(nextYear.year, 5, 12),
      registrationDeadline: DateTime(nextYear.year, 4, 30),
      price: 400.00, // Preço por equipe
      website: 'https://www.revezamento.com.br',
      organizer: 'Corpore',
      categories: ['Marathon', 'Relay'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    // Corridas Internacionais
    RaceModel(
      id: '',
      name: 'Boston Marathon',
      location: 'Boston, MA, USA',
      distance: '42.195 km',
      month: 'April',
      year: '${nextYear.year}',
      imageUrl: 'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=800',
      description:
          'A maratona mais antiga do mundo e uma das mais prestigiadas. Requer qualificação para participar. Percurso histórico de Hopkinton até Boston.',
      status: 'Closed',
      eventDate: DateTime(nextYear.year, 4, 15),
      registrationDeadline: DateTime(nextYear.year, 2, 15),
      price: 195.00,
      website: 'https://www.baa.org/races/boston-marathon',
      organizer: 'Boston Athletic Association',
      categories: ['Marathon'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    RaceModel(
      id: '',
      name: 'New York City Marathon',
      location: 'New York, NY, USA',
      distance: '42.195 km',
      month: 'November',
      year: '${now.year}',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      description:
          'A maior maratona do mundo com mais de 50.000 participantes. Percurso pelos 5 boroughs de Nova York com suporte incrível do público.',
      status: 'Closed',
      eventDate: DateTime(now.year, 11, 3),
      registrationDeadline: DateTime(now.year, 9, 15),
      price: 295.00,
      website: 'https://www.nycmarathon.org',
      organizer: 'New York Road Runners',
      categories: ['Marathon'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    RaceModel(
      id: '',
      name: 'Berlin Marathon',
      location: 'Berlin, Germany',
      distance: '42.195 km',
      month: 'September',
      year: '${nextYear.year}',
      imageUrl: 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?w=800',
      description:
          'Famosa por ser um dos percursos mais rápidos do mundo. Muitos recordes mundiais foram estabelecidos aqui. Percurso plano e rápido pela capital alemã.',
      status: 'Open',
      eventDate: DateTime(nextYear.year, 9, 29),
      registrationDeadline: DateTime(nextYear.year, 8, 1),
      price: 120.00,
      website: 'https://www.bmw-berlin-marathon.com',
      organizer: 'SCC Events',
      categories: ['Marathon'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    RaceModel(
      id: '',
      name: 'London Marathon',
      location: 'London, UK',
      distance: '42.195 km',
      month: 'April',
      year: '${nextYear.year}',
      imageUrl: 'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=800',
      description:
          'Uma das 6 World Marathon Majors. Percurso histórico passando por pontos icônicos como Tower Bridge, Big Ben e Buckingham Palace.',
      status: 'Open',
      eventDate: DateTime(nextYear.year, 4, 21),
      registrationDeadline: DateTime(nextYear.year, 3, 1),
      price: 49.00,
      website: 'https://www.tcslondonmarathon.com',
      organizer: 'London Marathon Events',
      categories: ['Marathon'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    RaceModel(
      id: '',
      name: 'Tokyo Marathon',
      location: 'Tokyo, Japan',
      distance: '42.195 km',
      month: 'March',
      year: '${nextYear.year}',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      description:
          'Uma das 6 World Marathon Majors. Experiência única de correr em Tóquio com organização impecável e apoio incrível do público japonês.',
      status: 'Open',
      eventDate: DateTime(nextYear.year, 3, 3),
      registrationDeadline: DateTime(nextYear.year, 1, 15),
      price: 15000.00, // JPY (aproximadamente 150 USD)
      website: 'https://www.marathon.tokyo',
      organizer: 'Tokyo Marathon Foundation',
      categories: ['Marathon'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    // Corridas de 10K e 5K
    RaceModel(
      id: '',
      name: 'São Paulo 10K',
      location: 'São Paulo, SP',
      distance: '10 km',
      month: 'July',
      year: '${nextYear.year}',
      imageUrl: 'https://images.unsplash.com/photo-1513593771513-7b58b6c4af38?w=800',
      description:
          'Corrida de 10K no centro de São Paulo. Percurso rápido e acessível para iniciantes e corredores experientes.',
      status: 'Open',
      eventDate: DateTime(nextYear.year, 7, 8),
      registrationDeadline: DateTime(nextYear.year, 6, 25),
      price: 80.00,
      website: 'https://www.sp10k.com.br',
      organizer: 'Corpore',
      categories: ['10K', '5K'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    RaceModel(
      id: '',
      name: 'Corrida da Mulher',
      location: 'São Paulo, SP',
      distance: '5 km',
      month: 'March',
      year: '${nextYear.year}',
      imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=800',
      description:
          'Corrida exclusiva para mulheres em comemoração ao Dia Internacional da Mulher. Evento inclusivo e acolhedor.',
      status: 'Open',
      eventDate: DateTime(nextYear.year, 3, 8),
      registrationDeadline: DateTime(nextYear.year, 2, 25),
      price: 60.00,
      website: 'https://www.corridadamulher.com.br',
      organizer: 'Corpore',
      categories: ['5K'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),

    RaceModel(
      id: '',
      name: 'Night Run São Paulo',
      location: 'São Paulo, SP',
      distance: '10 km',
      month: 'October',
      year: '${now.year}',
      imageUrl: 'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=800',
      description:
          'Corrida noturna pelas ruas de São Paulo. Percurso iluminado com música e animação ao longo do trajeto.',
      status: 'Upcoming',
      eventDate: DateTime(now.year, 10, 20),
      registrationDeadline: DateTime(now.year, 10, 10),
      price: 90.00,
      website: 'https://www.nightrun.com.br',
      organizer: 'Corpore',
      categories: ['10K', '5K'],
      createdAt: now,
      updatedAt: now,
      isExternal: false,
    ),
  ];
}

