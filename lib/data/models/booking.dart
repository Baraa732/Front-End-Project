class Booking {
  final String id;
  final String apartmentId;
  final String tenantId;
  final String landlordId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime createdAt;
  final String? notes;

  const Booking({
    required this.id,
    required this.apartmentId,
    required this.tenantId,
    required this.landlordId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      apartmentId: json['apartment_id'].toString(),
      tenantId: json['tenant_id'].toString(),
      landlordId: json['landlord_id'].toString(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      notes: json['notes'],
    );
  }
}