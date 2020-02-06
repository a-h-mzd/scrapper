import 'dart:io';

class Input {
  static Input _instance;

  factory Input() {
    if (_instance == null) _instance = Input._internal();
    return _instance;
  }

  Input._internal();

  String writeString(String fileName) {
    if (fileName == null) return null;
    String output;
    File file = File(Directory.current.path + '/output/$fileName');
    if (file.existsSync()) output = file.readAsStringSync();
    return output;
  }
}