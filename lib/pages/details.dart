import 'package:flutter/material.dart';
import 'package:scrapper/models/variant.dart';
import 'package:scrapper/components/Text.dart';

class Details extends StatefulWidget {
  final Variant variant;

  const Details({Key key, this.variant}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  void initState() {
    super.initState();

    if (widget.variant == null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List<DataRow> rows = [];
    (widget.variant.toMap()..remove('name'))
        .forEach((key, value) => rows.add(DataRow(
              cells: [
                DataCell(CText(
                  key.toString(),
                  fontSize: 20,
                )),
                DataCell(CText(
                  value ?? '?',
                  fontSize: 20,
                )),
              ],
            )));

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 10),
          CText(
            widget.variant.name,
            fontSize: 56,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 120),
            child: DataTable(
              columnSpacing: 300,
              columns: <DataColumn>[
                DataColumn(
                  label: CText(
                    'key',
                    fontSize: 28,
                  ),
                ),
                DataColumn(
                  label: CText(
                    'value',
                    fontSize: 28,
                  ),
                ),
              ],
              rows: rows,
            ),
          ),
        ],
      ),
    );
  }
}
