import 'package:flutter/material.dart';
import 'package:medico/models/special_offer.dart';
import 'package:medico/core/services/special_offers_service.dart';
import 'package:medico/core/theme/app_colors.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({Key? key}) : super(key: key);

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountPercentageController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _selectedCategory = 'appointment';
  List<String> _selectedAudiences = ['all'];
  bool _isLoading = false;

  final List<String> _categories = [
    'appointment',
    'medicine',
    'test',
    'consultation',
    'surgery',
    'therapy',
    'general',
  ];

  final List<String> _audiences = [
    'all',
    'premium',
    'new_users',
    'returning_users',
    'elderly',
    'children',
    'adults',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _originalPriceController.dispose();
    _discountPercentageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _updateDiscountedPrice() {
    final originalPrice = double.tryParse(_originalPriceController.text) ?? 0;
    final discountPercentage = double.tryParse(_discountPercentageController.text) ?? 0;
    final discountedPrice = originalPrice * (1 - discountPercentage / 100);
    
    // Update the UI to show calculated discounted price
    setState(() {});
  }

  Future<void> _createOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final originalPrice = double.parse(_originalPriceController.text);
      final discountPercentage = double.parse(_discountPercentageController.text);
      final discountedPrice = originalPrice * (1 - discountPercentage / 100);

      final offer = await SpecialOffersService.createOffer(
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text,
        discountPercentage: discountPercentage,
        originalPrice: originalPrice,
        discountedPrice: discountedPrice,
        startDate: _startDate,
        endDate: _endDate,
        targetAudience: _selectedAudiences,
        category: _selectedCategory,
      );

      if (offer != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create offer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final originalPrice = double.tryParse(_originalPriceController.text) ?? 0;
    final discountPercentage = double.tryParse(_discountPercentageController.text) ?? 0;
    final discountedPrice = originalPrice * (1 - discountPercentage / 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Special Offer'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Offer Title *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 50% Off Cardiology Consultation',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  hintText: 'Describe the offer details...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/offer-image.jpg',
                ),
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Target Audience
              const Text(
                'Target Audience *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _audiences.map((audience) {
                  final isSelected = _selectedAudiences.contains(audience);
                  return FilterChip(
                    label: Text(audience.replaceAll('_', ' ').toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (audience == 'all') {
                            _selectedAudiences = ['all'];
                          } else {
                            _selectedAudiences.remove('all');
                            _selectedAudiences.add(audience);
                          }
                        } else {
                          _selectedAudiences.remove(audience);
                          if (_selectedAudiences.isEmpty) {
                            _selectedAudiences = ['all'];
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Pricing Section
              const Text(
                'Pricing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Original Price *',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _updateDiscountedPrice(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter original price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountPercentageController,
                      decoration: const InputDecoration(
                        labelText: 'Discount % *',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _updateDiscountedPrice(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter discount percentage';
                        }
                        final discount = double.tryParse(value);
                        if (discount == null) {
                          return 'Please enter a valid number';
                        }
                        if (discount < 0 || discount > 100) {
                          return 'Discount must be 0-100%';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calculated Discounted Price
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Discounted Price: \$${discountedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date Range
              const Text(
                'Validity Period',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Date'),
                      subtitle: Text(_startDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Date'),
                      subtitle: Text(_endDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Offer',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 