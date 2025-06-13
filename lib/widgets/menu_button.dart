import 'package:flutter/material.dart';
import 'svg_icon.dart'; // Importa el nuevo widget
import '../app_theme.dart';

class MenuButton extends StatelessWidget {
  final String iconAsset; // Cambiamos a nombre de asset
  final String title;
  final VoidCallback onPressed;

  const MenuButton({
    super.key,
    required this.iconAsset, // Ahora recibe el nombre del SVG
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[900]!.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppTheme.menuGradient,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SvgIcon(assetName: iconAsset), // Usamos nuestro widget SVG
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Icon(Icons.chevron_right, size: 32, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}