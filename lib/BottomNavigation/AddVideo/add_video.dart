import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:progress_dialog/progress_dialog.dart';
import 'package:qvid/BottomNavigation/AddVideo/add_video_filter.dart';
import 'package:qvid/BottomNavigation/AddVideo/my_trimmer.dart';
import 'package:qvid/BottomNavigation/Home/home_page.dart';

import 'package:qvid/Routes/routes.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class AddVideo extends StatefulWidget {
  @override
  _AddVideoState createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> with WidgetsBindingObserver {
  late List<CameraDescription> cameras;
  CameraController? controller;
  var selectedCamera = 1;
  String? videoPath;
  double videoLength = 29.0;
  String audioFile =
      "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3";

  bool videoRecorded = false;
  bool isVideoRecorded = false;

  bool isUploading = false;

  bool cameraCrash = false;
  bool showProgress = false;

  double videoProgressPercent = 0;

  bool reverse = false;

  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;

  bool showLoader = false;

  bool isFlash = false;

  bool isDialog = false;

  File? songFile;

  late AssetsAudioPlayer assetsAudioPlayer;
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    openCamera(selectedCamera);
    //WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        openCamera(selectedCamera);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    controller!.dispose();
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
                  child: controller == null ||
                          controller!.value.isInitialized == false
                      ? Center(child: CircularProgressIndicator())
                      : CameraPreview(controller!),
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
                    onTap: () {
                      setState(() {
                        if (selectedCamera == 0) {
                          selectedCamera = 1;
                        } else {
                          selectedCamera = 0;
                        }
                        openCamera(selectedCamera);
                      });
                    },
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
                                          videoLength = 15.00;
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
                                          videoLength = 29.00;
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
                                          videoLength = 60.0;
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
                                    Text('Choose Flash Mode',
                                        style: TextStyle(color: Colors.white)),
                                    SizedBox(height: 20),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          controller!
                                              .setFlashMode(FlashMode.always);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'On',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          controller!
                                              .setFlashMode(FlashMode.off);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Off',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          controller!
                                              .setFlashMode(FlashMode.auto);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Auto',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                    },
                    child: Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),
                  right: 25,
                  top: 253,
                ),
                Positioned(
                    child: Text(
                      "Flash",
                      style: TextStyle(color: Colors.white),
                    ),
                    right: 23,
                    top: 282),
                Positioned(
                  child: InkWell(
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
                  child: Container(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(
                      color: Colors.red,
                      value: videoProgressPercent,
                    ),
                  ),
                  left: MediaQuery.of(context).size.width - 245,
                  top: MediaQuery.of(context).size.height - 110,
                ),
                Positioned(
                    child: Stack(
                      children: [
                        Icon(
                          Icons.fiber_manual_record_rounded,
                          color: Colors.yellow,
                          size: 80,
                        ),
                        Positioned(
                            top: 28,
                            left: 28,
                            child: Visibility(
                                visible: controller == null ? false : true,
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        controller!.value.isRecordingVideo ==
                                                true
                                            ? pauseVideoRecording()
                                            : resumeVideoRecording();
                                      });
                                    },
                                    child: controller!.value.isRecordingPaused
                                        ? Icon(Icons.play_arrow)
                                        : controller!.value.isRecordingVideo
                                            ? Icon(Icons.pause)
                                            : Icon(Icons.pause)))),
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
          // body: FadedSlideAnimation(
          //   Stack(
          //     children: <Widget>[
          //       controller == null
          //           ? Center(child: CircularProgressIndicator())
          //           : CameraPreview(controller!),
          //       AppBar(
          //         actions: [
          //           GestureDetector(
          //             onTap: () {
          //               setState(() {
          //                 if (selectedCamera == 0) {
          //                   selectedCamera = 1;
          //                 } else {
          //                   selectedCamera = 0;
          //                 }
          //                 openCamera(selectedCamera);
          //               });
          //             },
          //             child: Padding(
          //                 padding: const EdgeInsets.only(right: 20),
          //                 child: Image.asset(
          //                   "assets/icons/swap_camera.png",
          //                   width: 45,
          //                   height: 45,
          //                   color: Colors.white,
          //                 )),
          //           ),
          //         ],
          //       ),
          //       Positioned(
          //           top: 130,
          //           right: 17,
          //           child: InkWell(
          //             onTap: () {
          //               print("sdsd");
          //             },
          //             child: Card(
          //                 color: backgroundColor,
          //                 shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(20)),
          //                 child: Container(
          //                   width: 40,
          //                   height: 40,
          //                   alignment: Alignment.center,
          //                   child: Text("30sec",
          //                       style: TextStyle(
          //                           color: Colors.black,
          //                           fontSize: 10,
          //                           fontWeight: FontWeight.bold)),
          //                 )),
          //           )),
          //       Positioned(
          //           top: 200,
          //           right: 20,
          //           child: CircleAvatar(
          //             backgroundImage: AssetImage("assets/user/user1.png"),
          //             radius: 20,
          //           )),
          //       isDialog == true
          //           ? Align(
          //               alignment: Alignment.center,
          //               child: CustomeLoader.customLoader,
          //             )
          //           : Container(),
          //       SizedBox(
          //         height: 10,
          //       ),
          //       Positioned(
          //           top: 85,
          //           right: 20,
          //           child: GestureDetector(
          //             onTap: () {
          //               //print("sdsd");
          //               /* Navigator.pushNamedAndRemoveUntil(
          //                   context, PageRoutes.choose_music); */
          //               Navigator.pushNamed(context, PageRoutes.choose_music);
          //             },
          //             child: CircleAvatar(
          //               backgroundImage:
          //                   AssetImage("assets/icons/music_icon.png"),
          //               radius: 20,
          //             ),
          //           )),
          //       (controller == null ||
          //               !controller!.value.isInitialized ||
          //               !controller!.value.isRecordingVideo)
          //           ?
          //           //visible when recording in progress
          //           Positioned(
          //               width: wt,
          //               bottom: 1,
          //               child: Container(
          //                 margin: EdgeInsets.only(bottom: 10),
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //                   children: <Widget>[
          //                     GestureDetector(
          //                       onTap: () => _openGallery(),
          //                       child: Image.asset(
          //                         "assets/icons/gallery.png",
          //                         width: 50,
          //                         height: 50,
          //                       ),
          //                     ),
          //                     GestureDetector(
          //                       child: CircleAvatar(
          //                           radius: 30,
          //                           backgroundColor: videoCall,
          //                           child: controller != null
          //                               ? Icon(
          //                                   Icons.videocam,
          //                                   color: secondaryColor,
          //                                   size: 30,
          //                                 )
          //                               : Text("sorry")),
          //                       /* onTap: () => Navigator.pushNamed(
          //                   context, PageRoutes.addVideoFilterPage), */
          //                       onTap: _startRecordering,
          //                     ),
          //                     InkWell(
          //                       onTap: () async {
          //                         if (!isFlash) {
          //                           controller!.setFlashMode(FlashMode.always);
          //                           print("On");
          //                           setState(() {
          //                             isFlash = true;
          //                           });
          //                         } else {
          //                           controller!.setFlashMode(FlashMode.off);
          //                           print("off");
          //                           setState(() {
          //                             isFlash = false;
          //                           });
          //                         }
          //                       },
          //                       child: Icon(
          //                         isFlash == true
          //                             ? Icons.flash_on
          //                             : Icons.flash_off,
          //                         color: secondaryColor,
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             )
          //           : Container(),
          //       (showProgress)
          //           ? Positioned(
          //               bottom: 71,
          //               child: LinearPercentIndicator(
          //                 width: MediaQuery.of(context).size.width,
          //                 lineHeight: 6.0,
          //                 animationDuration: 100,
          //                 percent: videoProgressPercent,
          //                 progressColor: Color(0xffec4a63),
          //               ),
          //             )
          //           : Container(),
          //       (controller != null &&
          //               controller!.value.isInitialized &&
          //               controller!.value.isRecordingVideo)
          //           ? Positioned(
          //               width: wt,
          //               bottom: 10,
          //               child: Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   Padding(
          //                     padding: const EdgeInsets.only(left: 5),
          //                     child: ElevatedButton(
          //                         onPressed: () {
          //                           assetsAudioPlayer.dispose();
          //                           Navigator.of(context).pop();
          //                         },
          //                         child: Text("Previous")),
          //                   ),
          //                   InkWell(
          //                     onTap: () {
          //                       //check condition
          //                       setState(() {
          //                         reverse = reverse;
          //                       });
          //                       if (!videoRecorded) {
          //                         onResumeButtonPressed();
          //                         // _animationController!.forward();
          //                       } else {
          //                         onPauseButtonPressed();
          //                         //_animationController!.stop();
          //                       }
          //                     },
          //                     child: Image.asset(
          //                       !videoRecorded
          //                           ? "assets/icons/play-icon.png"
          //                           : "assets/icons/pause-icon.png",
          //                       width: 50,
          //                       height: 50,
          //                     ),
          //                   ),
          //                   Padding(
          //                     padding: const EdgeInsets.only(right: 5),
          //                     child: ElevatedButton(
          //                         onPressed: () {
          //                           _onStopButtonPressed();
          //                         },
          //                         child: Text("Next  ")),
          //                   )
          //                 ],
          //               ))
          //           : Container(),
          //       GestureDetector(
          //         onDoubleTap: () {
          //           setState(() {
          //             if (selectedCamera == 0) {
          //               selectedCamera = 1;
          //             } else {
          //               selectedCamera = 0;
          //             }
          //             openCamera(selectedCamera);
          //           });
          //         },
          //         onScaleStart: (one) {
          //           zoom = _scaleFactor;
          //           /*         if (zoom < 8) {
          //             zoom = zoom + 1;
          //           }
          //           controller!.setZoomLevel(zoom); */
          //         },
          //         onScaleUpdate: (one) {
          //           setState(() {
          //             _scaleFactor = zoom * one.scale.toInt();
          //             if (one.scale.toInt() < 8 && one.scale.toInt() > 0) {
          //               print(one.scale.toInt());
          //               if (_scaleFactor < 8.0 && _scaleFactor > 0.0)
          //                 controller!.setZoomLevel(_scaleFactor);
          //             }
          //           });
          //         },
          //       )
          //     ],
          //   ),
          //   beginOffset: Offset(0, 0.3),
          //   endOffset: Offset(0, 0),
          //   slideCurve: Curves.linearToEaseOut,
        ),
      ),
    );
  }

  void openCamera(int index) async {
    cameras = await availableCameras();
    print(cameras.length);

    controller =
        CameraController(cameras[selectedCamera], ResolutionPreset.max);

    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  //create instace of trimmer
  //final Trimmer _trimmer = Trimmer();

  Future _openGallery() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowCompression: true);
    File? file;

    if (result != null) {
      file = File(result.files.single.path!);

      /*   setState(() {
      if (file != null) {
        
        print("video selected");
      } else {
        print('No Video  selected.');
      }
    }); */
    }

    //trim video by video trimmer

    if (file != null) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => TrimmerView(file!, 1)));
      /* await _trimmer.loadVideo(videoFile: file!);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return TrimmerVie(_trimmer, (output) async {
          setState(() {
            videoPath = output;
          });
          print("videoPath");
          Navigator.pop(context);
          setState(() {
            // isUploading = true;
          });
          String responseVideo = "";
          // responseVideo = await uploadVideo();
          if (responseVideo != "") {
            _pc1.open();
          }
        }, videoLength, audioFile);
      })); */
    }
  }

  void _startRecordering() async {
    setState(() {
      videoRecorded = true;
      isVideoRecorded = true;
    });
    _startVideoRecording().then((String filePath) {
      if (filePath.isNotEmpty) {
        setState(() {
          showProgress = true;
          startTimer();
        });
      }
    });
  }

  //start video recording

  Future<String> _startVideoRecording() async {
    if (!controller!.value.isInitialized) {
      return "";
    }

    //play asset audio player
    //_assetsAudioPlayer.play();

    // Do nothing if a recording is on progress
    if (controller!.value.isRecordingVideo) {
      return "";
    }

    final Directory? appDirectory = await getExternalStorageDirectory();
    final String videoDirectory = '${appDirectory!.path}/Videos';
    print("VideoDirectory" + videoDirectory);
    await Directory(videoDirectory).create(recursive: true);
    /*final String currentTime =
        "$countVideos" + DateTime.now().millisecondsSinceEpoch.toString();*/
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp4';
    try {
      await controller!.startVideoRecording();

      videoPath = filePath;

      //check video path
      print(videoPath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return "";
    }

    return filePath;
  }

  //show camera exception

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);
    setState(() {
      cameraCrash = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        //show here exception widget
        child: Text("Camera stop working"),
      ),
    );
  }

  //start timer
  Timer? timer;
  startTimer() {
    timer = Timer.periodic(new Duration(milliseconds: 100), (timer) {
      setState(() {
        print(timer.tick);
        videoProgressPercent += 1 / (videoLength * 10);
        print(videoProgressPercent);
        if (videoProgressPercent >= 1) {
          videoProgressPercent = 1;
          timer.cancel();
          _onStopButtonPressed();
        }
      });
    });
  }

