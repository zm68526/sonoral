import 'custom_exceptions.dart';

// the delimeter between different attributes of a composition when saved as text
String compositionDelimeter = '⦀';

// the delimeter between different attributes of a sound when saved as text
String soundDelimeter = '⥹';

// A class to represent a complete composition project
class Composition {
  String name;
  String authorUsername;
  String? description;
  List<Sound> sounds;
  DateTime lastActivity;
  int? index;

  Composition({
    required this.name,
    required this.authorUsername,
    required this.lastActivity,
    this.description,
    this.sounds = const [],
    this.index,
  });

  factory Composition.fromString(String s, int? index) {
    var tokens = s.split(compositionDelimeter);
    if (tokens.length < 5) {
      throw SonoralCompositionFormatException(
          invalidValue: '${tokens.length} tokens found, 5 expected for composition $s');
    }

    try {
      var name = tokens[0];
      var author = tokens[1];
      var description = tokens[2];
      var lastModified =
          DateTime.fromMillisecondsSinceEpoch(int.parse(tokens[3]));

      // Remainder of the tokens are considered separate sounds
      List<Sound> sounds = [];
      for (int i = 4; i < tokens.length; i++) {
        if (tokens[i].isEmpty) continue;
        sounds.add(Sound.fromString(tokens[i]));
      }

      /*
      print(tokens[4].split(soundDelimeter));
      var soundStrings = tokens[4].split(soundDelimeter);
      for (var soundString in soundStrings) {
        if (soundString.isNotEmpty) sounds.add(Sound.fromString(soundString));
      } */

      return Composition(
        name: name,
        authorUsername: author,
        description: description,
        sounds: sounds,
        lastActivity: lastModified,
        index: index,
      );
    } catch (e) {
      throw SonoralCompositionFormatException(message: "${e.toString()} on composition $s");
    }
  }

  @override
  String toString() {
    var soundStrings =
        sounds.map((sound) => sound.toString()).join(compositionDelimeter);
    StringBuffer sb = StringBuffer();

    sb.write(name);
    sb.write(compositionDelimeter);

    sb.write(authorUsername);
    sb.write(compositionDelimeter);

    sb.write(description);
    sb.write(compositionDelimeter);

    sb.write(lastActivity.millisecondsSinceEpoch);
    sb.write(compositionDelimeter);

    sb.write(soundStrings);
    return sb.toString();
  }
}

class Sound {
  String path;
  double volume;
  double panx;
  double pany;
  double panz;
  SoundType type;
  double trimLeft;
  double trimRight;
  double repeatLeft;
  double repeatRight;
  bool isMuted;
  bool isSolo;

  Sound({
    required this.path,
    this.volume = 1.0,
    this.panx = 0.0,
    this.pany = 0.0,
    this.panz = 0.0,
    this.type = SoundType.looping,
    this.trimLeft = 0,
    this.trimRight = 0,
    this.repeatLeft = -1.0,
    this.repeatRight = -1.0,
    this.isMuted = false,
    this.isSolo = false,
  });

  factory Sound.fromString(String s) {
    var tokens = s.split(soundDelimeter);
    if (tokens.length != 12) {
      throw SonoralSoundFormatException(invalidValue: '${tokens.length} tokens found, expected 9 on sound $s ');
    }

    try {
      var path = tokens[0];
      var volume = double.parse(tokens[1]);
      var panx = double.parse(tokens[2]);
      var pany = double.parse(tokens[3]);
      var panz = double.parse(tokens[4]);
      var type = SoundType.values[int.parse(tokens[5])];
      var trimLeft = double.parse(tokens[6]);
      var trimRight = double.parse(tokens[7]);
      var repeatLeft = double.parse(tokens[8]);
      var repeatRight = double.parse(tokens[9]);
      var isMuted = tokens[10] == 'true';
      var isSolo = tokens[11] == 'true';

      return Sound(
        path: path,
        volume: volume,
        panx: panx,
        pany: pany,
        panz: panz,
        type: type,
        trimLeft: trimLeft,
        trimRight: trimRight,
        repeatLeft: repeatLeft,
        repeatRight: repeatRight,
        isMuted: isMuted,
        isSolo: isSolo,
      );
    } catch (e) {
      throw SonoralSoundFormatException(message: e.toString());
    }
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();

    sb.write(path);
    sb.write(soundDelimeter);

    sb.write(volume);
    sb.write(soundDelimeter);

    sb.write(panx);
    sb.write(soundDelimeter);

    sb.write(pany);
    sb.write(soundDelimeter);

    sb.write(panz);
    sb.write(soundDelimeter);

    sb.write(type.index);
    sb.write(soundDelimeter);

    sb.write(trimLeft);
    sb.write(soundDelimeter);

    sb.write(trimRight);
    sb.write(soundDelimeter);

    sb.write(repeatLeft);
    sb.write(soundDelimeter);

    sb.write(repeatRight);
    sb.write(soundDelimeter);

    sb.write(isMuted);
    sb.write(soundDelimeter);

    sb.write(isSolo);

    return sb.toString();
  }
}

enum SoundType { looping, oneshot }

class Download {
  Composition information;
  DateTime downloadDate;

  Download({
    required this.information,
    required this.downloadDate,
  });
}
