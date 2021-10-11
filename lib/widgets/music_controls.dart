import 'package:flutter/material.dart';

class MusicControls extends StatefulWidget {
  const MusicControls({Key? key, this.player}) : super(key: key);

  final AudioPlayer? player;

  @override
  _MusicControlsState createState() => _MusicControlsState();
}

class _MusicControlsState extends State<MusicControls> {
  late AudioPlayer _player;

  @override
  void initState() {
    _player = widget.player;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
