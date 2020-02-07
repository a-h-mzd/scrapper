import 'package:flutter/material.dart';
import 'package:scrapper/components/Text.dart';
import 'package:scrapper/components/loading_dots.dart';

class Loading {
  bool _canPop = false;
  static Loading _instance;

  factory Loading() {
    if (_instance == null) _instance = Loading._();
    return _instance;
  }

  Loading._();

  void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
          SizedBox(height: 8),
          CText('downloading data...'),
          LoadingDots(),
            ],
          ),
          width: MediaQuery.of(context).size.width / 10,
        ),
      ),
    );
    _canPop = true;
  }

  void hide(BuildContext context) {
    if (_canPop) Navigator.of(context).pop();
    _canPop = false;
  }
}
