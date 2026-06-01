import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/mock_repository.dart';
import '../../models/branch.dart';
import '../../state/map_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/rating_stars.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapController = MapController();
  final repo = MockRepository.instance;
  LatLng? _currentPosition;
  bool _locationLoading = true;
  bool _locationError = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          if (mounted) {
            setState(() {
              _locationLoading = false;
              _locationError = true;
            });
          }
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(pos.latitude, pos.longitude);
          _locationLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationLoading = false;
          _locationError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final branches = repo.branches;
        final selected = ref.watch(selectedBranchProvider);
        final searchQuery = ref.watch(searchQueryProvider);
        final filterOpenOnly = ref.watch(filterOpenOnlyProvider);

        var filteredBranches = branches.where((b) {
          if (searchQuery.isNotEmpty &&
              !b.name.toLowerCase().contains(searchQuery.toLowerCase())) {
            return false;
          }
          if (filterOpenOnly && !b.isOpenNow) return false;
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: SizedBox(
              height: 38,
              child: TextField(
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Search branches...',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: FilterChip(
                  label: const Text('Open', style: TextStyle(fontSize: 12)),
                  selected: filterOpenOnly,
                  onSelected: (v) =>
                      ref.read(filterOpenOnlyProvider.notifier).state = v,
                  visualDensity: VisualDensity.compact,
                  selectedColor: Colors.green.shade100,
                  checkmarkColor: Colors.green,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.view_list),
                onPressed: () => context.push('/nearby'),
                tooltip: 'List view',
              ),
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter:
                      _currentPosition ?? const LatLng(12.0, 104.5),
                  initialZoom: _currentPosition != null ? 12 : 7,
                  onTap: (_, __) =>
                      ref.read(selectedBranchProvider.notifier).state = null,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    userAgentPackageName: 'com.yourname.khmer_gift',
                  ),
                  MarkerLayer(
                    markers: [
                      if (_currentPosition != null)
                        Marker(
                          point: _currentPosition!,
                          width: 32,
                          height: 32,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 32,
                          ),
                        ),
                      ...filteredBranches.map((b) {
                        final isSelected = selected?.id == b.id;
                        final circleSize = isSelected ? 36.0 : 28.0;
                        return Marker(
                          point: LatLng(b.lat, b.lng),
                          width: isSelected ? 170 : 150,
                          height: isSelected ? 90 : 80,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(selectedBranchProvider.notifier).state =
                                  b;
                              mapController.move(LatLng(b.lat, b.lng), 15);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    b.name,
                                    style: TextStyle(
                                      fontSize: isSelected ? 15 : 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: circleSize,
                                  height: circleSize,
                                  decoration: BoxDecoration(
                                    color: b.isOpenNow
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFC62828),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.gold
                                          : Colors.white,
                                      width: isSelected ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    b.isOpenNow
                                        ? Icons.store
                                        : Icons.store_mall_directory,
                                    color: Colors.white,
                                    size: isSelected ? 20 : 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),

              if (_locationLoading)
                const Positioned(
                  top: 12,
                  right: 16,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: selected != null
                    ? _BranchSheet(
                        key: ValueKey(selected.id),
                        branch: selected,
                        onClose: () => ref
                            .read(selectedBranchProvider.notifier)
                            .state = null,
                        onNavigate: () => mapController
                            .move(LatLng(selected.lat, selected.lng), 15),
                      )
                    : const SizedBox.shrink(),
              ),

              Positioned(
                right: 16,
                bottom: selected != null ? 280 : 32,
                child: FloatingActionButton.small(
                  heroTag: 'myLocation',
                  onPressed: _currentPosition != null
                      ? () => mapController.move(_currentPosition!, 14)
                      : _locationError ? _initLocation : null,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.my_location,
                    color: _currentPosition != null ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BranchSheet extends StatelessWidget {
  final Branch branch;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const _BranchSheet({
    super.key,
    required this.branch,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (branch.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: branch.imageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.store, color: Colors.grey),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.store, color: Colors.grey),
                      ),
                    ),
                  ),
                if (branch.imageUrl.isNotEmpty) const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              branch.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: branch.isOpenNow
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              branch.isOpenNow ? 'Open' : 'Closed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          RatingStars(rating: branch.rating, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            branch.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.near_me,
                              size: 13, color: Colors.grey.shade600),
                          const SizedBox(width: 3),
                          Text(
                            '${branch.distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    branch.address,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (branch.phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    branch.phone,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  branch.openHours,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.near_me, size: 16),
                    label: const Text('Center'),
                    onPressed: onNavigate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Directions'),
                    onPressed: () async {
                      final uri = Uri.parse(
                        'https://www.google.com/maps/dir/?api=1&destination=${branch.lat},${branch.lng}',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
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
