import 'package:assistant/assistantPage.dart';
import 'package:assistant/explorePage.dart';
import 'package:assistant/googleLensPage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Load environment variables from .env
  await dotenv.load(); 
  print("🔑 Loaded API Key: ${dotenv.env['GEMINI_API_KEY']}");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Assistant Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    checkMicPermission();
  }

  void checkMicPermission() async {
    if (await Permission.microphone.request().isGranted) {
      debugPrint("Microphone permission granted");
    } else {
      debugPrint("Microphone permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Top - Google Assistant icon and text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/hi.png',
                  height: 40,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Google Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100),

            // Middle - Logo and Message
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AssistantPage()),
                );
              },
              child: Column(
                children: [
                  Image.asset(
                    'assets/hi.png',
                    height: 130,
                  ),
                  const SizedBox(height: 10),
                  
                ],
              ),
            ),

            const Spacer(),

            // Bottom - 3 Icon Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Explore
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExplorePage()),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          child: Image.asset(
                            'assets/explore.png',
                            height: 30,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('Explore', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  // Assistant
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AssistantPage()),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          child: Image.asset(
                            'assets/mic.png',
                            height: 30,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('Assistant', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  // Google Lens
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GoogleLensPage()),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          child: Image.asset(
                            'assets/googlelens.png',
                            height: 30,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('Lens', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 