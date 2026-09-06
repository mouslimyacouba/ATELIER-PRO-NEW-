import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/type_atelier.dart';
import '../../providers/atelier_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  TypeAtelier _typeAtelier = TypeAtelier.couture;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telephoneCtrl.dispose();
    _villeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context.read<AtelierProvider>().createAtelier(
          nomAtelier: _nomCtrl.text.trim(),
          specialite: _typeAtelier.dbValue,
          telephone: _telephoneCtrl.text.trim().isEmpty ? null : _telephoneCtrl.text.trim(),
          ville: _villeCtrl.text.trim().isEmpty ? null : _villeCtrl.text.trim(),
        );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = result;
    });
    // Si result == null, le router redirige automatiquement vers '/'
    // dès que AtelierProvider notifie son changement d'état.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtelierProColors.sable,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Créons votre atelier',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Quelques infos pour démarrer — vous pourrez tout modifier plus tard.",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: "Nom de l'atelier"),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TypeAtelier>(
                  value: _typeAtelier,
                  decoration: const InputDecoration(labelText: "Métier de l'atelier"),
                  items: TypeAtelier.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.dbValue)))
                      .toList(),
                  onChanged: (v) => setState(() => _typeAtelier = v ?? _typeAtelier),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telephoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Téléphone (optionnel)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _villeCtrl,
                  decoration: const InputDecoration(labelText: 'Ville (optionnel)'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AtelierProColors.rougeAlerte)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer mon atelier'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
