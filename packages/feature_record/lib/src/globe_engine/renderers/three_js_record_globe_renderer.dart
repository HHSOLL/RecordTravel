import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:vector_math/vector_math_64.dart' as vm;

import '../../globe/domain/entities/record_globe_country.dart';
import '../../globe/domain/entities/record_globe_scene_spec.dart';
import '../controllers/camera_controller.dart';
import '../controllers/gesture_controller.dart';
import '../record_globe_camera_state.dart';
import '../record_globe_engine.dart';
import '../record_globe_engine_config.dart';

class ThreeJsRecordGlobeRenderer extends RecordGlobeEngine {
  const ThreeJsRecordGlobeRenderer();

  @override
  Widget buildStage(
    BuildContext context, {
    required RecordGlobeEngineConfig config,
    ValueChanged<String?>? onCountrySelected,
  }) {
    return _ThreeJsRecordGlobeStage(
      key: ValueKey(
        '${config.style.name}:${config.scene?.countries.length ?? 0}',
      ),
      config: config,
      onCountrySelected: onCountrySelected,
    );
  }
}

class _ThreeJsRecordGlobeStage extends StatefulWidget {
  const _ThreeJsRecordGlobeStage({
    super.key,
    required this.config,
    this.onCountrySelected,
  });

  final RecordGlobeEngineConfig config;
  final ValueChanged<String?>? onCountrySelected;

  @override
  State<_ThreeJsRecordGlobeStage> createState() =>
      _ThreeJsRecordGlobeStageState();
}

class _ThreeJsRecordGlobeStageState extends State<_ThreeJsRecordGlobeStage> {
  static const double _globeRadius = 1;
  static const double _markerAltitude = 1.022;
  static const double _baseCameraDistance = 3.1;
  static const int _earthSegments = 64;
  static const int _markerSegments = 16;

  final RecordGlobeCameraController _cameraController =
      const RecordGlobeCameraController();
  final RecordGlobeGestureController _gestureController =
      const RecordGlobeGestureController();
  final three.Raycaster _raycaster = three.Raycaster();
  final Map<String, _MarkerHandle> _markersByCountry =
      <String, _MarkerHandle>{};

  late final three.ThreeJS _threeJs;

  late three.Scene _scene;
  late three.PerspectiveCamera _camera;
  late three.Group _globeRoot;
  RecordGlobeCameraState _cameraState = const RecordGlobeCameraState(
    yaw: 0.3,
    pitch: -0.18,
    zoom: 1,
  );
  three.Texture? _baseTexture;
  three.Texture? _borderTexture;

