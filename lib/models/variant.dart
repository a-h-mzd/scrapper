class Variant {
  final String name;
  final String sift;
  final String polyphen;
  final double cADDScore;
  final String alleleCount;
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

  bool get damaging => true; //TODO!
}
