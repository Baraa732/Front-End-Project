import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../theme_provider.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../shared/tenant_apartment_details_screen.dart';
import '../shared/landlord_profile_screen.dart';

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> with TickerProviderStateMixin, RealTimeRefreshMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Apartment> _apartments = [];
  List<Apartment> _filteredApartments = [];
  bool _isLoading = true;
  String _selectedGovernorate = 'All';
  String _selectedPriceRange = 'All';

  late AnimationController _backgroundController;
  late Animation<double> _rotationAnimation;

  final List<String> _governorates = ['All', 'Cairo', 'Giza', 'Alexandria', 'Luxor', 'Aswan'];
  final List<String> _priceRanges = ['All', '0-500', '500-1000', '1000-2000', '2000+'];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadApartments();
    // Remove auto-refresh for tenant home - apartments don't change frequently
    // startRealTimeRefresh();
  }

  void _initAnimations() {
    _backgroundController = AnimationController(duration: const Duration(seconds: 20), vsync: this)..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_backgroundController);
  }

  Future<void> _loadApartments() async {
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.getApartments();
      if (result['success'] == true) {
        final data = result['data'];
        List<Apartment> apartments = [];
        
        if (data is Map && data['data'] != null) {
          apartments = (data['data'] as List)
              .map((json) => Apartment.fromJson(json))
              .where((apartment) => apartment.isApproved && apartment.status == 'approved')
              .toList();
        } else if (data is List) {
          apartments = data
              .map((json) => Apartment.fromJson(json))
              .where((apartment) => apartment.isApproved && apartment.status == 'approved')
              .toList();
        }
        
        setState(() {
          _apartments = apartments;
          _filteredApartments = apartments;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredApartments = _apartments.where((apartment) {
        bool matchesSearch = _searchController.text.isEmpty ||
            apartment.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            apartment.city.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesGovernorate = _selectedGovernorate == 'All' || apartment.governorate == _selectedGovernorate;
        bool matchesPrice = _selectedPriceRange == 'All' || _checkPriceRange(apartment.price);

        return matchesSearch && matchesGovernorate && matchesPrice;
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.getBackgroundGradient(themeProvider.isDarkMode),
            ),
            child: Stack(
              children: [
                _buildAnimatedBackground(themeProvider.isDarkMode),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(themeProvider.isDarkMode),
                      Expanded(child: _buildApartmentsList()),
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

  Widget _buildHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.getBorderColor(isDark)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
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
                child: const Text('TENANT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const Spacer(),
              Text(
                '${_filteredApartments.length} Available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getTextColor(isDark)),
              ),
              const SizedBox(width: 8),
              const ThemeToggleButton(),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(isDark),
          const SizedBox(height: 12),
          _buildFilters(isDark),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(isDark)),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppTheme.getTextColor(isDark)),
        decoration: InputDecoration(
          hintText: 'Search apartments...',
          hintStyle: TextStyle(color: AppTheme.getSubtextColor(isDark)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFff6f2d)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => _applyFilters(),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildFilter('Location', _selectedGovernorate, _governorates, (v) { setState(() => _selectedGovernorate = v!); _applyFilters(); }, isDark)),
        const SizedBox(width: 8),
        Expanded(child: _buildFilter('Price', _selectedPriceRange, _priceRanges, (v) { setState(() => _selectedPriceRange = v!); _applyFilters(); }, isDark)),
      ],
    );
  }

  Widget _buildFilter(String label, String value, List<String> options, Function(String?) onChanged, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppTheme.getCardColor(isDark),
          style: TextStyle(color: AppTheme.getTextColor(isDark), fontSize: 12),
          items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
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
      return const Center(child: Text('No apartments found', style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredApartments.length,
      itemBuilder: (context, index) => _buildApartmentCard(_filteredApartments[index]),
    );
  }

  Widget _buildApartmentCard(Apartment apartment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context.watch<ThemeProvider>().isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context.watch<ThemeProvider>().isDarkMode)),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getTextColor(context.watch<ThemeProvider>().isDarkMode)),
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
                    Text('${apartment.city}, ${apartment.governorate}', style: TextStyle(color: AppTheme.getSubtextColor(context.watch<ThemeProvider>().isDarkMode))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.bed, size: 16, color: AppTheme.getSubtextColor(context.watch<ThemeProvider>().isDarkMode)),
                    Text(' ${apartment.bedrooms}', style: TextStyle(color: AppTheme.getSubtextColor(context.watch<ThemeProvider>().isDarkMode))),
                    const SizedBox(width: 16),
                    Icon(Icons.bathtub, size: 16, color: AppTheme.getSubtextColor(context.watch<ThemeProvider>().isDarkMode)),
                    Text(' ${apartment.bathrooms}', style: TextStyle(color: AppTheme.getSubtextColor(context.watch<ThemeProvider>().isDarkMode))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('\$${apartment.price}/night', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFff6f2d))),
                    const Spacer(),
                    if (apartment.landlord != null) _buildLandlordProfile(apartment.landlord!),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: apartment.isAvailable 
                          ? () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => TenantApartmentDetailsScreen(apartmentId: apartment.id)));
                              _loadApartments();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: apartment.isAvailable ? const Color(0xFF10B981) : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(apartment.isAvailable ? 'Book Now' : 'Not Available', style: const TextStyle(color: Colors.white)),
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

  Widget _buildApartmentImage(Apartment apartment) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: apartment.images.isNotEmpty
            ? Image.network(
                AppConfig.getImageUrlSync(apartment.images.first),
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
              )
            : Container(
                color: Colors.grey, 
                child: const Icon(Icons.image, color: Colors.white, size: 50)
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
      child: Text(isAvailable ? 'Available' : 'Booked', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLandlordProfile(Map<String, dynamic> landlord) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LandlordProfileScreen(landlord: landlord))),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFff6f2d), width: 2)),
        child: CircleAvatar(
          radius: 16,
          backgroundImage: landlord['profile_image_url'] != null ? NetworkImage(landlord['profile_image_url']) : null,
          child: landlord['profile_image_url'] == null ? Text(landlord['first_name']?[0]?.toUpperCase() ?? 'L', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
          backgroundColor: const Color(0xFFff6f2d),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
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
                        const Color(0xFFff6f2d).withOpacity(isDark ? 0.3 : 0.1),
                        const Color(0xFF4a90e2).withOpacity(isDark ? 0.2 : 0.05),
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
                        const Color(0xFF4a90e2).withOpacity(isDark ? 0.4 : 0.1),
                        const Color(0xFFff6f2d).withOpacity(isDark ? 0.3 : 0.08),
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

  @override
  void refreshData() => _loadApartments();

  @override
  void dispose() {
    _backgroundController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
