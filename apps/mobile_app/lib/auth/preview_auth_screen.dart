import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:feature_record/feature_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app_preferences.dart';

enum _AuthMode { welcome, login, signup }

class PreviewAuthScreen extends ConsumerStatefulWidget {
  const PreviewAuthScreen({super.key});

  @override
  ConsumerState<PreviewAuthScreen> createState() => _PreviewAuthScreenState();
}

class _PreviewAuthScreenState extends ConsumerState<PreviewAuthScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  _AuthMode _mode = _AuthMode.welcome;
  bool _submitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider);
    final theme = Theme.of(context);
    final palette = context.atlasPalette;
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';

    return Scaffold(
      body: AtlasBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactHeader = constraints.maxWidth < 390;
                final previewBadge = Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surfaceGlass.withValues(
                      alpha: palette.isLight ? 0.85 : 0.7,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: palette.outline.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    isKorean ? '프리뷰 로그인' : 'Preview Auth',
                    style: theme.textTheme.labelLarge,
                  ),
                );
                final controls = Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'ko', label: Text('KO')),
                        ButtonSegment(value: 'en', label: Text('EN')),
                      ],
                      selected: {prefs.locale.languageCode},
                      onSelectionChanged: (selection) {
                        ref
                            .read(appPreferencesProvider)
                            .setLanguageCode(selection.first);
                      },
                    ),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: palette.surfaceGlass.withValues(
                          alpha: palette.isLight ? 0.85 : 0.7,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: palette.outline.withValues(alpha: 0.25),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isKorean ? '시스템' : 'System',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ],
                );

                return Column(
                  children: [
                    if (compactHeader)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: previewBadge,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: controls,
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          previewBadge,
                          const Spacer(),
                          controls,
                        ],
                      ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, viewportConstraints) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: viewportConstraints.maxHeight,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 420,
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 280),
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    child: _mode == _AuthMode.welcome
                                        ? _buildWelcome(
                                            context,
                                            isKorean,
                                            palette,
                                          )
                                        : _buildForm(
                                            context,
                                            isKorean,
                                            palette,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(
    BuildContext context,
    bool isKorean,
    AtlasPalette palette,
  ) {
    final theme = Theme.of(context);
    final compactLayout = MediaQuery.sizeOf(context).height < 860;
    final photoStackSize = compactLayout ? 232.0 : 280.0;
    final photoScale = photoStackSize / 280;
    return Column(
      key: const ValueKey('welcome'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const RecordWordmark(logoSize: 64, fontSize: 34, spacing: 12),
        SizedBox(height: compactLayout ? 22 : 32),
        SizedBox(
          width: photoStackSize,
          height: photoStackSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _TravelPhotoCard(
                seed: 'tokyo',
                label: 'TOKYO',
                angle: -0.12,
                offset: Offset(-78 * photoScale, 32 * photoScale),
              ),
              _TravelPhotoCard(
                seed: 'paris',
                label: 'PARIS',
                angle: 0.18,
                offset: Offset(68 * photoScale, -24 * photoScale),
              ),
              _TravelPhotoCard(
                seed: 'new-york',
                label: 'NEW YORK',
                angle: -0.22,
                offset: Offset(-18 * photoScale, -76 * photoScale),
              ),
              _TravelPhotoCard(
                seed: 'seoul',
                label: 'SEOUL',
                angle: 0.12,
                offset: Offset(88 * photoScale, 42 * photoScale),
              ),
            ],
          ),
        ),
        SizedBox(height: compactLayout ? 14 : 20),
        Text(
          isKorean ? '당신의 여정을 기록하세요' : 'Record Your Journey',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: compactLayout ? 28 : 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: compactLayout ? 10 : 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            isKorean
                ? '개인용 3D 지구본에 모든 순간과 목적지를 담아보세요. 지금은 완성 전 프리뷰라 어떤 아이디로든 바로 들어갈 수 있습니다.'
                : 'Capture moments and destinations on your personal 3D globe. For now, preview mode lets you enter with any ID.',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: compactLayout ? 22 : 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() => _mode = _AuthMode.signup),
            style: FilledButton.styleFrom(
              backgroundColor: palette.isLight
                  ? const Color(0xFF1C1917)
                  : Colors.white,
              foregroundColor: palette.isLight
                  ? Colors.white
                  : const Color(0xFF1C1917),
            ),
            child: Text(isKorean ? '회원가입' : 'Sign up'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() => _mode = _AuthMode.login),
            child: Text(isKorean ? '로그인' : 'Login'),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, bool isKorean, AtlasPalette palette) {
    final theme = Theme.of(context);
    final isSignup = _mode == _AuthMode.signup;

    return Column(
      key: ValueKey(_mode.name),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _mode = _AuthMode.welcome),
                borderRadius: BorderRadius.circular(999),
                child: Ink(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: palette.surfaceGlass.withValues(
                      alpha: palette.isLight ? 0.88 : 0.64,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.outline.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Center(child: RecordLogo(size: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                isSignup
                    ? (isKorean ? '회원가입' : 'Sign up')
                    : (isKorean ? '로그인' : 'Login'),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          AtlasPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _identifierController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: isKorean ? '아이디' : 'ID',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                if (isSignup) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nicknameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: isKorean ? '닉네임' : 'Nickname',
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: isKorean ? '비밀번호' : 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted.withValues(
                      alpha: palette.isLight ? 0.78 : 0.86,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    isSignup
                        ? (isKorean
                              ? '아직은 실제 회원가입이 아니라 프리뷰 계정을 바로 만듭니다. 아이디와 닉네임만 입력해도 됩니다.'
                              : 'This is still preview auth. A temporary account is created immediately from your ID and nickname.')
                        : (isKorean
                              ? '비밀번호는 아직 검사하지 않습니다. 아이디만 입력해도 바로 로그인됩니다.'
                              : 'Passwords are ignored for now. Any non-empty ID signs you in.'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      isSignup
                          ? (isKorean ? '바로 시작하기' : 'Start Now')
                          : (isKorean ? '계속하기' : 'Continue'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _mode = isSignup ? _AuthMode.login : _AuthMode.signup;
                });
              },
              child: Text(
                isSignup
                    ? (isKorean ? '이미 계정이 있으신가요?' : 'Already have an account?')
                    : (isKorean ? '계정이 없으신가요?' : 'Don’t have an account?'),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _submit() async {
    final identifier = _identifierController.text.trim();
    final locale = Localizations.localeOf(context).languageCode;
    if (identifier.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locale == 'ko' ? '아이디를 입력해 주세요.' : 'Enter any ID to continue.',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final sessionRepository = ref.read(sessionRepositoryProvider);
    final result = _mode == _AuthMode.signup
        ? await sessionRepository.signUp(
            email: identifier,
            password: _passwordController.text,
            displayName: _nicknameController.text.trim().isEmpty
                ? identifier
                : _nicknameController.text.trim(),
          )
        : await sessionRepository.signIn(
            email: identifier,
            password: _passwordController.text,
          );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (!result.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }
}

class _TravelPhotoCard extends StatelessWidget {
  const _TravelPhotoCard({
    required this.seed,
    required this.label,
    required this.angle,
    required this.offset,
  });

  final String seed;
  final String label;
  final double angle;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 108,
          height: 136,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
          decoration: BoxDecoration(
            color: palette.isLight ? Colors.white : const Color(0xFFFEFCF7),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE7E5E4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.network(
                    'https://picsum.photos/seed/$seed/220/220',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -14,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF78716C),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
