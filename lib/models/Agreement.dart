class Agreement {
  final int id;
  final String name;
  final bool isActive;

  Agreement({required this.id, required this.name, required this.isActive});

  factory Agreement.fromJson(Map<String, dynamic> json) {
    return Agreement(
      id: json['id'],
      name: json['name'],
      isActive: json['isActive'] ?? false,
    );
  }
}