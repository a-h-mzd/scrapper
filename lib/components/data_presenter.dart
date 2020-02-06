import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrapper/models/variant.dart';
import 'package:scrapper/components/Text.dart';

class DataPresenter extends StatefulWidget {
  final List<Variant> _variants = [];

  DataPresenter(final List<Variant> variants) {
    _variants.addAll(variants);
  }

  @override
  _DataPresenterState createState() => _DataPresenterState();
}

class _DataPresenterState extends State<DataPresenter> {
  final List<Variant> _variants = [];
  int _currentSortIndex = 0;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();

    _variants.addAll(widget._variants);
  }

  void _sort(int index, bool ascending) {
    if (_currentSortIndex == index)
      _ascending = !_ascending;
    else {
      _ascending = true;
      _currentSortIndex = index;
    }

    _variants.sort(_listSort);

    setState(() {});
  }

  int _listSort(Variant variant1, Variant variant2) {
    int returnValue;
    switch (_currentSortIndex) {
      case 0:
        returnValue = variant1.name.compareTo(variant2.name);
        break;
      case 1:
        returnValue = variant1.aADDScore.compareTo(variant2.aADDScore);
        break;
      case 2:
        returnValue =
            variant1.alleleFrequency.compareTo(variant2.alleleFrequency);
        break;
      default:
        _ascending = true;
        _currentSortIndex = 0;
        return _listSort(variant1, variant2);
    }
    return returnValue * (_ascending ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      sortColumnIndex: _currentSortIndex,
      showCheckboxColumn: false,
      sortAscending: _ascending,
      columns: <DataColumn>[
        DataColumn(
          label: CText('name'),
          onSort: _sort,
        ),
        DataColumn(
          label: CText('aADDScore'),
          onSort: _sort,
        ),
        DataColumn(
          label: CText('alleleFrequency'),
          onSort: _sort,
        ),
      ],
      rows: _variants
          .map((Variant variant) => DataRow(
                onSelectChanged: (_) async {
                  final String oldData =
                      (await Clipboard.getData('text/plain')).text;
                  final String textToCopy = variant.name;
                  await Clipboard.setData(ClipboardData(text: textToCopy));
                  ScaffoldFeatureController controller;
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
                              await Clipboard.setData(
                                  ClipboardData(text: oldData));
                              controller.close();
                            },
                          ),
                        ),
                      ],
                    ),
                    shape: Border(
                      top: BorderSide(width: 2, color: Colors.blue),
                    ),
                  );
                  controller = Scaffold.of(context).showSnackBar(snackBar);
                },
                cells: [
                  DataCell(CText(variant.name)),
                  DataCell(CText(variant.aADDScore)),
                  DataCell(CText(variant.alleleFrequency)),
                ],
              ))
          .toList(),
    );
  }
}
