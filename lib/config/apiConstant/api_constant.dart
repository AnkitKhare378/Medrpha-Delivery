// lib/config/api_constant.dart

class ApiConstants {
  static const String baseUrl = "https://online-tech.in/api/";

  // Auth APIs
  static const String login = "${baseUrl}Auth/SignupOrLogin";

  //Address APIs
  static const String getAddressType = "${baseUrl}MasterAPI/GetAddressType";
  static const String getUserAddress = "${baseUrl}Customer/GetUserAddressByUserId";
  static const String updateAddress = "${baseUrl}Customer/UserAddressesUpdate";
  static const String deleteUserAddress = "${baseUrl}Customer/UserAddressesDeleteById";

  // Family Member APIs
  static const String insertFamilyMember = "${baseUrl}Customer/FamilyMemberInsert";

  static const String getAllSymptoms = "${baseUrl}Lab/GetAllSymptoms";

  static const String getAllTests = "${baseUrl}Lab/GetTestAll";

  //  New Cart API
  static const String addToCart = "${baseUrl}MasterAPI/AddToCart";

  static const String insertWishlist = "${baseUrl}WishlistAPI/InsertWishlist";

  // Image Base URL (commonly stored here or in a separate file)
  static const String labImageBaseUrl = "https://www.online-tech.in/LabImage/";
  static const String symptomImageBaseUrl = "https://www.online-tech.in/SymptomsImage/";
  static const String testImageBaseUrl = "https://www.online-tech.in/TestMasterImage/";
}