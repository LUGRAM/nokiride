class ProfileStatsModel {
  const ProfileStatsModel({
    required this.totalTrips,
    required this.totalDeliveries,
    required this.totalMarketOrders,
    required this.totalOrders,
    required this.totalSpentFcfa,
    required this.memberSince,
    required this.recentActivities,
  });

  factory ProfileStatsModel.empty() => const ProfileStatsModel(
        totalTrips: 0,
        totalDeliveries: 0,
        totalMarketOrders: 0,
        totalOrders: 0,
        totalSpentFcfa: 0,
        memberSince: '',
        recentActivities: [],
      );

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    final activities = (json['recent_activities'] as List<dynamic>? ?? [])
        .map((item) => ActivitySummary.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();

    return ProfileStatsModel(
      totalTrips: int.tryParse('${json['total_trips'] ?? 0}') ?? 0,
      totalDeliveries: int.tryParse('${json['total_deliveries'] ?? 0}') ?? 0,
      totalMarketOrders:
          int.tryParse('${json['total_market_orders'] ?? 0}') ?? 0,
      totalOrders: int.tryParse('${json['total_orders'] ?? 0}') ?? 0,
      totalSpentFcfa: int.tryParse('${json['total_spent_fcfa'] ?? 0}') ?? 0,
      memberSince: '${json['member_since'] ?? ''}',
      recentActivities: activities,
    );
  }

  final int totalTrips;
  final int totalDeliveries;
  final int totalMarketOrders;
  final int totalOrders;
  final int totalSpentFcfa;
  final String memberSince;
  final List<ActivitySummary> recentActivities;

  String get formattedSpent => '${_formatAmount(totalSpentFcfa)} F';

  String get formattedMemberSince {
    if (memberSince.isEmpty) return '-';
    final parsed = DateTime.tryParse(memberSince);
    if (parsed == null) return memberSince;
    const months = [
      'Jan.',
      'Fév.',
      'Mar.',
      'Avr.',
      'Mai',
      'Juin',
      'Juil.',
      'Août',
      'Sep.',
      'Oct.',
      'Nov.',
      'Déc.',
    ];
    return '${months[parsed.month - 1]} ${parsed.year}';
  }

  static String _formatAmount(int amount) => amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]} ',
      );
}

class ActivitySummary {
  const ActivitySummary({
    required this.type,
    required this.reference,
    required this.title,
    required this.status,
    required this.amountFcfa,
    required this.createdAt,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) =>
      ActivitySummary(
        type: '${json['type'] ?? ''}',
        reference: '${json['reference'] ?? ''}',
        title: '${json['title'] ?? ''}',
        status: '${json['status'] ?? ''}',
        amountFcfa: int.tryParse('${json['amount_fcfa'] ?? 0}') ?? 0,
        createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      );

  final String type;
  final String reference;
  final String title;
  final String status;
  final int amountFcfa;
  final DateTime? createdAt;

  String get formattedAmount =>
      '${ProfileStatsModel._formatAmount(amountFcfa)} F';

  String get formattedDate {
    if (createdAt == null) return '';
    final local = createdAt!.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} · ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
