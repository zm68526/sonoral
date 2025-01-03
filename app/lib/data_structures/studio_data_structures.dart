import 'package:sonoral_app/data_structures/custom_exceptions.dart';

import 'composition_data_structures.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:flutter_soloud/flutter_soloud.dart';

// Holds information about a sound and its playback information
class SoundUnit {
  Sound sound;
  AudioModule? module;
  Exception? exception;

  SoundUnit({required this.sound, this.module, this.exception});

  Future<SoundHandle?> play() async {
    if (module == null) return null;
    final soloud = SoLoud.instance;
    SoundHandle? handle;

    if (sound.trimLeft == 0 && sound.trimRight == 0) {
      handle = await soloud.play3d(
        module!.source,
        sound.panx,
        sound.pany,
        sound.panz,
        looping: sound.type == SoundType.looping,
        volume: sound.volume,
        paused: true,
      );
    } else {
      // if trimLeft defined and trimRight is not defined:
      //    seek to the trimLeft position
      //    if looping, let the engine handle the looping
      //    if one-shot, let the sound play out normally
      // if trimLeft either is or is not defined and trimRight is defined:
      //    seek to the trimLeft position (by default, 0)
      //    calculate the loop duration (trimRight - trimLeft)
      //    if looping, use a timer to seek to the beginning after the loop has completed
      //    if one-shot, use a timer to stop the sound after the loop has completed

      // this flag is true when the sound is marked as looping and
      // only has a trimLeft value defined
      bool letEngineHandleLooping =
          (sound.trimLeft != 0 && sound.trimRight == 0) &&
              (sound.type == SoundType.looping);

      // play the sound and set up loop timer
      handle = await soloud.play3d(
        module!.source,
        sound.panx,
        sound.pany,
        sound.panz,
        looping: letEngineHandleLooping,
        volume: sound.isMuted ? 0.0 : sound.volume,
        paused: true,
      );

      // seek to the appropriate position
      soloud.seek(
          handle, Duration(milliseconds: (sound.trimLeft * 1000).toInt()));

      if (letEngineHandleLooping) {
        soloud.setLoopPoint(
            handle, Duration(milliseconds: (sound.trimLeft * 1000).toInt()));
      }

      if (sound.trimRight != 0) {
        Duration loopDuration = Duration(
            milliseconds: ((sound.trimRight - sound.trimLeft) * 1000).toInt());

        if (sound.type == SoundType.looping) {
          // after the loop has completed, seek to the beginning
          module!.trimTimer = Timer.periodic(
            loopDuration,
            (timer) {
              soloud.seek(handle!,
                  Duration(milliseconds: (sound.trimLeft * 1000).toInt()));
            },
          );
        } else {
          // stop the sound after the loop duration has concluded
          module!.trimTimer = Timer(
            loopDuration,
            () {
              soloud.stop(handle!);
            },
          );
        }
      }
    }

    if (sound.type == SoundType.oneshot &&
        (sound.repeatLeft != -1 && sound.repeatRight != -1)) {
      // get random delay
      final random = Random();
      final randomValue = random.nextDouble();
      final result = sound.repeatLeft +
          (randomValue * (sound.repeatRight - sound.repeatLeft));
      var repetitionDelay = double.parse(result.toStringAsFixed(4));

      // set up timer for repeating the sound
      if (module!.repeatTimer == null || module!.repeatTimer!.isActive) {
        module!.repeatTimer = Timer(
          Duration(milliseconds: (repetitionDelay * 1000).toInt()),
          () {
            play();
          },
        );
      }
    }

    if (sound.isMuted) {
      soloud.setVolume(handle, 0.0);
    }

    soloud.pauseSwitch(handle);
    return handle;
  }

  Future<void> stop() async {
    final soloud = SoLoud.instance;

    module?.trimTimer?.cancel();
    module?.repeatTimer?.cancel();

    module?.activeInstances.forEach((element) async {
      await soloud.stop(element);
    });
  }
}

// Holds information relating to the playback side
class AudioModule {
  AudioSource source;
  Timer? trimTimer;
  Timer? repeatTimer;

  AudioModule({required this.source});

  UnmodifiableSetView<SoundHandle> get activeInstances => source.handles;
}

