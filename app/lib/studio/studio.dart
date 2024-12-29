import '../local_storage/local_storage_handler.dart';
import '../data_structures/composition_data_structures.dart';
import '../data_structures/studio_data_structures.dart';
import './studio_widgets.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// widget which obtains the appropriate composition from the local storage
class StudioWrapperWidget extends StatefulWidget {
  final int? id;
  const StudioWrapperWidget({super.key, required this.id});

  @override
  State<StudioWrapperWidget> createState() => _StudioWrapperWidgetState();
}

class _StudioWrapperWidgetState extends State<StudioWrapperWidget> {
  Composition? composition;

  @override
  void initState() {
    super.initState();
    final compositionsList = getCompositions();
    if (widget.id != null && widget.id! < compositionsList.length) {
      composition = getCompositions()[widget.id!];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (composition == null) {
      return const Center(
        child: Text('Composition not found'),
      );
    }

    return StudioScaffold(composition: composition!);
  }
}

class StudioScaffold extends StatefulWidget {
  final Composition composition;
  const StudioScaffold({super.key, required this.composition});

  @override
  State<StudioScaffold> createState() => _StudioScaffoldState();
}

class _StudioScaffoldState extends State<StudioScaffold> {
  final _titleController = TextEditingController();

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'ogg', 'wav', 'm4a'],
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        widget.composition.sounds.add(
          Sound(path: filePath),
        );
      }
    }

    setState(() {
      // print('setting state');
    });
  }

  Future<void> _saveComposition() async {
    await saveComposition(widget.composition);
  }

  Future<void> _renameComposition() async {
    widget.composition.name = _titleController.text;
    await saveComposition(widget.composition);
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = widget.composition.name;
    widget.composition.lastActivity = DateTime.now();
    _saveComposition();
    final sounds = widget.composition.sounds;
    // print('sounds refreshed: $sounds');

    return Scaffold(
      appBar: AppBar(
        title: EditTextField(controller: _titleController, onSubmitted: (_) => _renameComposition()),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _pickAudioFile, child: const Icon(Icons.add)),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('Play'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Publish'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Export'),
              ),
              ElevatedButton(
                onPressed: _saveComposition,
                child: Text('Save'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                Sound s = sounds[index];
                return Text('${s.path} ${s.isMuted} ${s.type}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
