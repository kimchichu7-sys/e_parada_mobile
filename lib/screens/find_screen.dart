import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';

import '../models/parking_space.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../utils/marker_bitmap_generator.dart';
import '../utils/parking_discovery.dart';
import '../widgets/app_network_image.dart';
import '../widgets/favorite_space_button.dart';
import 'parking_details_screen.dart';
import 'reserve_parking_screen.dart';

typedef ParkScreen = FindScreen;

class FindScreen extends StatefulWidget {
  const FindScreen({
    super.key,
    this.loadParkingSpaces = ApiService.fetchParkingSpaces,
    this.initialSelectedSpace,
  });

  final Future<List<ParkingSpace>> Function() loadParkingSpaces;
  final ParkingSpace? initialSelectedSpace;

  @override
  State<FindScreen> createState() => _FindScreenState();
}

enum _FindViewMode { map, grid }

class _FindScreenState extends State<FindScreen> {
  static const _fallbackCenter = LatLng(14.2117, 121.1653);

  // Controllers & State
  final MapController _mapController = MapController();
  final _searchController = TextEditingController();

  late Future<List<ParkingSpace>> _spacesFuture;
  List<ParkingSpace> _allSpaces = const [];
  ParkingSpace? _selectedSpace;
  int? _expandedSpaceId;
  int? _hoveredSpaceId;

  bool _isSpaceExpanded(int spaceId) =>
      _expandedSpaceId == spaceId || _hoveredSpaceId == spaceId;

  // Filter state
  String _searchQuery = '';
  late DateTime _arriveDate;
  late TimeOfDay _arriveTime;
  late DateTime _exitDate;
  late TimeOfDay _exitTime;
  String _selectedVehicleType = '';
  bool _onlyFavorites = false;
  _FindViewMode _viewMode = _FindViewMode.map;

  // Location & Map
  LatLng? _currentLocation;
  bool _locationPermissionGranted = false;
  bool _mapReady = false;
  bool _showSearchHereButton = false;

