import 'dart:html' as html;

void applyWebGlobeDomTweaksImpl() {
  final canvas = html.document.querySelector('#canvas-id');
  if (canvas != null) {
    canvas.style.pointerEvents = 'none';
  }
}
