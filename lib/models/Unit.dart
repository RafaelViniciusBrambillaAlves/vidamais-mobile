class Unit {
  final int id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String phone;
  final String openingTime;
  final String closingTime;
  final String? deleted_at;

  Unit({
    required this.id,
    required this.name,
    required this.address,
    required this.city, 
    required this.state, 
    required this.phone, 
    required this.openingTime, 
    required this.closingTime,
    this.deleted_at
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      phone: json['phone'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      deleted_at: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'phone': phone,
      'openingTime': openingTime,
      'closingTime': closingTime,
    };
  }
}
