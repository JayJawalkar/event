import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Fav extends StatefulWidget {
  const Fav({super.key});

  @override
  State<Fav> createState() => _FavState();
}

class _FavState extends State<Fav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Your Favourite's"),
              Icon(
                CupertinoIcons.heart_fill,
                color: Colors.red,
              )
            ],
          ),
        ),
      ),
      body: Center(
        child: Text('No favourites yet'),
      ),
    );
  }
}
