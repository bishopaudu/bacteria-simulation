import 'dart:async';
import 'dart:math';

import 'package:bacteria_simulation/bacterialcollection.dart';
import 'package:bacteria_simulation/historygraph/bacteriahistorygraph.dart';
import 'package:bacteria_simulation/models/bacteria.dart';
import 'package:bacteria_simulation/models/bactriagrowthhistoryelement.dart';
import 'package:flutter/material.dart';

class Petridishiterative extends StatefulWidget {
  const Petridishiterative({super.key});

  @override
  State<Petridishiterative> createState() => _PetridishiterativeState();
}

class _PetridishiterativeState extends State<Petridishiterative> {
  static const int tickTime = 30;
  static const double recreationProbability = 0.005;
  static const double deathProbability = 0.001;
  static const double maxBacteriaAmount = 1024;

  List<Bacteria> bacteriaList = [
    Bacteria(x: 100, y: 100),
    Bacteria(x: 200, y: 200),
    Bacteria(x: 300, y: 300),
  ];
  final List<BacteriaGrowthHistoryElement> historyElements = [];
  int currentTick = 0;
  Size size = Size.zero;

  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(milliseconds: tickTime), (timer) {
      _tick();
    });
    //print("initState called");
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
   // print(  "dispose called");
    super.dispose();
  }

  void _tick() {
     if (size == Size.zero) return;

     currentTick++;
     historyElements.add(BacteriaGrowthHistoryElement(
       tickNumber: currentTick,
       amountOfBacteria: bacteriaList.length,
     ));

  if (bacteriaList.isEmpty) {
    _createInitialBacteria();
    return;
  }

  _iterateAllBacteria();
}

void _createInitialBacteria() {
  final List<Bacteria> newList = <Bacteria>[];
  newList.add(Bacteria.createRandomFromBounds(size.width, size.height));

  _updateBacteriaList(newList);
}
void _iterateAllBacteria() {
  final List<Bacteria> newList = <Bacteria>[];

  for (final Bacteria bacteria in bacteriaList) {
    final bool shouldKill = Random().nextDouble() > 1 - deathProbability;

    if (!shouldKill) {
      final Bacteria movedBacteria =
          Bacteria.createRandomFromExistingBacteria(
        size,
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

  if (shouldCreateNew && bacteriaList.length < maxBacteriaAmount) {
    newList.add(
      Bacteria.createRandomFromExistingBacteria(size, bacteria),
    );
  }
}

void _updateBacteriaList(List<Bacteria> newList) {
  setState(() {
    bacteriaList = newList;
  });
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          size = constraints.biggest;
          return Stack(
            children: [
              SizedBox(
                width: size.width,
                height: size.height,
                child: Bacterialcollection(bacteriaList: bacteriaList),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                height: 150,
                child: Bacteriahistorygraph(
                  historyElements: historyElements,
                  currentTick: currentTick,
                  currentBacteriaAmount: historyElements.isEmpty
                      ? 1
                      : historyElements
                          .map((e) => e.amountOfBacteria)
                          .fold(1, (maxVal, elem) => max(maxVal, elem)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
