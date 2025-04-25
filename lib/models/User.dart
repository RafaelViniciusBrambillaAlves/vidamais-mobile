class User {
  String username;
  DateTime birthdate;
  String sex;
  String cellphone;
  String cpf;
  String password;

  User({
    required this.username,
    required this.birthdate,
    required this.sex,
    required this.cellphone,
    required this.cpf,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'birthdate': birthdate.toIso8601String(),
      'sex': sex,
      'cellphone': cellphone,
      'cpf': cpf,
      'password': password,
    };
  }
}
