import '../../trip/model/place_model.dart';

enum ParcelSize { small, medium, large }

extension ParcelSizeExt on ParcelSize {
  String get label => switch (this) {
    ParcelSize.small  => 'Petit (< 2 kg)',
    ParcelSize.medium => 'Moyen (2–10 kg)',
    ParcelSize.large  => 'Grand (> 10 kg)',
  };
  String get emoji => switch (this) {
    ParcelSize.small  => '✉️',
    ParcelSize.medium => '📦',
    ParcelSize.large  => '🗃️',
  };
  int get surcharge => switch (this) {
    ParcelSize.small  => 0,
    ParcelSize.medium => 300,
    ParcelSize.large  => 700,
  };
}

enum DeliveryStatus { idle, estimating, searching, assigned, inProgress, delivered, cancelled }

class RecipientModel {
  final String name;
  final String phone;
  const RecipientModel({required this.name, required this.phone});
}

class DeliveryModel {
  final String         id;
  final PlaceModel     pickup;
  final PlaceModel     dropoff;
  final RecipientModel recipient;
  final ParcelSize     parcelSize;
  final String?        parcelNote;
  final double         distanceKm;
  final int            priceFCFA;
  final int            estimatedMinutes;
  final DeliveryStatus status;

  const DeliveryModel({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.recipient,
    required this.parcelSize,
    required this.distanceKm,
    required this.priceFCFA,
    required this.estimatedMinutes,
    this.parcelNote,
    this.status = DeliveryStatus.idle,
  });

  DeliveryModel copyWith({DeliveryStatus? status}) => DeliveryModel(
    id: id, pickup: pickup, dropoff: dropoff,
    recipient: recipient, parcelSize: parcelSize,
    parcelNote: parcelNote, distanceKm: distanceKm,
    priceFCFA: priceFCFA, estimatedMinutes: estimatedMinutes,
    status: status ?? this.status,
  );

  String get formattedPrice {
    final s = priceFCFA.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return '$s F CFA';
  }
  String get formattedDistance =>
      '${distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km';
  String get formattedDuration => '~$estimatedMinutes min';
}
