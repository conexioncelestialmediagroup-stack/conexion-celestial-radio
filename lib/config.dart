import 'package:flutter/material.dart';

class RadioConfig {
  static const String streamUrl = "https://stream.caster.fm/radio/a2d5b34b-afec-42d5-b35b-2148c40e229d/stream";
  static const String lowDataStreamUrl = "https://stream.caster.fm/radio/a2d5b34b-afec-42d5-b35b-2148c40e229d/stream";
  
  static const String radioName = "CONEXIÓN CELESTIAL RADIO";
  static const String radioSlogan = "Conectando corazones al cielo";
  static const String fmFrequency = "89.7 FM";
  
  static const int primaryColor = 0xFF1E5F9E;
  
  static const int checkIntervalSeconds = 15;
  
  static final List<SocialButton> socialButtons = [
    SocialButton(name: "WhatsApp", icon: Icons.whatsapp, url: "https://wa.me/123456789", color: 0xFF25D366),
    SocialButton(name: "Facebook", icon: Icons.facebook, url: "https://facebook.com/tupagina", color: 0xFF1877F2),
    SocialButton(name: "Instagram", icon: Icons.instagram, url: "https://instagram.com/tucuenta", color: 0xFFE4405F),
    SocialButton(name: "YouTube", icon: Icons.play_circle_filled, url: "https://youtube.com/@tucanal", color: 0xFFFF0000),
  ];
}

class SocialButton {
  final String name;
  final IconData icon;
  final String url;
  final int color;
  SocialButton({required this.name, required this.icon, required this.url, required this.color});
}
