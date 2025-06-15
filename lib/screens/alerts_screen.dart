import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _isSending = false;
  
  final List<Map<String, dynamic>> _alerts = [
    {
      'id': 1,
      'title': 'Alerta de temperatura',
      'description': 'La temperatura ha excedido los 30°C',
      'time': 'Hoy, 10:30 AM',
      'icon': Icons.warning,
      'iconColor': Colors.amber,
      'selected': false,
    },
    {
      'id': 2,
      'title': 'Alerta de seguridad',
      'description': 'Movimiento detectado en zona restringida',
      'time': 'Ayer, 8:45 PM',
      'icon': Icons.security,
      'iconColor': Colors.red,
      'selected': false,
    },
    {
      'id': 3,
      'title': 'Sistema de riego fallido',
      'description': 'Baja presión detectada en tubería principal',
      'time': 'Ayer, 5:20 PM',
      'icon': Icons.water_damage,
      'iconColor': Colors.blue,
      'selected': false,
    },
    {
      'id': 4,
      'title': 'Batería baja',
      'description': 'Sistema de respaldo al 15% de capacidad',
      'time': 'Ayer, 2:45 PM',
      'icon': Icons.battery_alert,
      'iconColor': Colors.orange,
      'selected': false,
    },
  ];

  Future<void> _sendAlerts() async {
    final selectedAlerts = _alerts.where((alert) => alert['selected'] == true).toList();
    
    if (selectedAlerts.isEmpty) {
      _showSnackBar('Selecciona al menos una alerta para enviar', Colors.orange);
      return;
    }

    setState(() => _isSending = true);

    try {
      await _sendSMS(selectedAlerts);
      await _sendEmail(selectedAlerts);
      _showSnackBar('Alertas enviadas con éxito', Colors.green);
    } catch (e) {
      _showSnackBar('Error al enviar alertas: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _sendEmail(List<Map<String, dynamic>> alerts) async {
    final subject = 'ALERTAS - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';
    final body = _buildEmailBody(alerts);
    
    // SOLUCIÓN FUNCIONAL PARA CORREO
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'jonathanv10022008@gmail.com',
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'No se pudo abrir el cliente de correo';
    }
  }

  String _buildEmailBody(List<Map<String, dynamic>> alerts) {
    final buffer = StringBuffer();
    buffer.writeln('ALERTAS DEL SISTEMA DE INVERNADERO');
    buffer.writeln('----------------------------------\n');
    
    for (var alert in alerts) {
      buffer.writeln('• ${alert['title']}:');
      buffer.writeln('  ${alert['description']}');
      buffer.writeln('  (${alert['time']})\n');
    }
    
    buffer.writeln('\nEste mensaje fue generado automáticamente.');
    return buffer.toString();
  }

  Future<void> _sendSMS(List<Map<String, dynamic>> alerts) async {
    // SOLUCIÓN FUNCIONAL PARA SMS
    final message = 'Alertas del invernadero:\n${alerts.map((a) => '• ${a['title']}').join('\n')}';
    
    // Formato alternativo que funciona en todos los dispositivos
    final smsUri = Uri.parse('sms:+593968127813?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw 'No se pudo abrir la app de mensajes';
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _toggleAllAlerts(bool? value) {
    setState(() {
      for (var alert in _alerts) {
        alert['selected'] = value ?? false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _alerts.where((alert) => alert['selected'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALERTAS'),
        backgroundColor: const Color(0xFF1D1E33),
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: _isSending ? null : _sendAlerts,
            tooltip: 'Enviar alertas automáticamente',
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildSelectionBar(selectedCount),
              Expanded(child: _buildAlertsList()),
              _buildSendButton(selectedCount),
            ],
          ),
          if (_isSending)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(int selectedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF252540),
      child: Row(
        children: [
          Checkbox(
            value: selectedCount == _alerts.length && _alerts.isNotEmpty,
            onChanged: _toggleAllAlerts,
            checkColor: Colors.white,
            activeColor: Colors.blue,
            tristate: true,
          ),
          const SizedBox(width: 10),
          Text(
            selectedCount > 0 
              ? '$selectedCount alerta${selectedCount > 1 ? 's' : ''} seleccionada${selectedCount > 1 ? 's' : ''}' 
              : 'Seleccionar alertas',
            style: const TextStyle(color: Colors.white70),
          ),
          const Spacer(),
          if (selectedCount > 0)
            TextButton(
              onPressed: () => setState(() {
                for (var alert in _alerts) {
                  alert['selected'] = false;
                }
              }),
              child: const Text(
                'DESELECCIONAR',
                style: TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Card(
      color: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => setState(() {
          alert['selected'] = !(alert['selected'] as bool);
        }),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: alert['selected'] as bool,
                    onChanged: (value) => setState(() {
                      alert['selected'] = value;
                    }),
                    checkColor: Colors.white,
                    activeColor: Colors.blue,
                  ),
                  Icon(alert['icon'] as IconData, color: alert['iconColor'] as Color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      alert['title'] as String,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['description'] as String,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert['time'] as String,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(int selectedCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: _isSending ? null : _sendAlerts,
        icon: const Icon(Icons.send),
        label: Text(
          _isSending 
            ? 'ENVIANDO...' 
            : 'ENVIAR ALERTAS${selectedCount > 0 ? ' ($selectedCount)' : ''}',
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedCount > 0 
              ? const Color(0xFF0D47A1)
              : Colors.blueGrey,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}