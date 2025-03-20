import 'package:flutter/material.dart';

Widget schedule(String dateText) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey[300],
    ),
    margin: const EdgeInsets.all(10),
    child: Column(
      children: [
        const Text(
          'Selected Date',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          dateText == 'null' ? 'No date selected' : dateText,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}
