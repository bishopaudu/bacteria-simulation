# 🦠 Bacteria Simulation

A real-time, interactive bacteria simulation built in Flutter. Watch a living colony grow, compete for nutrients, respond to antibiotics, and evolve — all rendered at 30+ FPS using Flutter's `CustomPainter` and `provider` state management.

---

## 📱 Features

| Feature | Description |
|---|---|
| **Live Simulation** | Bacteria move, reproduce, age, and die every 30 ms |
| **Energy System** | Each bacterium burns energy as it moves; it starves and dies if it runs out |
| **Food Dropper** | Tap/drag the petri dish to drop glowing nutrients |
| **Antibiotic Spray** | Drag to spray cyan smoke rings that instantly kill bacteria |
| **Microscope Tool** | Tap any bacterium to open a telemetry HUD (Age, Speed, Generation, Energy) |
| **Growth Graph** | Live line chart at the bottom tracking population over time |
| **Speed Mutations** | Offspring inherit their parent's speed ± a small mutation |
| **Energy Colours** | Bacteria colour-shifts red → green based on current energy level |

---

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point, ChangeNotifierProvider
├── petridishiterative.dart            # Main screen (gesture routing, toolbar, HUD)
├── bacterialcollection.dart           # CustomPaint host widget
├── bacteriacollectionpainter.dart     # Renders bacteria, food, particles, rings
│
├── providers/
│   └── simulation_provider.dart       # All business logic + state management
│
├── models/
│   ├── bacteria.dart                  # Bacteria data model + physics/AI
│   ├── antibiotic_particle.dart       # Smoke ring particle model
│   └── bactriagrowthhistoryelement.dart # History graph data point
│
└── historygraph/
    ├── bacteriahistorygraph.dart      # Glass card wrapping the chart
    ├── historygraph.dart              # CustomPaint host for the chart
    └── bacterialgrowthchartpainter.dart # Paints the growth line
```

---

## 🔄 Summary of Code Changes

### Phase 1 — Bug Fixes (Initial)
- **Fixed `right: bacteria.y`** → changed to `top: bacteria.y` in the positioned widget (y-coordinate was accidentally setting horizontal spacing instead of vertical position)
- **Fixed empty timer callback** → the `Timer.periodic` in `initState` was created but calling nothing; added `_tick()` call
- **Fixed `Size.zero` race condition** → added an early-return guard in `_tick()` so the simulation doesn't run before Flutter has laid out the screen

### Phase 2 — Growth Graph
- Created `BacteriaGrowthHistoryElement` model to record `(tickNumber, amountOfBacteria)` pairs
- Created `BacteriaGrowthChartPainter` that draws a green line chart from these data points
- Created `BacteriaHistoryGraph` — a semi-transparent black card wrapping the chart
- Plugged the graph into the main screen as a `Positioned` overlay at the bottom

### Phase 3 — Provider State Management Refactor
- Created `SimulationProvider extends ChangeNotifier` in `lib/providers/`
- Moved all simulation variables (`bacteriaList`, `historyElements`, `currentTick`, `size`) into the provider
- Moved all logic methods (`_tick`, `_iterateAllBacteria`, `_createNewBacteria`, etc.) into the provider
- Converted `Petridishiterative` from a `StatefulWidget` to a `StatelessWidget` that reads from the provider via `context.watch<SimulationProvider>()`
- Used `WidgetsBinding.instance.addPostFrameCallback` to safely deliver the screen size to the provider after layout completes (avoids calling `notifyListeners()` during a build pass)
- Wrapped `MyApp.build()` with `ChangeNotifierProvider<SimulationProvider>` so the provider is available both at runtime and during widget tests

### Phase 4 — Interactive Tools
- **`Bacteria` model** — added `id`, `energy`, `age`, `generation`, `speed`, `state`, and a `move()` method with food-steering AI and energy metabolism
- **`AntibioticParticle` model** — tracks position, radius, opacity; `fade()` expands and dims it each tick
- **`SimulationProvider`** — added `InteractiveTool` enum and handlers: `dropFood`, `applyAntibiotic`, `inspectAt`, `selectTool`, `clearInspection`
- **`Bacteriacollectionpainter`** — updated to render four layers: food dots, smoke rings, energy-coloured bacteria, inspection ring
- **`Bacterialcollection`** — updated to forward `foodList`, `particles`, `inspectedBacteria` props to the painter
- **`Petridishiterative`** — added `GestureDetector` that routes taps/drags based on active tool; added sci-fi glass tool bar; added microscope HUD card

---

## 🎨 Why Do Bacteria Have Different Colours?

The colour is a **live energy indicator**.

In `bacteriacollectionpainter.dart`, each bacterium is painted with a colour that is linearly interpolated between two colours based on its `energy` value (0–100):

```dart
final energyFraction = (bacteria.energy / 100.0).clamp(0.0, 1.0);
paint.color = Color.lerp(
  Color(0xFFFF4A4A),   // 🔴 Red  → energy = 0% (about to die)
  Color(0xFF69FF6E),   // 🟢 Green → energy = 100% (just born / fed)
  energyFraction,
)!;
```

| Colour | Meaning |
|---|---|
| 🟢 Bright green | Freshly born or just ate food — full energy |
| 🟡 Yellow-green | Moderately healthy — has been alive for a while |
| 🟠 Orange | Getting hungry — energy below 50% |
| 🔴 Red | Critically low energy — will starve and die soon |

Energy decays each tick:
```dart
double energyLoss = 0.15 + (speed * 0.05);
```
Faster bacteria burn energy more quickly, so a highly mutated speed-3.0 specimen will turn red and die before a slower one does — this is the foundation of **natural selection**.

---

## 🐌 Why Do Bacteria Multiply Slowly?

Two deliberate design decisions control population growth rate:

### 1. Low reproduction probability
```dart
static const double recreationProbability = 0.004; // 0.4% per tick
```
Every 30ms (one tick), **each living bacterium** rolls a random number. Only if it lands above `1 - 0.004 = 0.996` does it reproduce. With a few bacteria this rarely fires; only as the colony grows does reproduction become frequent.

### 2. Energy-based death
Bacteria now die for two reasons — random chance *and* running out of energy:
```dart
if (shouldDie || bacteria.energy <= 0) { continue; /* = removed */ }
```
Without food on the dish, energy drains at `~0.15–0.35` per tick. A bacterium survives roughly **300–660 ticks = 9–20 seconds** before starving. This balances out fast reproducers, so the population doesn't just explode immediately.

### Net effect
Population grows slowly at first, then accelerates exponentially once enough bacteria are alive for the reproduction probability to fire frequently — you can watch this S-curve appear in the growth graph. Drop food to spike the population fast!

---

## 🛠 How to Run

```bash
flutter pub get
flutter run
```

## 🧪 Tests
```bash
flutter test
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `provider: ^6.1.5` | State management |
| `flutter` SDK | Core framework |

---

## 🚀 Possible Next Steps

- **Mutations & Natural Selection** — track speed/size distributions over generations
- **Multiple Species** — predator bacteria that hunt other bacteria
- **Chemotaxis heatmap** — visualise food gradient with a colour overlay
- **Simulation speed slider** — pause, slow down, or fast-forward via the control bar
