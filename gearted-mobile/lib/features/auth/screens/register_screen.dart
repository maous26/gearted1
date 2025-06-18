import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/gearted_text_field.dart';
import '../../../services/auth_service.dart';

// Army green color for tactical theme
const Color _armyGreen = Color(0xFF4A5D23);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  bool _validateInputs() {
    bool isValid = true;

    // Valider username
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _usernameError = 'Le nom d\'utilisateur est requis';
      });
      isValid = false;
    } else if (_usernameController.text.trim().length < 3) {
      setState(() {
        _usernameError =
            'Le nom d\'utilisateur doit contenir au moins 3 caractères';
      });
      isValid = false;
    } else {
      setState(() {
        _usernameError = null;
      });
    }

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

    // Valider confirmation mot de passe
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'La confirmation du mot de passe est requise';
      });
      isValid = false;
    } else if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _confirmPasswordError = 'Les mots de passe ne correspondent pas';
      });
      isValid = false;
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }

    // Valider termes et conditions
    if (!_acceptTerms) {
      setState(() {
        _termsError = 'Vous devez accepter les termes et conditions';
      });
      isValid = false;
    } else {
      setState(() {
        _termsError = null;
      });
    }

    return isValid;
  }

  Future<void> _register() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUpWithEmail(
        _usernameController.text.trim(),
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
            content: Text('Erreur d\'inscription: ${e.toString()}'),
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

  Future<void> _registerWithGoogle() async {
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
            content: Text('Erreur d\'inscription Google: ${e.toString()}'),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D), // Dark tactical AppBar
        elevation: 0,
        iconTheme: IconThemeData(
          color: _armyGreen,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for dark theme
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Rejoignez la communauté Gearted et commencez à échanger votre équipement Airsoft.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400, // Lighter grey for dark theme
                  ),
                ),

                const SizedBox(height: 32),

                // Formulaire
                GeartedTextField(
                  label: 'Nom d\'utilisateur',
                  hint: 'Choisissez un nom d\'utilisateur',
                  controller: _usernameController,
                  prefixIcon: Icons.person_outline,
                  errorText: _usernameError,
                ),

                const SizedBox(height: 16),

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
                  hint: 'Créez un mot de passe',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: _togglePasswordVisibility,
                  errorText: _passwordError,
                ),

                const SizedBox(height: 16),

                GeartedTextField(
                  label: 'Confirmer le mot de passe',
                  hint: 'Confirmez votre mot de passe',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: _toggleConfirmPasswordVisibility,
                  errorText: _confirmPasswordError,
                ),

                const SizedBox(height: 24),

                // Termes et conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                          if (_acceptTerms) {
                            _termsError = null;
                          }
                        });
                      },
                      activeColor: _armyGreen,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              text: 'J\'accepte les ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors
                                    .grey.shade400, // Lighter for dark theme
                              ),
                              children: [
                                TextSpan(
                                  text: 'Conditions d\'utilisation',
                                  style: TextStyle(
                                    color: _armyGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' et la ',
                                  style: TextStyle(
                                    color: Colors
                                        .grey.shade400, // Consistent color
                                  ),
                                ),
                                TextSpan(
                                  text: 'Politique de confidentialité',
                                  style: TextStyle(
                                    color: _armyGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_termsError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _termsError!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Bouton d'inscription
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            'S\'inscrire',
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
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Boutons d'inscription sociale - GOOGLE SEULEMENT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      onPressed: _registerWithGoogle,
                      icon: Icons.g_mobiledata,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Lien de connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Déjà un compte?',
                      style: TextStyle(
                          color: Colors.white), // White text for dark theme
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: Text(
                        'Se connecter',
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
