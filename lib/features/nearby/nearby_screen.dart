import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mock_repository.dart';
import '../../models/branch.dart';
import '../../theme/app_colors.dart';
import '../../widgets/rating_stars.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});
  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  bool _openOnly = false;
  String _sort = 'distance';

  @override
  Widget build(BuildContext context) {
    List<Branch> branches = MockRepository.instance.branches;
    if (_openOnly) branches = branches.where((b) => b.isOpenNow).toList();
    if (_sort == 'distance') branches.sort((a, b) => a.distance.compareTo(b.distance));
    if (_sort == 'rating')   branches.sort((a, b) => b.rating.compareTo(a.rating));

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Shops')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            FilterChip(label: const Text('Open Now'), selected: _openOnly, onSelected: (v) => setState(() => _openOnly = v)),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Distance'), selected: _sort == 'distance', onSelected: (_) => setState(() => _sort = 'distance')),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Rating'), selected: _sort == 'rating', onSelected: (_) => setState(() => _sort = 'rating')),
          ]),
        ),
        Expanded(child: ListView.builder(
          itemCount: branches.length,
          itemBuilder: (context, i) {
            final b = branches[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: CachedNetworkImage(imageUrl: b.imageUrl, width: 90, height: 90, fit: BoxFit.cover),
                ),
                Expanded(child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: b.isOpenNow ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(b.isOpenNow ? 'Open' : 'Closed',
                            style: TextStyle(color: b.isOpenNow ? Colors.green : Colors.red, fontSize: 10)),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    Text(b.address, style: const TextStyle(color: AppColors.warmGray, fontSize: 12)),
                    Text(b.openHours, style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    Row(children: [
                      RatingStars(rating: b.rating, size: 12),
                      const SizedBox(width: 8),
                      Text('${b.distance < 1 ? "${(b.distance * 1000).round()}m" : "${b.distance.toStringAsFixed(0)}km"} away',
                          style: const TextStyle(fontSize: 11, color: AppColors.warmGray)),
                    ]),
                  ]),
                )),
                IconButton(
                  icon: const Icon(Icons.directions, color: AppColors.gold),
                  onPressed: () async {
                    final uri = Uri.parse('https://www.google.com/maps?q=${b.lat},${b.lng}');
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                ),
              ]),
            );
          },
        )),
      ]),
    );
  }
}