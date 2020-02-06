import 'dart:io';

class Output {
  static Output _instance;

  factory Output() {
    if (_instance == null) _instance = Output._internal();
    return _instance;
  }

  Output._internal();

  void writeString(String fileName, String text) {
    if (text == null || fileName == null) return;
    File(Directory.current.path + '/output/$fileName')
      ..createSync()
      ..writeAsString(text);
  }
}
