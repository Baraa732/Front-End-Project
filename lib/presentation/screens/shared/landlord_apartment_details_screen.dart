import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_service.dart';
import '../../../core/constants/app_config.dart';
import '../../widgets/common/cached_network_image.dart';

class LandlordApartmentDetailsScreen extends StatefulWidget {
  final String apartmentId;
  const LandlordApartmentDetailsScreen({super.key, required this.apartmentId});

  @override
  State<LandlordApartmentDetailsScreen> createState() => _LandlordApartmentDetailsScreenState();
}

class _LandlordApartmentDetailsScreenState extends State<LandlordApartmentDetailsScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _apartment;
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  int _currentImageIndex = 0;
  int _selectedTab = 0;
  
  late AnimationController _backgroundController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }
  
  void _initAnimations() {
    _backgroundController = AnimationController(duration: const Duration(seconds: 20), vsync: this)..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_backgroundController);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadApartmentDetails(), _loadBookings()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadApartmentDetails() async {
    try {
      final result = await _apiService.getApartmentDetails(widget.apartmentId);
      if (result['success'] == true && result['data'] != null) {
        setState(() => _apartment = result['data']);
      }
    } catch (e) {
      print('Error loading apartment details: $e');
    }
  }

  Future<void> _loadBookings() async {
    try {
      final result = await _apiService.getLandlordBookingRequests();
      if (result['success'] == true) {
        final allBookings = List<Map<String, dynamic>>.from(result['data']['data'] ?? []);
        setState(() {
          _bookings = allBookings.where((booking) => booking['apartment_id'].toString() == widget.apartmentId).toList();
        });
      }
    } catch (e) {
      print('Error loading bookings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: _isLoading
              ? Container(
                  decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.isDarkMode)),
                  child: const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d))),
                )
              : _apartment == null
                  ? Container(
                      decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.isDarkMode)),
                      child: SafeArea(
                        child: Column(
                          children: [
                            _buildHeader(),
                            const Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, size: 80, color: Colors.white54),
                                    SizedBox(height: 16),
                                    Text('Apartment not found', style: TextStyle(color: Colors.white, fontSize: 18)),
                                    SizedBox(height: 8),
                                    Text('This apartment may have been deleted or you don\'t have access to it.', 
                                         style: TextStyle(color: Colors.white54), textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.isDarkMode)),
                      child: Stack(
                        children: [
                          _buildAnimatedBackground(),
                          SafeArea(
                            child: Column(
                              children: [
                                _buildHeader(),
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildApartmentInfo(),
                                        const SizedBox(height: 24),
                                        _buildImageGallery(),
                                        const SizedBox(height: 24),
                                        _buildStatsCards(),
                                        const SizedBox(height: 24),
                                        _buildManagementActions(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
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
            'Manage Property',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _apartment!['title'] ?? 'Apartment',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              _buildApprovalStatusBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFff6f2d), size: 20),
              const SizedBox(width: 4),
              Text(
                '${_apartment!['city'] ?? ''}, ${_apartment!['governorate'] ?? ''}',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\$${_apartment!['price_per_night'] ?? _apartment!['price'] ?? 0}/night',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFff6f2d)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoCard(Icons.bed, '${_apartment!['bedrooms'] ?? 0} Beds'),
              const SizedBox(width: 12),
              _buildInfoCard(Icons.bathtub, '${_apartment!['bathrooms'] ?? 0} Baths'),
              const SizedBox(width: 12),
              _buildInfoCard(Icons.square_foot, '${_apartment!['area'] ?? 0} m²'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalStatusBadge() {
    final isApproved = _apartment!['is_approved'] ?? false;
    final status = _apartment!['status'] ?? 'pending';
    
    Color color;
    String text;
    
    if (!isApproved) {
      switch (status) {
        case 'pending':
          color = Colors.orange;
          text = 'PENDING';
          break;
        case 'rejected':
          color = Colors.red;
          text = 'REJECTED';
          break;
        default:
          color = Colors.orange;
          text = 'UNDER REVIEW';
      }
    } else {
      color = Colors.green;
      text = 'APPROVED';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildImageGallery() {
    final images = List<String>.from(_apartment!['images'] ?? []);
    
    if (images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, color: Colors.white54, size: 48),
              SizedBox(height: 8),
              Text('No images uploaded', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: PageView.builder(
          itemCount: images.length,
          onPageChanged: (index) => setState(() => _currentImageIndex = index),
          itemBuilder: (context, index) {
            return Image.network(
              AppConfig.getImageUrlSync(images[index]),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d))),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey,
                child: const Icon(Icons.image, color: Colors.white, size: 50),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Bookings', '${_bookings.length}', Icons.calendar_today, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Active', '${_bookings.where((b) => b['status'] == 'confirmed').length}', Icons.check_circle, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Pending', '${_bookings.where((b) => b['status'] == 'pending').length}', Icons.pending, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildManagementActions() {
    final isApproved = _apartment!['is_approved'] ?? false;
    
    return Column(
      children: [
        if (!isApproved) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: const Column(
              children: [
                Icon(Icons.hourglass_empty, color: Colors.orange, size: 32),
                SizedBox(height: 8),
                Text('Waiting for Admin Approval', style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Your apartment is under review. Management features will be available once approved.', 
                     style: TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
              ],
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4a90e2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Edit Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('View Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: _apartment!['is_available'] ? Colors.red : const Color(0xFFff6f2d),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _apartment!['is_available'] ? 'Mark as Unavailable' : 'Mark as Available',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _toggleAvailability() async {
    try {
      final result = await _apiService.toggleApartmentAvailability(widget.apartmentId);
      if (result['success']) {
        setState(() {
          _apartment!['is_available'] = !_apartment!['is_available'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability updated successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update availability'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              right: -30,
              top: 50,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4a90e2).withOpacity(0.2),
                        const Color(0xFFff6f2d).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 100,
              child: Transform.rotate(
                angle: -_rotationAnimation.value * 1.5 * 3.14159,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFff6f2d).withOpacity(0.3),
                        const Color(0xFF4a90e2).withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFff6f2d), size: 24),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }
}
