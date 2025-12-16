import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/connection_manager.dart';
import '../services/error_handler.dart';
import '../config/app_config.dart';
import '../models/apartment.dart';
import '../widgets/cached_network_image.dart';
import '../widgets/theme_toggle_button.dart';
import 'apartment_details_screen.dart';
import 'notifications_screen.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.isDarkMode ? AppTheme.getDarkGradient() : AppTheme.getLightGradient(),
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
      },
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
                color: AppTheme.getCardColor(context.watch<ThemeProvider>().isDarkMode),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.getBorderColor(context.watch<ThemeProvider>().isDarkMode)),
                boxShadow: [BoxShadow(color: context.watch<ThemeProvider>().isDarkMode ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
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
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return Text(
                            '${_filteredApartments.length}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextColor(themeProvider.isDarkMode),
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
        color: AppTheme.getCardColor(context.watch<ThemeProvider>().isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context.watch<ThemeProvider>().isDarkMode)),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppTheme.getTextColor(context.watch<ThemeProvider>().isDarkMode), fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search apartments...',
          hintStyle: TextStyle(color: AppTheme.getSubtextColor(context.watch<ThemeProvider>().isDarkMode)),
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
        color: AppTheme.getCardColor(context.watch<ThemeProvider>().isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context.watch<ThemeProvider>().isDarkMode)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF17173a),
          style: TextStyle(color: AppTheme.getTextColor(context.watch<ThemeProvider>().isDarkMode), fontSize: 12),
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
      return Center(child: Text('No apartments found', style: TextStyle(color: AppTheme.getTextColor(context.watch<ThemeProvider>().isDarkMode))));
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
        color: AppTheme.getCardColor(context.watch<ThemeProvider>().isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context.watch<ThemeProvider>().isDarkMode)),
      ),
      child: ListTile(
        title: Text(apartment.title, style: TextStyle(color: AppTheme.getTextColor(context.watch<ThemeProvider>().isDarkMode))),
        subtitle: Text('${apartment.city}', style: TextStyle(color: AppTheme.getSubtextColor(context.watch<ThemeProvider>().isDarkMode))),
        trailing: Text('\$${apartment.price}', style: const TextStyle(color: Color(0xFFff6f2d), fontWeight: FontWeight.bold)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApartmentDetailsScreen(apartmentId: apartment.id))),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
                            const Color(0xFFff6f2d).withOpacity(themeProvider.isDarkMode ? 0.3 : 0.1),
                            const Color(0xFF4a90e2).withOpacity(themeProvider.isDarkMode ? 0.2 : 0.05),
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
                            const Color(0xFF4a90e2).withOpacity(themeProvider.isDarkMode ? 0.4 : 0.1),
                            const Color(0xFFff6f2d).withOpacity(themeProvider.isDarkMode ? 0.3 : 0.08),
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
