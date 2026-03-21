import 'package:core_domain/core_domain.dart';
import 'package:flutter/foundation.dart';

import '../contracts/session_repository.dart';

class DemoSessionRepository extends ChangeNotifier
    implements SessionRepository {
  DemoSessionRepository({required BackendProfile backendProfile})
    : _backendProfile = backendProfile;

  final BackendProfile _backendProfile;

  @override
  SessionSnapshot get currentSession => SessionSnapshot(
    user: const AppUserSummary(
      id: 'user-sol',
      displayName: 'Sol',
      email: 'sol@travelatlas.local',
      homeBase: 'Seoul, South Korea',
    ),
    isSignedIn: true,
    backendProfile: _backendProfile,
  );

  @override
  bool get supportsRemoteAuth => false;

  @override
  Future<SessionActionResult> signIn({
    required String email,
    required String password,
  }) async {
    return const SessionActionResult(
      success: false,
      message:
          'Remote auth is disabled in local-first mode. Add Supabase keys to enable sign-in.',
    );
  }

  @override
  Future<SessionActionResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return const SessionActionResult(
      success: false,
      message:
          'Remote auth is disabled in local-first mode. Add Supabase keys to enable account creation.',
    );
  }

  @override
  Future<void> signOut() async {}
}
