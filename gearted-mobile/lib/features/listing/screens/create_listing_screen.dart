import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../widgets/common/gearted_button.dart';
import '../../../core/constants/category_structure.dart';

// Army green color for seller screen
const Color _armyGreen = Color(0xFF4A5D23);

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _tagController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;
  String? _selectedSubCategory;
  String _selectedCondition = 'Très bon état';
  bool _isExchangeable = false;
  List<String> _tags = [];
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  // Options pour les dropdowns - remplacé par CategoryStructure
  final List<Map<String, dynamic>> _conditions = [
    {'name': 'Neuf', 'color': Colors.green, 'icon': Icons.new_releases},
    {'name': 'Comme neuf', 'color': Colors.lightGreen, 'icon': Icons.star},
    {'name': 'Très bon état', 'color': Colors.blue, 'icon': Icons.thumb_up},
    {'name': 'Bon état', 'color': Colors.orange, 'icon': Icons.check_circle},
    {'name': 'État correct', 'color': Colors.amber, 'icon': Icons.warning},
    {'name': 'Pour pièces', 'color': Colors.red, 'icon': Icons.build_circle},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 5) {
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _addImage() async {
    if (_selectedImages.length < 8) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    print('DEBUG: _submitForm called');

    // Debug individual field values
    print(
        'DEBUG: Title: "${_titleController.text}" (${_titleController.text.length} chars)');
    print(
        'DEBUG: Description: "${_descriptionController.text}" (${_descriptionController.text.length} chars)');
    print('DEBUG: Price: "${_priceController.text}"');

    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');

      // Show specific validation guidance
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez corriger les erreurs dans le formulaire:\n'
            '• Titre: au moins 10 caractères\n'
            '• Description: au moins 20 caractères\n'
            '• Prix: entre 1€ et 10,000€',
            style: TextStyle(fontSize: 14),
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }
    print('DEBUG: Form validation passed');

    if (_selectedImages.isEmpty) {
      print('DEBUG: No images selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print('DEBUG: Images validation passed - ${_selectedImages.length} images');

    if (_selectedCategory == null) {
      print('DEBUG: No category selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une catégorie'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print('DEBUG: Category validation passed - $_selectedCategory');

    if (_selectedSubCategory == null) {
      print('DEBUG: No subcategory selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une sous-catégorie'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print('DEBUG: Subcategory validation passed - $_selectedSubCategory');

    setState(() {
      _isLoading = true;
    });
    print('DEBUG: Starting API simulation...');

    try {
      // TODO: Intégrer avec l'API réelle
      await Future.delayed(
          const Duration(seconds: 2)); // Simulation d'appel API

      print('DEBUG: API simulation completed');

      if (context.mounted) {
        print('DEBUG: Context mounted, showing success message');
        // Redirection vers l'écran d'accueil après création réussie
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce créée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
        print('DEBUG: Navigating to home');
      } else {
        print('DEBUG: Context not mounted');
      }
    } catch (e) {
      print('DEBUG: Error occurred: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      print('DEBUG: Finalizing...');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('DEBUG: Loading state set to false');
      } else {
        print('DEBUG: Widget not mounted, cannot update loading state');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF1A1A1A), // Dark background like home screen
      appBar: AppBar(
        title: const Text(
          'CRÉER UNE ANNONCE',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D), // Dark tactical color
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec progression
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A), // Dark container
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _armyGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _armyGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.add_business,
                            color: _armyGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NOUVELLE ANNONCE',
                                style: TextStyle(
                                  fontFamily: 'Oswald',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Vendez votre équipement airsoft rapidement',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section photos améliorée
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A), // Dark container
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_camera,
                          color: _armyGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'PHOTOS DE L\'ARTICLE',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _armyGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _armyGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '${_selectedImages.length}/8',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _armyGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajoutez jusqu\'à 8 photos pour attirer l\'attention des acheteurs',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grille d'images améliorée
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Bouton d'ajout d'image amélioré
                          GestureDetector(
                            onTap:
                                _selectedImages.length < 8 ? _addImage : null,
                            child: Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: _selectedImages.length < 8
                                    ? const Color(0xFF3A3A3A)
                                    : const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedImages.length < 8
                                      ? _armyGreen.withOpacity(0.5)
                                      : Colors.grey.shade700,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 32,
                                    color: _selectedImages.length < 8
                                        ? _armyGreen
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedImages.length < 8
                                        ? 'AJOUTER'
                                        : 'LIMITE',
                                    style: TextStyle(
                                      fontFamily: 'Oswald',
                                      color: _selectedImages.length < 8
                                          ? _armyGreen
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Images ajoutées avec design amélioré
                          ..._selectedImages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final image = entry.value;
                            return Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3A3A3A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: index == 0
                                        ? Border.all(
                                            color: _armyGreen,
                                            width: 2,
                                          )
                                        : Border.all(
                                            color: Colors.grey.shade700,
                                            width: 1,
                                          ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(image.path),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_rounded,
                                              size: 32,
                                              color: Colors.grey.shade600,
                                            ),
                                            if (index == 0)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 4),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _armyGreen,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Principal',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                if (index == 0)
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _armyGreen,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'PRINCIPAL',
                                        style: TextStyle(
                                          fontFamily: 'Oswald',
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 8,
                                  right: 20,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade500,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section informations principales
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A), // Dark container
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _armyGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'INFORMATIONS DE L\'ARTICLE',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Titre
                    TextFormField(
                      controller: _titleController,
                      maxLength: 80,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Titre de l\'annonce',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        hintText: 'Ex: M4A1 Daniel Defense RIS II neuf',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.title, color: _armyGreen),
                        filled: true,
                        fillColor: const Color(0xFF3A3A3A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _armyGreen, width: 2),
                        ),
                        counterStyle: TextStyle(color: Colors.grey.shade400),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le titre est obligatoire';
                        }
                        if (value.trim().length < 10) {
                          return 'Le titre doit contenir au moins 10 caractères';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 1000,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Description détaillée',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        hintText:
                            'Décrivez votre article : marque, modèle, état, accessoires inclus...',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.description, color: _armyGreen),
                        filled: true,
                        fillColor: const Color(0xFF3A3A3A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _armyGreen, width: 2),
                        ),
                        alignLabelWithHint: true,
                        counterStyle: TextStyle(color: Colors.grey.shade400),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La description est obligatoire';
                        }
                        if (value.trim().length < 20) {
                          return 'La description doit contenir au moins 20 caractères';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Prix
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Prix de vente (€)',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        hintText: 'Entrez votre prix sans le symbole €',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.euro, color: _armyGreen),
                        filled: true,
                        fillColor: const Color(0xFF3A3A3A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _armyGreen, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le prix est obligatoire';
                        }
                        final price = int.tryParse(value);
                        if (price == null || price < 1) {
                          return 'Veuillez entrer un prix valide';
                        }
                        if (price > 10000) {
                          return 'Le prix ne peut pas dépasser 10 000€';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section catégorie et état
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A), // Dark container
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          color: _armyGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'CATÉGORIE ET ÉTAT',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Catégorie - déjà mis à jour plus haut
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              size: 20,
                              color: _armyGreen,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'CATÉGORIE',
                              style: TextStyle(
                                fontFamily: 'Oswald',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF3A3A3A),
                              hint: Text(
                                'Sélectionnez une catégorie',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                              items: CategoryStructure.mainCategories
                                  .map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Icon(
                                        CategoryStructure.getCategoryIcon(
                                                category) ??
                                            Icons.category,
                                        size: 20,
                                        color: _armyGreen,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          category,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                    _selectedSubCategory =
                                        null; // Reset subcategory when category changes
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Sous-catégorie (conditionnel)
                    if (_selectedCategory != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.subdirectory_arrow_right,
                                size: 20,
                                color: _armyGreen,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'SOUS-CATÉGORIE',
                                style: TextStyle(
                                  fontFamily: 'Oswald',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A3A3A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSubCategory,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF3A3A3A),
                                hint: Text(
                                  'Sélectionnez une sous-catégorie',
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                                items: CategoryStructure.getSubCategories(
                                        _selectedCategory!)
                                    .map((subCategory) {
                                  return DropdownMenuItem<String>(
                                    value: subCategory,
                                    child: Text(
                                      subCategory,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedSubCategory = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // État - déjà mis à jour plus haut
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rate,
                              size: 20,
                              color: _armyGreen,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ÉTAT DE L\'ARTICLE',
                              style: TextStyle(
                                fontFamily: 'Oswald',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCondition,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF3A3A3A),
                              hint: Text(
                                'Sélectionnez l\'état',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                              items: _conditions.map((condition) {
                                return DropdownMenuItem<String>(
                                  value: condition['name'],
                                  child: Row(
                                    children: [
                                      Icon(
                                        condition['icon'],
                                        size: 20,
                                        color: condition['color'],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        condition['name'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCondition = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section options avancées
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A), // Dark container
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: _armyGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'OPTIONS AVANCÉES',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tags améliorés
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer,
                              size: 18,
                              color: _armyGreen,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'TAGS (OPTIONNEL)',
                              style: TextStyle(
                                fontFamily: 'Oswald',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _armyGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _armyGreen.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${_tags.length}/5',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _armyGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajoutez des mots-clés pour améliorer la visibilité',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Ex: GBBR, Tokyo Marui, neuf...',
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade600),
                                  filled: true,
                                  fillColor: const Color(0xFF3A3A3A),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: _armyGreen,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: _addTag,
                                enabled: _tags.length < 5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _tags.length < 5
                                  ? () => _addTag(_tagController.text)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _armyGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'AJOUTER',
                                style: TextStyle(
                                  fontFamily: 'Oswald',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_tags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3A3A3A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _armyGreen.withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tag,
                                      style: TextStyle(
                                        fontFamily: 'Oswald',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _removeTag(tag),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Échange possible amélioré
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isExchangeable
                                  ? _armyGreen.withOpacity(0.2)
                                  : const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _isExchangeable
                                    ? _armyGreen.withOpacity(0.5)
                                    : Colors.grey.shade700,
                              ),
                            ),
                            child: Icon(
                              Icons.swap_horiz,
                              size: 20,
                              color: _isExchangeable
                                  ? _armyGreen
                                  : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ÉCHANGE POSSIBLE',
                                  style: TextStyle(
                                    fontFamily: 'Oswald',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  'Acceptez les propositions d\'échange',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isExchangeable,
                            activeColor: _armyGreen,
                            onChanged: (value) {
                              setState(() {
                                _isExchangeable = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bouton de validation amélioré
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _armyGreen.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: GeartedButton(
                  label: 'PUBLIER L\'ANNONCE',
                  onPressed: () {
                    print('DEBUG: Publish button pressed');
                    // Simple test - just show a snackbar to confirm button works
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Button clicked! Running validation...'),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 1),
                      ),
                    );
                    // Call the actual submit form after a short delay
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _submitForm();
                    });
                  },
                  isLoading: _isLoading,
                  fullWidth: true,
                  type: GeartedButtonType.accent,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
