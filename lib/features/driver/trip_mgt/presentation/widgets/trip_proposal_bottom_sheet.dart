import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../core/network/api_client.dart';

class TripProposalBottomSheet extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const TripProposalBottomSheet({
    super.key,
    required this.tripData,
  });

  @override
  State<TripProposalBottomSheet> createState() => _TripProposalBottomSheetState();
}

class _TripProposalBottomSheetState extends State<TripProposalBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isProcessing = false;

  String get tripId => widget.tripData['trip_id']?.toString() ?? '';
  String get pickup => widget.tripData['pickup_address'] ?? 'Position actuelle';
  String get destination => widget.tripData['destination_address'] ?? 'Destination inconnue';
  String get earnings => widget.tripData['estimated_earnings']?.toString() ?? '0';
  String get distance => widget.tripData['distance_km']?.toString() ?? '0';
  int get timeout => widget.tripData['timeout_seconds'] ?? 15;

  @override
  void initState() {
    super.initState();
    
    // Vibration pour capter l'attention du chauffeur
    HapticFeedback.heavyImpact();

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: timeout),
    );

    _progressController.reverse(from: 1.0).then((_) {
      if (mounted && !_isProcessing) {
        _autoReject();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _autoReject() async {
    try {
      await ApiClient.instance.post('/trips/$tripId/reject', data: {'reason': 'timeout'});
    } finally {
      if (Get.isBottomSheetOpen ?? false) Get.back();
    }
  }

  Future<void> _handleReject() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await ApiClient.instance.post('/trips/$tripId/reject', data: {'reason': 'manual_reject'});
    } finally {
      if (mounted) Get.back();
    }
  }

  Future<void> _handleAccept() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    
    try {
      final response = await ApiClient.instance.post('/trips/$tripId/accept');
      
      if (response['status'] == 'success') {
        if (mounted) {
          Get.back(); // Ferme le BottomSheet
          // Redirection vers la page du trajet actif avec les données reçues
          Get.toNamed('/driver/active-trip', arguments: response['trip']);
        }
      } else {
        _handleAcceptError(response['error'] ?? "Impossible d'accepter la course.");
      }
    } catch (e) {
      // Gestion spécifique des erreurs HTTP (ex: 410 Gone de Laravel)
      if (e.toString().contains('410') || e.toString().contains('409')) {
        _handleAcceptError("Désolé, un autre chauffeur a accepté cette course plus rapidement.");
      } else {
        setState(() => _isProcessing = false); // Réactive les boutons pour erreur réseau
        Get.snackbar(
          "Erreur", 
          "Problème de connexion. Veuillez réessayer.",
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  void _handleAcceptError(String message) {
    if (!mounted) return;
    
    setState(() => _isProcessing = false);
    
    // Affichage d'un message d'erreur visuel
    Get.snackbar(
      "Course indisponible",
      message,
      backgroundColor: Colors.orange.shade800,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.timer_off, color: Colors.white),
    );

    // Fermeture automatique après un court délai pour revenir au mode recherche
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isBottomSheetOpen ?? false) Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false, // Bloque le bouton retour physique
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Timer & Titre
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "OFFRE DE COURSE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) => CircularProgressIndicator(
                        value: _progressController.value,
                        strokeWidth: 4,
                        color: _progressController.value < 0.3 ? Colors.red : const Color(0xFF2E7D32),
                        backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                      ),
                    ),
                    Text(
                      "${(timeout * _progressController.value).ceil()}",
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ],
                )
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Gain estimé
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Gain : ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "$earnings FCFA",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Adresses
            _buildRouteTimeline(pickup, destination, isDark),
            
            const SizedBox(height: 24),
            
            // Distance
            Row(
              children: [
                const Icon(Icons.directions_car, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Distance : $distance km",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            if (_isProcessing)
              const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            else
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _handleReject,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                      ),
                      child: const Text(
                        "REFUSER",
                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        "ACCEPTER",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteTimeline(String from, String to, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.radio_button_checked, size: 20, color: Color(0xFF2E7D32)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                from,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 9),
          child: Container(
            width: 2,
            height: 24,
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.location_on, size: 20, color: Colors.redAccent),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                to,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
