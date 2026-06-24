import 'dart:async';
import 'dart:math';

import 'package:bacteria_simulation/models/antibiotic_particle.dart';
import 'package:bacteria_simulation/models/bacteria.dart';
import 'package:bacteria_simulation/models/bactriagrowthhistoryelement.dart';
import 'package:flutter/material.dart';

enum InteractiveTool { none, foodDropper, antibioticSpray, microscope }

class SimulationProvider extends ChangeNotifier {
  static const int tickTime = 30;
  static const double recreationProbability = 0.004;
  static const double deathProbability = 0.001;
  static const double maxBacteriaAmount = 1024;
  static const double antibioticKillRadius = 50.0;
  static const double foodEatRadius = 12.0;

  // --- Simulation state ---
  List<Bacteria> _bacteriaList = [];
  List<Bacteria> get bacteriaList => _bacteriaList;

  final List<BacteriaGrowthHistoryElement> _historyElements = [];
  List<BacteriaGrowthHistoryElement> get historyElements => _historyElements;

  int _currentTick = 0;
  int get currentTick => _currentTick;

  Size _size = Size.zero;
  Size get size => _size;

  // Interactive tool state 
  InteractiveTool _activeTool = InteractiveTool.none;
  InteractiveTool get activeTool => _activeTool;

  final List<Offset> _foodList = [];
  List<Offset> get foodList => List.unmodifiable(_foodList);

  final List<AntibioticParticle> _particles = [];
  List<AntibioticParticle> get particles => List.unmodifiable(_particles);

  Bacteria? _inspectedBacteria;
  Bacteria? get inspectedBacteria => _inspectedBacteria;

  Timer? _timer;

  // Tool selection 
  void selectTool(InteractiveTool tool) {
    // Toggle off if already selected
    _activeTool = _activeTool == tool ? InteractiveTool.none : tool;
    if (_activeTool != InteractiveTool.microscope) {
      _inspectedBacteria = null;
    }
    notifyListeners();
  }

  // Food dropper 
  void dropFood(Offset position) {
    _foodList.add(position);
    notifyListeners();
  }

  // Antibiotic spray 
  void applyAntibiotic(Offset position) {
    _particles.add(AntibioticParticle(
      position: position,
      radius: antibioticKillRadius * 0.3,
      opacity: 0.85,
    ));
    // Kill bacteria in the blast radius immediately
    _bacteriaList = _bacteriaList.where((b) {
      final dx = (b.x + Bacteria.width / 2) - position.dx;
      final dy = (b.y + Bacteria.height / 2) - position.dy;
      return sqrt(dx * dx + dy * dy) > antibioticKillRadius;
    }).toList();
    notifyListeners();
  }

  // Microscope 
  void inspectAt(Offset position) {
    const double tapRadius = 24.0;
    Bacteria? closest;
    double minDist = double.infinity;
    for (final b in _bacteriaList) {
      final dx = (b.x + Bacteria.width / 2) - position.dx;
      final dy = (b.y + Bacteria.height / 2) - position.dy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist < tapRadius && dist < minDist) {
        minDist = dist;
        closest = b;
      }
    }
    _inspectedBacteria = closest;
    notifyListeners();
  }

  void clearInspection() {
    _inspectedBacteria = null;
    notifyListeners();
  }

  // Size / timer lifecycle 
  void updateSize(Size newSize) {
    if (_size == newSize) return;
    _size = newSize;
    if (_timer == null && _size != Size.zero) {
      _timer = Timer.periodic(const Duration(milliseconds: tickTime), (timer) {
        _tick();
      });
    }
  }

  // Core simulation tick 
  void _tick() {
    if (_size == Size.zero) return;

    _currentTick++;
    _historyElements.add(BacteriaGrowthHistoryElement(
      tickNumber: _currentTick,
      amountOfBacteria: _bacteriaList.length,
    ));

    // Fade antibiotic particles
    _particles.removeWhere((p) => p.isDead);
    for (int i = 0; i < _particles.length; i++) {
      _particles[i] = _particles[i].fade();
    }

    if (_bacteriaList.isEmpty) {
      _createInitialBacteria();
      return;
    }

    _iterateAllBacteria();
  }

  void _createInitialBacteria() {
    final newList = <Bacteria>[
      Bacteria.createRandomFromBounds(_size.width, _size.height),
    ];
    _updateBacteriaList(newList);
  }

  void _iterateAllBacteria() {
    final newList = <Bacteria>[];

    for (final bacteria in _bacteriaList) {
      // Check if a bacteria is already dead from antibiotic
      final bool shouldDie = Random().nextDouble() > 1 - deathProbability;
      if (shouldDie || bacteria.energy <= 0) {
        // Remove inspected reference if it died
        if (_inspectedBacteria?.id == bacteria.id) {
          _inspectedBacteria = null;
        }
        continue;
      }

      // Move with food steering
      final moved = bacteria.move(environmentSize: _size, foodList: _foodList);

      // Check if bacteria eats a food item
      _checkFoodEaten(moved, newList);

      _createNewBacteria(bacteria, newList);
    }

    _updateBacteriaList(newList);
  }

  void _checkFoodEaten(Bacteria bacteria, List<Bacteria> newList) {
    int eatenIndex = -1;
    for (int i = 0; i < _foodList.length; i++) {
      final dx = (bacteria.x + Bacteria.width / 2) - _foodList[i].dx;
      final dy = (bacteria.y + Bacteria.height / 2) - _foodList[i].dy;
      if (sqrt(dx * dx + dy * dy) < foodEatRadius) {
        eatenIndex = i;
        break;
      }
    }

    if (eatenIndex >= 0) {
      _foodList.removeAt(eatenIndex);
      // Eating refills energy
      newList.add(bacteria.copyWith(
        energy: (bacteria.energy + 40.0).clamp(0.0, 100.0),
        state: 'Eating',
      ));
    } else {
      // Keep inspected bacteria reference current
      if (_inspectedBacteria?.id == bacteria.id) {
        _inspectedBacteria = bacteria;
      }
      newList.add(bacteria);
    }
  }

  void _createNewBacteria(Bacteria bacteria, List<Bacteria> newList) {
    final bool shouldCreate =
        Random().nextDouble() > 1 - recreationProbability;
    if (shouldCreate && _bacteriaList.length < maxBacteriaAmount) {
      newList.add(
        Bacteria.createRandomFromExistingBacteria(_size, bacteria),
      );
    }
  }

  void _updateBacteriaList(List<Bacteria> newList) {
    _bacteriaList = newList;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
