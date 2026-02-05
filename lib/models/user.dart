class User {
    final String id;
    final String userName;
    final String email;
    final String premiumAt;
    final String createdAt;
    final String updatedAt;
  User(this.id, this.userName, this.email, this.premiumAt, this.createdAt, this.updatedAt);
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['userName'],
      json['email'],
      json['premiumAt'],
      json['createdAt'],
      json['updatedAt'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'premiumAt': premiumAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
