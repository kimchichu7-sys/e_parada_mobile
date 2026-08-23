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

  @override
  void initState() {
    super.initState();
    _catalogFuture = VehicleService.fetchCatalog();
  }

  @override
  void didUpdateWidget(covariant VehicleCatalogFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleType != widget.vehicleType) {
      setState(() {
        _make = null;
        _model = null;
        _color = null;
      });
      _notify();
    }
  }

  void _notify() {
    widget.onChanged(_make ?? '', _model ?? '', _color ?? '');
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

        final makes = snapshot.data!.makesFor(widget.vehicleType);
        final selectedMake = _firstWhereOrNull(
          makes,
          (item) => item.name == _make,
        );
        final models = selectedMake?.models ?? const <VehicleCatalogModel>[];
        final selectedModel = _firstWhereOrNull(
          models,
          (item) => item.name == _model,
        );
        final colors = selectedModel?.colors ?? const <String>[];

        return Column(
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey('make-${widget.vehicleType}-${_make ?? ''}'),
              initialValue: _make,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Make',
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
                        _model = null;
                        _color = null;
                      });
                      _notify();
                    }
                  : null,
              validator: _required,
            ),
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
                        _color = null;
                      });
                      _notify();
                    }
                  : null,
              validator: _required,
            ),
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
                      _notify();
                    }
                  : null,
              validator: _required,
            ),
          ],
        );
      },
    );
  }
}
