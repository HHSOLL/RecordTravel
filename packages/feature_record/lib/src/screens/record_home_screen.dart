import 'dart:math' as math;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../globe/globe.dart';
import '../globe_engine/record_globe_engine.dart';
import '../globe_engine/record_globe_engine_controller.dart';
import '../globe_engine/record_globe_engine_state.dart';
import '../globe_engine/renderers/three_js_record_globe_renderer.dart';
import '../components/record_wordmark.dart';
import '../i18n/record_strings.dart';
import '../providers/record_provider.dart';
import 'record_country_map_screen.dart';

class RecordHomeScreen extends ConsumerStatefulWidget {
  const RecordHomeScreen({
    super.key,
    this.onOpenProfile,
  });

  final VoidCallback? onOpenProfile;

  @override
  ConsumerState<RecordHomeScreen> createState() => _RecordHomeScreenState();
}

class _RecordHomeScreenState extends ConsumerState<RecordHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterAnim;
  late final RecordGlobeViewModel _globeViewModel;
  late final RecordGlobeEngineController _globeEngineController;
  final RecordGlobeEngine _globeEngine = const ThreeJsRecordGlobeRenderer();

  bool _openingCountry = false;
  String? _lastSceneSignature;

  @override
  void initState() {
    super.initState();
    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _globeViewModel = RecordGlobeViewModel();
    _globeEngineController = RecordGlobeEngineController(
      initialState: RecordGlobeEngineState.initial().copyWith(
        camera: const RecordGlobeCameraState(yaw: 0.3, pitch: -0.18, zoom: 1),
      ),
    );
  }

  @override
  void dispose() {
    _enterAnim.dispose();
    _globeViewModel.dispose();
    _globeEngineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final user = ref.watch(recordUserProvider);
    final trips = ref.watch(recordTripsProvider);
    final theme = Theme.of(context);
    final globeScene = ref.watch(recordGlobeSceneSpecProvider(theme.brightness));
    _syncGlobeScene(globeScene);
    final selectedCountryCode = _globeViewModel.state.selectedCountryCode;
    final selectedSpotlight = selectedCountryCode == null
        ? null
        : ref.watch(recordCountrySpotlightProvider(selectedCountryCode));
    final hasTrips = trips.isNotEmpty;
    final isSheetVisible =
        hasTrips &&
        selectedSpotlight != null &&
        _globeViewModel.state.isSheetOpen &&
        !_openingCountry;

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
                                    child: RecordGlobeViewport(
                                      engine: _globeEngine,
                                      engineController: _globeEngineController,
                                      viewModel: _globeViewModel,
                                      size: globeSize,
                                      loadingBuilder: (context) => const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                      errorBuilder: (context, message) => Center(
                                        child: Text(
                                          message,
                                          style: theme.textTheme.bodyMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      onCountrySelected: (countryCode) {
                                        setState(() {
                                          if (countryCode == null) {
                                            _globeViewModel.closeSheet();
                                          } else {
                                            _globeViewModel.openSheet();
                                          }
                                        });
                                      },
                                      onCountryFocused: (_) => setState(() {}),
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
                      final spotlight = selectedSpotlight;
                      return RecordCountryBottomSheet(
                        spotlight: spotlight,
                        strings: strings,
                        onOpen: () => _openCountryDetails(spotlight.code),
                        onClose: () {
                          setState(() {
                            _globeViewModel.selectCountry(null);
                            _globeViewModel.focusCountry(null);
                            _globeViewModel.closeSheet();
                          });
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

  Future<void> _openCountryDetails(String countryCode) async {
    if (_openingCountry) {
      return;
    }

    setState(() {
      _openingCountry = true;
      _globeViewModel.selectCountry(countryCode);
      _globeViewModel.focusCountry(countryCode);
      _globeViewModel.openSheet();
    });
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 620),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            RecordCountryMapScreen(countryCode: countryCode),
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
      _globeViewModel.selectCountry(null);
      _globeViewModel.focusCountry(null);
      _globeViewModel.closeSheet();
    });
  }

  void _syncGlobeScene(RecordGlobeSceneSpec sceneSpec) {
    final signature = [
      sceneSpec.style.name,
      sceneSpec.initialCountryCode ?? '',
      for (final country in sceneSpec.countries)
        '${country.code}:${country.visitCount}:${country.anchorLatitude.toStringAsFixed(3)}:${country.anchorLongitude.toStringAsFixed(3)}',
    ].join('|');

    if (_lastSceneSignature == signature) {
      return;
    }
    _lastSceneSignature = signature;

    final selectedCountryCode =
        _globeViewModel.state.selectedCountryCode ?? sceneSpec.initialCountryCode;
    final focusedCountryCode =
        _globeViewModel.state.focusedCountryCode ?? selectedCountryCode;

    _globeViewModel.setScene(
      _globeViewModel.state.copyWith(
        isLoading: false,
        isReady: true,
        errorMessage: null,
        isSheetOpen: selectedCountryCode != null,
        selectedCountryCode: selectedCountryCode,
        focusedCountryCode: focusedCountryCode,
        sceneSpec: sceneSpec.copyWith(
          selectedCountryCode: selectedCountryCode,
          focusedCountryCode: focusedCountryCode,
        ),
      ),
    );
  }

  double _compactBottomPadding(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return bottomInset > 0 ? 90 : 84;
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
    final content =
        child ??
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
    final initials = trimmed.isEmpty
        ? 'R'
        : String.fromCharCode(trimmed.runes.first);
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
