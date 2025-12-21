import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/core.dart';
import '../../../presentation/widgets/common/animated_input_field.dart'; // Import the AnimatedInputField

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

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
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
        String errorMessage = result['message'] ?? 'Registration failed';

        if (result['data'] != null && result['data']['message'] != null) {
          String serverMessage = result['data']['message'];
          if (serverMessage.contains('SQLSTATE') || serverMessage.contains('Connection refused') || serverMessage.contains('database')) {
            errorMessage = 'Database connection failed. The server database is not available. Please try again later or check your internet connection.';
          } else if (serverMessage.contains('phone') && serverMessage.contains('taken')) {
            errorMessage = 'This phone number is already registered. Please use a different number or try logging in.';
          }
        }

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
      if (!mounted) return;
      setState(() => _isLoading = false);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Text(
              'Registration Successful',
              style: TextStyle(
                color: AppTheme.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Your account has been created successfully!\n\nPlease wait for admin approval before you can login. You will be notified once your account is approved.',
          style: TextStyle(
            color: AppTheme.getSubtextColor(isDark),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.primaryPink),
            const SizedBox(width: 8),
            Text(
              'Registration Error',
              style: TextStyle(
                color: AppTheme.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: TextStyle(
              color: AppTheme.getSubtextColor(isDark),
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(isDark),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(isDark),
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
                          _buildHeader(isDark),
                          _buildProgressIndicator(isDark),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildPage1(isDark),
                                _buildPage2(isDark),
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
                        AppTheme.primaryOrange.withOpacity(isDark ? 0.3 : 0.1),
                        AppTheme.primaryBlue.withOpacity(isDark ? 0.2 : 0.05),
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
                        AppTheme.primaryBlue.withOpacity(isDark ? 0.4 : 0.1),
                        AppTheme.primaryOrange.withOpacity(isDark ? 0.3 : 0.08),
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

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.getBorderColor(isDark)),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.getTextColor(isDark)),
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
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextColor(isDark),
                      ),
                    ),
                  ),
                  Text(
                    _currentPage == 0 ? 'Personal Information' : 'Account Details',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.getSubtextColor(isDark),
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

  Widget _buildProgressIndicator(bool isDark) {
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
                    : AppTheme.getBorderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // First Name with AnimatedInputField
            AnimatedInputField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person,
              isDark: isDark,
              hintText: 'Enter your first name',
              primaryColor: AppTheme.primaryOrange,
              secondaryColor: AppTheme.primaryBlue,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'First name is required';
                }
                if (value!.length < 2) {
                  return 'Must be at least 2 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Last Name with AnimatedInputField
            AnimatedInputField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline,
              isDark: isDark,
              hintText: 'Enter your last name',
              primaryColor: AppTheme.primaryOrange,
              secondaryColor: AppTheme.primaryBlue,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Last name is required';
                }
                if (value!.length < 2) {
                  return 'Must be at least 2 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Phone Number with AnimatedInputField
            AnimatedInputField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              isDark: isDark,
              hintText: '09xxxxxxxx',
              primaryColor: AppTheme.primaryOrange,
              secondaryColor: AppTheme.primaryBlue,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Phone number is required';
                }
                if (!RegExp(r'^09[0-9]{8}$').hasMatch(value!)) {
                  return 'Please enter a valid Syrian phone number (09xxxxxxxx)';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Location dropdowns
            _buildLocationDropdowns(isDark),

            const SizedBox(height: 24),

            // Role selector with fixed label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Text(
                    'I am a',
                    style: TextStyle(
                      color: AppTheme.getTextColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _buildRoleSelector(isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey2,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSummaryCard(isDark),
            const SizedBox(height: 24),
            _buildBirthDatePicker(isDark),
            const SizedBox(height: 24),
            _buildImageUploadSection(isDark),
            const SizedBox(height: 24),

            // Password with AnimatedInputField
            AnimatedInputField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              isDark: isDark,
              hintText: 'Enter your password',
              obscureText: _obscurePassword,
              primaryColor: AppTheme.primaryBlue,
              secondaryColor: AppTheme.primaryOrange,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Password is required';
                }
                if (value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              onTap: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),

            const SizedBox(height: 20),

            // Confirm Password with AnimatedInputField
            AnimatedInputField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              isDark: isDark,
              hintText: 'Confirm your password',
              obscureText: _obscureConfirmPassword,
              primaryColor: AppTheme.primaryBlue,
              secondaryColor: AppTheme.primaryOrange,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              onTap: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightCard,
            isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightCard,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.getBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Name', '${_firstNameController.text} ${_lastNameController.text}', isDark),
          _buildSummaryRow('Phone', _phoneController.text, isDark),
          _buildSummaryRow('Location', '${_selectedCity ?? 'Not selected'}, ${_selectedGovernorate ?? 'Not selected'}', isDark),
          _buildSummaryRow('Birth Date', _selectedBirthDate != null ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}' : 'Not selected', isDark),
          _buildSummaryRow('Role', _selectedRole.toUpperCase(), isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
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
                color: AppTheme.getSubtextColor(isDark),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.getTextColor(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        : LinearGradient(colors: [
                      isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightCard,
                      isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightCard,
                    ]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedRole == 'tenant'
                          ? Colors.transparent
                          : AppTheme.getBorderColor(isDark),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        color: _selectedRole == 'tenant' ? Colors.white : AppTheme.getTextColor(isDark),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tenant',
                        style: TextStyle(
                          color: _selectedRole == 'tenant' ? Colors.white : AppTheme.getTextColor(isDark),
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
                        : LinearGradient(colors: [
                      isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightCard,
                      isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightCard,
                    ]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedRole == 'landlord'
                          ? Colors.transparent
                          : AppTheme.getBorderColor(isDark),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.home_work,
                        color: _selectedRole == 'landlord' ? Colors.white : AppTheme.getTextColor(isDark),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Landlord',
                        style: TextStyle(
                          color: _selectedRole == 'landlord' ? Colors.white : AppTheme.getTextColor(isDark),
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

  Widget _buildImageUploadSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'Upload Images',
            style: TextStyle(
              color: AppTheme.getTextColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImageUploadCard(
                'ID Image',
                Icons.credit_card,
                _idImage,
                    () => _pickImage(false),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageUploadCard(String title, IconData icon, File? image, VoidCallback onTap, {required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightCard,
              isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightCard,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.getBorderColor(isDark)),
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
                  child: Icon(
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
                color: AppTheme.getTextColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to upload',
              style: TextStyle(
                color: AppTheme.getSubtextColor(isDark),
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
          } else {
            _idImage = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBirthDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'Birth Date',
            style: TextStyle(
              color: AppTheme.getTextColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedBirthDate ?? DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
              builder: (context, child) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: AppTheme.primaryOrange,
                      surface: AppTheme.getCardColor(isDark),
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
                  isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightCard,
                  isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightCard,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _selectedBirthDate != null
                      ? AppTheme.primaryOrange
                      : AppTheme.getBorderColor(isDark),
                  width: 2
              ),
            ),
            child: Row(
              children: [
                Icon(
                    Icons.cake,
                    color: _selectedBirthDate != null
                        ? AppTheme.primaryOrange
                        : AppTheme.getSubtextColor(isDark)
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedBirthDate != null
                        ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                        : 'Select your birth date (must be 16+)',
                    style: TextStyle(
                        color: _selectedBirthDate != null
                            ? AppTheme.primaryOrange
                            : AppTheme.getSubtextColor(isDark)
                    ),
                  ),
                ),
                Icon(
                    Icons.calendar_today,
                    color: AppTheme.getSubtextColor(isDark),
                    size: 16
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdowns(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'Location',
            style: TextStyle(
              color: AppTheme.getTextColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightCard,
                      isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.getBorderColor(isDark)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGovernorate,
                    dropdownColor: AppTheme.getCardColor(isDark),
                    style: TextStyle(color: AppTheme.getTextColor(isDark), fontSize: 14),
                    isExpanded: true,
                    hint: Text(
                        'Select Governorate',
                        style: TextStyle(color: AppTheme.getSubtextColor(isDark), fontSize: 14)
                    ),
                    items: _governorates.map((gov) => DropdownMenuItem(
                        value: gov,
                        child: Text(
                            gov,
                            style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.getTextColor(isDark)
                            ),
                            overflow: TextOverflow.ellipsis
                        )
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGovernorate = value;
                        _selectedCity = null;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightCard,
                      isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.getBorderColor(isDark)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    dropdownColor: AppTheme.getCardColor(isDark),
                    style: TextStyle(color: AppTheme.getTextColor(isDark), fontSize: 14),
                    isExpanded: true,
                    hint: Text(
                        'Select City',
                        style: TextStyle(color: AppTheme.getSubtextColor(isDark), fontSize: 14)
                    ),
                    items: _selectedGovernorate != null
                        ? _cities[_selectedGovernorate]!.map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(
                            city,
                            style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.getTextColor(isDark)
                            ),
                            overflow: TextOverflow.ellipsis
                        )
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
