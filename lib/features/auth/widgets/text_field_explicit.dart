import 'package:flutter/material.dart';

class TextFieldExplicit extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType textInputType;
  final String? Function(String?)? validator; 
  const TextFieldExplicit({
    super.key,
    required this.controller,
    required this.labelText,
    required this.obscureText,
    required this.textInputType, 
    this.validator,
  });

  @override
  State<TextFieldExplicit> createState() => _TextFieldExplicitState();
}

class _TextFieldExplicitState extends State<TextFieldExplicit> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        keyboardType: widget.textInputType,
        obscureText: widget.obscureText,
        controller: widget.controller,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
