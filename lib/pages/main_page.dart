import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrapper/helpers/db.dart';
import 'package:scrapper/pages/new_tab.dart';
import 'package:scrapper/API/get_variants.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final StreamController<void> backSpaceController =
      StreamController.broadcast();
  final FocusNode _focusNode = FocusNode();
  final List<TabInfo> tabs = <TabInfo>[];
  bool _canAddTab = true;

  @override
  void initState() {
    super.initState();

    _addNewTab();
  }

  @override
  void dispose() {
    backSpaceController.close();
    GetVariants.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _focusNode.requestFocus();
    return DefaultTabController(
      length: tabs.length,
      child: Builder(builder: builder),
    );
  }

  List<PopupMenuEntry<String>> menuBuilder(BuildContext context) =>
      <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'NewTab',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add,
                color: Colors.black,
              ),
              SizedBox(width: 8),
              Text('NewTab'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Close All',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.close,
                color: Colors.black,
              ),
              SizedBox(width: 8),
              Text('Close All'),
            ],
          ),
        ),
        if (!DB().containsMinimum())
          PopupMenuItem<String>(
            value: 'download database',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.cloud_download,
                  color: Colors.black,
                ),
                SizedBox(width: 8),
                Text('download database'),
              ],
            ),
          ),
      ];

  void _addNewTab() => tabs.add(TabInfo(this));

  void addNewTab(BuildContext context) async {
    if (!_canAddTab) return;
    _canAddTab = false;
    setState(_addNewTab);
    await Future.delayed(Duration(milliseconds: 100));
    DefaultTabController.of(context).animateTo(tabs.length - 1);
    _canAddTab = true;
  }

  void closeAll() async {
    while (tabs.length > 1) {
      setState(() => tabs.removeLast());
      await Future.delayed(Duration(milliseconds: 300));
    }
    setState(() => tabs.last.reset());
  }

  void onMenuItemSelected(BuildContext context, String action) {
    switch (action) {
      case 'NewTab':
        addNewTab(context);
        break;
      case 'Close All':
        closeAll();
        break;
      case 'download database':
        DB().createMinimumDB(context);
        break;
      default:
        break;
    }
  }

  void onKey(BuildContext context, RawKeyEvent event) {
    if (!event.isControlPressed) return;
    if (event.isKeyPressed(LogicalKeyboardKey.keyT))
      addNewTab(context);
    else if (event.isKeyPressed(LogicalKeyboardKey.keyW)) {
      if (tabs.length == 1)
        tabs.last.reset();
      else
        tabs.removeAt(DefaultTabController.of(context).index);
    } else if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
      backSpaceController.add(null);
    }
    setState(() {});
  }

  Widget builder(BuildContext context) => RawKeyboardListener(
        onKey: (event) => onKey(context, event),
        focusNode: _focusNode,
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              PopupMenuButton<String>(
                itemBuilder: menuBuilder,
                icon: Icon(Icons.more_vert),
                onSelected: (String action) =>
                    onMenuItemSelected(context, action),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ],
            centerTitle: false,
            title: TabBar(
              isScrollable: true,
              tabs: tabs.map((TabInfo tabInfo) {
                return Tab(
                  child: GestureDetector(
                    onLongPress: () => setState(() => tabs.length == 1
                        ? tabs.last.reset()
                        : tabs.removeWhere((TabInfo newTabInfo) =>
                            tabInfo.tab.key == newTabInfo.tab.key)),
                    child: Row(
                      children: <Widget>[
                        Icon(tabInfo.tab.getTabInfo.icon),
                        SizedBox(width: 8),
                        Text(tabInfo.tab.getTabInfo.title),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: tabs.map((TabInfo tabInfo) {
              return tabInfo.widget;
            }).toList(),
          ),
        ),
      );
}
