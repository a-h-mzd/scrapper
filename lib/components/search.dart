import 'package:flutter/material.dart';
import 'package:scrapper/components/loading.dart';
import 'package:scrapper/helpers/db.dart';
import 'package:scrapper/pages/new_tab.dart';
import 'package:scrapper/components/Text.dart';
import 'package:scrapper/API/get_variants.dart';

class Search extends StatefulWidget {
  final void Function(VoidCallback) setState;
  final NewTabState newTabState;

  const Search(
    this.setState,
    this.newTabState, {
    Key key,
  }) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _controller = TextEditingController();
  Loading _loading = Loading();

  String get _genomeName => _controller.text;

  void _search() async {
    DB db = DB();
    if (db.contains(_genomeName))
      widget.newTabState.variants = db.getVariants(_genomeName);
    else {
      _loading.show(context);
      try {
        widget.newTabState.variants =
            await GetVariants().getVariants(_genomeName); //'OTX2'
        await db.addGenome(_genomeName, widget.newTabState.variants);
      } catch (e) {
        _loading.hide(context);
        Scaffold.of(context).hideCurrentSnackBar();
        SnackBar snackbar = SnackBar(
            content: CText('Genome Not Found', textAlign: TextAlign.center));
        Scaffold.of(context).showSnackBar(snackbar);
        return;
      }
    }
    widget.newTabState.widget.getTabInfo.title = _genomeName;
    _loading.hide(context);
    widget.setState(() {
      widget.newTabState.stage = 1;
    });
    widget.newTabState.widget.changeState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = widget.newTabState.screenSize;

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: screenSize.width / 2.5,
        height: screenSize.height / 2.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextField(
              maxLines: 1,
              controller: _controller,
              textAlign: TextAlign.center,
              onEditingComplete: _search,
              decoration: InputDecoration(
                hintText: 'Genome Name',
              ),
            ),
            RaisedButton(
              onPressed: _search,
              color: Colors.blue,
              child: CText('Search'),
              shape: StadiumBorder(),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
