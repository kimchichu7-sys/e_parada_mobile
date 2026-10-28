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
  LatLng? _customOrigin;
  String? _customOriginName;
  bool _isPickingOriginOnMap = false;
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
    if (_customOrigin != null) return _customOrigin!;
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

  void _setCustomOrigin(LatLng point, String name) {
    setState(() {
      _customOrigin = point;
      _customOriginName = name;
      _isPickingOriginOnMap = false;
    });
    if (_selectedSpace != null) {
      _fetchAndApplyRoute(_selectedSpace!, autoFit: true);
    }
  }

  void _resetOriginToGps() {
    setState(() {
      _customOrigin = null;
      _customOriginName = null;
      _isPickingOriginOnMap = false;
    });
    if (_currentLocation == null) {
      _goToCurrentLocation(refitFor: _selectedSpace);
    } else if (_selectedSpace != null) {
      _fetchAndApplyRoute(_selectedSpace!, autoFit: true);
    }
  }

  void _showStartingPointPicker(List<ParkingSpace> allSpaces) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StartingPointPickerSheet(
        allSpaces: allSpaces,
        currentSelectedSpace: _selectedSpace,
        currentOrigin: _customOrigin,
        currentOriginName: _customOriginName,
        currentGpsLocation: _currentLocation,
        onSelectOrigin: (point, name) {
          _setCustomOrigin(point, name);
          _message('Starting point set to $name');
        },
        onSelectOnMap: () {
          setState(() {
            _isPickingOriginOnMap = true;
          });
          _message('Tap anywhere on the map to place your starting point');
        },
        onResetToGps: () {
          _resetOriginToGps();
          _message('Starting point reset to Live GPS');
        },
      ),
    );
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
        if (autoFit) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fitRoute(startPoint, destPoint);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
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
      _customOrigin = null;
      _customOriginName = null;
      _isPickingOriginOnMap = false;
    });
  }

  Future<void> _startDriving() async {
    if (_selectedSpace == null) return;
    _navSubscription?.cancel();
    _navSubscription = null;
    _isSimulatingRoute = false;

    // 1. Detect driver's live GPS location if no custom starting point is set and GPS is not yet available
    if (_customOrigin == null && _currentLocation == null) {
      _message('Detecting your live GPS location...');
      try {
        final enabled = await Geolocator.isLocationServiceEnabled();
        if (!enabled) {
          _message('Please turn on location services on your device.');
        } else {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            final pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation,
                timeLimit: Duration(seconds: 10),
              ),
            );
            if (mounted) {
              _handlePositionUpdate(pos);
            }
          } else {
            _message('Location permission is needed for live driving.');
          }
        }
      } catch (e) {
        debugPrint('Live location detection error: $e');
      }
    }

    // 2. Recalculate route starting from effective origin
    if (_selectedSpace != null) {
      await _fetchAndApplyRoute(_selectedSpace!, autoFit: false);
    }

    if (!mounted || _selectedSpace == null || _routeData == null) return;

    final livePos = _customOrigin ?? _currentLocation ?? _routeData!.primaryCoordinates.first;

    setState(() {
      _isNavigating = true;
      _cameraFollowsVehicle = true;
    });

    // 3. Start continuous high-accuracy live GPS stream (only moves pin when driver actually moves)
    _initRealtimeLocationTracking(moveCameraOnFix: true);

    if (_currentLocation != null) {
      _updateRealtimeNavigationProgress(_currentLocation!, _currentHeading, _currentSpeedKmh);
    } else {
      final initialProgress = RouteNavigationService.computeProgress(
        routeData: _routeData!,
        progressFraction: 0.0,
      );
      setState(() {
        _navProgress = initialProgress;
      });
    }

    _moveMap(livePos, 18.0);
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
                  fontSize: 12,
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

          final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;

          if (_isNavigating) {
            return _buildMapStack(
              allSpaces,
              mappedSpaces,
              isLandscape: isLandscape,
              borderRadius: BorderRadius.zero,
            );
          }

          if (isLandscape) {
            return Row(
              children: [
                // Left Control / List Pane (Responsive width)
                SizedBox(
                  width: 380,
                  child: Column(
                    children: [
                      if (_selectedSpace != null)
                        _RoutePlanningHeader(
                          space: _selectedSpace!,
                          routeData: _routeData,
                          transportMode: _transportMode,
                          isLiveGps: _currentLocation != null,
                          customOriginName: _customOriginName,
                          onSelectOrigin: () => _showStartingPointPicker(allSpaces),
                          onResetToGps: _resetOriginToGps,
                          onModeChanged: _setTransportMode,
                          onStartDriving: _startDriving,
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
                      else
                        _buildSearchAndFilters(allSpaces),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          children: [
                            if (_selectedSpace != null) ...[
                              _SelectedSpaceCard(
                                space: _selectedSpace!,
                                distance: _routeData?.distanceKm ??
                                    _distanceFor(_selectedSpace!),
                                eta: _routeData?.etaText ??
                                    _estimateEta(
                                      _distanceFor(_selectedSpace!),
                                    ),
                                steps: _routeData?.steps ?? const [],
                                isLiveGps: _customOrigin == null &&
                                    _currentLocation != null,
                                originName: _customOriginName,
                                onStartDriving: _startDriving,
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
                                onExternalNavigation: _startDriving,
                                onDetails: () =>
                                    _openDetails(_selectedSpace!),
                                onSyncGps: () => _goToCurrentLocation(
                                  refitFor: _selectedSpace,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _sort == ParkingSort.nearest
                                        ? 'Nearest Parking'
                                        : 'Available Nearby',
                                    style: const TextStyle(
                                      fontSize: 18,
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
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // Right Full-Height Map Pane
                Expanded(
                  child: _buildMapStack(
                    allSpaces,
                    mappedSpaces,
                    isLandscape: true,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ],
            );
          }

          // Portrait orientation
          return Column(
            children: [
              if (_selectedSpace != null && !_isNavigating)
                _RoutePlanningHeader(
                  space: _selectedSpace!,
                  routeData: _routeData,
                  transportMode: _transportMode,
                  isLiveGps: _currentLocation != null,
                  customOriginName: _customOriginName,
                  onSelectOrigin: () => _showStartingPointPicker(allSpaces),
                  onResetToGps: _resetOriginToGps,
                  onModeChanged: _setTransportMode,
                  onStartDriving: _startDriving,
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
                _buildSearchAndFilters(allSpaces),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    SizedBox(
                      key: _mapKey,
                      height: _isMapFullscreen
                          ? (MediaQuery.of(context).size.height * 0.70)
                          : 340,
                      child: _buildMapStack(
                        allSpaces,
                        mappedSpaces,
                        isLandscape: false,
                        borderRadius: BorderRadius.circular(22),
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

  Widget _buildSearchAndFilters(List<ParkingSpace> allSpaces) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
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
                              fontSize: 12,
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
    );
  }

  Widget _buildMapStack(
    List<ParkingSpace> allSpaces,
    List<ParkingSpace> mappedSpaces, {
    BorderRadius? borderRadius,
    bool isLandscape = false,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(22),
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
                final start = _effectiveOrigin(_selectedSpace!);
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
            onTap: (latLng) {
              if (_isPickingOriginOnMap) {
                _setCustomOrigin(
                  LatLng(latLng.latitude, latLng.longitude),
                  'Map Pin (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})',
                );
                _message('Starting point set from map pin.');
              }
            },
            markers: _buildGoogleMarkers(allSpaces, mappedSpaces),
            polylines: _buildGooglePolylines(),
          ),
          if (_isPickingOriginOnMap)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: Color(0xFF38BDF8),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Set Starting Point',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Tap anywhere on the map to set origin',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isPickingOriginOnMap = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF38BDF8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
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
                    _cameraFollowsVehicle = !_cameraFollowsVehicle;
                  });
                  if (_cameraFollowsVehicle && _navProgress != null) {
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
          else if (_selectedSpace != null && !isLandscape)
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
                isLiveGps: _customOrigin == null && _currentLocation != null,
                originName: _customOriginName,
                onStartDriving: _startDriving,
                onClose: _clearSelection,
                onRecenter: () {
                  if (_pointFor(_selectedSpace!) != null) {
                    final start = _effectiveOrigin(_selectedSpace!);
                    _fitRoute(
                      start,
                      _pointFor(_selectedSpace!)!,
                    );
                  }
                },
                onExternalNavigation: _startDriving,
                onDetails: () => _openDetails(_selectedSpace!),
                onSyncGps: () => _goToCurrentLocation(
                  refitFor: _selectedSpace,
                ),
              ),
            ),
        ],
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

      // Driver vehicle / origin marker (real-time moving pin or custom starting point)
      final originPt = _customOrigin ??
          _currentLocation ??
          _navProgress?.currentPosition ??
          _effectiveOrigin(_selectedSpace!);
      final bearing = _isNavigating
          ? (_currentHeading > 0.0 ? _currentHeading : (_navProgress?.bearing ?? 0.0))
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
            _customOrigin != null
                ? gmaps.BitmapDescriptor.hueOrange
                : (_isNavigating
                    ? gmaps.BitmapDescriptor.hueCyan
                    : gmaps.BitmapDescriptor.hueBlue),
          ),
          infoWindow: gmaps.InfoWindow(
            title: _customOrigin != null
                ? 'Starting Point: ${_customOriginName ?? "Custom"}'
                : (_isNavigating ? 'Vehicle En Route' : 'Your Live Location'),
            snippet: _customOrigin != null
                ? (_routeData != null
                    ? '${_routeData!.etaText} (${_routeData!.distanceKm.toStringAsFixed(1)} km)'
                    : 'Custom starting origin')
                : (_currentSpeedKmh > 1.0
                    ? '${_currentSpeedKmh.toStringAsFixed(0)} km/h • GPS Active${_currentAccuracyMeters > 0 ? " (±${_currentAccuracyMeters.toStringAsFixed(0)}m)" : ""}'
                    : (_routeData != null
                        ? '${_routeData!.etaText} (${_routeData!.distanceKm.toStringAsFixed(1)} km)'
                        : 'Real-time GPS Tracking${_currentAccuracyMeters > 0 ? " (±${_currentAccuracyMeters.toStringAsFixed(0)}m)" : ""}')),
          ),
        ),
      );

      // If user specified a custom origin AND live GPS is available, show actual position pin too
      if (_customOrigin != null && _currentLocation != null) {
        markers.add(
          gmaps.Marker(
            markerId: const gmaps.MarkerId('driver_live_gps_marker'),
            position: gmaps.LatLng(
              _currentLocation!.latitude,
              _currentLocation!.longitude,
            ),
            rotation: _currentHeading,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            zIndexInt: 9,
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueAzure,
            ),
            infoWindow: const gmaps.InfoWindow(
              title: 'Your Location (Live GPS)',
              snippet: 'Live device position',
            ),
          ),
        );
      }
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
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  space.price,
                  style: TextStyle(
                    fontSize: 14,
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
                          fontSize: 14,
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
    this.originName,
    this.onStartDriving,
    this.steps = const [],
  });

  final ParkingSpace space;
  final double? distance;
  final String eta;
  final bool isLiveGps;
  final String? originName;
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
                          fontSize: 12,
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
                      fontSize: 14,
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
            if (widget.originName != null) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.trip_origin_rounded, size: 12, color: Color(0xFF2563EB)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'From: ${widget.originName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            LayoutBuilder(
              builder: (context, cardConstraints) {
                final isNarrow = cardConstraints.maxWidth < 360;

                Widget buildDrivingButton() {
                  return FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: widget.onStartDriving,
                    icon: const Icon(Icons.navigation_rounded, size: 14),
                    label: const Text('Start Driving', style: TextStyle(fontSize: 12)),
                  );
                }

                Widget buildReserveButton() {
                  return FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: widget.onDetails,
                    child: const Text('Reserve', style: TextStyle(fontSize: 12)),
                  );
                }

                if (isNarrow) {
                  return Column(
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
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.onStartDriving != null) ...[
                            Expanded(child: buildDrivingButton()),
                            const SizedBox(width: 8),
                          ],
                          Expanded(child: buildReserveButton()),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
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
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.onStartDriving != null) ...[
                      buildDrivingButton(),
                      const SizedBox(width: 8),
                    ],
                    buildReserveButton(),
                  ],
                );
              },
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
                    Expanded(
                      child: Text(
                        _showSteps ? 'Hide directions' : 'View turn-by-turn directions',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
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
                        widget.originName != null
                            ? 'Depart from ${widget.originName}'
                            : (widget.isLiveGps
                                ? 'Depart from your current position'
                                : 'Depart from starting point'),
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
              fontSize: 12,
              color: color,
            ),
          ),
        ],
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
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
                              fontSize: 14,
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
                                      fontSize: 12,
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
                              fontSize: 12,
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
                                  fontSize: 14,
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
                              fontSize: 12,
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
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please proceed to the security barrier or designated stall to present your Entry Pass.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
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
          fontSize: 12,
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
    required this.onSelectOrigin,
    this.customOriginName,
    this.onResetToGps,
    this.onStartDriving,
    this.onSyncGps,
  });

  final ParkingSpace space;
  final NavigationRouteData? routeData;
  final NavigationTransportMode transportMode;
  final bool isLiveGps;
  final String? customOriginName;
  final VoidCallback onSelectOrigin;
  final VoidCallback? onResetToGps;
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
                    label: const Text('Start', style: TextStyle(fontSize: 14)),
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
                          color: customOriginName != null
                              ? const Color(0xFFF97316)
                              : const Color(0xFF2563EB),
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
                      // Origin box (interactive - allows custom input or live location)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onSelectOrigin,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: customOriginName != null
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: customOriginName != null
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFCBD5E1),
                                width: customOriginName != null ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        customOriginName ??
                                            (isLiveGps
                                                ? 'Your location (Live GPS)'
                                                : 'Your location (Starting point)'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: customOriginName != null
                                              ? const Color(0xFF1E3A8A)
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        customOriginName != null
                                            ? 'Custom origin • Tap to change'
                                            : 'Tap to input custom starting point',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: customOriginName != null
                                              ? const Color(0xFF2563EB)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: customOriginName != null
                                        ? const Color(0xFFDBEAFE)
                                        : (isLiveGps
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFF1F5F9)),
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
                                          color: customOriginName != null
                                              ? const Color(0xFF2563EB)
                                              : (isLiveGps
                                                  ? const Color(0xFF16A34A)
                                                  : const Color(0xFF94A3B8)),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        customOriginName != null
                                            ? 'Custom'
                                            : (isLiveGps ? 'GPS' : 'Est.'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: customOriginName != null
                                              ? const Color(0xFF1D4ED8)
                                              : (isLiveGps
                                                  ? const Color(0xFF15803D)
                                                  : const Color(0xFF64748B)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (customOriginName != null && onResetToGps != null) ...[
                                  const SizedBox(width: 4),
                                  Tooltip(
                                    message: 'Reset to Live GPS',
                                    child: InkWell(
                                      onTap: onResetToGps,
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 13,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
                                      fontSize: 14,
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
                                        fontSize: 12,
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
                // Swap / Change origin icon button
                IconButton.filledTonal(
                  tooltip: 'Change or swap starting point',
                  onPressed: onSelectOrigin,
                  style: IconButton.styleFrom(
                    backgroundColor: customOriginName != null
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF1F5F9),
                    foregroundColor: customOriginName != null
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF0F172A),
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
                  fontSize: 12,
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

class _CalambaLandmark {
  const _CalambaLandmark({
    required this.name,
    required this.subtitle,
    required this.point,
    required this.icon,
  });

  final String name;
  final String subtitle;
  final LatLng point;
  final IconData icon;
}

const List<_CalambaLandmark> _kCalambaLandmarks = [
  _CalambaLandmark(
    name: 'SM City Calamba',
    subtitle: 'National Hwy, Brgy. Real, Calamba',
    point: LatLng(14.2052, 121.1558),
    icon: Icons.shopping_bag_rounded,
  ),
  _CalambaLandmark(
    name: 'Calamba Crossing / Central Terminal',
    subtitle: 'Central Transport Hub, Brgy. Real',
    point: LatLng(14.2096, 121.1539),
    icon: Icons.directions_bus_rounded,
  ),
  _CalambaLandmark(
    name: 'Calamba City Hall Complex',
    subtitle: 'Chipeco Ave, Poblacion, Calamba',
    point: LatLng(14.2078, 121.1667),
    icon: Icons.account_balance_rounded,
  ),
  _CalambaLandmark(
    name: 'Turbina Bus Terminal',
    subtitle: 'Pan-Philippine Hwy, Brgy. Turbina',
    point: LatLng(14.1865, 121.1444),
    icon: Icons.departure_board_rounded,
  ),
  _CalambaLandmark(
    name: 'Canlubang IT & Commercial Center',
    subtitle: 'Carmelray Industrial Park, Canlubang',
    point: LatLng(14.2185, 121.1415),
    icon: Icons.apartment_rounded,
  ),
  _CalambaLandmark(
    name: 'Pansol Hot Springs Area',
    subtitle: 'National Highway, Brgy. Pansol',
    point: LatLng(14.1834, 121.1802),
    icon: Icons.pool_rounded,
  ),
  _CalambaLandmark(
    name: 'Colegio de San Juan de Letran',
    subtitle: 'Ipil-ipil St, Brgy. Bucal, Calamba',
    point: LatLng(14.1887, 121.1652),
    icon: Icons.school_rounded,
  ),
  _CalambaLandmark(
    name: 'Waltermart Calamba',
    subtitle: 'National Hwy, Brgy. Real, Calamba',
    point: LatLng(14.2045, 121.1505),
    icon: Icons.storefront_rounded,
  ),
  _CalambaLandmark(
    name: 'Rizal Shrine & Town Plaza',
    subtitle: 'Mercado St, Poblacion 5, Calamba',
    point: LatLng(14.2140, 121.1660),
    icon: Icons.museum_rounded,
  ),
  _CalambaLandmark(
    name: 'Calamba Medical Center',
    subtitle: 'National Hwy, Crossing, Calamba',
    point: LatLng(14.2081, 121.1582),
    icon: Icons.local_hospital_rounded,
  ),
];

class _StartingPointPickerSheet extends StatefulWidget {
  const _StartingPointPickerSheet({
    required this.allSpaces,
    required this.onSelectOrigin,
    required this.onSelectOnMap,
    required this.onResetToGps,
    this.currentSelectedSpace,
    this.currentOrigin,
    this.currentOriginName,
    this.currentGpsLocation,
  });

  final List<ParkingSpace> allSpaces;
  final ParkingSpace? currentSelectedSpace;
  final LatLng? currentOrigin;
  final String? currentOriginName;
  final LatLng? currentGpsLocation;
  final void Function(LatLng point, String name) onSelectOrigin;
  final VoidCallback onSelectOnMap;
  final VoidCallback onResetToGps;

  @override
  State<_StartingPointPickerSheet> createState() =>
      _StartingPointPickerSheetState();
}

class _StartingPointPickerSheetState extends State<_StartingPointPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  LatLng? _pointFor(ParkingSpace space) {
    final lat = space.latitude;
    final lng = space.longitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final matchingLandmarks = _kCalambaLandmarks.where((l) {
      if (q.isEmpty) return true;
      return l.name.toLowerCase().contains(q) ||
          l.subtitle.toLowerCase().contains(q);
    }).toList();

    final otherSpaces = widget.allSpaces.where((s) {
      if (widget.currentSelectedSpace != null &&
          s.id == widget.currentSelectedSpace!.id) {
        return false;
      }
      if (_pointFor(s) == null) return false;
      if (q.isEmpty) return true;
      return s.name.toLowerCase().contains(q) ||
          s.address.toLowerCase().contains(q);
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Set Starting Point',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.currentSelectedSpace != null
                            ? 'Route to: ${widget.currentSelectedSpace!.name}'
                            : 'Choose where your trip begins',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          // Search box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              textInputAction: TextInputAction.search,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Search location, landmark, or street...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Scrollable list of options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                // Quick Action: My Live Location
                _buildQuickActionTile(
                  icon: Icons.my_location_rounded,
                  iconColor: const Color(0xFF16A34A),
                  iconBgColor: const Color(0xFFDCFCE7),
                  title: 'Your Location (Live GPS)',
                  subtitle: widget.currentGpsLocation != null
                      ? 'Real-time GPS • Calamba area'
                      : 'Use device live location sensor',
                  badge: 'GPS',
                  badgeColor: const Color(0xFFDCFCE7),
                  badgeTextColor: const Color(0xFF15803D),
                  isSelected: widget.currentOrigin == null,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onResetToGps();
                  },
                ),
                const SizedBox(height: 8),
                // Quick Action: Pick on Map
                _buildQuickActionTile(
                  icon: Icons.touch_app_rounded,
                  iconColor: const Color(0xFF0284C7),
                  iconBgColor: const Color(0xFFE0F2FE),
                  title: 'Choose on Map',
                  subtitle: 'Tap anywhere on the map to set starting pin',
                  badge: 'Map Tap',
                  badgeColor: const Color(0xFFE0F2FE),
                  badgeTextColor: const Color(0xFF0369A1),
                  isSelected: false,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onSelectOnMap();
                  },
                ),
                if (_query.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Custom input as starting location
                  _buildQuickActionTile(
                    icon: Icons.add_location_alt_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(0xFFEDE9FE),
                    title: 'Use custom starting point:',
                    subtitle: '"${_query.trim()}"',
                    badge: 'Custom',
                    badgeColor: const Color(0xFFEDE9FE),
                    badgeTextColor: const Color(0xFF6D28D9),
                    isSelected: false,
                    onTap: () {
                      final name = _query.trim();
                      final fallback = widget.currentGpsLocation ??
                          const LatLng(14.2117, 121.1653);
                      // Slight pseudo-hash offset so distinct text yields slightly different valid Calamba coords
                      final hashOffset = (name.hashCode % 100) * 0.0001;
                      final customPoint = LatLng(
                        fallback.latitude - 0.004 + hashOffset,
                        fallback.longitude - 0.003 - hashOffset,
                      );
                      Navigator.of(context).pop();
                      widget.onSelectOrigin(customPoint, name);
                    },
                  ),
                ],
                const SizedBox(height: 16),
                // Calamba Landmarks Section
                if (matchingLandmarks.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      'Calamba Landmarks & Hubs',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  for (final landmark in matchingLandmarks) ...[
                    _buildLandmarkTile(
                      landmark: landmark,
                      isSelected: widget.currentOriginName == landmark.name,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onSelectOrigin(landmark.point, landmark.name);
                      },
                    ),
                    const SizedBox(height: 6),
                  ],
                  const SizedBox(height: 14),
                ],
                // Registered Parking Spaces Section
                if (otherSpaces.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      'Registered Parking Spaces',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  for (final space in otherSpaces) ...[
                    _buildSpaceTile(
                      space: space,
                      isSelected: widget.currentOriginName == space.name,
                      onTap: () {
                        final pt = _pointFor(space);
                        if (pt != null) {
                          Navigator.of(context).pop();
                          widget.onSelectOrigin(pt, space.name);
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                  ],
                ],
                if (matchingLandmarks.isEmpty && otherSpaces.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_off_rounded,
                              size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'No matching landmarks or spaces found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'You can still select "Choose on Map" or tap the custom starting point option.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandmarkTile({
    required _CalambaLandmark landmark,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(landmark.icon, size: 18, color: const Color(0xFF475569)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      landmark.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      landmark.subtitle,
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
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2563EB), size: 20)
              else
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceTile({
    required ParkingSpace space,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_parking_rounded,
                    size: 18, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      space.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      space.address,
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
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2563EB), size: 20)
              else
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}


