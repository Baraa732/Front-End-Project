import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/auth_service.dart';
import '../../../core/constants/app_config.dart';
import '../../widgets/common/cached_network_image.dart';
import '../tenant/create_booking_screen.dart';

class TenantApartmentDetailsScreen extends StatefulWidget {
  final String apartmentId;
  const TenantApartmentDetailsScreen({super.key, required this.apartmentId});

  @override
  State<TenantApartmentDetailsScreen> createState() => _TenantApartmentDetailsScreenState();
}

class _TenantApartmentDetailsScreenState extends State<TenantApartmentDetailsScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _apartment;
  bool _isLoading = true;
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  
  late AnimationController _backgroundController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDetails();
  }
  
  void _initAnimations() {
    _backgroundController = AnimationController(duration: const Duration(seconds: 20), vsync: this)..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_backgroundController);
  }

  Future<void> _loadDetails() async {
    try {
      final result = await _apiService.getApartmentDetails(widget.apartmentId);
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _apartment = result['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
                      child: const Center(child: Text('Apartment not found', style: TextStyle(color: Colors.white))),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 300,
                          pinned: true,
                          backgroundColor: Colors.transparent,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                              children: [
                                _buildAnimatedBackground(),
                                _buildImageGallery(),
                              ],
                            ),
                          ),
                          actions: [
                            IconButton(
                              onPressed: _toggleFavorite,
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.getBackgroundGradient(themeProvider.isDarkMode),
                            ),
                            child: Stack(
                              children: [
                                _buildAnimatedBackground(),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _apartment!['title'] ?? 'Apartment',
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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
                                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFff6f2d)),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          _buildInfoCard(Icons.bed, '${_apartment!['bedrooms'] ?? 0} Beds'),
                                          const SizedBox(width: 12),
                                          _buildInfoCard(Icons.bathtub, '${_apartment!['bathrooms'] ?? 0} Baths'),
                                          const SizedBox(width: 12),
                                          _buildInfoCard(Icons.square_foot, '${_apartment!['area'] ?? 0} m²'),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      _buildLandlordInfo(),
                                      const SizedBox(height: 24),
                                      const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(height: 8),
                                      Text(
                                        _apartment!['description'] ?? 'No description available',
                                        style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5, fontSize: 16),
                                      ),
                                      const SizedBox(height: 24),
                                      if (_apartment!['features'] != null && (_apartment!['features'] as List).isNotEmpty) ...[
                                        const Text('Amenities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: (_apartment!['features'] as List).map<Widget>((feature) => Chip(
                                            label: Text(feature.toString(), style: const TextStyle(color: Colors.white)),
                                            backgroundColor: const Color(0xFFff6f2d).withOpacity(0.3),
                                            side: const BorderSide(color: Color(0xFFff6f2d)),
                                          )).toList(),
                                        ),
                                        const SizedBox(height: 24),
                                      ],
                                      _buildBookingSection(),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildImageGallery() {
    final images = List<String>.from(_apartment!['images'] ?? []);
    
    if (images.isEmpty) {
      return Container(color: Colors.grey, child: const Center(child: Icon(Icons.image, color: Colors.white, size: 50)));
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (index) => setState(() => _currentImageIndex = index),
          itemBuilder: (context, index) {
            return FutureBuilder<String>(
              future: AppConfig.getImageUrl(images[index]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CachedNetworkImage(
                    imageUrl: snapshot.data!,
                    fit: BoxFit.cover,
                    placeholder: Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d)))),
                    errorWidget: Container(color: Colors.grey, child: const Icon(Icons.image, color: Colors.white, size: 50)),
                  );
                }
                return Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d))));
              },
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key ? Colors.white : Colors.white.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLandlordInfo() {
    final landlord = _apartment!['landlord'];
    if (landlord == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: landlord['profile_image_url'] != null ? NetworkImage(landlord['profile_image_url']) : null,
            child: landlord['profile_image_url'] == null ? Text(landlord['first_name']?[0]?.toUpperCase() ?? 'L', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)) : null,
            backgroundColor: const Color(0xFFff6f2d),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${landlord['first_name']} ${landlord['last_name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text('Property Owner', style: TextStyle(color: Colors.white70)),
                if (landlord['city'] != null) Text('${landlord['city']}, ${landlord['governorate']}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4a90e2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Contact', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSection() {
    final isAvailable = _apartment!['is_available'] ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Booking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isAvailable ? Icons.check_circle : Icons.cancel,
                    color: isAvailable ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAvailable ? 'Available for booking' : 'Currently unavailable',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isAvailable ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreateBookingScreen(apartment: _apartment!)),
                    );
                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking request sent successfully!'), backgroundColor: Color(0xFF10B981)),
                      );
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable ? const Color(0xFFff6f2d) : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isAvailable ? 'Book This Property' : 'Not Available',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite() async {
    try {
      final result = _isFavorite 
        ? await _apiService.removeFromFavorites(widget.apartmentId)
        : await _apiService.addToFavorites(widget.apartmentId);
      
      if (result['success']) {
        setState(() => _isFavorite = !_isFavorite);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? (_isFavorite ? 'Added to favorites' : 'Removed from favorites')),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: const Color(0xFFEF4444)),
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
                        const Color(0xFFff6f2d).withOpacity(0.2),
                        const Color(0xFF4a90e2).withOpacity(0.1),
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
                        const Color(0xFF4a90e2).withOpacity(0.3),
                        const Color(0xFFff6f2d).withOpacity(0.2),
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
