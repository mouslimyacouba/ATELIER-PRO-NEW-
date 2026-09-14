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
    if (_clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un client')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final atelier = context.read<AtelierProvider>().atelier;
    if (atelier == null) return;

    final clientNom = context.read<ClientsProvider>().byId(_clientId!)?.nomComplet;
    List<Map<String, dynamic>> etapesSnapshot = [];
    if (_modeleId != null) {
      final modele = context.read<ModelesProvider>().tousLesModeles.firstWhere((m) => m.id == _modeleId);
      int ordre = 1;
      etapesSnapshot = modele.etapes.map((e) => {'id': e.id, 'ordre': ordre++, 'titre': e.titre, 'terminee': false}).toList();
    }

    final result = await context.read<OrdersProvider>().createOrder(AtelierOrder(
      id: '',
      userId: atelier.userId,
      clientId: _clientId!,
      clientName: clientNom,
      description: _descCtrl.text.trim(),
      status: OrderStatus.enAttente,
      dateCommande: DateTime.now(),
      dateEcheance: _dateEcheance,
      prixTotal: double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0,
      acompte: 0,
      createdAt: DateTime.now(),
      ficheMesureId: _ficheMesureId,
      modeleId: _modeleId,
      etapesSnapshot: etapesSnapshot,
      specificationsMetier: _specificationsMetier,
    ));

    if (!mounted) return;
    if (result == null) context.go('/commandes');
    else setState(() { _loading = false; _error = result; });
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
    return Column(children: [
      if (fiches.isNotEmpty) DropdownButtonFormField<String>(
        value: _ficheMesureId,
        decoration: const InputDecoration(labelText: 'Fiche liée', border: OutlineInputBorder()),
        items: fiches.map<DropdownMenuItem<String>>((f) => DropdownMenuItem(value: f.id, child: Text(f.titre))).toList(),
        onChanged: (v) => setState(() => _ficheMesureId = v),
      ),
      const SizedBox(height: 16),
      TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      TextFormField(controller: _amountCtrl, decoration: const InputDecoration(labelText: 'Montant (FCFA)', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      ListTile(
        title: Text(_dateEcheance == null ? "Date de livraison" : "Livraison : ${_dateEcheance!.day}/${_dateEcheance!.month}"),
        trailing: const Icon(Icons.calendar_today),
        onTap: _pickDate,
      ),
    ]);
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
