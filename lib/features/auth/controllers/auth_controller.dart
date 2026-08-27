import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../services/auth_service.dart';

class AuthController extends Notifier<bool> {
  AuthService get _auth => ref.read(authServiceProvider);

  @override
  bool build() => _auth.isLoggedIn;

  Future<AuthResult> login(String email, String password) async {
    final result = await _auth.login(email: email, password: password);
    if (result.ok) state = true;
    return result;
  }

  Future<void> logout() async {
    await _auth.logout();
    state = false;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(settingsRepositoryProvider));
});

final authControllerProvider =
    NotifierProvider<AuthController, bool>(AuthController.new);
