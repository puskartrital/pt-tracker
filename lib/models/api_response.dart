class ApiResponse {
  final String logoUrl;
  final String welcomeMessage;
  
  ApiResponse({
    required this.logoUrl,
    required this.welcomeMessage,
  });
  
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    // Extract logo URL directly from the correct field
    final String logoUrl = json['logoUrl'] ?? '';
    
    // For now, use a static welcome message since it's not in the API
    const String welcomeMessage = 'Welcome to PT Tracker!';
    
    return ApiResponse(
      logoUrl: logoUrl,
      welcomeMessage: welcomeMessage,
    );
  }
  
  @override
  String toString() => 'ApiResponse(logoUrl: $logoUrl, welcomeMessage: $welcomeMessage)';
}
