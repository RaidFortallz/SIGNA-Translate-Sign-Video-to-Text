import 'package:signa_video_to_text/features/data/data_sources/firebase_data_sources.dart';
import 'package:signa_video_to_text/features/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseDataSources dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<void> signInAnonimously() async {
    await dataSource.signInAnonimously();
  }

  @override
  String? getUserId() {
    return dataSource.getCurrentUid();
  }
}
