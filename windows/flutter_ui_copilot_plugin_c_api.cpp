#include "include/flutter_ui_copilot/flutter_ui_copilot_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_ui_copilot_plugin.h"

void FlutterUiCopilotPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_ui_copilot::FlutterUiCopilotPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
