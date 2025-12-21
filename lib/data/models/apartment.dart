class Apartment {
  final String id;
  final String title;
  final String description;
  final String address;
  final String governorate;
  final String city;
  final double price;
  final double? pricePerNight;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final List<String> images;
  final List<String> features;
  final bool isAvailable;
  final bool isApproved;
  final String status;
  final double? rating;
  final Map<String, dynamic>? landlord;

  Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.governorate,
    required this.city,
    required this.price,
    this.pricePerNight,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.images,
    required this.features,
    required this.isAvailable,
    required this.isApproved,
    required this.status,
    this.rating,
    this.landlord,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      governorate: json['governorate'] ?? '',
      city: json['city'] ?? '',
      price: json['price'] != null
          ? double.parse(json['price'].toString())
          : (json['price_per_night'] != null
                ? double.parse(json['price_per_night'].toString())
                : 0),
      pricePerNight: json['price_per_night'] != null
          ? double.parse(json['price_per_night'].toString())
          : null,
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: double.parse(json['area'].toString()),
      images: List<String>.from(json['images'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      isAvailable: json['is_available'] ?? false,
      isApproved: json['is_approved'] ?? false,
      status: json['status'] ?? 'pending',
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : null,
      landlord: json['landlord'] as Map<String, dynamic>?,
    );
  }
}
