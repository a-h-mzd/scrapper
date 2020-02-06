import 'package:flutter/material.dart';
import 'package:scrapper/models/variant.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:scrapper/components/data_presenter.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: SingleChildScrollView(
        child: DataPresenter([
          Variant(
            name: '1',
            aADDScore: 14,
            alleleFrequency: 16,
          ),
          Variant(
            name: '2',
            aADDScore: 12,
            alleleFrequency: 17,
          ),
          Variant(
            name: '3',
            aADDScore: 13,
            alleleFrequency: 15,
          ),
        ].expand<Variant>((element) {
          List<Variant> ret = [];
          for (int i = 0; i < 4; i++) ret.add(element);
          return ret;
        }).toList()),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TabInfo implements TickerProvider {
  NewTab _tab;
  String _title;
  IconData _icon;
  bool _canReset = true;
  AnimationController _controller;
  final GlobalKey _mainKey = GlobalKey();
  void Function(VoidCallback) changeState;
  final Duration animationLength = Duration(milliseconds: 200);

  NewTab get tab => _tab;
  String get title => _title;
  IconData get icon => _icon;

  set title(String newTitle) => _title = newTitle;
  set icon(IconData newIcon) => _icon = newIcon;

  Widget get widget => ScaleTransition(
        child: _tab,
        key: _mainKey,
        scale: _controller,
      );

  void reset() {
    if (!_canReset) return;
    _canReset = false;
    _icon = Icons.tab;
    _title = 'New Tab';
    _controller.reverse().then((value) {
      changeState(
          () => _tab = NewTab(changeState, tabInfo: this, key: GlobalKey()));
      _controller.forward().then((value) => _canReset = true);
    });
  }

  TabInfo(
    this.changeState, {
    IconData icon,
    String title,
  })  : _title = title ?? 'New Tab',
        _icon = icon ?? Icons.tab {
    _tab = NewTab(changeState, tabInfo: this, key: GlobalKey());
    _controller = AnimationController(
      value: 1,
      vsync: this,
      duration: animationLength,
    );
  }

  @override
  Ticker createTicker(onTick) {
    return Ticker(onTick);
  }
}
