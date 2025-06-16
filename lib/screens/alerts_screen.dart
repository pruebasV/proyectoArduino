import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';

class Alert {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  bool selected;

  Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    this.selected = false,
  });

  // Formatear la fecha para mostrar
  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (timestamp.isAfter(today)) {
      return 'Hoy, ${DateFormat('h:mm a').format(timestamp)}';
    } else if (timestamp.isAfter(yesterday)) {
      return 'Ayer, ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      return DateFormat('dd/MM/yyyy, h:mm a').format(timestamp);
    }
  }
}

class AlertService {
  static Future<void> sendSMS(List<Alert> alerts, String phoneNumber) async {
    final message = 'Alertas del invernadero:\n${alerts.map((a) => '• ${a.title}').join('\n')}';
    final smsUri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw 'No se pudo abrir la app de mensajes';
    }
  }

  static Future<void> sendEmail(List<Alert> alerts, String email) async {
    final subject = 'ALERTAS - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';
    final body = _buildEmailBody(alerts);
    
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'No se pudo abrir el cliente de correo';
    }
  }

  static String _buildEmailBody(List<Alert> alerts) {
    final buffer = StringBuffer();
    buffer.writeln('ALERTAS DEL SISTEMA DE INVERNADERO');
    buffer.writeln('----------------------------------\n');
    
    for (var alert in alerts) {
      buffer.writeln('• ${alert.title}:');
      buffer.writeln('  ${alert.description}');
      buffer.writeln('  (${alert.formattedTime})\n');
    }
    
    buffer.writeln('\nEste mensaje fue generado automáticamente.');
    return buffer.toString();
  }
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Alert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      await Firebase.initializeApp();
      
      _firestore.collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          setState(() {
            _alerts = snapshot.docs.map((doc) {
              final data = doc.data();
              return Alert(
                id: doc.id,
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                icon: _parseIcon(data['icon']),
                iconColor: _parseColor(data['color']),
                selected: false,
              );
            }).toList();
            _isLoading = false;
          });
        });
    } catch (e) {
      print('Error loading alerts: $e');
      setState(() => _isLoading = false);
    }
  }

  IconData _parseIcon(String? icon) {
    switch (icon) {
      case 'warning': return Icons.warning;
      case 'security': return Icons.security;
      case 'water': return Icons.water_damage;
      case 'battery': return Icons.battery_alert;
      default: return Icons.notification_important;
    }
  }

  Color _parseColor(String? color) {
    switch (color) {
      case 'amber': return Colors.amber;
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'orange': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Future<void> _sendAlerts() async {
    final selectedAlerts = _alerts.where((alert) => alert.selected).toList();
    
    if (selectedAlerts.isEmpty) {
      _showSnackBar('Selecciona al menos una alerta para enviar', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AlertService.sendSMS(selectedAlerts, '+593968127813');
      await AlertService.sendEmail(selectedAlerts, 'jonathanv10022008@gmail.com');
      _showSnackBar('Alertas enviadas con éxito', Colors.green);
    } catch (e) {
      _showSnackBar('Error al enviar alertas: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleAllAlerts(bool? value) {
    setState(() {
      for (var alert in _alerts) {
        alert.selected = value ?? false;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ALERTAS'),
          backgroundColor: const Color(0xFF1D1E33),
        ),
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final selectedCount = _alerts.where((alert) => alert.selected).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALERTAS'),
        backgroundColor: const Color(0xFF1D1E33),
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: _isLoading ? null : _sendAlerts,
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
              _SelectionBar(
                selectedCount: selectedCount,
                totalAlerts: _alerts.length,
                onToggleAll: _toggleAllAlerts,
                onDeselectAll: () {
                  setState(() {
                    for (var alert in _alerts) {
                      alert.selected = false;
                    }
                  });
                },
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    return _AlertCard(
                      alert: _alerts[index],
                      onTap: () {
                        setState(() {
                          _alerts[index].selected = !_alerts[index].selected;
                        });
                      },
                    );
                  },
                ),
              ),
              _SendButton(
                selectedCount: selectedCount,
                isSending: _isLoading,
                onPressed: _sendAlerts,
              ),
            ],
          ),
          if (_isLoading)
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
}

// Widgets independientes y reutilizables
class _SelectionBar extends StatelessWidget {
  final int selectedCount;
  final int totalAlerts;
  final Function(bool?) onToggleAll;
  final VoidCallback onDeselectAll;

  const _SelectionBar({
    required this.selectedCount,
    required this.totalAlerts,
    required this.onToggleAll,
    required this.onDeselectAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF252540),
      child: Row(
        children: [
          Checkbox(
            value: selectedCount == totalAlerts && totalAlerts > 0,
            onChanged: onToggleAll,
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
              onPressed: onDeselectAll,
              child: const Text(
                'DESELECCIONAR',
                style: TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;

  const _AlertCard({
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: alert.selected,
                    onChanged: (_) => onTap(),
                    checkColor: Colors.white,
                    activeColor: Colors.blue,
                  ),
                  Icon(alert.icon, color: alert.iconColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      alert.title,
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
                      alert.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.formattedTime,
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
}

class _SendButton extends StatelessWidget {
  final int selectedCount;
  final bool isSending;
  final VoidCallback onPressed;

  const _SendButton({
    required this.selectedCount,
    required this.isSending,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: isSending ? null : onPressed,
        icon: const Icon(Icons.send),
        label: Text(
          isSending 
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