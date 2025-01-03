import 'package:flutter/material.dart';
import '../data_structures/composition_data_structures.dart';
import '../data_structures/studio_data_structures.dart';

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

class SoundControl extends StatefulWidget {
  final StudioData studioData; // the studio data object
  final int index; // the specific index which this sound control represents
  const SoundControl({super.key, required this.studioData, required this.index});

  @override
  State<SoundControl> createState() => _SoundControlState();
}

class _SoundControlState extends State<SoundControl> {

  @override
  Widget build(BuildContext context) {
    SoundUnit su = widget.studioData.soundUnits[widget.index];

    return Row(
      children: [
        MuteSoloToggle(),
        VolumeSlider(value: su.sound.volume, onChanged: (value) {
          setState(() {
            widget.studioData.setVolume(widget.index, value);
          });
        }),
        Panner3D(),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.cut),
          label: const Text('Trim'),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.delete),
          label: const Text('Delete'),
        ),
      ],
    );
  }
}

class MuteSoloToggle extends StatefulWidget {
  const MuteSoloToggle({super.key});

  @override
  State<MuteSoloToggle> createState() => _MuteSoloToggleState();
}

class _MuteSoloToggleState extends State<MuteSoloToggle> {
  @override
  Widget build(BuildContext context) {
    return const Text('Mute/Solo');
  }
}

class VolumeSlider extends StatefulWidget {
  final Function(double) onChanged;
  final double value;
  const VolumeSlider({super.key, required this.onChanged, required this.value});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      onChanged: (value) => widget.onChanged(value),
      value: widget.value,
    );
  }
}

class Panner3D extends StatefulWidget {
  const Panner3D({super.key});

  @override
  State<Panner3D> createState() => _Panner3DState();
}

class _Panner3DState extends State<Panner3D> {
  @override
  Widget build(BuildContext context) {
    return const Text('Panner');
  }
}
