import 'package:flutter/material.dart';

class GeometricBackground extends StatelessWidget {
  const GeometricBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -50,
          top: 100,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFFff6f2d).withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          left: 40,
          top: 150,
          child: Transform.rotate(
            angle: -0.2,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(colors: [Color(0xFFff6f2d), Color(0xFFff9b57)]),
              ),
            ),
          ),
        ),
        Positioned(
          right: 30,
          top: 200,
          child: Transform.rotate(
            angle: -0.15,
            child: Column(
              children: List.generate(
                3,
                (i) => Row(
                  children: List.generate(
                    3,
                    (j) => Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
