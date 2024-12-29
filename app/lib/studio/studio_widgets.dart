import 'package:flutter/material.dart';

class EditTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSubmitted;
  const EditTextField({super.key, required this.controller, this.onSubmitted});

  @override
  State<EditTextField> createState() => _EditTextFieldState();
}

class _EditTextFieldState extends State<EditTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: widget.onSubmitted,
      controller: widget.controller,
      decoration: const InputDecoration(
        hoverColor: Colors.black,
        border: OutlineInputBorder(),
        labelText: 'Title',
      ),
    );
  }
}