import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/fiche_templates.dart';
import '../../core/theme.dart';
import '../../models/champ_fiche.dart';
import '../../models/fiche_mesure.dart';
import '../../models/fiche_template.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/fiches_mesures_provider.dart';
import '../../widgets/spinner.dart';

final _date = DateFormat('dd/MM/yyyy');

class MesuresScreen extends StatefulWidget {
  const MesuresScreen({super.key});

  @override
  State<MesuresScreen> createState() => _MesuresScreenState();
}

class _MesuresScreenState extends State<MesuresScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final userId = context.read<AtelierProvider>().atelier?.userId;
      if (userId != null) context.read<FichesMesuresProvider>().load(userId);
    }
  }

  FicheTemplate get _template {
    final typeAtelier = context.read<AtelierProvider>().atelier?.typeAtelier;
    return ficheTemplates[typeAtelier] ?? ficheTemplates.values.last;
  }

  Future<void> _openForm({FicheMesure? existing}) async {
    final userId = context.read<AtelierProvider>().atelier!.userId;
    final clients = context.read<ClientsProvider>().clients;
    final template = _template;
    final titreCtrl = TextEditingController(text: existing?.titre ?? template.nomFiche);
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String? clientId = existing?.clientId ?? (clients.isNotEmpty ? clients.first.id : null);

    // Un contrôleur par champ texte/nombre, et une valeur sélectionnée par
    // champ liste — pilotés entièrement par le template du métier.
    final champCtrls = <String, TextEditingController>{};
    final champListe = <String, String?>{};
    for (final champ in template.champs) {
      final existingValue = existing?.mesures[champ.id];
      if (champ.typeChamp == TypeChamp.liste) {
        champListe[champ.id] = existingValue?.toString();
      } else {
        champCtrls[champ.id] = TextEditingController(text: existingValue?.toString() ?? '');
      }
    }
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    existing == null ? 'Nouvelle ${template.nomFiche.toLowerCase()}' : 'Modifier la fiche',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: clientId,
                    decoration: const InputDecoration(labelText: 'Client'),
                    items: clients
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nomComplet)))
                        .toList(),
                    onChanged: existing != null ? null : (v) => clientId = v,
                    validator: (v) => v == null ? 'Sélectionnez un client' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: titreCtrl,
                    decoration: const InputDecoration(labelText: 'Titre'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
                  ),
                  const SizedBox(height: 20),
                  for (final champ in template.champs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: champ.typeChamp == TypeChamp.liste
                          ? DropdownButtonFormField<String>(
                              value: champListe[champ.id],
                              decoration: InputDecoration(labelText: champ.label),
                              items: (champ.options ?? [])
                                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                                  .toList(),
                              onChanged: (v) => setSheetState(() => champListe[champ.id] = v),
                              validator: champ.obligatoire
                                  ? (v) => (v == null || v.isEmpty) ? 'Champ requis' : null
                                  : null,
                            )
                          : TextFormField(
                              controller: champCtrls[champ.id],
                              keyboardType: champ.typeChamp == TypeChamp.nombre
                                  ? const TextInputType.numberWithOptions(decimal: true)
                                  : TextInputType.text,
                              decoration: InputDecoration(
                                labelText: champ.label,
                                suffixText: champ.unite,
                              ),
                              validator: champ.obligatoire
                                  ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null
                                  : null,
                            ),
                    ),
                  TextFormField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: clients.isEmpty
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final donnees = <String, dynamic>{};
                            for (final champ in template.champs) {
                              if (champ.typeChamp == TypeChamp.liste) {
                                final v = champListe[champ.id];
                                if (v != null && v.isNotEmpty) donnees[champ.id] = v;
                              } else {
                                final raw = champCtrls[champ.id]!.text.trim();
                                if (raw.isEmpty) continue;
                                donnees[champ.id] = champ.typeChamp == TypeChamp.nombre
                                    ? (double.tryParse(raw.replaceAll(',', '.')) ?? raw)
                                    : raw;
                              }
                            }

                            String? error;
                            if (existing == null) {
                              error = await context.read<FichesMesuresProvider>().addFiche(FicheMesure(
                                    id: '',
                                    userId: userId,
                                    clientId: clientId!,
                                    titre: titreCtrl.text.trim(),
                                    mesures: donnees,
                                    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ));
                            } else {
                              error = await context.read<FichesMesuresProvider>().updateFiche(existing.id, {
                                'titre': titreCtrl.text.trim(),
                                'mesures': donnees,
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
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fiche enregistrée')));
    }
  }

  Future<void> _confirmDelete(FicheMesure fiche) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette fiche ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: AtelierProColors.rougeAlerte)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<FichesMesuresProvider>().deleteFiche(fiche.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fichesProvider = context.watch<FichesMesuresProvider>();
    final clientsProvider = context.watch<ClientsProvider>();
    final template = _template;

    return Scaffold(
      appBar: AppBar(title: Text(template.nomFiche)),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = context.read<AtelierProvider>().atelier?.userId;
          if (userId != null) await context.read<FichesMesuresProvider>().load(userId);
        },
        child: fichesProvider.loading && fichesProvider.fiches.isEmpty
            ? ListView(children: const [SizedBox(height: 200), AtelierSpinner()])
            : fichesProvider.fiches.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(child: Text('Aucune ${template.nomFiche.toLowerCase()}')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: fichesProvider.fiches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final fiche = fichesProvider.fiches[i];
                      final client = clientsProvider.byId(fiche.clientId);
                      return Card(
                        child: ListTile(
                          onTap: () => _openForm(existing: fiche),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x1F442A22),
                            child: Icon(Icons.description_outlined, color: AtelierProColors.terracotta, size: 20),
                          ),
                          title: Text(fiche.titre),
                          subtitle: Text('${client?.nomComplet ?? 'Client'} · ${_date.format(fiche.updatedAt)}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') _confirmDelete(fiche);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'info',
                                enabled: false,
                                child: Text('${fiche.mesures.length} champs',
                                    style: const TextStyle(fontSize: 12, color: Colors.black45)),
                              ),
                              const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: clientsProvider.clients.isEmpty
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ajoutez d\'abord un client')),
                )
            : () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
