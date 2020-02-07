import 'dart:io';

import 'package:scrapper/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:scrapper/helpers/db.dart';

void main() async {
  await DB.init();

  if (Platform.isWindows || Platform.isLinux)
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

  ErrorWidget.builder = (FlutterErrorDetails details) =>
      Container(); //TODO: send details.stack to server.

  runApp(ScrapperApp());
}
