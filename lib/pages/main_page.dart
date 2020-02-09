import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrapper/pages/new_tab.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FocusNode _focusNode = FocusNode();
  final List<TabInfo> _tabs = <TabInfo>[];
  bool _canAddTab = true;

  @override
  void initState() {
    super.initState();

    _addNewTab();
  }

  @override
  Widget build(BuildContext context) {
    _focusNode.requestFocus();
    return DefaultTabController(
      length: _tabs.length,
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
      ];

  void _addNewTab() => _tabs.add(TabInfo(setState));

  void addNewTab(BuildContext context) async {
    if (!_canAddTab) return;
    _canAddTab = false;
    setState(_addNewTab);
    await Future.delayed(Duration(milliseconds: 100));
    DefaultTabController.of(context).animateTo(_tabs.length - 1);
    _canAddTab = true;
  }

  void closeAll() async {
    while (_tabs.length > 1) {
      setState(() => _tabs.removeLast());
      await Future.delayed(Duration(milliseconds: 300));
    }
    setState(() => _tabs.last.reset());
  }

  void onMenuItemSelected(BuildContext context, String action) {
    switch (action) {
      case 'NewTab':
        addNewTab(context);
        break;
      case 'Close All':
        closeAll();
        break;
      default:
        break;
    }
  }

  void onKey(BuildContext context, RawKeyEvent event) {
    if (!event.isControlPressed) return;
    if (event.isKeyPressed(LogicalKeyboardKey.keyT))
      addNewTab(context);
    else if (event.isKeyPressed(LogicalKeyboardKey.keyW)) if (_tabs.length == 1)
      _tabs.last.reset();
    else
      _tabs.removeLast();
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
              tabs: _tabs.map((TabInfo tabInfo) {
                return Tab(
                  child: GestureDetector(
                    onLongPress: () => setState(() => _tabs.length == 1
                        ? _tabs.last.reset()
                        : _tabs.removeWhere((TabInfo newTabInfo) =>
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
            children: _tabs.map((TabInfo tabInfo) {
              return tabInfo.widget;
            }).toList(),
          ),
        ),
      );
}