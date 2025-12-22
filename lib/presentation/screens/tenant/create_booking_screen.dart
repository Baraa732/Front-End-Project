import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/state/state.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> apartment;
  
  const CreateBookingScreen({super.key, required this.apartment});

  @override
  ConsumerState<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guests = 1;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(isDarkMode),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildApartmentInfo(),
                        const SizedBox(height: 24),
                        _buildDateSelection(),
                        const SizedBox(height: 24),
                        _buildGuestSelection(),
                        const SizedBox(height: 24),
                        _buildMessageField(),
                        const SizedBox(height: 24),
                        if (_checkInDate != null && _checkOutDate != null)
                          _buildPriceSummary(),
                        const SizedBox(height: 32),
                        _buildBookButton(),
                      ],
                    ),
                  ),
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
            'Book Apartment',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentInfo() {
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
          Text(
            widget.apartment['title']?.toString() ?? 'Apartment',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.apartment['city']?.toString() ?? ''}, ${widget.apartment['governorate']?.toString() ?? ''}',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${widget.apartment['price_per_night']?.toString() ?? widget.apartment['price']?.toString() ?? '0'}/night',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFff6f2d)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Dates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField('Check-in', _checkInDate, (date) => setState(() => _checkInDate = date)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField('Check-out', _checkOutDate, (date) => setState(() => _checkOutDate = date)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onDateSelected) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              date != null ? '${date.day}/${date.month}/${date.year}' : 'Select date',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Number of Guests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                icon: const Icon(Icons.remove, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  '$_guests guest${_guests > 1 ? 's' : ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _guests++),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Message (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _messageController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Any special requests or questions...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    final pricePerNight = double.tryParse(widget.apartment['price_per_night']?.toString() ?? '0') ?? 0.0;
    final totalPrice = (nights * pricePerNight).toInt();

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
          Row(
            children: [
              Text(
                '\$${pricePerNight.toInt()}/night × $nights nights',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '\$$totalPrice',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '\$$totalPrice',
                style: const TextStyle(color: Color(0xFFff6f2d), fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canBook() ? _bookApartment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Book Now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  bool _canBook() {
    return _checkInDate != null && _checkOutDate != null && !_isLoading;
  }

  Future<void> _bookApartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Creating booking request with data:');
      print('Apartment ID: ${widget.apartment['id']}');
      print('Check-in: ${_checkInDate!.toIso8601String()}');
      print('Check-out: ${_checkOutDate!.toIso8601String()}');
      print('Guests: $_guests');
      print('Message: ${_messageController.text}');
      
      final result = await _apiService.createBookingRequest(
        apartmentId: widget.apartment['id']?.toString() ?? '',
        checkIn: _checkInDate!.toIso8601String(),
        checkOut: _checkOutDate!.toIso8601String(),
        guests: _guests,
        message: _messageController.text.isNotEmpty ? _messageController.text : null,
      );

      print('Booking result: $result');

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Booking request sent successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to create booking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Booking error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}