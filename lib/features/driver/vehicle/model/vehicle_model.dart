class VehicleModel {
  const VehicleModel({
    required this.brand,
    required this.model,
    required this.color,
    required this.plateNumber,
  });

  final String brand;
  final String model;
  final String color;
  final String plateNumber;

  String get id => plateNumber.toUpperCase().replaceAll(' ', '-');

  Map<String, dynamic> toJson() => {
        'vehicle_id': id,
        'vehicle_brand': brand,
        'vehicle_model': model,
        'vehicle_color': color,
        'vehicle_plate': plateNumber,
      };
}
