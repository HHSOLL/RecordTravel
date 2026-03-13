import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl_flutterflow/flutter_gl.dart';
import 'package:flutter_gl_flutterflow/native-array/index.dart';
import 'package:globe_poc_core/globe_poc_core.dart';
import 'package:three_dart_flutterflow/three_dart.dart' as three;

class CandidateBEngineBinding implements GlobeEngineBinding {
  @override
  GlobeCandidateKind get candidate => GlobeCandidateKind.candidateB;

  @override
  String get displayName => 'Candidate B · Dart-native Three port';

  @override
  GlobeEngineAdapter createAdapter({
    required GlobeFixture fixture,
    required GlobePocController controller,
  }) {
    return CandidateBEngineAdapter(fixture: fixture, controller: controller);
  }
}

class CandidateBEngineAdapter implements GlobeEngineAdapter {
  CandidateBEngineAdapter({required this.fixture, required this.controller});

  final GlobeFixture fixture;
  final GlobePocController controller;
  final ValueNotifier<GlobeProbeResult> _probe = ValueNotifier(
    GlobeProbeResult.unknown,
  );

  @override
  GlobeCandidateKind get candidate => GlobeCandidateKind.candidateB;

  @override
  String get displayName => 'Candidate B · Dart-native Three port';

  @override
  ValueNotifier<GlobeProbeResult> get probeResult => _probe;

  @override
  Widget buildRenderer(BuildContext context) {
    return CandidateBThreeDartView(
      fixture: fixture,
      controller: controller,
      probeResult: _probe,
    );
  }

