import 'package:flutter/material.dart';

Widget forms(TextEditingController nameController, TextEditingController descriptionController,String? Function(String?)? validator  ) {
  return SafeArea(
    child: Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: TextFormField(
            validator: validator,
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Enter Event Name",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(20),
          child: TextFormField(
            validator: validator,
            controller: descriptionController,
            maxLines: 10,
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
              focusColor: Colors.grey,
              hintText: "Enter Event Description",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
