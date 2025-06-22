import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../utils/text_util.dart';
import '../theme/colors.dart';

class TTSWidget extends StatefulWidget {
  final String text;

  const TTSWidget({super.key, required this.text});

  @override
  TTSWidgetState createState() => TTSWidgetState();
}

class TTSWidgetState extends State<TTSWidget> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentLine = 0;
  List<String> _lines = [];

  /// Speaks the provided text using TTS.
  /// It preprocesses the text into lines if not already done.
  Future<void> _speakText() async {
    if (widget.text.isNotEmpty) {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);

      // Only preprocess if starting from the beginning
      if (_lines.isEmpty) {
        _lines = preprocessForTTS(widget.text);
      }

      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });

      for (; _currentLine < _lines.length; _currentLine++) {
        if (_isPaused) break;
        final line = _lines[_currentLine].trim();
        if (line.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 700));
          continue;
        }
        await _flutterTts.speak(line);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (!_isPaused) {
        setState(() {
          _isPlaying = false;
          _currentLine = 0;
          _lines = [];
        });
      }
    }
  }

  /// Pauses reading the text.
  /// This will stop the current speech and set the state to paused.
  Future<void> _pauseText() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = true;
    });
  }

  /// Stops reading the text.
  /// This will reset the state and clear the current line and lines.
  Future<void> _stopText() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _currentLine = 0;
      _lines = [];
    });
  }

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
          onTap: () {
            if (_isPaused) {
              _speakText(); // Resume from where paused
            } else {
              _currentLine = 0;
              _lines = [];
              _speakText();
            }
          },
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
