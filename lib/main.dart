import 'dart:io';

import 'package:scrapper/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux)
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

  runApp(ScrapperApp());
}
