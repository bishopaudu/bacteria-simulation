import 'package:flutter/material.dart';

class AntibioticParticle {
  final Offset position;
  final double radius;
  final double opacity;

  const AntibioticParticle({
    required this.position,
    required this.radius,
    required this.opacity,
  });

  AntibioticParticle fade() {
    return AntibioticParticle(
      position: position,
      radius: radius + 1.2,
      opacity: (opacity - 0.035).clamp(0.0, 1.0),
    );
  }

  bool get isDead => opacity <= 0.0;
}
