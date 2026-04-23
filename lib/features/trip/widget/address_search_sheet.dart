import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controller/trip_controller.dart';
import '../model/place_model.dart';

class AddressSearchSheet extends GetView<TripController> {
  const AddressSearchSheet({
    super.key,
    required this.isDark,
    required this.isPickup,
    required this.onSelect,
  });

  final bool                     isDark;
  final bool                     isPickup;
  final ValueChanged<PlaceModel> onSelect;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppColors.bgDarkSurface  : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark      : AppColors.borderLight;
    final primary = isDark ? AppColors.primaryBlue   : AppColors.primaryGreen;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final hintC  = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;
    final inputBg= isDark ? AppColors.bgDarkElevated  : AppColors.bgLightInput;

    return Container(
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 38, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color:        border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPickup ? "Point d'enlèvement" : 'Destination',
                  style: TextStyle(
                    fontSize:   17,
                    fontWeight: FontWeight.w800,
                    color:      titleC,
                  ),
                ),
                const SizedBox(height: 14),

                // Champ de recherche
                Container(
                  height:  50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color:        inputBg,
                    borderRadius: BorderRadius.circular(14),
                    border:       Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: hintC, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(
                            color:    titleC,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            border:      InputBorder.none,
                            hintText:    'Rechercher un quartier...',
                            hintStyle:   TextStyle(color: hintC, fontSize: 14),
                            isDense:     true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: controller.searchPlace,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Résultats
          Obx(() {
            if (controller.isSearching.value) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color:       primary,
                ),
              );
            }

            final results = controller.searchResults;

            if (results.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: _QuickSuggestions(
                  isDark:   isDark,
                  onSelect: (place) {
                    onSelect(place);
                    Get.back();
                  },
                ),
              );
            }

            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap:  true,
                itemCount:   results.length,
                padding:     const EdgeInsets.symmetric(horizontal: 20),
                separatorBuilder: (_, __) => Divider(
                  color: border, height: 1,
                ),
                itemBuilder: (_, i) => _ResultTile(
                  place:  results[i],
                  isDark: isDark,
                  onTap:  () {
                    onSelect(results[i]);
                    controller.clearSearch();
                    Get.back();
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Suggestions rapides ──────────────────────────────────────
class _QuickSuggestions extends StatelessWidget {
  const _QuickSuggestions({
    required this.isDark,
    required this.onSelect,
  });
  final bool                     isDark;
  final ValueChanged<PlaceModel> onSelect;

  static const _suggestions = [
    PlaceModel(name: 'Akanda',       address: 'Quartier Akanda, Libreville',     lat: 0.4477, lng: 9.4321),
    PlaceModel(name: 'Charbonnages', address: 'Quartier Charbonnages, Libreville', lat: 0.3875, lng: 9.4523),
    PlaceModel(name: 'Centre-Ville', address: 'Centre-Ville, Libreville',         lat: 0.3934, lng: 9.4567),
    PlaceModel(name: 'Owendo',       address: 'Owendo, Libreville',               lat: 0.3021, lng: 9.5012),
    PlaceModel(name: 'Nzeng-Ayong',  address: 'Nzeng-Ayong, Libreville',          lat: 0.3761, lng: 9.4689),
  ];

  @override
  Widget build(BuildContext context) {
    final subC  = isDark ? AppColors.textDarkSub  : AppColors.textLightSub;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final border = isDark ? AppColors.borderDark   : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quartiers fréquents',
          style: TextStyle(
            fontSize:   12,
            fontWeight: FontWeight.w600,
            color:      subC,
          ),
        ),
        const SizedBox(height: 8),
        ..._suggestions.map((p) => _ResultTile(
          place:  p,
          isDark: isDark,
          onTap:  () => onSelect(p),
        )),
      ],
    );
  }
}

// ─── Tile résultat ────────────────────────────────────────────
class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.place,
    required this.isDark,
    required this.onTap,
  });
  final PlaceModel   place;
  final bool         isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;

    return ListTile(
      onTap:        onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color:        (isDark ? AppColors.primaryBlue : AppColors.primaryGreen)
              .withOpacity(.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.place_rounded,
          color: isDark ? AppColors.primaryBlueLight : AppColors.primaryGreenDark,
          size:  18,
        ),
      ),
      title: Text(
        place.name,
        style: TextStyle(
          fontSize:   14,
          fontWeight: FontWeight.w700,
          color:      titleC,
        ),
      ),
      subtitle: Text(
        place.address,
        style: TextStyle(fontSize: 12, color: subC),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
