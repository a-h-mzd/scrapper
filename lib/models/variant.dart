import 'dart:convert';

class Variant {
  final String name;
  final String sift;
  final String polyphen;
  final String cADDScore;
  final int alleleCount;
  final double dbSNPESPMAF;
  final double dbSNPExACMAF;
  final double alleleFrequency;
  final double dbSNPGenomADMAF;
  final double dbSNP1000GenomeMAF;
  final int numberOfPeople;

  const Variant({
    this.name,
    this.alleleCount,
    this.alleleFrequency,
    this.cADDScore,
    this.polyphen,
    this.sift,
    this.dbSNP1000GenomeMAF,
    this.dbSNPExACMAF,
    this.dbSNPESPMAF,
    this.dbSNPGenomADMAF,
    this.numberOfPeople,
  });

  bool get damaging {
    final bool pol = polyphen != null &&
        (polyphen.toLowerCase().contains('damaging') ||
            polyphen.toLowerCase() == 'unknown');
    final bool sif = sift != null && sift.toLowerCase() == 'deleterious';
    final tempCadd = double.tryParse(cADDScore ?? '0');
    final bool cad = tempCadd != null && tempCadd >= 15;
    return pol || sif || cad;
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'sift': sift,
        'polyphen': polyphen,
        'cADDScore': cADDScore,
        'alleleCount': alleleCount,
        'dbSNPESPMAF': dbSNPESPMAF,
        'dbSNPExACMAF': dbSNPExACMAF,
        'alleleFrequency': alleleFrequency,
        'dbSNPGenomADMAF': dbSNPGenomADMAF,
        'dbSNP1000GenomeMAF': dbSNP1000GenomeMAF,
        'numberOfPeople': numberOfPeople,
        'damaging': damaging,
      };

  factory Variant.fromJsonString(String jsonString) {
    Map<String, dynamic> rawData = jsonDecode(jsonString);
    return Variant(
      name: rawData['name'],
      alleleCount: rawData['alleleCount'],
      alleleFrequency: rawData['alleleFrequency'],
      cADDScore: rawData['cADDScore'],
      polyphen: rawData['polyphen'],
      sift: rawData['sift'],
      dbSNP1000GenomeMAF: rawData['dbSNP1000GenomeMAF'],
      dbSNPExACMAF: rawData['dbSNPExACMAF'],
      dbSNPESPMAF: rawData['dbSNPESPMAF'],
      dbSNPGenomADMAF: rawData['dbSNPGenomADMAF'],
      numberOfPeople: rawData['numberOfPeople'],
    );
  }
}
