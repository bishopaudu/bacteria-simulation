import 'package:bacteria_simulation/models/antibiotic_particle.dart';
import 'package:bacteria_simulation/models/bacteria.dart';
import 'package:flutter/material.dart';

class Bacteriacollectionpainter extends CustomPainter {
  Bacteriacollectionpainter({
    required this.bacteriaList,
    required this.foodList,
    required this.particles,
    required this.inspectedBacteria,
  });

  final List<Bacteria> bacteriaList;
  final List<Offset> foodList;
  final List<AntibioticParticle> particles;
  final Bacteria? inspectedBacteria;

  static const _energyHighColor = Color(0xFF69FF6E);
  static const _energyLowColor = Color(0xFFFF4A4A);

  @override
  void paint(Canvas canvas, Size size) {
    _drawFood(canvas, size);
    _drawAntibioticParticles(canvas);
    _drawBacteria(canvas);
    _drawInspectionRing(canvas);
  }

  // Food dots 
  void _drawFood(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final food in foodList) {
      // Outer glow
      paint.color = const Color(0xFF69FF6E).withAlpha(60);
      canvas.drawCircle(food, 12, paint);
      // Core
      paint.color = const Color(0xFF69FF6E);
      canvas.drawCircle(food, 5, paint);
    }
  }

  // Antibiotic smoke rings 
  void _drawAntibioticParticles(Canvas canvas) {
    for (final particle in particles) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = Color.fromRGBO(0, 230, 255, particle.opacity);
      canvas.drawCircle(particle.position, particle.radius, paint);

      // Inner fill (very translucent)
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Color.fromRGBO(0, 230, 255, particle.opacity * 0.15);
      canvas.drawCircle(particle.position, particle.radius, fillPaint);
    }
  }

  //  Bacteria bodies 
  void _drawBacteria(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final bacteria in bacteriaList) {
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

      // Color interpolated from energy level
      final energyFraction = (bacteria.energy / 100.0).clamp(0.0, 1.0);
      paint.color = Color.lerp(_energyLowColor, _energyHighColor, energyFraction)!
          .withAlpha(200);

      _drawRotated(
        canvas,
        Offset(bacteria.x + Bacteria.width / 2, bacteria.y + Bacteria.height / 2),
        bacteria.rotation,
        () => canvas.drawRRect(rrect, paint),
      );
    }
  }

  // Microscope inspection ring 
  void _drawInspectionRing(Canvas canvas) {
    if (inspectedBacteria == null) return;
    final b = inspectedBacteria!;
    final center = Offset(b.x + Bacteria.width / 2, b.y + Bacteria.height / 2);
    final radius = Bacteria.height * 0.85;

    // Dashed ring animation effect
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.cyanAccent;

    canvas.drawCircle(center, radius, outerPaint);
    canvas.drawCircle(center, radius + 5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = Colors.cyanAccent.withAlpha(80));
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
  bool shouldRepaint(covariant Bacteriacollectionpainter oldDelegate) {
    return oldDelegate.bacteriaList != bacteriaList ||
        oldDelegate.foodList != foodList ||
        oldDelegate.particles != particles ||
        oldDelegate.inspectedBacteria != inspectedBacteria;
  }
}
