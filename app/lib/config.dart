import 'dart:io' show Platform;

// the link to the server hosting the backend
const String backendPath = "http://127.0.0.1:5000/";

// whether to show labels on the bottom navigation bar
const showBottomNavigationBarLabels = true;

// whether the current platform is mobile
final isMobile = (Platform.isAndroid || Platform.isIOS);
