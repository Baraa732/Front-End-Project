import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/error_handler.dart';
import '../../models/apartment.dart';
import 'add_apartment_screen.dart';
import '../apartment_details_screen.dart';

class MyApartmentsScreen extends StatefulWidget {
  const MyApartmentsScreen({super.key});

  @override
  State<MyApartmentsScreen> createState() => _MyApartmentsScreenState();
}

class _MyApartmentsScreenState extends State<MyApartmentsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _apartments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApartments();
  }

  Future<void> _loadApartments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.getMyApartments();
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        final data = result['data'];
        if (data is List) {
          setState(() {
            _apartments = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ErrorHandler.showError(context, null, customMessage: result['message'] ?? 'Failed to load apartments');
        }
      }
    } catch (e) {
      ErrorHandler.logError('loadMyApartments', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _deleteApartment(String apartmentId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF17173a),
        title: const Text('Delete Apartment', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "$title"?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _apiService.deleteApartment(apartmentId);
        
        if (!mounted) return;
        
        if (result['success']) {
          ErrorHandler.showSuccess(context, result['message'] ?? 'Apartment deleted successfully');
          _loadApartments();
        } else {
          ErrorHandler.showError(context, null, customMessage: result['message'] ?? 'Failed to delete apartment');
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showError(context, e);
        }
      }
    }
  }

  Future<void> _toggleAvailability(String apartmentId, bool currentStatus) async {
    try {
      final result = await _apiService.toggleApartmentAvailability(apartmentId);
      
      if (!mounted) return;
      
      if (result['success']) {
        ErrorHandler.showSuccess(context, result['message'] ?? 'Availability updated');
        _loadApartments();
      } else {
        ErrorHandler.showError(context, null, customMessage: result['message'] ?? 'Failed to update availability');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0e1330), Color(0xFF17173a)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d)))
                    : _apartments.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadApartments,
                            color: const Color(0xFFff6f2d),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _apartments.length,
                              itemBuilder: (context, index) => _buildApartmentCard(_apartments[index]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddApartmentScreen()),
          );
          if (result == true && mounted) _loadApartments();
        },
        backgroundColor: const Color(0xFFff6f2d),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'My Apartments',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work, size: 80, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No apartments yet',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first apartment',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentCard(Map<String, dynamic> apartment) {
    final images = List<String>.from(apartment['images'] ?? []);
    final isAvailable = apartment['available'] ?? apartment['is_available'] ?? true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: images.isNotEmpty
                    ? Image.network(
                        images.first,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey,
                          child: const Icon(Icons.image, color: Colors.white, size: 50),
                        ),
                      )
                    : Container(
                        height: 150,
                        color: Colors.grey,
                        child: const Icon(Icons.image, color: Colors.white, size: 50),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? const Color(0xFF10B981) : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAvailable ? 'Available' : 'Unavailable',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apartment['title'] ?? 'Untitled',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${apartment['city'] ?? ''}, ${apartment['governorate'] ?? ''}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.bed, color: Color(0xFFff6f2d), size: 16),
                    const SizedBox(width: 4),
                    Text('${apartment['bedrooms'] ?? 0}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 16),
                    const Icon(Icons.bathtub, color: Color(0xFFff6f2d), size: 16),
                    const SizedBox(width: 4),
                    Text('${apartment['bathrooms'] ?? 0}', style: const TextStyle(color: Colors.white)),
                    const Spacer(),
                    Text(
                      '\$${apartment['price'] ?? 0}/month',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFff6f2d)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApartmentDetailsScreen(apartmentId: apartment['id'].toString()),
                            ),
                          );
                          if (result == true) _loadApartments();
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFff6f2d),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddApartmentScreen(apartment: apartment, isEdit: true),
                            ),
                          );
                          if (result == true) _loadApartments();
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _toggleAvailability(apartment['id'].toString(), isAvailable),
                      icon: Icon(
                        isAvailable ? Icons.visibility_off : Icons.visibility,
                        color: isAvailable ? Colors.orange : const Color(0xFF10B981),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteApartment(apartment['id'].toString(), apartment['title'] ?? 'Apartment'),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}