class SonoralCompositionFormatException implements Exception {
  final String? message;
  final String invalidValue;

  SonoralCompositionFormatException({this.invalidValue = "", this.message = 'Invalid composition string format'});

  @override
  String toString() => '$message: $invalidValue';
}

class SonoralSoundFormatException implements Exception {
  final String? message;
  final String invalidValue;

  SonoralSoundFormatException({this.invalidValue = "", this.message = 'Invalid sound string format'});

  @override
  String toString() => '$message: $invalidValue';
}

class SonoralCurrentlyPlayingException implements Exception {
  final String? message;
  final String invalidValue;

  SonoralCurrentlyPlayingException({this.invalidValue = "", this.message = 'Tried to modify a currently playing sound'});

  @override
  String toString() => '$message: $invalidValue';
}
