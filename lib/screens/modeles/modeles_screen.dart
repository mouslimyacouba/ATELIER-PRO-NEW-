import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/modeles_provider.dart';
import '../../core/theme.dart';
import '../../models/modele_fabrication.dart';

class ModelesScreen extends StatelessWidget {
  const ModelesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modelesProvider = context.watch<ModelesProvider>();
    final modeles = modelesProvider.modeles;

    return Scaffold(
      backgroundColor: AtelierProColors.surface,
      appBar: AppBar(
        backgroundColor: AtelierProColors.surfaceContainer,
        title: const Text(
          'Mes modèles de fabrication',
          style: TextStyle(color: AtelierProColors.onSurface),
        ),
        iconTheme: const IconThemeData(color: AtelierProColors.onSurface),
      ),
      body: modelesProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AtelierProColors.terracotta,
              ),
            )
          : modeles.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.design_services_outlined,
                          size: 64,
                          color: AtelierProColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun modèle de fabrication',
                          style: TextStyle(
                            color: AtelierProColors.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Créez des modèles pour préremplir rapidement vos nouvelles commandes (description, prix, étapes de fabrication...).',
                          style: TextStyle(
                            color: AtelierProColors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/modeles/nouveau'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AtelierProColors.terracotta,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Créer un modèle'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: modeles.length,
                  itemBuilder: (context, index) {
                    final modele = modeles[index];
                    return Card(
                      color: AtelierProColors.surfaceContainer,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AtelierProColors.outlineVariant,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          modele.nom,
                          style: const TextStyle(
                            color: AtelierProColors.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              modele.typeProduit,
                              style: const TextStyle(
                                color: AtelierProColors.terracotta,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              modele.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AtelierProColors.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.format_list_numbered,
                                  size: 14,
                                  color: AtelierProColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${modele.etapes.length} étapes',
                                  style: const TextStyle(
                                    color: AtelierProColors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                if (modele.prixIndicatif != null) ...[
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.euro,
                                    size: 14,
                                    color: AtelierProColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${modele.prixIndicatif!.toStringAsFixed(2)} €',
                                    style: const TextStyle(
                                      color: AtelierProColors.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _confirmerSuppression(context, modele),
                        ),
                        onTap: () => context.push('/modeles/${modele.id}'),
                      ),
                    );
                  },
                ),
      floatingActionButton: modeles.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: AtelierProColors.terracotta,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/modeles/nouveau'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _confirmerSuppression(BuildContext context, ModeleFabrication modele) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AtelierProColors.surfaceContainer,
        title: const Text(
          'Supprimer le modèle',
          style: TextStyle(color: AtelierProColors.onSurface),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer "${modele.nom}" ? Cela n\'affectera pas les commandes déjà créées.',
          style: const TextStyle(color: AtelierProColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<ModelesProvider>().supprimerModele(modele.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
