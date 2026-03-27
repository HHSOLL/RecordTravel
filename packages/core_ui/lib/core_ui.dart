import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';

@immutable
class AtlasPalette extends ThemeExtension<AtlasPalette> {
  const AtlasPalette({
    required this.isLight,
    required this.backgroundBase,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.surfaceGlass,
    required this.surfacePanel,
    required this.surfaceMuted,
    required this.outline,
    required this.accent,
    required this.accentSoft,
    required this.glowA,
    required this.glowB,
    required this.shadow,
  });

  final bool isLight;
  final Color backgroundBase;
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color surfaceGlass;
  final Color surfacePanel;
  final Color surfaceMuted;
  final Color outline;
  final Color accent;
  final Color accentSoft;
  final Color glowA;
  final Color glowB;
  final Color shadow;

  static const dark = AtlasPalette(
    isLight: false,
    backgroundBase: Color(0xFF0B1019),
    backgroundTop: Color(0xFF08111F),
    backgroundBottom: Color(0xFF040912),
    surfaceGlass: Color(0xAA030D1D),
    surfacePanel: Color(0xFF131A27),
    surfaceMuted: Color(0xFF1D263B),
    outline: Color(0xFF21405F),
    accent: Color(0xFF00D1FF),
    accentSoft: Color(0xFF00F0FF),
    glowA: Color(0x6600F0FF),
    glowB: Color(0x40FF008A),
    shadow: Color(0x33000000),
  );

  static const light = AtlasPalette(
    isLight: true,
    backgroundBase: Color(0xFFF3F7FF),
    backgroundTop: Color(0xFFEAF3FF),
    backgroundBottom: Color(0xFFDCEBFF),
    surfaceGlass: Color(0xD9FFFFFF),
    surfacePanel: Color(0xFFFDFBF7),
    surfaceMuted: Color(0xFFF2F6FF),
    outline: Color(0xFFB7CDE8),
    accent: Color(0xFF3B77C9),
    accentSoft: Color(0xFF6DA7F5),
    glowA: Color(0x5AB7D8FF),
    glowB: Color(0x40FFF3C5),
    shadow: Color(0x1C6888B7),
  );

