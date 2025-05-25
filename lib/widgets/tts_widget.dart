import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../theme/colors.dart';

class TTSWidget extends StatefulWidget {
  final String text;

  const TTSWidget({super.key, required this.text});

  @override
  _TTSWidgetState createState() => _TTSWidgetState();
}

class _TTSWidgetState extends State<TTSWidget> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;

  // Preprocess the text for TTS
  String preprocessForTTS(String text) {
    final lines = text.split('\n');
    final buffer = StringBuffer();

    for (var line in lines) {
      String l = line.trim();
      if (l.isEmpty) {
        buffer.write('. '); // Add a pause for blank lines
        continue;
      }
      // Headings: "# Heading" -> "Heading."
      l = l.replaceAllMapped(RegExp(r'^#+\s*(.*)'), (m) => '${m[1]}.');
      // Remove bold/italic markdown
      l = l.replaceAll(RegExp(r'\*\*|\*|__|_'), '');
      // List items: "* item" or "- item" -> "• item."
      l = l.replaceAllMapped(RegExp(r'^[\*\-]\s*'), (m) => 'Next ingredient: ');
      // Ensure each line ends with a period for a pause
      if (!l.endsWith('.') && !l.endsWith('!') && !l.endsWith('?')) {
        l = '$l.';
      }
      buffer.write('$l ');
    }
    return buffer.toString();
  }

  // Speak the provided text
  Future<void> _speakText() async {
    if (widget.text.isNotEmpty) {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);

      final ttsText = preprocessForTTS(widget.text);

      if (_isPaused) {
        // Resume TTS if paused
        await _flutterTts.speak(ttsText);
      } else {
        // Start TTS from the beginning
        await _flutterTts.speak(ttsText);
      }

      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  // Pause the TTS
  Future<void> _pauseText() async {
    await _flutterTts.pause();
    setState(() {
      _isPlaying = false;
      _isPaused = true;
    });
  }

  // Stop the TTS
  Future<void> _stopText() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  // Stop the TTS when the widget is disposed
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: primarySwatch[100],
      foregroundColor: Colors.white,
      icon: _isPlaying ? Icons.pause : Icons.volume_up,
      activeIcon: Icons.close,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.play_arrow, color: Colors.white),
          backgroundColor: primarySwatch[200],
          label: 'Play',
          onTap: _speakText,
        ),
        SpeedDialChild(
          child: const Icon(Icons.pause, color: Colors.white),
          backgroundColor: primarySwatch[300],
          label: 'Pause',
          onTap: _pauseText,
        ),
        SpeedDialChild(
          child: const Icon(Icons.stop, color: Colors.white),
          backgroundColor: primarySwatch[400],
          label: 'Stop',
          onTap: _stopText,
        ),
      ],
    );
  }
}
