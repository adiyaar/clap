import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qvid/BottomNavigation/AddVideo/post_info.dart';
import 'package:qvid/widget/toast.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
class VideoEditor extends StatefulWidget {
  VideoEditor({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor>
    with SingleTickerProviderStateMixin {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;
  TabController? _tabController;
  File? coverImage;
  File? exportedVideo;

  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: Duration(seconds: 30))
      ..initialize().then((_) => setState(() {}));
    _tabController = new TabController(vsync: this, length: 2);

    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    _tabController!.dispose();
    super.dispose();
  }

  void _openCropScreen() => Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => CropScreen(controller: _controller)));

  void _exportVideo() async {
    _isExporting.value = true;
    bool _firstStat = true;

    await _controller.exportVideo(
      // preset: VideoExportPreset.medium,
      // customInstruction: "-crf 17",
      onProgress: (statics) {
        // First statistics is always wrong so if first one skip it
        if (_firstStat) {
          _firstStat = false;
        } else {
          _exportingProgress.value = statics.getTime() /
              _controller.video.value.duration.inMilliseconds;
        }
      },
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;
        if (file != null) {
          // _tabController!.animateTo(1);

          MyToast(message: "Please Select Your Cover to move Ahead").toast;

          print(file);
          setState(() {
            exportedVideo = file;
          });
          print(exportedVideo);

          // final VideoPlayerController _videoController =
          //     VideoPlayerController.file(exportedVideo);
          // _videoController.initialize().then((value) async {
          //   setState(() {});
          //   _videoController.play();
          //   _videoController.setLooping(true);
          //   await showModalBottomSheet(
          //     context: context,
          //     backgroundColor: Colors.black54,
          //     builder: (_) => AspectRatio(
          //       aspectRatio: _videoController.value.aspectRatio,
          //       child: VideoPlayer(_videoController),
          //     ),
          //   );
          //   await _videoController.pause();
          //   _videoController.dispose();
          // });
          // _exportText = "Video success export!";
        } else {
          _exportText = "Error on export video :(";
        }

        setState(() => _exported = true);
        Misc.delayed(2000, () => setState(() => _exported = false));
      },
    );
  }

  void _exportCover() async {
    setState(() => _exported = false);
    await _controller.extractCover(
      onCompleted: (coverImage) {
        if (!mounted) return;

        if (coverImage != null) {
          _exportText = "Cover exported! ${coverImage.path}";

          print(_exportText);
          print(exportedVideo);
          // showModalBottomSheet(
          //   context: context,
          //   backgroundColor: Colors.black54,
          //   builder: (BuildContext context) =>
          //       Image.memory(coverImage.readAsBytesSync()),
          // );

          if (exportedVideo != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PostInfo(
                          videoFilePath: exportedVideo!.path,
                          coverFilePath: coverImage,
                        )));
          }
        } else
          _exportText = "Error on cover exportation :(";

        setState(() => _exported = true);
        Misc.delayed(2000, () => setState(() => _exported = false));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.initialized
          ? SafeArea(
              child: Stack(children: [
              Column(children: [
                _topNavBar(),
                Expanded(
                    child: DefaultTabController(
                        length: 2,
                        child: Column(children: [
                          Expanded(
                              child: TabBarView(
                            controller: _tabController,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Stack(alignment: Alignment.center, children: [
                                CropGridViewer(
                                  controller: _controller,
                                  showGrid: false,
                                ),
                                AnimatedBuilder(
                                  animation: _controller.video,
                                  builder: (_, __) => OpacityTransition(
                                    visible: !_controller.isPlaying,
                                    child: GestureDetector(
                                      onTap: _controller.video.play,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.play_arrow,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                              CoverViewer(controller: _controller)
                            ],
                          )),
                          Container(
                              height: 200,
                              margin: Margin.top(10),
                              child: Column(children: [
                                TabBar(
                                  indicatorColor: Colors.white,
                                  tabs: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: Margin.all(5),
                                              child: Icon(Icons.content_cut)),
                                          Text('Trim')
                                        ]),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: Margin.all(5),
                                              child: Icon(Icons.video_label)),
                                          Text('Cover')
                                        ]),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      Container(
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: _trimSlider())),
                                      Container(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _coverSelection(),
                                              SizedBox(height: 20),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.0),
                                                color: Colors.blue,
                                                child: TextButton(
                                                  onPressed: _exportCover,
                                                  child: Text(
                                                      'Save Your Cover Image',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              )
                                            ]),
                                      ),
                                    ],
                                  ),
                                )
                              ])),
                          _customSnackBar(),
                          ValueListenableBuilder(
                            valueListenable: _isExporting,
                            builder: (_, bool export, __) => OpacityTransition(
                              visible: export,
                              child: AlertDialog(
                                backgroundColor: Colors.white,
                                title: ValueListenableBuilder(
                                  valueListenable: _exportingProgress,
                                  builder: (_, double value, __) =>
                                      TextDesigned(
                                    "Exporting video ${(value * 100).ceil()}%",
                                    color: Colors.black,
                                    bold: true,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ])))
              ])
            ]))
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: Container(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.goBack(),
                child: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.rotate90Degrees(RotateDirection.left),
                child: Icon(Icons.rotate_left, color: Colors.white),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.rotate90Degrees(RotateDirection.right),
                child: Icon(Icons.rotate_right, color: Colors.white),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _openCropScreen,
                child: Icon(Icons.crop, color: Colors.white),
              ),
            ),
            // Expanded(
            //   child: GestureDetector(
            //     onTap: _exportCover,
            //     child: Icon(Icons.save_alt, color: Colors.white),
            //   ),
            // ),
            // Expanded(
            //   child: GestureDetector(
            //     onTap: _exportVideo,
            //     child: Icon(Icons.save, color: Colors.white),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: Margin.horizontal(height / 4),
            child: Row(children: [
              TextDesigned(formatter(Duration(seconds: pos.toInt()))),
              Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  TextDesigned(formatter(Duration(seconds: start.toInt()))),
                  SizedBox(width: 10),
                  TextDesigned(formatter(Duration(seconds: end.toInt()))),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: Margin.vertical(height / 15),
        child: TrimSlider(
            child: TrimTimeline(
                controller: _controller, margin: EdgeInsets.only(top: 10)),
            controller: _controller,
            height: height,
            horizontalMargin: height / 4),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        color: Colors.blue,
        child: TextButton(
          onPressed: _exportVideo,
          child: Text('Save Your Trimmed Video',
              style: TextStyle(color: Colors.white)),
        ),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: Margin.horizontal(height / 4),
        child: CoverSelection(
          controller: _controller,
          height: height,
          nbSelection: 8,
        ));
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        // direction: SwipeDirection.fromBottom,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: TextDesigned(
              _exportText,
              bold: true,
            ),
          ),
        ),
      ),
    );
  }
}

