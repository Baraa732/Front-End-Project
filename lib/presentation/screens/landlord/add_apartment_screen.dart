import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/core.dart';

class AddApartmentScreen extends StatefulWidget {
  final Map<String, dynamic>? apartment;
  final bool isEdit;

  const AddApartmentScreen({super.key, this.apartment, this.isEdit = false});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();
  final _guestsController = TextEditingController(text: '2');
  final _apiService = ApiService();
  final _picker = ImagePicker();

  String _selectedGovernorate = 'Cairo';
  String _selectedCity = 'Cairo';
  List<File> _selectedImages = [];
  List<String> _existingImages = [];
  List<String> _selectedFeatures = [];
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  final List<String> _governorates = ['Cairo', 'Giza', 'Alexandria', 'Luxor', 'Aswan'];
  final Map<String, List<String>> _cities = {
    'Cairo': ['Cairo', 'New Cairo', 'Heliopolis', 'Maadi', 'Zamalek'],
    'Giza': ['Giza', '6th October', 'Sheikh Zayed', 'Dokki', 'Mohandessin'],
    'Alexandria': ['Alexandria', 'Borg El Arab', 'Agami', 'Montaza'],
    'Luxor': ['Luxor', 'Karnak', 'West Bank'],
    'Aswan': ['Aswan', 'Abu Simbel', 'Kom Ombo']
  };

  final List<Map<String, String>> _availableFeatures = [
    {'value': 'wifi', 'label': 'WiFi'},
    {'value': 'air_conditioning', 'label': 'Air Conditioning'},
    {'value': 'heating', 'label': 'Heating'},
    {'value': 'kitchen', 'label': 'Kitchen'},
    {'value': 'washing_machine', 'label': 'Washing Machine'},
    {'value': 'parking', 'label': 'Parking'},
    {'value': 'balcony', 'label': 'Balcony'},
    {'value': 'elevator', 'label': 'Elevator'},
    {'value': 'security', 'label': 'Security'},
    {'value': 'furnished', 'label': 'Furnished'},
    {'value': 'pet_friendly', 'label': 'Pet Friendly'},
    {'value': 'swimming_pool', 'label': 'Swimming Pool'},
    {'value': 'gym', 'label': 'Gym'},
    {'value': 'garden', 'label': 'Garden'},
    {'value': 'terrace', 'label': 'Terrace'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.apartment != null) {
      _initializeEditMode();
    }
  }

