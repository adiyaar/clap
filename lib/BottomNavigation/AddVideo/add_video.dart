import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/BottomNavigation/AddVideo/VideoView.dart';
//import 'package:progress_dialog/progress_dialog.dart';
import 'package:qvid/BottomNavigation/AddVideo/add_video_filter.dart';
import 'package:qvid/BottomNavigation/AddVideo/my_trimmer.dart';
import 'package:qvid/BottomNavigation/Home/home_page.dart';

import 'package:qvid/Routes/routes.dart';
import 'package:qvid/widget/toast.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

List<CameraDescription>? cameras;

class AddVideo extends StatefulWidget {
  @override
  _AddVideoState createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> with WidgetsBindingObserver {
  CameraController? _cameraController;
  Future<void>? cameraValue;

  bool isRecoring = false;
  bool isRecordingPause = false;
  bool flash = false;
  bool iscamerafront = true;
  String videoPath = '';
  Directory? videoRecordingPath;

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

    await Future.delayed(Duration(seconds: 5));
    overlayEntry.remove();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    openCamera();
    _cameraController = CameraController(cameras![0], ResolutionPreset.high);
    cameraValue = _cameraController!.initialize();

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
      if (_cameraController != null) {
        // openCamera(selectedCamera);
      }
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
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Stack(
              overflow: Overflow.clip,
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
                              child: CameraPreview(_cameraController!));
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
                  child: InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),
                  right: 25,
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
                  left: MediaQuery.of(context).size.width - 350,
                  top: MediaQuery.of(context).size.height - 100,
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
                          },
                          child: isRecoring == true
                              ? GestureDetector(
                                  onTap: () async {
                                    XFile videoFilePath =
                                        await _cameraController!
                                            .stopVideoRecording();

                                    File filePath = File(videoFilePath.path);
                                    setState(() {
                                      isRecoring = false;
                                    });
                                    _showOverlayProgress(context);
                                    Future.delayed(Duration(seconds: 5), () {
                                      // Do something
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) =>
                                                  VideoViewPage(
                                                    path: videoFilePath.path,
                                                    fileView: filePath,
                                                  )));
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
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, PageRoutes.choose_music),
                    child: Container(
                      height: 40,
                      width: 40,
                      child: Image.asset('assets/icons/music_icon.png'),
                    ),
                  ),
                  right: MediaQuery.of(context).size.width - 350,
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
  final VideoPlayerController? duetPlayer;
  final String? videoName;
  DuetPage({Key? key, @required this.duetPlayer, @required this.videoName})
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

    _cameraController = CameraController(cameras![0], ResolutionPreset.high);
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

                                File fileupdated = File(newDirectory.path);

                                // Do something
                                // String b =
                                //     '-i new1.mp4 -i new2.mp4 -i new3.mp4 -i new4.mp4 -filter_complex \ "[0]setdar=16/9[a];[1]setdar=16/9[b];[2]setdar=16/9[c];[3]setdar=16/9[d]; \ [a][b][c][d]concat=n=4:v=1:a=1" output.mp4';

                                // String a =
                                //     '-i ${dir!.path}/videos.mp4 -i ${videoFilePath.path} -filter_complex "[0:v]scale=1024:576:force_original_aspect_ratio=1[v0]; [1:v]scale=1024:576:force_original_aspect_ratio=1[v1]; [v0][0:a][v1][1:a]concat=n=2:v=1:a=1[v][a]" -map [v] -map [a] ${newDirectory.path}/${DateTime.now().millisecond.toString()}.mp4';
                                // // String commandToExecute =
                                // // '-i ${dir!.path}/${widget.videoName} -i ${videoFilePath.path} -filter_complex \'[0:0][1:0]concat=n=2:v=1:a=0[out]\' -map \'[out]\' ${newDirectory.path}/output.mp4';

                                // FlutterFFmpeg().execute(a).then((value) {
                                //   print(value);
                                //   print("Value of the command");
                                //   value == 0
                                Future.delayed(Duration(seconds: 2), () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => VideoDuetView(
                                                pathDownloaded: duetfilePath,
                                                pathRecorded:
                                                    videoFilePath.path,
                                              )));
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
              child: InkWell(
                onTap: () {},
                child: Icon(
                  Icons.cameraswitch,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              right: 25,
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
