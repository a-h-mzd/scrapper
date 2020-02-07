import 'package:flutter/material.dart';
import 'package:scrapper/models/variant.dart';
import 'package:scrapper/API/get_variants.dart';
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
  List<Variant> variants = [];
  int _stage = 1;

  void changeStage(int newStage, var data) async {}

  @override
  void initState() {
    super.initState();

    GetVariants()
        .getVariants('OTX2')
        .then((value) => setState(() => variants = value));
  }

  Widget get stageWidget {
    Widget child;
    switch (_stage) {
      case 0:
        child = Container();
        break;
      case 1:
        child = variants.isEmpty ? Container() : DataPresenter(variants);
        break;
      default:
        child = Container();
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: SingleChildScrollView(
        child: stageWidget,
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
