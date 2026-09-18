// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/modeles_provider.dart';
import '../../core/theme.dart';
import '../../models/modele_fabrication.dart';

class ModeleFormScreen extends StatefulWidget {
  final String? modeleId;

  const ModeleFormScreen({super.key, this.modeleId});

  @override
  State<ModeleFormScreen> createState() => _ModeleFormScreenState();
}

class _ModeleFormScreenState extends State<ModeleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomController;
  late TextEditingController _typeProduitController;
  late TextEditingController _descriptionController;
  late TextEditingController _prixController;

  final List<TextEditingController> _etapesControllers = [];
  final List<TextEditingController> _champsMesuresControllers = [];
  final List<TextEditingController> _materiauxControllers = [];

  bool _isLoading = false;
  ModeleFabrication? _modeleExistant;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _typeProduitController = TextEditingController();
    _descriptionController = TextEditingController();
    _prixController = TextEditingController();

    if (widget.modeleId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<ModelesProvider>();
        try {
          _modeleExistant = provider.tousLesModeles.firstWhere((m) => m.id == widget.modeleId);
          _remplirChamps();
        } catch (_) {}
      });
    } else {
      _ajouterEtape();
    }
  }

  void _remplirChamps() {
    if (_modeleExistant == null) return;
    setState(() {
      _nomController.text = _modeleExistant!.nom;
      _typeProduitController.text = _modeleExistant!.typeProduit;
      _descriptionController.text = _modeleExistant!.description;
      _prixController.text = _modeleExistant!.prixIndicatif?.toStringAsFixed(0) ?? '';

      for (var e in _modeleExistant!.etapes) {
        _etapesControllers.add(TextEditingController(text: e.titre));
      }
      for (var c in _modeleExistant!.champsMesures) {
        _champsMesuresControllers.add(TextEditingController(text: c));
      }
      for (var m in _modeleExistant!.materiauxDefaut) {
        _materiauxControllers.add(TextEditingController(text: m));
      }
    });
    if (_etapesControllers.isEmpty) {
      _ajouterEtape();
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _typeProduitController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    for (var c in _etapesControllers) {
      c.dispose();
    }
    for (var c in _champsMesuresControllers) {
      c.dispose();
    }
    for (var c in _materiauxControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _ajouterEtape([String titre = '']) {
    setState(() {
      _etapesControllers.add(TextEditingController(text: titre));
    });
  }

  void _supprimerEtape(int index) {
    setState(() {
      _etapesControllers[index].dispose();
      _etapesControllers.removeAt(index);
    });
  }

  void _ajouterChampMesure() {
    setState(() {
      _champsMesuresControllers.add(TextEditingController());
    });
  }

  void _supprimerChampMesure(int index) {
    setState(() {
      _champsMesuresControllers[index].dispose();
      _champsMesuresControllers.removeAt(index);
    });
  }

  void _ajouterMateriau() {
    setState(() {
      _materiauxControllers.add(TextEditingController());
    });
  }

  void _supprimerMateriau(int index) {
    setState(() {
      _materiauxControllers[index].dispose();
      _materiauxControllers.removeAt(index);
    });
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ModelesProvider>();

      final nom = _nomController.text.trim();
      final typeProduit = _typeProduitController.text.trim();
      final description = _descriptionController.text.trim();
      final prix = double.tryParse(_prixController.text.replaceAll(',', '.'));

      final etapes = _etapesControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .map((t) => EtapeFabrication(id: DateTime.now().microsecondsSinceEpoch.toString(), titre: t))
          .toList();

      final champs = _champsMesuresControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final materiaux = _materiauxControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (widget.modeleId == null) {
        await provider.ajouterModele(
          nom: nom,
          typeProduit: typeProduit,
          description: description,
          champsMesures: champs,
          materiauxDefaut: materiaux,
          etapes: etapes,
          prixIndicatif: prix,
        );
      } else {
        if (_modeleExistant != null) {
          final modif = _modeleExistant!.copyWith(
            nom: nom,
            typeProduit: typeProduit,
            description: description,
            champsMesures: champs,
            materiauxDefaut: materiaux,
            etapes: etapes,
            prixIndicatif: prix,
          );
          await provider.modifierModele(modif);
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdition = widget.modeleId != null;

    return Scaffold(
      backgroundColor: AtelierProColors.surface,
      appBar: AppBar(
        backgroundColor: AtelierProColors.surfaceContainer,
        title: Text(
          isEdition ? 'Modifier le modèle' : 'Nouveau modèle de fabrication',
          style: const TextStyle(color: AtelierProColors.onSurface),
        ),
        iconTheme: const IconThemeData(color: AtelierProColors.onSurface),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/modeles');
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AtelierProColors.terracotta))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nomController,
                    style: const TextStyle(color: AtelierProColors.onSurface),
                    decoration: _inputDecoration('Nom du modèle *', 'Ex: Robe de soirée sur mesure'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _typeProduitController,
                    style: const TextStyle(color: AtelierProColors.onSurface),
                    decoration: _inputDecoration('Type de produit *', 'Ex: Robe, Costume, Veston...'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: AtelierProColors.onSurface),
                    maxLines: 3,
                    decoration: _inputDecoration('Description par défaut', 'Détails du modèle...'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prixController,
                    style: const TextStyle(color: AtelierProColors.onSurface),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Prix indicatif (FCFA)', 'Ex: 25000'),
                  ),
                  const SizedBox(height: 24),

                  // Section Étapes de fabrication
                  _buildSectionHeader('Étapes de fabrication', _ajouterEtape),
                  const SizedBox(height: 8),
                  ..._etapesControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              style: const TextStyle(color: AtelierProColors.onSurface),
                              decoration: _inputDecoration('Étape ${index + 1}', 'Ex: Prise de mesures'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                            ),
                          ),
                          if (_etapesControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                              onPressed: () => _supprimerEtape(index),
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  // Section Matériaux par défaut
                  _buildSectionHeader('Matériaux par défaut', _ajouterMateriau),
                  const SizedBox(height: 8),
                  ..._materiauxControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              style: const TextStyle(color: AtelierProColors.onSurface),
                              decoration: _inputDecoration('Matériau ${index + 1}', 'Ex: Soie, Satin...'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => _supprimerMateriau(index),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _sauvegarder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AtelierProColors.terracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Enregistrer le modèle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AtelierProColors.terracotta,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Ajouter'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AtelierProColors.onSurfaceVariant),
      hintStyle: const TextStyle(color: AtelierProColors.onSurfaceVariant),
      filled: true,
      fillColor: AtelierProColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AtelierProColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AtelierProColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AtelierProColors.terracotta),
      ),
    );
  }
}