//handle stop button

  _onStopButtonPressed() {
    setState(() {
      //work of upload here...
      showProgress = false;
      videoRecorded = false;
      print("showing dialog");
      isDialog = true;
    });
    _stopVideoRecording().then((String outputVideo) async {
      print("_loadingStreamCtrl.true");
      setState(() {
        print("dissmiss dialog");
        isDialog = false;
      });

//      _loadingStreamCtrl.sink.add(true);
      if (mounted)
        setState(() {
          showDialog(
              context: context,
              builder: (context) {
                return FutureProgressDialog(
                  playVideo(outputVideo),
                  message: Text("Loading..."),
                );
              });
        });
    });
  }

  late String reelPath;
  //stop video here
  Future<String> _stopVideoRecording() async {
    print("sdsds");
    setState(() {
      isUploading = true;
      print("_loadingStreamCtrl.true");
//      _loadingStreamCtrl.sink.add(true);
    });
    //assetsAudioPlayer.pause();
    if (!controller!.value.isRecordingVideo) {
      return "";
    }
    try {
      XFile videoFile = await controller!.stopVideoRecording();
      videoPath = videoFile.path;
      print(videoFile.path);
    } on CameraException catch (e) {
      _showCameraException(e);
      return "";
    }

    final Directory? appDirectory = await getExternalStorageDirectory();
    final String outputDirectory = '${appDirectory!.path}/outputVideos';
    await Directory(outputDirectory).create(recursive: true);
    /*final String currentTime =
        "$countVideos" + DateTime.now().millisecondsSinceEpoch.toString();*/
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String outputVideo = '$outputDirectory/$currentTime.mp4';
    print(outputVideo);

    // final String thumbNail = '$outputDirectory/${currentTime}.png';
    // final String thumbGif = '$outputDirectory/${currentTime}.gif';
    // Directory appDocDir = await getApplicationDocumentsDirectory();
    // String appDocPath = appDocDir.path;
    // String aFPath = '${appDirectory.path}/Audios/$audioFile';
    String responseVideo = "";
//    _loadingStreamCtrl.sink.add(true);

    final info = await VideoCompress.compressVideo(
      videoPath!,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: true,
    );

    print("compressed");

    setState(() {
      if (info != null) {
        videoPath = info.path;
        reelPath = info.path!;

        //print("videoPath" + videoPath!);
      }
    });

//    await _startVideoPlayer(videoPath);

//    responseVideo = await uploadVideo();
    /*   if (progress >= 100.0) {
      print("progress 100");
    } */
//    String aFPath = '${appDocDir.parent.path}' + '/$audioFile';
//    audioFile = "https://www.rachelallan.com/sara_rasines.mp3";
//    aFPath = "https://www.rachelallan.com/sarah_rasines.mp3";
    print("Merge Audio");
    /*if (audioFile != "") {
      _flutterFFmpeg
          .execute(
              "-i $videoPath -i $audioFile -c:v libx264 -c:a aac -ac 2 -ar 22050 -map 0:v:0 -map 1:a:0 -shortest $outputVideo")
          .then((rc) => print("FFmpeg process exited with rc $rc"));

      */ /*setState(() {
        videoPath = outputVideo;
      });*/ /*
    } else {
      _flutterFFmpeg
          .execute("-i $videoPath -vcodec libx265 -crf 28 $outputVideo")
          .then((rc) => print("FFmpeg process exited with rc $rc"));

      */ /*setState(() {
        videoPath = outputVideo;
      });*/ /*
    }*/
    /*_flutterFFmpeg
        .execute("-i $videoPath -ss 00:00:01.000 -vframes 1 $thumbNail")
        .then((rc) => print("FFmpeg process exited with rcthumb $rc"));
    _flutterFFmpeg
        .execute(
            "-ss 0 -t 3 -i $videoPath -vf 'fps=10,scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse' -loop 0 $thumbGif")
        .then((rc) async {
      print("FFmpeg process exited with rcgif $rc");

      setState(() {
        isConverting = false;
        thumbFile = thumbNail;
        gifFile = thumbGif;
      });
    });*/
    if (responseVideo != '') {
      print("dsdsds" + responseVideo);
//      _loadingStreamCtrl.sink.add(false);
      /*setState(() {
        videoPath = outputVideo;
      });*/
      //await _startVideoPlayer(responseVideo);
    }

    return reelPath;
  }

  //start video player

