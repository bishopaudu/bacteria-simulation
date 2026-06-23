import 'package:bacteria_simulation/historygraph/bacterialgrowthchartpainter.dart';
import 'package:bacteria_simulation/models/bactriagrowthhistoryelement.dart';
import 'package:flutter/material.dart';

class HistoryGraph extends StatelessWidget {
  const HistoryGraph({
    required this.historyElements,
    required this.currentTick,
    required this.currentBacteriaAmount,
  });

  final List<BacteriaGrowthHistoryElement> historyElements;
  final int currentTick;
  final int currentBacteriaAmount;

  @override
  Widget build(BuildContext context) {
    if (historyElements.isEmpty || currentBacteriaAmount == 0) {
      return Container();
    }
    return CustomPaint(
      painter: BacteriaGrowthChartPainter(
        historyElements: historyElements,
        currentTick: currentTick,
        currentBacteriaAmount: currentBacteriaAmount,
      ),
    );
  }
}
