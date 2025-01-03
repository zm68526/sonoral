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

    // find the appropriate composition from the passed id
    if (widget.id != null && widget.id! < compositionsList.length) {
      composition = compositionsList[widget.id!];
    }
  }

  // builds the new studio data object from the passed composition
  Future<StudioData> _buildStudioData() async {
    return await StudioDataBuilder.buildStudioData(composition!);
  }

  @override
  Widget build(BuildContext context) {
    if (composition == null) {
      return const Center(
        child: Text('Composition not found'),
      );
    }

    return FutureBuilder<StudioData>(
      future: _buildStudioData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StudioScaffold(
            composition: composition!,
            studioData: snapshot.data!,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class StudioScaffold extends StatefulWidget {
  final Composition composition;
  final StudioData studioData;
  const StudioScaffold(
      {super.key, required this.composition, required this.studioData});

  @override
  State<StudioScaffold> createState() => _StudioScaffoldState();
}

class _StudioScaffoldState extends State<StudioScaffold> {
  final _titleController = TextEditingController();
  var _playButtonText = 'Play';

  @override
  void dispose() {
    super.dispose();
    widget.studioData.dispose();
  }

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
    widget.composition.sounds = widget.studioData.sounds;
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
        title: EditTextField(
            controller: _titleController,
            onSubmitted: (s) => widget.composition.name = s),
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
                onPressed: () {
                  if (_playButtonText == 'Play') {
                    widget.studioData.playAll();
                    setState(() => _playButtonText = 'Stop',);
                  } else {
                    widget.studioData.stopAll();
                    setState(() => _playButtonText = 'Play',);
                  }
                },
                child: Text(_playButtonText),
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
                // Sound s = sounds[index];
                return SoundControl(
                  studioData: widget.studioData,
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
