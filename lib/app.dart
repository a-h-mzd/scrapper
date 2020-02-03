import 'package:flutter/material.dart';
import 'package:scrapper/Pages/search_page.dart';

class ScrapperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'scrapper',
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: SearchPage(),
    );
  }
}
