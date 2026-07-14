import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../controller/driver_trip_controller.dart';

class NewRequestOverlay extends GetView<DriverTripController> {
  const NewRequestOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final request = controller.activeRequest.value;
      
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: request == null 
          ? const SizedBox.shrink()
          : Container(
              color: Colors.black.withValues(alpha: 0.72),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 30)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'NOUVELLE COURSE',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.accent(context),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent(context).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${controller.requestCountdown.value}s',
                                    style: GoogleFonts.inter(
                                      color: AppColors.accent(context),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _Line(label: 'PASSAGER', value: request.passengerName),
                            const SizedBox(height: 12),
                            _Line(label: 'DESTINATION', value: request.dropoff.address),
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _Stat(label: 'DISTANCE', value: request.formattedDistance),
                                _Stat(label: 'GAIN ESTIMÉ', value: request.formattedPrice, isPrice: true),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: controller.rejectRequest,
                                    child: Text('IGNORER', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w800)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 56,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      onPressed: controller.acceptRequest,
                                      child: Text('ACCEPTER', style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
      );
    });
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.isPrice = false});
  final String label, value;
  final bool isPrice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey)),
        Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: isPrice ? AppColors.success : null)),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey)),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
