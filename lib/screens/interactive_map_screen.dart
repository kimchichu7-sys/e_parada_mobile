import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' hide Path;

import '../models/parking_space.dart';
import '../services/api_service.dart';
import '../services/route_navigation_service.dart';
import '../utils/parking_discovery.dart';
import '../widgets/app_network_image.dart';
import '../widgets/favorite_space_button.dart';
import '../widgets/image_preview_dialog.dart';
import 'parking_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.loadParkingSpaces = ApiService.fetchParkingSpaces,
    this.initialLatitude,
    this.initialLongitude,
    this.focusedParkingSpaceId,
    this.initialSelectedSpace,
    this.startNavigationMode = false,
  });

  final Future<List<ParkingSpace>> Function() loadParkingSpaces;
  final double? initialLatitude;
  final double? initialLongitude;
  final int? focusedParkingSpaceId;
  final ParkingSpace? initialSelectedSpace;
  final bool startNavigationMode;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _fallbackCenter = LatLng(14.2117, 121.1653);

  gmaps.GoogleMapController? _googleMapController;
  final _searchController = TextEditingController();
  final _mapKey = GlobalKey();

  late Future<List<ParkingSpace>> _spacesFuture;
  String _query = '';
  bool _mapReady = false;
  bool _locating = false;
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  double _currentHeading = 0.0;
  double _currentSpeedKmh = 0.0;
  double _currentAccuracyMeters = 0.0;
  bool _isLiveTrackingActive = false;
  bool _isSimulatingRoute = false;

  ParkingSpace? _selectedSpace;
  NavigationRouteData? _routeData;
  NavigationTransportMode _transportMode = NavigationTransportMode.car;
  bool _isNavigating = false;
  LiveNavigationProgress? _navProgress;
  StreamSubscription<LiveNavigationProgress>? _navSubscription;
  bool _cameraFollowsVehicle = true;

  String? _vehicleFilter;
  bool _openNowOnly = false;
  double? _maxHourlyRate;
  ParkingSort _sort = ParkingSort.recommended;
  bool _isMapFullscreen = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedSpace != null) {
      _selectedSpace = widget.initialSelectedSpace;
    }
    _spacesFuture = widget.loadParkingSpaces().then((spaces) {
      if (widget.focusedParkingSpaceId != null && _selectedSpace == null) {
        try {
          final found = spaces.firstWhere(
            (s) => s.id == widget.focusedParkingSpaceId,
          );
          _selectSpace(found, autoFit: true);
        } catch (_) {}
      } else if (_selectedSpace != null) {
        _selectSpace(_selectedSpace!, autoFit: true);
      }
      if ((widget.startNavigationMode || widget.focusedParkingSpaceId != null) &&
          _currentLocation == null) {
        _goToCurrentLocation(refitFor: _selectedSpace);
      }
      return spaces;
    });
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _currentLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
    }
    // Automatically start continuous, high-accuracy real-time driver GPS tracking
    _initRealtimeLocationTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _navSubscription?.cancel();
    _searchController.dispose();
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

  LatLng _effectiveOrigin(ParkingSpace destination) {
    if (_currentLocation != null) return _currentLocation!;
    final destPoint = _pointFor(destination);
    if (destPoint != null) {
      return LatLng(
        destPoint.latitude - 0.009,
        destPoint.longitude - 0.008,
      );
    }
    return _fallbackCenter;
  }

  void _setTransportMode(NavigationTransportMode mode) {
    if (_transportMode == mode) return;
    setState(() {
      _transportMode = mode;
    });
    if (_selectedSpace != null) {
      _fetchAndApplyRoute(_selectedSpace!, autoFit: false);
    }
  }

  Future<void> _fetchAndApplyRoute(ParkingSpace space, {bool autoFit = true}) async {
    final destPoint = _pointFor(space);
    if (destPoint == null) return;
    final startPoint = _effectiveOrigin(space);

    final instantFallback = RouteNavigationService.generateFallbackRoute(
      origin: startPoint,
      destination: destPoint,
      destinationSpace: space,
      mode: _transportMode,
    );

    if (mounted && _selectedSpace?.id == space.id) {
      setState(() {
        _routeData = instantFallback;
      });
    }

    if (autoFit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitRoute(startPoint, destPoint);
      });
    }

    try {
      final liveData = await RouteNavigationService.fetchRoute(
        origin: startPoint,
        destination: destPoint,
        destinationSpace: space,
        mode: _transportMode,
      );
      if (mounted && _selectedSpace?.id == space.id) {
        setState(() {
          _routeData = liveData;
        });
      }
    } catch (_) {}
  }

  void _selectSpace(ParkingSpace space, {bool autoFit = true}) {
    final point = _pointFor(space);
    if (point == null) {
      _message('${space.name} does not have map coordinates yet.');
      return;
    }

    setState(() {
      _selectedSpace = space;
    });

    _fetchAndApplyRoute(space, autoFit: autoFit);

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

  void _clearSelection() {
    _stopDriving();
    setState(() {
      _selectedSpace = null;
      _routeData = null;
    });
  }

  void _startDriving({bool simulate = false}) {
    if (_selectedSpace == null || _routeData == null) return;
    _navSubscription?.cancel();
    _isSimulatingRoute = simulate;

    final initialPos = _currentLocation ?? _routeData!.primaryCoordinates.first;
    final initialProgress = RouteNavigationService.computeProgress(
      routeData: _routeData!,
      progressFraction: 0.0,
    );
    setState(() {
      _isNavigating = true;
      _cameraFollowsVehicle = true;
      _navProgress = initialProgress;
    });

    _initRealtimeLocationTracking(moveCameraOnFix: true);
    _moveMap(initialPos, 18.0);

    if (simulate) {
      _navSubscription = RouteNavigationService.simulateNavigationStream(
        routeData: _routeData!,
        totalDurationSeconds: 15.0,
      ).listen((progress) {
        if (!mounted) return;
        setState(() {
          _navProgress = progress;
        });
        if (_cameraFollowsVehicle) {
          _moveMap(progress.currentPosition, 18.0);
        }
        if (progress.isArrived) {
          _showArrivalDialog(_selectedSpace!);
        }
      });
    }
  }

  void _stopDriving() {
    _navSubscription?.cancel();
    _navSubscription = null;
    _isSimulatingRoute = false;
    setState(() {
      _isNavigating = false;
      _navProgress = null;
    });
    if (_selectedSpace != null) {
      final start = _effectiveOrigin(_selectedSpace!);
      final dest = _pointFor(_selectedSpace!);
      if (dest != null) _fitRoute(start, dest);
    }
  }

  void _showArrivalDialog(ParkingSpace space) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ArrivalCelebrationDialog(
        space: space,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _moveMap(LatLng point, double zoom) {
    if (!_mapReady || _googleMapController == null) return;
    _googleMapController!.animateCamera(
      gmaps.CameraUpdate.newLatLngZoom(
        gmaps.LatLng(point.latitude, point.longitude),
        zoom,
      ),
    );
  }

  void _fitRoute(LatLng origin, LatLng destination) {
    if (!_mapReady || _googleMapController == null) return;
    final south = math.min(origin.latitude, destination.latitude);
    final north = math.max(origin.latitude, destination.latitude);
    final west = math.min(origin.longitude, destination.longitude);
    final east = math.max(origin.longitude, destination.longitude);

    final bounds = gmaps.LatLngBounds(
      southwest: gmaps.LatLng(south, west),
      northeast: gmaps.LatLng(north, east),
    );

    try {
      _googleMapController!.animateCamera(
        gmaps.CameraUpdate.newLatLngBounds(bounds, 48),
      );
    } catch (_) {
      final midLat = (origin.latitude + destination.latitude) / 2;
      final midLng = (origin.longitude + destination.longitude) / 2;
      _googleMapController!.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          gmaps.LatLng(midLat, midLng),
          14.5,
        ),
      );
    }
  }

  void _showOnMap(ParkingSpace space) {
    _selectSpace(space, autoFit: true);
  }

  void _submitSearch(List<ParkingSpace> spaces) {
    final results = _filtered(spaces);
    if (results.isEmpty) {
      _message('No parking spaces match your search.');
      return;
    }
    for (final space in results) {
      if (_pointFor(space) != null) {
        _selectSpace(space, autoFit: true);
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
    final origin = _currentLocation ?? _effectiveOrigin(space);
    return parkingDistanceKm(
      space,
      currentLatitude: origin.latitude,
      currentLongitude: origin.longitude,
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

  Widget _buildQuickFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF173B64) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF173B64) : const Color(0xFFCBD5E1),
              width: 1.1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF173B64).withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? const Color(0xFFFFDE70) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _estimateEta(double? distanceKm) {
    if (distanceKm == null) return 'ETA unavailable';
    if (distanceKm < 0.1) return '< 1 min drive';
    final minutes = (distanceKm / 25.0 * 60.0).ceil();
    if (minutes < 60) {
      return '~$minutes min${minutes > 1 ? 's' : ''} drive';
    }
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    return '~$hours hr${hours > 1 ? 's' : ''} ${rem > 0 ? '$rem min' : ''} drive';
  }

  Future<void> _navigateTo(ParkingSpace space) async {
    _selectSpace(space, autoFit: true);

    if (_currentLocation == null) {
      _goToCurrentLocation(refitFor: space);
    }

    final dist = _routeData?.distanceKm ?? _distanceFor(space);
    final eta = _routeData?.etaText ?? _estimateEta(dist);
    _message(
      '🚗 In-App Route: ${space.name}${dist != null ? ' • ${formatParkingDistance(dist)}' : ''} ($eta)',
    );
  }

  Future<void> _initRealtimeLocationTracking({bool moveCameraOnFix = false}) async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // Try quick cached fix first to show the pin immediately
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null && mounted) {
          _handlePositionUpdate(lastPos);
        }
      } catch (_) {}

      // Get precise initial fix
      try {
        final initialPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            timeLimit: Duration(seconds: 8),
          ),
        );
        if (mounted) {
          _handlePositionUpdate(initialPos);
          if (moveCameraOnFix) {
            _moveMap(LatLng(initialPos.latitude, initialPos.longitude), 17.5);
          }
        }
      } catch (_) {}

      // Start continuous high-accuracy position stream (fires every 2 meters of movement)
      _positionStreamSubscription?.cancel();
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _handlePositionUpdate,
        onError: (e) {
          debugPrint('Geolocator position stream error: $e');
        },
      );
    } catch (e) {
      debugPrint('Location tracking init error: $e');
    }
  }

  void _handlePositionUpdate(Position position) {
    if (!mounted) return;
    final newPoint = LatLng(position.latitude, position.longitude);

    double heading = _currentHeading;
    if (position.heading > 0.0 && !position.heading.isNaN) {
      heading = position.heading;
    } else if (_currentLocation != null) {
      final movedMeters = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );
      if (movedMeters >= 1.5) {
        heading = RouteNavigationService.computeBearing(_currentLocation!, newPoint);
      }
    }

    final speedKmh = position.speed >= 0 ? (position.speed * 3.6) : 0.0;

    setState(() {
      _currentLocation = newPoint;
      _currentHeading = heading;
      _currentSpeedKmh = speedKmh;
      _currentAccuracyMeters = position.accuracy;
      _isLiveTrackingActive = true;
    });

    // If navigating in real GPS mode (not simulation mode), update turn instructions & progress
    if (_isNavigating && !_isSimulatingRoute && _selectedSpace != null && _routeData != null) {
      _updateRealtimeNavigationProgress(newPoint, heading, speedKmh);
    }

    // If camera follows vehicle and navigating, animate camera along driver's movement
    if (_isNavigating && _cameraFollowsVehicle && _mapReady && _googleMapController != null) {
      _googleMapController!.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: gmaps.LatLng(newPoint.latitude, newPoint.longitude),
            bearing: heading,
            tilt: 45.0,
            zoom: 18.0,
          ),
        ),
      );
    }
  }

  void _updateRealtimeNavigationProgress(
    LatLng currentPos,
    double heading,
    double speedKmh,
  ) {
    if (_routeData == null || _selectedSpace == null) return;

    final destPt = _pointFor(_selectedSpace!);
    if (destPt == null) return;

    final distanceToDestMeters = Geolocator.distanceBetween(
      currentPos.latitude,
      currentPos.longitude,
      destPt.latitude,
      destPt.longitude,
    );
    final distanceToDestKm = distanceToDestMeters / 1000.0;

    // Check arrival if within 25 meters of destination
    final isArrived = distanceToDestMeters <= 25.0;

    final totalKm = _routeData!.distanceKm > 0 ? _routeData!.distanceKm : 1.0;
    final progressFraction = (1.0 - (distanceToDestKm / totalKm)).clamp(0.0, 1.0);

    final steps = _routeData!.steps;
    final stepIndex = steps.isNotEmpty
        ? (progressFraction * steps.length).floor().clamp(0, steps.length - 1)
        : 0;
    final currentStep = steps.isNotEmpty
        ? steps[stepIndex]
        : const RouteStepItem(instruction: 'Follow route to destination');
    final nextStep = (stepIndex + 1 < steps.length) ? steps[stepIndex + 1] : null;

    final effectiveSpeed = speedKmh > 5.0
        ? speedKmh
        : (_transportMode == NavigationTransportMode.motorcycle ? 30.0 : 24.0);
    final remainingMinutes = math.max(1, (distanceToDestKm / effectiveSpeed * 60.0).round());
    final remainingEtaText = isArrived
        ? 'Arrived'
        : (remainingMinutes < 60
            ? '$remainingMinutes min'
            : '${remainingMinutes ~/ 60}h ${remainingMinutes % 60}m');

    final updatedProgress = LiveNavigationProgress(
      currentPosition: currentPos,
      bearing: heading,
      currentStepIndex: stepIndex,
      currentStep: currentStep,
      nextStep: nextStep,
      remainingDistanceKm: distanceToDestKm,
      remainingDurationMinutes: remainingMinutes,
      remainingEtaText: remainingEtaText,
      currentSpeedKmh: speedKmh,
      isArrived: isArrived,
      progressFraction: progressFraction,
    );

    setState(() {
      _navProgress = updatedProgress;
    });

    if (isArrived) {
      _showArrivalDialog(_selectedSpace!);
    }
  }

  Future<void> _goToCurrentLocation({ParkingSpace? refitFor}) async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _message(
          'Turn on location services to show your live position.',
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
          'Location permission was denied. You can still browse or use estimated routes.',
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

      // Ensure continuous position stream is active
      if (_positionStreamSubscription == null) {
        await _initRealtimeLocationTracking();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _handlePositionUpdate(position);
      final point = LatLng(position.latitude, position.longitude);

      final targetSpace = refitFor ?? _selectedSpace;
      if (targetSpace != null && _pointFor(targetSpace) != null) {
        _fetchAndApplyRoute(targetSpace, autoFit: true);
      } else {
        _moveMap(point, 16.5);
      }
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
            tooltip: _isLiveTrackingActive ? 'Live GPS Active' : 'Use my location',
            onPressed: _locating ? null : _goToCurrentLocation,
            icon: _locating
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isLiveTrackingActive
                        ? Icons.gps_fixed_rounded
                        : Icons.my_location_rounded,
                    color: _isLiveTrackingActive ? const Color(0xFF16A34A) : null,
                  ),
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
              if (_selectedSpace != null && !_isNavigating)
                _RoutePlanningHeader(
                  space: _selectedSpace!,
                  routeData: _routeData,
                  transportMode: _transportMode,
                  isLiveGps: _currentLocation != null,
                  onModeChanged: _setTransportMode,
                  onStartDriving: () => _startDriving(simulate: false),
                  onClose: _clearSelection,
                  onRecenter: () {
                    if (_pointFor(_selectedSpace!) != null) {
                      final start = _effectiveOrigin(_selectedSpace!);
                      _fitRoute(start, _pointFor(_selectedSpace!)!);
                    }
                  },
                  onSyncGps: () => _goToCurrentLocation(
                    refitFor: _selectedSpace,
                  ),
                )
              else if (!_isNavigating)
                Container(
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
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
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildQuickFilterChip(
                              label: 'Open Now',
                              icon: Icons.access_time_filled_rounded,
                              isSelected: _openNowOnly,
                              onTap: () {
                                setState(() {
                                  _openNowOnly = !_openNowOnly;
                                  if (_selectedSpace != null &&
                                      !_filtered(allSpaces).contains(_selectedSpace)) {
                                    _selectedSpace = null;
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildQuickFilterChip(
                              label: 'Cars',
                              icon: Icons.directions_car_rounded,
                              isSelected: _vehicleFilter == 'car',
                              onTap: () {
                                setState(() {
                                  _vehicleFilter = _vehicleFilter == 'car' ? null : 'car';
                                  if (_selectedSpace != null &&
                                      !_filtered(allSpaces).contains(_selectedSpace)) {
                                    _selectedSpace = null;
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildQuickFilterChip(
                              label: 'Motorcycles',
                              icon: Icons.two_wheeler_rounded,
                              isSelected: _vehicleFilter == 'motorcycle',
                              onTap: () {
                                setState(() {
                                  _vehicleFilter = _vehicleFilter == 'motorcycle' ? null : 'motorcycle';
                                  if (_selectedSpace != null &&
                                      !_filtered(allSpaces).contains(_selectedSpace)) {
                                    _selectedSpace = null;
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildQuickFilterChip(
                              label: '≤ ₱50/hr',
                              icon: Icons.sell_rounded,
                              isSelected: _maxHourlyRate == 50.0,
                              onTap: () {
                                setState(() {
                                  _maxHourlyRate = _maxHourlyRate == 50.0 ? null : 50.0;
                                  if (_selectedSpace != null &&
                                      !_filtered(allSpaces).contains(_selectedSpace)) {
                                    _selectedSpace = null;
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildQuickFilterChip(
                              label: 'Nearest',
                              icon: Icons.near_me_rounded,
                              isSelected: _sort == ParkingSort.nearest,
                              onTap: () async {
                                setState(() {
                                  _sort = _sort == ParkingSort.nearest
                                      ? ParkingSort.recommended
                                      : ParkingSort.nearest;
                                });
                                if (_sort == ParkingSort.nearest && _currentLocation == null) {
                                  await _goToCurrentLocation();
                                }
                              },
                            ),
                            if (_activeFilterCount > 0) ...[
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _vehicleFilter = null;
                                    _openNowOnly = false;
                                    _maxHourlyRate = null;
                                    _sort = ParkingSort.recommended;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFEF4444)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Reset',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    SizedBox(
                      key: _mapKey,
                      height: _isMapFullscreen
                          ? (MediaQuery.of(context).size.height * 0.70)
                          : 340,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            gmaps.GoogleMap(
                              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                              initialCameraPosition: gmaps.CameraPosition(
                                target: gmaps.LatLng(
                                  _initialCenter(allSpaces).latitude,
                                  _initialCenter(allSpaces).longitude,
                                ),
                                zoom: 14,
                              ),
                              onMapCreated: (controller) {
                                _googleMapController = controller;
                                _mapReady = true;
                                if (_selectedSpace != null &&
                                    _pointFor(_selectedSpace!) != null) {
                                  final start =
                                      _effectiveOrigin(_selectedSpace!);
                                  _fitRoute(
                                    start,
                                    _pointFor(_selectedSpace!)!,
                                  );
                                }
                              },
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              compassEnabled: true,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              markers: _buildGoogleMarkers(allSpaces, mappedSpaces),
                              polylines: _buildGooglePolylines(),
                            ),
                            if (!_isNavigating)
                              Positioned(
                                top: 14,
                                right: 14,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _MapControlButton(
                                      icon: _isMapFullscreen
                                          ? Icons.fullscreen_exit_rounded
                                          : Icons.fullscreen_rounded,
                                      tooltip: _isMapFullscreen
                                          ? 'Collapse map'
                                          : 'Expand map',
                                      onPressed: () {
                                        setState(() {
                                          _isMapFullscreen = !_isMapFullscreen;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    _MapControlButton(
                                      icon: Icons.add_rounded,
                                      tooltip: 'Zoom in',
                                      onPressed: () {
                                        _googleMapController?.animateCamera(
                                          gmaps.CameraUpdate.zoomIn(),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    _MapControlButton(
                                      icon: Icons.remove_rounded,
                                      tooltip: 'Zoom out',
                                      onPressed: () {
                                        _googleMapController?.animateCamera(
                                          gmaps.CameraUpdate.zoomOut(),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    _MapControlButton(
                                      icon: Icons.my_location_rounded,
                                      tooltip: 'Recenter',
                                      onPressed: () {
                                        if (_currentLocation != null) {
                                          _moveMap(_currentLocation!, 16);
                                        } else {
                                          _goToCurrentLocation();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            if (mappedSpaces.isEmpty)
                              const Positioned(
                                top: 12,
                                left: 12,
                                right: 12,
                                child: _MapNotice(),
                              ),
                            if (_isNavigating &&
                                _navProgress != null &&
                                _selectedSpace != null)
                              Positioned.fill(
                                child: _DrivingNavigationHUD(
                                  space: _selectedSpace!,
                                  progress: _navProgress!,
                                  mode: _transportMode,
                                  cameraFollowsVehicle: _cameraFollowsVehicle,
                                  onToggleCameraFollow: () {
                                    setState(() {
                                      _cameraFollowsVehicle =
                                          !_cameraFollowsVehicle;
                                    });
                                    if (_cameraFollowsVehicle &&
                                        _navProgress != null) {
                                      _moveMap(
                                        _navProgress!.currentPosition,
                                        17.5,
                                      );
                                    }
                                  },
                                  onRecenter: () {
                                    if (_navProgress != null) {
                                      _moveMap(
                                        _navProgress!.currentPosition,
                                        17.5,
                                      );
                                    }
                                  },
                                  onStopDriving: _stopDriving,
                                ),
                              )
                            else if (_selectedSpace != null)
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 20,
                                child: _SelectedSpaceCard(
                                  space: _selectedSpace!,
                                  distance: _routeData?.distanceKm ??
                                      _distanceFor(_selectedSpace!),
                                  eta: _routeData?.etaText ??
                                      _estimateEta(
                                        _distanceFor(_selectedSpace!),
                                      ),
                                  steps: _routeData?.steps ?? const [],
                                  isLiveGps: _currentLocation != null,
                                  onStartDriving: () =>
                                      _startDriving(simulate: false),
                                  onClose: _clearSelection,
                                  onRecenter: () {
                                    if (_pointFor(_selectedSpace!) != null) {
                                      final start =
                                          _effectiveOrigin(_selectedSpace!);
                                      _fitRoute(
                                        start,
                                        _pointFor(_selectedSpace!)!,
                                      );
                                    }
                                  },
                                  onExternalNavigation: () {
                                    _startDriving(simulate: false);
                                  },
                                  onDetails: () =>
                                      _openDetails(_selectedSpace!),
                                  onSyncGps: () => _goToCurrentLocation(
                                    refitFor: _selectedSpace,
                                  ),
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

  Set<gmaps.Marker> _buildGoogleMarkers(
    List<ParkingSpace> allSpaces,
    List<ParkingSpace> mappedSpaces,
  ) {
    final markers = <gmaps.Marker>{};

    // 1. In Navigation / Route Mode: show the destination and vehicle position
    if (_selectedSpace != null && _pointFor(_selectedSpace!) != null) {
      final destPt = _pointFor(_selectedSpace!)!;
      final isAvailable = _selectedSpace!.isAvailable;
      final rate = _selectedSpace!.getEffectiveRate(vehicleType: _vehicleFilter);

      markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId('selected_dest_${_selectedSpace!.id}'),
          position: gmaps.LatLng(destPt.latitude, destPt.longitude),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            isAvailable
                ? gmaps.BitmapDescriptor.hueAzure
                : gmaps.BitmapDescriptor.hueRed,
          ),
          infoWindow: gmaps.InfoWindow(
            title: _selectedSpace!.name,
            snippet: isAvailable
                ? '₱${rate.toStringAsFixed(2)}/hr • ${_selectedSpace!.availableSlotsCount} slots free'
                : 'Destination • Sold Out',
          ),
          onTap: () {
            final start = _effectiveOrigin(_selectedSpace!);
            _fitRoute(start, destPt);
          },
        ),
      );

      // Driver vehicle / origin marker (real-time moving pin)
      final originPt = _navProgress?.currentPosition ??
          _currentLocation ??
          _effectiveOrigin(_selectedSpace!);
      final bearing = _isNavigating
          ? (_navProgress?.bearing ?? _currentHeading)
          : _currentHeading;

      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('driver_vehicle_marker'),
          position: gmaps.LatLng(originPt.latitude, originPt.longitude),
          rotation: bearing,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 10,
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            _isNavigating
                ? gmaps.BitmapDescriptor.hueCyan
                : gmaps.BitmapDescriptor.hueBlue,
          ),
          infoWindow: gmaps.InfoWindow(
            title: _isNavigating ? 'Vehicle En Route' : 'Your Live Location',
            snippet: _currentSpeedKmh > 1.0
                ? '${_currentSpeedKmh.toStringAsFixed(0)} km/h • GPS Active${_currentAccuracyMeters > 0 ? " (±${_currentAccuracyMeters.toStringAsFixed(0)}m)" : ""}'
                : (_routeData != null
                    ? '${_routeData!.etaText} (${_routeData!.distanceKm.toStringAsFixed(1)} km)'
                    : 'Real-time GPS Tracking${_currentAccuracyMeters > 0 ? " (±${_currentAccuracyMeters.toStringAsFixed(0)}m)" : ""}'),
          ),
        ),
      );
    }
    // 2. In Browse Mode: show real-time driver location pin PLUS all filtered spaces
    else {
      // Add real-time driver location marker if position is known
      if (_currentLocation != null) {
        markers.add(
          gmaps.Marker(
            markerId: const gmaps.MarkerId('driver_live_location_marker'),
            position: gmaps.LatLng(
              _currentLocation!.latitude,
              _currentLocation!.longitude,
            ),
            rotation: _currentHeading,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            zIndexInt: 10,
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueAzure,
            ),
            infoWindow: gmaps.InfoWindow(
              title: 'Your Location (Live GPS)',
              snippet: _currentSpeedKmh > 1.0
                  ? '${_currentSpeedKmh.toStringAsFixed(0)} km/h • Real-time Tracking${_currentAccuracyMeters > 0 ? " (±${_currentAccuracyMeters.toStringAsFixed(0)}m)" : ""}'
                  : 'Real-time GPS detected${_currentAccuracyMeters > 0 ? " (±${_currentAccuracyMeters.toStringAsFixed(0)}m)" : ""}',
            ),
          ),
        );
      }

      for (final space in mappedSpaces) {
        final pt = _pointFor(space);
        if (pt == null) continue;
        final selected = _selectedSpace?.id == space.id;
        final rate = space.getEffectiveRate(vehicleType: _vehicleFilter);

        markers.add(
          gmaps.Marker(
            markerId: gmaps.MarkerId('parking_space_${space.id}'),
            position: gmaps.LatLng(pt.latitude, pt.longitude),
            icon: space.isAvailable
                ? (selected
                    ? gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueYellow)
                    : gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueViolet))
                : gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
            infoWindow: gmaps.InfoWindow(
              title: space.name,
              snippet: space.isAvailable
                  ? '₱${rate.toStringAsFixed(2)}/hr • ${space.availableSlotsCount} slots free'
                  : 'Sold Out / Unavailable',
            ),
            onTap: () {
              _selectSpace(space, autoFit: true);
            },
          ),
        );
      }
    }

    return markers;
  }

  Set<gmaps.Polyline> _buildGooglePolylines() {
    final polylines = <gmaps.Polyline>{};

    if (_selectedSpace != null &&
        _pointFor(_selectedSpace!) != null &&
        _routeData != null) {
      // Alternative route in subtle slate grey
      if (_routeData!.alternativeCoordinates != null &&
          _routeData!.alternativeCoordinates!.isNotEmpty) {
        polylines.add(
          gmaps.Polyline(
            polylineId: const gmaps.PolylineId('alternative_route'),
            points: _routeData!.alternativeCoordinates!
                .map((p) => gmaps.LatLng(p.latitude, p.longitude))
                .toList(),
            color: const Color(0xFF94A3B8),
            width: 4,
          ),
        );
      }

      // High-contrast casing for primary route
      polylines.add(
        gmaps.Polyline(
          polylineId: const gmaps.PolylineId('primary_route_casing'),
          points: _routeData!.primaryCoordinates
              .map((p) => gmaps.LatLng(p.latitude, p.longitude))
              .toList(),
          color: const Color(0xFF173B64),
          width: 8,
        ),
      );

      // Primary route polyline in vibrant brand gold/blue
      polylines.add(
        gmaps.Polyline(
          polylineId: const gmaps.PolylineId('primary_route'),
          points: _routeData!.primaryCoordinates
              .map((p) => gmaps.LatLng(p.latitude, p.longitude))
              .toList(),
          color: const Color(0xFFFFDE70),
          width: 5,
        ),
      );
    }

    return polylines;
  }

  Widget _parkingCard(ParkingSpace space) {
    final distance = _distanceFor(space);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasImage = space.imageUrl != null && space.imageUrl!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: hasImage
                ? () => ImagePreviewDialog.show(
                      context,
                      imageUrl: space.imageUrl!,
                      title: space.name,
                    )
                : null,
            child: Container(
              width: 88,
              height: 88,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    AppNetworkImage(
                      imageUrl: space.imageUrl!,
                      fit: BoxFit.cover,
                      fallbackWidget: Center(
                        child: Icon(
                          Icons.local_parking_rounded,
                          color: colors.primary,
                          size: 36,
                        ),
                      ),
                      loadingWidget: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.local_parking_rounded,
                        color: colors.primary,
                        size: 36,
                      ),
                    ),
                  if (hasImage)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                ],
              ),
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
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    _StatusBadge(space: space),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  space.address,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  space.price,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                if (distance != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_outlined,
                        size: 15,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatParkingDistance(distance),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
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
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
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

class _SelectedSpaceCard extends StatefulWidget {
  const _SelectedSpaceCard({
    required this.space,
    required this.distance,
    required this.eta,
    required this.isLiveGps,
    required this.onClose,
    required this.onRecenter,
    required this.onExternalNavigation,
    required this.onDetails,
    required this.onSyncGps,
    this.onStartDriving,
    this.steps = const [],
  });

  final ParkingSpace space;
  final double? distance;
  final String eta;
  final bool isLiveGps;
  final VoidCallback onClose;
  final VoidCallback onRecenter;
  final VoidCallback onExternalNavigation;
  final VoidCallback onDetails;
  final VoidCallback onSyncGps;
  final VoidCallback? onStartDriving;
  final List<RouteStepItem> steps;

  @override
  State<_SelectedSpaceCard> createState() => _SelectedSpaceCardState();
}

class _SelectedSpaceCardState extends State<_SelectedSpaceCard> {
  bool _showSteps = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasSteps = widget.steps.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 8,
      shadowColor: Colors.black38,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.navigation_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'IN-APP ROUTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.distance != null
                        ? '${formatParkingDistance(widget.distance)} • ${widget.eta}'
                        : widget.eta,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Recenter route',
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onRecenter,
                  icon: const Icon(Icons.center_focus_strong_rounded, size: 18),
                ),
                IconButton(
                  tooltip: 'External navigation',
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onExternalNavigation,
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                ),
                IconButton(
                  tooltip: 'Close route',
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.space.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.space.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.onStartDriving != null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: widget.onStartDriving,
                    icon: const Icon(Icons.navigation_rounded, size: 15),
                    label: const Text('Start Driving'),
                  ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  onPressed: widget.onDetails,
                  child: const Text('Reserve'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => setState(() => _showSteps = !_showSteps),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  children: [
                    Icon(
                      _showSteps
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 16,
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showSteps ? 'Hide directions' : 'View turn-by-turn directions',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showSteps) ...[
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    if (hasSteps)
                      for (int i = 0; i < widget.steps.length; i++) ...[
                        if (i > 0) const Divider(height: 8),
                        _stepRow(
                          widget.steps[i].icon,
                          i == 0
                              ? Colors.green
                              : (i == widget.steps.length - 1
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFF2563EB)),
                          i == 0
                              ? 'Start'
                              : (i == widget.steps.length - 1 ? 'Arrival' : ''),
                          widget.steps[i].instruction,
                        ),
                      ]
                    else ...[
                      _stepRow(
                        Icons.trip_origin_rounded,
                        Colors.green,
                        'Start',
                        'Depart from your current position',
                      ),
                      const Divider(height: 8),
                      _stepRow(
                        Icons.turn_right_rounded,
                        const Color(0xFF2563EB),
                        'Drive',
                        'Follow route towards ${widget.space.address.isNotEmpty ? widget.space.address : widget.space.name}',
                      ),
                      const Divider(height: 8),
                      _stepRow(
                        Icons.local_parking_rounded,
                        const Color(0xFF4F46E5),
                        'Arrival',
                        'Enter ${widget.space.name} and present QR / Gate Pass',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stepRow(IconData icon, Color color, String tag, String desc) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        if (tag.isNotEmpty) ...[
          Text(
            '$tag: ',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: color,
            ),
          ),
        ],
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}



class _DrivingNavigationHUD extends StatelessWidget {
  const _DrivingNavigationHUD({
    required this.space,
    required this.progress,
    required this.mode,
    required this.cameraFollowsVehicle,
    required this.onToggleCameraFollow,
    required this.onRecenter,
    required this.onStopDriving,
  });

  final ParkingSpace space;
  final LiveNavigationProgress progress;
  final NavigationTransportMode mode;
  final bool cameraFollowsVehicle;
  final VoidCallback onToggleCameraFollow;
  final VoidCallback onRecenter;
  final VoidCallback onStopDriving;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          children: [
            // Top Turn-by-Turn Maneuver Card
            Material(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              elevation: 8,
              shadowColor: Colors.black45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        progress.currentStep.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            progress.isArrived
                                ? 'Arriving at Destination'
                                : (progress.currentStep.distanceMeters != null
                                    ? 'In ${(progress.currentStep.distanceMeters! / 10).round() * 10}m'
                                    : 'Next maneuver'),
                            style: const TextStyle(
                              color: Color(0xFF4ADE80),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            progress.currentStep.instruction,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          if (progress.nextStep != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Then: ${progress.nextStep!.instruction}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Floating Camera Follow and Recenter controls
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'nav_recenter',
                      tooltip: 'Center on vehicle',
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      onPressed: onRecenter,
                      child: const Icon(Icons.my_location_rounded, size: 20),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'nav_toggle_camera',
                      tooltip: cameraFollowsVehicle ? 'Camera Following' : 'Camera Free',
                      backgroundColor: cameraFollowsVehicle
                          ? const Color(0xFF2563EB)
                          : Colors.white,
                      foregroundColor: cameraFollowsVehicle
                          ? Colors.white
                          : const Color(0xFF64748B),
                      onPressed: onToggleCameraFollow,
                      child: Icon(
                        cameraFollowsVehicle
                            ? Icons.lock_outline_rounded
                            : Icons.lock_open_rounded,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Driving Metrics & Action Bar
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              elevation: 10,
              shadowColor: Colors.black38,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Speed Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            progress.currentSpeedKmh.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Text(
                            'km/h',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Remaining ETA & Distance
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                progress.remainingEtaText,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '• ${progress.remainingDistanceKm.toStringAsFixed(1)} km left',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            space.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stop / Exit button
                    IconButton.filledTonal(
                      tooltip: 'Stop Navigation',
                      onPressed: onStopDriving,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        foregroundColor: const Color(0xFFDC2626),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrivalCelebrationDialog extends StatelessWidget {
  const _ArrivalCelebrationDialog({
    required this.space,
    required this.onClose,
  });

  final ParkingSpace space;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Color(0xFFDCFCE7),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.local_parking_rounded,
          color: Color(0xFF16A34A),
          size: 40,
        ),
      ),
      title: const Text(
        'You have arrived!',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Welcome to ${space.name}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            space.address,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please proceed to the security barrier or designated stall to present your Entry Pass.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: onClose,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Got it, finish navigation'),
        ),
      ],
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

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip ?? '',
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 20, color: const Color(0xFF1E293B)),
          ),
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

class _RoutePlanningHeader extends StatelessWidget {
  const _RoutePlanningHeader({
    required this.space,
    required this.routeData,
    required this.transportMode,
    required this.isLiveGps,
    required this.onModeChanged,
    required this.onClose,
    required this.onRecenter,
    this.onStartDriving,
    this.onSyncGps,
  });

  final ParkingSpace space;
  final NavigationRouteData? routeData;
  final NavigationTransportMode transportMode;
  final bool isLiveGps;
  final ValueChanged<NavigationTransportMode> onModeChanged;
  final VoidCallback onClose;
  final VoidCallback onRecenter;
  final VoidCallback? onStartDriving;
  final VoidCallback? onSyncGps;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: Car & Motor mode tabs + Start Driving + Close button
            Row(
              children: [
                _ModeItem(
                  mode: NavigationTransportMode.car,
                  label: 'Drive',
                  eta: routeData?.carEta ?? '',
                  icon: Icons.directions_car_rounded,
                  isSelected: transportMode == NavigationTransportMode.car,
                  onTap: () => onModeChanged(NavigationTransportMode.car),
                ),
                const SizedBox(width: 8),
                _ModeItem(
                  mode: NavigationTransportMode.motorcycle,
                  label: 'Motor',
                  eta: routeData?.motorcycleEta ?? '',
                  icon: Icons.two_wheeler_rounded,
                  isSelected: transportMode == NavigationTransportMode.motorcycle,
                  onTap: () => onModeChanged(NavigationTransportMode.motorcycle),
                ),
                const Spacer(),
                if (onStartDriving != null) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onStartDriving,
                    icon: const Icon(Icons.navigation_rounded, size: 14),
                    label: const Text('Start', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 4),
                ],
                FavoriteSpaceButton(
                  parkingSpaceId: space.id,
                  parkingSpaceName: space.name,
                  iconSize: 20,
                  padding: const EdgeInsets.all(4),
                ),
                IconButton(
                  tooltip: 'Close route',
                  visualDensity: VisualDensity.compact,
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Origin and Destination fields with vertical track
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left route indicator (Origin circle -> dotted -> Destination pin)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2563EB),
                          width: 3.5,
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 22,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      child: CustomPaint(
                        painter: _DottedLinePainter(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: Color(0xFFEF4444),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Location Boxes
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Origin box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                isLiveGps
                                    ? 'Your location (Live GPS)'
                                    : 'Your location (Starting point)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isLiveGps
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isLiveGps
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isLiveGps ? 'GPS' : 'Est.',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isLiveGps
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Destination box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    space.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (space.address.isNotEmpty)
                                    Text(
                                      space.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Recenter icon button
                IconButton.filledTonal(
                  tooltip: 'Recenter route',
                  onPressed: onRecenter,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.all(8),
                  ),
                  icon: const Icon(Icons.swap_vert_rounded, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeItem extends StatelessWidget {
  const _ModeItem({
    required this.mode,
    required this.label,
    required this.eta,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final NavigationTransportMode mode;
  final String label;
  final String eta;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFBAE6FD) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF64748B),
              ),
              const SizedBox(height: 2),
              Text(
                eta.isNotEmpty ? eta : label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 3.0;
    const dashSpace = 3.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, math.min(startY + dashHeight, size.height)),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

