import 'package:flutter/material.dart';
import '../core/config/metier_config.dart';
import '../core/config/metier_registry.dart';
import '../providers/atelier_provider.dart';

class MetierProvider extends ChangeNotifier {
  final AtelierProvider _atelierProvider;
  MetierConfig? _currentConfig;

  MetierProvider(this._atelierProvider) {
    _atelierProvider.addListener(_updateConfig);
    _updateConfig();
  }

  MetierConfig? get config => _currentConfig;

  void _updateConfig() {
    final atelier = _atelierProvider.atelier;
    if (atelier == null) {
      _currentConfig = null;
    } else {
      _currentConfig = MetierRegistry.getByType(atelier.typeAtelier);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _atelierProvider.removeListener(_updateConfig);
    super.dispose();
  }
}
