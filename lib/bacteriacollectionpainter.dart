import 'package:bacteria_simulation/models/bacteria.dart';
import 'package:flutter/material.dart';

class Bacteriacollectionpainter extends CustomPainter {
  Bacteriacollectionpainter({required this.bacteriaList});
  final List<Bacteria> bacteriaList;
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    for (final Bacteria bacteria in bacteriaList) {
      final rect = Rect.fromLTWH(
        bacteria.x,
        bacteria.y,
        Bacteria.width,
        Bacteria.height,
      );
      final rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(Bacteria.width / 2),
      );
      paint.strokeWidth = 2;
      paint.color = Colors.black38;

     _drawRotated(
        canvas,
        Offset(
          bacteria.x + Bacteria.width / 2,
          bacteria.y + Bacteria.height / 2,
        ),
        bacteria.rotation,
        () => canvas.drawRRect(rrect, paint),
      );
    }
  }

    void _drawRotated(
    Canvas canvas,
    Offset center,
    double angle,
    VoidCallback drawFunction,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);

    drawFunction();

    canvas.restore();
  }


  @override
  @override
  bool shouldRepaint(covariant Bacteriacollectionpainter oldDelegate) {
    return oldDelegate.bacteriaList != bacteriaList;
  }
}
