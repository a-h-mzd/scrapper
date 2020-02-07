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
    List <dynamic> variantsMappings = jsonDecode(variantsJSON);
    List<Variant> variants = [];
    for (dynamic variantMapping in variantsMappings) {
      Variant variant = Variant();
      variants.add(variant);
    }
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
