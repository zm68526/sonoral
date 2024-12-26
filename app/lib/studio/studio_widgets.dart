import 'package:flutter/material.dart';

class EditTextField extends StatefulWidget {
  final TextEditingController controller;
  const EditTextField({super.key, required this.controller});

  @override
  State<EditTextField> createState() => _EditTextFieldState();
}

class _EditTextFieldState extends State<EditTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hoverColor: Colors.black,
        border: OutlineInputBorder(),
        labelText: 'Enter your text',
      ),
    );
  }
}