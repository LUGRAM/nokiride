enum UserRole { client, driver }

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.isOnline = false,
    this.vehicleId,
    this.rating,
  });

  final int? id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final bool isOnline;
  final String? vehicleId;
  final double? rating;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleValue = '${json['role'] ?? json['user_role'] ?? ''}';
    final mappedRole =
        roleValue == 'driver' ? UserRole.driver : UserRole.client;

    return UserModel(
      id: int.tryParse('${json['id'] ?? ''}'),
      name: '${json['name'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      email: json['email']?.toString(),
      role: mappedRole,
      isOnline: json['is_online'] == true || json['isOnline'] == true,
      vehicleId:
          json['vehicle_id']?.toString() ?? json['vehicleId']?.toString(),
      rating: double.tryParse('${json['rating'] ?? ''}'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role == UserRole.driver ? 'driver' : 'client',
        'is_online': isOnline,
        'vehicle_id': vehicleId,
        'rating': rating,
      };

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    bool? isOnline,
    String? vehicleId,
    double? rating,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      vehicleId: vehicleId ?? this.vehicleId,
      rating: rating ?? this.rating,
    );
  }
}
