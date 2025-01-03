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
  const SoundControl(
      {super.key, required this.studioData, required this.index});

  @override
  State<SoundControl> createState() => _SoundControlState();
}

class _SoundControlState extends State<SoundControl> {
  @override
  Widget build(BuildContext context) {
    SoundUnit su = widget.studioData.soundUnits[widget.index];

    return Row(
      children: [
        MuteSoloButtons(
          isMuted: su.sound.isMuted,
          isSolo: su.sound.isSolo,
          onMute: (value) {
            setState(() {
              widget.studioData.setMuted(
                widget.index,
                value,
              );
            });
          },
          onSolo:(value) {
            setState(() {
              su.sound.isSolo = value;
            });
          },
        ),
        VolumeSlider(
            value: su.sound.volume,
            onChanged: (value) {
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

class MuteSoloButtons extends StatefulWidget {
  final bool isMuted;
  final bool isSolo;
  final Function(bool) onMute;
  final Function(bool) onSolo;
  const MuteSoloButtons(
      {super.key,
      required this.isMuted,
      required this.isSolo,
      required this.onMute,
      required this.onSolo});

  @override
  State<MuteSoloButtons> createState() => _MuteSoloButtonsState();
}

class _MuteSoloButtonsState extends State<MuteSoloButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isMuted ? Colors.red : null,
          ),
          onPressed: () {
            widget.onMute(!widget.isMuted);
          },
          child: Text('M'),
          // label: const Text('Mute'),
        ),
        const SizedBox(width: 4.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isSolo ? Colors.yellow : null,
          ),
          onPressed: () {
            widget.onSolo(!widget.isSolo);
          },
          child: Text('S'),
          // label: const Text('Solo'),
        ),
      ],
    );
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

class RepeatTypeToggle extends StatefulWidget {
  const RepeatTypeToggle({super.key});

  @override
  State<RepeatTypeToggle> createState() => _RepeatTypeToggleState();
}

class _RepeatTypeToggleState extends State<RepeatTypeToggle> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class RepetitionDelayEntry extends StatefulWidget {
  const RepetitionDelayEntry({super.key});

  @override
  State<RepetitionDelayEntry> createState() => _RepetitionDelayEntryState();
}

class _RepetitionDelayEntryState extends State<RepetitionDelayEntry> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
