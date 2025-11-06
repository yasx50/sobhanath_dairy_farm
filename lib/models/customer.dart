class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;

  Customer({required this.id, required this.name, required this.phone, this.address = ''});

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'address': address,
  };

  factory Customer.fromMap(String id, Map<String, dynamic> map) => Customer(
    id: id,
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    address: map['address'] ?? '',
  );
}
