import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'record_globe.dart';
import 'record_globe_scene.dart';

class RecordGlobeWebView extends StatefulWidget {
  const RecordGlobeWebView({
    super.key,
    required this.size,
    required this.scene,
    this.selectedCountryCode,
    this.onCountrySelected,
    this.onCountryOpen,
  });

  final double size;
  final RecordGlobeScene scene;
  final String? selectedCountryCode;
  final ValueChanged<String>? onCountrySelected;
  final ValueChanged<String>? onCountryOpen;

  @override
  State<RecordGlobeWebView> createState() => _RecordGlobeWebViewState();
}

class _RecordGlobeWebViewState extends State<RecordGlobeWebView> {
  WebViewController? _controller;
  bool _pageReady = false;
  bool _readyProbeScheduled = false;
  String? _lastRuntimeError;
  String? _lastBootstrapJson;
  String? _lastSelectedCountryCode;

  @override
  void initState() {
    super.initState();
    if (WebViewPlatform.instance == null) {
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'RecordBridge',
        onMessageReceived: (javaScriptMessage) {
          final payload = _decodeMessage(javaScriptMessage.message);
          final type = payload['type'] as String?;
          final countryCode = payload['countryCode'] as String?;
          final errorMessage = payload['message'] as String?;
          if (countryCode == null) {
            if (type == 'ready') {
              _pageReady = true;
              _pushBootstrap(force: true);
            } else if (type == 'runtime_error' && errorMessage != null) {
              if (mounted) {
                setState(() {
                  _lastRuntimeError = errorMessage;
                });
              } else {
                _lastRuntimeError = errorMessage;
              }
              debugPrint('RecordGlobeWebView runtime error: $errorMessage');
            }
            return;
          }
          switch (type) {
            case 'country_selected':
              widget.onCountrySelected?.call(countryCode);
              break;
            case 'country_open':
              widget.onCountryOpen?.call(countryCode);
              break;
            case 'ready':
              _pageReady = true;
              _pushBootstrap(force: true);
              break;
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _scheduleReadyProbe();
          },
          onWebResourceError: (error) {
            final message =
                '${error.errorType?.name ?? 'unknown'}: ${error.description}';
            if (mounted) {
              setState(() {
                _lastRuntimeError = message;
              });
            } else {
              _lastRuntimeError = message;
            }
            debugPrint(
              'RecordGlobeWebView resource error: $message',
            );
          },
        ),
      )
      ..loadFlutterAsset('assets/web_globe/embed.html');
  }

  @override
  void didUpdateWidget(covariant RecordGlobeWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene != widget.scene ||
        oldWidget.selectedCountryCode != widget.selectedCountryCode) {
      _pushBootstrap();
    }
  }

  Map<String, dynamic> _decodeMessage(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Ignore malformed bridge payloads.
    }
    return const {};
  }

  Future<void> _pushBootstrap({bool force = false}) async {
    if (!_pageReady) {
      return;
    }

    final bootstrap = {
      'theme': widget.scene.style == RecordGlobeStyle.storybookLight
          ? 'light'
          : 'dark',
      'initialCountryCode': widget.scene.initialCountryCode,
      'selectedCountryCode':
          widget.selectedCountryCode ?? widget.scene.initialCountryCode,
      'selectableCountryCodes': widget.scene.selectableCountryCodes.toList(),
      'anchors': [
        for (final anchor in widget.scene.anchors)
          {
            'countryCode': anchor.countryCode,
            'countryName': anchor.countryName,
            'latitude': anchor.latitude,
            'longitude': anchor.longitude,
            'markerCount': anchor.markerCount,
            'color': _hexFromColor(anchor.color),
          },
      ],
    };

    final payload = jsonEncode(bootstrap);
    if (!force && payload == _lastBootstrapJson) {
      final selectedCountryCode = widget.selectedCountryCode;
      if (selectedCountryCode == _lastSelectedCountryCode) {
        return;
      }
    }

    _lastBootstrapJson = payload;
    _lastSelectedCountryCode = widget.selectedCountryCode;
    final controller = _controller;
    if (controller == null) {
      return;
    }
    try {
      await controller.runJavaScript('window.recordBootstrap($payload);');
      await controller.runJavaScript(
        'window.recordSetSelectedCountry(${jsonEncode(widget.selectedCountryCode)});',
      );
    } catch (_) {
      // Ignore transient JS timing issues and allow the next bridge-ready signal to retry.
    }
  }

  void _scheduleReadyProbe() {
    if (_readyProbeScheduled || _pageReady) {
      return;
    }
    _readyProbeScheduled = true;
    Future<void>(() async {
      final controller = _controller;
      if (controller == null) {
        _readyProbeScheduled = false;
        return;
      }
      for (var attempt = 0; attempt < 20 && mounted && !_pageReady; attempt++) {
        try {
          await controller.runJavaScript('''
            if (window.RecordBridge?.postMessage &&
                typeof window.recordBootstrap === 'function' &&
                typeof window.recordSetSelectedCountry === 'function') {
              window.RecordBridge.postMessage(JSON.stringify({ type: 'ready' }));
            }
          ''');
        } catch (_) {
          // Ignore and keep probing until the module script has initialized.
        }
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
      _readyProbeScheduled = false;
    });
  }

  String _hexFromColor(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode && defaultTargetPlatform == TargetPlatform.iOS) {
      return RecordGlobe(
        size: widget.size,
        scene: widget.scene,
        selectedCountryCode: widget.selectedCountryCode,
        onCountrySelected: widget.onCountrySelected,
        onCountryOpen: widget.onCountryOpen,
      );
    }

    final controller = _controller;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFF133A66),
            const Color(0xFF08101F),
          ],
          stops: const [0.18, 1],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331F7DFF),
            blurRadius: 36,
            spreadRadius: 2,
          ),
        ],
        shape: BoxShape.circle,
      ),
    );
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: controller == null
          ? fallback
          : Stack(
              fit: StackFit.expand,
              children: [
                WebViewWidget(
                  controller: controller,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
                if (_lastRuntimeError != null)
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xCC08101F),
                        borderRadius: BorderRadius.circular(widget.size / 2),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _lastRuntimeError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
