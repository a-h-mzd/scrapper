import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrapper/helpers/db.dart';
import 'package:scrapper/components/Text.dart';
import 'package:scrapper/API/get_variants.dart';
import 'package:scrapper/models/minimum_db.dart';
import 'package:scrapper/components/loading_dots.dart';

class Loading {
  bool _canPop = false;
  static Loading _instance;

  factory Loading() {
    if (_instance == null) _instance = Loading._();
    return _instance;
  }

  Loading._();

  void show(BuildContext context, [bool isDBCreating = false]) {
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
              isDBCreating
                  ? _DownloadIndexIndicator()
                  : CText('Downloading data...'),
              SizedBox(height: 16),
              _ProgressIndicator(),
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

class _ProgressIndicator extends StatefulWidget {
  @override
  _ProgressIndicatorState createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<_ProgressIndicator> {
  StreamSubscription<double> _listener;
  double _progress = 0;

  @override
  void initState() {
    super.initState();

    _listener = GetVariants.progressStreamController.stream.listen((progress) {
      _progress = (progress * 10000).floorToDouble() / 100;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _listener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CText('%$_progress', fontWeight: FontWeight.bold),
        SizedBox(width: 8),
        CircularProgressIndicator(
          strokeWidth: 3,
          backgroundColor: Colors.grey[200],
          value: _progress == 0 ? null : _progress / 100,
        ),
      ],
    );
  }
}

class _DownloadIndexIndicator extends StatefulWidget {
  @override
  _DownloadIndexIndicatorState createState() => _DownloadIndexIndicatorState();
}

class _DownloadIndexIndicatorState extends State<_DownloadIndexIndicator> {
  StreamSubscription<int> _listener;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _listener = DB.progressStreamController.stream.listen((progress) {
      _progress = progress;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _listener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final int max = (minDB.split('\n')..removeLast()).length;
    return CText('Downloading data... $_progress/$max');
  }
}
