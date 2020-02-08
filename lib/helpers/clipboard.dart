import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrapper/components/Text.dart';

class ClipBoardHelper {
  static ClipBoardHelper _instance;

  factory ClipBoardHelper() {
    if (_instance == null) _instance = ClipBoardHelper._();
    return _instance;
  }

  ClipBoardHelper._();

  Future<void> copyToClipBoard(
      final BuildContext context, final String newData) async {
    String oldData;
    try {
      oldData = (await Clipboard.getData('text/plain')).text;
    } catch (e) {}
    await Clipboard.setData(ClipboardData(text: newData));
    final SnackBar snackBar = SnackBar(
      content: Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            child: CText(
              'copied to clipboard.',
              textAlign: TextAlign.center,
            ),
          ),
          if (oldData != null)
            Material(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                child: Padding(
                  child: CText('undo'),
                  padding: const EdgeInsets.all(8),
                ),
                splashColor: Colors.blueGrey,
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: oldData));
                  Scaffold.of(context).hideCurrentSnackBar();
                },
              ),
            ),
        ],
      ),
      shape: Border(
        top: BorderSide(width: 2, color: Colors.blue),
      ),
    );
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
