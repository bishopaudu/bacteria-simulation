import 'dart:math';

import 'package:bacteria_simulation/bacterialcollection.dart';
import 'package:bacteria_simulation/historygraph/bacteriahistorygraph.dart';
import 'package:bacteria_simulation/providers/simulation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Petridishiterative extends StatelessWidget {
  const Petridishiterative({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimulationProvider>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<SimulationProvider>().updateSize(constraints.biggest);
          });

          return Stack(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Bacterialcollection(bacteriaList: provider.bacteriaList),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                height: 150,
                child: Bacteriahistorygraph(
                  historyElements: provider.historyElements,
                  currentTick: provider.currentTick,
                  currentBacteriaAmount: provider.historyElements.isEmpty
                      ? 1
                      : provider.historyElements
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