//handle resume here

  void onResumeButtonPressed() {
    //assetsAudioPlayer.play();
    resumeVideoRecording().then((_) {
      if (mounted)
        setState(() {
          videoRecorded = true;
          startTimer();
        });
    });
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

//handle pause action button
  void onPauseButtonPressed() async {
    pauseVideoRecording().then((_) {
      if (mounted)
        setState(() {
          videoRecorded = false;
          timer!.cancel();
        });
    });
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

//for stop video recording

  Future<void> playVideo(String filePath) async {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddVideoFilter(videoPath: filePath)));
    });
  }

  showLoade() async {
    /*   final ProgressDialog pr = ProgressDialog(context, isDismissible: false);
    pr.style(message: "Loading...");
    isDialog == true ? await pr.show() : await pr.hide(); */
  }

  // void playAudio(File songFile) async {
  //   print("song playing");
  //   await assetsAudioPlayer.open(Audio.file(songFile.path));
  //   assetsAudioPlayer.play();
  //   _startRecordering();
  // }

  // void playMusic() {
  //   Future.delayed(Duration(seconds: 2), () {
  //     assetsAudioPlayer = AssetsAudioPlayer();
  //     setState(() {
  //       if (songFile != null) {
  //         playAudio(songFile!);
  //       } else {
  //         print("sorry");
  //       }
  //     });
  //   });
  // }

  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    return true;
  }
}

