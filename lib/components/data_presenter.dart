import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrapper/helpers/csv.dart';
import 'package:scrapper/pages/new_tab.dart';
import 'package:scrapper/helpers/output.dart';
import 'package:scrapper/models/variant.dart';
import 'package:scrapper/components/Text.dart';
import 'package:scrapper/helpers/clipboard.dart';

class DataPresenter extends StatefulWidget {
  final List<Variant> _variants = [];
  final NewTabState newTabState;

  DataPresenter(final List<Variant> variants, this.newTabState) {
    _variants.addAll(variants);
  }

  @override
  _DataPresenterState createState() => _DataPresenterState();
}

class _DataPresenterState extends State<DataPresenter> {
  TextEditingController _controller = TextEditingController();
  final List<Variant> _variants = [];
  int _currentSortIndex = 0;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();

    _variants.addAll(widget._variants);
    _variants.sort(_listSort);
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
        returnValue = variant1.cADDScore.compareTo(variant2.cADDScore);
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

  void _export() {
    String toSave = CsvHelper().variantsToCsv(_variants);
    if (_controller.text != '')
      Output().writeString('${_controller.text}.csv', toSave);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (false)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: RaisedButton.icon(
                    color: Colors.blue,
                    onPressed: () => null,
                    shape: StadiumBorder(),
                    textColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down),
                    label: CText('Filters'),
                  ),
                ),
              SizedBox(width: 80),
              SizedBox(
                width: widget.newTabState.screenSize.width / 10,
                child: TextField(
                  maxLines: 1,
                  controller: _controller,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp("[a-zA-Z._]")),
                  ],
                  decoration: InputDecoration(
                    hintText: 'File Name',
                  ),
                ),
              ),
              RaisedButton.icon(
                onPressed: _export,
                color: Colors.blue,
                shape: StadiumBorder(),
                textColor: Colors.white,
                icon: Icon(Icons.save_alt),
                label: CText('Export CSV'),
              ),
            ],
          ),
          SizedBox(height: 20),
          DataTable(
            sortColumnIndex: _currentSortIndex,
            showCheckboxColumn: false,
            sortAscending: _ascending,
            columns: <DataColumn>[
              DataColumn(
                label: CText('name'),
                onSort: _sort,
              ),
              DataColumn(
                label: CText('cADDScore'),
                onSort: _sort,
              ),
              DataColumn(
                label: CText('alleleFrequency'),
                onSort: _sort,
              ),
              DataColumn(
                label: CText('polyphen'),
              ),
              DataColumn(
                label: CText('dbSNP1000GenomeMAF'),
              ),
            ],
            rows: _variants
                .map((Variant variant) => DataRow(
                      onSelectChanged: (_) async {
                        ClipBoardHelper clipBoardHelper = ClipBoardHelper();
                        await clipBoardHelper.copyToClipBoard(
                            context, variant.name);
                      },
                      cells: [
                        DataCell(CText(variant.name)),
                        DataCell(CText(variant.cADDScore)),
                        DataCell(CText(variant.alleleFrequency)),
                        DataCell(CText(variant.polyphen)),
                        DataCell(CText(variant.dbSNP1000GenomeMAF ?? '?')),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
