import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/connection_manager.dart';
import '../services/error_handler.dart';
import '../config/app_config.dart';
import '../models/apartment.dart';
import '../widgets/cached_network_image.dart';
import 'tenant/create_booking_screen.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  final String apartmentId;
  const ApartmentDetailsScreen({super.key, required this.apartmentId});

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _apartment;
  Map<String, dynamic>? _currentUser;
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
    _loadUser();
  }
  
  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_backgroundController);
  }

  Future<void> _loadUser() async {
    final user = await _authService.getUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadDetails() async {
    try {
      final result = await _apiService.getApartmentDetails(widget.apartmentId);
      
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _apartment = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ErrorHandler.showError(context, null, customMessage: result['message'] ?? 'Failed to load apartment details');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add favorites'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    try {
      final result = _isFavorite 
        ? await _apiService.removeFromFavorites(widget.apartmentId)
        : await _apiService.addToFavorites(widget.apartmentId);
      
      if (result['success']) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? (_isFavorite ? 'Added to favorites' : 'Removed from favorites')),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update favorites'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Container(
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0e1330), Color(0xFF17173a)])),
              child: const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d))),
            )
          : _apartment == null
              ? Container(
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0e1330), Color(0xFF17173a)])),
                  child: const Center(child: Text('Apartment not found', style: TextStyle(color: Colors.white))),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      backgroundColor: const Color(0xFF0e1330),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            _buildAnimatedBackground(),
                            _buildImageGallery(),
                          ],
                        ),
                      ),
                      actions: const [],
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF0e1330), Color(0xFF17173a)]),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
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
                                      if (_currentUser?['role'] == 'tenant')
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
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Color(0xFFff6f2d), size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_apartment!['city'] ?? ''}, ${_apartment!['governorate'] ?? ''}',
                                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '\$${_apartment!['price_per_night'] ?? _apartment!['price'] ?? 0}/night',
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFff6f2d)),
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
                                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text(
                                    _apartment!['description'] ?? 'No description available',
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
                                  ),
                                  const SizedBox(height: 24),
                                  if (_apartment!['features'] != null && (_apartment!['features'] as List).isNotEmpty) ...[
                                    const Text('Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                                  if (_apartment!['latitude'] != null && _apartment!['longitude'] != null)
                                    _buildLocationSection(),
                                  const SizedBox(height: 32),
                                  if (_currentUser?['role'] == 'tenant')
                                    _buildBookingButton()
                                  else if (_currentUser == null)
                                    _buildLoginPrompt(),
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
  }

  Widget _buildImageGallery() {
    final images = List<String>.from(_apartment!['images'] ?? []);
    
    if (images.isEmpty) {
      return Container(
        color: Colors.grey,
        child: const Center(
          child: Icon(Icons.image, color: Colors.white, size: 50),
        ),
      );
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
                    placeholder: Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFff6f2d),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: Container(
                      color: Colors.grey,
                      child: const Icon(Icons.image, color: Colors.white, size: 50),
                    ),
                  );
                }
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFff6f2d),
                      strokeWidth: 2,
                    ),
                  ),
                );
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

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 48, color: Color(0xFFff6f2d)),
              const SizedBox(height: 8),
              Text(
                'Latitude: ${_apartment!['latitude']?.toStringAsFixed(4)}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Longitude: ${_apartment!['longitude']?.toStringAsFixed(4)}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Interactive map available when integrated',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBookingButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateBookingScreen(apartment: _apartment!),
            ),
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking request sent successfully!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFff6f2d),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'Book Now',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.login, color: Color(0xFFff6f2d), size: 48),
          const SizedBox(height: 8),
          const Text(
            'Login Required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Please login as a tenant to book this apartment',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
            Icon(icon, color: const Color(0xFFff6f2d)),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
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