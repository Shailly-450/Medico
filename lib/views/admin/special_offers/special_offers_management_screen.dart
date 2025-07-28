import 'package:flutter/material.dart';
import 'package:medico/models/offer_package.dart';
import 'package:medico/core/services/offer_service.dart';
import 'package:medico/core/services/notification_sender_service.dart';
import 'package:medico/core/theme/app_colors.dart';
import 'package:medico/core/services/auth_service.dart';
import 'package:medico/core/services/api_service.dart';
import 'create_offer_screen.dart';
import 'offer_detail_screen.dart';

class SpecialOffersManagementScreen extends StatefulWidget {
  const SpecialOffersManagementScreen({Key? key}) : super(key: key);

  @override
  State<SpecialOffersManagementScreen> createState() => _SpecialOffersManagementScreenState();
}

class _SpecialOffersManagementScreenState extends State<SpecialOffersManagementScreen> {
  List<OfferPackage> _offers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all'; // all, active, inactive, expired

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final offers = await OfferService.getOffers();
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load offers: $e';
        _isLoading = false;
      });
    }
  }

  List<OfferPackage> get _filteredOffers {
    switch (_selectedFilter) {
      case 'active':
        return _offers.where((offer) => offer.isActive && offer.validUntil.isAfter(DateTime.now())).toList();
      case 'inactive':
        return _offers.where((offer) => !offer.isActive).toList();
      case 'expired':
        return _offers.where((offer) => offer.validUntil.isBefore(DateTime.now())).toList();
      default:
        return _offers;
    }
  }

  Future<void> _sendPushNotificationForOffer(OfferPackage offer) async {
    final title = 'Special Offer: ${offer.title}';
    final message = '${offer.description}\nNow only ₹${offer.discountedPrice.toStringAsFixed(0)}! (${offer.discountPercentage}% OFF)';
    final success = await NotificationSenderService.sendToAll(
      title: title,
      message: message,
      // Optionally, add more data here
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Push notification sent!' : 'Failed to send notification'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Offers Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOffers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Offers')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(value: 'expired', child: Text('Expired')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Offers List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadOffers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredOffers.isEmpty
                        ? const Center(
                            child: Text('No offers found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredOffers.length,
                            itemBuilder: (context, index) {
                              final offer = _filteredOffers[index];
                              return _buildOfferCard(offer);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateOfferScreen(),
            ),
          );
          if (result == true) {
            _loadOffers();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Offer'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildOfferCard(OfferPackage offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () {
          // You can navigate to a detail screen or show more info here
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (offer.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        offer.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.description,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: offer.isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      offer.isActive ? 'ACTIVE' : 'INACTIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '₹${offer.discountedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${offer.originalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${offer.discountPercentage}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: offer.includedServices.map((service) => Chip(
                  label: Text(service),
                  backgroundColor: Colors.grey[200],
                )).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Valid Until: ${offer.validUntil.toString().split(' ')[0]}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.notifications),
                    label: const Text('Send Push'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _sendPushNotificationForOffer(offer),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 