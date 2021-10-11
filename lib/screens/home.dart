import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minimal_music_player/constants.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  late AudioPlayer _player;
  double _cardheight = minCardHeight;

  int? currentIndex = 0;

  ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: audioSource);

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    _player = AudioPlayer();
    _init();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _player.stop();
    }
  }

  Future<void> _init() async {
    _player.sequenceStateStream.listen((event) {
      setState(() {
        currentIndex = event?.currentIndex;
      });
    });
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  double screenHeight() => MediaQuery.of(context).size.height;

  Widget _buildGradientBackground() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      decoration: BoxDecoration(
        gradient: background.evaluate(
          AlwaysStoppedAnimation(
            currentIndex! / audioSource.length,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard() {
    return Positioned(
        top: screenHeight() * .5,
        child: FractionalTranslation(
          translation: Offset(0, -.5),
          child: Stack(
            children: [
              Positioned(
                width: cardWidth,
                height: minCardHeight * .5,
                bottom: 0,
                child: DecoratedBox(
                    decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Color(0x1F4D6FDE),
                    blurRadius: 20,
                    offset: Offset(20, 20),
                  ),
                  BoxShadow(
                    color: Color(0x1F4D6FDE),
                    blurRadius: 20,
                    offset: Offset(-20, 20),
                  )
                ])),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: AnimatedContainer(
                  width: cardWidth,
                  height: _cardheight,
                  duration: Duration(
                    milliseconds: 300,
                  ),
                  curve: Curves.easeIn,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: background.evaluate(
                      AlwaysStoppedAnimation(
                          currentIndex! / audioSource.length),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildArtwork(String artwork) {
    return Container(
        width: artworkDi,
        height: artworkDi,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(artwork),
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x142196F3),
                offset: Offset(0, 40),
                blurRadius: 40,
              )
            ]));
  }

  Widget _buildTitle(String title) {}

  Widget _buildMetaData() {
    return StreamBuilder<SequenceState?>(
      stream: _player.sequenceStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;

        if (state?.sequence.isEmpty ?? true) return SizedBox();
        final metadata = state?.currentSource?.tag as AudioMetadata;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildArtwork(metadata.artwork),
            _buildTitle(metadata.title),
          ],
        );
      },
    ); //  StreamBuilder
  }

  Widget _buildPlayerContent() {
    double posY = screenHeight() / 2 - (minCardHeight / 2 + artworkDi / 2);
    return Positioned(
      top: posY,
      child: Column(
        children: [
          _buildMetaData(),
          SizedBox(height: defaultPadding * 2),
          MusicControls(player: _player)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        _buildGradientBackground(),
        _buildPlayerCard(),
        _buildPlayerContent(),
      ],
    ));
  }
}
