import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/state/state.dart';
import '../../../data/data.dart';
import '../../widgets/common/cached_network_image.dart';
import '../../widgets/common/theme_toggle_button.dart';
import 'apartment_details_screen.dart';
import 'notifications_screen.dart';
import 'landlord_profile_screen.dart';

class ModernHomeScreen extends ConsumerStatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  ConsumerState<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends ConsumerState<ModernHomeScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Apartment> _apartments = [];
  List<Apartment> _filteredApartments = [];
  bool _isLoading = true;
  String _selectedGovernorate = 'All';
  String _selectedPriceRange = 'All';
  String _selectedBedrooms = 'All';
  bool _showFilters = false;

  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _filterAnimationController;
  late AnimationController _backgroundController;
  late Animation<double> _headerAnimation;
  late Animation<double> _filterAnimation;
  late Animation<double> _rotationAnimation;

  final List<String> _governorates = ['All', 'Cairo', 'Giza', 'Alexandria', 'Luxor', 'Aswan'];
  final List<String> _priceRanges = ['All', '0-500', '500-1000', '1000-2000', '2000+'];
  final List<String> _bedroomOptions = ['All', '1', '2', '3', '4+'];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {  
    _headerAnimationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _cardAnimationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _filterAnimationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _backgroundController = AnimationController(duration: const Duration(seconds: 20), vsync: this)..repeat();

    _headerAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic));
    _filterAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _filterAnimationController, curve: Curves.easeInOut));
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_backgroundController);

    _headerAnimationController.forward();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadApartments();
    _cardAnimationController.forward();
  }

  Future<void> _loadApartments() async {
    try {
      final result = await _apiService.getApartments();
      if (result['success'] == true) {
        final data = result['data'];
        List<Apartment> apartments = [];
        
        if (data is Map && data['data'] != null) {
          apartments = (data['data'] as List).map((json) => Apartment.fromJson(json)).toList();
        } else if (data is List) {
          apartments = data.map((json) => Apartment.fromJson(json)).toList();
        }
        
        setState(() {
          _apartments = apartments;
          _filteredApartments = apartments;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ErrorHandler.showError(context, null, customMessage: result['message'] ?? 'Failed to load apartments');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredApartments = _apartments.where((apartment) {
        bool matchesSearch = _searchController.text.isEmpty ||
            apartment.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            apartment.city.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            apartment.governorate.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesGovernorate = _selectedGovernorate == 'All' || apartment.governorate == _selectedGovernorate;
        bool matchesPrice = _selectedPriceRange == 'All' || _checkPriceRange(apartment.price);
        bool matchesBedrooms = _selectedBedrooms == 'All' || _checkBedrooms(apartment.bedrooms);

        return matchesSearch && matchesGovernorate && matchesPrice && matchesBedrooms;
      }).toList();
    });
  }

  bool _checkPriceRange(double price) {
    switch (_selectedPriceRange) {
      case '0-500': return price <= 500;
      case '500-1000': return price > 500 && price <= 1000;
      case '1000-2000': return price > 1000 && price <= 2000;
      case '2000+': return price > 2000;
      default: return true;
    }
  }

  bool _checkBedrooms(int bedrooms) {
    switch (_selectedBedrooms) {
      case '1': return bedrooms == 1;
      case '2': return bedrooms == 2;
      case '3': return bedrooms == 3;
      case '4+': return bedrooms >= 4;
      default: return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(isDarkMode),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildUnifiedHeader(),
                  Expanded(child: _buildApartmentsList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -30 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(ref.watch(themeProvider)),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.getBorderColor(ref.watch(themeProvider))),
                boxShadow: [BoxShadow(color: ref.watch(themeProvider) ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('AUTOHIVE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const Spacer(),
                      Consumer(
                        builder: (context, ref, child) {
                          final isDarkMode = ref.watch(themeProvider);
                          return Text(
                            '${_filteredApartments.length}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextColor(isDarkMode),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const ThemeToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAdvancedSearchBar(),
                  const SizedBox(height: 12),
                  _buildQuickFilters(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(ref.watch(themeProvider)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(ref.watch(themeProvider))),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppTheme.getTextColor(ref.watch(themeProvider)), fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search apartments...',
          hintStyle: TextStyle(color: AppTheme.getSubtextColor(ref.watch(themeProvider))),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFff6f2d)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => _applyFilters(),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Row(
      children: [
        Expanded(child: _buildCompactFilter('Location', _selectedGovernorate, _governorates, (v) { setState(() => _selectedGovernorate = v!); _applyFilters(); })),
        const SizedBox(width: 8),
        Expanded(child: _buildCompactFilter('Price', _selectedPriceRange, _priceRanges, (v) { setState(() => _selectedPriceRange = v!); _applyFilters(); })),
      ],
    );
  }

  Widget _buildCompactFilter(String label, String value, List<String> options, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(ref.watch(themeProvider)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(ref.watch(themeProvider))),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppTheme.getCardColor(ref.watch(themeProvider)),
          style: TextStyle(color: AppTheme.getTextColor(ref.watch(themeProvider)), fontSize: 12),
          items: options.map((option) => DropdownMenuItem(value: option, child: Text(option, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildApartmentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d)));
    }
    if (_filteredApartments.isEmpty) {
      return Center(child: Text('No apartments found', style: TextStyle(color: AppTheme.getTextColor(ref.watch(themeProvider)))));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _filteredApartments.length,
      itemBuilder: (context, index) => _buildModernApartmentCard(_filteredApartments[index], index),
    );
  }

  Widget _buildModernApartmentCard(Apartment apartment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(ref.watch(themeProvider)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(ref.watch(themeProvider))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildApartmentImage(apartment),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        apartment.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(ref.watch(themeProvider)),
                        ),
                      ),
                    ),
                    _buildStatusBadge(apartment.isAvailable),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFff6f2d), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${apartment.city}, ${apartment.governorate}',
                      style: TextStyle(color: AppTheme.getSubtextColor(ref.watch(themeProvider))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.bed, size: 16, color: AppTheme.getSubtextColor(ref.watch(themeProvider))),
                    Text(' ${apartment.bedrooms}', style: TextStyle(color: AppTheme.getSubtextColor(ref.watch(themeProvider)))),
                    const SizedBox(width: 16),
                    Icon(Icons.bathtub, size: 16, color: AppTheme.getSubtextColor(ref.watch(themeProvider))),
                    Text(' ${apartment.bathrooms}', style: TextStyle(color: AppTheme.getSubtextColor(ref.watch(themeProvider)))),
                    const SizedBox(width: 16),
                    Icon(Icons.square_foot, size: 16, color: AppTheme.getSubtextColor(ref.watch(themeProvider))),
                    Text(' ${apartment.area}m²', style: TextStyle(color: AppTheme.getSubtextColor(ref.watch(themeProvider)))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '\$${apartment.price}/night',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFff6f2d),
                      ),
                    ),
                    const Spacer(),
                    _buildLandlordProfile(apartment),
                    const SizedBox(width: 8),
                    _buildActionButton(apartment),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    final isDarkMode = ref.watch(themeProvider);
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              right: -50,
              top: 100,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFff6f2d).withOpacity(isDarkMode ? 0.3 : 0.1),
                        const Color(0xFF4a90e2).withOpacity(isDarkMode ? 0.2 : 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -20,
              top: 300,
              child: Transform.rotate(
                angle: -_rotationAnimation.value * 1.5 * 3.14159,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4a90e2).withOpacity(isDarkMode ? 0.4 : 0.1),
                        const Color(0xFFff6f2d).withOpacity(isDarkMode ? 0.3 : 0.08),
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

  Widget _buildApartmentImage(Apartment apartment) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: apartment.images.isNotEmpty
            ? FutureBuilder<String>(
                future: AppConfig.getImageUrl(apartment.images.first),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return CachedNetworkImage(
                      imageUrl: snapshot.data!,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d))),
                      ),
                      errorWidget: Container(
                        color: Colors.grey,
                        child: const Icon(Icons.image, color: Colors.white, size: 50),
                      ),
                    );
                  }
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d))),
                  );
                },
              )
            : Container(
                color: Colors.grey,
                child: const Icon(Icons.image, color: Colors.white, size: 50),
              ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Booked',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLandlordProfile(Apartment apartment) {
    if (apartment.landlord == null) return const SizedBox();
    
    return GestureDetector(
      onTap: () => _showLandlordProfile(apartment.landlord!),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFff6f2d), width: 2),
        ),
        child: CircleAvatar(
          radius: 16,
          backgroundImage: apartment.landlord!['profile_image_url'] != null
              ? NetworkImage(apartment.landlord!['profile_image_url'])
              : null,
          child: apartment.landlord!['profile_image_url'] == null
              ? Text(
                  apartment.landlord!['first_name']?[0]?.toUpperCase() ?? 'L',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )
              : null,
          backgroundColor: const Color(0xFFff6f2d),
        ),
      ),
    );
  }

  void _showLandlordProfile(Map<String, dynamic> landlord) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LandlordProfileScreen(landlord: landlord),
      ),
    );
  }

  Widget _buildActionButton(Apartment apartment) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _authService.getUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApartmentDetailsScreen(apartmentId: apartment.id))),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff6f2d),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('View Details', style: TextStyle(color: Colors.white)),
          );
        }
        
        if (user['role'] == 'landlord') {
          return ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApartmentDetailsScreen(apartmentId: apartment.id))),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4a90e2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Show Details', style: TextStyle(color: Colors.white)),
          );
        } else {
          return ElevatedButton(
            onPressed: apartment.isAvailable 
                ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApartmentDetailsScreen(apartmentId: apartment.id)))
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: apartment.isAvailable ? const Color(0xFF10B981) : Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              apartment.isAvailable ? 'Book Apartment' : 'Not Available',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _filterAnimationController.dispose();
    _backgroundController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
