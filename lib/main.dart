import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'config.dart';
import 'stream_detector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StreamDetector.initializeNotifications();
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.conexioncelestial.radio.channel',
    androidNotificationChannelName: RadioConfig.radioName,
    androidNotificationOngoing: true,
    notificationTitle: RadioConfig.radioName,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: RadioConfig.radioName,
      theme: ThemeData(primaryColor: Color(RadioConfig.primaryColor)),
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
  bool _lowDataMode = false;
  bool _isStreamingLive = false;
  String _connectivityStatus = "Verificando...";
  
  String get _streamUrl => _lowDataMode ? RadioConfig.lowDataStreamUrl : RadioConfig.streamUrl;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkConnectivity();
    StreamDetector.startDetecting();
    _checkLiveStatus();
  }
  
  Future<void> _checkLiveStatus() async {
    final isLive = await StreamDetector.isStreamAlive();
    setState(() {
      _isStreamingLive = isLive;
    });
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _lowDataMode = prefs.getBool('lowDataMode') ?? false);
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lowDataMode', _lowDataMode);
  }

  Future<void> _checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    setState(() {
      if (result == ConnectivityResult.mobile) {
        _connectivityStatus = "📱 Datos móviles - Activa modo ahorro";
        if (!_lowDataMode && _isPlaying) _showDataWarning();
      } else if (result == ConnectivityResult.wifi) {
        _connectivityStatus = "📶 WiFi - Calidad óptima";
      } else {
        _connectivityStatus = "❌ Sin conexión";
      }
    });
  }

  void _showDataWarning() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("💡 Ahorra tus datos"),
      content: Text("Estás usando datos móviles. ¿Activar modo bajo consumo?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(_), child: Text("No")),
        ElevatedButton(onPressed: () {
          setState(() => _lowDataMode = true);
          _saveSettings();
          if (_isPlaying) _restartPlayback();
          Navigator.pop(_);
        }, child: Text("Activar")),
      ],
    ));
  }

  Future<void> _restartPlayback() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(_streamUrl)));
      await _audioPlayer.play();
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      try {
        await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(_streamUrl)));
        await _audioPlayer.play();
        setState(() => _isPlaying = true);
        await _checkConnectivity();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión. ¿Están al aire?"))
        );
      }
    }
  }

  void _toggleLowDataMode() async {
    setState(() => _lowDataMode = !_lowDataMode);
    await _saveSettings();
    if (_isPlaying) await _restartPlayback();
  }

  void _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    StreamDetector.stopDetecting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(RadioConfig.primaryColor), Colors.white],
        )),
        child: SafeArea(
          child: Column(children: [
            SizedBox(height: 20),
            if (_isStreamingLive)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    SizedBox(width: 8),
                    Text("EN VIVO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            SizedBox(height: 10),
            CircleAvatar(radius: 60, backgroundColor: Colors.white, child: Icon(Icons.radio, size: 70, color: Color(RadioConfig.primaryColor))),
            SizedBox(height: 20),
            Text(RadioConfig.radioName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(RadioConfig.radioSlogan, style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70)),
            SizedBox(height: 10),
            Container(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text("🎵 ${RadioConfig.fmFrequency}", style: TextStyle(fontWeight: FontWeight.bold, color: Color(RadioConfig.primaryColor)))),
            SizedBox(height: 40),
            GestureDetector(onTap: _togglePlayback, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 50, color: Color(RadioConfig.primaryColor)))),
            SizedBox(height: 30),
            if (_isPlaying) Padding(padding: EdgeInsets.symmetric(horizontal: 30), child: Column(children: [Text("🎙️ Transmitiendo en vivo", style: TextStyle(color: Colors.white70)), LinearProgressIndicator(color: Colors.white)])),
            SizedBox(height: 20),
            Container(margin: EdgeInsets.symmetric(horizontal: 20), padding: EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("🌙 Modo ahorro", style: TextStyle(fontWeight: FontWeight.bold)), Text(_lowDataMode ? "Económico" : "Normal", style: TextStyle(fontSize: 12)), Text(_connectivityStatus, style: TextStyle(fontSize: 11, color: Colors.blue))]),
              Switch(value: _lowDataMode, onChanged: (_) => _toggleLowDataMode(), activeColor: Color(RadioConfig.primaryColor)),
            ])),
            SizedBox(height: 20),
            Text("SÍGUENOS", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            Wrap(spacing: 20, runSpacing: 15, children: RadioConfig.socialButtons.map((s) => GestureDetector(onTap: () => _openUrl(s.url), child: Column(children: [Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(s.icon, color: Color(s.color), size: 28)), Text(s.name, style: TextStyle(color: Colors.white70, fontSize: 11))]))).toList()),
            Spacer(),
            Text("📻 Conectando corazones al cielo", style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
