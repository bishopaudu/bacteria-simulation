import 'package:bacteria_simulation/bacteriacollectionpainter.dart';
import 'package:bacteria_simulation/models/bacteria.dart';
import 'package:flutter/material.dart';

class Bacterialcollection extends StatelessWidget {
  final List<Bacteria> bacteriaList;
  const Bacterialcollection({super.key,required this.bacteriaList});

  @override
  Widget build(BuildContext context) {
   // final List<Widget> widgetList = bacteriaList.map((bacteria) =>buildWidgetFromBacteria(bacteria)).toList();
    return CustomPaint(
      painter: Bacteriacollectionpainter(bacteriaList: bacteriaList),
      
    );
  }

  Positioned buildWidgetFromBacteria(Bacteria bacteria) {
    return Positioned(
      left:bacteria.x,
      top: bacteria.y,
      child: Container(
       // width: 10,
        //height: 10,
        decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(5),
        ),
        width: Bacteria.width,
      height: Bacteria.height,
      ));
  }
}