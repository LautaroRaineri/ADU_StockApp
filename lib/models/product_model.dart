class Product {
  final String id;
  final String name;
  final String sku;
  final int quantity;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.price,
  });

  // Convierte los datos recibidos de Supabase (JSON) a un objeto Dart
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  // Convierte el objeto Dart a JSON para enviarlo a Supabase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'quantity': quantity,
      'price': price,
    };
  }
}