import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/active_trip_controller.dart';

class ActiveTripPage extends GetView<ActiveTripController> {
  const ActiveTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. CARTE GOOGLE MAPS
          Obx(() => GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                double.parse(controller.tripData['pickup_latitude'].toString()),
                double.parse(controller.tripData['pickup_longitude'].toString()),
              ),
              zoom: 14.5,
            ),
            onMapCreated: (mapC) => controller.mapController = mapC,
            markers: controller.markers,
            polylines: controller.polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            style: _googleMapStyle(theme.brightness == Brightness.dark),
          )),

          // 2. BANDEAU D'INSTRUCTION (FLOTTANT EN HAUT)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: _buildHeader(context),
          ),

          // 3. BOUTON D'ACTION (EN BAS)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildActionButton(context),
          ),
          
          // BOUTON DE RECENTRAGE
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton.small(
              onPressed: () {
                // Recentrer sur la voiture
              },
              backgroundColor: theme.cardColor,
              child: Icon(Icons.my_location, color: theme.primaryColor),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.navigation, color: Color(0xFF2E7D32), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => Text(
                  controller.instructionText,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                )),
                Obx(() => Text(
                  "${controller.tripData['pickup_address']}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, // Lancer Google Maps Externe
            icon: const Icon(Icons.map_outlined),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ElevatedButton(
        onPressed: () => controller.nextStep(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Obx(() => Text(
          controller.actionButtonText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
        )),
      ),
    );
  }

  String? _googleMapStyle(bool isDark) {
    if (!isDark) return null;
    return '''[
      {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
      {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
      {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
      {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
      {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#38414e"}]},
      {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212a37"}]},
      {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#9ca5b3"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#17263c"}]},
      {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#515c6d"}]},
      {"featureType": "water", "elementType": "labels.text.stroke", "stylers": [{"color": "#17263c"}]}
    ]''';
  }
}
