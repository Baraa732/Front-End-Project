import 'package:flutter/material.dart';

class AnimatedInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool isDark;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool enabled;
  final String? hintText;
  final Color? primaryColor;
  final Color? secondaryColor;

  const AnimatedInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    required this.isDark,
    this.validator,
    this.onTap,
    this.enabled = true,
    this.hintText,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _hasText = widget.controller.text.isNotEmpty;
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onTextChange() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? const Color(0xFFff6f2d);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isDark 
                ? const Color(0xFF1A1A2E).withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            border: Border.all(
              color: _isFocused
                  ? primaryColor
                  : widget.isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            style: TextStyle(
              color: widget.isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hintText,
              labelStyle: TextStyle(
                color: _isFocused
                    ? primaryColor
                    : widget.isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                fontSize: 16,
              ),
              hintStyle: TextStyle(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.grey[400],
                fontSize: 16,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: _isFocused
                    ? primaryColor
                    : widget.isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                size: 22,
              ),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        widget.obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: widget.isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[600],
                        size: 22,
                      ),
                      onPressed: widget.onTap,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: widget.validator,
          ),
        );
      },
    );
  }
}