  @override
  Future<void> initialize() async {
    _probe.value = const GlobeProbeResult(
      ready: true,
      summary: 'Dart-native Three port bootstrap started',
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

class CandidateBThreeDartView extends StatefulWidget {
  const CandidateBThreeDartView({
    required this.fixture,
    required this.controller,
    required this.probeResult,
    super.key,
  });

  final GlobeFixture fixture;
  final GlobePocController controller;
  final ValueNotifier<GlobeProbeResult> probeResult;

  @override
  State<CandidateBThreeDartView> createState() =>
      _CandidateBThreeDartViewState();
}

class _CandidateBThreeDartViewState extends State<CandidateBThreeDartView> {
  late FlutterGlPlugin flutterGlPlugin;
  three.WebGLRenderer? renderer;
  three.Scene? scene;
  three.Camera? camera;
  three.Mesh? earthMesh;
  three.Points? markerPoints;
  final List<three.Line> routeLines = [];

  bool initialized = false;
  bool disposed = false;
  bool rendering = false;
  double dpr = 1.0;
  double memorySampleAccumulator = 0;
  Size? screenSize;
  dynamic sourceTexture;
  late three.WebGLRenderTarget renderTarget;

  @override
  void initState() {
    super.initState();
    flutterGlPlugin = FlutterGlPlugin();
  }

  @override
  void dispose() {
    disposed = true;
    renderer?.dispose();
    super.dispose();
  }

  Future<void> _initIfNeeded() async {
    if (initialized || screenSize == null) {
      return;
    }
    initialized = true;
    final width = screenSize!.width;
    final height = screenSize!.height;
    final options = {
      'antialias': true,
      'alpha': false,
      'width': width.toInt(),
      'height': height.toInt(),
      'dpr': dpr,
    };
    await flutterGlPlugin.initialize(options: options);
    if (mounted) {
      setState(() {});
    }
    Future<void>.delayed(const Duration(milliseconds: 100), () async {
      if (!kIsWeb) {
        await flutterGlPlugin.prepareContext();
      }
      _initScene();
      _animate();
      widget.probeResult.value = const GlobeProbeResult(
        ready: true,
        summary: 'Dart-native Three port scene ready',
        blockingIssues: [],
      );
    });
  }

  void _initScene() {
    final width = screenSize!.width;
    final height = screenSize!.height;
    renderer = three.WebGLRenderer({
      'width': width,
      'height': height,
      'gl': flutterGlPlugin.gl,
      'antialias': true,
      'canvas': flutterGlPlugin.element,
    });
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    if (!kIsWeb) {
      final pars = three.WebGLRenderTargetOptions({
        'minFilter': three.LinearFilter,
        'magFilter': three.LinearFilter,
        'format': three.RGBAFormat,
      });
      renderTarget = three.WebGLRenderTarget(
        (width * dpr).toInt(),
        (height * dpr).toInt(),
        pars,
      );
      renderTarget.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }

    scene = three.Scene();
    scene!.background = three.Color(0x04101a);
    camera = three.PerspectiveCamera(38, width / height, 0.1, 100);
    scene!.add(three.AmbientLight(0xffffff, 0.75));
    final directional = three.DirectionalLight(0xffffff, 1)
      ..position.set(4, 4, 6);
    scene!.add(directional);

    earthMesh = _buildEarthMesh();
    markerPoints = _buildMarkers();
    scene!.add(earthMesh!);
    scene!.add(markerPoints!);
    for (final route in widget.fixture.routes) {
      final line = _buildRoute(route);
      routeLines.add(line);
      scene!.add(line);
    }
  }

  three.Mesh _buildEarthMesh() {
    final texture = three.DataTexture(
      widget.fixture.textureBundle.earthRgba,
      widget.fixture.textureBundle.width,
      widget.fixture.textureBundle.height,
      three.RGBAFormat,
      three.UnsignedByteType,
    )..needsUpdate = true;
    final material = three.MeshPhongMaterial({
      'map': texture,
      'shininess': 8.0,
      'side': three.DoubleSide,
    });
    return three.Mesh(three.SphereGeometry(1, 64, 32), material);
  }

  three.Points _buildMarkers() {
    final positions = <double>[];
    for (final city in widget.fixture.cities) {
      final point = GlobeMath.latLonToVector3(
        latitude: city.latitude,
        longitude: city.longitude,
        radius: 1.04,
      );
      positions.addAll([point.x, point.y, point.z]);
    }
    final geometry = three.BufferGeometry()
      ..setAttribute(
        'position',
        three.Float32BufferAttribute(
          Float32Array.fromList(positions),
          3,
          false,
        ),
      );
    final material = three.PointsMaterial({
      'color': 0xffffff,
      'size': 0.055,
      'transparent': true,
      'opacity': 0.88,
      'sizeAttenuation': true,
    });
    return three.Points(geometry, material);
  }

  three.Line _buildRoute(TravelRoute route) {
    final geometry = three.BufferGeometry()
      ..setFromPoints(
        route.points
            .map((point) => three.Vector3(point.x, point.y, point.z))
            .toList(),
      );
    final material = three.LineBasicMaterial({
      'color': route.transportType == 'flight' ? 0xFFD678FF : 0xFF70E4FF,
      'transparent': true,
      'opacity': 0.42,
    });
    return three.Line(geometry, material);
  }

  Future<void> _animate() async {
    if (!mounted ||
        disposed ||
        scene == null ||
        camera == null ||
        renderer == null) {
      return;
    }
    if (rendering) {
      return;
    }
    rendering = true;
    while (mounted && !disposed) {
      final startedAt = DateTime.now();
      _syncScene();
      renderer!.render(scene!, camera!);
      flutterGlPlugin.gl.flush();
      if (!kIsWeb) {
        await flutterGlPlugin.updateTexture(sourceTexture);
      }
      final elapsed =
          DateTime.now().difference(startedAt).inMicroseconds / 1000;
      widget.controller.recordFrame(elapsed);
      memorySampleAccumulator += 0.016;
      if (memorySampleAccumulator >= 1) {
        memorySampleAccumulator = 0;
        widget.controller.recordMemorySample(WebMemoryProbe.usedHeapBytes());
      }
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    rendering = false;
  }

  void _syncScene() {
    final pose = widget.controller.cameraPose;
    final cameraPosition = GlobeMath.cameraPosition(pose);
    camera!.position.set(cameraPosition.x, cameraPosition.y, cameraPosition.z);
    camera!.lookAt(three.Vector3(0, 0, 0));
    final playhead = widget.controller.playhead;
    for (int index = 0; index < routeLines.length; index++) {
      final material = routeLines[index].material as three.LineBasicMaterial;
      final progress = index / routeLines.length;
      material.opacity = widget.controller.playing
          ? (progress <= playhead ? 0.95 : 0.12)
          : 0.42 + 0.18 * (index % 4 == 0 ? 1 : 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize ??= MediaQuery.of(context).size;
    dpr = MediaQuery.of(context).devicePixelRatio;
    _initIfNeeded();
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
