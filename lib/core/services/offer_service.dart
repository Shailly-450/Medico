import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medico/models/offer_package.dart';
import 'package:medico/core/services/auth_service.dart';
import 'package:medico/core/config.dart';

class OfferService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 30);

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

  static Future<List<OfferPackage>> getOffers() async {
    print('Calling GET $baseUrl/offers');
    final response = await http.get(
      Uri.parse('$baseUrl/offers'),
      headers: _authHeaders,
    ).timeout(timeout);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => OfferPackage.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  static Future<OfferPackage?> getOfferById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/offers/$id'),
      headers: _authHeaders,
    ).timeout(timeout);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return OfferPackage.fromJson(data['data']);
      }
    }
    return null;
  }

  static Future<OfferPackage?> createOffer(Map<String, dynamic> offerData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/offers'),
      headers: _authHeaders,
      body: jsonEncode(offerData),
    ).timeout(timeout);
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return OfferPackage.fromJson(data['data']);
      }
    }
    return null;
  }

  static Future<OfferPackage?> updateOffer(String id, Map<String, dynamic> offerData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/offers/$id'),
      headers: _authHeaders,
      body: jsonEncode(offerData),
    ).timeout(timeout);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return OfferPackage.fromJson(data['data']);
      }
    }
    return null;
  }

  static Future<bool> deleteOffer(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/offers/$id'),
      headers: _authHeaders,
    ).timeout(timeout);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  }
} 