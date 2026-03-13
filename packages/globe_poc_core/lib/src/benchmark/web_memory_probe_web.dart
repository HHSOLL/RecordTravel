import 'dart:html' as html;
import 'dart:js_util' as js_util;

int? usedHeapBytes() {
  final performance = html.window.performance;
  final memory = js_util.getProperty<Object?>(performance, 'memory');
  if (memory == null) {
    return null;
  }
  final used = js_util.getProperty<Object?>(memory, 'usedJSHeapSize');
  if (used is num) {
    return used.toInt();
  }
  return null;
}
