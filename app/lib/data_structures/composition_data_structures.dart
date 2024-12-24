import 'custom_exceptions.dart';

// the delimeter between different attributes of a composition when saved as text
String compositionDelimeter = '⦀';

// the delimetere between different attributes of a sound when saved as text
String soundDelimeter = '⥹';

// A class to represent a complete composition project
class Composition {
  String name;
  String authorUsername;
  String? description;
  List<Sound> sounds;
  DateTime lastModified;
  int? index;

  Composition({
    required this.name,
    required this.authorUsername,
    required this.lastModified,
    this.description,
    this.sounds = const [],
    this.index,
  });

  factory Composition.fromString(String s, int? index) {
    var tokens = s.split(compositionDelimeter);
    if (tokens.length != 5) {
      throw InvalidCompositionFormatException(
          invalidValue: 'Not enough tokens for composition $s');
    }

    try {
      var name = tokens[0];
      var author = tokens[1];
      var description = tokens[2];
      var lastModified =
          DateTime.fromMillisecondsSinceEpoch(int.parse(tokens[3]));

      List<Sound> sounds = [];
      var soundStrings = tokens[4].split(soundDelimeter);
      for (var soundString in soundStrings) {
        if (soundString.isNotEmpty) sounds.add(Sound.fromString(soundString));
      }

      return Composition(
        name: name,
        authorUsername: author,
        description: description,
        sounds: sounds,
        lastModified: lastModified,
        index: index,
      );
    } catch (e) {
      throw InvalidCompositionFormatException(message: e.toString());
    }
  }

  @override
  String toString() {
    var soundStrings =
        sounds.map((sound) => sound.toString()).join(soundDelimeter);
    StringBuffer sb = StringBuffer();

    sb.write(name);
    sb.write(compositionDelimeter);

    sb.write(authorUsername);
    sb.write(compositionDelimeter);

    sb.write(description);
    sb.write(compositionDelimeter);

    sb.write(lastModified.millisecondsSinceEpoch);
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
  bool isMuted;

  Sound({
    required this.path,
    this.volume = 1.0,
    this.panx = 0.0,
    this.pany = 0.0,
    this.panz = 0.0,
    this.type = SoundType.looping,
    this.trimLeft = -1.0,
    this.trimRight = -1.0,
    this.isMuted = false,
  });

  factory Sound.fromString(String s) {
    var tokens = s.split(soundDelimeter);
    if (tokens.length != 9) {
      throw InvalidSoundFormatException(invalidValue: 'Not enough tokens');
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
      var isMuted = tokens[8] == 'true';

      return Sound(
        path: path,
        volume: volume,
        panx: panx,
        pany: pany,
        panz: panz,
        type: type,
        trimLeft: trimLeft,
        trimRight: trimRight,
        isMuted: isMuted,
      );
    } catch (e) {
      throw InvalidSoundFormatException(message: e.toString());
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

    sb.write(isMuted);

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
