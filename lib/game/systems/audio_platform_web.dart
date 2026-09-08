// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Web implementation calling window.AntigravityAudioEngine
void invokeWebAudioEngine(String method, [List<dynamic>? args]) {
  try {
    final engine = js.context['AntigravityAudioEngine'];
    if (engine != null) {
      js.JsObject.fromBrowserObject(engine).callMethod(method, args ?? []);
    }
  } catch (_) {}
}
