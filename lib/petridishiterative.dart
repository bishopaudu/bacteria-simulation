import 'dart:math';

import 'package:bacteria_simulation/bacterialcollection.dart';
import 'package:bacteria_simulation/historygraph/bacteriahistorygraph.dart';
import 'package:bacteria_simulation/models/bacteria.dart';
import 'package:bacteria_simulation/providers/simulation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Petridishiterative extends StatelessWidget {
  const Petridishiterative({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimulationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<SimulationProvider>().updateSize(constraints.biggest);
          });

          return Stack(
            children: [
              // Simulation canvas with gesture detection
              _SimulationCanvas(provider: provider),

              // Growth graph overlay
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                height: 130,
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

              // Sci-fi Tool bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _ToolBar(provider: provider),
              ),

              // Microscope HUD overlay
              if (provider.inspectedBacteria != null)
                Positioned(
                  top: 80,
                  right: 20,
                  child: _MicroscopeHUD(bacteria: provider.inspectedBacteria!),
                ),

              // Active tool hint
              if (provider.activeTool != InteractiveTool.none)
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: _ToolHint(tool: provider.activeTool),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Simulation canvas with gesture routing
class _SimulationCanvas extends StatelessWidget {
  final SimulationProvider provider;
  const _SimulationCanvas({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _onTap(context, details.localPosition),
      onPanStart: (details) => _onPan(context, details.localPosition),
      onPanUpdate: (details) => _onPan(context, details.localPosition),
      child: SizedBox.expand(
        child: Bacterialcollection(
          bacteriaList: provider.bacteriaList,
          foodList: provider.foodList,
          particles: provider.particles,
          inspectedBacteria: provider.inspectedBacteria,
        ),
      ),
    );
  }

  void _onTap(BuildContext context, Offset pos) {
    final sim = context.read<SimulationProvider>();
    switch (sim.activeTool) {
      case InteractiveTool.foodDropper:
        sim.dropFood(pos);
        break;
      case InteractiveTool.antibioticSpray:
        sim.applyAntibiotic(pos);
        break;
      case InteractiveTool.microscope:
        sim.inspectAt(pos);
        break;
      case InteractiveTool.none:
        break;
    }
  }

  void _onPan(BuildContext context, Offset pos) {
    final sim = context.read<SimulationProvider>();
    switch (sim.activeTool) {
      case InteractiveTool.foodDropper:
        sim.dropFood(pos);
        break;
      case InteractiveTool.antibioticSpray:
        sim.applyAntibiotic(pos);
        break;
      default:
        break;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sci-Fi Tool Bar
// ═══════════════════════════════════════════════════════════════════════════
class _ToolBar extends StatelessWidget {
  final SimulationProvider provider;
  const _ToolBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(160),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.cyanAccent.withAlpha(60), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withAlpha(30),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ToolButton(
              tool: InteractiveTool.foodDropper,
              icon: Icons.spa_rounded,
              label: 'Food',
              color: const Color(0xFF69FF6E),
              activeTool: provider.activeTool,
            ),
            _ToolButton(
              tool: InteractiveTool.antibioticSpray,
              icon: Icons.air_rounded,
              label: 'Spray',
              color: const Color(0xFF00E6FF),
              activeTool: provider.activeTool,
            ),
            _ToolButton(
              tool: InteractiveTool.microscope,
              icon: Icons.center_focus_strong_rounded,
              label: 'Inspect',
              color: const Color(0xFFFFD700),
              activeTool: provider.activeTool,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final InteractiveTool tool;
  final IconData icon;
  final String label;
  final Color color;
  final InteractiveTool activeTool;

  const _ToolButton({
    required this.tool,
    required this.icon,
    required this.label,
    required this.color,
    required this.activeTool,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = activeTool == tool;
    return GestureDetector(
      onTap: () => context.read<SimulationProvider>().selectTool(tool),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? color : Colors.white24,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: color.withAlpha(100), blurRadius: 14)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? color : Colors.white38, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Microscope HUD
// ═══════════════════════════════════════════════════════════════════════════
class _MicroscopeHUD extends StatelessWidget {
  final Bacteria bacteria;
  const _MicroscopeHUD({required this.bacteria});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withAlpha(100), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withAlpha(40),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.center_focus_strong_rounded,
                  color: Colors.cyanAccent, size: 16),
              const SizedBox(width: 6),
              const Text(
                'SPECIMEN',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.read<SimulationProvider>().clearInspection(),
                child: const Icon(Icons.close, color: Colors.white38, size: 16),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          _HudRow(label: 'Age', value: '${bacteria.age} ticks'),
          _HudRow(
            label: 'Speed',
            value: '${bacteria.speed.toStringAsFixed(2)}x',
          ),
          _HudRow(label: 'Gen', value: '#${bacteria.generation}'),
          _HudRow(label: 'State', value: bacteria.state),
          const SizedBox(height: 8),
          // Energy bar
          Row(
            children: [
              const Text(
                'Energy',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const Spacer(),
              Text(
                '${bacteria.energy.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: bacteria.energy / 100.0,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.lerp(
                  const Color(0xFFFF4A4A),
                  const Color(0xFF69FF6E),
                  bacteria.energy / 100.0,
                )!,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _HudRow extends StatelessWidget {
  final String label;
  final String value;
  const _HudRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tool hint label
// ═══════════════════════════════════════════════════════════════════════════
class _ToolHint extends StatelessWidget {
  final InteractiveTool tool;
  const _ToolHint({required this.tool});

  String get _hint {
    switch (tool) {
      case InteractiveTool.foodDropper:
        return 'Tap or drag to drop nutrients';
      case InteractiveTool.antibioticSpray:
        return 'Tap or drag to spray antibiotic';
      case InteractiveTool.microscope:
        return 'Tap a bacterium to inspect it';
      case InteractiveTool.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _hint,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
