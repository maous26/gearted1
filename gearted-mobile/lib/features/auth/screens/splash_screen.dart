import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glitchAnimation;
  late Animation<double> _staticAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3500), // Increased duration
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.6, // Start smaller for more dramatic effect
      end: 1.1, // Scale slightly larger than final size
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));

    _glitchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 0.8, curve: Curves.easeInOut),
    ));

    _staticAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.linear),
    ));

    _startAnimationAndNavigation();
  }

  void _startAnimationAndNavigation() async {
    _animationController.forward();

    // Wait for animation to complete, then check authentication
    await Future.delayed(const Duration(milliseconds: 3500));

    if (mounted) {
      try {
        final authService = AuthService();
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        if (token != null) {
          // User has a token, try to validate it
          final isLoggedIn = await authService.isLoggedIn();
          if (isLoggedIn) {
            context.go('/home');
          } else {
            context.go('/login');
          }
        } else {
          // No token, go to login
          context.go('/login');
        }
      } catch (e) {
        // If authentication check fails, go to login
        print('Auth check error: $e');
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Create enhanced glitch effect with more dramatic movement
            final glitchOffset = _glitchAnimation.value < 0.6
                ? Offset(
                    ((_glitchAnimation.value * 25) % 1) * 12 -
                        6, // Even more dramatic glitch range
                    ((_glitchAnimation.value * 30) % 1) * 6 -
                        3, // More vertical movement
                  )
                : Offset.zero;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with transmission interference effect
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Enhanced static noise overlay with red glow effect only
                        if (_staticAnimation.value > 0 &&
                            _staticAnimation.value < 0.9)
                          Container(
                            width: 380, // Even bigger size
                            height: 380, // Even bigger size
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF8B0000).withOpacity(0.15 *
                                      _staticAnimation.value), // Red tint only
                                  Colors.transparent,
                                  const Color(0xFF8B0000).withOpacity(0.1 *
                                      _staticAnimation.value), // Red tint only
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.3, 0.7, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B0000).withOpacity(
                                      0.5 *
                                          _staticAnimation
                                              .value), // Stronger shadow
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),

                        // Main logo with enhanced glitch effect
                        Transform.translate(
                          offset: glitchOffset,
                          child: Container(
                            width: 350, // Even bigger logo container
                            height: 350, // Even bigger logo container
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _glitchAnimation.value > 0.2 &&
                                        _glitchAnimation.value < 0.8
                                    ? const Color(0xFF8B0000)
                                        .withOpacity(0.8) // More visible border
                                    : Colors.transparent,
                                width: 4, // Even thicker border
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B0000).withOpacity(
                                      0.6 *
                                          _glitchAnimation
                                              .value), // Stronger glow
                                  blurRadius: 40,
                                  spreadRadius: 15,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: Stack(
                                children: [
                                  // Main logo - much bigger
                                  Padding(
                                    padding: const EdgeInsets.all(
                                        35), // More padding
                                    child: Image.asset(
                                      'assets/images/GEARTED.png', // Using the new logo
                                      fit: BoxFit.contain,
                                      width: 280, // Even bigger logo
                                      height: 280, // Even bigger logo
                                      color: _glitchAnimation.value > 0.5 &&
                                              _glitchAnimation.value < 0.9
                                          ? const Color(0xFF8B0000).withOpacity(
                                              0.3) // Red tint instead of white
                                          : null,
                                      colorBlendMode:
                                          _glitchAnimation.value > 0.5 &&
                                                  _glitchAnimation.value < 0.9
                                              ? BlendMode.multiply
                                              : null,
                                    ),
                                  ),

                                  // Enhanced horizontal scan lines (TV interference effect) with red tint
                                  if (_staticAnimation.value > 0.1 &&
                                      _staticAnimation.value < 0.8)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: List.generate(
                                                40, // Even more scan lines
                                                (index) => index % 2 == 0
                                                    ? Colors.transparent
                                                    : const Color(0xFF8B0000)
                                                        .withOpacity(
                                                            0.04)), // Red scan lines instead of white
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Enhanced red glitch overlay
                                  if (_glitchAnimation.value > 0.3 &&
                                      _glitchAnimation.value < 0.7)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFF8B0000)
                                                  .withOpacity(
                                                      0.15), // Stronger
                                              Colors.transparent,
                                              const Color(0xFF8B0000)
                                                  .withOpacity(0.1), // Stronger
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Additional pulsing effect
                                  if (_glitchAnimation.value > 0.1 &&
                                      _glitchAnimation.value < 0.9)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(26),
                                          border: Border.all(
                                            color: const Color(0xFF8B0000)
                                                .withOpacity(0.3 *
                                                    _glitchAnimation.value),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Enhanced loading indicator with signal strength effect
                    Transform.translate(
                      offset: Offset(
                          0,
                          _glitchAnimation.value > 0.4
                              ? 4
                              : 0), // More movement
                      child: SizedBox(
                        width: 60, // Even bigger loading indicator
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 6, // Even thicker stroke
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _staticAnimation.value > 0.3 &&
                                    _staticAnimation.value < 0.7
                                ? const Color(0xFF8B0000)
                                    .withOpacity(0.9) // More visible
                                : const Color(0xFF8B0000)
                                    .withOpacity(1.0), // Full opacity
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Enhanced "Signal" text with more dramatic glitch effect
                    if (_fadeAnimation.value > 0.6)
                      Transform.translate(
                        offset: _glitchAnimation.value > 0.5
                            ? Offset(3, 0) // Even more dramatic movement
                            : Offset.zero,
                        child: Text(
                          _staticAnimation.value > 0.4 &&
                                  _staticAnimation.value < 0.8
                              ? "ÉTABLISSEMENT DE LA CONNEXION..."
                              : "CONNEXION ÉTABLIE",
                          style: TextStyle(
                            color:
                                Colors.white.withOpacity(0.95), // More visible
                            fontSize: 16, // Bigger text
                            fontWeight: FontWeight.w500, // Even bolder
                            letterSpacing: 3.0, // More spacing
                            shadows: [
                              Shadow(
                                color: const Color(0xFF8B0000).withOpacity(0.7),
                                blurRadius: 15,
                                offset: const Offset(0, 0),
                              ),
                              Shadow(
                                color: const Color(0xFF8B0000).withOpacity(0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
