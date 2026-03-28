import 'dart:math' as math;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../globe/globe.dart';
import '../globe_engine/record_globe_engine.dart';
import '../globe_engine/renderers/three_js_record_globe_renderer.dart';
import '../components/record_wordmark.dart';
import '../i18n/record_strings.dart';
import '../providers/record_provider.dart';
import 'record_country_detail_screen.dart';

class RecordHomeScreen extends ConsumerStatefulWidget {
  const RecordHomeScreen({
    super.key,
    this.forceGlobeFallback = false,
    this.isGlobeAvailabilityPending = false,
    this.onOpenProfile,
    this.onRetryGlobe3D,
  });

  final bool forceGlobeFallback;
  final bool isGlobeAvailabilityPending;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onRetryGlobe3D;

  @override
  ConsumerState<RecordHomeScreen> createState() => _RecordHomeScreenState();
}

class _RecordHomeScreenState extends ConsumerState<RecordHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterAnim;
  late final RecordGlobeViewModel _globeViewModel;
  final RecordGlobeEngine _globeEngine = const ThreeJsRecordGlobeRenderer();

  ProviderSubscription<RecordGlobeSceneSpec>? _globeSceneSubscription;
  Brightness? _sceneBrightness;
  bool _openingCountry = false;

  @override
  void initState() {
    super.initState();
    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _globeViewModel = RecordGlobeViewModel()
      ..addListener(_handleGlobeStateChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_sceneBrightness == brightness) {
      return;
    }

    _sceneBrightness = brightness;
    _globeSceneSubscription?.close();

    final provider = recordGlobeSceneSpecProvider(brightness);
    _globeViewModel.syncScene(ref.read(provider));
    _globeSceneSubscription = ref.listenManual<RecordGlobeSceneSpec>(
      provider,
      (_, next) => _globeViewModel.syncScene(next),
    );
  }

  void _handleGlobeStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _enterAnim.dispose();
    _globeSceneSubscription?.close();
    _globeViewModel
      ..removeListener(_handleGlobeStateChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final user = ref.watch(recordUserProvider);
    final trips = ref.watch(recordTripsProvider);
    final theme = Theme.of(context);
    final globeViewModel = _globeViewModel;
    final globeState = globeViewModel.state;
    final globeSceneSpec = globeState.sceneSpec;
    final globeAssetSet = globeSceneSpec == null
        ? null
        : ref.watch(recordGlobeAssetSetProvider(globeSceneSpec.style));
    final selectedCountryCode = globeState.selectedCountryCode;
    final selectedProjection = selectedCountryCode == null
        ? null
        : ref.watch(recordCountryProjectionProvider(selectedCountryCode));
    final hasTrips = trips.isNotEmpty;
    final isSheetVisible = hasTrips &&
        selectedProjection != null &&
        globeState.isSheetOpen &&
        !_openingCountry;
    final showGlobeAvailabilityPending =
        hasTrips && widget.isGlobeAvailabilityPending;
    final showGlobeFallback = hasTrips && widget.forceGlobeFallback;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AtlasBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: _RecordHomeSpaceBackdrop(
                isDark: theme.brightness == Brightness.dark,
              ),
            ),
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compactLayout = constraints.maxHeight < 780;
                  final contentWidth = constraints.maxWidth - 40;
                  final bottomClearance = compactLayout
                      ? (isSheetVisible ? 224.0 : 108.0)
                      : (isSheetVisible ? 244.0 : 124.0);
                  final globeHeightBudget = math.max(
                    compactLayout ? 260.0 : 312.0,
                    constraints.maxHeight -
                        bottomClearance -
                        (compactLayout ? 96.0 : 112.0),
                  );
                  final globeSize = hasTrips
                      ? math.min(
                          contentWidth * (compactLayout ? 0.92 : 0.96),
                          compactLayout
                              ? math.min(globeHeightBudget, 340.0)
                              : math.min(globeHeightBudget, 432.0),
                        )
                      : 0.0;

                  return AnimatedBuilder(
                    animation: _enterAnim,
                    builder: (context, child) {
                      final value = Curves.easeOutCubic.transform(
                        _enterAnim.value,
                      );
                      return Transform.translate(
                        offset: Offset(0, 18 * (1 - value)),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const _HeaderButton(
                                icon: Icons.dark_mode_rounded,
                              ),
                              Expanded(
                                child: Center(
                                  child: Transform.translate(
                                    offset: const Offset(-4, 0),
                                    child: const RecordWordmark(
                                      logoSize: 24,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              _HeaderButton(
                                onPressed: widget.onOpenProfile,
                                child: _ProfileBadge(name: user.name),
                              ),
                            ],
                          ),
                          SizedBox(height: compactLayout ? 12 : 20),
                          if (hasTrips)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: compactLayout ? 8 : 16,
                                  bottom: bottomClearance,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      compactLayout ? -10 : -18,
                                    ),
                                    child: showGlobeAvailabilityPending
                                        ? _RecordHomeGlobeAvailabilityCard(
                                            strings: strings,
                                            globeSize: globeSize,
                                          )
                                        : showGlobeFallback
                                            ? _RecordHomeGlobeFallback(
                                                strings: strings,
                                                isDark: theme.brightness ==
                                                    Brightness.dark,
                                                countries: globeState
                                                        .sceneSpec?.countries ??
                                                    const [],
                                                globeSize: globeSize,
                                                onOpenCountry: (countryCode) {
                                                  _openCountryDetails(
                                                    globeViewModel,
                                                    countryCode,
                                                  );
                                                },
                                                onRetry3D:
                                                    widget.onRetryGlobe3D,
                                              )
                                            : RecordGlobeViewport(
                                                engine: _globeEngine,
                                                state: globeState,
                                                assetSet: globeAssetSet,
                                                size: globeSize,
                                                loadingBuilder: (context) =>
                                                    const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                  ),
                                                ),
                                                onCountrySelected:
                                                    (countryCode) {
                                                  if (countryCode == null) {
                                                    globeViewModel
                                                        .clearSelection();
                                                    return;
                                                  }
                                                  switch (
                                                      globeViewModel.tapCountry(
                                                    countryCode,
                                                  )) {
                                                    case RecordGlobeTapAction
                                                          .previewCountry:
                                                      globeViewModel
                                                          .pinFocusedCountry();
                                                      break;
                                                    case RecordGlobeTapAction
                                                          .enterCountry:
                                                      _openCountryDetails(
                                                        globeViewModel,
                                                        countryCode,
                                                      );
                                                      break;
                                                    case RecordGlobeTapAction
                                                          .clearSelection:
                                                      globeViewModel
                                                          .clearSelection();
                                                      break;
                                                  }
                                                },
                                              ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: bottomClearance,
                                ),
                                child: Center(
                                  child: AtlasEmptyState(
                                    title: strings.text('home.empty'),
                                    message: strings.text('nav.create'),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isSheetVisible)
              Positioned(
                left: 20,
                right: 20,
                bottom: _compactBottomPadding(context),
                child: SafeArea(
                  top: false,
                  child: Builder(
                    builder: (context) {
                      final spotlight = selectedProjection;
                      return RecordCountryBottomSheet(
                        spotlight: spotlight,
                        strings: strings,
                        onOpen: () => _openCountryDetails(
                          globeViewModel,
                          spotlight.code,
                        ),
                        onClose: () {
                          globeViewModel.clearSelection();
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCountryDetails(
    RecordGlobeViewModel globeViewModel,
    String countryCode,
  ) async {
    if (_openingCountry) {
      return;
    }

    setState(() {
      _openingCountry = true;
    });
    globeViewModel.markCountryEntered(countryCode);
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 620),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            RecordCountryDetailScreen(countryCode: countryCode),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            ),
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _openingCountry = false;
    });
    globeViewModel.clearSelection();
  }

  double _compactBottomPadding(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return bottomInset > 0 ? 90 : 84;
  }
}

class _RecordHomeGlobeFallback extends StatelessWidget {
  const _RecordHomeGlobeFallback({
    required this.strings,
    required this.isDark,
    required this.countries,
    required this.globeSize,
    required this.onOpenCountry,
    this.onRetry3D,
  });

  final RecordStrings strings;
  final bool isDark;
  final List<RecordGlobeCountry> countries;
  final double globeSize;
  final ValueChanged<String> onOpenCountry;
  final VoidCallback? onRetry3D;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    final quickCountries = countries.take(6).toList(growable: false);
    final previewSize = math.min(globeSize * 0.62, 224.0);
    final previewAsset = isDark
        ? 'assets/globe/earth_storybook_dark.png'
        : 'assets/globe/earth_storybook_light.png';

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: AtlasPanel(
          key: const Key('record-home-globe-fallback'),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Container(
                  width: previewSize,
                  height: previewSize,
                  color: palette.surfaceMuted,
                  child: Image.asset(
                    previewAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              palette.surfaceMuted,
                              palette.surfaceGlass,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.public_rounded,
                          size: math.max(56, previewSize * 0.28),
                          color: palette.accentSoft,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                strings.text('home.globeUnavailableTitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                strings.text('home.globeUnavailableSubtitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (quickCountries.isNotEmpty) ...[
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    strings.text('home.quickCountries'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final country in quickCountries)
                      ActionChip(
                        key: Key('record-home-quick-country-${country.code}'),
                        avatar: const Icon(Icons.map_rounded, size: 18),
                        label: Text(country.name),
                        onPressed: () => onOpenCountry(country.code),
                      ),
                  ],
                ),
              ],
              if (onRetry3D != null) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  key: const Key('record-home-retry-3d'),
                  onPressed: onRetry3D,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(strings.text('home.retry3d')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordHomeGlobeAvailabilityCard extends StatelessWidget {
  const _RecordHomeGlobeAvailabilityCard({
    required this.strings,
    required this.globeSize,
  });

  final RecordStrings strings;
  final double globeSize;

  @override
  Widget build(BuildContext context) {
    final previewSize = math.min(globeSize * 0.56, 208.0);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: AtlasPanel(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: previewSize,
              height: previewSize,
              child: const Center(
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(strokeWidth: 2.6),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.text('home.globeAvailabilityCheckingTitle'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              strings.text('home.globeAvailabilityCheckingSubtitle'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({this.onPressed, this.icon, this.child});

  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    final content = child ??
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: palette.surfaceGlass.withValues(
            alpha: palette.isLight ? 0.84 : 0.58,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: palette.outline.withValues(alpha: 0.5)),
        ),
        child: Center(child: content),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initials =
        trimmed.isEmpty ? 'R' : String.fromCharCode(trimmed.runes.first);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _RecordHomeSpaceBackdrop extends StatelessWidget {
  const _RecordHomeSpaceBackdrop({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: isDark
                      ? const Alignment(-0.14, -0.82)
                      : const Alignment(0.0, -0.95),
                  radius: isDark ? 1.12 : 0.96,
                  colors: isDark
                      ? const [
                          Color(0x2218B8D6),
                          Color(0x140F4B7F),
                          Color(0x00000000),
                        ]
                      : const [
                          Color(0x24C8E0FF),
                          Color(0x10E7F2FF),
                          Color(0x00000000),
                        ],
                  stops: const [0, 0.52, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -40,
            child: _SpaceNebula(
              size: isDark ? 320 : 240,
              color: isDark ? const Color(0x5522D3FF) : const Color(0x44C7E2FF),
            ),
          ),
          Positioned(
            right: -100,
            bottom: 120,
            child: _SpaceNebula(
              size: isDark ? 360 : 260,
              color: isDark ? const Color(0x443C2B91) : const Color(0x28FFFFFF),
            ),
          ),
          if (isDark)
            const Positioned.fill(
              child: CustomPaint(painter: _HomeStarfieldPainter()),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [
                          Color(0x00000000),
                          Color(0x0D030816),
                          Color(0x38010713),
                        ]
                      : const [
                          Color(0x00FFFFFF),
                          Color(0x00FFFFFF),
                          Color(0x14E6F1FF),
                        ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceNebula extends StatelessWidget {
  const _SpaceNebula({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.14), Colors.transparent],
          stops: const [0, 0.42, 1],
        ),
      ),
    );
  }
}

class _HomeStarfieldPainter extends CustomPainter {
  const _HomeStarfieldPainter();

  static const _stars = <({double x, double y, double radius, double alpha})>[
    (x: 0.08, y: 0.12, radius: 1.7, alpha: 0.44),
    (x: 0.16, y: 0.24, radius: 1.2, alpha: 0.32),
    (x: 0.28, y: 0.08, radius: 1.6, alpha: 0.40),
    (x: 0.46, y: 0.18, radius: 1.8, alpha: 0.42),
    (x: 0.62, y: 0.10, radius: 1.3, alpha: 0.30),
    (x: 0.74, y: 0.22, radius: 1.4, alpha: 0.36),
    (x: 0.88, y: 0.14, radius: 1.9, alpha: 0.46),
    (x: 0.91, y: 0.32, radius: 1.1, alpha: 0.28),
    (x: 0.14, y: 0.42, radius: 1.3, alpha: 0.32),
    (x: 0.33, y: 0.36, radius: 1.4, alpha: 0.34),
    (x: 0.56, y: 0.44, radius: 1.5, alpha: 0.36),
    (x: 0.80, y: 0.40, radius: 1.2, alpha: 0.30),
    (x: 0.10, y: 0.64, radius: 1.5, alpha: 0.36),
    (x: 0.26, y: 0.72, radius: 1.1, alpha: 0.28),
    (x: 0.48, y: 0.66, radius: 1.6, alpha: 0.42),
    (x: 0.67, y: 0.78, radius: 1.2, alpha: 0.30),
    (x: 0.82, y: 0.62, radius: 1.8, alpha: 0.44),
    (x: 0.92, y: 0.86, radius: 1.5, alpha: 0.34),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in _stars) {
      final center = Offset(size.width * star.x, size.height * star.y);
      final glow = Paint()
        ..color = Colors.white.withValues(alpha: star.alpha * 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final core = Paint()..color = Colors.white.withValues(alpha: star.alpha);
      canvas.drawCircle(center, star.radius * 2.2, glow);
      canvas.drawCircle(center, star.radius, core);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeStarfieldPainter oldDelegate) => false;
}
