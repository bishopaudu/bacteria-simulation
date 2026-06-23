/*class Bacteria {
  final double x;
  final double y;

  Bacteria({this.x = 0, this.y = 0,});

}*/

import 'dart:math';
import 'package:flutter/material.dart';

class Bacteria {
  static final Random _random = Random();

  static const double width = 12;
  static const double height = 24;

  final double x;
  final double y;
  final double rotation;

  const Bacteria({
    this.x = 0,
    this.y = 0,
    this.rotation = 0,
  });

  factory Bacteria.createRandomFromBounds(
    double width,
    double height,
  ) {
    return Bacteria(
      x: _random.nextDouble() * width,
      y: _random.nextDouble() * height,
      rotation: _random.nextDouble() * pi * 2,
    );
  }

  factory Bacteria.createRandomFromExistingBacteria(
    Size environmentSize,
    Bacteria existingBacteria,
  ) {
    double newX = existingBacteria.x +
        existingBacteria._getMovementAddition();

    double newY = existingBacteria.y +
        existingBacteria._getMovementAddition();

    if (newX < -Bacteria.width) {
      newX = environmentSize.width;
    } else if (newX > environmentSize.width + Bacteria.width) {
      newX = 0;
    }

    if (newY < -Bacteria.height) {
      newY = environmentSize.height;
    } else if (newY > environmentSize.height + Bacteria.height) {
      newY = 0;
    }
        final double rotation = existingBacteria.rotation + (Random().nextDouble() * 2 - 1) * pi / 40;


    return Bacteria(
      x: newX,
      y: newY,
      rotation: rotation,
    );
  }

  double _getMovementAddition() {
    final movementMax = width / 6;
    return _random.nextDouble() * movementMax - movementMax / 2;
  }
}
