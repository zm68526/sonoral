class InvalidCompositionFormatException implements Exception {
  final String? message;
  final String invalidValue;

  InvalidCompositionFormatException({this.invalidValue = "", this.message = 'Invalid composition string format'});

  @override
  String toString() => '$message: $invalidValue';
}

class InvalidSoundFormatException implements Exception {
  final String? message;
  final String invalidValue;

  InvalidSoundFormatException({this.invalidValue = "", this.message = 'Invalid sound string format'});

  @override
  String toString() => '$message: $invalidValue';
}