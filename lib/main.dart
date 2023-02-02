import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(VideoDemo());

class VideoDemo extends StatefulWidget {
  @override
  VideoDemoState createState() => VideoDemoState();
}

class VideoDemoState extends State<VideoDemo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.network(
        "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4");
    _initializeVideoPlayerFuture = _controller.initialize();
    // _controller.setLooping(true);
    _controller.setVolume(1.0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Video Demo"),
        ),
        body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Stack(children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  Positioned(
                      bottom: 0,
                      width: MediaQuery.of(context).size.width,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                            backgroundColor: Colors.black,
                            bufferedColor: Colors.blueGrey,
                            playedColor: Colors.white),
                      )),
                  Positioned(
                      left: 0,
                      bottom: 0,
                      child: ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: _controller,
                          builder: (_, listenedValue, a) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                //TODO fix the time portion
                                "${listenedValue.position.inSeconds.toString().padLeft(2, '0')}/"
                                "${_controller.value.duration.inSeconds.toString()}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }))
                ]),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ),
    );
  }
}
