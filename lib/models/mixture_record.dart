class ConcreteMixtureRecord {
  final String id;
  final double cement;
  final double blastFurnaceSlag;
  final double flyAsh;
  final double water;
  final double superplasticizer;
  final double coarseAggregate;
  final double fineAggregate;
  final int age;
  final double compressiveStrength;

  ConcreteMixtureRecord({
    required this.id,
    required this.cement,
    required this.blastFurnaceSlag,
    required this.flyAsh,
    required this.water,
    required this.superplasticizer,
    required this.coarseAggregate,
    required this.fineAggregate,
    required this.age,
    required this.compressiveStrength,
  });

  factory ConcreteMixtureRecord.fromMap(String id, Map<String, dynamic> data) {
    return ConcreteMixtureRecord(
      id: id,
      cement: (data['cement'] as num?)?.toDouble() ?? 0.0,
      blastFurnaceSlag: (data['blastFurnaceSlag'] as num?)?.toDouble() ?? 0.0,
      flyAsh: (data['flyAsh'] as num?)?.toDouble() ?? 0.0,
      water: (data['water'] as num?)?.toDouble() ?? 0.0,
      superplasticizer: (data['superplasticizer'] as num?)?.toDouble() ?? 0.0,
      coarseAggregate: (data['coarseAggregate'] as num?)?.toDouble() ?? 0.0,
      fineAggregate: (data['fineAggregate'] as num?)?.toDouble() ?? 0.0,
      age: (data['age'] as num?)?.toInt() ?? 0,
      compressiveStrength:
          (data['compressiveStrength'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cement': cement,
      'blastFurnaceSlag': blastFurnaceSlag,
      'flyAsh': flyAsh,
      'water': water,
      'superplasticizer': superplasticizer,
      'coarseAggregate': coarseAggregate,
      'fineAggregate': fineAggregate,
      'age': age,
      'compressiveStrength': compressiveStrength,
    };
  }

  List<MixtureComponentItem> get components => [
        MixtureComponentItem(
          name: 'Cement',
          value: _formatNumber(cement),
          unit: 'kg/m³',
          fieldName: 'cement',
          description:
              'The primary binder that reacts chemically with water (hydration) to form a paste holding aggregates together.',
        ),
        MixtureComponentItem(
          name: 'Blast Furnace Slag',
          value: _formatNumber(blastFurnaceSlag),
          unit: 'kg/m³',
          fieldName: 'blastFurnaceSlag',
          description:
              'A byproduct of iron manufacture used as a supplementary cementitious material to increase long-term durability.',
        ),
        MixtureComponentItem(
          name: 'Fly Ash',
          value: _formatNumber(flyAsh),
          unit: 'kg/m³',
          fieldName: 'flyAsh',
          description:
              'Fine pozzolanic particles from coal combustion that improve workability and decrease permeability.',
        ),
        MixtureComponentItem(
          name: 'Water',
          value: _formatNumber(water),
          unit: 'kg/m³',
          fieldName: 'water',
          description:
              'Essential for the hydration process. Lower water-to-cement ratios generally yield higher compressive strength.',
        ),
        MixtureComponentItem(
          name: 'Superplasticizer',
          value: _formatNumber(superplasticizer),
          unit: 'kg/m³',
          fieldName: 'superplasticizer',
          description:
              'High-range water reducer that enhances fluidity without compromising the strength of the hardened concrete.',
        ),
        MixtureComponentItem(
          name: 'Coarse Aggregate',
          value: _formatNumber(coarseAggregate),
          unit: 'kg/m³',
          fieldName: 'coarseAggregate',
          description:
              'Gravel or crushed stone particles providing structural bulk and thermal stability to the mix matrix.',
        ),
        MixtureComponentItem(
          name: 'Fine Aggregate',
          value: _formatNumber(fineAggregate),
          unit: 'kg/m³',
          fieldName: 'fineAggregate',
          description:
              'Sand particles filling voids between coarse aggregates to create a dense, cohesive mortar matrix.',
        ),
        MixtureComponentItem(
          name: 'Age',
          value: '$age',
          unit: 'days',
          fieldName: 'age',
          description:
              'The curing period elapsed between batch pouring and compressive strength testing (standard 28 days for full design strength).',
        ),
        MixtureComponentItem(
          name: 'Concrete Compressive Strength',
          value: _formatNumber(compressiveStrength, decimals: 3),
          unit: 'MPa',
          fieldName: 'compressiveStrength',
          description:
              'The maximum uniaxial compressive stress the cured mixture can withstand before mechanical failure.',
        ),
      ];

  static String _formatNumber(double val, {int decimals = 1}) {
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(decimals);
  }
}

class MixtureComponentItem {
  final String name;
  final String value;
  final String unit;
  final String fieldName;
  final String description;

  const MixtureComponentItem({
    required this.name,
    required this.value,
    required this.unit,
    required this.fieldName,
    required this.description,
  });
}
