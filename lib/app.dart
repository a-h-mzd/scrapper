import 'package:flutter/material.dart';
import 'package:scrapper/pages/search_page.dart';

class ScrapperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'scrapper',
      home: SearchPage(),
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
