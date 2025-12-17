class ProductPost {
  final int? id;
  final String? name;
  final double? price;
  final String? image;
  final String? description;

  ProductPost({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  factory ProductPost.fromJson(Map<String, dynamic> json) {
    return ProductPost(
      id: json["id"],
      name: json["name"],
      price: json["price"] is int
          ? (json["price"] as int).toDouble()
          : json["price"],
      image: json["image"],
      description: json["description"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "image": image,
    "description": description,
  };
}
