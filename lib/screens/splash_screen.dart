import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:pt_tracker/providers/language_provider.dart';
import 'package:pt_tracker/screens/home_screen.dart';
import 'package:pt_tracker/theme/app_theme.dart';
import 'package:pt_tracker/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _showProgressIndicator = false;
  String _logoUrl = '';
  Timer? _progressIndicatorTimer;

  @override
  void initState() {
    super.initState();
    
    _progressIndicatorTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && _isLoading) {
        setState(() {
          _showProgressIndicator = true;
        });
      }
    });
    
    _loadApp();
  }

  Future<void> _loadApp() async {
    try {
      // Fetch logo URL from API
      final apiService = ApiService();
      final response = await apiService.fetchHomeData();
      setState(() => _logoUrl = response.logoUrl);
      
      // Add minimum delay for branding visibility
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Error loading logo: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _progressIndicatorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: _buildSplashContent(context, languageProvider, isDarkMode),
      ),
    );
  }

  Widget _buildSplashContent(BuildContext context, LanguageProvider languageProvider, bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode 
              ? [
                  const Color(0xFF121212),
                  const Color(0xFF1E1E1E),
                ] 
              : [
                  AppTheme.primaryLight.withOpacity(0.9),
                  AppTheme.secondaryLight,
                ],
          stops: const [0.3, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAppIcon(),
          const SizedBox(height: 24),
          Text(
            languageProvider.getLocalizedText('PT Tracker', 'पीटी ट्र्याकर'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate()
            .fadeIn(delay: const Duration(milliseconds: 300))
            .slide(begin: const Offset(0, 0.2)),
          const SizedBox(height: 8),
          Text(
            languageProvider.getLocalizedText(
              'Your Personal Task Assistant',
              'तपाईंको व्यक्तिगत कार्य सहायक'
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(delay: const Duration(milliseconds: 500)),
          if (_showProgressIndicator && _isLoading) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(4),
              ),
            ).animate()
              .fadeIn(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAppIcon() {
    if (_logoUrl.isNotEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.network(
            _logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingIndicator();
            },
          ),
        ),
      ).animate()
        .fadeIn(duration: const Duration(milliseconds: 500))
        .scale(begin: const Offset(0.8, 0.8));
    }
    
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryLight,
            AppTheme.secondaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.checklist_rounded,
          size: 56,
          color: Colors.white,
        ),
      ),
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 500))
      .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
