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

class SoundControl extends StatefulWidget {
  const SoundControl({super.key});

  @override
  State<SoundControl> createState() => _SoundControlState();
}

class _SoundControlState extends State<SoundControl> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MuteSoloToggle(),
        VolumeSlider(),
        BinauralPanner(),
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
  const VolumeSlider({super.key});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  @override
  Widget build(BuildContext context) {
    return const Text('Volume');
  }
}

class BinauralPanner extends StatefulWidget {
  const BinauralPanner({super.key});

  @override
  State<BinauralPanner> createState() => _BinauralPannerState();
}

class _BinauralPannerState extends State<BinauralPanner> {
  @override
  Widget build(BuildContext context) {
    return const Text('Panner');
  }
}
