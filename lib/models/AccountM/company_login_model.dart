// company_login_model.dart

class CompanyLoginModel {
  final int id;
  final String userName;
  final String companyName;
  final String labName;
  final String email;
  final String phone;
  final String address;
  final String image;
  final String password; // Note: In a real app, storing or receiving the password field is usually avoided.
  final int companyId;
  final int labId;

  CompanyLoginModel({
    required this.id,
    required this.userName,
    required this.companyName,
    required this.labName,
    required this.email,
    required this.phone,
    required this.address,
    required this.image,
    required this.password,
    required this.companyId,
    required this.labId,
  });

  factory CompanyLoginModel.fromJson(Map<String, dynamic> json) {
    return CompanyLoginModel(
      id: json['id'] as int,
      userName: json['userName'] as String,
      companyName: json['companyName'] as String,
      labName: json['lab_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      image: json['image'] as String,
      password: json['password'] as String,
      companyId: json['companyId'] as int,
      labId: json['labId'] as int,
    );
  }

  // Helper method to convert a list response (which the API returns) to a single model.
  static CompanyLoginModel? fromListJson(List<dynamic> jsonList) {
    if (jsonList.isNotEmpty) {
      return CompanyLoginModel.fromJson(jsonList.first as Map<String, dynamic>);
    }
    return null;
  }
}