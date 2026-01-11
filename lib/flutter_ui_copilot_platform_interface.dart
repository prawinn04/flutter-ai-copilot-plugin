// Copyright (c) 2026 Praveen Kumar. All rights reserved.
// Use of this source code is governed by a Non-Commercial license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_ui_copilot_method_channel.dart';

abstract class FlutterUiCopilotPlatform extends PlatformInterface {
  /// Constructs a FlutterUiCopilotPlatform.
  FlutterUiCopilotPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterUiCopilotPlatform _instance = MethodChannelFlutterUiCopilot();

  /// The default instance of [FlutterUiCopilotPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterUiCopilot].
  static FlutterUiCopilotPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterUiCopilotPlatform] when
  /// they register themselves.
  static set instance(FlutterUiCopilotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