  @override
  AtlasPalette copyWith({
    bool? isLight,
    Color? backgroundBase,
    Color? backgroundTop,
    Color? backgroundBottom,
    Color? surfaceGlass,
    Color? surfacePanel,
    Color? surfaceMuted,
    Color? outline,
    Color? accent,
    Color? accentSoft,
    Color? glowA,
    Color? glowB,
    Color? shadow,
  }) {
    return AtlasPalette(
      isLight: isLight ?? this.isLight,
      backgroundBase: backgroundBase ?? this.backgroundBase,
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      surfacePanel: surfacePanel ?? this.surfacePanel,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      outline: outline ?? this.outline,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      glowA: glowA ?? this.glowA,
      glowB: glowB ?? this.glowB,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AtlasPalette lerp(ThemeExtension<AtlasPalette>? other, double t) {
    if (other is! AtlasPalette) return this;
    return AtlasPalette(
      isLight: t < 0.5 ? isLight : other.isLight,
      backgroundBase: Color.lerp(backgroundBase, other.backgroundBase, t)!,
      backgroundTop: Color.lerp(backgroundTop, other.backgroundTop, t)!,
      backgroundBottom: Color.lerp(
        backgroundBottom,
        other.backgroundBottom,
        t,
      )!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      surfacePanel: Color.lerp(surfacePanel, other.surfacePanel, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      glowA: Color.lerp(glowA, other.glowA, t)!,
      glowB: Color.lerp(glowB, other.glowB, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AtlasThemeContext on BuildContext {
  AtlasPalette get atlasPalette =>
      Theme.of(this).extension<AtlasPalette>() ??
      (Theme.of(this).brightness == Brightness.light
          ? AtlasPalette.light
          : AtlasPalette.dark);
}

class AtlasTheme {
  static ThemeData buildTheme({Brightness brightness = Brightness.dark}) {
    final palette = brightness == Brightness.light
        ? AtlasPalette.light
        : AtlasPalette.dark;
    final accent = palette.accent;
    final accentSoft = palette.accentSoft;
    final glow = palette.accentSoft;
    final textPrimary = brightness == Brightness.light
        ? const Color(0xFF172033)
        : const Color(0xFFFFFFFF);
    final textSecondary = brightness == Brightness.light
        ? const Color(0xFF5E718E)
        : const Color(0xFFA0AEC0);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accentSoft,
          brightness: brightness,
        ).copyWith(
          surface: palette.surfacePanel,
          primary: accentSoft,
          secondary: accent,
          outline: palette.outline,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[palette],
      scaffoldBackgroundColor: palette.backgroundBase,
      splashFactory: InkSparkle.splashFactory,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfacePanel,
        contentTextStyle: TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.1,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.15,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.2,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: textSecondary),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentSoft,
          foregroundColor: const Color(0xFF06101C),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: palette.outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surfacePanel.withValues(
          alpha: palette.isLight ? 0.9 : 0.6,
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: palette.outline.withValues(
              alpha: palette.isLight ? 0.6 : 0.8,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceMuted.withValues(
          alpha: palette.isLight ? 0.95 : 0.7,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: palette.outline.withValues(
              alpha: palette.isLight ? 0.7 : 0.8,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: glow, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceMuted,
        selectedColor: accent.withValues(alpha: 0.24),
        disabledColor: palette.surfaceMuted,
        labelStyle: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        side: BorderSide(color: palette.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: accent.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? textPrimary
                : textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class AtlasBackground extends StatelessWidget {
  const AtlasBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.backgroundTop,
            palette.backgroundBase,
            palette.backgroundBottom,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: palette.isLight
                ? const _AtlasCloudfield()
                : const _AtlasStarfield(),
          ),
          Positioned(
            top: -140,
            left: -70,
            child: _GlowOrb(color: palette.glowA, size: 400),
          ),
          Positioned(
            top: 250,
            right: -120,
            child: _GlowOrb(color: palette.glowB, size: 450),
          ),
          Positioned(
            bottom: -140,
            left: 30,
            child: _GlowOrb(
              color: palette.accentSoft.withValues(
                alpha: palette.isLight ? 0.16 : 0.08,
              ),
              size: 260,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      palette.isLight
                          ? const Color(0xFFF8FBFF).withValues(alpha: 0.16)
                          : const Color(0xFF02060D).withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AtlasCloudfield extends StatelessWidget {
  const _AtlasCloudfield();

  static const _clouds =
      <({double x, double y, double w, double h, double alpha})>[
        (x: 0.06, y: 0.10, w: 140, h: 54, alpha: 0.42),
        (x: 0.72, y: 0.08, w: 120, h: 46, alpha: 0.48),
        (x: 0.80, y: 0.38, w: 100, h: 40, alpha: 0.34),
        (x: 0.14, y: 0.62, w: 150, h: 58, alpha: 0.28),
        (x: 0.66, y: 0.74, w: 130, h: 50, alpha: 0.36),
      ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final cloud in _clouds)
                Positioned(
                  left: constraints.maxWidth * cloud.x,
                  top: constraints.maxHeight * cloud.y,
                  child: Container(
                    width: cloud.w,
                    height: cloud.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withValues(alpha: cloud.alpha),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(
                            alpha: cloud.alpha * 0.45,
                          ),
                          blurRadius: 26,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AtlasStarfield extends StatelessWidget {
  const _AtlasStarfield();

  static const _stars = <({double x, double y, double size, double alpha})>[
    (x: 0.08, y: 0.12, size: 2, alpha: 0.55),
    (x: 0.18, y: 0.09, size: 1.8, alpha: 0.38),
    (x: 0.31, y: 0.16, size: 2.4, alpha: 0.48),
    (x: 0.44, y: 0.11, size: 1.6, alpha: 0.42),
    (x: 0.57, y: 0.18, size: 2.2, alpha: 0.45),
    (x: 0.72, y: 0.10, size: 1.6, alpha: 0.34),
    (x: 0.85, y: 0.14, size: 2, alpha: 0.42),
    (x: 0.93, y: 0.08, size: 1.6, alpha: 0.5),
    (x: 0.12, y: 0.28, size: 1.6, alpha: 0.34),
    (x: 0.26, y: 0.33, size: 2, alpha: 0.36),
    (x: 0.49, y: 0.30, size: 1.5, alpha: 0.32),
    (x: 0.63, y: 0.37, size: 1.8, alpha: 0.43),
    (x: 0.78, y: 0.26, size: 2.2, alpha: 0.48),
    (x: 0.89, y: 0.35, size: 1.6, alpha: 0.4),
    (x: 0.07, y: 0.52, size: 1.8, alpha: 0.34),
    (x: 0.21, y: 0.46, size: 2.3, alpha: 0.38),
    (x: 0.37, y: 0.56, size: 1.6, alpha: 0.44),
    (x: 0.53, y: 0.49, size: 2, alpha: 0.36),
    (x: 0.69, y: 0.58, size: 1.8, alpha: 0.42),
    (x: 0.84, y: 0.47, size: 2.1, alpha: 0.34),
    (x: 0.94, y: 0.60, size: 1.8, alpha: 0.45),
    (x: 0.15, y: 0.72, size: 2.1, alpha: 0.46),
    (x: 0.29, y: 0.78, size: 1.5, alpha: 0.36),
    (x: 0.43, y: 0.68, size: 2.2, alpha: 0.4),
    (x: 0.61, y: 0.80, size: 1.7, alpha: 0.42),
    (x: 0.76, y: 0.73, size: 2.2, alpha: 0.34),
    (x: 0.90, y: 0.83, size: 1.6, alpha: 0.44),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final star in _stars)
                Positioned(
                  left: constraints.maxWidth * star.x,
                  top: constraints.maxHeight * star.y,
                  child: Container(
                    width: star.size,
                    height: star.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: star.alpha),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}

class AtlasPanel extends StatelessWidget {
  const AtlasPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, val, animChild) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - val)),
          child: Opacity(opacity: val, child: animChild),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: palette.surfaceGlass.withValues(
                alpha: palette.isLight ? 0.82 : 0.55,
              ),
              border: Border.all(
                color: palette.outline.withValues(
                  alpha: palette.isLight ? 0.55 : 0.45,
                ),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.shadow,
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class AtlasHeroPanel extends StatelessWidget {
  const AtlasHeroPanel({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.message,
    this.metrics = const [],
    this.actions = const [],
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String message;
  final List<Widget> metrics;
  final List<Widget> actions;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, val, animChild) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - val)),
          child: Opacity(opacity: val, child: animChild),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: palette.surfaceGlass.withValues(
                alpha: palette.isLight ? 0.86 : 0.65,
              ),
              border: Border.all(
                color: palette.outline.withValues(
                  alpha: palette.isLight ? 0.62 : 0.5,
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.shadow.withValues(
                    alpha: palette.isLight ? 0.22 : 0.28,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eyebrow.toUpperCase(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.accent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              foreground: Paint()
                                ..shader = ui.Gradient.linear(
                                  const Offset(0, 0),
                                  const Offset(0, 30),
                                  palette.isLight
                                      ? [
                                          const Color(0xFF22345A),
                                          palette.accentSoft,
                                        ]
                                      : [Colors.white, palette.accentSoft],
                                ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(message, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 16),
                      trailing!,
                    ],
                  ],
                ),
                if (metrics.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(spacing: 12, runSpacing: 12, children: metrics),
                ],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(spacing: 12, runSpacing: 12, children: actions),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AtlasOrbitalGraphic extends StatelessWidget {
  const AtlasOrbitalGraphic({
    super.key,
    this.size = 110,
    this.glowColor = const Color(0xFF8DEBFF),
  });

  final double size;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: glowColor.withValues(alpha: 0.18)),
            ),
          ),
          Transform.rotate(
            angle: 0.6,
            child: Container(
              width: size * 0.86,
              height: size * 0.42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size),
                border: Border.all(color: glowColor.withValues(alpha: 0.24)),
              ),
            ),
          ),
          Container(
            width: size * 0.64,
            height: size * 0.64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF234A70),
                  const Color(0xFF10233A),
                  const Color(0xFF09111E),
                ],
              ),
              border: Border.all(color: const Color(0xFF355A7C)),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.16),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Positioned(
            top: size * 0.18,
            right: size * 0.18,
            child: Container(
              width: size * 0.1,
              height: size * 0.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor,
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.22,
            left: size * 0.12,
            child: Container(
              width: size * 0.07,
              height: size * 0.07,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AtlasSectionHeader extends StatelessWidget {
  const AtlasSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AtlasMetricChip extends StatelessWidget {
  const AtlasMetricChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class AtlasMiniMetric extends StatelessWidget {
  const AtlasMiniMetric({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.minWidth = 94,
  });

  final String label;
  final String value;
  final IconData? icon;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: palette.accentSoft),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class AtlasActionTile extends StatelessWidget {
  const AtlasActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.outline),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.surfacePanel,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: palette.accentSoft),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.54),
            ),
          ],
        ),
      ),
    );
  }
}

class AtlasStatusPill extends StatelessWidget {
  const AtlasStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SyncBanner extends StatelessWidget {
  const SyncBanner({
    super.key,
    required this.title,
    required this.message,
    required this.tone,
  });

  final String title;
  final String message;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tone.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tone.withValues(alpha: 0.2),
                ),
                child: Icon(Icons.sync_rounded, color: tone, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: tone),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AtlasEmptyState extends StatelessWidget {
  const AtlasEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AtlasPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.travel_explore_rounded,
            size: 28,
            color: Color(0xFF78B7FF),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class TimelineMarker extends StatelessWidget {
  const TimelineMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Color(0xFF8DEBFF),
        shape: BoxShape.circle,
      ),
    );
  }
}

String formatShortDate(DateTime date) => DateFormat('MMM d').format(date);
String formatLongDate(DateTime date) => DateFormat('EEE, MMM d').format(date);
String formatRelativeSync(DateTime? date) =>
    date == null ? 'Not synced yet' : DateFormat('MMM d • HH:mm').format(date);
