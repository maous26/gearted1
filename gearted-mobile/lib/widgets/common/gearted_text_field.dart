import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class GeartedTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;

  const GeartedTextField({
    Key? key,
    required this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade300 
                  : Colors.grey.shade700,
            ),
          ),
        ),
        
        // TextField
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          cursorColor: GeartedTheme.primaryBlue,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.grey.shade800,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            helperText: helperText,
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: Colors.grey.shade500) 
                : null,
            suffixIcon: suffixIcon != null 
                ? IconButton(
                    icon: Icon(suffixIcon, color: Colors.grey.shade500),
                    onPressed: onSuffixIconTap,
                  ) 
                : null,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey.shade800 
                : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GeartedTheme.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
