import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Pa' Firestore y FieldValue
import 'firebase_options.dart'; 
import 'app_theme.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _createSampleData(); // Primero crea los datos, luego corre la app
  runApp(MyApp());
}

Future<void> _createSampleData() async {
  final firestore = FirebaseFirestore.instance;
  
  // 1. Configuración de CALIBRACIÓN (documento FIJO)
  final calibrationRef = firestore.collection('calibration').doc('current_values');
  if (!(await calibrationRef.get()).exists) {
    await calibrationRef.set({
      'humedad': 70.0,
      'temperatura': 25.0,
      'luz': 60.0,
      'phSuelo': 6.5,
      'co2': 400.0,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  // 2. Estado de SISTEMAS (documento FIJO)
  final systemsRef = firestore.collection('systems').doc('current_state');
  if (!(await systemsRef.get()).exists) {
    await systemsRef.set({
      'irrigation': false,
      'leds': false,
      'buzzer': false,
      'ventilation': false,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  // 3. LOG de ejemplo (documento con Auto-ID)
  await firestore.collection('logs').add({
    'title': 'Sistema iniciado',
    'description': 'App cargada correctamente',
    'timestamp': FieldValue.serverTimestamp(),
    'type': 'system_start',
  });

  // 4. ALERTA de ejemplo (documento con Auto-ID)
  await firestore.collection('alerts').add({
    'title': 'Temperatura crítica',
    'description': 'La temperatura superó los 40°C',
    'timestamp': FieldValue.serverTimestamp(),
    'icon': 'warning',
    'color': 'red',
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invernadero Inteligente',
      theme: AppTheme.darkTheme,
      home: HomeScreen(), 
      debugShowCheckedModeBanner: false, // Pa' quitar el banner de debug
    );
  }
}