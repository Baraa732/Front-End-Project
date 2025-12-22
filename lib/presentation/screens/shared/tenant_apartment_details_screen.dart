import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/state/state.dart';
import '../../widgets/common/cached_network_image.dart';
import '../tenant/create_booking_screen.dart';
import 'chat_screen.dart';

class TenantApartmentDetailsScreen extends ConsumerStatefulWidget {
  final String apartmentId;
  const TenantApartmentDetailsScreen({super.key, required this.apartmentId});

  @override
  ConsumerState<TenantApartmentDetailsScreen> createState() => _TenantApartmentDetailsScreenState();
}

class _TenantApartmentDetailsScreenState extends ConsumerState<TenantApartmentDetailsScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
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
    _loadCurrentUser();
    _loadDetails();
  }
  
  Future<void> _loadCurrentUser() async {
    _currentUser = await _authService.getUser();
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
    final isDarkMode = ref.watch(themeProvider);
    
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(isDarkMode)),
          child: const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d))),
        ),
      );
    }
    
    if (_apartment == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(isDarkMode)),
          child: const Center(child: Text('Apartment not found', style: TextStyle(color: Colors.white))),
        ),
      );
    }
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  _buildImageGallery(),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(backgroundColor: Colors.black26),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 8,
                    child: IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                        size: 28,
                      ),
                      style: IconButton.styleFrom(backgroundColor: Colors.black26),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(isDarkMode)),
              child: Stack(
                children: [
                  Positioned.fill(child: _buildAnimatedBackground()),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _apartment?['title']?.toString() ?? 'Apartment',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFFff6f2d), size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${_apartment?['city']?.toString() ?? ''}, ${_apartment?['governorate']?.toString() ?? ''}',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\$${_apartment?['price_per_night']?.toString() ?? _apartment?['price']?.toString() ?? '0'}/night',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFff6f2d)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildInfoCard(Icons.bed, '${_apartment?['bedrooms']?.toString() ?? '0'} Beds'),
                            const SizedBox(width: 12),
                            _buildInfoCard(Icons.bathtub, '${_apartment?['bathrooms']?.toString() ?? '0'} Baths'),
                            const SizedBox(width: 12),
                            _buildInfoCard(Icons.square_foot, '${_apartment?['area']?.toString() ?? '0'} m²'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildLandlordInfo(),
                        const SizedBox(height: 24),
                        const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          _apartment?['description']?.toString() ?? 'No description available',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        if (_apartment?['features'] != null && (_apartment!['features'] as List).isNotEmpty) ...[
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
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final imagesData = _apartment?['images'];
    final images = imagesData != null ? List<String>.from(imagesData) : <String>[];
    
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
                    errorWidget: Container(color: Colors.grey, child: const Center(child: Icon(Icons.image, color: Colors.white, size: 50))),
                  );
                } else {
                  return Container(color: Colors.grey, child: const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d))));
                }
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

  Widget _buildLandlordInfo() {
    final landlord = _apartment?['landlord'];
    if (landlord == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Landlord', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFff6f2d),
                backgroundImage: landlord['profile_image_url'] != null ? NetworkImage(landlord['profile_image_url']) : null,
                child: landlord['profile_image_url'] == null ? Text(
                  (landlord['first_name']?.toString().isNotEmpty == true ? landlord['first_name'][0].toUpperCase() : 'L'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${landlord['first_name']?.toString() ?? ''} ${landlord['last_name']?.toString() ?? ''}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Property Owner',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isOwnApartment = _currentUser?['id'].toString() == _apartment?['landlord']?['id'].toString();
    final isAvailable = _apartment?['available'] ?? _apartment?['is_available'] ?? true;
    
    if (isOwnApartment) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'This is your apartment',
                style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    if (!isAvailable) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'This apartment is currently unavailable',
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
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
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Book This Apartment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startChat,
            icon: const Icon(Icons.chat, color: Colors.white),
            label: const Text(
              'Chat with Landlord',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff6f2d),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startChat() async {
    try {
      final result = await _chatService.createOrGetChat(
        apartmentId: widget.apartmentId,
        landlordId: _apartment?['landlord']?['id'].toString() ?? '',
      );

      if (result['success'] == true && result['data'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: result['data']['id'].toString(),
              otherUserName: '${_apartment?['landlord']?['first_name']} ${_apartment?['landlord']?['last_name']}',
              apartmentTitle: _apartment?['title'] ?? 'Apartment',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to start chat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error starting chat'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }
}