import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/BottomNavigation/AddVideo/VideoView.dart';
import 'package:qvid/BottomNavigation/AddVideo/my_trimmer.dart';
import 'package:qvid/BottomNavigation/Home/home_page.dart';

import 'package:qvid/Routes/routes.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:blinking_text/blinking_text.dart';

late List<CameraDescription> cameras;

class AddVideo extends StatefulWidget {
  final int duration;
  AddVideo(this.duration);
  @override
  _AddVideoState createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> with WidgetsBindingObserver {
  late CameraController _cameraController;
  Future<void>? cameraValue;

  bool isRecoring = false;
  bool isRecordingPause = false;
  bool flash = false;
  bool iscamerafront = true;
  String videoPath = '';
  Directory? videoRecordingPath;

  double transform = 0;

  void openCamera() async {
    cameras = await availableCameras();
  }

  void _showOverlayProgress(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return Center(child: CircularProgressIndicator());
    });

    overlayState!.insert(overlayEntry);

    await Future.delayed(Duration(seconds: 2));
    overlayEntry.remove();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    openCamera();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraValue = _cameraController.initialize();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _cameraController.initialize();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Stack(
              overflow: Overflow.clip,
              fit: StackFit.loose,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder(
                      future: cameraValue,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: _cameraController.value.isInitialized
                                  ? CameraPreview(_cameraController)
                                  : CircularProgressIndicator());
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
                Positioned(
                  child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 31,
                      )),
                  left: 25,
                  top: 40,
                ),
                Positioned(
                  child: IconButton(
                    icon: Transform.rotate(
                      angle: transform,
                      child: Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 31,
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        iscamerafront = !iscamerafront;
                        transform = transform + pi;
                      });
                      int cameraPos = iscamerafront ? 0 : 1;
                      _cameraController = CameraController(
                          cameras[cameraPos], ResolutionPreset.high);
                      cameraValue = _cameraController.initialize();
                    },
                  ),
                  right: 16,
                  top: 140,
                ),
                Positioned(
                    child: Text(
                      "Flip",
                      style: TextStyle(color: Colors.white),
                    ),
                    right: 23,
                    top: 183),
                Positioned(
                  child: InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.tag_faces,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),
                  right: 25,
                  top: 203,
                ),
                Positioned(
                    child: Text(
                      "Beautify",
                      style: TextStyle(color: Colors.white),
                    ),
                    right: 17,
                    top: 233),
                Positioned(
                  child: IconButton(
                      icon: Icon(
                        flash ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          flash = !flash;
                        });
                        flash
                            ? _cameraController.setFlashMode(FlashMode.torch)
                            : _cameraController.setFlashMode(FlashMode.off);
                      }),
                  right: 19,
                  top: 253,
                ),
                Positioned(
                    child: Text(
                      "Flash",
                      style: TextStyle(color: Colors.white),
                    ),
                    right: 23,
                    top: 287),
                Positioned(
                  child: isRecoring == true
                      ? InkWell(
                          onTap: () async {
                            if (isRecordingPause == false) {
                              await _cameraController.pauseVideoRecording();

                              setState(() {
                                isRecordingPause = true;
                              });
                            } else {
                              await _cameraController.resumeVideoRecording();

                              setState(() {
                                isRecordingPause = false;
                              });
                            }
                          },
                          child: isRecordingPause == true
                              ? Icon(
                                  Icons.play_circle,
                                  color: Colors.white,
                                  size: 42,
                                )
                              : Icon(
                                  Icons.pause_circle,
                                  color: Colors.white,
                                  size: 42,
                                ),
                        )
                      : InkWell(
                          onTap: () => _openGallery(),
                          child: Container(
                            height: 40,
                            width: 40,
                            // decoration: BoxDecoration(color: Colors.white),
                            child: Image.asset(
                              "assets/icons/gallery.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                  left: MediaQuery.of(context).size.width -
                      MediaQuery.of(context).size.width / 1.2,
                  top: MediaQuery.of(context).size.height - 100,
                ),
                Positioned(
                    child: Stack(
                      overflow: Overflow.visible,
                      fit: StackFit.loose,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _cameraController.startVideoRecording();
                            setState(() {
                              isRecoring = true;
                            });
                            Timer(Duration(seconds: widget.duration), () async {
                              print(
                                  "Yeah, this line is printed after ${widget.duration} seconds");

                              XFile videoFilePath =
                                  await _cameraController.stopVideoRecording();

                              File filePath = File(videoFilePath.path);
                              setState(() {
                                isRecoring = false;
                              });
                              _showOverlayProgress(context);
                              FutureProgressDialog(
                                  Future.delayed(Duration(seconds: 2), () {
                                print('Important');
                                print(videoFilePath.path);
                                print(filePath);
                                print('Important');
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => VideoViewPage(
                                              path: videoFilePath.path,
                                              fileView: filePath,
                                            )));
                              }));
                            });
                          },
                          child: isRecoring == true
                              ? GestureDetector(
                                  onTap: () async {
                                    XFile videoFilePath =
                                        await _cameraController
                                            .stopVideoRecording();

                                    File filePath = File(videoFilePath.path);
                                    setState(() {
                                      isRecoring = false;
                                    });
                                    _showOverlayProgress(context);
                                    FutureProgressDialog(Future.delayed(
                                        Duration(seconds: 2), () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) =>
                                                  VideoViewPage(
                                                    path: videoFilePath.path,
                                                    fileView: filePath,
                                                  )));
                                    }));
                                  },
                                  child: Icon(
                                    Icons.radio_button_on,
                                    color: Colors.red,
                                    size: 80,
                                  ),
                                )
                              : Icon(
                                  Icons.fiber_manual_record_rounded,
                                  color: Colors.yellow,
                                  size: 80,
                                ),
                        ),
                      ],
                    ),
                    left: MediaQuery.of(context).size.width -
                        MediaQuery.of(context).size.width / 1.7,
                    top: MediaQuery.of(context).size.height - 110),
                Positioned(
                  child: isRecoring == true
                      ? isRecordingPause
                          ? BlinkText(
                              'Paused',
                              style: TextStyle(
                                  fontSize: 24.0, color: Colors.redAccent),
                              endColor: Colors.orange,
                            )
                          : BlinkText(
                              'REC',
                              style: TextStyle(
                                  fontSize: 24.0, color: Colors.redAccent),
                              endColor: Colors.orange,
                            )
                      : InkWell(
                          onTap: () => Navigator.pushNamed(
                              context, PageRoutes.choose_music),
                          child: Container(
                            height: 40,
                            width: 40,
                            child: Image.asset('assets/icons/music_icon.png'),
                          ),
                        ),
                  right: MediaQuery.of(context).size.width -
                      MediaQuery.of(context).size.width / 1.15,
                  top: MediaQuery.of(context).size.height - 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _openGallery() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowCompression: true);
    File? file;

    if (result != null) {
      file = File(result.files.single.path!);
    }

    //trim video by video trimmer

    if (file != null) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => TrimmerView(file!, 1)));
    }
  }

  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    return true;
  }
}

