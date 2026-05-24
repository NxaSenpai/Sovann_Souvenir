import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mock_repository.dart';
import '../../models/branch.dart';
import '../../theme/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Branch? _selected;
  final repo = MockRepository.instance;

  @override
  Widget build(BuildContext context) {
    final branches = repo.branches;

    return Scaffold(
      appBar: AppBar(title: const Text('Shop Locations'),
        actions: [
          TextButton(onPressed: () => context.push('/nearby'), child: const Text('List View')),
        ],
      ),
      body: Stack(children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(12.0, 104.5),
            initialZoom: 7,
            onTap: (_, __) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.yourname.khmer_gift',
            ),
            MarkerLayer(
              markers: branches.map((b) => Marker(
                point: LatLng(b.lat, b.lng),
                width: 40, height: 40,
                child: GestureDetector(
                  onTap: () => setState(() => _selected = b),
                  child: const Icon(Icons.storefront, color: AppColors.gold, size: 36),
                ),
              )).toList(),
            ),
          ],
        ),

        // Bottom sheet for selected branch
        if (_selected != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Expanded(child: Text(_selected!.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _selected!.isOpenNow ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(_selected!.isOpenNow ? 'Open' : 'Closed',
                        style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(_selected!.address, style: const TextStyle(color: AppColors.warmGray, fontSize: 13)),
                Text(_selected!.openHours, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  onPressed: () async {
                    final uri = Uri.parse('https://www.google.com/maps?q=${_selected!.lat},${_selected!.lng}');
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}