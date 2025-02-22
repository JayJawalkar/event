import 'package:flutter/material.dart';

class ButtonText extends StatelessWidget {
  final VoidCallback onTap;
  const ButtonText({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
     return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.black),
    ),
    child: TextButton(
      onPressed: onTap,
      child: const Text("Book Now"),
    ),
  );
  }
}