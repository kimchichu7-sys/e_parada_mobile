class VehicleCatalogModel {
  const VehicleCatalogModel({required this.name, required this.colors});

  final String name;
  final List<String> colors;

  factory VehicleCatalogModel.fromJson(Map<String, dynamic> json) {
    return VehicleCatalogModel(
      name: json['name']?.toString() ?? '',
      colors: (json['colors'] as List? ?? const [])
          .map((color) => color.toString())
          .where((color) => color.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class VehicleCatalogMake {
  const VehicleCatalogMake({required this.name, required this.models});

  final String name;
  final List<VehicleCatalogModel> models;

  factory VehicleCatalogMake.fromJson(Map<String, dynamic> json) {
    return VehicleCatalogMake(
      name: json['make']?.toString() ?? '',
      models: (json['models'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (model) =>
                VehicleCatalogModel.fromJson(Map<String, dynamic>.from(model)),
          )
          .toList(growable: false),
    );
  }
}

class VehicleCatalog {
  const VehicleCatalog({required this.byType, required this.otherValue});

  final Map<String, List<VehicleCatalogMake>> byType;
  final String otherValue;

  List<VehicleCatalogMake> makesFor(String vehicleType) {
    return byType[vehicleType] ?? const [];
  }

  factory VehicleCatalog.fromJson(Map<String, dynamic> json) {
    final byType = <String, List<VehicleCatalogMake>>{};
    final data = json['data'];

    if (data is Map) {
      for (final entry in data.entries) {
        final rawMakes = entry.value;
        if (rawMakes is! List) continue;
        byType[entry.key.toString()] = rawMakes
            .whereType<Map>()
            .map(
              (make) =>
                  VehicleCatalogMake.fromJson(Map<String, dynamic>.from(make)),
            )
            .toList(growable: false);
      }
    }

    return VehicleCatalog(
      byType: byType,
      otherValue: json['other_value']?.toString() ?? 'Other / Not listed',
    );
  }
}
