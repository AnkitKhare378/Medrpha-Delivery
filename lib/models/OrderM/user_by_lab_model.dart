class UserByLabModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String image;
  final int labId;

  UserByLabModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.labId,
  });

  factory UserByLabModel.fromJson(Map<String, dynamic> json) {
    return UserByLabModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      image: json['image'] ?? "",
      labId: json['labId'] ?? 0,
    );
  }
}