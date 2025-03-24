import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english,
  nepali,
}

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.nepali;
  
  LanguageProvider() {
    _loadLanguagePreference();
  }
  
  AppLanguage get currentLanguage => _currentLanguage;
  bool get isNepali => _currentLanguage == AppLanguage.nepali;
  
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final String langString = prefs.getString('app_language') ?? 'nepali';
    
    _currentLanguage = langString == 'english' 
        ? AppLanguage.english 
        : AppLanguage.nepali;
    
    notifyListeners();
  }
  
  Future<void> toggleLanguage() async {
    _currentLanguage = _currentLanguage == AppLanguage.english 
        ? AppLanguage.nepali 
        : AppLanguage.english;
    
    notifyListeners();
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'app_language', 
      _currentLanguage == AppLanguage.english ? 'english' : 'nepali'
    );
  }
  
  String getLocalizedText(String englishText, String nepaliText) {
    return _currentLanguage == AppLanguage.english ? englishText : nepaliText;
  }
}