//-----------------//
//CROP VIDEO SCREEN//
//-----------------//
class CropScreen extends StatelessWidget {
  CropScreen({Key? key, required this.controller}) : super(key: key);

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: Margin.all(30),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.rotate90Degrees(RotateDirection.left),
                  child: Icon(Icons.rotate_left, color: Colors.white),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      controller.rotate90Degrees(RotateDirection.right),
                  child: Icon(Icons.rotate_right, color: Colors.white),
                ),
              )
            ]),
            SizedBox(height: 15),
            Expanded(
              child: AnimatedInteractiveViewer(
                maxScale: 2.4,
                child: CropGridViewer(
                    controller: controller, horizontalMargin: 60),
              ),
            ),
            SizedBox(height: 15),
            Row(children: [
              Expanded(
                child: SplashTap(
                  onTap: context.goBack,
                  child: Center(
                    child: TextDesigned(
                      "CANCEL",
                      bold: true,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              buildSplashTap("16:9", 16 / 9, padding: Margin.horizontal(10)),
              buildSplashTap("1:1", 1 / 1),
              buildSplashTap("4:5", 4 / 5, padding: Margin.horizontal(10)),
              buildSplashTap("NO", null, padding: Margin.right(10)),
              Expanded(
                child: SplashTap(
                  onTap: () {
                    //2 WAYS TO UPDATE CROP
                    //WAY 1:
                    controller.updateCrop();
                    /*WAY 2:
                    controller.minCrop = controller.cacheMinCrop;
                    controller.maxCrop = controller.cacheMaxCrop;
                    */
                    context.goBack();
                  },
                  child: Center(
                    child: TextDesigned(
                      "DONE",
                      bold: true,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget buildSplashTap(
    String title,
    double? aspectRatio, {
    EdgeInsetsGeometry? padding,
  }) {
    return SplashTap(
      onTap: () => controller.preferredCropAspectRatio = aspectRatio,
      child: Padding(
        padding: padding ?? Margin.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.aspect_ratio, color: Colors.white),
            TextDesigned(
              title,
              bold: true,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
