import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/parking_space.dart';
import '../services/api_service.dart';
import '../utils/parking_discovery.dart';
import 'parking_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.loadParkingSpaces = ApiService.fetchParkingSpaces,
    this.initialLatitude,
    this.initialLongitude,
  });

  final Future<List<ParkingSpace>> Function() loadParkingSpaces;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _fallbackCenter = LatLng(14.2117, 121.1653);
  static final _osmCopyrightUri = Uri.parse(
    'https://www.openstreetmap.org/copyright',
  );

  final _mapController = MapController();
  final _searchController = TextEditingController();
  google_maps.GoogleMapController? _googleMapController;
  final _mapKey = GlobalKey();

  late Future<List<ParkingSpace>> _spacesFuture;
  String _query = '';
  bool _mapReady = false;
  bool _locating = false;
  LatLng? _currentLocation;
  ParkingSpace? _selectedSpace;

  String? _vehicleFilter;
  bool _openNowOnly = false;
  double? _maxHourlyRate;
  ParkingSort _sort = ParkingSort.recommended;

  @override
  void initState() {
    super.initState();
    _spacesFuture = widget.loadParkingSpaces();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _currentLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  List<ParkingSpace> _filtered(List<ParkingSpace> spaces) {
    return discoverParkingSpaces(
      spaces: spaces,
      query: _query,
      vehicleType: _vehicleFilter,
      openNowOnly: _openNowOnly,
      maxHourlyRate: _maxHourlyRate,
      sort: _sort,
      currentLatitude: _currentLocation?.latitude,
      currentLongitude: _currentLocation?.longitude,
    );
  }

  LatLng? _pointFor(ParkingSpace space) {
    final latitude = space.latitude;
    final longitude = space.longitude;
    if (latitude == null || longitude == null) return null;
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }
    return LatLng(latitude, longitude);
  }

  LatLng _initialCenter(List<ParkingSpace> spaces) {
    for (final space in spaces) {
      final point = _pointFor(space);
      if (point != null) return point;
    }
    return _fallbackCenter;
  }

  void _message(String text, {String? actionLabel, VoidCallback? onAction}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction),
        ),
      );
  }

  void _moveMap(LatLng point, double zoom) {
    if (!_mapReady) return;
    if (kIsWeb) {
      _googleMapController?.animateCamera(
        google_maps.CameraUpdate.newLatLngZoom(
          google_maps.LatLng(point.latitude, point.longitude),
          zoom,
        ),
      );
      return;
    }
    _mapController.move(point, zoom);
  }

  void _showOnMap(ParkingSpace space) {
    final point = _pointFor(space);
    if (point == null) {
      _message('${space.name} does not have map coordinates yet.');
      return;
    }

    setState(() => _selectedSpace = space);
    _moveMap(point, 16);
    final mapContext = _mapKey.currentContext;
    if (mapContext != null) {
      Scrollable.ensureVisible(
        mapContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        alignment: 0.08,
      );
    }
  }

  void _submitSearch(List<ParkingSpace> spaces) {
    final results = _filtered(spaces);
    if (results.isEmpty) {
      _message('No parking spaces match your search.');
      return;
    }
    for (final space in results) {
      if (_pointFor(space) != null) {
        _showOnMap(space);
        return;
      }
    }
    _message('The matching spaces do not have map coordinates yet.');
  }

  int get _activeFilterCount =>
      (_vehicleFilter == null ? 0 : 1) +
      (_openNowOnly ? 1 : 0) +
      (_maxHourlyRate == null ? 0 : 1) +
      (_sort == ParkingSort.recommended ? 0 : 1);

  double? _distanceFor(ParkingSpace space) {
    return parkingDistanceKm(
      space,
      currentLatitude: _currentLocation?.latitude,
      currentLongitude: _currentLocation?.longitude,
    );
  }

  Future<void> _openFilters(List<ParkingSpace> spaces) async {
    final selection = await showModalBottomSheet<_FilterSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FilterSheet(
        vehicleTypes: parkingVehicleTypes(spaces),
        vehicleType: _vehicleFilter,
        openNowOnly: _openNowOnly,
        maxHourlyRate: _maxHourlyRate,
        sort: _sort,
      ),
    );
    if (selection == null || !mounted) return;

    setState(() {
      _vehicleFilter = selection.vehicleType;
      _openNowOnly = selection.openNowOnly;
      _maxHourlyRate = selection.maxHourlyRate;
      _sort = selection.sort;
      if (_selectedSpace != null &&
          !_filtered(spaces).contains(_selectedSpace)) {
        _selectedSpace = null;
      }
    });

    if (selection.sort == ParkingSort.nearest && _currentLocation == null) {
      await _goToCurrentLocation();
    }
  }

  Future<void> _navigateTo(ParkingSpace space) async {
    final point = _pointFor(space);
    if (point == null) {
      _message('${space.name} does not have map coordinates yet.');
      return;
    }

    final directionsUri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${point.latitude},${point.longitude}',
      'travelmode': 'driving',
    });
    final opened = await launchUrl(
      directionsUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) _message('Google Maps could not be opened.');
  }

  Future<void> _goToCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _message(
          'Turn on location services to show your position.',
          actionLabel: kIsWeb ? null : 'Settings',
          onAction: kIsWeb ? null : () => Geolocator.openLocationSettings(),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _message(
          'Location permission was denied. You can still browse by name or filters.',
        );
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _message(
          'Location permission is blocked. Enable it in the app or browser settings.',
          actionLabel: kIsWeb ? null : 'Settings',
          onAction: kIsWeb ? null : () => Geolocator.openAppSettings(),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final point = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _currentLocation = point);
      _moveMap(point, 16);
    } catch (_) {
      _message('Your current location could not be retrieved.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _openDetails(ParkingSpace space) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParkingDetailsScreen(
          parkingSpaceId: space.id,
          parkingName: space.name,
          address: space.address,
          status: space.status,
          price: space.price,
          description: space.description,
          supportedVehicles: space.supportedVehicles,
          imageUrl: space.imageUrl,
          operatingHours: space.operatingHours,
          latitude: space.latitude,
          longitude: space.longitude,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Parking'),
        actions: [
          IconButton(
            tooltip: 'Use my location',
            onPressed: _locating ? null : _goToCurrentLocation,
            icon: _locating
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<ParkingSpace>>(
        future: _spacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(
              error: snapshot.error,
              onRetry: () => setState(() {
                _spacesFuture = widget.loadParkingSpaces();
              }),
            );
          }

          final allSpaces = snapshot.data ?? const <ParkingSpace>[];
          final spaces = _filtered(allSpaces);
          final mappedSpaces = spaces
              .where((space) => _pointFor(space) != null)
              .toList(growable: false);

          return Column(
            children: [
              Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => setState(() {
                    _query = value;
                    if (_selectedSpace != null &&
                        !_filtered(allSpaces).contains(_selectedSpace)) {
                      _selectedSpace = null;
                    }
                  }),
                  onSubmitted: (_) => _submitSearch(allSpaces),
                  decoration: InputDecoration(
                    hintText: 'Search location or parking space',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_query.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _selectedSpace = null;
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        IconButton(
                          tooltip: 'Filters',
                          onPressed: () => _openFilters(allSpaces),
                          icon: Badge(
                            isLabelVisible: _activeFilterCount > 0,
                            label: Text('$_activeFilterCount'),
                            child: const Icon(Icons.tune_rounded),
                          ),
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    SizedBox(
                      key: _mapKey,
                      height: 330,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            kIsWeb
                                ? _buildGoogleMap(allSpaces, mappedSpaces)
                                : FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter: _initialCenter(allSpaces),
                                      initialZoom: 14,
                                      minZoom: 3,
                                      maxZoom: 19,
                                      onMapReady: () => _mapReady = true,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.eparada.mobile',
                                        maxNativeZoom: 19,
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          for (final space in mappedSpaces)
                                            _parkingMarker(space),
                                          if (_currentLocation != null)
                                            Marker(
                                              point: _currentLocation!,
                                              width: 34,
                                              height: 34,
                                              child: const _LocationDot(),
                                            ),
                                        ],
                                      ),
                                      RichAttributionWidget(
                                        attributions: [
                                          TextSourceAttribution(
                                            'OpenStreetMap contributors',
                                            onTap: () =>
                                                launchUrl(_osmCopyrightUri),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                            if (mappedSpaces.isEmpty)
                              const Positioned(
                                top: 12,
                                left: 12,
                                right: 12,
                                child: _MapNotice(),
                              ),
                            if (_selectedSpace != null)
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 28,
                                child: _SelectedSpaceCard(
                                  space: _selectedSpace!,
                                  distance: _distanceFor(_selectedSpace!),
                                  onClose: () =>
                                      setState(() => _selectedSpace = null),
                                  onNavigate: () =>
                                      _navigateTo(_selectedSpace!),
                                  onDetails: () =>
                                      _openDetails(_selectedSpace!),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _sort == ParkingSort.nearest
                                ? 'Nearest Parking'
                                : 'Available Nearby',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Text(
                          '${spaces.length} found',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    if (_sort == ParkingSort.nearest &&
                        _currentLocation == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _goToCurrentLocation,
                            icon: const Icon(Icons.my_location_rounded),
                            label: const Text(
                              'Enable location to calculate distance',
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (spaces.isEmpty)
                      const _EmptyResult()
                    else
                      ...spaces.map(_parkingCard),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGoogleMap(
    List<ParkingSpace> allSpaces,
    List<ParkingSpace> mappedSpaces,
  ) {
    final center = _initialCenter(allSpaces);
    return google_maps.GoogleMap(
      initialCameraPosition: google_maps.CameraPosition(
        target: google_maps.LatLng(center.latitude, center.longitude),
        zoom: 14,
      ),
      minMaxZoomPreference: const google_maps.MinMaxZoomPreference(3, 19),
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      markers: _googleMarkers(mappedSpaces),
      onMapCreated: (controller) {
        _googleMapController = controller;
        _mapReady = true;
      },
    );
  }

  Set<google_maps.Marker> _googleMarkers(List<ParkingSpace> spaces) {
    return {
      for (final space in spaces)
        google_maps.Marker(
          markerId: google_maps.MarkerId('parking-${space.id}'),
          position: google_maps.LatLng(space.latitude!, space.longitude!),
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
            _selectedSpace?.id == space.id
                ? google_maps.BitmapDescriptor.hueAzure
                : space.isAvailable
                ? google_maps.BitmapDescriptor.hueViolet
                : google_maps.BitmapDescriptor.hueRed,
          ),
          onTap: () {
            setState(() => _selectedSpace = space);
            _moveMap(_pointFor(space)!, 16);
          },
        ),
      if (_currentLocation != null)
        google_maps.Marker(
          markerId: const google_maps.MarkerId('current-location'),
          position: google_maps.LatLng(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          ),
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueAzure,
          ),
          zIndexInt: 2,
          infoWindow: const google_maps.InfoWindow(title: 'Your location'),
        ),
    };
  }

  Marker _parkingMarker(ParkingSpace space) {
    final point = _pointFor(space)!;
    final selected = _selectedSpace?.id == space.id;
    return Marker(
      point: point,
      width: 52,
      height: 52,
      child: Semantics(
        label: '${space.name}, ${space.status}',
        button: true,
        child: GestureDetector(
          onTap: () {
            setState(() => _selectedSpace = space);
            _moveMap(point, 16);
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: selected ? 1.18 : 1,
            child: Icon(
              Icons.location_pin,
              size: 48,
              color: space.isAvailable
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFFDC2626),
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _parkingCard(ParkingSpace space) {
    final distance = _distanceFor(space);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 88,
            height: 88,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: space.imageUrl != null && space.imageUrl!.isNotEmpty
                ? Image.network(
                    space.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: Color(0xFF64748B),
                    ),
                  )
                : const Icon(
                    Icons.local_parking_rounded,
                    color: Color(0xFF64748B),
                    size: 34,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        space.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusBadge(space: space),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  space.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  space.price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                if (distance != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.near_me_outlined,
                        size: 15,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatParkingDistance(distance),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton.outlined(
                      tooltip: 'Show on map',
                      onPressed: () => _showOnMap(space),
                      icon: const Icon(Icons.map_outlined),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: 'Navigate',
                      onPressed: () => _navigateTo(space),
                      icon: const Icon(Icons.directions_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _openDetails(space),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationDot extends StatelessWidget {
  const _LocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
  }
}

class _FilterSelection {
  const _FilterSelection({
    required this.vehicleType,
    required this.openNowOnly,
    required this.maxHourlyRate,
    required this.sort,
  });

  final String? vehicleType;
  final bool openNowOnly;
  final double? maxHourlyRate;
  final ParkingSort sort;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.vehicleTypes,
    required this.vehicleType,
    required this.openNowOnly,
    required this.maxHourlyRate,
    required this.sort,
  });

  final List<String> vehicleTypes;
  final String? vehicleType;
  final bool openNowOnly;
  final double? maxHourlyRate;
  final ParkingSort sort;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _vehicleType;
  late bool _openNowOnly;
  late double? _maxHourlyRate;
  late ParkingSort _sort;

  @override
  void initState() {
    super.initState();
    _vehicleType = widget.vehicleType;
    _openNowOnly = widget.openNowOnly;
    _maxHourlyRate = widget.maxHourlyRate;
    _sort = widget.sort;
  }

  String _sortLabel(ParkingSort sort) => switch (sort) {
    ParkingSort.recommended => 'Recommended',
    ParkingSort.nearest => 'Nearest',
    ParkingSort.lowestPrice => 'Lowest price',
  };

  @override
  Widget build(BuildContext context) {
    const rateOptions = <double?>[null, 50, 100, 200];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Find the right parking',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            const Text(
              'Vehicle type',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Any vehicle'),
                  selected: _vehicleType == null,
                  onSelected: (_) => setState(() => _vehicleType = null),
                ),
                for (final vehicleType in widget.vehicleTypes)
                  ChoiceChip(
                    label: Text(vehicleType),
                    selected: _vehicleType == vehicleType,
                    onSelected: (_) =>
                        setState(() => _vehicleType = vehicleType),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Open now only',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Hide parking spaces outside operating hours',
              ),
              value: _openNowOnly,
              onChanged: (value) => setState(() => _openNowOnly = value),
            ),
            const SizedBox(height: 8),
            const Text(
              'Maximum hourly rate',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final rate in rateOptions)
                  ChoiceChip(
                    label: Text(
                      rate == null
                          ? 'Any price'
                          : 'Up to PHP ${rate.toStringAsFixed(0)}',
                    ),
                    selected: _maxHourlyRate == rate,
                    onSelected: (_) => setState(() => _maxHourlyRate = rate),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Sort results',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sort in ParkingSort.values)
                  ChoiceChip(
                    label: Text(_sortLabel(sort)),
                    selected: _sort == sort,
                    onSelected: (_) => setState(() => _sort = sort),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _vehicleType = null;
                    _openNowOnly = false;
                    _maxHourlyRate = null;
                    _sort = ParkingSort.recommended;
                  }),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      _FilterSelection(
                        vehicleType: _vehicleType,
                        openNowOnly: _openNowOnly,
                        maxHourlyRate: _maxHourlyRate,
                        sort: _sort,
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Apply filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedSpaceCard extends StatelessWidget {
  const _SelectedSpaceCard({
    required this.space,
    required this.distance,
    required this.onClose,
    required this.onNavigate,
    required this.onDetails,
  });

  final ParkingSpace space;
  final double? distance;
  final VoidCallback onClose;
  final VoidCallback onNavigate;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(
          children: [
            const Icon(Icons.local_parking_rounded, color: Color(0xFF4F46E5)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    distance == null
                        ? space.price
                        : '${space.price} • ${formatParkingDistance(distance)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Navigate',
              onPressed: onNavigate,
              icon: const Icon(Icons.directions_rounded),
            ),
            TextButton(onPressed: onDetails, child: const Text('Reserve')),
            IconButton(
              tooltip: 'Close',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.space});

  final ParkingSpace space;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: space.isAvailable
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        space.status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: space.isAvailable
              ? const Color(0xFF166534)
              : const Color(0xFF991B1B),
        ),
      ),
    );
  }
}

class _MapNotice extends StatelessWidget {
  const _MapNotice();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('No mapped parking spaces match this search.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 42, color: Color(0xFF64748B)),
          SizedBox(height: 10),
          Text(
            'No parking spaces found',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Try searching for another parking name or address.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Failed to load parking map data.\n$error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
