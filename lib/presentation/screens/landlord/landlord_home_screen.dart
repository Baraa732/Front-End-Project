import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/state/state.dart';
import '../../../data/data.dart';
import '../../widgets/common/cached_network_image.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../widgets/common/apartment_status_notification.dart';
import '../shared/landlord_apartment_details_screen.dart';
import '../shared/chats_list_screen.dart';

class LandlordHomeScreen extends ConsumerStatefulWidget {
  const LandlordHomeScreen({super.key});

  @override
  ConsumerState<LandlordHomeScreen> createState() => _LandlordHomeScreenState();
}

class _LandlordHomeScreenState extends ConsumerState<LandlordHomeScreen>
    with TickerProviderStateMixin, RealTimeRefreshMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<Apartment> _myApartments = [];
  List<Map<String, dynamic>> _bookingRequests = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  Timer? _refreshTimer;

  late AnimationController _backgroundController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
    // Only refresh booking requests, not apartments
    startRealTimeRefresh(interval: const Duration(seconds: 30));
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_backgroundController);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadMyApartments(), _loadBookingRequests()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadMyApartments() async {
    try {
      final result = await _apiService.getMyApartments();
      if (result['success'] == true) {
        final data = result['data'];
        List<Apartment> apartments = [];

        if (data is Map && data['data'] != null) {
          apartments = (data['data'] as List)
              .map((json) => Apartment.fromJson(json))
              .toList();
        } else if (data is List) {
          apartments = data.map((json) => Apartment.fromJson(json)).toList();
        }

        setState(() => _myApartments = apartments);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadBookingRequests() async {
    try {
      final result = await _apiService.getLandlordBookingRequests();
      if (result['success'] == true) {
        setState(
          () => _bookingRequests = List<Map<String, dynamic>>.from(
            result['data']['data'] ?? [],
          ),
        );
      }
    } catch (e) {
      // Handle error
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
            _buildAnimatedBackground(isDarkMode),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDarkMode),
                  _buildTabBar(isDarkMode),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ],
        ),
      ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4a90e2), Color(0xFFff6f2d)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'LANDLORD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatsListScreen()),
            ),
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFff6f2d)),
            tooltip: 'Messages',
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_myApartments.length} Properties',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(isDark),
                ),
              ),
              Text(
                '${_bookingRequests.length} Requests',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getSubtextColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const ThemeToggleButton(),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(isDark)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab('My Properties', 0, isDark)),
          Expanded(child: _buildTab('Booking Requests', 1, isDark)),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4a90e2), Color(0xFFff6f2d)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.getTextColor(isDark),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFff6f2d)),
      );
    }

    return _selectedTab == 0 ? _buildMyApartments() : _buildBookingRequests();
  }

  Widget _buildMyApartments() {
    if (_myApartments.isEmpty) {
      return const Center(
        child: Text(
          'No apartments listed',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _myApartments.length,
      itemBuilder: (context, index) =>
          _buildApartmentCard(_myApartments[index]),
    );
  }

  Widget _buildApartmentCard(Apartment apartment) {
    return Column(
      children: [
        if (!apartment.isApproved)
          ApartmentStatusNotification(
            status: apartment.status,
            rejectionReason:
                null, // You can add rejection reason from backend if needed
          ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(ref.watch(themeProvider)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.getBorderColor(ref.watch(themeProvider)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
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
                        _buildStatusBadge(apartment),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFff6f2d),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${apartment.city}, ${apartment.governorate}',
                          style: TextStyle(
                            color: AppTheme.getSubtextColor(ref.watch(themeProvider)),
                          ),
                        ),
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
                        IconButton(
                          onPressed: apartment.isApproved
                              ? () => _editApartment(apartment)
                              : null,
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              _deleteApartment(apartment.id, apartment.title),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: apartment.isApproved
                              ? () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LandlordApartmentDetailsScreen(
                                            apartmentId: apartment.id,
                                          ),
                                    ),
                                  );
                                  _loadData();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: apartment.isApproved
                                ? const Color(0xFF4a90e2)
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            apartment.isApproved ? 'Manage' : 'Pending',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingRequests() {
    if (_bookingRequests.isEmpty) {
      return const Center(
        child: Text(
          'No booking requests',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _bookingRequests.length,
      itemBuilder: (context, index) =>
          _buildBookingRequestCard(_bookingRequests[index]),
    );
  }

  Widget _buildBookingRequestCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(ref.watch(themeProvider)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(ref.watch(themeProvider)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request['apartment']?['title'] ?? 'Apartment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(ref.watch(themeProvider)),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Guest: ${request['user']?['first_name']} ${request['user']?['last_name']}',
            style: TextStyle(
              color: AppTheme.getSubtextColor(ref.watch(themeProvider)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dates: ${request['check_in']} to ${request['check_out']}',
            style: TextStyle(
              color: AppTheme.getSubtextColor(ref.watch(themeProvider)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '\$${request['total_price']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFff6f2d),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _approveRequest(request['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Approve',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _rejectRequest(request['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reject',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _approveRequest(String requestId) async {
    // Optimistically update UI
    final requestIndex = _bookingRequests.indexWhere(
      (req) => req['id'].toString() == requestId,
    );
    if (requestIndex != -1) {
      setState(() {
        _bookingRequests[requestIndex]['status'] = 'approved';
      });
    }

    try {
      final result = await _apiService.approveBookingRequest(requestId);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request approved'),
            backgroundColor: Colors.green,
          ),
        );
        // Remove from pending list
        if (requestIndex != -1) {
          setState(() {
            _bookingRequests.removeAt(requestIndex);
          });
        }
      } else {
        // Revert on failure
        if (requestIndex != -1) {
          setState(() {
            _bookingRequests[requestIndex]['status'] = 'pending';
          });
        }
      }
    } catch (e) {
      // Revert on error
      if (requestIndex != -1) {
        setState(() {
          _bookingRequests[requestIndex]['status'] = 'pending';
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to approve request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    // Optimistically update UI
    final requestIndex = _bookingRequests.indexWhere(
      (req) => req['id'].toString() == requestId,
    );
    if (requestIndex != -1) {
      setState(() {
        _bookingRequests[requestIndex]['status'] = 'rejected';
      });
    }

    try {
      final result = await _apiService.rejectBookingRequest(requestId);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request rejected'),
            backgroundColor: Colors.orange,
          ),
        );
        // Remove from pending list
        if (requestIndex != -1) {
          setState(() {
            _bookingRequests.removeAt(requestIndex);
          });
        }
      } else {
        // Revert on failure
        if (requestIndex != -1) {
          setState(() {
            _bookingRequests[requestIndex]['status'] = 'pending';
          });
        }
      }
    } catch (e) {
      // Revert on error
      if (requestIndex != -1) {
        setState(() {
          _bookingRequests[requestIndex]['status'] = 'pending';
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildApartmentImage(Apartment apartment) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFff6f2d),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[600],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Image not available',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                color: Colors.grey[600],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No images added',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusBadge(Apartment apartment) {
    Color color;
    String text;

    if (!apartment.isApproved) {
      switch (apartment.status) {
        case 'pending':
          color = Colors.orange;
          text = 'Pending Approval';
          break;
        case 'rejected':
          color = Colors.red;
          text = 'Rejected';
          break;
        default:
          color = Colors.orange;
          text = 'Under Review';
      }
    } else {
      color = apartment.isAvailable ? Colors.green : Colors.red;
      text = apartment.isAvailable ? 'Available' : 'Booked';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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
                        const Color(0xFF4a90e2).withOpacity(isDark ? 0.3 : 0.1),
                        const Color(
                          0xFFff6f2d,
                        ).withOpacity(isDark ? 0.2 : 0.05),
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
                        const Color(0xFFff6f2d).withOpacity(isDark ? 0.4 : 0.1),
                        const Color(
                          0xFF4a90e2,
                        ).withOpacity(isDark ? 0.3 : 0.08),
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

  Future<void> _editApartment(Apartment apartment) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit apartment feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _deleteApartment(String apartmentId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(ref.watch(themeProvider)),
        title: Text(
          'Delete Apartment',
          style: TextStyle(
            color: AppTheme.getTextColor(ref.watch(themeProvider)),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$title"?',
          style: TextStyle(
            color: AppTheme.getTextColor(ref.watch(themeProvider)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.getSubtextColor(ref.watch(themeProvider)),
              ),
            ),
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
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Apartment deleted successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete apartment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete apartment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void refreshData() => _loadBookingRequests(); // Only refresh booking requests

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }
}
