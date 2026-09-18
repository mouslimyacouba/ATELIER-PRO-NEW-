import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/atelier_provider.dart';
import '../../models/stock_item.dart';
import '../../core/theme.dart';

class StockFormScreen extends StatefulWidget {
  final String? itemId;

  const StockFormScreen({super.key, this.itemId});

  @override
  State<StockFormScreen> createState() => _StockFormScreenState();
}

class _StockFormScreenState extends State<StockFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomCtrl;
  late TextEditingController _categorieCtrl;
  late TextEditingController _quantiteCtrl;
  late TextEditingController _uniteCtrl;
  late TextEditingController _seuilAlerteCtrl;
  late TextEditingController _coutUnitaireCtrl;

  bool _isLoading = false;
  StockItem? _itemExistant;

  final List<String> _categoriesSuggerees = [
    'Tissus',
    'Fils',
    'Boutons',
    'Fermetures',
    'Quincaillerie',
    'Bois',
    'Peinture',
    'Élastiques',
    'Cuir',
    'Perles',
    'Général'
  ];

  final List<String> _unitesSuggerees = [
    'mètres',
    'pièces',
    'kg',
    'litres',
    'bobines',
    'rouleaux',
    'sacs',
    'paquets'
  ];

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController();
    _categorieCtrl = TextEditingController(text: 'Tissus');
    _quantiteCtrl = TextEditingController(text: '0');
    _uniteCtrl = TextEditingController(text: 'mètres');
    _seuilAlerteCtrl = TextEditingController(text: '2');
    _coutUnitaireCtrl = TextEditingController(text: '0');

    if (widget.itemId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<StockProvider>();
        try {
          _itemExistant = provider.items.firstWhere((i) => i.id == widget.itemId);
          setState(() {
            _nomCtrl.text = _itemExistant!.nom;
            _categorieCtrl.text = _itemExistant!.categorie;
            _quantiteCtrl.text = _itemExistant!.quantite.toString();
            _uniteCtrl.text = _itemExistant!.unite;
            _seuilAlerteCtrl.text = _itemExistant!.seuilAlerte.toString();
            _coutUnitaireCtrl.text = _itemExistant!.coutUnitaire.toStringAsFixed(0);
          });
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _categorieCtrl.dispose();
    _quantiteCtrl.dispose();
    _uniteCtrl.dispose();
    _seuilAlerteCtrl.dispose();
    _coutUnitaireCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AtelierProvider>().atelier?.userId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    final item = StockItem(
      id: widget.itemId ?? '',
      userId: userId,
      nom: _nomCtrl.text.trim(),
      categorie: _categorieCtrl.text.trim(),
      quantite: double.tryParse(_quantiteCtrl.text.trim()) ?? 0.0,
      unite: _uniteCtrl.text.trim(),
      seuilAlerte: double.tryParse(_seuilAlerteCtrl.text.trim()) ?? 2.0,
      coutUnitaire: double.tryParse(_coutUnitaireCtrl.text.trim()) ?? 0.0,
      updatedAt: DateTime.now(),
    );

    final error = await context.read<StockProvider>().saveItem(item);

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article de stock enregistré')));
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _supprimer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer l'article ?"),
        content: const Text("Cette action retirera définitivement cet article de votre inventaire de stock."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: AtelierProColors.rougeAlerte)),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.itemId != null && mounted) {
      setState(() => _isLoading = true);
      final error = await context.read<StockProvider>().deleteItem(widget.itemId!);
      if (mounted) {
        setState(() => _isLoading = false);
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
        } else {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdition = widget.itemId != null;

    return Scaffold(
      backgroundColor: AtelierProColors.surface,
      appBar: AppBar(
        title: Text(isEdition ? "Modifier l'article" : 'Ajouter au stock'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/stock');
            }
          },
        ),
        actions: [
          if (isEdition)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AtelierProColors.rougeAlerte),
              tooltip: "Supprimer l'article",
              onPressed: _isLoading ? null : _supprimer,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AtelierProColors.terracotta))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nomCtrl,
                    decoration: _inputDecoration('Nom de l\'article *', 'Ex: Bazin Riche Blanc, Fils noir 40/2'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Le nom est obligatoire' : null,
                  ),
                  const SizedBox(height: 16),

                  // Catégorie Autocomplete ou Menu déroulant
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _categorieCtrl,
                          decoration: _inputDecoration('Catégorie *', 'Ex: Tissus, Fils, Quincaillerie'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'La catégorie est obligatoire' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.arrow_drop_down),
                        onSelected: (v) => setState(() => _categorieCtrl.text = v),
                        itemBuilder: (ctx) => _categoriesSuggerees
                            .map((cat) => PopupMenuItem<String>(value: cat, child: Text(cat)))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantiteCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration('Quantité en stock *', 'Ex: 15.5'),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Quantité invalide' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _uniteCtrl,
                                decoration: _inputDecoration('Unité de mesure', 'Ex: mètres, pièces'),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              onSelected: (v) => setState(() => _uniteCtrl.text = v),
                              itemBuilder: (ctx) => _unitesSuggerees
                                  .map((unite) => PopupMenuItem<String>(value: unite, child: Text(unite)))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _seuilAlerteCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Seuil d\'alerte stock faible', 'Alerte si la quantité baisse sous...'),
                    validator: (v) => (v == null || double.tryParse(v) == null) ? 'Seuil invalide' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _coutUnitaireCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Coût d\'achat unitaire (FCFA)', 'Ex: 4500'),
                    validator: (v) => (v == null || double.tryParse(v) == null) ? 'Montant invalide' : null,
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _enregistrer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AtelierProColors.terracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isEdition ? 'Mettre à jour l\'article' : 'Enregistrer au stock',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AtelierProColors.surfaceContainer,
      labelStyle: const TextStyle(color: AtelierProColors.onSurfaceVariant),
      hintStyle: const TextStyle(color: AtelierProColors.onSurfaceVariant),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AtelierProColors.outlineVariant)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AtelierProColors.outlineVariant)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AtelierProColors.terracotta)),
    );
  }
}
