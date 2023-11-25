class UserModel {
  final String id;
  final String? email;
  final String? password;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
  });

  UserModel.withoutPassword({
    required this.id,
    required this.email,
  }) : password = null;

  UserModel.withoutId({
    required this.email,
    required this.password,
  }) : id = '';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }
}
