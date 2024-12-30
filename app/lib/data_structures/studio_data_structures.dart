import 'composition_data_structures.dart';
import 'dart:collection';
import 'dart:io';
import 'package:flutter_soloud/flutter_soloud.dart';

// Moving to a separate class enables async construction
class SoundUnitBuilder {
  static Future<SoundUnit> buildSoundUnit(Sound s) async {
    final soloud = SoLoud.instance;
    File? file;
    Exception? e;
    AudioSource? source;
    try {
      file = File(Uri.decodeFull(s.path));
      final normalizedPath = file.absolute.path.replaceAll(r'\', '/');
      // source = await soloud.loadFile(normalizedPath);

      source = await soloud.loadMem(normalizedPath, file.readAsBytesSync());
    } on Exception catch (exception) {
      print(exception);
      e = exception;
    }

    if (source == null) {
      return SoundUnit(
        sound: s,
        exception: e,
        file: file,
      );
    } else {
      return SoundUnit(
        sound: s,
        file: file,
        module: AudioModule(
          source: source,
        ),
      );
    }
  }
}

class SoundUnit {
  Sound sound;
  File? file;
  AudioModule? module;
  Exception? exception;

  SoundUnit({required this.sound, this.module, this.exception, this.file});

  Future<void> play() async {
    final soloud = SoLoud.instance;

    /* print(soloud.listPlaybackDevices());
    soloud.changeDevice(newDevice: soloud.listPlaybackDevices()[0]); */

    if (module != null) {
      soloud.play3d(module!.source, sound.panx, sound.pany, sound.panz);
      // soloud.play(module!.source);
    }
  }
}

class AudioModule {
  AudioSource source;

  AudioModule({required this.source});

  UnmodifiableSetView<SoundHandle> get activeInstances => source.handles;
}
