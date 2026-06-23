import 'dart:async';
import 'dart:math';

import 'package:bacteria_simulation/models/bacteria.dart';
import 'package:bacteria_simulation/models/bactriagrowthhistoryelement.dart';
import 'package:flutter/material.dart';

class SimulationProvider extends ChangeNotifier {
  static const int tickTime = 30;
  static const double recreationProbability = 0.005;
  static const double deathProbability = 0.001;
  static const double maxBacteriaAmount = 1024;

  List<Bacteria> _bacteriaList = [];
  List<Bacteria> get bacteriaList => _bacteriaList;

  final List<BacteriaGrowthHistoryElement> _historyElements = [];
  List<BacteriaGrowthHistoryElement> get historyElements => _historyElements;

  int _currentTick = 0;
  int get currentTick => _currentTick;

  Size _size = Size.zero;
  Size get size => _size;

  Timer? _timer;

  void updateSize(Size newSize) {
    if (_size == newSize) return;
    _size = newSize;
    
    // Start timer when size is non-zero and not already running
    if (_timer == null && _size != Size.zero) {
      _timer = Timer.periodic(const Duration(milliseconds: tickTime), (timer) {
        _tick();
      });
    }
  }

  void _tick() {
    if (_size == Size.zero) return;

    _currentTick++;
    _historyElements.add(BacteriaGrowthHistoryElement(
      tickNumber: _currentTick,
      amountOfBacteria: _bacteriaList.length,
    ));

    if (_bacteriaList.isEmpty) {
      _createInitialBacteria();
      return;
    }

    _iterateAllBacteria();
  }

  void _createInitialBacteria() {
    final List<Bacteria> newList = <Bacteria>[];
    newList.add(Bacteria.createRandomFromBounds(_size.width, _size.height));

    _updateBacteriaList(newList);
  }

  void _iterateAllBacteria() {
    final List<Bacteria> newList = <Bacteria>[];

    for (final Bacteria bacteria in _bacteriaList) {
      final bool shouldKill = Random().nextDouble() > 1 - deathProbability;

      if (!shouldKill) {
        final Bacteria movedBacteria =
            Bacteria.createRandomFromExistingBacteria(
          _size,
          bacteria,
        );
        newList.add(movedBacteria);
      }

      _createNewBacteria(bacteria, newList);
    }

    _updateBacteriaList(newList);
  }

  void _createNewBacteria(Bacteria bacteria, List<Bacteria> newList) {
    final bool shouldCreateNew =
        Random().nextDouble() > 1 - recreationProbability;

    if (shouldCreateNew && _bacteriaList.length < maxBacteriaAmount) {
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
