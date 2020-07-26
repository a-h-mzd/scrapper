import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import '../models/variant.dart';
import 'package:html/parser.dart';
import 'package:scrapper/models/variant.dart';

class GetVariants {
  final Set<String> _validPredictionSiteStrings =
      {'GnomAD', 'ESP', 'ExAC', '1000G'}.map((e) => ' $e)').toSet();
  static final StreamController<double> progressStreamController =
      StreamController.broadcast();
  static GetVariants _instance;
  Dio client = new Dio();

  factory GetVariants() {
    if (_instance == null) _instance = GetVariants._internal();
    return _instance;
  }

  GetVariants._internal();

  static void dispose() => progressStreamController.close();

  Future<String> _getGenomeResultsLink(String genomeName) async {
    var uri = Uri.http('www.iranome.ir', '/awesome', {"query": genomeName});
    var res = await client.getUri(uri,
        options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }));
    return res.headers["location"].first;
  }

  Future<Map<String, double>> _getRSDataFields(String rsid) async {
    Response res;
    while (res == null)
      try {
        res = await client.get('https://www.ncbi.nlm.nih.gov/snp/' + rsid);
      } catch (e) {
        print('retrying');
      }
    var document = parse(res.data);
    List<Element> rsdatas = document.querySelectorAll('.summary-box div');
    Map<String, double> resultingData = {};
    for (Element element in rsdatas ?? []) {
      List<String> lines = element.text.split('\n');
      if (lines.length == 1) continue;
      String firstLine =
          lines[1].split('=').last; // Yeah I know :)) It's R Tiiiime! :))
      String secondLine = lines[2].split(',').last;
      if (_validPredictionSiteStrings.contains(secondLine)) {
        resultingData[secondLine.substring(1, secondLine.length - 1)] =
            double.tryParse(firstLine);
      }
    }
    return resultingData;
  }

  Future<List<Variant>> getVariants(String genomeName) async {
    int foundVariants = 0;
    String link = await _getGenomeResultsLink(genomeName);
    var res = await client.get(link);
    RegExp regExp = RegExp(r'window\.table_variants = (?<variantsJSON>.*);');
    Match match = regExp.allMatches(res.toString()).first;
    var variantsJSON = match.group(0);
    variantsJSON = variantsJSON.substring(24, variantsJSON.length - 1);
    List<dynamic> variantMappings = jsonDecode(variantsJSON);
    List<Variant> variants = [];
    for (dynamic variantMapping in variantMappings) {
      progressStreamController.add(foundVariants / variantMappings.length);
      String rsid = variantMapping['rsid'];
      Map<String, double> rsdata = await this._getRSDataFields(rsid);
      Variant variant = Variant(
        name: variantMapping['variant_id'],
        alleleCount: variantMapping['allele_count'],
        alleleFrequency: variantMapping['allele_freq'],
        cADDScore: variantMapping['dbnsfp_pred']['CADD Score (Phred Scale)'],
        polyphen: variantMapping['dbnsfp_pred']['Polyphen2 HVAR Pred (C)'],
        sift: variantMapping['dbnsfp_pred']['SIFT Pred (C)'],
        numberOfPeople: variantMapping['allele_count'],
        dbSNP1000GenomeMAF: rsdata['1000G'],
        dbSNPESPMAF: rsdata['ESP'],
        dbSNPExACMAF: rsdata['ExAC'],
        dbSNPGenomADMAF: rsdata['GnomAD'],
        hgvsp: variantMapping['HGVSp'],
        hgvsc: variantMapping['HGVSc'],
        filter: variantMapping['major_consequence'],
        exonNumber: variantMapping['exon_num']
      );
      variants.add(variant);
      foundVariants++;
    }
    progressStreamController.add(1);
    return variants;
  }
}

Future<int> main() async {
  print(await GetVariants().getVariants("OTX2"));
  return 0;
}
