// Copyright (c) 2026 Praveen Kumar. All rights reserved.
// Use of this source code is governed by a Non-Commercial license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'services/ai_service.dart';
import 'overlay/spotlight_painter.dart';

/// A class to hold registry info for a tagged widget.
class TagMetadata {
  final String id;
  final String description;
  final GlobalKey key;
  final VoidCallback? onPerformAction;

  TagMetadata({
    required this.id,
    required this.description,
    required this.key,
    this.onPerformAction,
  });
}

/// The main provider widget that manages state (API keys, tags, screenshotting).
class CopilotProvider extends StatefulWidget {
  final Widget child;
  final String apiKey;
  final LLMProvider aiProvider;

  const CopilotProvider({
    Key? key,
    required this.child,
    required this.apiKey,
    required this.aiProvider,
  }) : super(key: key);

  static CopilotState of(BuildContext context) {
    final _CopilotInherited? inherited =
        context.dependOnInheritedWidgetOfExactType<_CopilotInherited>();
    assert(inherited != null, 'No CopilotProvider found in context');
    return inherited!.data;
  }

  @override
  State<CopilotProvider> createState() => CopilotState();
}

class CopilotState extends State<CopilotProvider> {
  final Map<String, TagMetadata> _registry = {};
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  
  // State for highlighting
  String? _highlightedId;
  Rect? _highlightRect;
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  String? get highlightedId => _highlightedId;

  void registerTag(TagMetadata tag) {
    _registry[tag.id] = tag;
  }

  void unregisterTag(String id) {
    _registry.remove(id);
  }

  /// Sends a message to the AI, capturing the screen context.
  Future<void> sendMessage(String text) async {
    setState(() => _isLoading = true);

    try {
      // 1. Capture screen
      final screenshot = await _capturePng();
      
      // 2. Prepare Widget context (JSON description of tags)
      final widgetTreeDesc = _registry.values.map((t) {
        return {
          "id": t.id,
          "description": t.description,
        };
      }).toList();

      // 3. Send to AI
      final responseJson = await widget.aiProvider.sendMessage(
        text,
        screenshot,
        widget.apiKey,
        extraContext: {"widgets": widgetTreeDesc},
      );

      // 4. Handle Action
      _handleAiResponse(responseJson);

    } catch (e) {
      debugPrint("Copilot Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary? boundary = _repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      
      // Pixel ratio can be adjusted for performance vs quality
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Screenshot failed: $e");
      return null;
    }
  }

  void _handleAiResponse(String response) {
    try {
      Map<String, dynamic> data;
      
      // 1. Try to find JSON block
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
      
      if (jsonMatch != null) {
        // Found potential JSON
        String jsonStr = jsonMatch.group(0)!;
        // Clean up markdown if inside the match
        jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
        data = jsonDecode(jsonStr);
      } else {
        // No JSON found, treat as simple text message
        // Maybe we want to show a snackbar or just log it?
        // For now, let's assume it's just a message without action.
        debugPrint("AI (Text only): $response");
        return; 
      }

      final String? action = data['action'];
      final String? targetId = data['targetId'];
      final String? message = data['message']; // Usage for TTS/Snackbar later
      
      if (message != null) {
         debugPrint("AI Message: $message");
         // Could show a snackbar here if desired
      }
      
      if (action == 'highlight' && targetId != null) {
        highlightWidget(targetId);
      } else if (action == 'remove_highlight') {
        clearHighlight();
      } else if ((action == 'click' || action == 'tap') && targetId != null) {
        // Highlight first for feedback, then perform action
        highlightWidget(targetId);
        
        // Short delay to show highlight before action
        Future.delayed(const Duration(milliseconds: 500), () {
          performAction(targetId);
          clearHighlight(); 
        });
      }
      
      // Expand for other actions like 'navigation', 'fill_text' etc.

    } catch (e) {
      debugPrint("Failed to parse AI response: $e");
      debugPrint("Raw Response: $response");
    }
  }

  void highlightWidget(String id) {
    final tag = _registry[id];
    if (tag != null) {
      final RenderBox? box = tag.key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        // finding position relative to the provider's boundary
        // We'll use the offset from the screen top-left for now or implement coordinate conversion
        final offset = box.localToGlobal(Offset.zero);
        final size = box.size;
        
        setState(() {
          _highlightedId = id;
          _highlightRect = offset & size;
        });
        return;
      }
    }
    debugPrint("Widget with id $id not found or not visible.");
  }

  void performAction(String id) {
    final tag = _registry[id];
    if (tag != null && tag.onPerformAction != null) {
      tag.onPerformAction!();
      debugPrint("Action performed on $id");
    } else {
      debugPrint("No executable action found for $id");
    }
  }
  
  void clearHighlight() {
    setState(() {
      _highlightedId = null;
      _highlightRect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CopilotInherited(
      data: this,
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [
          // Wrap child in RepaintBoundary for screenshots
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: widget.child,
          ),

          // Overlay layer
          if (_highlightRect != null)
            Positioned.fill(
              child: IgnorePointer( // Let touches pass through the overlay
                 ignoring: true, // If we want to block interaction outside highlight, change this logic
                 child: CustomPaint(
                   painter: SpotlightPainter(targetRect: _highlightRect!),
                 ),
              ),
            ),
            
          // Loading indicator
          if (_isLoading)
            const Positioned(
              top: 50,
              right: 20,
              child: SafeArea(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _CopilotInherited extends InheritedWidget {
  final CopilotState data;

  const _CopilotInherited({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_CopilotInherited old) => true; 
}