  @override
  void initState() {
    super.initState();
    FavoritesService.init();

    // Default Arrive: Now + 15 min, Default Exit: Arrive + 2 hours
    final now = DateTime.now();
    final start = now.add(const Duration(minutes: 15));
    _arriveDate = DateTime(start.year, start.month, start.day);
    _arriveTime = TimeOfDay(hour: start.hour, minute: start.minute);

    final end = start.add(const Duration(hours: 2));
    _exitDate = DateTime(end.year, end.month, end.day);
    _exitTime = TimeOfDay(hour: end.hour, minute: end.minute);

    if (widget.initialSelectedSpace != null) {
      _selectedSpace = widget.initialSelectedSpace;
    }

    _loadSpaces();
    _checkLocationServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _moveCamera(LatLng point, double zoom) {
    if (!_mapReady) return;
    try {
      _mapController.move(point, zoom);
    } catch (_) {}
  }

  void _loadSpaces() {
    _spacesFuture = widget.loadParkingSpaces().then((spaces) {
      if (!mounted) return spaces;
      setState(() {
        _allSpaces = spaces;
      });

      if (_currentLocation == null && _mapReady && spaces.isNotEmpty) {
        final firstWithCoords = spaces.firstWhere(
          (s) => s.latitude != null && s.longitude != null,
          orElse: () => spaces.first,
        );
        if (firstWithCoords.latitude != null && firstWithCoords.longitude != null) {
          _moveCamera(
            LatLng(firstWithCoords.latitude!, firstWithCoords.longitude!),
            14.5,
          );
        }
      }
      return spaces;
    });
  }

  Future<void> _checkLocationServices() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        _locationPermissionGranted = true;
        _fetchCurrentLocation();
      }
    } catch (_) {}
  }

  Future<void> _requestLocationAndCenter() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _showToast('Please enable device location services.');
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showToast('Location permission denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showToast('Location permission permanently denied. Enable in Settings.');
        await Geolocator.openAppSettings();
        return;
      }

      setState(() {
        _locationPermissionGranted = true;
      });

      await _fetchCurrentLocation(animateCamera: true);
    } catch (e) {
      _showToast('Failed to acquire location: $e');
    }
  }

  Future<void> _fetchCurrentLocation({bool animateCamera = false}) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;
      final point = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentLocation = point;
      });

      if (animateCamera && _mapReady) {
        _moveCamera(point, 15.0);
      }
    } catch (_) {}
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  List<ParkingSpace> _getFilteredSpaces([List<ParkingSpace>? source]) {
    final query = _searchQuery.trim().toLowerCase();
    final vehicle = _selectedVehicleType.trim().toLowerCase();
    final favIds = FavoritesService.getFavoriteIds();
    final targetList = source ?? _allSpaces;

    final baseFiltered = targetList.where((space) {
      if (_onlyFavorites && !favIds.contains(space.id)) {
        return false;
      }

      if (vehicle.isNotEmpty && vehicle != 'all') {
        final supportsVehicle = space.supportedVehicles.any(
          (v) => v.trim().toLowerCase().contains(vehicle),
        );
        if (!supportsVehicle) return false;
      }

      return true;
    }).toList();

    if (query.isEmpty) {
      return baseFiltered;
    }

    final queryMatches = baseFiltered.where((space) {
      final nameMatch = space.name.toLowerCase().contains(query);
      final addrMatch = space.address.toLowerCase().contains(query);
      return nameMatch || addrMatch;
    }).toList();

    // If direct matches exist, return them; otherwise keep spaces on the map so pins don't vanish!
    return queryMatches.isNotEmpty ? queryMatches : baseFiltered;
  }

  Future<void> _searchAndMoveToPlace(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();

    final qLower = query.toLowerCase();

    // 1. Direct match with any parking space (name or address)
    ParkingSpace? matchedSpace;
    for (final s in _allSpaces) {
      if (s.name.toLowerCase().contains(qLower) || s.address.toLowerCase().contains(qLower)) {
        matchedSpace = s;
        break;
      }
    }

    if (matchedSpace != null && matchedSpace.latitude != null && matchedSpace.longitude != null) {
      setState(() {
        _selectedSpace = matchedSpace;
        _showSearchHereButton = false;
      });
      _moveCamera(
        LatLng(matchedSpace.latitude!, matchedSpace.longitude!),
        16.0,
      );
      _showToast('Found parking at: ${matchedSpace.name}');
      return;
    }

    // 2. Known Laguna & Philippine hub coordinates fallback dictionary
    final knownHubs = <String, LatLng>{
      'balian': const LatLng(14.4010, 121.4770),
      'pangil': const LatLng(14.4010, 121.4770),
      'calamba': const LatLng(14.2117, 121.1653),
      'los banos': const LatLng(14.1706, 121.2433),
      'los baños': const LatLng(14.1706, 121.2433),
      'pansol': const LatLng(14.1812, 121.1815),
      'canlubang': const LatLng(14.2223, 121.0961),
      'mayapa': const LatLng(14.2251, 121.1347),
      'turbina': const LatLng(14.1917, 121.1396),
      'real': const LatLng(14.2058, 121.1554),
      'cabuyao': const LatLng(14.2786, 121.1247),
      'santa rosa': const LatLng(14.3122, 121.1114),
      'sta rosa': const LatLng(14.3122, 121.1114),
      'biñan': const LatLng(14.3333, 121.0833),
      'binan': const LatLng(14.3333, 121.0833),
      'san pedro': const LatLng(14.3583, 121.0167),
      'santa cruz': const LatLng(14.2789, 121.4158),
      'sta cruz': const LatLng(14.2789, 121.4158),
      'pagsanjan': const LatLng(14.2731, 121.4542),
      'rizal shrine': const LatLng(14.2120, 121.1645),
      'plaza': const LatLng(14.2120, 121.1645),
      'sm calamba': const LatLng(14.2045, 121.1550),
      'manila': const LatLng(14.5995, 120.9842),
      'makati': const LatLng(14.5547, 121.0244),
      'bgc': const LatLng(14.5492, 121.0507),
    };

    for (final entry in knownHubs.entries) {
      if (qLower.contains(entry.key)) {
        final pt = entry.value;
        _moveCamera(pt, 15.5);
        _showToast('Moved map to ${entry.key.toUpperCase()}');
        return;
      }
    }

    // 3. Online Geocoding via ApiService
    try {
      final geoPt = await ApiService.geocodeAddress(query);
      if (geoPt != null) {
        _moveCamera(geoPt, 15.5);
        _showToast('Moved map to $query');
        return;
      }
    } catch (_) {}

    _showToast('Showing parking spaces around $query');
  }

  LatLng? _pointFor(ParkingSpace space) {
    final lat = space.latitude;
    final lng = space.longitude;
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return LatLng(lat, lng);
  }

  double? _distanceFor(ParkingSpace space) {
    if (_currentLocation == null) return null;
    return parkingDistanceKm(
      space,
      currentLatitude: _currentLocation!.latitude,
      currentLongitude: _currentLocation!.longitude,
    );
  }

  int _calculateDurationHours() {
    final start = DateTime(
      _arriveDate.year,
      _arriveDate.month,
      _arriveDate.day,
      _arriveTime.hour,
      _arriveTime.minute,
    );
    final end = DateTime(
      _exitDate.year,
      _exitDate.month,
      _exitDate.day,
      _exitTime.hour,
      _exitTime.minute,
    );
    final diffMinutes = end.difference(start).inMinutes;
    if (diffMinutes <= 0) return 1;
    return math.max(1, (diffMinutes / 60.0).ceil());
  }

  double _calculateEstimatedTotal(ParkingSpace space) {
    final hourly = space.getEffectiveRate(vehicleType: _selectedVehicleType);
    final hours = _calculateDurationHours();
    return hourly * hours;
  }

  Future<void> _pickArriveDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _arriveDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
      helpText: 'SELECT ARRIVAL DATE',
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _arriveTime,
      helpText: 'SELECT ARRIVAL TIME',
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _arriveDate = pickedDate;
      _arriveTime = pickedTime;
      // Auto-adjust exit if arrive is now after exit
      final start = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      final currentEnd = DateTime(
        _exitDate.year,
        _exitDate.month,
        _exitDate.day,
        _exitTime.hour,
        _exitTime.minute,
      );
      if (currentEnd.isBefore(start) || currentEnd.isAtSameMomentAs(start)) {
        final newEnd = start.add(const Duration(hours: 1));
        _exitDate = DateTime(newEnd.year, newEnd.month, newEnd.day);
        _exitTime = TimeOfDay(hour: newEnd.hour, minute: newEnd.minute);
      }
    });
  }

  Future<void> _pickExitDateTime() async {
    final start = DateTime(
      _arriveDate.year,
      _arriveDate.month,
      _arriveDate.day,
      _arriveTime.hour,
      _arriveTime.minute,
    );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _exitDate.isBefore(_arriveDate) ? _arriveDate : _exitDate,
      firstDate: _arriveDate,
      lastDate: DateTime.now().add(const Duration(days: 21)),
      helpText: 'SELECT EXIT DATE',
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _exitTime,
      helpText: 'SELECT EXIT TIME',
    );
    if (pickedTime == null || !mounted) return;

    final end = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (end.isBefore(start)) {
      _showToast('Exit time must be after arrival time.');
      return;
    }

    setState(() {
      _exitDate = pickedDate;
      _exitTime = pickedTime;
    });
  }

  void _applyFilters() {
    FocusScope.of(context).unfocus();
    final count = _getFilteredSpaces().length;
    _showToast('Filters applied: $count parking space${count == 1 ? '' : 's'} available');
    if (_selectedSpace != null && !_getFilteredSpaces().contains(_selectedSpace)) {
      setState(() => _selectedSpace = null);
    } else {
      setState(() {});
    }
  }

  void _openBookingScreen(ParkingSpace space) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReserveParkingScreen(
          parkingSpaceId: space.id,
          parkingName: space.name,
          address: space.address,
          price: space.price,
          initialStartDate: _arriveDate,
          initialEndDate: _exitDate,
          initialStartTime: _arriveTime,
          initialEndTime: _exitTime,
          initialVehicleType: _selectedVehicleType.isNotEmpty ? _selectedVehicleType : null,
        ),
      ),
    );
  }

  void _openDetailsScreen(ParkingSpace space) {
    Navigator.of(context).push(
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

  Future<void> _openDirections(ParkingSpace space) async {
    final pt = _pointFor(space);
    if (pt == null) {
      _showToast('Map coordinates unavailable for ${space.name}');
      return;
    }

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${pt.latitude},${pt.longitude}',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showToast('Could not launch map directions.');
      }
    } catch (_) {
      _showToast('Could not launch navigation.');
    }
  }

  List<Marker> _buildMarkers(List<ParkingSpace> spaces) {
    final markers = <Marker>[];

    // Driver Live GPS Marker
    if (_currentLocation != null) {
      markers.add(
        Marker(
          key: const ValueKey('driver_live_gps'),
          point: _currentLocation!,
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: const DriverGpsPinWidget(),
        ),
      );
    }

    // Parking spaces markers (render unselected first, selected on top)
    final orderedSpaces = [
      ...spaces.where((s) => _selectedSpace?.id != s.id),
      ...spaces.where((s) => _selectedSpace?.id == s.id),
    ];

    for (final space in orderedSpaces) {
      final pt = _pointFor(space);
      if (pt == null) continue;

      final isSelected = _selectedSpace?.id == space.id;
      final rate = space.getEffectiveRate(vehicleType: _selectedVehicleType);

      markers.add(
        Marker(
          key: ValueKey('space_${space.id}_$isSelected'),
          point: pt,
          width: 96,
          height: 44,
          alignment: Alignment.topCenter,
          child: PricePinBadge(
            price: rate,
            isAvailable: space.isAvailable,
            isClosed: space.isClosed,
            isSoldOut: space.isSoldOut,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedSpace = space;
              });
              if (_mapReady) {
                _moveCamera(pt, _mapController.camera.zoom);
              }
            },
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: FutureBuilder<List<ParkingSpace>>(
          future: _spacesFuture,
          builder: (context, snapshot) {
            final spaces = _getFilteredSpaces(snapshot.data ?? _allSpaces);

            return Column(
              children: [
                // 1. TOP BAR: Header & Filter Controls (Deep Navy Theme)
                _buildTopFilterHeader(),

                // 2. GPS / Location Services Banner (Matches Screenshot 1)
                _buildLocationServicesBanner(),

                // 3. MAIN BODY: Map View or Grid / List View
                Expanded(
                  child: Stack(
                    children: [
                      if (_viewMode == _FindViewMode.map)
                        _buildMapView(spaces)
                      else
                        _buildGridView(spaces),

                      // Bottom Floating Selected Space Card (Matches Screenshot 2)
                      if (_viewMode == _FindViewMode.map && _selectedSpace != null)
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: _buildSelectedSpaceCard(_selectedSpace!),
                        ),

                      // Floating "Search here" button when panned (Matches Screenshot 1)
                      if (_viewMode == _FindViewMode.map && _showSearchHereButton && _selectedSpace == null)
                        Positioned(
                          bottom: 24,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showSearchHereButton = false;
                                });
                                _showToast('Searching around this map location...');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text(
                                'Search here',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Filter Header (Deep Navy #1E3A4C / #173B64 with #FFDE70 Gold Accents)
  // ---------------------------------------------------------------------------
  Widget _buildTopFilterHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headerBg = isDark ? const Color(0xFF0A192C) : const Color(0xFF1E3A4C);
    final searchBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final searchBorder = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final searchTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final searchHintColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final searchIconColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF1E3A4C);
    final cursorColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF173B64);
    final closeIconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final chipBg = isDark ? const Color(0xFF1E293B) : const Color(0xFF28495D);
    final chipBorder = isDark ? const Color(0xFF334155) : const Color(0xFF475569);
    final chipDropdownBg = isDark ? const Color(0xFF1E293B) : const Color(0xFF1E3A4C);

    return Container(
      decoration: BoxDecoration(
        color: headerBg,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Search Bar + View Toggle & Favorites
          Row(
            children: [
              // Search text input (Adapts to light & dark theme)
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: searchBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: searchBorder, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFF43F5E), // Rose pin icon
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(
                            color: searchTextColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                          cursorColor: cursorColor,
                          decoration: InputDecoration(
                            hintText: 'Address, Place or Event...',
                            hintStyle: TextStyle(
                              color: searchHintColor,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (val) => _searchAndMoveToPlace(val),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              Icons.close_rounded,
                              color: closeIconColor,
                              size: 18,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () => _searchAndMoveToPlace(_searchController.text),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            Icons.search_rounded,
                            color: searchIconColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Favorites toggle button
              ValueListenableBuilder<Set<int>>(
                valueListenable: FavoritesService.favoritesNotifier,
                builder: (context, favIds, _) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _onlyFavorites = !_onlyFavorites;
                      });
                    },
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: _onlyFavorites
                            ? const Color(0xFFFFDE70)
                            : chipBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _onlyFavorites
                              ? const Color(0xFFFFDE70)
                              : chipBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _onlyFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: _onlyFavorites ? const Color(0xFF173B64) : const Color(0xFFF43F5E),
                            size: 18,
                          ),
                          if (favIds.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${favIds.length})',
                              style: TextStyle(
                                color: _onlyFavorites ? const Color(0xFF173B64) : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),

              // MAP / GRID view switcher
              Container(
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: chipBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewTab(
                      label: 'MAP',
                      isSelected: _viewMode == _FindViewMode.map,
                      onTap: () => setState(() => _viewMode = _FindViewMode.map),
                    ),
                    _buildViewTab(
                      label: 'GRID',
                      isSelected: _viewMode == _FindViewMode.grid,
                      onTap: () => setState(() => _viewMode = _FindViewMode.grid),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 2: Filter widgets (ARRIVE AFTER, EXIT BEFORE, VEHICLE TYPE, APPLY)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // 1. ARRIVE AFTER widget
                GestureDetector(
                  onTap: _pickArriveDateTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: chipBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ARRIVE AFTER',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${_arriveDate.month.toString().padLeft(2, '0')}/${_arriveDate.day.toString().padLeft(2, '0')}/${_arriveDate.year}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 6),
                            const Text('|', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            const SizedBox(width: 6),
                            Text(
                              _formatTimeOfDay(_arriveTime),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFDE70), // Naples Gold
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFFFFDE70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 2. EXIT BEFORE widget
                GestureDetector(
                  onTap: _pickExitDateTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: chipBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'EXIT BEFORE',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${_exitDate.month.toString().padLeft(2, '0')}/${_exitDate.day.toString().padLeft(2, '0')}/${_exitDate.year}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 6),
                            const Text('|', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            const SizedBox(width: 6),
                            Text(
                              _formatTimeOfDay(_exitTime),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFDE70), // Naples Gold
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFFFFDE70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 3. VEHICLE TYPE widget
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: chipBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'VEHICLE TYPE',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVehicleType.isEmpty ? 'All' : _selectedVehicleType,
                          dropdownColor: chipDropdownBg,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                          isDense: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Vehicle Types')),
                            DropdownMenuItem(value: 'Car', child: Text('Car')),
                            DropdownMenuItem(value: 'Motorcycle', child: Text('Motorcycle')),
                            DropdownMenuItem(value: 'SUV/MPV', child: Text('SUV / MPV')),
                            DropdownMenuItem(value: 'Van', child: Text('Van')),
                            DropdownMenuItem(value: 'Pickup', child: Text('Pickup')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedVehicleType = (val == null || val == 'All') ? '' : val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 4. APPLY BUTTON (Gold #FFDE70 with #173B64 bold text)
                ElevatedButton.icon(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDE70),
                    foregroundColor: const Color(0xFF173B64),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16, color: Color(0xFF173B64)),
                  label: const Text(
                    'APPLY',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.6,
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

  Widget _buildViewTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFDE70) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isSelected ? const Color(0xFF173B64) : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Location Services Banner (Matches Screenshot 1 Sky Blue Bar)
  // ---------------------------------------------------------------------------
  Widget _buildLocationServicesBanner() {
    final hasGps = _locationPermissionGranted && _currentLocation != null;

    return Material(
      color: hasGps ? const Color(0xFF0369A1) : const Color(0xFF0284C7),
      child: InkWell(
        onTap: _requestLocationAndCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Icon(
                hasGps ? Icons.near_me_rounded : Icons.navigation_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasGps
                      ? 'Live GPS enabled • Centered near your vehicle'
                      : 'Tap here to enable location services and find parking where you are.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Map View
  // ---------------------------------------------------------------------------
  Widget _buildMapView(List<ParkingSpace> spaces) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation ?? _fallbackCenter,
        initialZoom: 13.8,
        minZoom: 3,
        maxZoom: 20,
        onMapReady: () {
          _mapReady = true;
          if (_currentLocation == null && spaces.isNotEmpty) {
            final firstWithCoords = spaces.firstWhere(
              (s) => s.latitude != null && s.longitude != null,
              orElse: () => spaces.first,
            );
            if (firstWithCoords.latitude != null && firstWithCoords.longitude != null) {
              _moveCamera(
                LatLng(firstWithCoords.latitude!, firstWithCoords.longitude!),
                14.5,
              );
            }
          }
        },
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture && !_showSearchHereButton) {
            setState(() => _showSearchHereButton = true);
          }
        },
        onTap: (_, _) {
          if (_selectedSpace != null) {
            setState(() => _selectedSpace = null);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}',
          subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
          userAgentPackageName: 'com.eparada.app',
          maxZoom: 20,
        ),
        MarkerLayer(
          markers: _buildMarkers(spaces),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Miniature 2D Floor Plan Preview for Cascading / Collapsible Cards
  // ---------------------------------------------------------------------------
  Widget _buildMini2DFloorPlan(ParkingSpace space) {
    final slots = space.slotsLayout.isNotEmpty
        ? space.slotsLayout.take(8).toList()
        : List.generate(
            math.min(math.max(space.totalSlots, 4), 8),
            (i) => ParkingSlotPreview(
              id: i + 1,
              slotNumber: i + 1,
              label: 'Slot ${i + 1}',
              vehicleTypes: space.supportedVehicles.isNotEmpty
                  ? [space.supportedVehicles.first]
                  : const ['Car'],
              status: i < space.availableSlotsCount ? 'available' : 'occupied',
            ),
          );

    final mid = (slots.length / 2).ceil();
    final topRow = slots.sublist(0, mid);
    final bottomRow = slots.length > mid ? slots.sublist(mid) : const <ParkingSlotPreview>[];

    Widget buildStallRow(List<ParkingSlotPreview> rowSlots) {
      return Row(
        children: [
          for (var i = 0; i < rowSlots.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: InkWell(
                onTap: rowSlots[i].isAvailable ? () => _openBookingScreen(space) : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: rowSlots[i].isAvailable
                        ? const Color(0xFF064E3B)
                        : const Color(0xFF4C0519),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: rowSlots[i].isAvailable
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF43F5E),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: rowSlots[i].isAvailable
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFFB7185),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'P-${rowSlots[i].slotNumber}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rowSlots[i].vehicleTypes.isNotEmpty
                            ? rowSlots[i].vehicleTypes.first
                            : 'Bay',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.layers_outlined, size: 13, color: Color(0xFFFFDE70)),
                  SizedBox(width: 5),
                  Text(
                    '2D FLOOR PLAN PREVIEW',
                    style: TextStyle(
                      color: Color(0xFFFFDE70),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    'Open',
                    style: TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFB7185),
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    'Occupied',
                    style: TextStyle(color: Color(0xFFFB7185), fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          buildStallRow(topRow),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: const Color(0xFFFACC15).withValues(alpha: 0.6),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    '⇄ DRIVEWAY AISLE ⇄',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: const Color(0xFFFACC15).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (bottomRow.isNotEmpty) buildStallRow(bottomRow),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Selected Space Bottom Preview Card (Cascading / Collapsible)
  // ---------------------------------------------------------------------------
  Widget _buildSelectedSpaceCard(ParkingSpace space) {
    final dist = _distanceFor(space);
    final total = _calculateEstimatedTotal(space);
    final hours = _calculateDurationHours();
    final expanded = _isSpaceExpanded(space.id);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSpaceId = space.id),
      onExit: (_) => setState(() => _hoveredSpaceId = null),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _expandedSpaceId = (_expandedSpaceId == space.id) ? null : space.id;
          });
        },
        child: AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Main Summary Content: Photo + Title + Expand/Close
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 78,
                        height: 78,
                        child: space.imageUrl != null && space.imageUrl!.trim().isNotEmpty
                            ? AppNetworkImage(
                                imageUrl: space.imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFFE2E8F0),
                                child: const Icon(Icons.local_parking_rounded, color: Color(0xFF64748B), size: 32),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  space.name,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              FavoriteSpaceButton(
                                parkingSpaceId: space.id,
                                parkingSpaceName: space.name,
                                iconSize: 20,
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => setState(() => _selectedSpace = null),
                                child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            space.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: space.isSoldOut
                                      ? const Color(0xFFFFE4E6)
                                      : (space.isClosed ? const Color(0xFFF1F5F9) : const Color(0xFFDCFCE7)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  space.isSoldOut
                                      ? 'Sold Out'
                                      : (space.isClosed ? 'Closed' : '${space.availableSlotsCount} bays open'),
                                  style: TextStyle(
                                    color: space.isSoldOut
                                        ? const Color(0xFFBE123C)
                                        : (space.isClosed ? const Color(0xFF475569) : const Color(0xFF16A34A)),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                              if (dist != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  formatParkingDistance(dist),
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                ),
                              ],
                              const Spacer(),
                              Text(
                                expanded ? 'Hide 2D Plan ▲' : '2D Plan & Details ▼',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF173B64),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (expanded) ...[
                  const SizedBox(height: 10),
                  _buildMini2DFloorPlan(space),
                ],

                const SizedBox(height: 10),

                // Action Buttons: Book CTA + Directions & Details
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () => _openBookingScreen(space),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Book for ₱${total.toStringAsFixed(2)} ($hours hr${hours > 1 ? 's' : ''})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _openDirections(space),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      child: const Icon(Icons.directions_rounded, color: Color(0xFF173B64), size: 18),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _openDetailsScreen(space),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: Color(0xFF173B64), size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Grid / List View (Cascading / Collapsible Summary Cards)
  // ---------------------------------------------------------------------------
  Widget _buildGridView(List<ParkingSpace> spaces) {
    if (spaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text(
              'No parking spaces match your criteria',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try clearing filters or searching another area.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedVehicleType = '';
                  _onlyFavorites = false;
                });
              },
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: spaces.length,
      itemBuilder: (context, index) {
        final space = spaces[index];
        final rate = parkingHourlyRate(space) ?? 20.0;
        final expanded = _isSpaceExpanded(space.id);

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredSpaceId = space.id),
          onExit: (_) => setState(() => _hoveredSpaceId = null),
          child: Card(
            elevation: expanded ? 4 : 1.5,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: expanded ? const Color(0xFF173B64) : const Color(0xFFE2E8F0),
                width: expanded ? 1.5 : 1.0,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _expandedSpaceId = (_expandedSpaceId == space.id) ? null : space.id;
                });
              },
              child: AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clean Summary Header Row (Always Visible)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 76,
                              height: 76,
                              child: space.imageUrl != null && space.imageUrl!.trim().isNotEmpty
                                  ? AppNetworkImage(
                                      imageUrl: space.imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: const Color(0xFFE2E8F0),
                                      child: const Icon(Icons.local_parking_rounded, color: Color(0xFF64748B), size: 32),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    FavoriteSpaceButton(
                                      parkingSpaceId: space.id,
                                      parkingSpaceName: space.name,
                                      iconSize: 19,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  space.address,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: space.isSoldOut
                                            ? const Color(0xFFFFE4E6)
                                            : (space.isClosed
                                                ? const Color(0xFFF1F5F9)
                                                : const Color(0xFFDCFCE7)),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        space.isSoldOut
                                            ? 'Sold Out'
                                            : (space.isClosed
                                                ? 'Closed'
                                                : '${space.availableSlotsCount} bays open'),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: space.isSoldOut
                                              ? const Color(0xFFBE123C)
                                              : (space.isClosed ? const Color(0xFF64748B) : const Color(0xFF16A34A)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        expanded ? 'Hide Details ▲' : 'Tap for Details & 2D Plan ▼',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF173B64),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₱${rate.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF173B64),
                                ),
                              ),
                              const Text(
                                'PER HR',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Cascading / Collapsible Details & 2D Floor Plan
                      if (expanded) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF0284C7)),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                space.operatingHours.isNotEmpty ? space.operatingHours : 'Open 24/7',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (space.supportedVehicles.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: space.supportedVehicles.map((v) {
                              final vRate = space.vehicleHourlyRates[v];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                                ),
                                child: Text(
                                  vRate != null ? '$v: ₱${vRate.toStringAsFixed(0)}/hr' : v,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 10),
                        _buildMini2DFloorPlan(space),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () => _openBookingScreen(space),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFDE70),
                                  foregroundColor: const Color(0xFF173B64),
                                  elevation: 1,
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'BOOK NOW',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => _openDirections(space),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              icon: const Icon(Icons.near_me_outlined, size: 14, color: Color(0xFF173B64)),
                              label: const Text(
                                'Directions',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF173B64)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => _openDetailsScreen(space),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              child: const Text(
                                'DETAILS',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}
