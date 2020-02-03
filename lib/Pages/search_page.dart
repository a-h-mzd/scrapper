import 'package:flutter/material.dart';
import 'package:scrapper/Pages/new_tab.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<TabInfo> _tabs;

  @override
  void initState() {
    super.initState();

    _tabs = <TabInfo>[
      TabInfo(setState),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Builder(builder: builder),
    );
  }

  Widget builder(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                setState(() => _tabs.add(TabInfo(setState)));
                await Future.delayed(Duration(milliseconds: 150));
                DefaultTabController.of(context).animateTo(_tabs.length - 1);
              },
            ),
          ],
          centerTitle: false,
          title: TabBar(
            isScrollable: true,
            tabs: _tabs.map((TabInfo tabInfo) {
              return Tab(
                child: GestureDetector(
                  onLongPress: () => setState(() => _tabs.remove(tabInfo)),
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
            return tabInfo.tab;
          }).toList(),
        ),
      );
}
