import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrapper/helpers/db.dart';
import 'package:scrapper/helpers/csv.dart';
import 'package:scrapper/pages/new_tab.dart';
import 'package:scrapper/helpers/output.dart';
import 'package:scrapper/models/variant.dart';
import 'package:scrapper/components/Text.dart';
import 'package:scrapper/API/get_variants.dart';
import 'package:scrapper/components/loading.dart';

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

    final List<Variant> tempVariants = [];

    for (int i = 0; i < _variants.length; i++) {
      if (_variants[i].alleleFrequency >= 0.03) {
        continue;
      }
      if (_variants[i].dbSNP1000GenomeMAF != null &&
          _variants[i].dbSNP1000GenomeMAF >= 0.03) {
        continue;
      }
      if (_variants[i].dbSNPESPMAF != null &&
          _variants[i].dbSNPESPMAF >= 0.03) {
        continue;
      }
      if (_variants[i].dbSNPExACMAF != null &&
          _variants[i].dbSNPExACMAF >= 0.03) {
        continue;
      }
      if (_variants[i].dbSNPGenomADMAF != null &&
          _variants[i].dbSNPGenomADMAF >= 0.03) {
        continue;
      }
      tempVariants.add(_variants[i]);
    }

    toSave = CsvHelper().variantsToCsv(tempVariants);
    if (_controller.text != '')
      Output().writeString('${_controller.text}-Allele-3Percent.csv', toSave);
    
    final List<Variant> tempVariants2 = [];

    for (int i = 0; i < _variants.length; i++) {
      if (_variants[i].damaging) {
        tempVariants2.add(_variants[i]);
      }
    }

    toSave = CsvHelper().variantsToCsv(tempVariants2);
    if (_controller.text != '')
      Output().writeString('${_controller.text}-Damaging.csv', toSave);
  }

  void _refresh() async {
    String _genomeName = widget.newTabState.widget.getTabInfo.title;
    Loading _loading = Loading();
    DB db = DB();
    _loading.show(context);
    try {
      List<Variant> variants = await GetVariants().getVariants(_genomeName);
      _variants.clear();
      _variants.addAll(variants);
      await db.addGenome(_genomeName, _variants);
      _variants.sort(_listSort);
      Scaffold.of(context).hideCurrentSnackBar();
      SnackBar snackbar = SnackBar(
          content: CText('Refresh Completed.', textAlign: TextAlign.center));
      Scaffold.of(context).showSnackBar(snackbar);
    } catch (e) {
      print(e);
      Scaffold.of(context).hideCurrentSnackBar();
      SnackBar snackbar = SnackBar(
          content: CText('Couldn\'t Refresh.', textAlign: TextAlign.center));
      Scaffold.of(context).showSnackBar(snackbar);
    }
    _loading.hide(context);
    setState(() {});
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
              Opacity(
                opacity: 0, //TODO: implement filtering!
                child: Directionality(
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
              ),
              SizedBox(width: 140),
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
              SizedBox(width: 140),
              FloatingActionButton(
                mini: true,
                tooltip: 'refresh',
                onPressed: _refresh,
                child: Icon(Icons.refresh),
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
                label: CText('rsNumber'),
              ),
              DataColumn(
                label: CText('ProteinConsequence'),
              ),
              DataColumn(
                label: CText('TransctiptConsequence'),
              ),
              DataColumn(
                label: CText('Filter'),
              ),
              DataColumn(
                label: CText('Annotation'),
              ),
              DataColumn(label: CText('ExonNumber'), onSort: _sort),
              DataColumn(
                label: CText('cADDScore'),
                onSort: _sort,
              ),
              DataColumn(
                label: CText('AlleleFrequency'),
                onSort: _sort,
              ),
              DataColumn(
                label: CText('Polyphen'),
              ),
              DataColumn(
                label: CText('Sift'),
              ),
              DataColumn(
                label: CText('Damaging'),
              ),
            ],
            rows: _variants
                .map((Variant variant) => DataRow(
                      onSelectChanged: (_) {
                        widget.newTabState.selectedVariant = variant;
                        widget.newTabState.widget.getTabInfo.title =
                            variant.name;
                        widget.newTabState.stage = 2;
                        widget.newTabState.setState(() {});
                        widget.newTabState.widget.mainPageState.setState(() {});
                      },
                      cells: [
                        DataCell(CText(variant.name)),
                        DataCell(CText(variant.rsid)),
                        DataCell(CText(variant.hgvsp)),
                        DataCell(CText(variant.hgvsc)),
                        DataCell(CText(variant.filter)),
                        DataCell(CText(variant.annotation)),
                        DataCell(CText(variant.exonNumber)),
                        DataCell(CText(variant.cADDScore)),
                        DataCell(CText(variant.alleleFrequency)),
                        DataCell(CText(variant.polyphen)),
                        DataCell(CText(variant.sift)),
                        DataCell(CText(variant.damaging ? 'YES' : 'NO')),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
