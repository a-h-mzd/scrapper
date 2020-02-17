import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/helpers/input.dart';
import 'package:scrapper/models/variant.dart';
import 'package:scrapper/API/get_variants.dart';
import 'package:scrapper/models/minimum_db.dart';
import 'package:scrapper/components/loading.dart';

class DB {
  static StreamController<int> progressStreamController;
  static DB _instance;
  static Box _box;

  factory DB() {
    if (_instance == null) _instance = DB._internal();
    return _instance;
  }

  DB._internal();

  static Future init() async {
    Hive.init(Input().hivePath);
    _box = await Hive.openBox('db');
    if (_box.isEmpty) await _box.put('genomes', []);
  }

  List<String> get genomes {
    List<dynamic> rawList = _box.get('genomes');
    List<String> manipulatedList =
        rawList.map<String>((e) => e.toString()).toList();
    return manipulatedList;
  }

  bool contains(String genomeName) {
    if (genomeName == null) return null;
    return genomes.contains(genomeName);
  }

  List<Variant> _getAllVariants() {
    List<Variant> variants = [];
    genomes
        .map((genomeName) => variants.addAll(getVariants(genomeName)))
        .toList();
    return variants;
  }

  List<Variant> getVariants([String genomeName]) {
    if (genomeName == null) return _getAllVariants();
    if (!contains(genomeName)) return null;
    dynamic rawData = _box.get(genomeName);
    rawData = jsonDecode(rawData);
    List<Variant> variants = rawData
        .map<Variant>((e) => Variant.fromJsonString(e.toString()))
        .toList();
    return variants;
  }

  Future addGenome(String name, List<Variant> variants) async {
    if (!contains(name)) await _box.put('genomes', genomes..add(name));
    await _box.delete(name);
    List<String> encoded =
        variants.map<String>((variant) => jsonEncode(variant.toMap())).toList();
    await _box.put(name, jsonEncode(encoded));
  }

  Future removeGenome(String name) async {
    if (contains(name)) await _box.put('genomes', genomes..remove(name));
    await _box.delete(name);
  }

  void createMinimumDB(BuildContext context) async {
    progressStreamController = StreamController.broadcast();
    Loading loading = Loading();
    loading.show(context, true);

    List<String> genes = minDB.split('\n')..removeLast();
    for (String gene in genes) {
      progressStreamController.add(genes.indexOf(gene) + 1);
      if (!DB().contains(gene)) {
        try {
          List<Variant> variants = await GetVariants().getVariants(gene);
          await DB().addGenome(gene, variants);
        } catch (e) {
          print('get failed');
        }
      }
    }

    progressStreamController.close();
    loading.hide(context);
  }

  bool containsMinimum() {
    List<String> genes = minDB.split('\n')..removeLast();
    for (String gene in genes) {
      if (!genomes.contains(gene)) return false;
    }
    return true;
  }
}
