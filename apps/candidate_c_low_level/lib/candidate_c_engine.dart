import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl_flutterflow/flutter_gl.dart';
import 'package:flutter_gl_flutterflow/native-array/index.dart';
import 'package:globe_poc_core/globe_poc_core.dart';

import 'globe_asset_resolver.dart';
import 'web_globe_dom_tweaks.dart';

const bool kShowGlobeDebugOverlays = bool.fromEnvironment(
  'SHOW_GLOBE_DEBUG_OVERLAYS',
  defaultValue: false,
);

class CandidateCLowLevelBinding implements GlobeEngineBinding {
  @override
  GlobeCandidateKind get candidate => GlobeCandidateKind.candidateC;

  @override
  String get displayName => 'Candidate C · low-level GL custom';

  @override
  GlobeEngineAdapter createAdapter({
    required GlobeFixture fixture,
    required GlobePocController controller,
  }) {
    return CandidateCLowLevelAdapter(fixture: fixture, controller: controller);
  }
}

class CandidateCLowLevelAdapter implements GlobeEngineAdapter {
  CandidateCLowLevelAdapter({required this.fixture, required this.controller});

  final GlobeFixture fixture;
  final GlobePocController controller;
  final ValueNotifier<GlobeProbeResult> _probe = ValueNotifier(
    GlobeProbeResult.unknown,
  );

  @override
  GlobeCandidateKind get candidate => GlobeCandidateKind.candidateC;

  @override
  String get displayName => 'Candidate C · low-level GL custom';

  @override
  ValueNotifier<GlobeProbeResult> get probeResult => _probe;

  @override
  Widget buildRenderer(BuildContext context) {
    return CandidateCLowLevelView(
      fixture: fixture,
      controller: controller,
      probeResult: _probe,
    );
  }

  @override
  Future<void> initialize() async {
    _probe.value = const GlobeProbeResult(
      ready: true,
      summary: 'flutter_gl custom renderer bootstrap started',
      blockingIssues: [],
    );
  }

  @override
  Future<Uint8List?> captureFrame() async => null;

  @override
  Future<void> dispose() async {
    _probe.dispose();
  }
}

class CandidateCLowLevelView extends StatefulWidget {
  const CandidateCLowLevelView({
    required this.fixture,
    required this.controller,
    required this.probeResult,
    super.key,
  });

  final GlobeFixture fixture;
  final GlobePocController controller;
  final ValueNotifier<GlobeProbeResult> probeResult;

  @override
  State<CandidateCLowLevelView> createState() => _CandidateCLowLevelViewState();
}

class _CandidateCLowLevelViewState extends State<CandidateCLowLevelView> {
  late FlutterGlPlugin flutterGlPlugin;
  Size? screenSize;
  double dpr = 1.0;
  bool initialized = false;
  bool rendering = false;
  bool disposed = false;
  double memorySampleAccumulator = 0;
  dynamic sourceTexture;
  dynamic framebuffer;
  dynamic framebufferTexture;

  dynamic sphereProgram;
  dynamic flatProgram;
  dynamic vertexArray;
  dynamic quadBuffer;
  dynamic lineBuffer;
  dynamic pointBuffer;
  dynamic earthTexture;
  dynamic bordersTexture;
  dynamic countryIdTexture;
  dynamic starfieldTexture;
  NativeArray<int>? earthTextureBytes;
  NativeArray<int>? bordersTextureBytes;
  NativeArray<int>? countryIdTextureBytes;
  NativeArray<int>? starfieldTextureBytes;
  int markerVertexCount = 0;
  int framesRendered = 0;
  bool pixelProbeLogged = false;
  bool framebufferStatusLogged = false;
  bool webDomTweaksApplied = false;
  final List<Float32List> routeClipBuffers = [];
  GlobeResolvedAssets? resolvedAssets;

  @override
  void initState() {
    super.initState();
    flutterGlPlugin = FlutterGlPlugin();
  }

  @override
  void dispose() {
    disposed = true;
    earthTextureBytes?.dispose();
    bordersTextureBytes?.dispose();
    countryIdTextureBytes?.dispose();
    starfieldTextureBytes?.dispose();
    super.dispose();
  }

