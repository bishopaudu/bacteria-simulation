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
