import 'package:flutter/foundation.dart';
import 'package:core_domain/core_domain.dart';

abstract class SessionRepository extends ChangeNotifier {
  SessionSnapshot get currentSession;

  bool get supportsRemoteAuth;

  Future<SessionActionResult> signIn({
    required String email,
    required String password,
  });

  Future<SessionActionResult> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();
}
