import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../model/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _notifs = [
    NotificationModel(id:'1', title:'Course terminée', body:'Votre course Akanda → Charbonnages est terminée. Notez votre coursier.', time:"Il y a 2h", type: NotifType.trip),
    NotificationModel(id:'2', title:'Offre spéciale', body:'1ère course offerte avec le code NOKI2025. Valable jusqu\'au 30 avr.', time:'Hier', type: NotifType.promo, isRead: true),
    NotificationModel(id:'3', title:'Colis livré', body:'Votre colis à destination de Glass a été livré avec succès.', time:'22 avr.', type: NotifType.delivery, isRead: true),
    NotificationModel(id:'4', title:'Bienvenue !', body:'Bienvenue sur NokiRide. Découvrez nos services de mobilité urbaine.', time:'20 avr.', type: NotifType.system, isRead: true),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(children: [
              GestureDetector(onTap: Get.back, child: Icon(Icons.arrow_back_rounded, color: titleC)),
              const SizedBox(width: 14),
              Text("notifications".tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: titleC)),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _notifs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _NotifTile(item: _notifs[i], isDark: isDark),
            ),
          ),
        ]),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.item, required this.isDark});
  final NotificationModel item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkMuted : AppColors.textLightSub;
    final color = item.type == NotifType.trip ? AppColors.serviceMoto
        : item.type == NotifType.delivery ? AppColors.serviceEnvoi
        : item.type == NotifType.promo ? AppColors.warning
        : AppColors.primaryBlue;
    final icon = item.type == NotifType.trip ? Icons.sports_motorsports_rounded
        : item.type == NotifType.delivery ? Icons.inventory_2_rounded
        : item.type == NotifType.promo ? Icons.local_offer_rounded
        : Icons.info_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isRead ? bg : color.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: item.isRead ? border : color.withValues(alpha: .20)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(item.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: titleC))),
            Text(item.time, style: TextStyle(fontSize: 11, color: subC)),
          ]),
          const SizedBox(height: 4),
          Text(item.body, style: TextStyle(fontSize: 12.5, color: subC, height: 1.4)),
        ])),
      ]),
    );
  }
}
