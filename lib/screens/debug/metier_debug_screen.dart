import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/metier_provider.dart';
import '../../core/widgets/dynamic_fields_form.dart';

class MetierDebugScreen extends StatefulWidget {
  const MetierDebugScreen({super.key});

  @override
  State<MetierDebugScreen> createState() => _MetierDebugScreenState();
}

class _MetierDebugScreenState extends State<MetierDebugScreen> {
  final Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic> _values = {};

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metier = context.watch<MetierProvider>().config;

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Métier & Formulaire')),
      body: metier == null
          ? const Center(child: Text('Aucun métier configuré'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Métier actuel : ${metier.nom}',
                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Formulaire dynamique :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DynamicFieldsForm(
                  fields: metier.champs,
                  controllers: _controllers,
                  onChanged: (v) => setState(() => _values = v),
                ),
                Text('Valeurs : $_values'),
                const Divider(),
                const Text('Matériaux :', style: TextStyle(fontWeight: FontWeight.bold)),
                ...metier.materiaux.map((m) => ListTile(title: Text(m))),
                const Divider(),
                const Text('Étapes :', style: TextStyle(fontWeight: FontWeight.bold)),
                ...metier.etapes.map((e) => ListTile(title: Text(e))),
              ],
            ),
    );
  }
}