// DUET _ PAGE

class AddDuet extends StatefulWidget {
  final VideoPlayerController duetVideoPlayer;
  final String videoName;
  AddDuet({Key? key, required this.duetVideoPlayer, required this.videoName})
      : super(key: key);

  @override
  _AddDuetState createState() => _AddDuetState();
}

class _AddDuetState extends State<AddDuet> {
  CameraController? controller;
  String FileDuet = '';
  late List<CameraDescription> cameras;
  String? videoPath;
  double videoLength = 30.0;
  var selectedCamera = 1;
  bool videoRecorded = false;
  bool isVideoRecorded = false;
  bool showProgress = false;
  bool cameraCrash = false;
  double videoProgressPercent = 0.0;

  void openCamera(int index) async {
    cameras = await availableCameras();
    print(cameras.length);

    controller =
        CameraController(cameras[selectedCamera], ResolutionPreset.max);

    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future _openGallery() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowCompression: true);
    File? file;

    if (result != null) {
      file = File(result.files.single.path!);
    }
    if (file != null) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => TrimmerView(file!, 1)));
    }
  }

  void _startRecordering() async {
    downloadDuetVideo();

    setState(() {
      videoRecorded = true;
      isVideoRecorded = true;
    });
    _startVideoRecording().then((String filePath) {
      if (filePath.isNotEmpty) {
        setState(() {
          showProgress = true;
          startTimer();
        });
      }
    });
  }

  //start video recording

  void downloadDuetVideo() async {
    try {
      var dir = await getExternalStorageDirectory();
      print("path ${dir!.path}");
      await Dio().download(
          'http://emergenceinfotech.in/ClapNew/API/v1/Uploads/Video/' +
              widget.videoName,
          "${dir.path}/${widget.videoName}.mp4",
          onReceiveProgress: (rec, total) async {
        print("Rec: $rec , Total: $total");

        if (total == rec) {
          final String videoDUet = '${dir.path}/VideosDuet';
          await Directory(videoDUet).create(recursive: true);
          final String currentTime =
              DateTime.now().millisecondsSinceEpoch.toString();
          FileDuet = '$videoDUet/$currentTime.mp4';
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> _startVideoRecording() async {
    if (!controller!.value.isInitialized) {
      return "";
    }

    //play asset audio player
    //_assetsAudioPlayer.play();

    // Do nothing if a recording is on progress
    if (controller!.value.isRecordingVideo) {
      return "";
    }

    final Directory? appDirectory = await getExternalStorageDirectory();
    final String videoDirectory = '${appDirectory!.path}/Videos';

    print("VideoDirectory" + videoDirectory);
    await Directory(videoDirectory).create(recursive: true);
    /*final String currentTime =
        "$countVideos" + DateTime.now().millisecondsSinceEpoch.toString();*/
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await controller!.startVideoRecording();
      downloadDuetVideo();

      videoPath = filePath;

      //check video path
      print(videoPath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return "";
    }

    return filePath;
  }

  //show camera exception

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);
    setState(() {
      cameraCrash = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        //show here exception widget
        child: Text("Camera stop working"),
      ),
    );
  }

  Timer? timer;
  // Default 30 secs
  startTimer({videoDuration = 10.0}) {
    timer = Timer.periodic(new Duration(milliseconds: 100), (timer) {
      setState(() {
        videoProgressPercent += 1 / (videoDuration * 10);

        if (videoProgressPercent >= 1) {
          videoProgressPercent = 1;
          timer.cancel();
          _onStopButtonPressed();
        }
      });
    });
  }

//handle stop button

  _onStopButtonPressed() {
    setState(() {
      //work of upload here...
      showProgress = false;
      videoRecorded = false;
    });
    _stopVideoRecording().then((String outputVideo) async {
      setState(() {
        print("dissmiss dialog");
      });
      if (mounted)
        setState(() {
          showDialog(
              context: context,
              builder: (context) {
                return FutureProgressDialog(
                  playVideo(outputVideo),
                  message: Text("Loading..."),
                );
              });
        });
    });
  }

  late String reelPath;
  //stop video here
  Future<String> _stopVideoRecording() async {
    print("sdsds");
    setState(() {
      print("_loadingStreamCtrl.true");
    });

    if (!controller!.value.isRecordingVideo) {
      return "";
    }
    try {
      XFile videoFile = await controller!.stopVideoRecording();
      videoPath = videoFile.path;
      print(videoFile.path);
    } on CameraException catch (e) {
      _showCameraException(e);
      return "";
    }

    final Directory? appDirectory = await getExternalStorageDirectory();
    final String outputDirectory = '${appDirectory!.path}/outputVideos';
    await Directory(outputDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String outputVideo = '$outputDirectory/$currentTime.mp4';
    final String outputDuet = '$outputDirectory/duet.mp4';
    print(outputVideo);
    String responseVideo = "";

    final info = await VideoCompress.compressVideo(
      videoPath!,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: true,
    );

    setState(() {
      if (info != null) {
        videoPath = info.path;
        reelPath = info.path!;
      }
    });

    final filter =
        " [0:v]scale=480:640,setsar=1[l];[1:v]scale=480:640,setsar=1[r];[l][r]hstack;[0][1]amix -vsync 0 ";

    FlutterFFmpeg()
        .execute(" -y -i " +
            FileDuet +
            " -i " +
            videoPath! +
            " -filter_complex" +
            filter +
            outputDuet)
        .then((value) => print('Executed'));

    setState(() {});

    /*if (audioFile != "") {
      _flutterFFmpeg
          .execute(
              "-i $videoPath -i $audioFile -c:v libx264 -c:a aac -ac 2 -ar 22050 -map 0:v:0 -map 1:a:0 -shortest $outputVideo")
          .then((rc) => print("FFmpeg process exited with rc $rc"));

      */ /*setState(() {
        videoPath = outputVideo;
      });*/ /*
    } else {
      _flutterFFmpeg
          .execute("-i $videoPath -vcodec libx265 -crf 28 $outputVideo")
          .then((rc) => print("FFmpeg process exited with rc $rc"));

      */ /*setState(() {
        videoPath = outputVideo;
      });*/ /*
    }*/
    /*_flutterFFmpeg
        .execute("-i $videoPath -ss 00:00:01.000 -vframes 1 $thumbNail")
        .then((rc) => print("FFmpeg process exited with rcthumb $rc"));
    _flutterFFmpeg
        .execute(
            "-ss 0 -t 3 -i $videoPath -vf 'fps=10,scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse' -loop 0 $thumbGif")
        .then((rc) async {
      print("FFmpeg process exited with rcgif $rc");

      setState(() {
        isConverting = false;
        thumbFile = thumbNail;
        gifFile = thumbGif;
      });
    });*/
    if (outputDuet != '') {
      print("dsdsds" + responseVideo);
    }

    return outputDuet;
  }

//handle resume here

  void onResumeButtonPressed() {
    //assetsAudioPlayer.play();
    resumeVideoRecording().then((_) {
      if (mounted)
        setState(() {
          videoRecorded = true;
          startTimer();
        });
    });
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

//handle pause action button
  void onPauseButtonPressed() async {
    pauseVideoRecording().then((_) {
      if (mounted)
        setState(() {
          videoRecorded = false;
          timer!.cancel();
        });
    });
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

//for stop video recording

  Future<void> playVideo(String filePath) async {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddVideoFilter(videoPath: filePath)));
    });
  }

  @override
  void initState() {
    openCamera(selectedCamera);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Stack(
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
            Positioned(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (selectedCamera == 0) {
                      selectedCamera = 1;
                    } else {
                      selectedCamera = 0;
                    }
                    openCamera(selectedCamera);
                  });
                },
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
            /*Positioned(child: Icon(Icons.speed,color: Colors.white,size: 31,),
              right: 25,
              top: 100,)
            ,
            Positioned(child: Text("Speed",style: TextStyle(color: Colors.white),),
                right: 23,
                top:130),*/
            Positioned(
              child: Icon(
                Icons.timer,
                color: Colors.white,
                size: 31,
              ),
              right: 25,
              top: 100,
            ),
            Positioned(
                child: Text(
                  "Timer",
                  style: TextStyle(color: Colors.white),
                ),
                right: 23,
                top: 130),
            Positioned(
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(color: Colors.white),
              ),
              left: MediaQuery.of(context).size.width - 350,
              top: MediaQuery.of(context).size.height - 100,
            ),
            Positioned(
              child: Container(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  color: Colors.red,
                  value: videoProgressPercent,
                ),
              ),
              left: MediaQuery.of(context).size.width - 245,
              top: MediaQuery.of(context).size.height - 110,
            ),
            Positioned(
                child: InkWell(
                  onTap: () {
                    _startRecordering();
                  },
                  child: Icon(
                    Icons.fiber_manual_record_rounded,
                    color: Colors.yellow,
                    size: 80,
                  ),
                ),
                left: MediaQuery.of(context).size.width - 245,
                top: MediaQuery.of(context).size.height - 110),
            Positioned(
              child: Row(
                children: [
                  Container(
                      //color: Colors.red,
                      width: MediaQuery.of(context).size.width / 2,
                      height: 350,
                      child: GestureDetector(
                          onTap: () {
                            widget.duetVideoPlayer.value.isPlaying
                                ? widget.duetVideoPlayer.pause()
                                : widget.duetVideoPlayer.play();
                          },
                          child: VideoPlayer(widget.duetVideoPlayer))),
                  Container(
                      // color: Colors.green,
                      width: MediaQuery.of(context).size.width / 2,
                      child: controller == null
                          ? SizedBox()
                          : CameraPreview(controller!),
                      height: 350),
                ],
              ),
              top: MediaQuery.of(context).size.height - 500,
            ),
            Positioned(
              child: Icon(
                Icons.tag_faces,
                color: Colors.white,
                size: 31,
              ),
              right: 25,
              top: 155,
            ),
            Positioned(
                child: Text(
                  "Beautify",
                  style: TextStyle(color: Colors.white),
                ),
                right: 17,
                top: 183),
            Positioned(
              child: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (ctxt) => new AlertDialog(
                            scrollable: true,
                            title: Text("Choose Flash Mode"),
                            content: Container(
                              height: 70,
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        controller!
                                            .setFlashMode(FlashMode.always);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'On',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        controller!.setFlashMode(FlashMode.off);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Off',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        controller!
                                            .setFlashMode(FlashMode.auto);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Auto',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ));
                },
                child: Icon(
                  Icons.flash_on,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              right: 25,
              top: 210,
            ),
            Positioned(
                child: Text(
                  "Flash",
                  style: TextStyle(color: Colors.white),
                ),
                right: 23,
                top: 238),
          ],
        ),
      ),
    );
  }
}

Dio() {}
