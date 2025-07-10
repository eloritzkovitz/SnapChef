import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../utils/text_util.dart';
import '../theme/colors.dart';

class TTSWidget extends StatefulWidget {
  final String text;

  const TTSWidget({super.key, required this.text});

  static final FlutterTts _flutterTts = FlutterTts();

  static Future<void> stop() async {
    await _flutterTts.stop();
  }

  @override
  TTSWidgetState createState() => TTSWidgetState();
}

class TTSWidgetState extends State<TTSWidget> {
  bool _isPlaying = false;
  int _currentLine = 0;
  List<String> _lines = [];

  /// Speaks the current line of text.
  /// If the text is empty, it preprocesses the text for TTS.
  Future<void> _speakCurrentLine() async {
    if (_lines.isEmpty) {
      _lines = preprocessForTTS(widget.text);
    }
    if (_currentLine >= 0 && _currentLine < _lines.length) {
      setState(() {
        _isPlaying = true;
      });
      final line = _lines[_currentLine].trim();
      if (line.isNotEmpty) {
        await TTSWidget._flutterTts.speak(line);
        await Future.delayed(const Duration(milliseconds: 300));
      }
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  /// Plays the text using TTS.
  /// If the text is empty, it preprocesses the text for TTS.
  Future<void> _play() async {
    await TTSWidget._flutterTts.stop();
    if (_lines.isEmpty) {
      _lines = preprocessForTTS(widget.text);
    }
    setState(() {
      _isPlaying = true;
    });
    await _speakCurrentLine();
  }

  /// Pauses the TTS playback. Upon resuming, it will continue from the last spoken line.
  Future<void> _pauseText() async {
    await TTSWidget._flutterTts.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  /// Stops the TTS playback and resets the state.
  Future<void> _stopText() async {
    await TTSWidget._flutterTts.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _currentLine = 0;
        _lines = [];
      });
    }
  }

  /// Navigates to the previous line of text.
  /// If already at the first line, does nothing.
  Future<void> _previousLine() async {
    if (_currentLine > 0) {
      await TTSWidget._flutterTts.stop();
      setState(() {
        _currentLine -= 1;
        _isPlaying = false;
      });
      await _speakCurrentLine();
    }
  }

  /// Navigates to the next line of text.
  /// If already at the last line, does nothing.
  Future<void> _nextLine() async {
    if (_currentLine < _lines.length - 1) {
      await TTSWidget._flutterTts.stop();
      setState(() {
        _currentLine += 1;
        _isPlaying = false;
      });
      await _speakCurrentLine();
    }
  }

  @override
  void dispose() {
    TTSWidget._flutterTts.stop();
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
          child: const Icon(Icons.skip_previous, color: Colors.white),
          backgroundColor:
              _currentLine > 0 ? primarySwatch[200] : Colors.grey.shade400,
          label: 'Previous',
          onTap: _currentLine > 0 ? _previousLine : null,
        ),
        SpeedDialChild(
          child: const Icon(Icons.skip_next, color: Colors.white),
          backgroundColor: _currentLine < _lines.length - 1
              ? primarySwatch[300]
              : Colors.grey.shade400,
          label: 'Next',
          onTap: _currentLine < _lines.length - 1 ? _nextLine : null,
        ),
        SpeedDialChild(
          child: const Icon(Icons.play_arrow, color: Colors.white),
          backgroundColor: primarySwatch[400],
          label: 'Play',
          onTap: _play,
        ),
        SpeedDialChild(
          child: const Icon(Icons.pause, color: Colors.white),
          backgroundColor: primarySwatch[500],
          label: 'Pause',
          onTap: _pauseText,
        ),
        SpeedDialChild(
          child: const Icon(Icons.stop, color: Colors.white),
          backgroundColor: primarySwatch[600],
          label: 'Stop',
          onTap: _stopText,
        ),
      ],
    );
  }
}
