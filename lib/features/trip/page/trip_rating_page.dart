import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/trip_controller.dart';

class TripRatingPage extends GetView<TripController> {
  const TripRatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final inputBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    double rating = 5;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: primary.withOpacity(.12), shape: BoxShape.circle, border: Border.all(color: primary.withOpacity(.25))),
                child: Icon(Icons.person_rounded, color: primary, size: 36),
              ),
              const SizedBox(height: 16),
              Text("Jean-Baptiste M.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: titleC)),
              const SizedBox(height: 6),
              Text("Comment était votre course ?", style: TextStyle(fontSize: 14, color: subC)),
              const SizedBox(height: 28),
              RatingBar.builder(
                initialRating: 5, minRating: 1, direction: Axis.horizontal,
                itemCount: 5, itemSize: 44, allowHalfRating: true,
                itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.warning),
                onRatingUpdate: (r) => rating = r,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                child: TextField(
                  maxLines: 3,
                  style: TextStyle(fontSize: 14, color: titleC),
                  decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Laissez un commentaire (optionnel)",
                    hintStyle: TextStyle(color: subC), contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: controller.completeTrip,
                  child: const Text("Envoyer la note", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: controller.completeTrip, child: Text("Passer", style: TextStyle(color: subC))),
            ],
          ),
        ),
      ),
    );
  }
}
