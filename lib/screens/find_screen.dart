import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
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
  gmaps.GoogleMapController? _googleMapController;
  final _searchController = TextEditingController();

  late Future<List<ParkingSpace>> _spacesFuture;
  List<ParkingSpace> _allSpaces = const [];
  ParkingSpace? _selectedSpace;

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
  double _currentHeading = 0.0;
  bool _locationPermissionGranted = false;
  bool _mapReady = false;
  bool _showSearchHereButton = false;
  final Map<String, gmaps.BitmapDescriptor> _customMarkerBitmaps = {};

  @override
  void initState() {
    super.initState();
    FavoritesService.init();

    // Default Arrive: Today + 1 hour, Exit: Today + 2 hours
    final now = DateTime.now();
    _arriveDate = DateTime(now.year, now.month, now.day);
    _arriveTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);

    final exitDateTime = now.add(const Duration(hours: 2));
    _exitDate = DateTime(exitDateTime.year, exitDateTime.month, exitDateTime.day);
    _exitTime = TimeOfDay(hour: exitDateTime.hour, minute: 0);

    if (widget.initialSelectedSpace != null) {
      _selectedSpace = widget.initialSelectedSpace;
    }

    _loadSpaces();
    _checkLocationServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  void _loadSpaces() {
    _spacesFuture = widget.loadParkingSpaces().then((spaces) {
      if (!mounted) return spaces;
      setState(() {
        _allSpaces = spaces;
      });
      _preloadMarkerBitmaps(spaces);
      return spaces;
    });
  }

  Future<void> _preloadMarkerBitmaps(List<ParkingSpace> spaces) async {
    final futures = <Future<void>>[];
    for (final space in spaces) {
      final rate = space.getEffectiveRate(vehicleType: _selectedVehicleType);

      // Unselected state
      futures.add(
        MarkerBitmapGenerator.getPriceMarker(
          price: rate,
          isAvailable: space.isAvailable,
          isSelected: false,
        ).then((bitmap) {
          _customMarkerBitmaps['${space.id}_false'] = bitmap;
        }),
      );

      // Selected state
      futures.add(
        MarkerBitmapGenerator.getPriceMarker(
          price: rate,
          isAvailable: space.isAvailable,
          isSelected: true,
        ).then((bitmap) {
          _customMarkerBitmaps['${space.id}_true'] = bitmap;
        }),
      );
    }

    try {
      await Future.wait(futures);
      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
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
        _currentHeading = pos.heading;
      });

      if (animateCamera && _mapReady && _googleMapController != null) {
        _googleMapController!.animateCamera(
          gmaps.CameraUpdate.newCameraPosition(
            gmaps.CameraPosition(
              target: gmaps.LatLng(point.latitude, point.longitude),
              zoom: 15.0,
            ),
          ),
        );
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

    return targetList.where((space) {
      if (_onlyFavorites && !favIds.contains(space.id)) {
        return false;
      }

      if (query.isNotEmpty) {
        final nameMatch = space.name.toLowerCase().contains(query);
        final addrMatch = space.address.toLowerCase().contains(query);
        if (!nameMatch && !addrMatch) return false;
      }

      if (vehicle.isNotEmpty && vehicle != 'all') {
        final supportsVehicle = space.supportedVehicles.any(
          (v) => v.trim().toLowerCase().contains(vehicle),
        );
        if (!supportsVehicle) return false;
      }

      return true;
    }).toList();
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
    _preloadMarkerBitmaps(_allSpaces);
    final count = _getFilteredSpaces().length;
    _showToast('Filters applied: $count parking space${count == 1 ? '' : 's'} available');
    if (_selectedSpace != null && !_getFilteredSpaces().contains(_selectedSpace)) {
      setState(() => _selectedSpace = null);
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

  Set<gmaps.Marker> _buildMarkers(List<ParkingSpace> spaces) {
    final markers = <gmaps.Marker>{};

    // Driver Live GPS Marker
    if (_currentLocation != null) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('driver_live_gps'),
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
          infoWindow: const gmaps.InfoWindow(title: 'You are here'),
        ),
      );
    }

    // Parking spaces markers
    for (final space in spaces) {
      final pt = _pointFor(space);
      if (pt == null) continue;

      final isSelected = _selectedSpace?.id == space.id;
      final rate = space.getEffectiveRate(vehicleType: _selectedVehicleType);
      final cacheKey = '${space.id}_$isSelected';
      final customIcon = _customMarkerBitmaps[cacheKey] ??
          MarkerBitmapGenerator.getCachedMarker(
            price: rate,
            isAvailable: space.isAvailable,
            isSelected: isSelected,
          );

      markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId('space_${space.id}'),
          position: gmaps.LatLng(pt.latitude, pt.longitude),
          anchor: customIcon != null
              ? MarkerBitmapGenerator.getMarkerAnchor()
              : const Offset(0.5, 1.0),
          icon: customIcon ??
              (space.isAvailable
                  ? (isSelected
                      ? gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueYellow)
                      : gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueCyan))
                  : gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed)),
          infoWindow: gmaps.InfoWindow(
            title: space.name,
            snippet: '₱${rate % 1 == 0 ? rate.toInt() : rate.toStringAsFixed(1)}/hr • ${space.availableSlotsCount} slots free',
          ),
          onTap: () {
            setState(() {
              _selectedSpace = space;
            });
            _googleMapController?.animateCamera(
              gmaps.CameraUpdate.newLatLng(
                gmaps.LatLng(pt.latitude, pt.longitude),
              ),
            );
          },
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A4C), // Brand Deep Navy from Web screenshot
        boxShadow: [
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
              // Search text input
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF28495D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF475569)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFF43F5E), // Rose pin icon from web
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Address, Place or Event...',
                            hintStyle: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF94A3B8),
                            size: 18,
                          ),
                        )
                      else
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFFCBD5E1),
                          size: 20,
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
                        color: _onlyFavorites ? const Color(0xFFFFDE70) : const Color(0xFF28495D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _onlyFavorites ? const Color(0xFFFFDE70) : const Color(0xFF475569),
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
                  color: const Color(0xFF28495D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF475569)),
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
                      color: const Color(0xFF28495D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF475569)),
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
                      color: const Color(0xFF28495D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF475569)),
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
                    color: const Color(0xFF28495D),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF475569)),
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
                          dropdownColor: const Color(0xFF1E3A4C),
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
                            _preloadMarkerBitmaps(_allSpaces);
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
    return gmaps.GoogleMap(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(
          _currentLocation?.latitude ?? _fallbackCenter.latitude,
          _currentLocation?.longitude ?? _fallbackCenter.longitude,
        ),
        zoom: 13.8,
      ),
      onMapCreated: (ctrl) {
        _googleMapController = ctrl;
        _mapReady = true;
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      onCameraMove: (pos) {
        if (!_showSearchHereButton) {
          setState(() => _showSearchHereButton = true);
        }
      },
      onTap: (_) {
        if (_selectedSpace != null) {
          setState(() => _selectedSpace = null);
        }
      },
      markers: _buildMarkers(spaces),
    );
  }

  // ---------------------------------------------------------------------------
  // Selected Space Bottom Preview Card (Matches Screenshot 2)
  // ---------------------------------------------------------------------------
  Widget _buildSelectedSpaceCard(ParkingSpace space) {
    final dist = _distanceFor(space);
    final total = _calculateEstimatedTotal(space);
    final hours = _calculateDurationHours();

    return Container(
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

          // Main Card Content: Photo + Title + Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: space.imageUrl != null && space.imageUrl!.trim().isNotEmpty
                      ? AppNetworkImage(
                          imageUrl: space.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(Icons.local_parking_rounded, color: Color(0xFF64748B), size: 36),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Info & Details
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
                              fontSize: 16,
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
                    // Ratings, Distance, Slots
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 15),
                        const SizedBox(width: 2),
                        const Text(
                          '4.8',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        if (dist != null) ...[
                          const Icon(Icons.directions_walk_rounded, color: Color(0xFF64748B), size: 14),
                          Text(
                            formatParkingDistance(dist),
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${space.availableSlotsCount} slots free',
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w800,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons: Book CTA + Directions & Details
          Row(
            children: [
              // Big CTA Button: "Book for ₱..."
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () => _openBookingScreen(space),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981), // Emerald CTA like Screenshot 2
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Book for ₱${total.toStringAsFixed(2)} ($hours hr${hours > 1 ? 's' : ''})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Directions button
              OutlinedButton(
                onPressed: () => _openDirections(space),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                child: const Icon(Icons.directions_rounded, color: Color(0xFF173B64), size: 18),
              ),
              const SizedBox(width: 8),

              // Details button
              OutlinedButton(
                onPressed: () => _openDetailsScreen(space),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
    );
  }

  // ---------------------------------------------------------------------------
  // Grid / List View (Matches Screenshot 3 Left Side)
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

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Image + Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 95,
                        height: 95,
                        child: space.imageUrl != null && space.imageUrl!.trim().isNotEmpty
                            ? AppNetworkImage(
                                imageUrl: space.imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFFE2E8F0),
                                child: const Icon(Icons.local_parking_rounded, color: Color(0xFF64748B), size: 36),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Details
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
                                iconSize: 20,
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
                              Text(
                                'from ₱${rate.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF173B64),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'PER HOUR',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${space.availableSlotsCount} bays open • ${space.operatingHours.isNotEmpty ? space.operatingHours : "Open 24/7"}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Vehicle types chips
                if (space.supportedVehicles.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: space.supportedVehicles.map((v) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                        ),
                        child: Text(
                          v,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 10),

                // Action Buttons: BOOK NOW, Directions, DETAILS
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _openBookingScreen(space),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFDE70), // Naples Gold button from web
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
