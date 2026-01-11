// Copyright (c) 2026 Praveen Kumar. All rights reserved.
// Use of this source code is governed by a Non-Commercial license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'ai_service.dart';

/// Implementation for OpenAI (GPT-4o / Vision) or compatible APIs (Hugging Face, LocalAI).
class OpenAIProvider implements LLMProvider {
  final String model;
  final String baseUrl;
  final bool supportsImages;
  
  OpenAIProvider({
    this.model = 'gpt-4o',
    this.baseUrl = 'https://api.openai.com/v1/chat/completions',
    this.supportsImages = true,
  });

  @override
  Future<String> sendMessage(
    String prompt,
    Uint8List? screenshot,
    String apiKey,
    {Map<String, dynamic>? extraContext}
  ) async {
    final uri = Uri.parse(baseUrl);
    
    // Construct the context string from widgets
    String contextStr = "";
    if (extraContext != null && extraContext.containsKey('widgets')) {
       contextStr = "\n\nAvailable Interactive Elements (Widgets):\n${jsonEncode(extraContext['widgets'])}";
    }

    // System prompt to guide the AI
    final systemPrompt = """
You are a UI Copilot. You can see the screen and the list of available widgets with their IDs.
Your goal is to help the user navigate or understand the UI.
When you want to reference a widget, strictly output JSON.
Supported Actions:
- "highlight": { "action": "highlight", "targetId": "WIDGET_ID", "message": "Here is the button." }
- "click": { "action": "click", "targetId": "WIDGET_ID", "message": "Clicking the button." }
- "remove_highlight": { "action": "remove_highlight", "message": "Done." }

If the user asks to "click", "tap", "press", or specifically *perform* a task (e.g., "increment counter", "go back"), you MUST use the "click" action on the most relevant widget.
Do NOT just describe how to do it. Just do it.

Example:
User: "Increase the count"
Response: { "action": "click", "targetId": "increment_btn", "message": "Clicking increment button." }

If no specific action is needed, just reply with standard text in "message".
Always wrap your final answer in JSON: { "message": "...", "action": "...", "targetId": "..." }
""";

    final contentList = <Map<String, dynamic>>[
      {"type": "text", "text": "$prompt $contextStr"},
    ];

    if (screenshot != null && supportsImages) {
      contentList.add({
        "type": "image_url",
        "image_url": {
          "url": "data:image/png;base64,${base64Encode(screenshot)}"
        }
      });
    }

    final List<Map<String, dynamic>> messages = [
      {
        "role": "system", 
        "content": systemPrompt
      },
      {
        "role": "user",
        "content": contentList
      }
    ];

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": model,
        "messages": messages,
        "max_tokens": 512, // Increased from 50 to allow full JSON responses
        "temperature": 0.7,
        "stream": false,
        // "response_format": { "type": "json_object" } // Some HF models fail with this
        "store": true // optional
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenAI/HF Error: ${response.statusCode} - ${response.body}');
    }
  }
}

/// Implementation for Google Gemini.
class GeminiProvider implements LLMProvider {
  final String model;
  
  GeminiProvider({this.model = 'gemini-1.5-flash'});

  @override
  Future<String> sendMessage(
      String prompt,
      Uint8List? screenshot,
      String apiKey,
      {Map<String, dynamic>? extraContext}
  ) async {
    final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');

    String contextStr = "";
    if (extraContext != null && extraContext.containsKey('widgets')) {
       contextStr = "\n\nAvailable Interactive Elements (Widgets):\n${jsonEncode(extraContext['widgets'])}";
    }

    final systemPrompt = """
You are a UI Copilot.
Always reply in JSON: { "message": "...", "action": "...", "targetId": "..." }
Supported Actions: highlight, remove_highlight.
""";

    final Map<String, dynamic> requestBody = {
      "system_instruction": {
        "parts": [{"text": systemPrompt}]
      },
      "contents": [
        {
          "parts": [
            {"text": "$prompt $contextStr"},
            if (screenshot != null)
              {
                "inline_data": {
                  "mime_type": "image/png",
                  "data": base64Encode(screenshot)
                }
              }
          ]
        }
      ],
      "generationConfig": {
         "response_mime_type": "application/json"
      }
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Gemini response structure
      try {
        return data['candidates'][0]['content']['parts'][0]['text'];
      } catch (e) {
        throw Exception("Failed to parse Gemini response: $data");
      }
    } else {
      throw Exception('Gemini Error: ${response.statusCode} - ${response.body}');
    }
  }
}
