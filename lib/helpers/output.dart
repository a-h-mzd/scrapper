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
    File file;
    if (Platform.isMacOS)
      file = File(Directory.current.parent.parent.parent.parent.path +
          '/Desktop/$fileName');
    else
      file = File(Directory.current.path + '/data/$fileName');
    file
      ..createSync(recursive: true)
      ..writeAsStringSync(text);
  }
}
