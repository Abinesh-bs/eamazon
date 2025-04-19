class UserProfileModel {
  final String uid;
  final String name;
  final String phone;
  final String address;
  final String postalCode;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.address,
    required this.postalCode,
  });

  factory UserProfileModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfileModel(
      uid: uid,
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      postalCode: data['postal_code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'postal_code': postalCode,
    };
  }
}