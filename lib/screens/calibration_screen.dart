import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../app_theme.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  
  // Valores de calibración (0-100)
  double _humedad = 70.0;
  double _temperatura = 25.0;
  double _luz = 60.0;
  double _phSuelo = 6.5;
  double _co2 = 400.0;

  @override
  void initState() {
    super.initState();
    _loadCalibrationValues();
  }

  Future<void> _loadCalibrationValues() async {
    try {
      await Firebase.initializeApp();
      DocumentSnapshot doc = await _firestore.collection('calibration').doc('current_values').get();
      
      if (doc.exists) {
        setState(() {
          _humedad = doc['humedad']?.toDouble() ?? 70.0;
          _temperatura = doc['temperatura']?.toDouble() ?? 25.0;
          _luz = doc['luz']?.toDouble() ?? 60.0;
          _phSuelo = doc['phSuelo']?.toDouble() ?? 6.5;
          _co2 = doc['co2']?.toDouble() ?? 400.0;
          _isLoading = false;
        });
      } else {
        await _saveCalibrationValues();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading calibration: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCalibrationValues() async {
    await _firestore.collection('calibration').doc('current_values').set({
      'humedad': _humedad,
      'temperatura': _temperatura,
      'luz': _luz,
      'phSuelo': _phSuelo,
      'co2': _co2,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _guardarConfiguracion() async {
    try {
      setState(() => _isLoading = true);
      await _saveCalibrationValues();
      
      // Registrar el cambio en el log
      await _firestore.collection('logs').add({
        'title': 'Calibración actualizada',
        'description': 'Valores de calibración modificados',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'calibration',
        'details': {
          'humedad': _humedad,
          'temperatura': _temperatura,
          'luz': _luz,
          'phSuelo': _phSuelo,
          'co2': _co2,
        }
      });
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          title: const Text('Configuración Guardada', style: TextStyle(color: Colors.white)),
          content: Text(
            'Nuevos valores:\n'
            'Humedad: ${_humedad.toStringAsFixed(0)}%\n'
            'Temperatura: ${_temperatura.toStringAsFixed(1)}°C\n'
            'Luz: ${_luz.toStringAsFixed(0)}%\n'
            'pH: ${_phSuelo.toStringAsFixed(1)}\n'
            'CO₂: ${_co2.toStringAsFixed(0)}ppm',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('No se pudo guardar: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('CALIBRACIÓN INVERNADERO'),
          backgroundColor: const Color(0xFF1D1E33),
        ),
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CALIBRACIÓN INVERNADERO'),
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
            _buildCalibrationSlider(
              title: 'Humedad',
              value: _humedad,
              unit: '%',
              min: 0,
              max: 100,
              onChanged: (value) => setState(() => _humedad = value),
            ),
            _buildCalibrationSlider(
              title: 'Temperatura',
              value: _temperatura,
              unit: '°C',
              min: 10,
              max: 40,
              divisions: 30,
              onChanged: (value) => setState(() => _temperatura = value),
            ),
            _buildCalibrationSlider(
              title: 'Intensidad Lumínica',
              value: _luz,
              unit: '%',
              min: 0,
              max: 100,
              onChanged: (value) => setState(() => _luz = value),
            ),
            _buildCalibrationSlider(
              title: 'pH del Suelo',
              value: _phSuelo,
              unit: 'pH',
              min: 4,
              max: 9,
              divisions: 50,
              onChanged: (value) => setState(() => _phSuelo = value),
            ),
            _buildCalibrationSlider(
              title: 'Nivel de CO₂',
              value: _co2,
              unit: 'ppm',
              min: 300,
              max: 2000,
              divisions: 170,
              onChanged: (value) => setState(() => _co2 = value),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _guardarConfiguracion,
              icon: const Icon(Icons.save),
              label: const Text('GUARDAR CONFIGURACIÓN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationSlider({
    required String title,
    required double value,
    required String unit,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(unit == 'pH' || unit == '°C' ? 1 : 0)}$unit',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[200],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blueAccent,
                inactiveTrackColor: Colors.blueGrey[800],
                thumbColor: Colors.blue,
                overlayColor: Colors.blue.withOpacity(0.2),
                valueIndicatorColor: Colors.blueAccent,
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                label: '${value.toStringAsFixed(divisions != null ? 1 : 0)}$unit',
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}