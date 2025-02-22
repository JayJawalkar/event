import 'package:event/core/constants/image_constants.dart';
import 'package:event/features/search/widgets/easy.dart';
import 'package:flutter/material.dart';

class Genere extends StatefulWidget {
  const Genere({super.key});

  @override
  State<Genere> createState() => _GenereState();
}

class _GenereState extends State<Genere> {
  final List<Map<String, dynamic>> data = [
    {
      'title': 'Debate',
      'image': ImageConstants.debate,
      'color': const Color.fromRGBO(245, 239, 255, 1),
    },
    {
      'title': 'Singing',
      'image': ImageConstants.singing,
      'color': const Color.fromRGBO(229, 217, 242, 1),
    },
    {
      'title': 'Comedy',
      'image': ImageConstants.comedy,
      'color': const Color.fromRGBO(205, 193, 255, 1),
    },
    {
      'title': 'Sports',
      'image': ImageConstants.sports,
      'color': const Color.fromRGBO(162, 148, 249, 1),
    },
    {
      'title': 'Coding',
      'image': ImageConstants.coding,
      'color': const Color.fromRGBO(205, 193, 255, 1),
    },
    {
      'title': 'E-Sports',
      'image': ImageConstants.esports,
      'color': const Color.fromRGBO(229, 217, 242, 1),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Adjust this based on the desired grid layout
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1, // Adjust based on UI preference
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Easy(
            color: data[index]['color'],
            path: data[index]['image'],
            text: data[index]['title'].toString(),
          );
        },
      ),
    );
  }
}
