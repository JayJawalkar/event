import 'package:event/features/search/widgets/genere.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ), // Provide your custom back button here
        title: const Text("Search"),
      ),
      body: Column(
        children: [
          _search(), // Widget for search bar
          Expanded(child: Genere() // Widget for categories
              ), // Make this widget take the available space
        ],
      ),
    );
  }
}

Widget _search() {
  return Container(
    margin: const EdgeInsets.all(15),
    child: const TextField(
      decoration: InputDecoration(
        hintText: "Search",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  );
}
