import 'package:bacteria_simulation/bacteriacollectionpainter.dart';
import 'package:bacteria_simulation/models/antibiotic_particle.dart';
import 'package:bacteria_simulation/models/bacteria.dart';
import 'package:flutter/material.dart';

class Bacterialcollection extends StatelessWidget {
  final List<Bacteria> bacteriaList;
  final List<Offset> foodList;
  final List<AntibioticParticle> particles;
  final Bacteria? inspectedBacteria;

  const Bacterialcollection({
    super.key,
    required this.bacteriaList,
    required this.foodList,
    required this.particles,
    this.inspectedBacteria,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: Bacteriacollectionpainter(
        bacteriaList: bacteriaList,
        foodList: foodList,
        particles: particles,
        inspectedBacteria: inspectedBacteria,
      ),
      child: const SizedBox.expand(),
    );
  }
}