  Future<void> _initIfNeeded() async {
    if (initialized || screenSize == null) {
      return;
    }
    initialized = true;
    final width = screenSize!.width;
    final height = screenSize!.height;
    await flutterGlPlugin.initialize(
      options: {
        'antialias': true,
        'alpha': false,
        'width': width.toInt(),
        'height': height.toInt(),
        'dpr': dpr,
      },
    );
    if (mounted) {
      setState(() {});
    }
    Future<void>.delayed(const Duration(milliseconds: 100), () async {
      if (!kIsWeb) {
        await flutterGlPlugin.prepareContext();
        debugPrint(
          'POC_PREPARE_CONTEXT|${jsonEncode({
            'candidate': 'Candidate C · low-level GL custom',
            'textureId': flutterGlPlugin.textureId,
            'egls': flutterGlPlugin.egls,
            'screenWidth': screenSize!.width,
            'screenHeight': screenSize!.height,
            'dpr': dpr,
          })}',
        );
      }
      if (kIsWeb) {
        try {
          resolvedAssets = await GlobeAssetResolver().loadWebStandard();
          widget.controller.applyRuntimeGlobeAssets(
            textureBundle: resolvedAssets!.textureBundle,
            countries: resolvedAssets!.countries,
          );
        } catch (error) {
          debugPrint('POC_ASSET_RESOLVER_ERROR|$error');
        }
      }
      _setupFramebuffer();
      _setupPrograms();
      _uploadTextures();
      _buildStaticBuffers();
      if (mounted) {
        setState(() {});
      }
      widget.probeResult.value = const GlobeProbeResult(
        ready: true,
        summary: 'custom GL renderer ready',
        blockingIssues: [],
      );
      _animate();
    });
  }

  void _setupFramebuffer() {
    if (kIsWeb) {
      return;
    }
    final gl = flutterGlPlugin.gl;
    final requestedWidth = (screenSize!.width * dpr).round();
    final requestedHeight = (screenSize!.height * dpr).round();
    final width = requestedWidth > 0 ? requestedWidth : 1;
    final height = requestedHeight > 0 ? requestedHeight : 1;
    framebuffer = gl.createFramebuffer();
    framebufferTexture = gl.createTexture();
    final createError = gl.getError();
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, framebufferTexture);
    final bindTextureError = gl.getError();
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texStorage2D(gl.TEXTURE_2D, 1, gl.RGBA8, width, height);
    final storageError = gl.getError();
    gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
    final bindFramebufferError = gl.getError();
    gl.framebufferTexture2D(
      gl.FRAMEBUFFER,
      gl.COLOR_ATTACHMENT0,
      gl.TEXTURE_2D,
      framebufferTexture,
      0,
    );
    final attachError = gl.getError();
    final framebufferStatus = gl.checkFramebufferStatus(gl.FRAMEBUFFER);
    final statusError = gl.getError();
    debugPrint(
      'POC_FRAMEBUFFER_SETUP|${jsonEncode({
        'candidate': 'Candidate C · low-level GL custom',
        'logicalWidth': screenSize!.width,
        'logicalHeight': screenSize!.height,
        'dpr': dpr,
        'physicalWidth': width,
        'physicalHeight': height,
        'framebuffer': framebuffer,
        'framebufferTexture': framebufferTexture,
        'createError': createError,
        'bindTextureError': bindTextureError,
        'storageError': storageError,
        'bindFramebufferError': bindFramebufferError,
        'attachError': attachError,
        'framebufferStatus': framebufferStatus,
        'statusError': statusError,
      })}',
    );
    sourceTexture = framebufferTexture;
  }

  void _setupPrograms() {
    final gl = flutterGlPlugin.gl;
    final version = (!kIsWeb) ? '300 es' : '300 es';
    sphereProgram = _createProgram(
      gl,
      '''#version $version
precision highp float;
layout(location = 0) in vec2 aPosition;
out vec2 vUv;
void main() {
  vUv = aPosition * 0.5 + 0.5;
  gl_Position = vec4(aPosition, 0.0, 1.0);
}
''',
      '''#version $version
precision highp float;
in vec2 vUv;
out vec4 fragColor;
uniform sampler2D uEarth;
uniform sampler2D uBorders;
uniform sampler2D uCountryIds;
uniform sampler2D uStarfield;
uniform float uYaw;
uniform float uPitch;
uniform float uAspect;
uniform float uSelectedCountry;
uniform vec3 uAtmosphereColor;
uniform float uRimIntensity;
uniform float uFalloff;
mat3 rotY(float a) {
  float c = cos(a); float s = sin(a);
  return mat3(c,0.0,-s, 0.0,1.0,0.0, s,0.0,c);
}
mat3 rotX(float a) {
  float c = cos(a); float s = sin(a);
  return mat3(1.0,0.0,0.0, 0.0,c,-s, 0.0,s,c);
}
void main() {
  vec2 centered = vec2((vUv.x - 0.5) * uAspect, vUv.y - 0.5) * 2.0;
  float r2 = dot(centered, centered);
  if (r2 > 1.0) {
    fragColor = texture(uStarfield, vUv);
    return;
  }
  float z = sqrt(1.0 - r2);
  vec3 local = normalize(vec3(centered.x, centered.y, z));
  vec3 surface = rotY(uYaw) * rotX(-uPitch) * local;
  float latitude = asin(surface.y);
  float longitude = atan(surface.x, surface.z);
  vec2 texUv = vec2(longitude / 6.28318530718 + 0.5, 0.5 - latitude / 3.14159265359);
  vec4 earthColor = texture(uEarth, texUv);
  vec4 borderColor = texture(uBorders, texUv);
  vec4 countryColor = texture(uCountryIds, texUv);
  float country = dot(floor(countryColor.rgb * 255.0 + 0.5), vec3(1.0, 256.0, 65536.0));
  if (uSelectedCountry > 0.0 && abs(country - uSelectedCountry) < 0.5) {
    earthColor.rgb = mix(earthColor.rgb, vec3(1.0, 0.95, 0.5), 0.35);
  }
  earthColor.rgb = mix(earthColor.rgb, vec3(1.0), borderColor.a * 0.65);
  float fresnel = pow(max(0.0, 1.0 - local.z), uFalloff);
  earthColor.rgb += uAtmosphereColor * (fresnel * uRimIntensity);
  fragColor = earthColor;
}
''',
    );
    flatProgram = _createProgram(
      gl,
      '''#version $version
precision highp float;
layout(location = 0) in vec2 aPosition;
uniform float uPointSize;
void main() {
  gl_Position = vec4(aPosition, 0.0, 1.0);
  gl_PointSize = uPointSize;
}
''',
      '''#version $version
precision highp float;
out vec4 fragColor;
uniform vec4 uColor;
void main() {
  fragColor = uColor;
}
''',
    );
  }

  void _uploadTextures() {
    final gl = flutterGlPlugin.gl;
    final textureBundle = resolvedAssets?.textureBundle ?? widget.fixture.textureBundle;
    earthTextureBytes ??= Uint8Array.fromList(textureBundle.earthRgba);
    final bordersWidth = resolvedAssets?.textureBundle.width ?? 1;
    final bordersHeight = resolvedAssets?.textureBundle.height ?? 1;
    bordersTextureBytes ??= Uint8Array.fromList(
      resolvedAssets?.bordersRgba ?? Uint8List.fromList(const [0, 0, 0, 0]),
    );
    countryIdTextureBytes ??= Uint8Array.fromList(
      textureBundle.countryIdRgba,
    );
    final starfieldWidth = resolvedAssets?.textureBundle.width ?? 1;
    final starfieldHeight = resolvedAssets?.textureBundle.height ?? 1;
    starfieldTextureBytes ??= Uint8Array.fromList(
      resolvedAssets?.starfieldRgba ?? Uint8List.fromList(const [5, 10, 18, 255]),
    );
    earthTexture = _createTexture2D(
      gl,
      textureUnit: gl.TEXTURE0,
      width: textureBundle.width,
      height: textureBundle.height,
      bytes: earthTextureBytes,
      minFilter: gl.LINEAR,
      magFilter: gl.LINEAR,
      mipmaps: true,
    );
    bordersTexture = _createTexture2D(
      gl,
      textureUnit: gl.TEXTURE1,
      width: bordersWidth,
      height: bordersHeight,
      bytes: bordersTextureBytes,
      minFilter: gl.LINEAR,
      magFilter: gl.LINEAR,
      mipmaps: false,
    );
    countryIdTexture = _createTexture2D(
      gl,
      textureUnit: gl.TEXTURE2,
      width: textureBundle.width,
      height: textureBundle.height,
      bytes: countryIdTextureBytes,
      minFilter: gl.NEAREST,
      magFilter: gl.NEAREST,
      mipmaps: false,
      setBaseMaxLevel: true,
    );
    starfieldTexture = _createTexture2D(
      gl,
      textureUnit: gl.TEXTURE3,
      width: starfieldWidth,
      height: starfieldHeight,
      bytes: starfieldTextureBytes,
      minFilter: gl.LINEAR,
      magFilter: gl.LINEAR,
      mipmaps: true,
    );
  }

  void _buildStaticBuffers() {
    final gl = flutterGlPlugin.gl;
    vertexArray = gl.createVertexArray();
    gl.bindVertexArray(vertexArray);

    quadBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, quadBuffer);
    final quad = Float32List.fromList(const [-1, -1, 1, -1, -1, 1, 1, 1]);
    _bufferData(gl, quad);

    pointBuffer = gl.createBuffer();
    lineBuffer = gl.createBuffer();
  }

  dynamic _createTexture2D(
    dynamic gl, {
    required dynamic textureUnit,
    required int width,
    required int height,
    required dynamic bytes,
    required dynamic minFilter,
    required dynamic magFilter,
    required bool mipmaps,
    bool setBaseMaxLevel = false,
  }) {
    final texture = gl.createTexture();
    gl.activeTexture(textureUnit);
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, minFilter);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, magFilter);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    if (setBaseMaxLevel) {
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_BASE_LEVEL, 0);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAX_LEVEL, 0);
    }
    gl.texImage2D(
      gl.TEXTURE_2D,
      0,
      gl.RGBA,
      width,
      height,
      0,
      gl.RGBA,
      gl.UNSIGNED_BYTE,
      bytes,
    );
    if (mipmaps) {
      gl.generateMipmap(gl.TEXTURE_2D);
    }
    return texture;
  }

  Future<void> _animate() async {
    if (rendering) return;
    rendering = true;
    while (mounted && !disposed) {
      final startedAt = DateTime.now();
      _renderFrame();
      if (!kIsWeb) {
        await flutterGlPlugin.updateTexture(sourceTexture);
      }
      widget.controller.recordFrame(
        DateTime.now().difference(startedAt).inMicroseconds / 1000,
      );
      memorySampleAccumulator += 0.016;
      if (memorySampleAccumulator >= 1) {
        memorySampleAccumulator = 0;
        widget.controller.recordMemorySample(WebMemoryProbe.usedHeapBytes());
      }
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    rendering = false;
  }

  void _renderFrame() {
    final gl = flutterGlPlugin.gl;
    final width = (screenSize!.width * dpr).toInt();
    final height = (screenSize!.height * dpr).toInt();
    if (!kIsWeb && framebuffer != null) {
      gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
      if (!framebufferStatusLogged) {
        framebufferStatusLogged = true;
        final boundStatus = gl.checkFramebufferStatus(gl.FRAMEBUFFER);
        final boundStatusError = gl.getError();
        debugPrint(
          'POC_FRAMEBUFFER_RENDER_STATUS|${jsonEncode({
            'candidate': 'Candidate C · low-level GL custom',
            'frame': framesRendered,
            'framebuffer': framebuffer,
            'framebufferTexture': framebufferTexture,
            'status': boundStatus,
            'statusError': boundStatusError,
          })}',
        );
      }
    }
    if (vertexArray != null) {
      gl.bindVertexArray(vertexArray);
    }
    gl.viewport(0, 0, width, height);
    gl.clearColor(0.02, 0.07, 0.11, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    _renderSphere(gl);
    if (kShowGlobeDebugOverlays) {
      _renderRoutes(gl);
      _renderMarkers(gl);
    }
    if (kIsWeb) {
      gl.flush();
    } else {
      framesRendered += 1;
      if (!pixelProbeLogged && framesRendered >= 5) {
        pixelProbeLogged = true;
        _logPixelProbe(gl, width, height);
      }
      gl.finish();
    }
  }

  void _logPixelProbe(dynamic gl, int width, int height) {
    try {
      final samplePoints = <String, List<int>>{
        'center': _readPixel(gl, width ~/ 2, height ~/ 2),
        'upperLeft': _readPixel(gl, width ~/ 4, (height * 3) ~/ 4),
        'upperRight': _readPixel(gl, (width * 3) ~/ 4, (height * 3) ~/ 4),
        'lowerCenter': _readPixel(gl, width ~/ 2, height ~/ 4),
      };
      final nonBlackSamples = samplePoints.values.where((pixel) {
        if (pixel.length < 3) {
          return false;
        }
        return pixel[0] + pixel[1] + pixel[2] > 12;
      }).length;
      debugPrint(
        'POC_PIXEL_PROBE|${jsonEncode({
          'candidate': 'Candidate C · low-level GL custom',
          'width': width,
          'height': height,
          'samples': samplePoints,
          'nonBlackSamples': nonBlackSamples,
          'totalSamples': samplePoints.length,
        })}',
      );
    } catch (error) {
      debugPrint('POC_PIXEL_PROBE_ERROR|$error');
    }
  }

  List<int> _readPixel(dynamic gl, int x, int y) {
    final pixel = Uint8Array(4);
    gl.readPixels(x, y, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, pixel);
    return pixel.toDartList().toList(growable: false);
  }

  void _renderSphere(dynamic gl) {
    gl.useProgram(sphereProgram);
    gl.bindBuffer(gl.ARRAY_BUFFER, quadBuffer);
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, earthTexture);
    gl.uniform1i(gl.getUniformLocation(sphereProgram, 'uEarth'), 0);
    gl.activeTexture(gl.TEXTURE1);
    gl.bindTexture(gl.TEXTURE_2D, bordersTexture);
    gl.uniform1i(gl.getUniformLocation(sphereProgram, 'uBorders'), 1);
    gl.activeTexture(gl.TEXTURE2);
    gl.bindTexture(gl.TEXTURE_2D, countryIdTexture);
    gl.uniform1i(gl.getUniformLocation(sphereProgram, 'uCountryIds'), 2);
    gl.activeTexture(gl.TEXTURE3);
    gl.bindTexture(gl.TEXTURE_2D, starfieldTexture);
    gl.uniform1i(gl.getUniformLocation(sphereProgram, 'uStarfield'), 3);
    gl.uniform1f(
      gl.getUniformLocation(sphereProgram, 'uYaw'),
      widget.controller.cameraPose.yaw.toDouble(),
    );
    gl.uniform1f(
      gl.getUniformLocation(sphereProgram, 'uPitch'),
      widget.controller.cameraPose.pitch.toDouble(),
    );
    gl.uniform1f(
      gl.getUniformLocation(sphereProgram, 'uAspect'),
      screenSize!.width / screenSize!.height,
    );
    final atmosphere = resolvedAssets?.atmosphereProfile;
    final selected = (widget.controller.selectedCountryIndex ?? 0).toDouble();
    gl.uniform1f(
      gl.getUniformLocation(sphereProgram, 'uSelectedCountry'),
      selected,
    );
    gl.uniform3f(
      gl.getUniformLocation(sphereProgram, 'uAtmosphereColor'),
      _hexChannel((atmosphere?['atmosphereColor'] as String?) ?? '#6FA8FF', 0),
      _hexChannel((atmosphere?['atmosphereColor'] as String?) ?? '#6FA8FF', 1),
      _hexChannel((atmosphere?['atmosphereColor'] as String?) ?? '#6FA8FF', 2),
    );
    gl.uniform1f(
      gl.getUniformLocation(sphereProgram, 'uRimIntensity'),
      ((atmosphere?['rimIntensity'] as num?) ?? 0.18).toDouble(),
    );
    gl.uniform1f(
      gl.getUniformLocation(sphereProgram, 'uFalloff'),
      ((atmosphere?['falloff'] as num?) ?? 2.2).toDouble(),
    );
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  }

  void _renderRoutes(dynamic gl) {
    gl.useProgram(flatProgram);
    gl.uniform1f(gl.getUniformLocation(flatProgram, 'uPointSize'), 1.0);
    for (
      int routeIndex = 0;
      routeIndex < widget.fixture.routes.length;
      routeIndex++
    ) {
      final route = widget.fixture.routes[routeIndex];
      final clipPositions = <double>[];
      for (final point in route.points) {
        final screen = GlobeMath.projectToScreen(
          world: point,
          viewport: screenSize!,
          pose: widget.controller.cameraPose,
        );
        if (screen == null) continue;
        clipPositions.add((screen.dx / screenSize!.width) * 2 - 1);
        clipPositions.add(1 - (screen.dy / screenSize!.height) * 2);
      }
      if (clipPositions.length < 4) continue;
      gl.bindBuffer(gl.ARRAY_BUFFER, lineBuffer);
      _bufferData(gl, Float32List.fromList(clipPositions));
      gl.enableVertexAttribArray(0);
      gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
      final highlight =
          widget.controller.playing &&
          (routeIndex / widget.fixture.routes.length) <=
              widget.controller.playhead;
      gl.uniform4f(
        gl.getUniformLocation(flatProgram, 'uColor'),
        highlight ? 0.95 : 0.44,
        route.transportType == 'flight' ? 0.45 : 0.88,
        route.transportType == 'flight' ? 0.92 : 0.98,
        highlight ? 0.95 : 0.3,
      );
      gl.drawArrays(gl.LINE_STRIP, 0, clipPositions.length ~/ 2);
    }
  }

  void _renderMarkers(dynamic gl) {
    final positions = <double>[];
    for (final city in widget.fixture.cities) {
      final point = GlobeMath.latLonToVector3(
        latitude: city.latitude,
        longitude: city.longitude,
        radius: 1.04,
      );
      final screen = GlobeMath.projectToScreen(
        world: point,
        viewport: screenSize!,
        pose: widget.controller.cameraPose,
      );
      if (screen == null) continue;
      positions.add((screen.dx / screenSize!.width) * 2 - 1);
      positions.add(1 - (screen.dy / screenSize!.height) * 2);
    }
    if (positions.isEmpty) return;
    markerVertexCount = positions.length ~/ 2;
    gl.useProgram(flatProgram);
    gl.bindBuffer(gl.ARRAY_BUFFER, pointBuffer);
    _bufferData(gl, Float32List.fromList(positions));
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
    gl.uniform1f(gl.getUniformLocation(flatProgram, 'uPointSize'), 5.0 * dpr);
    gl.uniform4f(
      gl.getUniformLocation(flatProgram, 'uColor'),
      1.0,
      1.0,
      1.0,
      0.9,
    );
    gl.drawArrays(gl.POINTS, 0, markerVertexCount);
  }

  dynamic _createProgram(
    dynamic gl,
    String vertexSource,
    String fragmentSource,
  ) {
    final vertexShader = _compileShader(gl, gl.VERTEX_SHADER, vertexSource);
    final fragmentShader = _compileShader(
      gl,
      gl.FRAGMENT_SHADER,
      fragmentSource,
    );
    final program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    final ok = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (ok == false || ok == 0) {
      throw StateError(
        'GL program link failed: ${gl.getProgramInfoLog(program)}',
      );
    }
    return program;
  }

  dynamic _compileShader(dynamic gl, dynamic shaderType, String source) {
    final shader = gl.createShader(shaderType);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    final ok = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (ok == false || ok == 0) {
      throw StateError(
        'GL shader compile failed: ${gl.getShaderInfoLog(shader)}',
      );
    }
    return shader;
  }

  void _bufferData(dynamic gl, Float32List values) {
    if (kIsWeb) {
      gl.bufferData(
        gl.ARRAY_BUFFER,
        values.lengthInBytes,
        values,
        gl.STATIC_DRAW,
      );
    } else {
      gl.bufferData(
        gl.ARRAY_BUFFER,
        values.lengthInBytes,
        values,
        gl.STATIC_DRAW,
      );
    }
  }

  double _hexChannel(String hexColor, int index) {
    final normalized = hexColor.replaceAll('#', '');
    final offset = index * 2;
    if (normalized.length < offset + 2) {
      return 0;
    }
    final value = int.parse(normalized.substring(offset, offset + 2), radix: 16);
    return value / 255.0;
  }

  @override
  Widget build(BuildContext context) {
    screenSize ??= MediaQuery.of(context).size;
    dpr = MediaQuery.of(context).devicePixelRatio;
    _initIfNeeded();
    if (kIsWeb && flutterGlPlugin.isInitialized && !webDomTweaksApplied) {
      webDomTweaksApplied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        applyWebGlobeDomTweaks();
      });
    }
    return SizedBox.expand(
      child: flutterGlPlugin.isInitialized
          ? (kIsWeb
                ? HtmlElementView(
                    viewType: flutterGlPlugin.textureId!.toString(),
                  )
                : Texture(textureId: flutterGlPlugin.textureId!))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