// DUET _ PAGE

class DuetPage extends StatefulWidget {
  final int durationofVideo;
  final VideoPlayerController? duetPlayer;
  final String? videoName;
  DuetPage(
      {Key? key,
      @required this.duetPlayer,
      @required this.videoName,
      required this.durationofVideo})
      : super(key: key);

  @override
  State<DuetPage> createState() => _DuetPageState();
}

class _DuetPageState extends State<DuetPage> with WidgetsBindingObserver {
  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    return true;
  }

  CameraController? _cameraController;
  Future<void>? cameraValue;

  bool isRecoring = false;
  bool isRecordingPause = false;
  bool flash = false;
  bool iscamerafront = true;
  String videoPath = '';
  Directory? videoRecordingPath;
  bool isVideoPaused = false;
  String? duetVideoFileName;
  double transform = 0;
  void openCamera() async {
    cameras = await availableCameras();
  }

  void _showOverlayProgress(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return Center(child: CircularProgressIndicator());
    });

    overlayState!.insert(overlayEntry);

    await Future.delayed(Duration(seconds: 15));
    overlayEntry.remove();
  }

  void _showPause(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return Center(
          child: Icon(
        Icons.pause_circle,
        color: Colors.white,
      ));
    });

    overlayState!.insert(overlayEntry);

    await Future.delayed(Duration(milliseconds: 300));
    overlayEntry.remove();
  }

  void _showPlay(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return Center(
          child: Icon(
        Icons.play_circle,
        color: Colors.white,
      ));
    });

    overlayState!.insert(overlayEntry);

    await Future.delayed(Duration(milliseconds: 300));
    overlayEntry.remove();
  }

  String duetfilePath = '';
  Directory? dir;
  Future<String> getFilePath(uniqueFileName) async {
    String path = '';

    dir = await getApplicationDocumentsDirectory();

    path = '${dir!.path}/$uniqueFileName.mp4';

    return path;
  }

  void downloadDuetVideo() async {
    try {
      dir = await getApplicationDocumentsDirectory();

      duetfilePath = await getFilePath(DateTime.now().microsecond.toString());

      await Dio().download(
          'http://emergenceinfotech.in/ClapNew/API/v1/Uploads/Video/' +
              widget.videoName!,
          duetfilePath, onReceiveProgress: (rec, total) async {
        if (total == rec) {
          print('Downloaded');
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    openCamera();

    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraValue = _cameraController!.initialize();
    downloadDuetVideo();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _cameraController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        body: Stack(
          overflow: Overflow.clip,
          children: [
            Positioned(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              left: 25,
              top: 40,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (widget.duetPlayer!.value.isPlaying == true) {
                        setState(() {
                          widget.duetPlayer!.pause();
                          _showPause(context);
                          isVideoPaused = true;
                        });
                      } else {
                        setState(() {
                          widget.duetPlayer!.play();
                          _showPlay(context);
                          isVideoPaused = false;
                        });
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 2.3,
                      child: VideoPlayer(widget.duetPlayer!),
                    ),
                  ),
                  FutureBuilder(
                      future: cameraValue,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: MediaQuery.of(context).size.height / 2.3,
                              child: CameraPreview(_cameraController!));
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ],
              ),
            ),
            Positioned(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _cameraController!.startVideoRecording();
                        setState(() {
                          isRecoring = true;
                        });
                        Timer(Duration(seconds: widget.durationofVideo),
                            () async {
                          XFile videoFilePath =
                              await _cameraController!.stopVideoRecording();

                          File filePath = File(videoFilePath.path);

                          print(filePath);
                          print('Recorded Path');
                          setState(() {
                            isRecoring = false;
                          });
                          _showOverlayProgress(context);
                          Directory? newDirectory =
                              await getApplicationDocumentsDirectory();
                          String video1name =
                              '${newDirectory.path}/${widget.videoName}';
                          String video2name =
                              '${newDirectory.path}/${DateTime.now().microsecond}.mp4';
                          String outputVidep =
                              '${newDirectory.path}/${DateTime.now().millisecond}.mp4';
                          String scalevideo1 =
                              "-i $duetfilePath -vf scale=320:240  $video1name";
                          String scalevideo2 =
                              "-i ${videoFilePath.path} -vf scale=320:240  $video2name";

                          String a =
                              '-i $video1name -i $video2name -filter_complex "[0:v][1:v]hstack=inputs=2[v]; [0:a][1:a]amerge[a]" -map "[v]" -vsync 2 -map "[a]" -ac 2 $outputVidep';

                          File file1 = File(outputVidep);
                          FlutterFFmpeg().execute(scalevideo1).then((value) {
                            if (value == 0) {
                              print("Success at stage 1");
                              FlutterFFmpeg()
                                  .execute(scalevideo2)
                                  .then((value) => {
                                        if (value == 0)
                                          {
                                            print('Success at stage 2'),
                                            FlutterFFmpeg()
                                                .execute(a)
                                                .then((value) => {
                                                      if (value == 0)
                                                        {
                                                          print("Successfull"),
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          VideoViewPage(
                                                                            path:
                                                                                outputVidep,
                                                                            fileView:
                                                                                file1,
                                                                          )))
                                                        }
                                                      else
                                                        {
                                                          CircularProgressIndicator(),
                                                          print(
                                                              "Not Successfull")
                                                        }
                                                    })
                                          }
                                        else
                                          {CircularProgressIndicator()}
                                      });
                              print("I m here !! Success");
                            } else {
                              return CircularProgressIndicator();
                            }
                          });
                        });
                      },
                      child: isRecoring == true
                          ? GestureDetector(
                              onTap: () async {
                                XFile videoFilePath = await _cameraController!
                                    .stopVideoRecording();

                                File filePath = File(videoFilePath.path);

                                print(filePath);
                                print('Recorded Path');
                                setState(() {
                                  isRecoring = false;
                                });
                                _showOverlayProgress(context);
                                Directory? newDirectory =
                                    await getApplicationDocumentsDirectory();
                                String video1name =
                                    '${newDirectory.path}/${widget.videoName}';
                                String video2name =
                                    '${newDirectory.path}/${DateTime.now().microsecond}.mp4';
                                String outputVidep =
                                    '${newDirectory.path}/${DateTime.now().millisecond}.mp4';
                                String scalevideo1 =
                                    "-i $duetfilePath -vf scale=320:240  $video1name";
                                String scalevideo2 =
                                    "-i ${videoFilePath.path} -vf scale=320:240  $video2name";

                                String a =
                                    '-i $video1name -i $video2name -filter_complex "[0:v][1:v]hstack=inputs=2[v]; [0:a][1:a]amerge[a]" -map "[v]" -vsync 2 -map "[a]" -ac 2 $outputVidep';

                                File file1 = File(outputVidep);
                                FlutterFFmpeg()
                                    .execute(scalevideo1)
                                    .then((value) {
                                  if (value == 0) {
                                    print("Success at stage 1");
                                    FlutterFFmpeg()
                                        .execute(scalevideo2)
                                        .then((value) => {
                                              if (value == 0)
                                                {
                                                  print('Success at stage 2'),
                                                  FlutterFFmpeg()
                                                      .execute(a)
                                                      .then((value) => {
                                                            if (value == 0)
                                                              {
                                                                print(
                                                                    "Successfull"),
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            VideoViewPage(
                                                                              path: outputVidep,
                                                                              fileView: file1,
                                                                            )))
                                                              }
                                                            else
                                                              {
                                                                CircularProgressIndicator(),
                                                                print(
                                                                    "Not Successfull")
                                                              }
                                                          })
                                                }
                                              else
                                                {CircularProgressIndicator()}
                                            });
                                    print("I m here !! Success");
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                });
                              },
                              child: Icon(
                                Icons.radio_button_on,
                                color: Colors.red,
                                size: 80,
                              ),
                            )
                          : Icon(
                              Icons.fiber_manual_record_rounded,
                              color: Colors.yellow,
                              size: 80,
                            ),
                    ),
                  ],
                ),
                left: MediaQuery.of(context).size.width - 245,
                top: MediaQuery.of(context).size.height - 110),
            Positioned(
              child: isRecoring == true
                  ? isRecordingPause
                      ? BlinkText(
                          'Paused',
                          style: TextStyle(
                              fontSize: 24.0, color: Colors.redAccent),
                          endColor: Colors.orange,
                        )
                      : BlinkText(
                          'REC',
                          style: TextStyle(
                              fontSize: 24.0, color: Colors.redAccent),
                          endColor: Colors.orange,
                        )
                  : InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, PageRoutes.choose_music),
                      child: Container(
                        height: 40,
                        width: 40,
                        child: Image.asset('assets/icons/music_icon.png'),
                      ),
                    ),
              right: MediaQuery.of(context).size.width -
                  MediaQuery.of(context).size.width / 1.15,
              top: MediaQuery.of(context).size.height - 100,
            ),
            Positioned(
              child: IconButton(
                icon: Transform.rotate(
                  angle: transform,
                  child: Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    iscamerafront = !iscamerafront;
                    transform = transform + pi;
                  });
                  int cameraPos = iscamerafront ? 0 : 1;
                  _cameraController = CameraController(
                      cameras[cameraPos], ResolutionPreset.high);
                  cameraValue = _cameraController!.initialize();
                },
              ),
              right: 18,
              top: 40,
            ),
            Positioned(
                child: Text(
                  "Flip",
                  style: TextStyle(color: Colors.white),
                ),
                right: 28,
                top: 75),
            Positioned(
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (ctxt) => Container(
                            height: MediaQuery.of(context).size.height / 3,
                            color: Colors.black,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Choose Recording Speed',
                                    style: TextStyle(color: Colors.white)),
                                SizedBox(height: 20),
                                InkWell(
                                  onTap: () {
                                    // setState(() {
                                    //   // controller!
                                    //   //     .setFlashMode(FlashMode.always);
                                    // });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '0.5x',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    // setState(() {
                                    //   controller!
                                    //       .setFlashMode(FlashMode.off);
                                    // });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '1x',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    // setState(() {
                                    //   controller!
                                    //       .setFlashMode(FlashMode.auto);
                                    // });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '2x',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ));
                },
                child: Icon(
                  Icons.speed,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              right: 25,
              top: 100,
            ),
            Positioned(
                child: Text(
                  "Speed",
                  style: TextStyle(color: Colors.white),
                ),
                right: 23,
                top: 130),
            Positioned(
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (ctxt) => Container(
                            color: Colors.black,
                            height: MediaQuery.of(context).size.height / 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Choose Video Duration',
                                    style: TextStyle(color: Colors.white)),
                                SizedBox(height: 20),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      // videoLength = 15.00;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '15s',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      // videoLength = 29.00;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '29s',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      // videoLength = 60.0;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '1m',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ));
                },
                child: Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              right: 25,
              top: 155,
            ),
            Positioned(
                child: Text(
                  "Timer",
                  style: TextStyle(color: Colors.white),
                ),
                right: 23,
                top: 183),
            Positioned(
              child: InkWell(
                onTap: () {},
                child: Icon(
                  Icons.tag_faces,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              right: 25,
              top: 203,
            ),
            Positioned(
                child: Text(
                  "Beautify",
                  style: TextStyle(color: Colors.white),
                ),
                right: 17,
                top: 233),
            Positioned(
              child: IconButton(
                  icon: Icon(
                    flash ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      flash = !flash;
                    });
                    flash
                        ? _cameraController!.setFlashMode(FlashMode.torch)
                        : _cameraController!.setFlashMode(FlashMode.off);
                  }),
              right: 19,
              top: 253,
            ),
            Positioned(
                child: Text(
                  "Flash",
                  style: TextStyle(color: Colors.white),
                ),
                right: 23,
                top: 287),
            Positioned(
              child: isRecoring == true
                  ? InkWell(
                      onTap: () async {
                        if (isRecordingPause == false) {
                          await _cameraController!.pauseVideoRecording();

                          setState(() {
                            isRecordingPause = true;
                          });
                        } else {
                          await _cameraController!.resumeVideoRecording();

                          setState(() {
                            isRecordingPause = false;
                          });
                        }
                      },
                      child: isRecordingPause == true
                          ? Icon(
                              Icons.play_circle,
                              color: Colors.white,
                              size: 42,
                            )
                          : Icon(
                              Icons.pause_circle,
                              color: Colors.white,
                              size: 42,
                            ),
                    )
                  : SizedBox(),
              left: MediaQuery.of(context).size.width - 350,
              top: MediaQuery.of(context).size.height - 100,
            ),
          ],
        ),
      ),
    );
  }
}
