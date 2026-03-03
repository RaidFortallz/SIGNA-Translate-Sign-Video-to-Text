import 'package:signa_video_to_text/features/domain/repositories/auth_repository.dart';

class SignInUsecase {
  final IAuthRepository repo;

  SignInUsecase({required this.repo});

  Future<void> execute() async { 
    await repo.signInAnonimously();
  }
}
