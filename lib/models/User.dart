class User {
  int? id;
  String username;
  DateTime birthdate;
  String sex;
  String cellphone;
  String cpf;
  String? password;

  User({
    this.id,
    required this.username,
    required this.birthdate,
    required this.sex,
    required this.cellphone,
    required this.cpf,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'birthdate': birthdate.toIso8601String(),
      'sex': sex,
      'cellphone': cellphone,
      'cpf': cpf,
      'password': password,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['fullName'] as String,
      birthdate: DateTime.parse(json['birthDate'] as String),
      sex: json['gender'] as String,
      cellphone: json['phone'] as String,
      cpf: json['cpf'] as String,
      password: json['password'] as String,
    );
  }
}
