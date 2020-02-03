import 'dart:math' show Random;

import 'package:flutter/material.dart';

class NewTab extends StatefulWidget {
  TabInfo get getTabInfo => _tabInfo;

  NewTab(
    this.changeState, {
    TabInfo tabInfo,
    GlobalKey<_NewTabState> key,
  })  : _tabInfo = tabInfo,
        super(key: key);

  final TabInfo _tabInfo;
  final void Function(VoidCallback) changeState;

  @override
  _NewTabState createState() => _NewTabState();
}

class _NewTabState extends State<NewTab>
    with AutomaticKeepAliveClientMixin<NewTab> {
  int _text = Random().nextInt(100);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: RaisedButton(
        onPressed: () =>
            widget.changeState(() => widget.getTabInfo.title = 'title changed'),
        child: Text(_text.toString()),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TabInfo {
  String _title;
  IconData _icon;
  NewTab _tab;

  String get title => _title;
  IconData get icon => _icon;
  NewTab get tab => _tab;

  set title(String newTitle) => _title = newTitle;
  set icon(IconData newIcon) => _icon = newIcon;

  TabInfo(
    void Function(VoidCallback) changeState, {
    IconData icon,
    String title,
  })  : _title = title ?? 'New Tab',
        _icon = icon ?? Icons.tab {
    _tab = NewTab(changeState, tabInfo: this, key: GlobalKey());
  }
}
