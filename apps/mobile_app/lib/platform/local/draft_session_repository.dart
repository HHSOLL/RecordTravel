import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftSessionRepository extends ChangeNotifier
    implements SessionRepository {
  DraftSessionRepository({required BackendProfile backendProfile})
    : _backendProfile = backendProfile {
    _load();
  }

  static const _idKey = 'travel_atlas.preview_user.id';
  static const _displayNameKey = 'travel_atlas.preview_user.display_name';
  static const _emailKey = 'travel_atlas.preview_user.email';
  static const _homeBaseKey = 'travel_atlas.preview_user.home_base';

  final BackendProfile _backendProfile;
  AppUserSummary? _user;

  @override
  SessionSnapshot get currentSession => SessionSnapshot(
    user:
        _user ??
        const AppUserSummary(
          id: 'guest',
          displayName: 'Preview Guest',
          email: 'preview@travelatlas.local',
          homeBase: 'Local-first travel archive',
        ),
    isSignedIn: _user != null,
    backendProfile: _backendProfile,
  );

  @override
  bool get supportsRemoteAuth => false;

  @override
  Future<SessionActionResult> signIn({
    required String email,
    required String password,
  }) async {
    final identifier = email.trim();
    if (identifier.isEmpty) {
      return const SessionActionResult(
        success: false,
        message: 'Enter any ID to continue in preview mode.',
      );
    }
    _user = _userFromIdentifier(identifier);
    await _persistUser();
    notifyListeners();
    return const SessionActionResult(
      success: true,
      message: 'Preview login complete.',
    );
  }

  @override
  Future<SessionActionResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final identifier = email.trim();
    if (identifier.isEmpty) {
      return const SessionActionResult(
        success: false,
        message: 'Enter any ID to continue in preview mode.',
      );
    }
    _user = _userFromIdentifier(
      identifier,
      displayNameOverride: displayName?.trim(),
    );
    await _persistUser();
    notifyListeners();
    return const SessionActionResult(
      success: true,
      message: 'Preview account created.',
    );
  }

  @override
  Future<void> signOut() async {
    _user = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_idKey);
      await prefs.remove(_displayNameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_homeBaseKey);
    } catch (_) {
      // Keep logout local even if persistence cleanup fails.
    }
    notifyListeners();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_idKey);
      final displayName = prefs.getString(_displayNameKey);
      final email = prefs.getString(_emailKey);
      final homeBase = prefs.getString(_homeBaseKey);
      if (id != null &&
          displayName != null &&
          email != null &&
          homeBase != null) {
        _user = AppUserSummary(
          id: id,
          displayName: displayName,
          email: email,
          homeBase: homeBase,
        );
        notifyListeners();
      }
    } catch (_) {
      // Shared preferences are optional in tests and preview environments.
    }
  }

  AppUserSummary _userFromIdentifier(
    String identifier, {
    String? displayNameOverride,
  }) {
    final normalizedEmail = identifier.contains('@')
        ? identifier
        : '${_slugify(identifier)}@preview.local';
    final fallbackName = identifier.contains('@')
        ? identifier.split('@').first
        : identifier;
    final displayName =
        (displayNameOverride != null && displayNameOverride.isNotEmpty)
        ? displayNameOverride
        : fallbackName;
    final slug = _slugify(displayName);
    return AppUserSummary(
      id: 'preview-$slug',
      displayName: displayName,
      email: normalizedEmail,
      homeBase: 'record Preview',
    );
  }

  String _slugify(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), '-');
    final filtered = normalized.replaceAll(RegExp(r'[^a-zA-Z0-9가-힣_-]'), '');
    return filtered.isEmpty ? 'guest' : filtered.toLowerCase();
  }

  Future<void> _persistUser() async {
    final user = _user;
    if (user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_idKey, user.id);
      await prefs.setString(_displayNameKey, user.displayName);
      await prefs.setString(_emailKey, user.email);
      await prefs.setString(_homeBaseKey, user.homeBase);
    } catch (_) {
      // Keep preview auth functional even when persistence is unavailable.
    }
  }
}
