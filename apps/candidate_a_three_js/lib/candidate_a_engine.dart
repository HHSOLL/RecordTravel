import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:globe_poc_core/globe_poc_core.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_math/three_js_math.dart' as tmath;

const _disableRoutes = bool.fromEnvironment('POC_A_DISABLE_ROUTES');
const _disableTexture = bool.fromEnvironment('POC_A_DISABLE_TEXTURE');
const _disableEarthMesh = bool.fromEnvironment('POC_A_DISABLE_EARTH');
const _disableMarkers = bool.fromEnvironment('POC_A_DISABLE_MARKERS');

class CandidateAEngineBinding implements GlobeEngineBinding {
  @override
  GlobeCandidateKind get candidate => GlobeCandidateKind.candidateA;

  @override
  String get displayName => 'Candidate A · three_js';

  @override
  GlobeEngineAdapter createAdapter({
    required GlobeFixture fixture,
    required GlobePocController controller,
  }) {
    return CandidateAEngineAdapter(fixture: fixture, controller: controller);
  }
}

class CandidateAEngineAdapter implements GlobeEngineAdapter {
  CandidateAEngineAdapter({required this.fixture, required this.controller});

  final GlobeFixture fixture;
  final GlobePocController controller;
  final ValueNotifier<GlobeProbeResult> _probe = ValueNotifier(
    GlobeProbeResult.unknown,
  );

  @override
  GlobeCandidateKind get candidate => GlobeCandidateKind.candidateA;

  @override
  String get displayName => 'Candidate A · three_js';

  @override
  ValueNotifier<GlobeProbeResult> get probeResult => _probe;

  @override
  Widget buildRenderer(BuildContext context) {
    return CandidateAThreeJsView(
      fixture: fixture,
      controller: controller,
      probeResult: _probe,
    );
  }

  @override
  Future<void> initialize() async {
    _probe.value = const GlobeProbeResult(
      ready: true,
      summary: 'three_js bootstrapped',
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

class CandidateAThreeJsView extends StatefulWidget {
  const CandidateAThreeJsView({
    required this.fixture,
    required this.controller,
    required this.probeResult,
    super.key,
  });

  final GlobeFixture fixture;
  final GlobePocController controller;
  final ValueNotifier<GlobeProbeResult> probeResult;

  @override
  State<CandidateAThreeJsView> createState() => _CandidateAThreeJsViewState();
}

class _CandidateAThreeJsViewState extends State<CandidateAThreeJsView> {
  late final three.ThreeJS threeJs;
  three.Mesh? earthMesh;
  three.Points? markerPoints;
  final List<three.Line> routeLines = [];
  String? highlightedCountry;
  double _memorySampleAccumulator = 0;

  @override
  void initState() {
    super.initState();
    threeJs = three.ThreeJS(
      onSetupComplete: () {
        if (mounted) {
          setState(() {});
        }
      },
      setup: _setupScene,
    );
  }

  @override
  void dispose() {
    threeJs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => threeJs.build();

  Future<void> _setupScene() async {
    try {
      threeJs.scene = three.Scene();
      threeJs.scene.background = tmath.Color.fromHex32(0x04101a);
      threeJs.camera = three.PerspectiveCamera(
        38,
        threeJs.width / threeJs.height,
        0.1,
        100,
      );

      final ambient = three.AmbientLight(0xffffff, 0.75);
      final sun = three.DirectionalLight(0xffffff, 1.0)
        ..position.setValues(4, 4, 6);
      threeJs.scene.add(ambient);
      threeJs.scene.add(sun);

      if (!_disableEarthMesh) {
        earthMesh = _buildEarthMesh();
        threeJs.scene.add(earthMesh!);
      }
      if (!_disableMarkers) {
        markerPoints = _buildMarkers();
        threeJs.scene.add(markerPoints!);
      }
      if (!_disableRoutes) {
        for (final route in widget.fixture.routes) {
          final line = _buildRoute(route);
          routeLines.add(line);
          threeJs.scene.add(line);
        }
      }

      threeJs.addAnimationEvent((dt) {
        _syncScene(dt);
        widget.controller.recordFrame(dt * 1000);
        _memorySampleAccumulator += dt;
        if (_memorySampleAccumulator >= 1) {
          _memorySampleAccumulator = 0;
          widget.controller.recordMemorySample(WebMemoryProbe.usedHeapBytes());
        }
      });
    } catch (error, stackTrace) {
      widget.probeResult.value = GlobeProbeResult(
        ready: false,
        summary: 'three_js setup failed',
        blockingIssues: [error.toString()],
      );
      debugPrint('Candidate A setup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  three.Mesh _buildEarthMesh() {
    final material = three.MeshPhongMaterial({
      if (!_disableTexture)
        three.MaterialProperty.map: three.DataTexture(
          tmath.Uint8Array.fromList(widget.fixture.textureBundle.earthRgba),
          widget.fixture.textureBundle.width,
          widget.fixture.textureBundle.height,
          tmath.RGBAFormat,
          tmath.UnsignedByteType,
        )..needsUpdate = true,
      if (_disableTexture) three.MaterialProperty.color: 0x2B6EA6,
      three.MaterialProperty.shininess: 8.0,
      three.MaterialProperty.specular: tmath.Color.fromHex32(0x223344),
      three.MaterialProperty.side: tmath.DoubleSide,
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
      ..setAttributeFromString(
        'position',
        three.Float32BufferAttribute.fromList(positions, 3, false),
      );
    final material = three.PointsMaterial({
      three.MaterialProperty.color: 0xffffff,
      three.MaterialProperty.size: 0.055,
      three.MaterialProperty.sizeAttenuation: true,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.88,
    });
    return three.Points(geometry, material);
  }

  three.Line _buildRoute(TravelRoute route) {
    final geometry = three.BufferGeometry()..setFromPoints(route.points);
    final material = three.LineBasicMaterial({
      three.MaterialProperty.color: route.transportType == 'flight'
          ? 0xFFD678FF
          : 0xFF70E4FF,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.42,
    });
    return three.Line(geometry, material);
  }

  void _syncScene(double dt) {
    final pose = widget.controller.cameraPose;
    final cameraPosition = GlobeMath.cameraPosition(pose);
    threeJs.camera.position.setValues(
      cameraPosition.x,
      cameraPosition.y,
      cameraPosition.z,
    );
    threeJs.camera.lookAt(tmath.Vector3.zero());

    final selection = widget.controller.selectedCountryCode;
    if (selection != highlightedCountry) {
      highlightedCountry = selection;
      final earth = earthMesh;
      if (earth != null) {
        final earthMaterial = earth.material as three.MeshPhongMaterial;
        earthMaterial.emissive = selection == null
            ? tmath.Color.fromHex32(0x000000)
            : tmath.Color.fromHex32(0x153030);
      }
    }

    final playhead = widget.controller.playhead;
    for (int index = 0; index < routeLines.length; index++) {
      final line = routeLines[index];
      final material = line.material as three.LineBasicMaterial;
      final progress = index / routeLines.length;
      material.opacity = widget.controller.playing
          ? (progress <= playhead ? 0.95 : 0.12)
          : 0.42 + 0.18 * (index % 5 == 0 ? 1 : 0);
    }

    markerPoints?.rotation.y += dt * 0.02;
  }
}
