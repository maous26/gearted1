import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/gearted_text_field.dart';
import '../../../services/auth_service.dart';

// Army green color for tactical theme
const Color _armyGreen = Color(0xFF4A5D23);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  bool _validateInputs() {
    bool isValid = true;

    // Valider email
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'L\'email est requis';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      setState(() {
        _emailError = 'Email invalide';
      });
      isValid = false;
    } else {
      setState(() {
        _emailError = null;
      });
    }

    // Valider mot de passe
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Le mot de passe est requis';
      });
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = 'Le mot de passe doit contenir au moins 6 caractères';
      });
      isValid = false;
    } else {
      setState(() {
        _passwordError = null;
      });
    }

    return isValid;
  }

  Future<void> _login() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithGoogle();

      if (result != null && context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion Google: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark tactical background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Gearted Logo - Simple Design (Bigger)
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    child: Image.asset(
                      'assets/images/GEARTED.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Titre
                const Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for dark theme
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Formulaire
                GeartedTextField(
                  label: 'Email',
                  hint: 'Entrez votre email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  errorText: _emailError,
                ),

                const SizedBox(height: 16),

                GeartedTextField(
                  label: 'Mot de passe',
                  hint: 'Entrez votre mot de passe',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: _togglePasswordVisibility,
                  errorText: _passwordError,
                ),

                const SizedBox(height: 8),

                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Mot de passe oublié?',
                      style: TextStyle(
                        color: _armyGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton de connexion
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _armyGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _armyGreen.withOpacity(0.6),
                      disabledForegroundColor: Colors.white.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Oswald',
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Séparateur
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade600, // Darker for dark theme
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: TextStyle(
                          color: Colors.grey.shade400, // Lighter for dark theme
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade600, // Darker for dark theme
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Boutons de connexion sociale - GOOGLE SEULEMENT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      onPressed: _loginWithGoogle,
                      icon: Icons.g_mobiledata,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Lien d'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas encore de compte?',
                      style: TextStyle(
                          color: Colors.white), // White text for dark theme
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/register');
                      },
                      child: Text(
                        'S\'inscrire',
                        style: TextStyle(
                          color: _armyGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A), // Dark container
          border: Border.all(
            color: const Color(0xFF3A3A3A), // Darker border
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 30,
          color: _armyGreen, // Army green icons
        ),
      ),
    );
  }
}
