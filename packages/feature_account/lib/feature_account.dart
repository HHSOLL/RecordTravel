import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key, required this.onSyncNow});

  final VoidCallback onSyncNow;

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _displayNameController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncSnapshotProvider);
    final session = ref.watch(sessionSnapshotProvider);
    final sessionRepository = ref.watch(sessionRepositoryProvider);

    return AtlasBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            const AtlasSectionHeader(
              title: 'Profile & sync',
              subtitle:
                  'A production-grade app still needs clear account ownership, recoverable sessions, and calm sync feedback.',
            ),
            const SizedBox(height: 20),
            AtlasPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_rounded),
                    ),
                    title: Text(session.user.displayName),
                    subtitle: Text(
                      '${session.user.email}\n${session.user.homeBase}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SyncBanner(
                    title: sync.bannerTitle,
                    message:
                        '${sync.bannerMessage}\nLast synced: ${formatRelativeSync(sync.lastSyncedAt)}',
                    tone: _syncTone(sync.severity),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Backend profile: ${session.backendProfile.label}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.backendProfile.notes,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (session.isSignedIn) ...[
                    Text(
                      'Session restore is automatic once Supabase auth is configured. Sign out here only when you intentionally want to clear the local session.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: session.backendProfile.remoteSyncEnabled
                              ? widget.onSyncNow
                              : null,
                          icon: const Icon(Icons.sync_rounded),
                          label: const Text('Sync now'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isSubmitting ? null : _handleSignOut,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ] else if (sessionRepository.supportsRemoteAuth) ...[
                    const SizedBox(height: 4),
                    _AuthForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      displayNameController: _displayNameController,
                      isSubmitting: _isSubmitting,
                      onSignIn: _handleSignIn,
                      onSignUp: _handleSignUp,
                    ),
                  ] else ...[
                    Text(
                      'Remote auth is intentionally disabled in local-first mode. Add Supabase runtime keys when you want sign-in and remote sync.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: widget.onSyncNow,
                      icon: const Icon(Icons.sync_problem_rounded),
                      label: const Text('Retry local sync status'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            const AtlasSectionHeader(title: 'Offline behavior'),
            const SizedBox(height: 12),
            const AtlasPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This app saves first and syncs later.'),
                  SizedBox(height: 8),
                  Text(
                    'Pending uploads should never block writing memories, editing notes, or revisiting trip details.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Enter both email and password.');
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(sessionRepositoryProvider)
        .signIn(email: email, password: password);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showMessage(result.message);
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Enter email and password before creating an account.');
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(sessionRepositoryProvider)
        .signUp(
          email: email,
          password: password,
          displayName: displayName.isEmpty ? null : displayName,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showMessage(result.message);
  }

  Future<void> _handleSignOut() async {
    setState(() => _isSubmitting = true);
    await ref.read(sessionRepositoryProvider).signOut();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showMessage('Signed out.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.emailController,
    required this.passwordController,
    required this.displayNameController,
    required this.isSubmitting,
    required this.onSignIn,
    required this.onSignUp,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController displayNameController;
  final bool isSubmitting;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sign in to restore your session and sync travel records across devices.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          enabled: !isSubmitting,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'you@example.com',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          enabled: !isSubmitting,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: displayNameController,
          enabled: !isSubmitting,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          decoration: const InputDecoration(
            labelText: 'Display name (for sign up)',
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: isSubmitting ? null : onSignIn,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: const Text('Sign in'),
            ),
            OutlinedButton.icon(
              onPressed: isSubmitting ? null : onSignUp,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Create account'),
            ),
          ],
        ),
      ],
    );
  }
}

Color _syncTone(SyncSeverity severity) => switch (severity) {
  SyncSeverity.synced => const Color(0xFF67E2B7),
  SyncSeverity.syncing => const Color(0xFF8DEBFF),
  SyncSeverity.pending => const Color(0xFFFFD37A),
  SyncSeverity.attention => const Color(0xFFFF8B8B),
};
