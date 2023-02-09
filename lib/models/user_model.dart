class UserModel {
  UserModel({
    this.fullName,
    this.birthDate,
    this.experience,
    this.phoneCode,
    this.phoneNumber,
    this.emailAddress,
    this.password,
    this.isPremiumUser,
    this.isVerifiedByPhone,
    this.createdAt,
    this.updatedAt,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    fullName = json["full_name"];
    birthDate = json["birth_date"];
    experience = json["experience"];
    phoneCode = json["phone_code"];
    phoneNumber = json["phone_number"];
    emailAddress = json["email_address"];
    password = json["password"];
    isPremiumUser = json["is_premium_user"];
    isVerifiedByPhone = json["is_verified_by_phone"];
    createdAt = json["created_at"];
    updatedAt = json["updated_at"];
  }

  String? fullName;
  String? birthDate;
  int? experience;
  String? phoneCode;
  String? phoneNumber;
  String? emailAddress;
  String? password;
  bool? isPremiumUser;
  bool? isVerifiedByPhone;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["full_name"] = fullName;
    map["birth_date"] = birthDate;
    map["experience"] = experience;
    map["phone_code"] = phoneCode;
    map["phone_number"] = phoneNumber;
    map["email_address"] = emailAddress;
    map["password"] = password;
    map["is_premium_user"] = isPremiumUser;
    map["is_verified_by_phone"] = isVerifiedByPhone;
    map["created_at"] = createdAt;
    map["updated_at"] = updatedAt;
    return map;
  }
}