// Moving to a separate class enables async construction
class SoundUnitBuilder {
  static Future<SoundUnit> buildSoundUnit(Sound s) async {
    final soloud = SoLoud.instance;
    Exception? e;
    AudioSource? source;

    try {
      var file = File(Uri.decodeFull(s.path));
      final normalizedPath = file.absolute.path.replaceAll(r'\', '/');

      // source = await soloud.loadFile(normalizedPath);
      source = await soloud.loadMem(normalizedPath, file.readAsBytesSync());
    } on Exception catch (exception) {
      // print(exception);
      e = exception;
    }

    if (source == null) {
      // there was an exception loading the sound
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

enum SoundParameter {
  volume,
  panx,
  pany,
  panz,
  trimLeft,
  trimRight,
  isMuted,
  isLooping,
}

// Class which the studio widget interfaces with directly
class StudioData {
  List<SoundUnit> soundUnits;
  bool playing;

  StudioData({required this.soundUnits, this.playing = false});

  // gets the sounds from the sound units
  List<Sound> get sounds => soundUnits.map((e) => e.sound).toList();

  // gets a specific sound unit
  SoundUnit getSound(int index) => soundUnits[index];

  // Updates a parameter on all currently playing instances of a sound
  // Note: trimLeft, trimRight, and isLooping are not implemented because
  // they cannot be changed while a sound is playing, and isMuted is implemented
  // in its own function
  void updateAllInstances(int index, SoundParameter type, double newValue) {
    final soundUnit = soundUnits[index];
    final soloud = SoLoud.instance;

    soundUnit.module?.activeInstances.forEach((element) {
      switch (type) {
        case SoundParameter.volume:
          soloud.setVolume(element, newValue);
          break;
        case SoundParameter.panx:
          soloud.set3dSourcePosition(
              element, newValue, soundUnit.sound.pany, soundUnit.sound.panz);
          break;
        case SoundParameter.pany:
          soloud.set3dSourcePosition(
              element, soundUnit.sound.panx, newValue, soundUnit.sound.panz);
          break;
        case SoundParameter.panz:
          soloud.set3dSourcePosition(
              element, soundUnit.sound.panx, soundUnit.sound.pany, newValue);
          break;
        default:
          break;
      }
    });
  }

  void muteAllInstances(int index, bool isMuted) {
    final soundUnit = soundUnits[index];
    final soloud = SoLoud.instance;

    // If telling the engine to mute the sound, set the volume to 0,
    // otherwise set the volume to what's currently saved for the sound
    soundUnit.module?.activeInstances.forEach((element) {
      if (isMuted) {
        soloud.setVolume(element, 0.0);
      } else {
        soloud.setVolume(element, soundUnit.sound.volume);
      }
    });
  }

  Future<void> playAll() async {
    for (var soundUnit in soundUnits) {
      await soundUnit.play();
    }
    playing = true;
  }

  Future<void> stopAll() async {
    for (var soundUnit in soundUnits) {
      await soundUnit.stop();
    }
    playing = false;
  }

  Future<void> dispose() async {
    await stopAll();
    final soloud = SoLoud.instance;
    await soloud.disposeAllSources();
  }

  Future<void> addSound(Sound s) async {
    final soundUnit = await SoundUnitBuilder.buildSoundUnit(s);
    soundUnits.add(soundUnit);
  }

  Future<void> removeSound(int index) async {
    await soundUnits[index].stop();
    soundUnits.removeAt(index);
  }

  void setPanX(int index, double panx) async {
    soundUnits[index].sound.panx = panx;
    updateAllInstances(index, SoundParameter.panx, panx);
  }

  void setPanY(int index, double pany) async {
    soundUnits[index].sound.pany = pany;
    updateAllInstances(index, SoundParameter.pany, pany);
  }

  void setPanZ(int index, double panz) async {
    soundUnits[index].sound.panz = panz;
    updateAllInstances(index, SoundParameter.panz, panz);
  }

  void setVolume(int index, double newVolume) async {
    soundUnits[index].sound.volume = newVolume;
    updateAllInstances(index, SoundParameter.volume, newVolume);
  }

  void setMuted(int index, bool isMuted) {
    soundUnits[index].sound.isMuted = isMuted;
    muteAllInstances(index, isMuted);
  }

  void setRepeatType(int index, SoundType type) {
    if (playing) {
      throw SonoralCurrentlyPlayingException(
          invalidValue: "Cannot change repeat type while playing");
    }

    soundUnits[index].sound.type = type;
  }

  void setTrimLeft(int index, double trimLeft) {
    if (playing) {
      throw SonoralCurrentlyPlayingException(
          invalidValue: "Cannot change trim while playing");
    }

    soundUnits[index].sound.trimLeft = trimLeft;
  }

  void setTrimRight(int index, double trimRight) {
    if (playing) {
      throw SonoralCurrentlyPlayingException(
          invalidValue: "Cannot change trim while playing");
    }

    soundUnits[index].sound.trimRight = trimRight;
  }

  void setRepeatLeft(int index, double repeatLeft) {
    if (playing) {
      throw SonoralCurrentlyPlayingException(
          invalidValue: "Cannot change repetition delay while playing");
    }

    soundUnits[index].sound.repeatLeft = repeatLeft;
  }

  void setRepeatRight(int index, double repeatRight) {
    if (playing) {
      throw SonoralCurrentlyPlayingException(
          invalidValue: "Cannot change repetition delay while playing");
    }

    soundUnits[index].sound.repeatRight = repeatRight;
  }
}

class StudioDataBuilder {
  static Future<StudioData> buildStudioData(Composition c) async {
    final soundUnits = <SoundUnit>[];
    for (var sound in c.sounds) {
      final soundUnit = await SoundUnitBuilder.buildSoundUnit(sound);
      soundUnits.add(soundUnit);
    }

    return StudioData(soundUnits: soundUnits);
  }
}
