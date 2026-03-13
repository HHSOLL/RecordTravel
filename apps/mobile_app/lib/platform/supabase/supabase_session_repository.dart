import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSessionRepository extends ChangeNotifier
    implements SessionRepository {
  SupabaseSessionRepository({
    required SupabaseClient client,
    required BackendProfile backendProfile,
  }) : _client = client,
       _backendProfile = backendProfile {
    _subscription = _client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  final SupabaseClient _client;
  final BackendProfile _backendProfile;
  late final StreamSubscription<AuthState> _subscription;

  @override
  SessionSnapshot get currentSession {
    final session = _client.auth.currentSession;
    final user = session?.user;
    return SessionSnapshot(
      user: AppUserSummary(
        id: user?.id ?? 'guest',
        displayName: _displayNameFor(user),
        email: user?.email ?? 'Not signed in',
        homeBase: _homeBaseFor(user),
      ),
      isSignedIn: user != null,
      backendProfile: _backendProfile,
    );
  }

  @override
  bool get supportsRemoteAuth => true;

  @override
  Future<SessionActionResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      notifyListeners();
      return const SessionActionResult(
        success: true,
        message: 'Signed in successfully.',
      );
    } on AuthException catch (error) {
      return SessionActionResult(success: false, message: error.message);
    } catch (_) {
      return const SessionActionResult(
        success: false,
        message: 'Sign-in failed. Check your Supabase project settings.',
      );
    }
  }

  @override
  Future<SessionActionResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (displayName != null && displayName.trim().isNotEmpty)
            'display_name': displayName.trim(),
        },
      );
      notifyListeners();
      return const SessionActionResult(
        success: true,
        message:
            'Account created. If email confirmation is enabled, verify your inbox and sign in again.',
      );
    } on AuthException catch (error) {
      return SessionActionResult(success: false, message: error.message);
    } catch (_) {
      return const SessionActionResult(
        success: false,
        message: 'Account creation failed. Check your Supabase auth setup.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    notifyListeners();
  }

  String _displayNameFor(User? user) {
    final value =
        user?.userMetadata?['display_name'] ?? user?.userMetadata?['name'];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (user?.email case final email?) {
      return email.split('@').first;
    }
    return 'Guest mode';
  }

  String _homeBaseFor(User? user) {
    final value = user?.userMetadata?['home_base'];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return 'Local-first travel archive';
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
