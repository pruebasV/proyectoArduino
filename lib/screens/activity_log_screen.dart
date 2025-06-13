import 'package:flutter/material.dart';
import '../app_theme.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REGISTRO DE ACTIVIDAD'),
        backgroundColor: const Color(0xFF1D1E33),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildLogEntry('Apertura remota activada', 'Hoy, 10:30 AM', Icons.control_point),
            _buildLogEntry('Cobertura manual cerrada', 'Hoy, 9:15 AM', Icons.chevron_right_rounded),
            _buildLogEntry('Alerta de temperatura resuelta', 'Ayer, 8:45 PM', Icons.warning),
            _buildLogEntry('Calibración completada', 'Ayer, 6:30 PM', Icons.tune),
            _buildLogEntry('Sistema iniciado', 'Ayer, 5:00 PM', Icons.power),
          ],
        ),
      ),
    );
  }

  Widget _buildLogEntry(String title, String time, IconData icon) {
    return Card(
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[200]),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.blue),
      ),
    );
  }
}