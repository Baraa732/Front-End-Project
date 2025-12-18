import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/error_handler.dart';
import 'main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  final _governorateController = TextEditingController();
  DateTime? _selectedBirthDate;
  
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentPage = 0;
  String _selectedRole = 'tenant';
  String? _selectedGovernorate;
  String? _selectedCity;
  File? _profileImage;
  File? _idImage;
  final ImagePicker _picker = ImagePicker();
  
  final List<String> _governorates = ['Damascus', 'Aleppo', 'Homs', 'Hama', 'Lattakia', 'Tartus', 'Idlib', 'Daraa', 'Deir ez-Zor', 'Al-Hasakah', 'Ar-Raqqa', 'As-Suwayda', 'Quneitra', 'Damascus Countryside'];
  final Map<String, List<String>> _cities = {
    'Damascus': ['Damascus', 'Jaramana', 'Sahnaya', 'Harasta', 'Douma'],
    'Aleppo': ['Aleppo', 'Afrin', 'Al-Bab', 'Azaz', 'Manbij'],
    'Homs': ['Homs', 'Palmyra', 'Qusayr', 'Talkalakh'],
    'Hama': ['Hama', 'Salamiyah', 'Suqaylabiyah', 'Masyaf'],
    'Lattakia': ['Lattakia', 'Jableh', 'Qardaha'],
    'Tartus': ['Tartus', 'Banias', 'Safita'],
    'Idlib': ['Idlib', 'Jisr al-Shughur', 'Maarat al-Numan'],
    'Daraa': ['Daraa', 'Izra', 'Nawa'],
    'Deir ez-Zor': ['Deir ez-Zor', 'Mayadin', 'Al-Bukamal'],
    'Al-Hasakah': ['Al-Hasakah', 'Qamishli', 'Ras al-Ayn'],
    'Ar-Raqqa': ['Ar-Raqqa', 'Tell Abiad'],
    'As-Suwayda': ['As-Suwayda', 'Shahba'],
    'Quneitra': ['Quneitra'],
    'Damascus Countryside': ['Zabadani', 'Qatana', 'Yabroud', 'Rankous']
  };
  
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_backgroundController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();
    _governorateController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _formKey1.currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage = 1);
    }
  }

  void _previousPage() {
    if (_currentPage == 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage = 0);
    }
  }

  Future<void> _register() async {
    if (!_formKey2.currentState!.validate()) return;
    
    // Validate required fields
    if (_selectedGovernorate == null) {
      _showDetailedError('Please select a governorate');
      return;
    }
    
    if (_selectedCity == null) {
      _showDetailedError('Please select a city');
      return;
    }
    
    if (_selectedBirthDate == null) {
      _showDetailedError('Please select your birth date');
      return;
    }
    
    if (_profileImage == null) {
      _showDetailedError('Please upload a profile image');
      return;
    }
    
    if (_idImage == null) {
      _showDetailedError('Please upload an ID image');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simple test registration with minimal data
      final testData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'password_confirmation': _passwordController.text,
        'role': _selectedRole,
        'city': _selectedCity,
        'governorate': _selectedGovernorate,
      };
      
      print('🚀 Registration data: $testData');
      
      final result = await _authService.register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
        _selectedRole,
        _selectedCity ?? '',
        _selectedGovernorate ?? '',
        birthDate: _selectedBirthDate,
        profileImage: _profileImage,
        idImage: _idImage,
      );

      print('📋 Registration result: $result');

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        // Show success message if offline mode
        if (result['message']?.contains('Offline Mode') == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.offline_bolt, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Registered in offline mode')),
                ],
              ),
              backgroundColor: const Color(0xFF4a90e2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        
        _showRegistrationSuccessDialog();
      } else {
        print('❌ Registration failed: ${result['message']}');
        print('📊 Full result data: ${result['data']}');
        
        String errorMessage = result['message'] ?? 'Registration failed';
        
        // Handle specific database connection errors
        if (result['data'] != null && result['data']['message'] != null) {
          String serverMessage = result['data']['message'];
          if (serverMessage.contains('SQLSTATE') || serverMessage.contains('Connection refused') || serverMessage.contains('database')) {
            errorMessage = 'Database connection failed. The server database is not available. Please try again later or check your internet connection.';
          } else if (serverMessage.contains('phone') && serverMessage.contains('taken')) {
            errorMessage = 'This phone number is already registered. Please use a different number or try logging in.';
          }
        }
        
        // Check for validation errors
        if (result['data'] != null && result['data']['errors'] != null) {
          final errors = result['data']['errors'] as Map<String, dynamic>;
          final errorList = <String>[];
          errors.forEach((field, messages) {
            if (messages is List) {
              errorList.addAll(messages.map((msg) => '• $field: $msg'));
            } else {
              errorList.add('• $field: $messages');
            }
          });
          if (errorList.isNotEmpty) {
            errorMessage = errorList.join('\n');
          }
        }
        
        _showDetailedError(errorMessage);
      }
    } catch (e, stackTrace) {
      print('💥 Registration exception: $e');
      print('📍 Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Show more detailed error information
      String errorMsg = 'Registration failed: ${e.toString()}';
      if (e.toString().contains('Connection') || e.toString().contains('timeout')) {
        errorMsg = 'Cannot connect to server. Please check your internet connection and try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMsg = 'Server returned invalid response. Please try again later.';
      }
      
      _showDetailedError(errorMsg);
    }
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF17173a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            const Text('Registration Successful', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Your account has been created successfully!\n\nPlease wait for admin approval before you can login. You will be notified once your account is approved.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFFff6f2d))),
          ),
        ],
      ),
    );
  }

  void _showDetailedError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF17173a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            const Text('Registration Error', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFff6f2d))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0e1330), Color(0xFF17173a)],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _buildHeader(),
                          _buildProgressIndicator(),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildPage1(),
                                _buildPage2(),
                              ],
                            ),
                          ),
                          _buildNavigationButtons(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
                        const Color(0xFFff6f2d).withOpacity(0.3),
                        const Color(0xFF4a90e2).withOpacity(0.2),
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
                        const Color(0xFF4a90e2).withOpacity(0.4),
                        const Color(0xFFff6f2d).withOpacity(0.3),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (_currentPage == 0) {
                    Navigator.pop(context);
                  } else {
                    _previousPage();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                    ).createShader(bounds),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    _currentPage == 0 ? 'Personal Information' : 'Account Details',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
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

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: _currentPage == 1 
                    ? const Color(0xFFff6f2d) 
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField(_firstNameController, 'First Name', Icons.person),
            const SizedBox(height: 16),
            _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildLocationDropdowns(),
            const SizedBox(height: 24),
            _buildRoleSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey2,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSummaryCard(),
            const SizedBox(height: 24),
            _buildBirthDatePicker(),
            const SizedBox(height: 24),
            _buildImageUploadSection(),
            const SizedBox(height: 24),
            _buildPasswordField(_passwordController, 'Password', _obscurePassword, () {
              setState(() => _obscurePassword = !_obscurePassword);
            }),
            const SizedBox(height: 16),
            _buildPasswordField(_confirmPasswordController, 'Confirm Password', _obscureConfirmPassword, () {
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Name', '${_firstNameController.text} ${_lastNameController.text}'),
          _buildSummaryRow('Phone', _phoneController.text),
          _buildSummaryRow('Location', '${_selectedCity ?? 'Not selected'}, ${_selectedGovernorate ?? 'Not selected'}'),
          _buildSummaryRow('Birth Date', _selectedBirthDate != null ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}' : 'Not selected'),
          _buildSummaryRow('Role', _selectedRole.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedRole = 'tenant'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: _selectedRole == 'tenant'
                        ? const LinearGradient(colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)])
                        : LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedRole == 'tenant' ? Colors.transparent : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tenant',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedRole = 'landlord'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: _selectedRole == 'landlord'
                        ? const LinearGradient(colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)])
                        : LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedRole == 'landlord' ? Colors.transparent : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.home_work,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Landlord',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return '$label is required';
            if (label == 'Phone Number' && !RegExp(r'^09[0-9]{8}$').hasMatch(value!)) {
              return 'Please enter a valid Syrian phone number (09xxxxxxxx)';
            }
            if ((label == 'First Name' || label == 'Last Name') && value!.length < 2) {
              return '$label must be at least 2 characters';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool obscure, VoidCallback toggle) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4a90e2), Color(0xFFff6f2d)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock, color: Colors.white, size: 20),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withOpacity(0.6),
              ),
              onPressed: toggle,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return '$label is required';
            if (label == 'Password' && value!.length < 6) {
              return 'Password must be at least 6 characters';
            }
            if (label == 'Confirm Password' && value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Images',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildImageUploadCard(
                'Profile Photo',
                Icons.person,
                _profileImage,
                () => _pickImage(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImageUploadCard(
                'ID Image',
                Icons.credit_card,
                _idImage,
                () => _pickImage(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageUploadCard(String title, IconData icon, File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.file(
                      image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to upload',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage(bool isProfile) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(image.path);
            print('📷 Profile image selected: ${image.path}');
          } else {
            _idImage = File(image.path);
            print('🆔 ID image selected: ${image.path}');
          }
        });
      }
    } catch (e) {
      print('❌ Image picker error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBirthDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedBirthDate ?? DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)), // Must be 16+
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
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
          setState(() => _selectedBirthDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _selectedBirthDate != null ? const Color(0xFFff6f2d) : Colors.white.withOpacity(0.2), width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.cake, color: _selectedBirthDate != null ? const Color(0xFFff6f2d) : Colors.white.withOpacity(0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedBirthDate != null 
                    ? 'Birth Date: ${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                    : 'Select Birth Date (Required)',
                style: TextStyle(color: _selectedBirthDate != null ? const Color(0xFFff6f2d) : Colors.white.withOpacity(0.8)),
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdowns() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGovernorate,
                    dropdownColor: const Color(0xFF17173a),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    isExpanded: true,
                    hint: const Text('Select Governorate', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    items: _governorates.map((gov) => DropdownMenuItem(
                      value: gov, 
                      child: Text(gov, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGovernorate = value;
                        _selectedCity = null; // Reset city when governorate changes
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    dropdownColor: const Color(0xFF17173a),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    isExpanded: true,
                    hint: const Text('Select City', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    items: _selectedGovernorate != null 
                        ? _cities[_selectedGovernorate]!.map((city) => DropdownMenuItem(
                            value: city, 
                            child: Text(city, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)
                          )).toList()
                        : [],
                    onChanged: _selectedGovernorate != null 
                        ? (value) => setState(() => _selectedCity = value)
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFff6f2d).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : (_currentPage == 0 ? _nextPage : _register),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    _currentPage == 0 ? 'Next' : 'Create Account',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
