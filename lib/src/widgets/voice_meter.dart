import 'package:flutter/material.dart';

class VoiceMeter extends StatelessWidget {
  const VoiceMeter({super.key, required this.position});

  final double position;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.05,
        height: MediaQuery.of(context).size.height - 98,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.redAccent,
              Colors.greenAccent,
              Colors.lightBlueAccent
            ],
          ),
        ),
        child: Column(
          verticalDirection: VerticalDirection.up,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: EdgeInsets.only(bottom: position),
              width: 50.0,
              height: 20.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.orangeAccent
              ),
            ),
          ],
        ),
      ),
    );
  }
}
