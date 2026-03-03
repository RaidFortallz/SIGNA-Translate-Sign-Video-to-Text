abstract class IAuthRepository {
  Future<void> signInAnonimously();

  String? getUserId();
}