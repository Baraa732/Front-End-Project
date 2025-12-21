import 'package:flutter/material.dart';
import '../../../core/core.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin, RealTimeRefreshMixin {
  final _apiService = ApiService();
  late TabController _tabController;
  
  List<dynamic> _bookingRequests = [];
  List<dynamic> _confirmedBookings = [];
  bool _isLoadingRequests = true;
  bool _isLoadingBookings = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    startRealTimeRefresh();
  }

  @override
  void refreshData() => _loadData();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadBookingRequests(),
      _loadConfirmedBookings(),
    ]);
  }

  Future<void> _loadBookingRequests() async {
    setState(() => _isLoadingRequests = true);
    try {
      final result = await _apiService.getMyBookingRequests();
      if (result['success'] == true) {
        setState(() {
          _bookingRequests = result['data'] ?? [];
          _isLoadingRequests = false;
        });
      } else {
        setState(() => _isLoadingRequests = false);
      }
    } catch (e) {
      setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _loadConfirmedBookings() async {
    setState(() => _isLoadingBookings = true);
    try {
      final result = await _apiService.getMyBookings();
      if (result['success'] == true) {
        setState(() {
          _confirmedBookings = result['data'] ?? [];
          _isLoadingBookings = false;
        });
      } else {
        setState(() => _isLoadingBookings = false);
      }
    } catch (e) {
      setState(() => _isLoadingBookings = false);
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
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingRequestsTab(),
                    _buildConfirmedBookingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            'My Bookings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFFff6f2d),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        tabs: const [
          Tab(text: 'Requests'),
          Tab(text: 'Confirmed'),
        ],
      ),
    );
  }

  Widget _buildBookingRequestsTab() {
    if (_isLoadingRequests) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d)));
    }

    if (_bookingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No Booking Requests',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booking requests will appear here',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookingRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookingRequests.length,
        itemBuilder: (context, index) {
          final request = _bookingRequests[index];
          return _buildBookingRequestCard(request);
        },
      ),
    );
  }

  Widget _buildConfirmedBookingsTab() {
    if (_isLoadingBookings) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d)));
    }

    if (_confirmedBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No Confirmed Bookings',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Your confirmed bookings will appear here',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConfirmedBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _confirmedBookings.length,
        itemBuilder: (context, index) {
          final booking = _confirmedBookings[index];
          return _buildConfirmedBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingRequestCard(Map<String, dynamic> request) {
    final apartment = request['apartment'] ?? {};
    final status = request['status'] ?? 'pending';
    
    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF10B981);
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFFf59e0b);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
                  apartment['title'] ?? 'Apartment',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.6), size: 16),
              const SizedBox(width: 8),
              Text(
                '${request['check_in']} - ${request['check_out']}',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, color: Colors.white.withOpacity(0.6), size: 16),
              const SizedBox(width: 8),
              Text(
                '${request['guests']} guests',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              const Spacer(),
              Text(
                'EGP ${request['total_price']}',
                style: const TextStyle(color: Color(0xFFff6f2d), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (request['message'] != null && request['message'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Message: ${request['message']}',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmedBookingCard(Map<String, dynamic> booking) {
    final apartment = booking['apartment'] ?? {};
    final status = booking['status'] ?? 'confirmed';
    
    Color statusColor;
    switch (status) {
      case 'confirmed':
        statusColor = const Color(0xFF10B981);
        break;
      case 'completed':
        statusColor = const Color(0xFF6366f1);
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFFf59e0b);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
                  apartment['title'] ?? 'Apartment',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white.withOpacity(0.6), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  apartment['address'] ?? 'Address not available',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.6), size: 16),
              const SizedBox(width: 8),
              Text(
                '${booking['check_in']} - ${booking['check_out']}',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.white.withOpacity(0.6), size: 16),
              const SizedBox(width: 8),
              Text(
                'Total: EGP ${booking['total_price']}',
                style: const TextStyle(color: Color(0xFFff6f2d), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
