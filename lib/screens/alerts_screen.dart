import 'package:flutter/material.dart';
import '../app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALERTAS'),
        backgroundColor: const Color(0xFF1D1E33),
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: () {},
            tooltip: 'Enviar alertas por correo',
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildAlertCard(
                    title: 'Alerta de temperatura',
                    description: 'La temperatura ha excedido los 30°C',
                    time: 'Hoy, 10:30 AM',
                    icon: Icons.warning,
                    iconColor: Colors.amber,
                  ),
                  const SizedBox(height: 15),
                  _buildAlertCard(
                    title: 'Alerta de seguridad',
                    description: 'Movimiento detectado en zona restringida',
                    time: 'Ayer, 8:45 PM',
                    icon: Icons.security,
                    iconColor: Colors.red,
                  ),
                  const SizedBox(height: 15),
                  _buildAlertCard(
                    title: 'Sistema de riego fallido',
                    description: 'Baja presión detectada en tubería principal',
                    time: 'Ayer, 5:20 PM',
                    icon: Icons.water_damage,
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(height: 15),
                  _buildAlertCard(
                    title: 'Batería baja',
                    description: 'Sistema de respaldo al 15% de capacidad',
                    time: 'Ayer, 2:45 PM',
                    icon: Icons.battery_alert,
                    iconColor: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.email),
              label: const Text('ENVIAR TODAS LAS ALERTAS POR CORREO'),
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

  Widget _buildAlertCard({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      color: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}