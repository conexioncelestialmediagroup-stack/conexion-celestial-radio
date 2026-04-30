import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conexión Celestial Radio',
      theme: ThemeData(primaryColor: Colors.blue),
      home: RadioPlayerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RadioPlayerScreen extends StatefulWidget {
  @override
  _RadioPlayerScreenState createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  final String streamUrl = "https://stream.caster.fm/radio/a2d5b34b-afec-42d5-b35b-2148c40e229d/stream";

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      try {
        await _audioPlayer.play(UrlSource(streamUrl));
        setState(() => _isPlaying = true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión"))
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radio, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "CONEXIÓN CELESTIAL RADIO",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              Text(
                "89.7 FM",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 50),
              GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
