import 'dart:async';

import 'package:chat_app/Core/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as ap;

class AudioPlayer extends StatefulWidget {
  const AudioPlayer({
    required this.source,
    // required this.onDelete,
    Key? key,
  }) : super(key: key);

  /// Path from where to play recorded audio
  final ap.AudioSource source;

  /// Callback when audio file should be removed
  /// Setting this to null hides the delete button
  // final VoidCallback onDelete;

  @override
  AudioPlayerState createState() => AudioPlayerState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ap.AudioSource>('source', source));
    // properties.add(ObjectFlagProperty<VoidCallback>.has('onDelete', onDelete));
  }
}

class AudioPlayerState extends State<AudioPlayer> {
  // static const double _controlSize = 56;
  // static const double _deleteBtnSize = 24;

  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  late StreamSubscription<ap.PlayerState> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration?> _positionChangedSubscription;

  @override
  void initState() {
    _playerStateChangedSubscription =
        _audioPlayer.playerStateStream.listen((ap.PlayerState state) async {
      if (state.processingState == ap.ProcessingState.completed) {
        await stop();
      }
      setState(() {});
    });
    _positionChangedSubscription = _audioPlayer.positionStream
        .listen((Duration position) => setState(() {}));
    _durationChangedSubscription = _audioPlayer.durationStream
        .listen((Duration? duration) => setState(() {}));
    _init();

    super.initState();
  }

  Future<void> _init() async {
    try {
      await _audioPlayer.setAudioSource(widget.source);
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Duration position = _audioPlayer.position;
    final Duration? duration = _audioPlayer.duration;
    ThemeData applicationTheme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildControl(),
            Expanded(child: _buildSlider()),
            // IconButton(
            //   icon: const Icon(
            //     Icons.delete,
            //     color: Colors.white,
            //     size: _deleteBtnSize,
            //   ),
            //   onPressed: () {
            //     // ignore: always_specify_types
            //     _audioPlayer.stop().then((value) => widget.onDelete());
            //   },
            // ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Padding(
            // padding: EdgeInsets.only(
            //     right: MediaQuery.of(context).size.width * .3, left: 14),
            // child:
            Text(position.toString().split(".")[0],
                style: applicationTheme.textTheme.subtitle1),
            // ),
            if (duration != null)
              Text(duration.toString().split(".")[0],
                  style: applicationTheme.textTheme.subtitle1)
          ],
        ),
      ],
    );
  }

  Widget _buildControl() {
    Icon icon;
    Color color;

    if (_audioPlayer.playerState.playing) {
      final ThemeData theme = Theme.of(context);

      icon =
          Icon(Icons.pause, color: theme.textTheme.bodyText2!.color, size: 32);
      color = theme.textTheme.bodyText2!.color!.withOpacity(0.2);
    } else {
      final ThemeData theme = Theme.of(context);
      icon = Icon(Icons.play_arrow,
          color: theme.textTheme.bodyText2!.color, size: 32);
      color = theme.textTheme.bodyText2!.color!.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(child: icon),
          onTap: () async {
            if (_audioPlayer.playerState.playing) {
              await pause();
            } else {
              await play();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSlider() {
    final Duration position = _audioPlayer.position;
    final Duration? duration = _audioPlayer.duration;
    bool canSetValue = false;
    if (duration != null) {
      canSetValue = position.inMilliseconds > 0;
      canSetValue &= position.inMilliseconds < duration.inMilliseconds;
    }

    // double width = widgetWidth - _controlSize - _deleteBtnSize;
    // width -= _deleteBtnSize;

    return SliderTheme(
      data: const SliderThemeData(
        thumbColor: Colors.white,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
      ),
      child: Slider(
        activeColor: Theme.of(context).scaffoldBackgroundColor,
        inactiveColor: Theme.of(context).disabledColor,
        onChanged: (double v) {
          if (duration != null) {
            final double position = v * duration.inMilliseconds;
            _audioPlayer.seek(Duration(milliseconds: position.round()));
          }
        },
        value: canSetValue && duration != null
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0,
      ),
    );
  }

  Future<void> play() {
    return _audioPlayer.play();
  }

  Future<void> pause() {
    return _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    return _audioPlayer.seek(Duration.zero);
  }
}