  void _initializeEditMode() {
    final apt = widget.apartment!;
    _titleController.text = apt['title'] ?? '';
    _descriptionController.text = apt['description'] ?? '';
    _addressController.text = apt['address'] ?? '';
    _priceController.text = apt['price']?.toString() ?? '';
    _bedroomsController.text = apt['bedrooms']?.toString() ?? '';
    _bathroomsController.text = apt['bathrooms']?.toString() ?? '';
    _areaController.text = apt['area']?.toString() ?? '';
    _guestsController.text = apt['max_guests']?.toString() ?? '2';
    _selectedGovernorate = apt['governorate'] ?? 'Cairo';
    _selectedCity = apt['city'] ?? 'Cairo';
    _existingImages = List<String>.from(apt['images'] ?? []);
    _selectedFeatures = List<String>.from(apt['features'] ?? []);
    _latitude = apt['latitude'];
    _longitude = apt['longitude'];
    
    // Debug selected features
    print('🔧 Initialized features: $_selectedFeatures');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  void _showLocationDialog() {
    final latController = TextEditingController(text: _latitude?.toString() ?? '');
    final lngController = TextEditingController(text: _longitude?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF17173a),
        title: const Text('Set Location', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _latitude = double.tryParse(latController.text);
                _longitude = double.tryParse(lngController.text);
              });
              Navigator.pop(context);
            },
            child: const Text('Set', style: TextStyle(color: Color(0xFFff6f2d))),
          ),
        ],
      ),
    );
  }

  Future<void> _saveApartment() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedImages.isEmpty && _existingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🏠 Starting apartment save process...');
      final apartmentData = _getApartmentData();
      print('📊 Apartment data: $apartmentData');
      print('🔍 Features being sent: ${apartmentData['features']}');
      print('🔍 Features type: ${apartmentData['features'].runtimeType}');
      print('📸 Selected images: ${_selectedImages.length}');
      
      Map<String, dynamic> result;
      
      if (widget.isEdit) {
        print('✏️ Updating apartment: ${widget.apartment!['id']}');
        result = await _apiService.updateApartment(
          apartmentId: widget.apartment!['id'].toString(),
          apartmentData: _getApartmentData(),
          images: _selectedImages,
        );
      } else {
        print('➕ Creating new apartment...');
        result = await _apiService.createApartment(
          apartmentData: _getApartmentData(),
          images: _selectedImages,
        );
      }
      
      // Cache images after successful save
      if (result['success'] == true && result['data'] != null) {
        final apartmentData = result['data'];
        if (apartmentData['images'] != null) {
          final imageUrls = List<String>.from(apartmentData['images']);
          for (String imageUrl in imageUrls) {
            try {
              final imageCacheService = ImageCacheService();
              await imageCacheService.cacheImage(imageUrl);
            } catch (e) {
              print('Failed to cache image $imageUrl: $e');
            }
          }
        }
      }

      print('📋 API Result: $result');
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Apartment saved successfully'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      } else {
        // Extract detailed error message
        String errorMessage = result['message'] ?? 'Failed to save apartment';
        
        // Check for validation errors in the response
        if (result['data'] != null && result['data']['errors'] != null) {
          final errors = result['data']['errors'] as Map<String, dynamic>;
          final errorList = <String>[];
          errors.forEach((field, messages) {
            if (messages is List) {
              errorList.addAll(messages.map((msg) => '$field: $msg'));
            } else {
              errorList.add('$field: $messages');
            }
          });
          if (errorList.isNotEmpty) {
            errorMessage = errorList.join('\n');
          }
        }
        
        print('❌ Save failed: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('💥 Exception occurred: $e');
      print('📍 Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  Map<String, dynamic> _getApartmentData() {
    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'address': _addressController.text.trim(),
      'governorate': _selectedGovernorate,
      'city': _selectedCity,
      'price_per_night': double.parse(_priceController.text),
      'max_guests': int.parse(_guestsController.text),
      'rooms': int.parse(_bedroomsController.text),
      'bedrooms': int.parse(_bedroomsController.text),
      'bathrooms': int.parse(_bathroomsController.text),
      'area': double.parse(_areaController.text),
      'features': _selectedFeatures,
    };
    print('🔧 Final apartment data features: ${data['features']}');
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                        _buildTextField(_titleController, 'Apartment Title', Icons.home),
                        const SizedBox(height: 16),
                        _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),
                        const SizedBox(height: 16),
                        _buildTextField(_addressController, 'Address', Icons.location_on),
                        const SizedBox(height: 16),
                        _buildLocationDropdowns(),
                        const SizedBox(height: 16),
                        _buildLocationPicker(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_priceController, 'Price per Night (EGP)', Icons.attach_money, keyboardType: TextInputType.number)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(_guestsController, 'Max Guests', Icons.people, keyboardType: TextInputType.number)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_areaController, 'Area (m²)', Icons.square_foot, keyboardType: TextInputType.number)),
                            const SizedBox(width: 16),
                            Expanded(child: Container()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_bedroomsController, 'Bedrooms', Icons.bed, keyboardType: TextInputType.number)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(_bathroomsController, 'Bathrooms', Icons.bathtub, keyboardType: TextInputType.number)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildFeaturesSection(),
                        const SizedBox(height: 24),
                        _buildImagesSection(),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
              ).createShader(bounds),
              child: Text(
                widget.isEdit ? 'Edit Apartment' : 'Add Apartment',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
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
        validator: (value) => value?.isEmpty ?? true ? '$label is required' : null,
      ),
    );
  }

  Widget _buildLocationDropdowns() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGovernorate,
                dropdownColor: const Color(0xFF17173a),
                style: const TextStyle(color: Colors.white),
                items: _governorates.map((gov) => DropdownMenuItem(value: gov, child: Text(gov))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGovernorate = value!;
                    _selectedCity = _cities[value]!.first;
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
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                dropdownColor: const Color(0xFF17173a),
                style: const TextStyle(color: Colors.white),
                items: _cities[_selectedGovernorate]!.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                onChanged: (value) => setState(() => _selectedCity = value!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPicker() {
    return GestureDetector(
      onTap: _showLocationDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _latitude != null ? const Color(0xFFff6f2d) : Colors.white.withOpacity(0.2), width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: _latitude != null ? const Color(0xFFff6f2d) : Colors.white.withOpacity(0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _latitude != null ? 'Location Set (${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})' : 'Set Location Coordinates',
                style: TextStyle(color: _latitude != null ? const Color(0xFFff6f2d) : Colors.white.withOpacity(0.8)),
              ),
            ),
            Icon(Icons.edit, color: Colors.white.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableFeatures.map((feature) {
            final isSelected = _selectedFeatures.contains(feature['value']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedFeatures.remove(feature['value']);
                    print('🔧 Removed feature: ${feature['value']}');
                  } else {
                    _selectedFeatures.add(feature['value']!);
                    print('🔧 Added feature: ${feature['value']}');
                  }
                  print('🔧 Current features: $_selectedFeatures');
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFff6f2d) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? const Color(0xFFff6f2d) : Colors.white.withOpacity(0.2)),
                ),
                child: Text(feature['label']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Images', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const Spacer(),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate, color: Color(0xFFff6f2d)),
              label: const Text('Add Images', style: TextStyle(color: Color(0xFFff6f2d))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_existingImages.isNotEmpty || _selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._existingImages.map((url) => _buildImageItem(url, true)),
                ..._selectedImages.map((file) => _buildImageItem(file.path, false)),
              ],
            ),
          )
        else
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Center(
              child: Text('No images selected', style: TextStyle(color: Colors.white.withOpacity(0.7))),
            ),
          ),
      ],
    );
  }

  Widget _buildImageItem(String imagePath, bool isExisting) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isExisting
                ? Image.network(imagePath, width: 100, height: 100, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey))
                : Image.file(File(imagePath), width: 100, height: 100, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isExisting) {
                    _existingImages.remove(imagePath);
                  } else {
                    _selectedImages.removeWhere((file) => file.path == imagePath);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
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
        onPressed: _isLoading ? null : _saveApartment,
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
                widget.isEdit ? 'Update Apartment' : 'Add Apartment',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
