import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
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
    final theme = Theme.of(context);

    return AtlasBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            AtlasHeroPanel(
              eyebrow: 'Profile & sync',
              title: session.isSignedIn
                  ? 'Your atlas should feel owned, recoverable, and calm.'
                  : 'Account access should stay optional until you need cross-device sync.',
              message: session.isSignedIn
                  ? 'This screen is the trust layer: who owns the data, what is waiting to sync, and what needs attention next.'
                  : 'You can keep writing locally first. Sign in only when you want restore, backup, and multi-device continuity.',
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AtlasStatusPill(
                    label: sync.bannerTitle,
                    color: _syncTone(sync.severity),
                    icon: Icons.sync_rounded,
                  ),
                  const SizedBox(height: 16),
                  AtlasOrbitalGraphic(
                    size: 92,
                    glowColor: _syncTone(sync.severity),
                  ),
                ],
              ),
              metrics: [
                AtlasMiniMetric(
                  label: 'Pending changes',
                  value: '${sync.pendingChanges}',
                  icon: Icons.compare_arrows_rounded,
                ),
                AtlasMiniMetric(
                  label: 'Uploads',
                  value: '${sync.pendingUploads}',
                  icon: Icons.cloud_upload_rounded,
                ),
                AtlasMiniMetric(
                  label: 'Last sync',
                  value: _syncMetric(sync),
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),
            AtlasPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AtlasSectionHeader(
                    title: 'Identity',
                    subtitle: session.isSignedIn
                        ? 'The signed-in account is the owner of synced memories and uploads.'
                        : 'Local-first mode is active. Remote account ownership is not required yet.',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13253B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF21405F)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person_rounded),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.user.displayName,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.user.email,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.user.homeBase,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        AtlasStatusPill(
                          label: session.isSignedIn
                              ? 'Signed in'
                              : 'Local only',
                          color: session.isSignedIn
                              ? const Color(0xFF67E2B7)
                              : const Color(0xFFFFD37A),
                        ),
                      ],
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
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      AtlasMetricChip(
                        label: 'Pending changes',
                        value: '${sync.pendingChanges}',
                      ),
                      AtlasMetricChip(
                        label: 'Pending uploads',
                        value: '${sync.pendingUploads}',
                      ),
                    ],
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
                          label: const Text('Run sync now'),
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
            const AtlasSectionHeader(
              title: 'How this stays calm offline',
              subtitle:
                  'A premium travel app should explain resilience without exposing backend mechanics.',
            ),
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
            const SizedBox(height: 20),
            AtlasSectionHeader(
              title: 'Recommended next step',
              subtitle: session.isSignedIn
                  ? 'Use this area for explicit recovery actions only when something needs attention.'
                  : 'Keep local mode if you are still shaping the product. Connect remote auth later.',
            ),
            const SizedBox(height: 12),
            AtlasActionTile(
              icon: session.isSignedIn
                  ? Icons.verified_user_rounded
                  : Icons.lock_outline_rounded,
              title: session.isSignedIn
                  ? 'Account is ready'
                  : 'Remote auth is not required yet',
              subtitle: session.isSignedIn
                  ? 'Your next action should be writing and importing, not babysitting sync.'
                  : 'You can continue using the app locally until shared sync is worth turning on.',
              onTap: session.backendProfile.remoteSyncEnabled
                  ? widget.onSyncNow
                  : null,
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

String _syncMetric(SyncSnapshot sync) =>
    sync.lastSyncedAt == null ? 'Waiting' : formatShortDate(sync.lastSyncedAt!);
