import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

/// Support Screen - Contact support with issue details
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _isSending = false;

  @override
  void dispose() {
    _summaryController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to pick image. Please try again.');
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        title: Text(
          'Select Image Source',
          style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.gold),
              title: Text(
                'Camera',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textOnGreen,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.gold),
              title: Text(
                'Gallery',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textOnGreen,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _sendSupport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSending = true);

    // Simulate sending (in real app, integrate with email service or API)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSending = false);
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.gold, size: 28),
              const SizedBox(width: 12),
              Text(
                'Support Request Sent',
                style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          content: Text(
            'Thank you for contacting us! We\'ll get back to you as soon as possible.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnGreen,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close support screen
              },
              child: Text(
                'OK',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[300], size: 28),
            const SizedBox(width: 12),
            Text(
              'Error',
              style: AppTypography.cardTitle.copyWith(color: Colors.red[300]),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textOnGreen,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg.png',
        darkOverlay: true,
        child: Column(
          children: [
            // App Bar
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.gold),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Contact Support',
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Info
                      SmartCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.support_agent,
                                color: AppColors.gold,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'We\'re here to help! Please provide details about your issue.',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textOnGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Summary Input
                      _buildInputLabel('Summary *'),
                      const SizedBox(height: 8),
                      SmartCard(
                        child: TextFormField(
                          controller: _summaryController,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textOnGreen,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Brief summary of the issue',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.slateGray,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a summary';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Input
                      _buildInputLabel('Email *'),
                      const SizedBox(height: 8),
                      SmartCard(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textOnGreen,
                          ),
                          decoration: InputDecoration(
                            hintText: 'your.email@example.com',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.slateGray,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description Input
                      _buildInputLabel('Description *'),
                      const SizedBox(height: 8),
                      SmartCard(
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 6,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textOnGreen,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Please describe the issue in detail...',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.slateGray,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            if (value.trim().length < 10) {
                              return 'Please provide more details (at least 10 characters)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Media Section
                      _buildInputLabel('Attachments (Optional)'),
                      const SizedBox(height: 8),
                      SmartCard(
                        child: InkWell(
                          onTap: _showImageSourceDialog,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate,
                                  color: AppColors.gold,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Add Screenshot or Photo',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Selected Images
                      if (_selectedImages.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedImages.asMap().entries.map((entry) {
                            return _buildImagePreview(entry.value, entry.key);
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Send Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _sendSupport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Send Support Request',
                                      style: AppTypography.bodyLarge.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildImagePreview(File image, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.3),
              width: 2,
            ),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
