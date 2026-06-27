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
import '../../l10n/generated/app_localizations.dart';

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
          if (mounted) setState(() { _locationLoading = false; _locationError = true; });
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(pos.latitude, pos.longitude);
          _locationLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _locationLoading = false; _locationError = true; });
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
        final l10n = AppLocalizations.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final branches = repo.branchesTr;
        final selected = ref.watch(selectedBranchProvider);
        final searchQuery = ref.watch(searchQueryProvider);
        final filterOpenOnly = ref.watch(filterOpenOnlyProvider);

        var filtered = branches.where((b) {
          if (searchQuery.isNotEmpty &&
              !b.name.toLowerCase().contains(searchQuery.toLowerCase())) return false;
          if (filterOpenOnly && !b.isOpenNow) return false;
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: SizedBox(
              height: 38,
              child: TextField(
                onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: l10n.searchBranches,
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: FilterChip(
                  label: Text(l10n.openNow, style: const TextStyle(fontSize: 12)),
                  selected: filterOpenOnly,
                  onSelected: (v) => ref.read(filterOpenOnlyProvider.notifier).state = v,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.view_list),
                onPressed: () => context.push('/nearby'),
                tooltip: l10n.listView,
              ),
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: _currentPosition ?? const LatLng(12.0, 104.5),
                  initialZoom: _currentPosition != null ? 12 : 7,
                  onTap: (_, __) =>
                      ref.read(selectedBranchProvider.notifier).state = null,
                ),
                children: [
                  TileLayer(
                    urlTemplate: isDark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    userAgentPackageName: 'com.yourname.khmer_gift',
                  ),
                  MarkerLayer(
                    markers: [
                      if (_currentPosition != null)
                        Marker(
                          point: _currentPosition!,
                          width: 40, height: 40,
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(30),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: const Icon(Icons.my_location, color: Colors.blue, size: 16),
                          ),
                        ),
                      ...filtered.map((b) {
                        final isSelected = selected?.id == b.id;
                        return Marker(
                          point: LatLng(b.lat, b.lng),
                          width: 120, height: 50,
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(selectedBranchProvider.notifier).state = b;
                              mapController.move(LatLng(b.lat, b.lng), 15);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Name label
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurface : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(isDark ? 80 : 30),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    b.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isDark ? AppColors.cream : AppColors.charcoal,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                // Dot
                                Container(
                                  width: isSelected ? 16 : 12,
                                  height: isSelected ? 16 : 12,
                                  decoration: BoxDecoration(
                                    color: b.isOpenNow ? Colors.green : Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.gold : Colors.white,
                                      width: isSelected ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(60),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
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

              // Location loading
              if (_locationLoading)
                Positioned(
                  top: 12, right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 6)],
                    ),
                    child: const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                    ),
                  ),
                ),

              // Location button
              Positioned(
                right: 16,
                bottom: selected != null ? 260 : 32,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.my_location,
                      color: _currentPosition != null ? Colors.blue : Colors.grey,
                    ),
                    onPressed: _currentPosition != null
                        ? () => mapController.move(_currentPosition!, 14)
                        : _locationError ? _initLocation : null,
                  ),
                ),
              ),

              // Branch detail sheet
              if (selected != null)
                _BranchSheet(
                  key: ValueKey(selected!.id),
                  branch: selected!,
                  isDark: isDark,
                  onClose: () => ref.read(selectedBranchProvider.notifier).state = null,
                  onNavigate: () => mapController.move(LatLng(selected!.lat, selected!.lng), 15),
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
  final bool isDark;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const _BranchSheet({
    super.key,
    required this.branch,
    required this.isDark,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black54 : Colors.black26,
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header row: image + name + status + close
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (branch.imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: branch.imageUrl,
                        width: 56, height: 56,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 56, height: 56,
                          color: isDark ? AppColors.darkCard : Colors.grey.shade200,
                          child: const Icon(Icons.store, color: Colors.grey),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 56, height: 56,
                          color: isDark ? AppColors.darkCard : Colors.grey.shade200,
                          child: const Icon(Icons.store, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: isDark ? AppColors.cream : AppColors.charcoal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          RatingStars(rating: branch.rating, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            '${branch.rating.toStringAsFixed(1)}  ·  ${branch.distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: branch.isOpenNow ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      branch.isOpenNow ? l10n.open : l10n.closed,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 14,
                          color: isDark ? Colors.grey.shade400 : AppColors.charcoal),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(color: isDark ? AppColors.darkCard : Colors.grey.shade200, height: 1),

              // Info rows
              const SizedBox(height: 10),
              _InfoRow(icon: Icons.location_on_outlined, text: branch.address, isDark: isDark),
              if (branch.phone.isNotEmpty) ...[
                const SizedBox(height: 6),
                _InfoRow(icon: Icons.phone_outlined, text: branch.phone, isDark: isDark),
              ],
              const SizedBox(height: 6),
              _InfoRow(icon: Icons.access_time_outlined, text: branch.openHours, isDark: isDark),

              const SizedBox(height: 16),
              // Action buttons
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.near_me, size: 16),
                    label: Text(l10n.center),
                    onPressed: onNavigate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(color: AppColors.gold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.directions_outlined, size: 16),
                    label: Text(l10n.directions),
                    onPressed: () async {
                      final uri = Uri.parse(
                        'https://www.google.com/maps/dir/?api=1&destination=${branch.lat},${branch.lng}',
                      );
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: bottomPad),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _InfoRow({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15,
            color: isDark ? AppColors.goldLight : AppColors.gold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.cream.withAlpha(180) : AppColors.warmGray,
            ),
          ),
        ),
      ],
    );
  }
}
