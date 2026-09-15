import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../models/modele_fabrication.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/fiches_mesures_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/modeles_provider.dart';
import '../../providers/metier_provider.dart';
import '../../providers/stock_provider.dart';
import '../../core/widgets/dynamic_fields_form.dart';

enum NewOrderStep { clientMetier, specifications, fabricationAcompte }

class NewOrderScreen extends StatefulWidget {
  final String? initialClientId;
  const NewOrderScreen({super.key, this.initialClientId});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  NewOrderStep _currentStep = NewOrderStep.clientMetier;
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _dynamicControllers = {};
  Map<String, dynamic> _specificationsMetier = {};

  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _coutMateriauxCtrl = TextEditingController(text: '0');
  final TextEditingController _coutMainDoeuvreCtrl = TextEditingController(text: '0');
  final TextEditingController _coutTransportCtrl = TextEditingController(text: '0');

  String? _clientId;
  String? _modeleId;
  String? _ficheMesureId;
  DateTime? _dateEcheance;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _clientId = widget.initialClientId;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _coutMateriauxCtrl.dispose();
    _coutMainDoeuvreCtrl.dispose();
    _coutTransportCtrl.dispose();
    for (var c in _dynamicControllers.values) c.dispose();
    super.dispose();
  }

  void _appliquerModele(ModeleFabrication modele) {
    setState(() {
      _modeleId = modele.id;
      _descCtrl.text = modele.description.isNotEmpty ? modele.description : modele.nom;
      if (modele.prixIndicatif != null) {
        _amountCtrl.text = modele.prixIndicatif!.toStringAsFixed(0);
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dateEcheance = picked);
  }

  Future<void> _submit() async {
    if (_loading) return;

    if (_clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un client'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final atelier = context.read<AtelierProvider>().atelier;

    if (atelier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atelier non chargé. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final clientNom = context
          .read<ClientsProvider>()
          .byId(_clientId!)
          ?.nomComplet;

      List<Map<String, dynamic>> etapesSnapshot = [];
      List<String> modelMateriaux = [];

      if (_modeleId != null) {
        final modele = context
            .read<ModelesProvider>()
            .tousLesModeles
            .firstWhere((m) => m.id == _modeleId);

        int ordre = 1;
        modelMateriaux = modele.materiauxDefaut;

        etapesSnapshot = modele.etapes.map((e) {
          return {
            'id': e.id,
            'ordre': ordre++,
            'titre': e.titre,
            'terminee': false,
          };
        }).toList();
      }

      final result = await context.read<OrdersProvider>().createOrder(
        AtelierOrder(
          id: '',
          userId: atelier.userId,
          clientId: _clientId!,
          clientName: clientNom,
          description: _descCtrl.text.trim().isEmpty
              ? 'Commande sans description'
              : _descCtrl.text.trim(),
          status: OrderStatus.enAttente,
          dateCommande: DateTime.now(),
          dateEcheance: _dateEcheance,
          prixTotal: double.tryParse(
                _amountCtrl.text.replaceAll(',', '.'),
              ) ??
              0,
          acompte: 0,
          createdAt: DateTime.now(),
          ficheMesureId: _ficheMesureId,
          modeleId: _modeleId,
          etapesSnapshot: etapesSnapshot,
          specificationsMetier: _specificationsMetier,
          coutMateriaux: double.tryParse(_coutMateriauxCtrl.text.replaceAll(',', '.')) ?? 0.0,
          coutMainDoeuvre: double.tryParse(_coutMainDoeuvreCtrl.text.replaceAll(',', '.')) ?? 0.0,
          coutTransport: double.tryParse(_coutTransportCtrl.text.replaceAll(',', '.')) ?? 0.0,
        ),
        stockProvider: context.read<StockProvider>(),
        materiauxDefaut: modelMateriaux,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() => _loading = false);
        context.go('/commandes');
      } else {
        setState(() {
          _loading = false;
          _error = result;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $result'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtelierProColors.surface,
      appBar: _buildHeader(),
      body: Form(key: _formKey, child: _buildCurrentStepView()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      title: const Text('Nouvelle Commande'),
      backgroundColor: AtelierProColors.surfaceContainer,
    );
  }

  Widget _buildCurrentStepView() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: switch (_currentStep) {
      NewOrderStep.clientMetier => _buildClientMetierStep(),
      NewOrderStep.specifications => _buildSpecsStep(),
      NewOrderStep.fabricationAcompte => _buildFabStep(),
    });
  }

  Widget _buildClientMetierStep() {
    final clients = context.watch<ClientsProvider>().clients;
    final modeles = context.watch<ModelesProvider>().modeles;
    return Column(children: [
      DropdownButtonFormField<String>(
        value: _clientId,
        decoration: const InputDecoration(labelText: 'Client *', border: OutlineInputBorder()),
        items: clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nomComplet))).toList(),
        onChanged: (v) => setState(() => _clientId = v),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _modeleId,
        decoration: const InputDecoration(labelText: 'Modèle (optionnel)', border: OutlineInputBorder()),
        items: [const DropdownMenuItem(value: null, child: Text('Aucun')), ...modeles.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nom)))],
        onChanged: (v) {
          if (v != null) _appliquerModele(modeles.firstWhere((m) => m.id == v));
          else setState(() => _modeleId = null);
        },
      ),
    ]);
  }

  Widget _buildSpecsStep() {
    final metierConfig = context.watch<MetierProvider>().config;
    if (metierConfig == null || metierConfig.champs.isEmpty) return const Text('Aucune spécification requise.');
    return DynamicFieldsForm(fields: metierConfig.champs, controllers: _dynamicControllers, onChanged: (v) => _specificationsMetier = v);
  }

  Widget _buildFabStep() {
    final fiches = _clientId == null ? <dynamic>[] : context.watch<FichesMesuresProvider>().forClient(_clientId!);

    final prixVente = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final mat = double.tryParse(_coutMateriauxCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final mo = double.tryParse(_coutMainDoeuvreCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final trans = double.tryParse(_coutTransportCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final totalRevient = mat + mo + trans;
    final benefice = prixVente - totalRevient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fiches.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            value: _ficheMesureId,
            decoration: const InputDecoration(labelText: 'Fiche liée', border: OutlineInputBorder()),
            items: fiches.map<DropdownMenuItem<String>>((f) => DropdownMenuItem(value: f.id, child: Text(f.titre))).toList(),
            onChanged: (v) => setState(() => _ficheMesureId = v),
          ),
          const SizedBox(height: 16),
        ],
        TextFormField(
          controller: _descCtrl,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Description de la commande', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Prix de vente au client (FCFA) *', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 24),

        const Text(
          'ESTIMATION DES COÛTS & MARGE',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AtelierProColors.terracotta, letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: _coutMateriauxCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Coût des matériaux (FCFA)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _coutMainDoeuvreCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Coût de la main-d\'œuvre (FCFA)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _coutTransportCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Coût de transport / logistique (FCFA)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: benefice >= 0 ? Colors.green.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: benefice >= 0 ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Coût de revient total :', style: TextStyle(fontSize: 14)),
                  Text('${totalRevient.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    benefice >= 0 ? 'Bénéfice net estimé :' : 'Perte estimée :',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: benefice >= 0 ? Colors.green : Colors.red),
                  ),
                  Text(
                    '${benefice.toStringAsFixed(0)} FCFA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: benefice >= 0 ? Colors.green : Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ListTile(
          title: Text(_dateEcheance == null ? "Date d'échéance / livraison" : "Livraison : ${_dateEcheance!.day}/${_dateEcheance!.month}/${_dateEcheance!.year}"),
          trailing: const Icon(Icons.calendar_today),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: AtelierProColors.outlineVariant)),
          onTap: _pickDate,
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AtelierProColors.surfaceContainerHigh,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(children: [
        if (_currentStep != NewOrderStep.clientMetier)
          TextButton(onPressed: () => setState(() => _currentStep = NewOrderStep.values[_currentStep.index - 1]), child: const Text('Précédent')),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            if (_currentStep == NewOrderStep.fabricationAcompte) _submit();
            else setState(() => _currentStep = NewOrderStep.values[_currentStep.index + 1]);
          },
          child: Text(_currentStep == NewOrderStep.fabricationAcompte ? 'CRÉER' : 'Suivant'),
        ),
      ]),
    );
  }
}
