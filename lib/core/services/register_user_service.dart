import '../models/user_model.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class RegisterUserService {
  final AuthRepository _authRepository;

  RegisterUserService({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  Future<RegisterResult> call({
    required String name,
    required String email,
    required String password,
    required String experience,
  }) async {
    try {
      // 1. Criar usuário no Firebase Auth
      final userCredential = await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return RegisterResult(
          success: false,
          message: 'Erro ao criar usuário',
        );
      }

      // 2. Atualizar o nome do usuário no Firebase Auth
      await _authRepository.updateUserDisplayName(name);

      // 3. Criar documento do usuário no Firestore
      final userModel = UserModel(
        id: user.uid,
        name: name,
        email: email,
        experience: experience,
        profile: 'atleta', // Todos começam como atleta
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _authRepository.createUserDocument(userModel);

      return RegisterResult(
        success: true,
        message: 'Usuário criado com sucesso!',
        user: userModel,
      );
    } catch (e) {
      return RegisterResult(
        success: false,
        message: e.toString(),
      );
    }
  }
}

class RegisterResult {
  final bool success;
  final String message;
  final UserModel? user;

  RegisterResult({
    required this.success,
    required this.message,
    this.user,
  });
}
