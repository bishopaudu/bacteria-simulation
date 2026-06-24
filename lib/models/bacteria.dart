import 'dart:math';
import 'package:flutter/material.dart';

class Bacteria {
  static final Random _random = Random();

  static const double width = 12;
  static const double height = 24;

  final String id;
  final double x;
  final double y;
  final double rotation;

  // Science simulation attributes
  final double energy;
  final int age;
  final int generation;
  final double speed;
  final String state;

  const Bacteria({
    required this.id,
    this.x = 0,
    this.y = 0,
    this.rotation = 0,
    this.energy = 100.0,
    this.age = 0,
    this.generation = 1,
    this.speed = 1.0,
    this.state = 'Wandering',
  });

  factory Bacteria.createRandomFromBounds(
    double width,
    double height,
  ) {
    return Bacteria(
      id: _random.nextInt(10000000).toString(),
      x: _random.nextDouble() * width,
      y: _random.nextDouble() * height,
      rotation: _random.nextDouble() * pi * 2,
      energy: 100.0,
      age: 0,
      generation: 1,
      speed: 0.8 + _random.nextDouble() * 0.8, // Speed between 0.8 and 1.6
      state: 'Wandering',
    );
  }

  factory Bacteria.createRandomFromExistingBacteria(
    Size environmentSize,
    Bacteria existingBacteria,
  ) {
    // Inherit properties with speed mutation
    final double mutatedSpeed = (existingBacteria.speed + (_random.nextDouble() * 0.2 - 0.1)).clamp(0.5, 3.0);
    return Bacteria(
      id: _random.nextInt(10000000).toString(),
      x: existingBacteria.x,
      y: existingBacteria.y,
      rotation: _random.nextDouble() * pi * 2,
      energy: 50.0, // Child gets half energy
      age: 0,
      generation: existingBacteria.generation + 1,
      speed: mutatedSpeed,
      state: 'Wandering',
    );
  }

  // Calculate movements and physics update
  Bacteria move({
    required Size environmentSize,
    required List<Offset> foodList,
  }) {
    double targetRotation = rotation;
    String newState = 'Wandering';
    Offset? targetFood;

    // Search for nearest nutrient
    if (foodList.isNotEmpty) {
      double minDistance = double.infinity;
      for (final food in foodList) {
        final distance = _distanceTo(food);
        if (distance < minDistance) {
          minDistance = distance;
          targetFood = food;
        }
      }

      // If food is within detection range (150 pixels), steer towards it
      if (targetFood != null && minDistance < 150.0) {
        newState = 'Seeking Food';
        targetRotation = atan2(targetFood.dy - (y + height / 2), targetFood.dx - (x + width / 2));
      }
    }

    // Smoothly rotate towards target direction
    double diff = targetRotation - rotation;
    while (diff < -pi) {
      diff += pi * 2;
    }
    while (diff > pi) {
      diff -= pi * 2;
    }
    double newRotation = rotation + diff.clamp(-0.15, 0.15);

    // Wandering introduces random wiggle
    if (newState == 'Wandering') {
      newRotation += (_random.nextDouble() * 0.4 - 0.2);
    }

    // Step calculation
    double step = speed * (width / 5);
    double newX = x + cos(newRotation) * step;
    double newY = y + sin(newRotation) * step;

    // Screen wrapping bounds check
    if (newX < -width) {
      newX = environmentSize.width;
    } else if (newX > environmentSize.width + width) {
      newX = 0;
    }

    if (newY < -height) {
      newY = environmentSize.height;
    } else if (newY > environmentSize.height + height) {
      newY = 0;
    }

    // Metabolism energy decay
    double energyLoss = 0.15 + (speed * 0.05);
    double newEnergy = (energy - energyLoss).clamp(0.0, 100.0);

    return copyWith(
      x: newX,
      y: newY,
      rotation: newRotation,
      energy: newEnergy,
      age: age + 1,
      state: newState,
    );
  }

  double _distanceTo(Offset point) {
    final double dx = (x + width / 2) - point.dx;
    final double dy = (y + height / 2) - point.dy;
    return sqrt(dx * dx + dy * dy);
  }

  Bacteria copyWith({
    String? id,
    double? x,
    double? y,
    double? rotation,
    double? energy,
    int? age,
    int? generation,
    double? speed,
    String? state,
  }) {
    return Bacteria(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
      energy: energy ?? this.energy,
      age: age ?? this.age,
      generation: generation ?? this.generation,
      speed: speed ?? this.speed,
      state: state ?? this.state,
    );
  }
}
