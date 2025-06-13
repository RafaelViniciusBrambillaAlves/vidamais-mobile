class Exam {
  final int id;
  final String name;
  final String? description;

  Exam({
    required this.id, 
    required this.name, 
    this.description,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      name: json['name'],
      description: json['description'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description
    };
  }
}