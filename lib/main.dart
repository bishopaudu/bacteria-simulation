import 'package:bacteria_simulation/petridishiterative.dart';
import 'package:bacteria_simulation/providers/simulation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SimulationProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bacterial Simulator',
        home: const Petridishiterative(),
      ),
    );
  }
}
