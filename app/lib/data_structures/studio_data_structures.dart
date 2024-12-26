import 'composition_data_structures.dart';
import 'dart:collection';
import 'package:flutter_soloud/flutter_soloud.dart';

// Moving to a separate class enables async construction
class SoundUnitBuilder {
  static Future<SoundUnit> buildSoundUnit(Sound s) async {
    final soloud = SoLoud.instance;
    Exception? e;
    AudioSource? source;
    try {
      source = await soloud.loadAsset(s.path);
    } on Exception catch (exception) {
      e = exception;
    }
    
    if (source == null) {
      return SoundUnit(
        sound: s,
        exception: e,
      );
    } else {
      return SoundUnit(
        sound: s,
        module: AudioModule(
          source: source,
        ),
      );
    }
  }
}

class SoundUnit {
  Sound sound;
  AudioModule? module;
  Exception? exception;

  SoundUnit({required this.sound, this.module, this.exception});
}

class AudioModule {
  AudioSource source;

  AudioModule({required this.source});

  UnmodifiableSetView<SoundHandle> get activeInstances => source.handles;
}
