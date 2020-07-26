import 'package:csv/csv.dart';
import 'package:scrapper/models/variant.dart';

class CsvHelper {
  static CsvHelper _instance;
  CsvToListConverter _csvToListConverter = CsvToListConverter();
  ListToCsvConverter _listToCsvConverter = ListToCsvConverter();

  factory CsvHelper() {
    if (_instance == null) _instance = CsvHelper._internal();
    return _instance;
  }

  CsvHelper._internal();

  List<Variant> csvToVariants(String string) {
    List<List<dynamic>> raw = _csvToListConverter.convert(string);
    List<Variant> variants = [];
    raw.map((List<dynamic> element) => variants.add(Variant(
          name: element[0],
          alleleFrequency: element[1],
          cADDScore: element[2],
          polyphen: element[3],
          sift: element[4],
          alleleCount: element[5],
          dbSNP1000GenomeMAF: element[6],
          dbSNPExACMAF: element[7],
          dbSNPESPMAF: element[8],
          dbSNPGenomADMAF: element[9],
          numberOfPeople: element[10],
        )));
    return variants;
  }

  String variantsToCsv(List<Variant> variants) {
    List<List<dynamic>> convertMaterial = [
      [
        'name',
        'rsNumber',
        'Protein Consequence',
        'Transcript Consequence',
        'Filter',
        'Annotation',
        'Exon Number',
        'Allele Count',
        'Allele Number',
        'Homozygotes',
        'Heterozygotes',
        'Allele Frequency',
        'CADD Score',
        'Polyphen',
        'Sift',
        '1000Genome MAF',
        'ExAC MAF',
        'ESP MAF',
        'GenomAD MAF',
        'Number Of People',
        'Damaging',
      ]
    ];
    variants.map((Variant variant) {
      List<dynamic> toAdd = [];
      toAdd.add(variant.name);
      toAdd.add(variant.rsid);
      toAdd.add(variant.hgvsp);
      toAdd.add(variant.hgvsc);
      toAdd.add(variant.filter);
      toAdd.add(variant.annotation);
      toAdd.add(variant.exonNumber);
      toAdd.add(variant.alleleCount);
      toAdd.add(variant.alleleNumber);
      toAdd.add(variant.homozygotes);
      toAdd.add(variant.heterozygotes);
      toAdd.add(variant.alleleFrequency);
      toAdd.add(variant.cADDScore);
      toAdd.add(variant.polyphen);
      toAdd.add(variant.sift);
      toAdd.add(variant.dbSNP1000GenomeMAF);
      toAdd.add(variant.dbSNPExACMAF);
      toAdd.add(variant.dbSNPESPMAF);
      toAdd.add(variant.dbSNPGenomADMAF);
      toAdd.add(variant.numberOfPeople);
      toAdd.add(variant.damaging ? 'YES' : 'NO');
      convertMaterial.add(toAdd);
    }).toList();
    return _listToCsvConverter.convert(convertMaterial);
  }
}
