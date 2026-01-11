// Copyright (c) 2026 Praveen Kumar. All rights reserved.
// Use of this source code is governed by a Non-Commercial license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Paints a spotlight effect highlighting a specific target rectangle.
class SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final Color overlayColor;
  final Color highlightColor;
  final double strokeWidth;

  SpotlightPainter({
    required this.targetRect,
    this.overlayColor = const Color(0xAA000000),
    this.highlightColor = Colors.yellowAccent,
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the darkened overlay over the entire screen
    final paint = Paint()..color = overlayColor;
    
    // Create a path for the whole screen
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a path for the target "hole"
    final targetPath = Path()
      ..addRRect(RRect.fromRectAndRadius(targetRect, const Radius.circular(8)));

    // Subtract the hole from the background
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      targetPath,
    );

    canvas.drawPath(overlayPath, paint);

    // 2. Draw a glowing border around the target
    final borderPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    canvas.drawRRect(
      RRect.fromRectAndRadius(targetRect, const Radius.circular(8)), 
      borderPaint
    );
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
           oldDelegate.overlayColor != overlayColor ||
           oldDelegate.highlightColor != highlightColor;
  }
}
