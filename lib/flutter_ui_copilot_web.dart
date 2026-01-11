// Copyright (c) 2026 Praveen Kumar. All rights reserved.
// Use of this source code is governed by a Non-Commercial license that can be
// found in the LICENSE file.

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'flutter_ui_copilot_platform_interface.dart';

/// A web implementation of the FlutterUiCopilotPlatform of the FlutterUiCopilot plugin.
class FlutterUiCopilotWeb extends FlutterUiCopilotPlatform {
  /// Constructs a FlutterUiCopilotWeb
  FlutterUiCopilotWeb();

  static void registerWith(Registrar registrar) {
    FlutterUiCopilotPlatform.instance = FlutterUiCopilotWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
