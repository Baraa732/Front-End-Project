import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../widgets/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final Map<String, dynamic>? user;
  final double size;
  final bool showBorder;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.user,
    this.size = 48,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
          ),
          border: showBorder 
              ? Border.all(color: Colors.white.withOpacity(0.3), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFff6f2d).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildProfileImage(),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final profileImageUrl = user?['profile_image_url'];
    
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profileImageUrl,
        fit: BoxFit.cover,
        placeholder: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: _buildDefaultAvatar(),
      );
    }
    
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    final firstName = user?['first_name'] ?? '';
    final lastName = user?['last_name'] ?? '';
    
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
    
    if (initials.isEmpty) {
      return Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.white,
      );
    }
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}