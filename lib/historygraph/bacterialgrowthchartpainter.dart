import 'package:bacteria_simulation/models/bactriagrowthhistoryelement.dart';
import 'package:flutter/material.dart';

class BacteriaGrowthChartPainter extends CustomPainter {
  const BacteriaGrowthChartPainter({
    required this.historyElements,
    required this.currentTick,
    required this.currentBacteriaAmount,
  });

  final List<BacteriaGrowthHistoryElement> historyElements;
  final int currentTick;
  final int currentBacteriaAmount;

  @override
  void paint(Canvas canvas, Size size) {
    if (historyElements.isEmpty) return;

    final Paint paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < historyElements.length; i++) {
      final BacteriaGrowthHistoryElement element = historyElements[i];
      final double x = element.tickNumber / currentTick * size.width;
      final double y =
          element.amountOfBacteria / currentBacteriaAmount * size.height;

      if (i == 0) continue;

      final BacteriaGrowthHistoryElement previousElement =
          historyElements[i - 1];
      final double previousX =
          previousElement.tickNumber / currentTick * size.width;
      final double previousY = previousElement.amountOfBacteria /
          currentBacteriaAmount *
          size.height;

      canvas.drawLine(
        Offset(previousX, size.height - previousY),
        Offset(x, size.height - y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
