import 'dart:typed_data';

import 'package:clothing_shop/models/product_model.dart';
import 'package:clothing_shop/providers/product_provider.dart';
import 'package:clothing_shop/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _makerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Hoodies');
  final _colorsController = TextEditingController(
    text: '#1B1D18, #223B2E, #C68A2E',
  );

  final List<String> presetCategories = const [
    'Hoodies',
    'Jackets',
    'Tees',
    'Shirts',
    'Pants',
    'Accessories',
    'Footwear',
  ];

  final List<String> presetColors = const [
    '#1B1D18',
    '#223B2E',
    '#C68A2E',
    '#A9502F',
    '#3E6660',
    '#E3D8C3',
    '#FFFFFF',
  ];

  XFile? selectedImage;
  Uint8List? imageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _makerController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  // ============================
  // PICK IMAGE
  // ============================
  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Upload Image to Cloudinary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library, color: AppColors.forest),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt, color: AppColors.forest),
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      final Uint8List bytes = await image.readAsBytes();

      setState(() {
        selectedImage = image;
        imageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image selection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================
  // SUBMIT PRODUCT
  // ============================
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product image for Cloudinary upload'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final colorsList = _colorsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final newProduct = ProductModel(
      name: _nameController.text.trim(),
      maker: _makerController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      category: _categoryController.text.trim(),
      colors: colorsList,
      rating: 5.0,
      reviews: 1,
      imageUrl: '',
    );

    final provider = context.read<ProductProvider>();
    final success = await provider.addProduct(newProduct, selectedImage!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Product uploaded to Cloudinary & saved!'),
            ],
          ),
          backgroundColor: AppColors.forestDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload image to Cloudinary. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================
  // BUILD
  // ============================
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text(
          'Add New Product',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================
              // IMAGE PICKER & CLOUDINARY BOX
              // ============================
              GestureDetector(
                onTap: isLoading ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: imageBytes != null
                          ? AppColors.forest
                          : AppColors.line,
                      width: imageBytes != null ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageBytes != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(
                              imageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 240,
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.forestDark.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 14,
                                      color: AppColors.paper,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Ready for Cloudinary',
                                      style: TextStyle(
                                        color: AppColors.paper,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Tap to Change Image',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.paper,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.line),
                              ),
                              child: const Icon(
                                Icons.add_a_photo_outlined,
                                size: 28,
                                color: AppColors.forest,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Select Product Image',
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Will be uploaded to Cloudinary',
                              style: TextStyle(
                                color: AppColors.sub,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Gallery or Camera',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 22),

              // ============================
              // NAME
              // ============================
              _buildTextField(
                controller: _nameController,
                label: 'Product Name',
                hint: 'e.g., Heavyweight Oversized Hoodie',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter product name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ============================
              // MAKER
              // ============================
              _buildTextField(
                controller: _makerController,
                label: 'Maker / Brand',
                hint: 'e.g., Studio Kioo',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter maker name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ============================
              // CATEGORY CHIPS
              // ============================
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presetCategories.map((cat) {
                  final isSelected =
                      _categoryController.text.trim().toLowerCase() ==
                      cat.toLowerCase();
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _categoryController.text = cat;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.forest : AppColors.cream,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.forest : AppColors.line,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? AppColors.paper : AppColors.ink,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // ============================
              // PRICE
              // ============================
              _buildTextField(
                controller: _priceController,
                label: 'Price (\$)',
                hint: 'e.g., 59.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter price';
                  }
                  if (double.tryParse(val.trim()) == null) {
                    return 'Invalid price';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ============================
              // COLORS / PALETTE
              // ============================
              _buildTextField(
                controller: _colorsController,
                label: 'Color Palette (Hex Codes)',
                hint: '#1B1D18, #223B2E, #C68A2E',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter at least one color hex';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Quick Add:',
                    style: TextStyle(fontSize: 11, color: AppColors.sub),
                  ),
                  const SizedBox(width: 8),
                  ...presetColors.map((hex) {
                    return GestureDetector(
                      onTap: () {
                        if (!_colorsController.text.contains(hex)) {
                          setState(() {
                            final current = _colorsController.text.trim();
                            _colorsController.text = current.isEmpty
                                ? hex
                                : '$current, $hex';
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(
                              'FF${hex.replaceFirst('#', '')}',
                              radix: 16,
                            ),
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.line),
                        ),
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // ============================
              // DESCRIPTION
              // ============================
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe materials, fit, design inspiration...',
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // ============================
              // SAVE & UPLOAD BUTTON
              // ============================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: AppColors.paper,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Uploading to Cloudinary...',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Save & Upload Product',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // TEXT FIELD HELPER
  // ============================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.ink),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.sub),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: AppColors.sub.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: AppColors.cream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.forest, width: 2),
        ),
      ),
    );
  }
}

