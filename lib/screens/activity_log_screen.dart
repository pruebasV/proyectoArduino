import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      await Firebase.initializeApp();
      
      _firestore.collection('logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          setState(() {
            _logs = snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'title': data['title'] ?? '',
                'description': data['description'] ?? '',
                'timestamp': _formatTimestamp(data['timestamp'] as Timestamp),
                'icon': _parseIcon(data['type']),
              };
            }).toList();
            _isLoading = false;
          });
        });
    } catch (e) {
      print('Error loading logs: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date.isAfter(today)) {
      return 'Hoy, ${DateFormat('h:mm a').format(date)}';
    } else if (date.isAfter(yesterday)) {
      return 'Ayer, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy, h:mm a').format(date);
    }
  }

  IconData _parseIcon(String? type) {
    switch (type) {
      case 'system_change': return Icons.settings;
      case 'calibration': return Icons.tune;
      case 'alert': return Icons.warning;
      case 'maintenance': return Icons.build;
      case 'system_start': return Icons.power;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
        child: ListView.builder(
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final log = _logs[index];
            return _buildLogEntry(
              log['title'] as String,
              log['timestamp'] as String,
              log['icon'] as IconData,
            );
          },
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