import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/client.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/clients_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/spinner.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final userId = context.read<AtelierProvider>().atelier?.userId;
      if (userId != null) context.read<ClientsProvider>().load(userId);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openForm({AtelierClient? existing}) async {
    final userId = context.read<AtelierProvider>().atelier!.userId;
    final nameCtrl = TextEditingController(text: existing?.nomComplet ?? '');
    final phoneCtrl = TextEditingController(text: existing?.telephone ?? '');
    final addressCtrl = TextEditingController(text: existing?.adresse ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing == null ? 'Nouveau client' : 'Modifier le client',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  hintText: '90 00 00 00',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.length != 8) return 'Le numéro doit avoir 8 chiffres';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Adresse'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final clientsProvider = context.read<ClientsProvider>();
                  String? error;
                  if (existing == null) {
                    error = await clientsProvider.addClient(AtelierClient(
                      id: '',
                      userId: userId,
                      nomComplet: nameCtrl.text.trim(),
                      telephone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                      adresse: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ));
                  } else {
                    error = await clientsProvider.updateClient(existing.id, {
                      'nom_complet': nameCtrl.text.trim(),
                      'telephone': phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                      'adresse': addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                      'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                    });
                  }
                  if (ctx.mounted) {
                    if (error != null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      Navigator.of(ctx).pop(true);
                    }
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client enregistré')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsProvider = context.watch<ClientsProvider>();
    final filtered = _query.isEmpty
        ? clientsProvider.clients
        : clientsProvider.clients
            .where((c) => c.nomComplet.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Rechercher un client…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final userId = context.read<AtelierProvider>().atelier?.userId;
                if (userId != null) await context.read<ClientsProvider>().load(userId);
              },
              child: clientsProvider.loading && clientsProvider.clients.isEmpty
                  ? const AtelierSpinner()
                  : clientsProvider.error != null && clientsProvider.clients.isEmpty
                      ? ErrorState(
                          message: clientsProvider.error!,
                          onRetry: () {
                            final userId = context.read<AtelierProvider>().atelier?.userId;
                            if (userId != null) context.read<ClientsProvider>().load(userId);
                          },
                        )
                      : filtered.isEmpty
                          ? _query.isNotEmpty
                              ? EmptyState(
                                  icon: Icons.search_off,
                                  title: 'Aucun résultat',
                                  subtitle: 'Aucun client ne correspond à "$_query".',
                                )
                              : EmptyState(
                                  icon: Icons.people_outline,
                                  title: 'Aucun client',
                                  subtitle: 'Ajoutez votre premier client pour commencer.',
                                  actionLabel: 'Ajouter un client',
                                  onAction: () => _openForm(),
                                )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final client = filtered[i];
                                return Card(
                                  child: ListTile(
                                    onTap: () => context.push('/clients/${client.id}'),
                                    leading: CircleAvatar(
                                      backgroundColor: AtelierProColors.terracotta.withValues(alpha: 0.12),
                                      backgroundImage: client.photoUrl != null ? NetworkImage(client.photoUrl!) : null,
                                      child: client.photoUrl == null
                                          ? Text(
                                              client.nomComplet.isNotEmpty ? client.nomComplet[0].toUpperCase() : '?',
                                              style: const TextStyle(color: AtelierProColors.terracotta),
                                            )
                                          : null,
                                    ),
                                    title: Text(client.nomComplet),
                                    subtitle: Text(client.telephone ?? 'Pas de téléphone'),
                                    trailing: const Icon(Icons.chevron_right),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
