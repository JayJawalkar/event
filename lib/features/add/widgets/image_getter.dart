
import 'dart:io';

import 'package:flutter/material.dart';

Widget imageGetter(
  Function() pickImage,
  File? selectedImage,
  double width,
  double imageHeight,
  double imageWidth,
) {
  return Container(
    margin: const EdgeInsets.all(10),
    child: Column(
      children: [
        const Text(
          "Enter an Banner Image",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: const Text(
            "Enter an image only",
            style: TextStyle(
              backgroundColor: Color.fromARGB(255, 255, 250, 206),
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            fixedSize: Size(width, 60),
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: pickImage,
          child: const Text(
            "Select",
            style: TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 20),
        selectedImage == null
            ? const Text("No image selected")
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(),
                ),
                child: Image.file(
                  selectedImage,
                  height: imageHeight,
                  width: imageWidth,
                ),
              ),
      ],
    ),
  );
}
