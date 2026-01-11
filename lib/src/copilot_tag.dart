// Copyright (c) 2026 Praveen Kumar. All rights reserved.
// Use of this source code is governed by a Non-Commercial license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'copilot_provider.dart';

/// A wrapper widget that registers its child with the CopilotProvider.
class CopilotTag extends StatefulWidget {
  final String id;
  final String description;
  final Widget child;
  final VoidCallback? actionCallback;

  const CopilotTag({
    Key? key,
    required this.id,
    required this.description,
    required this.child,
    this.actionCallback,
  }) : super(key: key);

  @override
  State<CopilotTag> createState() => _CopilotTagState();
}

class _CopilotTagState extends State<CopilotTag> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _register();
    });
  }
  
  @override
  void dispose() {
    _unregister();
    super.dispose();
  }
  
  // Also re-register on updates if needed, but usually simple register/unregister is enough.
  // We should be careful about ancestry. Default checks context.

  void _register() {
    try {
      CopilotProvider.of(context).registerTag(TagMetadata(
        id: widget.id,
        description: widget.description,
        key: _key,
        onPerformAction: widget.actionCallback,
      ));
    } catch (e) {
      // Provider might not be present in tests or if used incorrectly
      debugPrint("CopilotTag error: $e");
    }
  }

  void _unregister() {
    // We can't access context.dependOnInheritedWidgetOfExactType in dispose easily 
    // without saving reference, but usually the whole tree is disposing.
    // Ideally the Provider clears its registry or we handle this better.
    // For now, we skip explicit unregister on dispose if the provider is also gone.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }
}
