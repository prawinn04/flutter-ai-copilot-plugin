// Copyright (c) 2026 Praveen Kumar. All rights reserved.
// Use of this source code is governed by a Non-Commercial license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_ui_copilot_platform_interface.dart';

/// An implementation of [FlutterUiCopilotPlatform] that uses method channels.
class MethodChannelFlutterUiCopilot extends FlutterUiCopilotPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ui_copilot');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
