import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../model/driver_earning_model.dart';
import '../service/driver_history_service.dart';

class DriverEarningsPage extends StatefulWidget {
  const DriverEarningsPage({super.key});

  @override
  State<DriverEarningsPage> createState() => _DriverEarningsPageState();
}

class _DriverEarningsPageState extends State<DriverEarningsPage> {
  final _service = DriverHistoryService();
  List<DriverEarningModel> _trips = const [];
  int _weeklyRevenue = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trips = await _service.completedTrips();
    final weeklyRevenue = await _service.weeklyRevenue();
    if (!mounted) return;
    setState(() {
      _trips = trips;
      _weeklyRevenue = weeklyRevenue;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Gains chauffeur')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Résumé semaine',
                        style: GoogleFonts.inter(
                          color: AppColors.textSub(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_weeklyRevenue FCFA',
                        style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_trips.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Text(
                        'Aucune course terminée pour le moment.',
                        style: GoogleFonts.inter(
                          color: AppColors.textSub(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  ..._trips.map((trip) => _TripTile(trip: trip)),
              ],
            ),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip});

  final DriverEarningModel trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Row(
        children: [
          const Icon(Icons.two_wheeler_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.netAmountFCFA} FCFA net',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trip.distanceKm.toStringAsFixed(1)} km • ${trip.date.day}/${trip.date.month}/${trip.date.year}',
                  style: GoogleFonts.inter(
                    color: AppColors.textSub(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
