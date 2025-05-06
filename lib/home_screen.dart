import 'package:flutter/material.dart';
import 'utils/storage_helper.dart';
import 'game_screen.dart';
import 'splash_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int unlockedLevel = 1; // change this to 1 

  // Uncomment these
  
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProgress(); // Reload progress whenever dependencies change
  }

  void _loadProgress() async {
    int level = await StorageHelper.getUnlockedLevel();
    setState(() => unlockedLevel = level);
  }

  void _onLevelComplete(int level) async {
    if (level >= unlockedLevel) {
      await StorageHelper.saveUnlockedLevel(level + 1);
      StorageHelper.saveUnlockedLevel(level + 1);
      setState(() => unlockedLevel = level + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const cardSize = 80.0;
    const spacing = 12.0;
    final crossAxisCount = (screenWidth / (cardSize + spacing)).floor();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        title: const Text('Memory Card Game'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 74, 173, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(spacing),
        child: GridView.builder(
          itemCount: 50,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final level = index + 1;
            // final isUnlocked = level <= 40; // level <= unlockedLevel;
            // Uncomment the line below to use the unlocked level from StorageHelper
            final isUnlocked = level <= unlockedLevel;
            return GestureDetector(
              onTap: isUnlocked
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            level: level,
                            onLevelComplete: _onLevelComplete,
                          ),
                        ),
                      )
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.lightBlue : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Level $level',
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
