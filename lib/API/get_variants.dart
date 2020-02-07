import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scrapper/models/variant.dart';

class GetVariants {
  Future<String> _getGenomeResultsLink(String genomeName) async {
    Dio client = new Dio();
    var uri = Uri.http('www.iranome.ir', '/awesome', {"query": genomeName});
    var res = await client.getUri(uri,
        options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }));
    return res.headers["location"].first;
  }

  Future<List<Variant>> _getVariants(String link) async {
    Dio client = new Dio();
    var res = await client.get(link);
    RegExp regExp = RegExp(r'window\.table_variants = (?<variantsJSON>.*);');
    Match match = regExp.allMatches(res.toString()).first;
    var variantsJSON = match.group(0);
    variantsJSON = variantsJSON.substring(24, variantsJSON.length-1);
    List <dynamic> variantMappings = jsonDecode(variantsJSON);
    List<Variant> variants = [];
    for (dynamic variantMapping in variantMappings) {
      Map <String, dynamic> res; // TODO
      Variant variant = Variant(
        name: variantMapping['variant_id'],
        alleleCount: variantMapping['allele_count'],
        alleleFrequency: variantMapping['allele_freq'],
        cADDScore: variantMapping['dbnsfp_pred']['CADD Score (Phred Scale)'],
        polyphen: variantMapping['dbnsfp_pred']['Polyphen2 HVAR Pred (C)'],
        sift: variantMapping['dbnsfp_pred']['SIFT Pred (C)'],
        numberOfPeople: variantMapping['allele_count'],
      );
      variants.add(variant);
    }
    variants.map((e) => print(e.name)).toList();
    return variants;
  }
}

Future<int> main(List<String> args) async {
  GetVariants genome = GetVariants();
  var link = await genome._getGenomeResultsLink("OTX2");
  print(link);
  await genome._getVariants(link);
  return 0;
}
