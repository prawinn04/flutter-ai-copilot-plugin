// Copyright (c) 2026 Praveen Kumar. All rights reserved.
// Use of this source code is governed by a Non-Commercial license that can be
// found in the LICENSE file.

import 'dart:typed_data';

/// Abstract class representing an AI provider.
abstract class LLMProvider {
  /// Sends a message and an optional screenshot to the AI using the given API key.
  /// Returns a JSON string response.
  Future<String> sendMessage(
    String prompt, 
    Uint8List? screenshot, 
    String apiKey,
    {Map<String, dynamic>? extraContext}
  );
}
