import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../model/place_model.dart';

class AddressSearchSheet extends StatelessWidget {
  const AddressSearchSheet({
    super.key,
    required this.isPickup,
    required this.onSelect,
    required this.onSearch,
    required this.searchResults,
    required this.isSearching,
    required this.onClearSearch,
  });

  final bool isPickup;
  final ValueChanged<PlaceModel> onSelect;
  final ValueChanged<String> onSearch;
  final RxList<PlaceModel> searchResults;
  final RxBool isSearching;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface(context);
    final border = AppColors.divider(context);
    final primary = AppColors.accent(context);
    final titleC = AppColors.textPrimary(context);
    final hintC = AppColors.textSub(context);
    final inputBg = AppColors.surface(context);

    return Container(
      decoration: BoxDecoration(
        color: bg,
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
            width: 38,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: border,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: titleC,
                  ),
                ),
                const SizedBox(height: 14),

                // Champ de recherche
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: hintC, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(
                            color: titleC,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Rechercher un quartier...',
                            hintStyle: TextStyle(color: hintC, fontSize: 14),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: onSearch,
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
            if (isSearching.value) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primary,
                ),
              );
            }

            final results = searchResults;

            if (results.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: _QuickSuggestions(
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
                shrinkWrap: true,
                itemCount: results.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                separatorBuilder: (_, __) => Divider(
                  color: border,
                  height: 1,
                ),
                itemBuilder: (_, i) => _ResultTile(
                  place: results[i],
                  onTap: () {
                    onSelect(results[i]);
                    onClearSearch();
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
    required this.onSelect,
  });
  final ValueChanged<PlaceModel> onSelect;

  static const _suggestions = [
    PlaceModel(
        name: 'Akanda',
        address: 'Quartier Akanda, Libreville',
        lat: 0.4477,
        lng: 9.4321),
    PlaceModel(
        name: 'Charbonnages',
        address: 'Quartier Charbonnages, Libreville',
        lat: 0.3875,
        lng: 9.4523),
    PlaceModel(
        name: 'Centre-Ville',
        address: 'Centre-Ville, Libreville',
        lat: 0.3934,
        lng: 9.4567),
    PlaceModel(
        name: 'Owendo',
        address: 'Owendo, Libreville',
        lat: 0.3021,
        lng: 9.5012),
    PlaceModel(
        name: 'Nzeng-Ayong',
        address: 'Nzeng-Ayong, Libreville',
        lat: 0.3761,
        lng: 9.4689),
  ];

  @override
  Widget build(BuildContext context) {
    final subC = AppColors.textSub(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quartiers fréquents',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: subC,
          ),
        ),
        const SizedBox(height: 8),
        ..._suggestions.map((p) => _ResultTile(
              place: p,
              onTap: () => onSelect(p),
            )),
      ],
    );
  }
}

// ─── Tile résultat ────────────────────────────────────────────
class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.place,
    required this.onTap,
  });
  final PlaceModel place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleC = AppColors.textPrimary(context);
    final subC = AppColors.textSub(context);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.accent(context).withOpacity(.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.place_rounded,
          color: AppColors.accent(context),
          size: 18,
        ),
      ),
      title: Text(
        place.name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: titleC,
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
