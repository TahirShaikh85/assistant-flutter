import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:url_launcher/url_launcher.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String greeting = '';
  String temperature = 'Loading...';
  String wind = '';
  String date = '';
  String city = '';
  String currentSong = 'None';
  bool isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Map<String, String>> songs = [
    {
      'title': 'SoundHelix Song 1',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    },
    {
      'title': 'SoundHelix Song 2',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    },
    {
      'title': 'SoundHelix Song 3',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    },
  ];

  int currentSongIndex = -1;

  @override
  void initState() {
    super.initState();
    setGreeting();
    fetchWeather();
    setupAudioSession();
  }

  Future<void> setupAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = "Good Morning!";
    } else if (hour < 16) {
      greeting = "Good Afternoon!";
    } else if (hour < 21) {
      greeting = "Good Evening!";
    } else {
      greeting = "Good Night!";
    }
  }

  Future<void> fetchWeather() async {
    final apiKey = dotenv.env['WEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print("❌ Missing WEATHER_API_KEY in .env");
      return;
    }

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          temperature = "Location permission denied.";
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = position.latitude;
      final lon = position.longitude;

      final url = Uri.parse(
        "https://api.weatherbit.io/v2.0/current?lat=$lat&lon=$lon&key=$apiKey",
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final rawDateTime = data['data'][0]['datetime']; // "2024-07-03:14:36"
        final utcDateTime = DateTime.now().toLocal();
        final formattedTime = DateFormat('h:mm a').format(utcDateTime);
        //  final localTime = DateTime.now().toLocal();

        setState(() {
          temperature = "${data['data'][0]['temp']}°C";
          wind = data['data'][0]['weather']['description'];
          city = data['data'][0]['city_name'];
          date = formattedTime;
        });
      } else {
        setState(() {
          temperature = "Failed to fetch weather.";
          wind = "";
          city = "";
          date = "";
        });
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        temperature = "Error fetching weather.";
      });
    }
  }

  Future<void> _playRandomSong() async {
    final random = Random();
    final index = random.nextInt(songs.length);
    await _playSongAt(index);
  }

  Future<void> _playSongAt(int index) async {
    try {
      final song = songs[index];
      await _audioPlayer.setUrl(song['url']!);
      await _audioPlayer.play();

      setState(() {
        currentSong = song['title']!;
        currentSongIndex = index;
        isPlaying = true;
      });
    } catch (e) {
      print("❌ Error playing song: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error playing song.")));
    }
  }

  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  Future<void> _resumeSong() async {
    await _audioPlayer.play();
    setState(() => isPlaying = true);
  }

  Future<void> _stopSong() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      currentSong = 'None';
      currentSongIndex = -1;
    });
  }

  Future<void> _playNextSong() async {
    final nextIndex = (currentSongIndex + 1) % songs.length;
    await _playSongAt(nextIndex);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _openWhatsApp() async {
  final Uri uri = Uri.parse("whatsapp://send?text=Hi");

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    print("❌ WhatsApp not installed or can't be opened.");
  }
}



  Future<void> _tellJoke() async {
    try {
      final response = await http.get(
        Uri.parse("https://official-joke-api.appspot.com/random_joke"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final setup = data['setup'];
        final punchline = data['punchline'];

        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("😂 Here's a Joke"),
                content: Text("$setup\n\n$punchline"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("LOL"),
                  ),
                ],
              ),
        );
      } else {
        throw Exception("Failed to fetch joke.");
      }
    } catch (e) {
      print("❌ Joke Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't fetch a joke. Try again.")),
      );
    }
  }

  void _callSomeone() async {
    final Uri telUri = Uri(scheme: 'tel', path: '');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Couldn't open phone dialer")),
      );
    }
  }

  void _readSMS() async {
    final Uri smsUri = Uri(scheme: 'sms');
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Couldn't open messaging app")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.white,
  body: Column(
    children: [
      Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 20),
      Image.asset(
        'assets/actionbar.png',
        height: 90,
        width: 180,
      ),
    ],
  ),
),

        
      Expanded( // Makes ListView scrollable in remaining space
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          child: ListView(
            children: [
              Text(
                greeting,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text("NOW | $date", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              Card(
                color: Colors.blue,
                elevation: 10,
                child: ListTile(
                  leading: const Icon(
                    Icons.cloud,
                    color: Colors.white,
                  ),
                  title: Text(
                    "$temperature • $city",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    wind,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text("Try it out", style: TextStyle(fontSize: 24)),
              Wrap(
                spacing: 10,
                children: [
                  ActionChip(
                    label: const Text("Open whatsapp"),
                    onPressed: _openWhatsApp,
                  ),
                  ActionChip(
                    label: const Text("Play song"),
                    onPressed: _playRandomSong,
                  ),
                  ActionChip(
                    label: const Text("Tell a joke"),
                    onPressed: _tellJoke,
                  ),
                  ActionChip(
                    label: const Text("Call someone"),
                    onPressed: _callSomeone,
                  ),
                  ActionChip(
                    label: const Text("Read my SMS"),
                    onPressed: _readSMS,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (currentSong != 'None') ...[
                Text(
                  "🎵 Now Playing: $currentSong",
                  style: const TextStyle(fontSize: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      iconSize: 32,
                      onPressed: isPlaying ? _pauseSong : _resumeSong,
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      iconSize: 32,
                      onPressed: _stopSong,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 32,
                      onPressed: _playNextSong,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ],
  ),
);
  }
}