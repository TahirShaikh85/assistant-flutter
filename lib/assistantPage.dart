// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _text = 'Press the mic and start speaking...';
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeAssistant();
  }

  Future<void> _initializeAssistant() async {
    await Permission.microphone.request();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    print("✅ Assistant initialized");
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('🟢 Speech status: $status'),
      onError: (error) => print('❌ Speech error: $error'),
    );

    if (available && !_isListening) {
      await _flutterTts.stop();
      setState(() {
        _isListening = true;
        _text = '';
      });

      _speech.listen(
        listenMode: stt.ListenMode.confirmation,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        onResult: (val) async {
          if (val.finalResult && val.recognizedWords.isNotEmpty) {
            final userInput = val.recognizedWords;
            setState(() {
              _text = userInput;
              _isListening = false;
            });

            final botReply = await _generateReply(userInput);
            _addMessage("You: $userInput", "Assistant: $botReply");

            await _flutterTts.setLanguage("en-US");
            await _flutterTts.setPitch(1.0);
            await _flutterTts.speak(botReply);

            setState(() {
              _text = 'Press the mic and start speaking...';
            });
          }
        },
      );
    }
  }

  Future<String> _generateReply(String input) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return "Gemini API key missing. Please check your .env file.";
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
    try {
      final content = [Content.text(input)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        return response.text!.trim();
      } else {
        return "No response from Gemini.";
      }
    } catch (e) {
      print('❌ Gemini Error: $e');
      return "Error occurred while getting response.";
    }
  }

  void _addMessage(String user, String bot) {
    setState(() {
      _messages.add({'human': user, 'assistant': bot});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(msg['human'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 5),
                      Text(msg['assistant'] ?? '',
                          style: const TextStyle(color: Colors.black87)),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _text,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _startListening,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: _isListening ? Colors.red : Colors.blue,
              child: const Icon(Icons.mic, size: 30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
