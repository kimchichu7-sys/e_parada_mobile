import 'package:flutter/material.dart';

import '../models/vehicle_catalog.dart';
import '../services/vehicle_service.dart';

class VehicleCatalogFields extends StatefulWidget {
  const VehicleCatalogFields({
    super.key,
    required this.vehicleType,
    required this.onChanged,
    this.enabled = true,
  });

  final String vehicleType;
  final bool enabled;
  final void Function(String make, String model, String color) onChanged;

  @override
  State<VehicleCatalogFields> createState() => _VehicleCatalogFieldsState();
}

class _VehicleCatalogFieldsState extends State<VehicleCatalogFields> {
  late Future<VehicleCatalog> _catalogFuture;
  String? _make;
  String? _model;
  String? _color;
  final _customMakeController = TextEditingController();
  final _customModelController = TextEditingController();
  final _customColorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _catalogFuture = VehicleService.fetchCatalog();
  }

  @override
  void dispose() {
    _customMakeController.dispose();
    _customModelController.dispose();
    _customColorController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VehicleCatalogFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleType != widget.vehicleType) {
      setState(() {
        _make = null;
        _model = null;
        _color = null;
        _customMakeController.clear();
        _customModelController.clear();
        _customColorController.clear();
      });
      _notify();
    }
  }

  void _notify([VehicleCatalog? catalog]) {
    final other = catalog?.otherValue ?? 'Other / Not listed';
    final effectiveMake = (_make == other && _customMakeController.text.trim().isNotEmpty)
        ? _customMakeController.text.trim()
        : (_make ?? '');
    final effectiveModel = ((_model == other || _make == other) && _customModelController.text.trim().isNotEmpty)
        ? _customModelController.text.trim()
        : (_model ?? '');
    final effectiveColor = (_color == other && _customColorController.text.trim().isNotEmpty)
        ? _customColorController.text.trim()
        : (_color ?? '');

    widget.onChanged(effectiveMake, effectiveModel, effectiveColor);
  }

  String? _required(String? value) {
    return (value?.isNotEmpty ?? false) ? null : 'Required';
  }

  T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T value) test) {
    for (final value in values) {
      if (test(value)) return value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VehicleCatalog>(
      future: _catalogFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_off_outlined),
              title: const Text('Vehicle catalog could not be loaded'),
              subtitle: Text(snapshot.error?.toString() ?? 'Try again.'),
              trailing: IconButton(
                tooltip: 'Retry',
                onPressed: () {
                  setState(() {
                    _catalogFuture = VehicleService.fetchCatalog(
                      forceRefresh: true,
                    );
                  });
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
          );
        }

        final catalog = snapshot.data!;
        final other = catalog.otherValue;
        final makes = catalog.makesFor(widget.vehicleType);
        final selectedMake = _firstWhereOrNull(
          makes,
          (item) => item.name == _make,
        );
        final defaultOtherModel = VehicleCatalogModel(
          name: other,
          colors: [other],
        );
        final models = _make == other
            ? [defaultOtherModel]
            : (selectedMake?.models ?? const <VehicleCatalogModel>[]);
        final selectedModel = _firstWhereOrNull(
          models,
          (item) => item.name == _model,
        );
        final colors = (_model == other || _make == other)
            ? [other]
            : (selectedModel?.colors ?? const <String>[]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey('make-${widget.vehicleType}-${_make ?? ''}'),
              initialValue: _make,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Make / Brand',
                prefixIcon: Icon(Icons.factory_outlined),
              ),
              items: makes
                  .map(
                    (make) => DropdownMenuItem(
                      value: make.name,
                      child: Text(make.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(growable: false),
              onChanged: widget.enabled
                  ? (value) {
                      setState(() {
                        _make = value;
                        if (_make == other) {
                          _model = other;
                          _color = other;
                        } else {
                          _model = null;
                          _color = null;
                        }
                      });
                      _notify(catalog);
                    }
                  : null,
              validator: _required,
            ),
            if (_make == other) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _customMakeController,
                enabled: widget.enabled,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Enter Brand / Make',
                  hintText: 'e.g. Vespa, Peugeot, Ducati',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _notify(catalog),
                validator: (v) => (_make == other && (v == null || v.trim().isEmpty))
                    ? 'Enter vehicle brand/make'
                    : null,
              ),
            ],
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              key: ValueKey('model-${_make ?? ''}-${_model ?? ''}'),
              initialValue: _model,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Model',
                prefixIcon: Icon(Icons.car_repair_outlined),
              ),
              items: models
                  .map(
                    (model) => DropdownMenuItem(
                      value: model.name,
                      child: Text(model.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(growable: false),
              onChanged: widget.enabled && _make != null
                  ? (value) {
                      setState(() {
                        _model = value;
                        if (_model == other) {
                          _color = other;
                        } else {
                          _color = null;
                        }
                      });
                      _notify(catalog);
                    }
                  : null,
              validator: _required,
            ),
            if (_model == other || _make == other) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _customModelController,
                enabled: widget.enabled,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Enter Vehicle Model',
                  hintText: 'e.g. Sprint 150, Panigale V2, 2008',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _notify(catalog),
                validator: (v) => ((_model == other || _make == other) &&
                        (v == null || v.trim().isEmpty))
                    ? 'Enter vehicle model'
                    : null,
              ),
            ],
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              key: ValueKey('color-${_model ?? ''}-${_color ?? ''}'),
              initialValue: _color,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Color',
                prefixIcon: Icon(Icons.palette_outlined),
              ),
              items: colors
                  .map(
                    (color) => DropdownMenuItem(
                      value: color,
                      child: Text(color, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(growable: false),
              onChanged: widget.enabled && _model != null
                  ? (value) {
                      setState(() => _color = value);
                      _notify(catalog);
                    }
                  : null,
              validator: _required,
            ),
            if (_color == other) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _customColorController,
                enabled: widget.enabled,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Enter Custom Color',
                  hintText: 'e.g. Matte Bronze, Pearl White, Teal',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _notify(catalog),
                validator: (v) => (_color == other && (v == null || v.trim().isEmpty))
                    ? 'Enter vehicle color'
                    : null,
              ),
            ],
          ],
        );
      },
    );
  }
}
