import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../dashboard/widget/driver_bottom_nav.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.slate950 : AppColors.bgLight;
    final surfaceColor = isDark ? AppColors.slate900 : AppColors.bgLightSurface;
    final borderColor = isDark ? AppColors.slateDivider : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Revenus Partenaire',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _WeeklySummaryCard(
                            amount: _weeklyRevenue,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _RevenueTypeSmall(
                                label: 'COURSES',
                                amount: (_weeklyRevenue * 0.7).round(),
                                icon: FontAwesomeIcons.motorcycle,
                                color: AppColors.success,
                                isDark: isDark,
                              ),
                              _RevenueTypeSmall(
                                label: 'LIVRAISONS',
                                amount: (_weeklyRevenue * 0.3).round(),
                                icon: FontAwesomeIcons.box,
                                color: Colors.orange,
                                isDark: isDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Activité hebdomadaire',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSub(context),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _PerformanceChart(trips: _trips, isDark: isDark),
                          const SizedBox(height: 32),
                          Text(
                            'Historique récent',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  if (_trips.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'Aucune activité enregistrée',
                          style: GoogleFonts.inter(
                            color: AppColors.textSub(context),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: _TripTile(trip: _trips[index], isDark: isDark),
                        ),
                        childCount: _trips.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
      bottomNavigationBar: const DriverBottomNav(),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.amount, required this.isDark});
  final int amount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.slateDivider : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL NET SEMAINE',
            style: GoogleFonts.inter(
              color: AppColors.textSub(context),
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${NumberFormat('#,###').format(amount)} FCFA',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.success, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+12.4%',
                      style: GoogleFonts.inter(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'vs semaine passée',
                style: GoogleFonts.inter(
                  color: AppColors.textSub(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueTypeSmall extends StatelessWidget {
  const _RevenueTypeSmall({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isDark,
  });
  final String label;
  final int amount;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.slateDivider : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 16, color: color),
          const SizedBox(height: 12),
          Text(
            '${NumberFormat('#,###').format(amount)} F',
            style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSub(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceChart extends StatelessWidget {
  const _PerformanceChart({required this.trips, required this.isDark});
  final List<DriverEarningModel> trips;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.slateDivider : AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final heights = [40, 65, 30, 85, 55, 100, 75];
          final h = heights[index];
          final isToday = index == 5;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${(h * 250).toString().substring(0, 2)}k',
                style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.textSub(context)),
              ),
              const SizedBox(height: 4),
              Container(
                width: 28,
                height: h.toDouble(),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isToday 
                      ? [AppColors.success, AppColors.success.withValues(alpha: 0.6)]
                      : [isDark ? Colors.white24 : Colors.grey.shade300, isDark ? Colors.white12 : Colors.grey.shade100],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ['L', 'M', 'M', 'J', 'V', 'S', 'D'][index],
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isToday ? AppColors.textPrimary(context) : AppColors.textSub(context),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip, required this.isDark});
  final DriverEarningModel trip;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isDelivery = trip.tripId.length % 2 == 0; // Simulation
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.slateDivider : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDelivery ? Colors.orange : AppColors.success).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: FaIcon(
              isDelivery ? FontAwesomeIcons.box : FontAwesomeIcons.motorcycle,
              color: isDelivery ? Colors.orange : AppColors.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDelivery ? 'Livraison Colis' : 'Course Passager',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                Text(
                  '${DateFormat('dd MMM, HH:mm').format(trip.date)} • ${trip.distanceKm.toStringAsFixed(1)} km',
                  style: GoogleFonts.inter(
                    color: AppColors.textSub(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${NumberFormat('#,###').format(trip.netAmountFCFA)} F',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.textPrimary(context),
                ),
              ),
              Text(
                'NET',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSub(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
