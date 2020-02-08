import 'package:flutter/material.dart';
import 'package:scrapper/pages/main_page.dart';

class ScrapperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'scrapper',
      home: MainPage(),
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
