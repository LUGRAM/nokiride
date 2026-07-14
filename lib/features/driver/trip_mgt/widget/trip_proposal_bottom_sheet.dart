import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripProposalBottomSheet extends StatefulWidget {
  final String tripId;
  final String pickup;
  final String destination;
  final String earnings;
  final String distance;
  final int timeout;

  const TripProposalBottomSheet({
    super.key,
    required this.tripId,
    required this.pickup,
    required this.destination,
    required this.earnings,
    required this.distance,
    required this.timeout,
  });

  @override
  State<TripProposalBottomSheet> createState() => _TripProposalBottomSheetState();
}

class _TripProposalBottomSheetState extends State<TripProposalBottomSheet> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timeout),
    )..forward().then((_) {
      if (mounted) Get.back(); // Fermeture auto à la fin du timeout
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header avec Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "NOUVELLE COURSE",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.green),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) => CircularProgressIndicator(
                      value: 1 - _progressController.value,
                      strokeWidth: 3,
                      color: Colors.green,
                      backgroundColor: Colors.green.withOpacity(0.1),
                    ),
                  ),
                  Text("${widget.timeout}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              )
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Détails Trajet
          _buildLocationItem(Icons.circle_outlined, "Départ", widget.pickup, Colors.blue),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Container(width: 1, height: 20, color: theme.dividerColor),
          ),
          _buildLocationItem(Icons.location_on, "Arrivée", widget.destination, Colors.red),
          
          const Divider(height: 40),
          
          // Stats (Distance & Gains)
          Row(
            children: [
              _buildStat(Icons.directions_car_filled_outlined, "${widget.distance} km", "Distance"),
              const SizedBox(width: 20),
              _buildStat(Icons.account_balance_wallet_outlined, "${widget.earnings} XAF", "Gains nets"),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("IGNORER", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    // Logique d'acceptation à venir
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("ACCEPTER LA COURSE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(IconData icon, String label, String address, Color color) {
    return Row(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              Text(address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
