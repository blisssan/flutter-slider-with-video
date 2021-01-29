import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SliderPage(),
    );
  }
}

class SliderPage extends StatefulWidget {
  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  int _currentPage = 0;
  List<String> _paths = [
    'assets/media/image1.jpg',
    'assets/media/image2.jpg',
    'assets/media/video.mp4',
  ];

  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    _pageController.addListener(() {});
    _initiateNextPage();
    super.initState();
  }

  _initiateNextPage() async {
    if (_getExtensionByPath(_paths[_currentPage]) != 'mp4') {
      var _duration = new Duration(seconds: 5);
      return Timer(_duration, _moveToNextPage);
    }
  }

  _moveToNextPage() async {
    _currentPage++;
    _currentPage = _currentPage >= _paths.length ? 0 : _currentPage;
    _pageController.jumpToPage(_currentPage);
  }

  _getExtensionByPath(String path) {
    return path.substring(path.lastIndexOf('.') + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: PageView.builder(
          onPageChanged: (pageIndex) {
            print('Pg index - $pageIndex');
            _initiateNextPage();
          },
          controller: _pageController,
          itemCount: _paths.length,
          itemBuilder: (context, position) {
            String mediaPath = _paths[position];
            String extension = _getExtensionByPath(mediaPath);
            return Container(
              color: position % 2 == 0 ? Colors.pink : Colors.cyan,
              child: extension == 'mp4'
                  ? VideoSlider(
                      path: mediaPath,
                      onVideoEnd: _moveToNextPage,
                    )
                  : Image.asset(mediaPath),
            );
          },
        ),
      ),
    );
  }
}

class VideoSlider extends StatefulWidget {
  final String path;
  final Function onVideoEnd;

  VideoSlider({@required this.path, this.onVideoEnd});

  @override
  _VideoSliderState createState() => _VideoSliderState();
}

class _VideoSliderState extends State<VideoSlider> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;

  @override
  void initState() {
    _initializeVideoController(widget.path);
    super.initState();
  }

  @override
  void dispose() {
    if (videoPlayerController != null) videoPlayerController.dispose();
    if (chewieController != null) chewieController.dispose();
    super.dispose();
  }

  _initializeVideoController(String videoPath) {
    videoPlayerController = VideoPlayerController.asset(videoPath);
    // important to set looping to false
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: false,
    );
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.position.inSeconds ==
          videoPlayerController.value.duration.inSeconds) {
        widget.onVideoEnd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: chewieController);
  }
}
