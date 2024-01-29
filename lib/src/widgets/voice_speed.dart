import 'dart:math';

import 'package:flutter/material.dart';

class VoicePercent extends StatelessWidget {
  const VoicePercent({super.key, required this.percentage, required this.radius});

  final double percentage;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PercentagePainter(percentage: percentage),
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Center(
          child: Text(
            percentage.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class PercentagePainter extends CustomPainter {
  final double percentage;

  PercentagePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;

    const double strokeWidth = 10.0;
    final double center = size.width / 2;
    final double angle = 2 * pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(center, center), radius: center - strokeWidth),
      -pi / 2,
      angle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
