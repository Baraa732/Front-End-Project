import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/connection_manager.dart';

class CreateBookingScreen extends StatefulWidget {
  final Map<String, dynamic> apartment;

  const CreateBookingScreen({super.key, required this.apartment});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _checkInController = TextEditingController();
  final _checkOutController = TextEditingController();
  final _guestsController = TextEditingController(text: '1');
  final _messageController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _totalDays = 0;
  double _totalPrice = 0;

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    _guestsController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectCheckInDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFff6f2d),
              surface: Color(0xFF17173a),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() {
        _checkInDate = date;
        _checkInController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        _calculateTotal();
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final minDate = _checkInDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 2));
    
    final date = await showDatePicker(
      context: context,
      initialDate: minDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFff6f2d),
              surface: Color(0xFF17173a),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() {
        _checkOutDate = date;
        _checkOutController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        _calculateTotal();
      });
    }
  }

  void _calculateTotal() {
    if (_checkInDate != null && _checkOutDate != null) {
      _totalDays = _checkOutDate!.difference(_checkInDate!).inDays;
      final pricePerNight = widget.apartment['price_per_night'] ?? widget.apartment['price'] ?? 0;
      _totalPrice = _totalDays * double.parse(pricePerNight.toString());
    }
  }

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.createBookingRequest(
        apartmentId: widget.apartment['id'].toString(),
        checkIn: _checkInController.text,
        checkOut: _checkOutController.text,
        guests: int.parse(_guestsController.text),
        message: _messageController.text.isNotEmpty ? _messageController.text : null,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Booking request sent successfully'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to create booking'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildApartmentInfo(),
                        const SizedBox(height: 24),
                        _buildDateFields(),
                        const SizedBox(height: 16),
                        _buildGuestsField(),
                        const SizedBox(height: 16),
                        _buildMessageField(),
                        const SizedBox(height: 24),
                        _buildPricingSummary(),
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
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildApartmentInfo() {
    final images = List<String>.from(widget.apartment['images'] ?? []);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: images.isNotEmpty
                ? Image.network(
                    images.first,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey,
                      child: const Icon(Icons.image, color: Colors.white),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey,
                    child: const Icon(Icons.image, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.apartment['title'] ?? 'Apartment',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.apartment['city'] ?? ''}, ${widget.apartment['governorate'] ?? ''}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${widget.apartment['price'] ?? 0}/night',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFff6f2d)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFields() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectCheckInDate,
            child: AbsorbPointer(
              child: TextFormField(
                controller: _checkInController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Check-in Date',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFff6f2d)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFff6f2d), width: 2),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Check-in date is required' : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _selectCheckOutDate,
            child: AbsorbPointer(
              child: TextFormField(
                controller: _checkOutController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Check-out Date',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFff6f2d)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFff6f2d), width: 2),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Check-out date is required' : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestsField() {
    return TextFormField(
      controller: _guestsController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Number of Guests',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        prefixIcon: const Icon(Icons.people, color: Color(0xFFff6f2d)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFff6f2d), width: 2),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Number of guests is required';
        final guests = int.tryParse(value!);
        if (guests == null || guests < 1) return 'Please enter a valid number of guests';
        return null;
      },
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      maxLines: 3,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Message to Landlord (Optional)',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        prefixIcon: const Icon(Icons.message, color: Color(0xFFff6f2d)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFff6f2d), width: 2),
        ),
      ),
    );
  }

  Widget _buildPricingSummary() {
    if (_totalDays == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFff6f2d).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFff6f2d).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Duration:', style: TextStyle(color: Colors.white.withOpacity(0.8))),
              Text('$_totalDays nights', style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price per night:', style: TextStyle(color: Colors.white.withOpacity(0.8))),
              Text('\$${widget.apartment['price'] ?? 0}', style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Guests:', style: TextStyle(color: Colors.white.withOpacity(0.8))),
              Text(_guestsController.text, style: const TextStyle(color: Colors.white)),
            ],
          ),
          const Divider(color: Colors.white),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('\$${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFff6f2d))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFff6f2d),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Send Booking Request',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
      ),
    );
  }
}