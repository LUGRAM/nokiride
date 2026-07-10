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
      if (request == null) return const SizedBox.shrink();

      return Positioned.fill(
        child: Material(
          color: Colors.black.withValues(alpha: 0.72),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Nouvelle course',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: AppColors.accent(context),
                              child: Text(
                                '${controller.requestCountdown.value}',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _Line(label: 'Client', value: request.passengerName),
                        _Line(label: 'Départ', value: request.pickup.address),
                        _Line(label: 'Arrivée', value: request.dropoff.address),
                        _Line(
                            label: 'Distance',
                            value: request.formattedDistance),
                        _Line(label: 'Montant', value: request.formattedPrice),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: controller.rejectRequest,
                                child: const Text('Refuser'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: controller.acceptRequest,
                                child: const Text('Accepter'),
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

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSub(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
