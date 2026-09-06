import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/contact_actions.dart';
import '../../core/storage_service.dart';
import '../../core/theme.dart';
import '../../models/type_atelier.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ⚠️ À personnaliser : numéro WhatsApp du support Zinder Digital.
  static const _supportPhone = '227XXXXXXXX';

  String _appVersion = '';
  bool _uploadingLogo = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = '${info.version} (${info.buildNumber})');
    } catch (_) {
      // Pas bloquant si indisponible (ex: web debug).
    }
  }

  Future<void> _changeLogo() async {
    final file = await StorageService.pickImage();
    if (file == null) return;

    setState(() => _uploadingLogo = true);
    try {
      final atelier = context.read<AtelierProvider>().atelier;
      if (atelier == null) return;
      final url = await StorageService.upload(
        bucket: 'logos',
        userId: atelier.userId,
        key: 'logo',
        file: file,
      );
      final error = await context.read<AtelierProvider>().updateLogo(url);
      if (mounted && error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'envoi : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }

  Future<void> _editAtelier() async {
    final atelier = context.read<AtelierProvider>().atelier;
    if (atelier == null) return;

    final nomCtrl = TextEditingController(text: atelier.nomAtelier);
    final telephoneCtrl = TextEditingController(text: atelier.telephone ?? '');
    final villeCtrl = TextEditingController(text: atelier.ville ?? '');
    TypeAtelier typeAtelier = atelier.typeAtelier;
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
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
                const Text('Modifier mon atelier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(labelText: "Nom de l'atelier"),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<TypeAtelier>(
                  value: typeAtelier,
                  decoration: const InputDecoration(labelText: "Métier de l'atelier"),
                  items: TypeAtelier.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.dbValue)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => typeAtelier = v ?? typeAtelier),
                ),
                if (typeAtelier != atelier.typeAtelier) ...[
                  const SizedBox(height: 6),
                  Text(
                    "⚠️ Changer de métier modifie les champs proposés pour les prochaines fiches. "
                    "Les fiches déjà créées restent inchangées.",
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
                const SizedBox(height: 10),
                TextFormField(
                  controller: telephoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: villeCtrl,
                  decoration: const InputDecoration(labelText: 'Ville'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final error = await context.read<AtelierProvider>().updateAtelier({
                      'nom_atelier': nomCtrl.text.trim(),
                      'specialite': typeAtelier.dbValue,
                      'telephone': telephoneCtrl.text.trim().isEmpty ? null : telephoneCtrl.text.trim(),
                      'ville': villeCtrl.text.trim().isEmpty ? null : villeCtrl.text.trim(),
                    });
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
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atelier mis à jour')));
    }
  }

  Future<void> _changePassword() async {
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
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
              const Text('Changer le mot de passe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                validator: (v) => (v == null || v.length < 6) ? '6 caractères minimum' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                validator: (v) => v != passwordCtrl.text ? 'Les mots de passe ne correspondent pas' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final error = await context.read<AuthProvider>().updatePassword(passwordCtrl.text);
                  if (ctx.mounted) {
                    if (error != null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      Navigator.of(ctx).pop(true);
                    }
                  }
                },
                child: const Text('Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe mis à jour')));
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Tu devras te reconnecter avec ton e-mail et ton mot de passe.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Se déconnecter', style: TextStyle(color: AtelierProColors.rougeAlerte)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }

  Future<void> _contactSupport() async {
    await openWhatsApp(_supportPhone, message: 'Bonjour, j\'ai besoin d\'aide avec AtelierPro Mobile.');
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer mon compte ?'),
        content: const Text(
          'Ton atelier, tes clients, commandes, fiches et paiements seront '
          'définitivement supprimés. Cette action est irréversible.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: AtelierProColors.rougeAlerte)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final atelier = context.read<AtelierProvider>().atelier;
    if (atelier != null) {
      // Supprime la ligne atelier ; les clients/commandes/paiements/fiches
      // partent en cascade (contraintes ON DELETE CASCADE côté base).
      final error = await context.read<AtelierProvider>().deleteAtelier();
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
    if (!mounted) return;
    await context.read<AuthProvider>().signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tes données ont été supprimées. Pour supprimer aussi ton compte de connexion, contacte le support.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final atelier = context.watch<AtelierProvider>().atelier;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: GestureDetector(
                onTap: _uploadingLogo ? null : _changeLogo,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AtelierProColors.terracotta.withValues(alpha: 0.12),
                      backgroundImage: (atelier?.logoUrl != null) ? NetworkImage(atelier!.logoUrl!) : null,
                      child: _uploadingLogo
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : (atelier?.logoUrl == null
                              ? const Icon(Icons.storefront, color: AtelierProColors.terracotta)
                              : null),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AtelierProColors.terracotta,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(atelier?.nomAtelier ?? '—'),
              subtitle: Text(atelier?.specialiteLabel ?? ''),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: _editAtelier,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(atelier?.telephone ?? 'Téléphone non renseigné'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(atelier?.ville ?? 'Ville non renseignée'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(user?.email ?? '—'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Changer le mot de passe'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePassword,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: AtelierProColors.terracotta.withValues(alpha: 0.06),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.payments_outlined, color: AtelierProColors.terracotta),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Paiement mobile money (iPayMoney) : à venir. Les paiements se saisissent "
                      "manuellement pour l'instant depuis chaque commande.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Aide / Support (WhatsApp)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _contactSupport,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Confidentialité des données'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confidentialité'),
                      content: const Text(
                        'Tes données (clients, commandes, paiements) sont stockées sur Firebase et '
                        'ne sont accessibles qu\'à ton compte. Aucune donnée n\'est partagée avec des tiers.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Fermer')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _confirmSignOut,
            icon: const Icon(Icons.logout, color: AtelierProColors.rougeAlerte),
            label: const Text('Se déconnecter', style: TextStyle(color: AtelierProColors.rougeAlerte)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AtelierProColors.rougeAlerte)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _confirmDeleteAccount,
            child: const Text(
              'Supprimer mes données et mon compte',
              style: TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ),
          if (_appVersion.isNotEmpty) ...[
            const SizedBox(height: 24),
            Center(
              child: Text(
                'AtelierPro Mobile · v$_appVersion',
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
