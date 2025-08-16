import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AudioProvider(),
      child: MaterialApp(
        title: 'Sons Relaxantes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _favorites = [];
  bool _isPlaying = false;
  double _volume = 0.5;
  String? _currentSoundId;

  List<String> get favorites => _favorites;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  String? get currentSoundId => _currentSoundId;

  final List<SoundModel> _sounds = [
    SoundModel(
      id: 'rain',
      title: 'Chuva',
      icon: Icons.grain,
      description: 'Som relaxante de chuva',
      assetPath: 'assets/sounds/chuva.ogg',
    ),
    SoundModel(
      id: 'ocean',
      title: 'Oceano',
      icon: Icons.waves,
      description: 'Ondas do oceano',
      assetPath: 'assets/sounds/oceano.ogg',
    ),
    SoundModel(
      id: 'forest',
      title: 'Floresta',
      icon: Icons.park,
      description: 'Sons da natureza',
      assetPath: 'assets/sounds/floresta.ogg',
    ),
    SoundModel(
      id: 'meditation',
      title: 'Meditação',
      icon: Icons.self_improvement,
      description: 'Música para meditação',
      assetPath: 'assets/sounds/meditacao.ogg',
    ),
  ];

  List<SoundModel> get sounds => _sounds;
  List<SoundModel> get favoriteSounds =>
      _sounds.where((sound) => _favorites.contains(sound.id)).toList();

  AudioProvider() {
    _loadFavorites();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favorites = prefs.getStringList('favorites') ?? [];
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favorites);
    } catch (e) {
      print('Erro ao salvar favoritos: $e');
    }
  }

  Future<void> playSound(SoundModel sound) async {
    try {
      if (_currentSoundId == sound.id && _isPlaying) {
        // Pausar som atual
        await _audioPlayer.pause();
        _isPlaying = false;
      } else if (_currentSoundId == sound.id && !_isPlaying) {
        // Retomar som pausado
        await _audioPlayer.resume();
        _isPlaying = true;
      } else {
        // Tocar novo som (usa o arquivo específico do SoundModel)
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(sound.assetPath));
        await _audioPlayer.setVolume(_volume);
        _isPlaying = true;
        _currentSoundId = sound.id;
      }
      notifyListeners();
    } catch (e) {
      print('Erro ao reproduzir som: $e');
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentSoundId = null;
      notifyListeners();
    } catch (e) {
      print('Erro ao parar som: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume;
      await _audioPlayer.setVolume(volume);
      notifyListeners();
    } catch (e) {
      print('Erro ao ajustar volume: $e');
    }
  }

  Future<void> toggleFavorite(String soundId) async {
    if (_favorites.contains(soundId)) {
      _favorites.remove(soundId);
    } else {
      _favorites.add(soundId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String soundId) {
    return _favorites.contains(soundId);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class SoundModel {
  final String id;
  final String title;
  final IconData icon;
  final String description;
  final String assetPath;

  SoundModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.assetPath,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Sons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sons Relaxantes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          return Column(
            children: [
              // Controle de Volume
              Card(
                elevation: 3,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Volume',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(audioProvider.volume * 100).round()}%',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.volume_down, color: Colors.grey[600]),
                          Expanded(
                            child: Slider(
                              value: audioProvider.volume,
                              onChanged: (value) =>
                                  audioProvider.setVolume(value),
                              min: 0.0,
                              max: 1.0,
                              divisions: 20,
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                              inactiveColor: Colors.grey[300],
                            ),
                          ),
                          Icon(Icons.volume_up, color: Colors.grey[600]),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Player Atual
              if (audioProvider.currentSoundId != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          audioProvider.sounds
                              .firstWhere(
                                  (s) => s.id == audioProvider.currentSoundId)
                              .icon,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tocando agora',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              audioProvider.sounds
                                  .firstWhere((s) =>
                                      s.id == audioProvider.currentSoundId)
                                  .title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => audioProvider.stopSound(),
                        icon: const Icon(Icons.stop, size: 28),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Lista de Sons
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: audioProvider.sounds.length,
                  itemBuilder: (context, index) {
                    final sound = audioProvider.sounds[index];
                    final isCurrentlyPlaying =
                        audioProvider.currentSoundId == sound.id &&
                            audioProvider.isPlaying;
                    final isFavorite = audioProvider.isFavorite(sound.id);

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Icon(
                            sound.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          sound.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          sound.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  audioProvider.toggleFavorite(sound.id),
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton.small(
                              heroTag: sound.id,
                              onPressed: () => audioProvider.playSound(sound),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Icon(
                                isCurrentlyPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Favoritos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          final favoriteSounds = audioProvider.favoriteSounds;

          if (favoriteSounds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum som favorito ainda',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione sons aos favoritos na tela inicial',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: favoriteSounds.length,
            itemBuilder: (context, index) {
              final sound = favoriteSounds[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      sound.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    sound.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    sound.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => audioProvider.toggleFavorite(sound.id),
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        heroTag: '${sound.id}_fav',
                        onPressed: () => audioProvider.playSound(sound),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
