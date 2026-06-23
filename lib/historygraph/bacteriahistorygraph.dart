import 'package:bacteria_simulation/historygraph/historygraph.dart';
import 'package:bacteria_simulation/models/bactriagrowthhistoryelement.dart';
import 'package:flutter/material.dart';

class Bacteriahistorygraph extends StatelessWidget {
  const Bacteriahistorygraph({
    super.key,
    required this.historyElements,
    required this.currentTick,
    required this.currentBacteriaAmount,
  });

  static const double opacity = 0.5;
  static const double padding = 32;

  final List<BacteriaGrowthHistoryElement> historyElements;
  final int currentTick;
  final int currentBacteriaAmount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Opacity(
          opacity: opacity,
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12),
              ],
            ),
            child: _buildMainPaint(constraints),
          ),
        );
      },
    );
  }

  Widget _buildMainPaint(BoxConstraints constraints) {
    if (historyElements.isEmpty) return Container();
    return Stack(
      fit: StackFit.expand,
      children: [
        HistoryGraph(
          historyElements: historyElements,
          currentTick: currentTick,
          currentBacteriaAmount: currentBacteriaAmount,
        ),
        _buildInfoText()
      ],
    );
  }
   Positioned _buildInfoText() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.white70,
        child: Text(
          '${historyElements.last.amountOfBacteria} Bacteria',
        ),
      ),
    );
  }
}
