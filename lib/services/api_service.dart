import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_tracker/models/api_response.dart';

class ApiService {
  static const String baseUrl = 'https://cms.puskartrital.com/api/home';
  
  Future<ApiResponse> fetchHomeData() async {
    debugPrint('Fetching data from $baseUrl');
    try {
      final response = await http.get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5)); // Reduced timeout for splash screen
      
      if (response.statusCode == 200) {
        debugPrint('API Response: ${response.body}');
        final decodedData = json.decode(response.body);
        
        if (decodedData is Map<String, dynamic>) {
          return ApiResponse.fromJson(decodedData);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        debugPrint('API Error: Status code ${response.statusCode}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API Exception: $e');
      // Return default values instead of throwing
      return ApiResponse(
        logoUrl: '',
        welcomeMessage: 'Welcome to PT Tracker!',
      );
    }
  }
}
