import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrapper/pages/details.dart';
import 'package:scrapper/helpers/filter.dart';
import 'package:scrapper/models/variant.dart';
import 'package:scrapper/pages/main_page.dart';
import 'package:scrapper/components/search.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:scrapper/components/data_presenter.dart';

class NewTab extends StatefulWidget {
  TabInfo get getTabInfo => _tabInfo;

  NewTab(
    this.mainPageState, {
    TabInfo tabInfo,
    GlobalKey<NewTabState> key,
  })  : _tabInfo = tabInfo,
        super(key: key);

  final TabInfo _tabInfo;
  final MainPageState mainPageState;

  @override
  NewTabState createState() => NewTabState();
}

class NewTabState extends State<NewTab>
    with AutomaticKeepAliveClientMixin<NewTab> {
  StreamSubscription<void> _subscription;
  Size screenSize = Size(0, 0);
  Filter _filter = Filter();
  List<Variant> rawVariants;
  List<Variant> _variants;
  Variant selectedVariant;
  int stage = 0;

  Widget get stageWidget {
    Widget child;
    switch (stage) {
      case 0:
        child = Search(this);
        break;
      case 1:
        child = DataPresenter(_variants, this);
        break;
      case 2:
        child = Details(variant: selectedVariant);
        break;
      default:
        child = Container();
    }
    return child;
  }

  void startFiltering() {
    _variants = _filter.filter(rawVariants);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _subscription =
        widget.mainPageState.backSpaceController.stream.listen((event) {
      if (stage == 0) return;
      if (DefaultTabController.of(context).index !=
          widget.mainPageState.tabs
              .indexWhere((element) => element == widget._tabInfo)) return;

      switch (stage) {
        case 1:
          widget._tabInfo.reset();
          break;
        case 2:
          stage = 1;
          widget._tabInfo.title = widget._tabInfo.backupTitle;
          setState(() {});
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(builder: (context, constraints) {
      screenSize = constraints.biggest;
      return Center(
        child: SingleChildScrollView(
          child: stageWidget,
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class TabInfo implements TickerProvider {
  NewTab _tab;
  String _title;
  IconData _icon;
  String backupTitle;
  bool _canReset = true;
  AnimationController _controller;
  final MainPageState mainPageState;
  final GlobalKey _mainKey = GlobalKey();
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
    _title = 'Search';
    _controller.reverse().then((value) {
      _tab = NewTab(mainPageState, tabInfo: this, key: GlobalKey());
      mainPageState.setState(() {});
      _controller.forward().then((value) => _canReset = true);
    });
  }

  TabInfo(
    this.mainPageState, {
    IconData icon,
    String title,
  })  : _title = title ?? 'Search',
        _icon = icon ?? Icons.tab {
    _tab = NewTab(mainPageState, tabInfo: this, key: GlobalKey());
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
