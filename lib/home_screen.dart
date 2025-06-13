import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/menu_button.dart';
import 'screens/remote_opening_screen.dart';
import 'screens/activity_log_screen.dart';
import 'screens/manual_cover_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/calibration_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CONTROL DE INVERNADERO',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1D1E33),
        elevation: 0,
      ),
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            MenuButton(
              iconAsset: 'remote_control', // Nombre del SVG sin extensión
              title: 'APERTURA REMOTA',
              onPressed: () => _navigateTo(
                context, 
                const RemoteOpeningScreen(),
              ),
            ),
            MenuButton(
              iconAsset: 'history',
              title: 'REGISTRO DE ACTIVIDAD',
              onPressed: () => _navigateTo(
                context, 
                const ActivityLogScreen(),
              ),
            ),
            MenuButton(
              iconAsset: 'cover',
              title: 'APERTURA MANUAL',
              onPressed: () => _navigateTo(
                context, 
                const ManualCoverScreen(),
              ),
            ),
            MenuButton(
              iconAsset: 'alert',
              title: 'ALERTAS',
              onPressed: () => _navigateTo(
                context, 
                const AlertsScreen(),
              ),
            ),
            MenuButton(
              iconAsset: 'tune',
              title: 'CALIBRACION',
              onPressed: () => _navigateTo(
                context, 
                const CalibrationScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}