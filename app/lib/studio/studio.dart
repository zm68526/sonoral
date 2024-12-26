import '../local_storage/local_storage_handler.dart';
import '../data_structures/composition_data_structures.dart';
import 'package:flutter/material.dart';

class StudioWidget extends StatefulWidget {
  final int? id;
  const StudioWidget({super.key, required this.id});

  @override
  State<StudioWidget> createState() => _StudioWidgetState();
}

class _StudioWidgetState extends State<StudioWidget> {
  late Composition composition;
  
  @override
  void initState() {
    super.initState();
    if (widget.id != null) composition = getCompositions()[widget.id!];
    // error handling if the id is out of range or null (unparseable)
  }

  @override
  Widget build(BuildContext context) {
    return Text(composition.toString());
  }
}