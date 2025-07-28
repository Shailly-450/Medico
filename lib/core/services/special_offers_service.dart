import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:medico/models/special_offer.dart';
import 'package:medico/core/config.dart';
import 'package:medico/core/services/auth_service.dart';
import 'package:medico/core/services/notification_sender_service.dart';
import 'package:medico/models/notification_item.dart';

class SpecialOffersService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Get auth headers
  static Map<String, String> get _authHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = AuthService.accessToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Fetch all special offers
  static Future<List<SpecialOffer>> fetchOffers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/offers'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => SpecialOffer.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching offers: $e');
      return [];
    }
  }

  // Create a new special offer
  static Future<SpecialOffer?> createOffer({
    required String title,
    required String description,
    required String imageUrl,
    required double discountPercentage,
    required double originalPrice,
    required double discountedPrice,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> targetAudience,
    required String category,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final body = {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'discountPercentage': discountPercentage,
        'originalPrice': originalPrice,
        'discountedPrice': discountedPrice,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'targetAudience': targetAudience,
        'category': category,
        'isActive': true,
        if (additionalData != null) 'additionalData': additionalData,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/offers'),
        headers: _authHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return SpecialOffer.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating offer: $e');
      return null;
    }
  }

  // Update an existing offer
  static Future<SpecialOffer?> updateOffer({
    required String offerId,
    String? title,
    String? description,
    String? imageUrl,
    double? discountPercentage,
    double? originalPrice,
    double? discountedPrice,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? targetAudience,
    String? category,
    bool? isActive,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (imageUrl != null) body['imageUrl'] = imageUrl;
      if (discountPercentage != null) body['discountPercentage'] = discountPercentage;
      if (originalPrice != null) body['originalPrice'] = originalPrice;
      if (discountedPrice != null) body['discountedPrice'] = discountedPrice;
      if (startDate != null) body['startDate'] = startDate.toIso8601String();
      if (endDate != null) body['endDate'] = endDate.toIso8601String();
      if (targetAudience != null) body['targetAudience'] = targetAudience;
      if (category != null) body['category'] = category;
      if (isActive != null) body['isActive'] = isActive;
      if (additionalData != null) body['additionalData'] = additionalData;

      final response = await http.put(
        Uri.parse('$baseUrl/offers/$offerId'),
        headers: _authHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return SpecialOffer.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating offer: $e');
      return null;
    }
  }

  // Delete an offer
  static Future<bool> deleteOffer(String offerId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/offers/$offerId'),
        headers: _authHeaders,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting offer: $e');
      return false;
    }
  }

  // Send push notification for a special offer
  static Future<bool> sendOfferNotification({
    required SpecialOffer offer,
    List<String>? targetUserIds,
    Map<String, String>? targetTags,
  }) async {
    try {
      // Create notification message
      final title = '🎉 Special Offer: ${offer.title}';
      final message = '${offer.description}\n\n${offer.formattedDiscount} - Save ${offer.formattedSavings}!';

      // Send to specific users if provided
      if (targetUserIds != null && targetUserIds.isNotEmpty) {
        for (final userId in targetUserIds) {
          await NotificationSenderService.sendToUser(
            userId: userId,
            title: title,
            message: message,
            type: NotificationType.general,
            data: {
              'type': 'special_offer',
              'offerId': offer.id,
              'category': offer.category,
              'discountPercentage': offer.discountPercentage,
              'originalPrice': offer.originalPrice,
              'discountedPrice': offer.discountedPrice,
              'startDate': offer.startDate.toIso8601String(),
              'endDate': offer.endDate.toIso8601String(),
            },
          );
        }
      }

      // Send to users with specific tags
      if (targetTags != null && targetTags.isNotEmpty) {
        await NotificationSenderService.sendToUsersWithTags(
          tags: targetTags,
          title: title,
          message: message,
          type: NotificationType.general,
          data: {
            'type': 'special_offer',
            'offerId': offer.id,
            'category': offer.category,
            'discountPercentage': offer.discountPercentage,
            'originalPrice': offer.originalPrice,
            'discountedPrice': offer.discountedPrice,
            'startDate': offer.startDate.toIso8601String(),
            'endDate': offer.endDate.toIso8601String(),
          },
        );
      }

      // Send to all users if no specific targeting
      if ((targetUserIds == null || targetUserIds.isEmpty) && 
          (targetTags == null || targetTags.isEmpty)) {
        await NotificationSenderService.sendToAll(
          title: title,
          message: message,
          type: NotificationType.general,
          data: {
            'type': 'special_offer',
            'offerId': offer.id,
            'category': offer.category,
            'discountPercentage': offer.discountPercentage,
            'originalPrice': offer.originalPrice,
            'discountedPrice': offer.discountedPrice,
            'startDate': offer.startDate.toIso8601String(),
            'endDate': offer.endDate.toIso8601String(),
          },
        );
      }

      debugPrint('Special offer notification sent successfully');
      return true;
    } catch (e) {
      debugPrint('Error sending offer notification: $e');
      return false;
    }
  }

  // Get active offers
  static Future<List<SpecialOffer>> getActiveOffers() async {
    final allOffers = await fetchOffers();
    return allOffers.where((offer) => offer.isCurrentlyActive).toList();
  }

  // Get offers by category
  static Future<List<SpecialOffer>> getOffersByCategory(String category) async {
    final allOffers = await fetchOffers();
    return allOffers.where((offer) => offer.category == category).toList();
  }

  // Get offers for specific target audience
  static Future<List<SpecialOffer>> getOffersForAudience(String audience) async {
    final allOffers = await fetchOffers();
    return allOffers.where((offer) => 
      offer.targetAudience.contains(audience) || 
      offer.targetAudience.contains('all')
    ).toList();
  }
} 