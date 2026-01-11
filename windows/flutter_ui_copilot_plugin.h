#ifndef FLUTTER_PLUGIN_FLUTTER_UI_COPILOT_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_UI_COPILOT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_ui_copilot {

class FlutterUiCopilotPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterUiCopilotPlugin();

  virtual ~FlutterUiCopilotPlugin();

  // Disallow copy and assign.
  FlutterUiCopilotPlugin(const FlutterUiCopilotPlugin&) = delete;
  FlutterUiCopilotPlugin& operator=(const FlutterUiCopilotPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_ui_copilot

#endif  // FLUTTER_PLUGIN_FLUTTER_UI_COPILOT_PLUGIN_H_
