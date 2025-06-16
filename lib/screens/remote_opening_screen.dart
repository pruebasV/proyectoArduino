import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../app_theme.dart';

class RemoteOpeningScreen extends StatefulWidget {
  const RemoteOpeningScreen({super.key});

  @override
  State<RemoteOpeningScreen> createState() => _RemoteOpeningScreenState();
}

class _RemoteOpeningScreenState extends State<RemoteOpeningScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  
  // Estados de los sistemas
  bool _sistemaRiego = false;
  bool _leds = false;
  bool _buzzer = false;
  bool _ventilacion = false;

  @override
  void initState() {
    super.initState();
    _loadSystemStates();
  }

  Future<void> _loadSystemStates() async {
    try {
      await Firebase.initializeApp();
      
      DocumentSnapshot doc = await _firestore.collection('systems').doc('current_state').get();
      
      if (doc.exists) {
        setState(() {
          _sistemaRiego = doc['irrigation'] ?? false;
          _leds = doc['leds'] ?? false;
          _buzzer = doc['buzzer'] ?? false;
          _ventilacion = doc['ventilation'] ?? false;
          _isLoading = false;
        });
      } else {
        await _saveSystemStates();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading system states: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSystemStates() async {
    await _firestore.collection('systems').doc('current_state').set({
      'irrigation': _sistemaRiego,
      'leds': _leds,
      'buzzer': _buzzer,
      'ventilation': _ventilacion,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _applyChanges() async {
    try {
      setState(() => _isLoading = true);
      await _saveSystemStates();
      
      // Registrar el cambio en el log
      await _firestore.collection('logs').add({
        'title': 'Cambio de configuración',
        'description': 'Sistemas actualizados por el usuario',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system_change',
        'details': {
          'riego': _sistemaRiego,
          'leds': _leds,
          'buzzer': _buzzer,
          'ventilacion': _ventilacion,
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Configuración aplicada: ${_countActiveSystems()} sistemas activados',
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleAllSystems() {
    final allActive = !_sistemaRiego || !_leds || !_buzzer || !_ventilacion;
    setState(() {
      _sistemaRiego = allActive;
      _leds = allActive;
      _buzzer = allActive;
      _ventilacion = allActive;
    });
  }

  int _countActiveSystems() {
    return [_sistemaRiego, _leds, _buzzer, _ventilacion].where((state) => state).length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('CONTROL DE SISTEMAS'),
          backgroundColor: const Color(0xFF1D1E33),
        ),
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONTROL DE SISTEMAS'),
        backgroundColor: const Color(0xFF1D1E33),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: _toggleAllSystems,
            tooltip: 'Activar/Desactivar todos',
          ),
        ],
      ),
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen de estado
            _buildStatusSummary(),
            const SizedBox(height: 30),
            
            // Sistema de riego
            _buildSystemCard(
              icon: Icons.water_drop,
              title: 'Sistema de Riego',
              value: _sistemaRiego,
              onChanged: (value) => setState(() => _sistemaRiego = value),
              color: Colors.blue,
            ),
            
            // Ventilación
            _buildSystemCard(
              icon: Icons.light,
              title: 'Leds',
              value: _leds,
              onChanged: (value) => setState(() => _leds = value),
              color: Colors.red,
            ),
            
            // Iluminación
            _buildSystemCard(
              icon: Icons.volume_up,
              title: 'buzzer',
              value: _buzzer,
              onChanged: (value) => setState(() => _buzzer = value),
              color: Colors.amber,
            ),
            
            // Calefacción
            _buildSystemCard(
              icon: Icons.air,
              title: 'Ventilación',
              value: _ventilacion,
              onChanged: (value) => setState(() => _ventilacion = value),
              color: Colors.blue,
            ),

            // Botón de aplicar cambios
            ElevatedButton.icon(
              onPressed: _applyChanges,
              icon: const Icon(Icons.send),
              label: const Text('APLICAR CAMBIOS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummary() {
    final activeCount = _countActiveSystems();

    return Card(
      color: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info, size: 36, color: Colors.blue),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado de Sistemas',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    '$activeCount de 4 sistemas activos',
                    style: TextStyle(
                      fontSize: 16,
                      color: activeCount > 2 ? Colors.green : Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              activeCount > 0 ? Icons.check_circle : Icons.warning,
              color: activeCount > 0 ? Colors.green : Colors.amber,
              size: 36,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Card(
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            Transform.scale(
              scale: 1.3,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: color,
                activeTrackColor: color.withOpacity(0.5),
                inactiveThumbColor: Colors.grey[300],
                inactiveTrackColor: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}