  bool _setupComplete = false;
  bool _gestureActive = false;
  double _gestureStartZoom = 1;
  Offset _lastFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _threeJs = three.ThreeJS(
      onSetupComplete: _handleSetupComplete,
      setup: _setupScene,
      settings: three.Settings(
        renderOptions: const {
          'antialias': true,
          'alpha': true,
          'samples': 4,
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _ThreeJsRecordGlobeStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_setupComplete) {
      return;
    }

    final previousScene = oldWidget.config.scene;
    final nextScene = widget.config.scene;
    final styleChanged = oldWidget.config.style != widget.config.style;
    final countriesChanged =
        !_hasSameCountries(previousScene?.countries, nextScene?.countries);

    if (styleChanged || countriesChanged) {
      _rebuildSceneObjects(nextScene);
      return;
    }

    if (previousScene?.selectedCountryCode != nextScene?.selectedCountryCode) {
      _applyMarkerSelection(nextScene?.selectedCountryCode);
    }

    if (previousScene?.focusedCountryCode != nextScene?.focusedCountryCode) {
      _focusOnCountry(nextScene?.focusedCountryCode, animate: true);
    }
  }

  @override
  void dispose() {
    if (_setupComplete) {
      _clearSceneObjects();
    } else {
      _disposeTextures();
    }
    try {
      _threeJs.dispose();
    } catch (_) {
      // Widget tests can dispose the stage before three_js finishes setup.
    }
    three.loading.clear();
    super.dispose();
  }

  Future<void> _setupScene() async {
    _camera = three.PerspectiveCamera(
      45,
      _threeJs.width / _threeJs.height,
      0.1,
      100,
    );
    _camera.position.setValues(
      0,
      0,
      _cameraDistanceForZoom(_cameraState.zoom),
    );

    _scene = three.Scene();
    _globeRoot = three.Group();
    _scene.add(_globeRoot);

    _scene.add(three.AmbientLight(0xffffff, 1.4));

    final keyLight = three.DirectionalLight(0xffffff, 1.2);
    keyLight.position.setValues(2.2, 1.8, 3.5);
    _scene.add(keyLight);

    final rimLight = three.DirectionalLight(0x8fb9ff, 0.6);
    rimLight.position.setValues(-3.5, -1.4, -2.2);
    _scene.add(rimLight);

    _threeJs.camera = _camera;
    _threeJs.scene = _scene;

    await _rebuildSceneObjects(widget.config.scene);
    _threeJs.addAnimationEvent(_tick);
  }

  void _handleSetupComplete() {
    _setupComplete = true;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _rebuildSceneObjects(RecordGlobeSceneSpec? scene) async {
    _clearSceneObjects();

    if (scene == null) {
      return;
    }

    final textureLoader = three.TextureLoader(flipY: true);
    final baseTexture = await textureLoader.fromAsset(
      scene.assetSet.baseEarthTextureAsset,
    );
    final borderTexture = await textureLoader.fromAsset(
      scene.assetSet.borderOverlayTextureAsset,
    );

    _baseTexture = baseTexture;
    _borderTexture = borderTexture;

    if (baseTexture != null) {
      baseTexture.needsUpdate = true;
    }
    if (borderTexture != null) {
      borderTexture.needsUpdate = true;
    }

    final earthMaterial = three.MeshPhongMaterial.fromMap({
      'map': baseTexture,
      'shininess': scene.style == RecordGlobeStyle.dark ? 10.0 : 4.0,
      'specular': scene.style == RecordGlobeStyle.dark ? 0x09111f : 0xd8dee9,
    });
    final earthMesh = three.Mesh(
      three.SphereGeometry(_globeRadius, _earthSegments, _earthSegments),
      earthMaterial,
    );
    _globeRoot.add(earthMesh);

    final borderMaterial = three.MeshPhongMaterial.fromMap({
      'map': borderTexture,
      'transparent': true,
      'opacity': scene.style == RecordGlobeStyle.dark ? 0.42 : 0.28,
      'side': three.DoubleSide,
      'shininess': 0.0,
    });
    final borderMesh = three.Mesh(
      three.SphereGeometry(
        _globeRadius * 1.002,
        _earthSegments,
        _earthSegments,
      ),
      borderMaterial,
    );
    _globeRoot.add(borderMesh);

    final atmosphereMaterial = three.MeshPhongMaterial.fromMap({
      'color': scene.style == RecordGlobeStyle.dark ? 0x60a5fa : 0x93c5fd,
      'transparent': true,
      'opacity': scene.style == RecordGlobeStyle.dark ? 0.16 : 0.10,
      'side': three.DoubleSide,
      'shininess': 0.0,
    });
    final atmosphereMesh = three.Mesh(
      three.SphereGeometry(_globeRadius * 1.08, 48, 32),
      atmosphereMaterial,
    );
    _globeRoot.add(atmosphereMesh);

    for (final country in scene.countries) {
      final marker = _buildMarker(country, scene.style);
      _markersByCountry[country.code] = marker;
      _globeRoot.add(marker.mesh);
    }

    final focusCountryCode = scene.focusedCountryCode ??
        scene.selectedCountryCode ??
        scene.initialCountryCode;
    if (focusCountryCode != null) {
      _focusOnCountry(focusCountryCode, animate: false);
    } else {
      _applyCameraState(_cameraState);
    }
    _applyMarkerSelection(scene.selectedCountryCode);

    if (mounted) {
      setState(() {});
    }
  }

  void _clearSceneObjects() {
    _markersByCountry.clear();
    _disposeTextures();
    if (!_setupComplete && _globeRoot.children.isEmpty) {
      return;
    }
    final children = List<three.Object3D>.from(_globeRoot.children);
    for (final child in children) {
      _globeRoot.remove(child);
      _disposeObject(child);
    }
  }

  void _disposeObject(three.Object3D object) {
    for (final child in List<three.Object3D>.from(object.children)) {
      object.remove(child);
      _disposeObject(child);
    }

    final dynamic renderObject = object;
    renderObject.geometry?.dispose();

    final material = renderObject.material;
    if (material is List) {
      for (final entry in material) {
        entry.dispose();
      }
      return;
    }
    material?.dispose();
  }

  void _disposeTextures() {
    _baseTexture?.dispose();
    _borderTexture?.dispose();
    _baseTexture = null;
    _borderTexture = null;
  }

  _MarkerHandle _buildMarker(
    RecordGlobeCountry country,
    RecordGlobeStyle style,
  ) {
    final point = _latLngToUnitVector(
      country.anchorLatitude,
      country.anchorLongitude,
    );
    final radius =
        (0.028 + (country.visitCount.clamp(1, 6) - 1) * 0.004).toDouble();
    final material = three.MeshPhongMaterial.fromMap({
      'color': style == RecordGlobeStyle.dark ? 0xf8fafc : 0x0f172a,
      'emissive': style == RecordGlobeStyle.dark ? 0x60a5fa : 0xffffff,
      'emissiveIntensity': style == RecordGlobeStyle.dark ? 0.22 : 0.08,
      'transparent': true,
      'opacity': 0.96,
    });
    final mesh = three.Mesh(
      three.SphereGeometry(radius, _markerSegments, _markerSegments),
      material,
    );
    mesh.position.setValues(
      point.x * _markerAltitude,
      point.y * _markerAltitude,
      point.z * _markerAltitude,
    );
    mesh.userData['countryCode'] = country.code;
    return _MarkerHandle(mesh: mesh);
  }

  bool _hasSameCountries(
    List<RecordGlobeCountry>? previous,
    List<RecordGlobeCountry>? next,
  ) {
    if (identical(previous, next)) {
      return true;
    }
    if (previous == null || next == null || previous.length != next.length) {
      return false;
    }
    for (var index = 0; index < previous.length; index += 1) {
      final prev = previous[index];
      final current = next[index];
      if (prev.code != current.code ||
          prev.visitCount != current.visitCount ||
          prev.anchorLatitude != current.anchorLatitude ||
          prev.anchorLongitude != current.anchorLongitude) {
        return false;
      }
    }
    return true;
  }

  void _tick(double dt) {
    if (!_setupComplete) {
      return;
    }

    final aspect =
        _threeJs.height == 0 ? 1.0 : _threeJs.width / _threeJs.height;
    if (_camera.aspect != aspect) {
      _camera.aspect = aspect;
      _camera.updateProjectionMatrix();
    }

    var camera = _cameraState;
    if (!_gestureActive) {
      camera = _settleCamera(camera, dt);
    }

    if (!_gestureActive &&
        widget.config.scene?.selectedCountryCode == null &&
        camera.targetYaw == null &&
        camera.targetPitch == null) {
      camera = camera.copyWith(yaw: _wrapAngle(camera.yaw - dt * 0.18));
    }

    _setCamera(camera);
  }

  void _setCamera(RecordGlobeCameraState camera) {
    _cameraState = camera;
    _applyCameraState(camera);
  }

  RecordGlobeCameraState _settleCamera(
    RecordGlobeCameraState camera,
    double dt,
  ) {
    var next = camera;
    var targetYaw = camera.targetYaw;
    var targetPitch = camera.targetPitch;
    var targetZoom = camera.targetZoom;

    if (targetYaw != null) {
      final delta = _shortestAngleDelta(camera.yaw, targetYaw);
      final yaw = _wrapAngle(camera.yaw + delta * math.min(1, dt * 5.5));
      targetYaw = delta.abs() < 0.002 ? null : targetYaw;
      next = next.copyWith(yaw: yaw, targetYaw: targetYaw);
    }

    if (targetPitch != null) {
      final delta = targetPitch - next.pitch;
      final pitch = next.pitch + delta * math.min(1, dt * 5.5);
      targetPitch = delta.abs() < 0.002 ? null : targetPitch;
      next = next.copyWith(pitch: pitch, targetPitch: targetPitch);
    }

    if (targetZoom != null) {
      final delta = targetZoom - next.zoom;
      final zoom = next.zoom + delta * math.min(1, dt * 5.5);
      targetZoom = delta.abs() < 0.002 ? null : targetZoom;
      next = next.copyWith(zoom: zoom, targetZoom: targetZoom);
    }

    return next;
  }

  void _applyCameraState(RecordGlobeCameraState camera) {
    _globeRoot.rotation.y = camera.yaw;
    _globeRoot.rotation.x = camera.pitch;
    _camera.position.setValues(0, 0, _cameraDistanceForZoom(camera.zoom));
    _camera.lookAt(_scene.position);
    _camera.updateProjectionMatrix();
  }

  double _cameraDistanceForZoom(double zoom) {
    return (_baseCameraDistance / zoom).clamp(1.8, 5.0).toDouble();
  }

  void _focusOnCountry(String? countryCode, {required bool animate}) {
    final scene = widget.config.scene;
    if (scene == null || countryCode == null) {
      return;
    }

    RecordGlobeCountry? match;
    for (final country in scene.countries) {
      if (country.code == countryCode) {
        match = country;
        break;
      }
    }
    if (match == null) {
      return;
    }

    final targetYaw = _wrapAngle(vm.radians(match.anchorLongitude));
    final targetPitch = (-vm.radians(match.anchorLatitude)).clamp(
      -1.45,
      1.45,
    );
    final current = _cameraState;
    final focused = animate
        ? _cameraController.focusOn(
            current,
            yaw: targetYaw,
            pitch: targetPitch.toDouble(),
            zoom: current.zoom,
          )
        : current.copyWith(
            yaw: targetYaw,
            pitch: targetPitch.toDouble(),
            targetYaw: null,
            targetPitch: null,
            targetZoom: null,
          );
    _setCamera(focused);
  }

  void _applyMarkerSelection(String? selectedCountryCode) {
    final style = widget.config.style;
    for (final entry in _markersByCountry.entries) {
      final marker = entry.value;
      final material = marker.mesh.material as three.MeshPhongMaterial;
      final isSelected = entry.key == selectedCountryCode;
      material.color.setFrom(
        three.Color.fromHex32(
          isSelected
              ? (style == RecordGlobeStyle.dark ? 0xf59e0b : 0x2563eb)
              : (style == RecordGlobeStyle.dark ? 0xf8fafc : 0x0f172a),
        ),
      );
      material.emissive?.setFrom(
        three.Color.fromHex32(
          isSelected
              ? (style == RecordGlobeStyle.dark ? 0xfdba74 : 0xbfdbfe)
              : (style == RecordGlobeStyle.dark ? 0x60a5fa : 0xffffff),
        ),
      );
      material.emissiveIntensity = isSelected
          ? (style == RecordGlobeStyle.dark ? 0.7 : 0.28)
          : (style == RecordGlobeStyle.dark ? 0.22 : 0.08);
      material.needsUpdate = true;

      final scale = isSelected ? 1.55 : 1.0;
      marker.mesh.scale.setValues(scale, scale, scale);
    }
  }

  vm.Vector3 _latLngToUnitVector(double latitude, double longitude) {
    final lat = vm.radians(latitude);
    final lng = vm.radians(longitude);
    return vm.Vector3(
      math.cos(lat) * math.sin(lng),
      math.sin(lat),
      math.cos(lat) * math.cos(lng),
    );
  }

  double _wrapAngle(double value) {
    while (value > math.pi) {
      value -= math.pi * 2;
    }
    while (value < -math.pi) {
      value += math.pi * 2;
    }
    return value;
  }

  double _shortestAngleDelta(double current, double target) {
    return _wrapAngle(target - current);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _gestureActive = true;
    _gestureStartZoom = _cameraState.zoom;
    _lastFocalPoint = details.focalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    var camera = _cameraState;
    if (details.pointerCount > 1 || (details.scale - 1).abs() > 0.015) {
      final desiredZoom =
          (_gestureStartZoom * details.scale).clamp(0.75, 2.2).toDouble();
      final deltaZoom = desiredZoom - camera.zoom;
      camera = _cameraController.zoomBy(camera, deltaZoom: deltaZoom);
    } else {
      final delta = details.focalPoint - _lastFocalPoint;
      camera = _gestureController.drag(
        camera,
        deltaX: delta.dx,
        deltaY: delta.dy,
      );
      _lastFocalPoint = details.focalPoint;
    }
    _setCamera(camera);
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _gestureActive = false;
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.distanceSquared > 0) {
      final camera = _gestureController.fling(
        _cameraState,
        velocityX: velocity.dx,
        velocityY: velocity.dy,
      );
      _cameraState = camera;
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_setupComplete || _markersByCountry.isEmpty) {
      return;
    }

    final box = context.findRenderObject();
    if (box is! RenderBox || box.size.isEmpty) {
      return;
    }

    final point = details.localPosition;
    final ndc = three.Vector2(
      (point.dx / box.size.width) * 2 - 1,
      -((point.dy / box.size.height) * 2 - 1),
    );

    _raycaster.setFromCamera(ndc, _camera);
    final hits = _raycaster.intersectObjects(
      _markersByCountry.values.map((marker) => marker.mesh).toList(),
    );

    if (hits.isEmpty) {
      return;
    }

    final object = hits.first.object;
    final countryCode = object?.userData['countryCode'] as String?;
    if (countryCode == null) {
      return;
    }

    widget.onCountrySelected?.call(countryCode);
    _focusOnCountry(countryCode, animate: true);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.config.style;
    final background = style == RecordGlobeStyle.dark
        ? const [Color(0xFF0B1220), Color(0xFF09101D), Color(0xFF030712)]
        : const [Color(0xFFF8FBFF), Color(0xFFE8F2FF), Color(0xFFDCEAFE)];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      onTapUp: _handleTapUp,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: background,
            stops: const [0.18, 0.65, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: style == RecordGlobeStyle.dark
                  ? const Color(0x553B82F6)
                  : const Color(0x332563EB),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _threeJs.build(),
              if (!_setupComplete)
                const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkerHandle {
  const _MarkerHandle({
    required this.mesh,
  });

  final three.Mesh mesh;
}
