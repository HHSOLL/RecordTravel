import 'web_memory_probe_stub.dart'
    if (dart.library.html) 'web_memory_probe_web.dart'
    as impl;

class WebMemoryProbe {
  static int? usedHeapBytes() => impl.usedHeapBytes();
}
