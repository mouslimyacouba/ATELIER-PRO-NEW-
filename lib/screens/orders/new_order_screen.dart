import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/fiches_mesures_provider.dart';
import '../../providers/orders_provider.dart';

class NewOrderScreen extends StatefulWidget {
  final String? initialClientId;
  const NewOrderScreen({super.key, this.initialClientId});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _clientId;
  String? _ficheMesureId;
  DateTime? _dateEcheance;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _clientId = widget.initialClientId;
  }

  bool _fichesLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fichesLoaded) {
      _fichesLoaded = true;
      final userId = context.read<AtelierProvider>().atelier?.userId;
      if (userId != null) context.read<FichesMesuresProvider>().load(userId);
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
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
    if (!_formKey.currentState!.validate() || _clientId == null) {
      if (_clientId == null) setState(() => _error = 'Sélectionnez un client');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final userId = context.read<AtelierProvider>().atelier!.userId;
    final clientNom = context.read<ClientsProvider>().byId(_clientId!)?.nomComplet;
    final result = await context.read<OrdersProvider>().createOrder(AtelierOrder(
          id: '',
          userId: userId,
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
        ));

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = result;
    });
    if (result == null) context.go('/commandes');
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.watch<ClientsProvider>().clients;
    final fiches = _clientId == null
        ? <dynamic>[]
        : context.watch<FichesMesuresProvider>().forClient(_clientId!);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle commande')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _clientId,
                decoration: const InputDecoration(labelText: 'Client'),
                items: clients
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nomComplet)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _clientId = v;
                  _ficheMesureId = null;
                }),
                hint: clients.isEmpty ? const Text('Aucun client — ajoutez-en un d\'abord') : const Text('Choisir un client'),
              ),
              if (fiches.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _ficheMesureId,
                  decoration: const InputDecoration(labelText: 'Fiche liée (optionnel)'),
                  items: fiches
                      .map<DropdownMenuItem<String>>((f) => DropdownMenuItem(value: f.id, child: Text(f.titre)))
                      .toList(),
                  onChanged: (v) => setState(() => _ficheMesureId = v),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description de la commande'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description requise' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Montant total (FCFA)'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_dateEcheance == null
                    ? "Date de livraison souhaitée (optionnel)"
                    : "Livraison : ${_dateEcheance!.day}/${_dateEcheance!.month}/${_dateEcheance!.year}"),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: _pickDate,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_loading || clients.isEmpty) ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Créer la commande'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
