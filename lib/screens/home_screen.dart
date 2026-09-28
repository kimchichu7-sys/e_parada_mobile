import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../models/driver_reservation.dart';
import '../models/parking_space.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../services/offline_parking_pass_service.dart';
import '../services/reservation_service.dart';
import '../widgets/app_network_image.dart';
import '../widgets/favorite_space_button.dart';
import '../widgets/image_preview_dialog.dart';
import '../widgets/notification_action_button.dart';
import '../widgets/offline_parking_pass_dialog.dart';
import '../widgets/reservation_credential_dialog.dart';
import 'interactive_map_screen.dart';
import 'parking_details_screen.dart';
import 'reservations_screen.dart';
import 'reserve_parking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  late Future<List<ParkingSpace>> _parkingSpaces;
  Future<List<DriverReservation>>? _activeReservations;
  String _query = '';
  String _selectedVehicle = 'All';

  static const _vehicleFilters = [
    {'key': 'All', 'label': 'All Types', 'icon': Icons.grid_view_rounded},
    {'key': 'Car', 'label': 'Cars', 'icon': Icons.directions_car_rounded},
    {
      'key': 'Motorcycle',
      'label': 'Motorcycles',
      'icon': Icons.two_wheeler_rounded,
    },
    {'key': 'Van', 'label': 'Vans / SUVs', 'icon': Icons.airport_shuttle_rounded},
  ];

  @override
  void initState() {
    super.initState();
    FavoritesService.init();
    _parkingSpaces = ApiService.fetchParkingSpaces();
    _activeReservations = _fetchActiveReservations();
  }

  Future<List<DriverReservation>> _fetchActiveReservations() async {
    try {
      final list = await ReservationService.fetchReservations();
      await OfflineParkingPassService.cacheReservations(list);
      return list;
    } catch (_) {
      return <DriverReservation>[];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final spacesRequest = ApiService.fetchParkingSpaces();
    final resRequest = _fetchActiveReservations();
    setState(() {
      _parkingSpaces = spacesRequest;
      _activeReservations = resRequest;
    });
    await Future.wait([spacesRequest, resRequest]);
  }

  DriverReservation? _extractActiveReservation(
    List<DriverReservation>? reservations,
  ) {
    if (reservations == null || reservations.isEmpty) return null;
    try {
      return reservations.firstWhere(
        (r) =>
            (r.timeIn != null && r.timeOut == null) ||
            (r.status == 'approved' && r.hasCredential),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Parada'),
        actions: [const NotificationActionButton()],
      ),
      body: FutureBuilder<List<ParkingSpace>>(
        future: _parkingSpaces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final allSpaces = snapshot.data ?? const <ParkingSpace>[];
          final normalizedQuery = _query.toLowerCase();
          final spaces = allSpaces.where((space) {
            final matchesQuery =
                normalizedQuery.isEmpty ||
                space.name.toLowerCase().contains(normalizedQuery) ||
                space.address.toLowerCase().contains(normalizedQuery);
            final matchesVehicle =
                _selectedVehicle == 'All' ||
                space.supportedVehicles.any(
                  (v) =>
                      v.toLowerCase().contains(_selectedVehicle.toLowerCase()),
                );
            return matchesQuery && matchesVehicle;
          }).toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Active Parking Pass Banner (if ongoing/approved reservation exists)
                        if (_activeReservations != null)
                          FutureBuilder<List<DriverReservation>>(
                            future: _activeReservations,
                            builder: (context, resSnapshot) {
                              final active = _extractActiveReservation(
                                resSnapshot.data,
                              );
                              if (active == null) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: _ActiveReservationBanner(
                                  reservation: active,
                                  onRefresh: _refresh,
                                ),
                              );
                            },
                          ),

                        Text(
                          'Find your next parking spot',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${allSpaces.length} approved spaces available from E-Parada.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),

                        // Search Input
                        TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _query = value.trim()),
                          decoration: InputDecoration(
                            hintText: 'Search by name or address',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Vehicle Type Quick Filters
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _vehicleFilters.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final filter = _vehicleFilters[index];
                              final isSelected =
                                  _selectedVehicle == filter['key'];
                              return FilterChip(
                                selected: isSelected,
                                showCheckmark: false,
                                avatar: Icon(
                                  filter['icon'] as IconData,
                                  size: 16,
                                  color: isSelected
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onPrimary
                                      : null,
                                ),
                                label: Text(filter['label'] as String),
                                labelStyle: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onPrimary
                                      : null,
                                ),
                                selectedColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                onSelected: (_) {
                                  setState(
                                    () => _selectedVehicle =
                                        filter['key'] as String,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Saved / Favorite Spaces Carousel
                        _SavedSpacesCarousel(spaces: allSpaces),
                      ],
                    ),
                  ),
                ),
                if (spaces.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _query.isEmpty && _selectedVehicle == 'All'
                              ? 'No parking spaces are available right now.'
                              : 'No parking spaces match your search and filter criteria.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.crossAxisExtent >= 800
                            ? 2
                            : 1;
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                mainAxisExtent: 390,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _ParkingSpaceCard(space: spaces[index]),
                            childCount: spaces.length,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActiveReservationBanner extends StatelessWidget {
  const _ActiveReservationBanner({
    required this.reservation,
    required this.onRefresh,
  });

  final DriverReservation reservation;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isCurrentlyParked =
        reservation.timeIn != null && reservation.timeOut == null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentlyParked
              ? const [Color(0xFF065F46), Color(0xFF047857)]
              : const [Color(0xFF3730A3), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (isCurrentlyParked
                    ? const Color(0xFF059669)
                    : const Color(0xFF4F46E5))
                .withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isCurrentlyParked
                        ? Icons.local_parking_rounded
                        : Icons.confirmation_number_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCurrentlyParked
                        ? 'CURRENTLY PARKED'
                        : 'ACTIVE PARKING PASS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  reservation.backupReference,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reservation.parkingSpaceName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${reservation.slotLabel} • ${reservation.plateNumber} (${reservation.vehicleType})',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reservation.scheduleLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (reservation.hasCredential)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isCurrentlyParked
                        ? const Color(0xFF065F46)
                        : const Color(0xFF3730A3),
                    elevation: 0,
                  ),
                  onPressed: () {
                    showReservationCredentialDialog(
                      context: context,
                      qrCode: reservation.qrCode,
                      backupReference: reservation.backupReference,
                      parkingSpaceName: reservation.parkingSpaceName,
                    );
                  },
                  icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                  label: const Text(
                    'QR Pass',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () {
                  OfflineParkingPassDialog.show(
                    context,
                    OfflinePassData.fromDriverReservation(reservation),
                  );
                },
                icon: const Icon(Icons.cloud_off_rounded, size: 16),
                label: const Text(
                  'Offline Pass',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReservationsScreen(),
                    ),
                  ).then((_) => onRefresh());
                },
                child: const Text('My Bookings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedSpacesCarousel extends StatelessWidget {
  const _SavedSpacesCarousel({required this.spaces});

  final List<ParkingSpace> spaces;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: FavoritesService.favoritesNotifier,
      builder: (context, favoriteIds, _) {
        if (favoriteIds.isEmpty) {
          return const SizedBox.shrink();
        }

        final saved = spaces.where((s) => favoriteIds.contains(s.id)).toList();
        if (saved.isEmpty) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Saved Spaces (${saved.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 115,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: saved.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final space = saved[index];
                  return InkWell(
                    onTap: () {
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
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: colors.surfaceContainerHighest,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: space.imageUrl != null && space.imageUrl!.trim().isNotEmpty
                                ? AppNetworkImage(
                                    imageUrl: space.imageUrl!,
                                    fit: BoxFit.cover,
                                    fallbackWidget: Icon(
                                      Icons.local_parking_rounded,
                                      color: colors.primary,
                                    ),
                                  )
                                : Icon(Icons.local_parking_rounded, color: colors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  space.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  space.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      space.price,
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                    if (space.latitude != null && space.longitude != null)
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MapScreen(
                                                focusedParkingSpaceId: space.id,
                                                initialSelectedSpace: space,
                                                startNavigationMode: true,
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          child: Icon(
                                            Icons.directions_rounded,
                                            color: colors.primary,
                                            size: 18,
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
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _ParkingSpaceCard extends StatelessWidget {
  const _ParkingSpaceCard({required this.space});

  final ParkingSpace space;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: space.imageUrl != null && space.imageUrl!.trim().isNotEmpty
                          ? () => ImagePreviewDialog.show(
                                context,
                                imageUrl: space.imageUrl!,
                                title: space.name,
                              )
                          : null,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (space.imageUrl == null || space.imageUrl!.trim().isEmpty)
                              Icon(
                                Icons.local_parking_rounded,
                                size: 52,
                                color: colors.primary,
                              )
                            else
                              AppNetworkImage(
                                imageUrl: space.imageUrl!,
                                fit: BoxFit.cover,
                                fallbackWidget: Icon(
                                  Icons.local_parking_rounded,
                                  size: 52,
                                  color: colors.primary,
                                ),
                                loadingWidget: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            if (space.imageUrl != null && space.imageUrl!.trim().isNotEmpty)
                              Positioned(
                                right: 6,
                                bottom: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.zoom_in, color: Colors.white, size: 12),
                                      SizedBox(width: 3),
                                      Text(
                                        'Zoom',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bookmark / Favorite Star Button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: FavoriteSpaceButton(
                      parkingSpaceId: space.id,
                      parkingSpaceName: space.name,
                      showBackground: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    space.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(
                    Icons.circle,
                    size: 10,
                    color: space.isOpenNow ? Colors.green : colors.error,
                  ),
                  label: Text(space.status),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(space.address, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    space.operatingHours,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  space.price,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (space.latitude != null && space.longitude != null) ...[
                  IconButton.outlined(
                    tooltip: 'Get directions',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapScreen(
                            focusedParkingSpaceId: space.id,
                            initialSelectedSpace: space,
                            startNavigationMode: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions_rounded, size: 20),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton(
                  onPressed: () {
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
                  },
                  child: const Text('Details'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.yaleBlue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReserveParkingScreen(
                            parkingSpaceId: space.id,
                            parkingName: space.name,
                            address: space.address,
                            price: space.price,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bolt_rounded, size: 16, color: AppPalette.naplesYellow),
                    label: const Text('Quick Rebook'),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 54,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load parking spaces',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              SelectableText(
                ApiConfig.baseUrl,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
