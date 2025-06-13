import 'package:flutter/material.dart';
import '../app_theme.dart';

class RemoteOpeningScreen extends StatefulWidget {
  const RemoteOpeningScreen({super.key});

  @override
  State<RemoteOpeningScreen> createState() => _RemoteOpeningScreenState();
}

class _RemoteOpeningScreenState extends State<RemoteOpeningScreen> {
  // Estados de los sistemas
  bool _sistemaRiego =true;
  bool _ventilacion = true;
  bool _iluminacion = true;
  bool _calefaccion = true;
  bool _cortinas = true;
  bool _sistemaSeguridad = true;

  @override
  Widget build(BuildContext context) {
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
              icon: Icons.air,
              title: 'Ventilación',
              value: _ventilacion,
              onChanged: (value) => setState(() => _ventilacion = value),
              color: Colors.green,
            ),
            
            // Iluminación
            _buildSystemCard(
              icon: Icons.lightbulb,
              title: 'Iluminación',
              value: _iluminacion,
              onChanged: (value) => setState(() => _iluminacion = value),
              color: Colors.amber,
            ),
            
            // Calefacción
            _buildSystemCard(
              icon: Icons.thermostat,
              title: 'Calefacción',
              value: _calefaccion,
              onChanged: (value) => setState(() => _calefaccion = value),
              color: Colors.orange,
            ),
            
            // Cortinas
            _buildSystemCard(
              icon: Icons.curtains,
              title: 'Cortinas',
              value: _cortinas,
              onChanged: (value) => setState(() => _cortinas = value),
              color: Colors.purple,
            ),
            
            // Sistema de seguridad
            _buildSystemCard(
              icon: Icons.security,
              title: 'Sistema de Seguridad',
              value: _sistemaSeguridad,
              onChanged: (value) => setState(() => _sistemaSeguridad = value),
              color: Colors.red,
            ),
            
            const SizedBox(height: 30),
            
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
    final activeCount = [
      _sistemaRiego,
      _ventilacion,
      _iluminacion,
      _calefaccion,
      _cortinas,
      _sistemaSeguridad
    ].where((state) => state).length;

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
                    '$activeCount de 6 sistemas activos',
                    style: TextStyle(
                      fontSize: 16,
                      color: activeCount > 3 ? Colors.green : Colors.amber,
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

  void _toggleAllSystems() {
    final allActive = !_sistemaRiego ||
        !_ventilacion ||
        !_iluminacion ||
        !_calefaccion ||
        !_cortinas ||
        !_sistemaSeguridad;

    setState(() {
      _sistemaRiego = allActive;
      _ventilacion = allActive;
      _iluminacion = allActive;
      _calefaccion = allActive;
      _cortinas = allActive;
      _sistemaSeguridad = allActive;
    });
  }

  void _applyChanges() {
    // Aquí iría la lógica para enviar los comandos al invernadero
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
  }

  int _countActiveSystems() {
    return [
      _sistemaRiego,
      _ventilacion,
      _iluminacion,
      _calefaccion,
      _cortinas,
      _sistemaSeguridad
    ].where((state) => state).length;
  }
}