import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:camera/camera.dart';
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
                    onTap: () {
                      // setState(() {
                      //   if (selectedCamera == 0) {
                      //     selectedCamera = 1;
                      //   } else {
                      //     selectedCamera = 0;
                      //   }
                      //   openCamera(selectedCamera);
                      // });
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

  // void openCamera(int index) async {
  //   cameras = await availableCameras();
  //   print(cameras.length);

  //   controller =
  //       CameraController(cameras[selectedCamera], ResolutionPreset.max);

  //   controller!.initialize().then((_) {
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() {});
  //   });
  // }

  //create instace of trimmer
  //final Trimmer _trimmer = Trimmer();

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

//   void _startRecordering() async {
//     setState(() {
//       videoRecorded = true;
//       isVideoRecorded = true;
//     });
//     _startVideoRecording().then((String filePath) {
//       if (filePath.isNotEmpty) {
//         setState(() {
//           showProgress = true;
//           startTimer();
//         });
//       }
//     });
//   }

//   //start video recording

//   Future<String> _startVideoRecording() async {
//     if (!controller!.value.isInitialized) {
//       return "";
//     }

//     //play asset audio player
//     //_assetsAudioPlayer.play();

//     // Do nothing if a recording is on progress
//     if (controller!.value.isRecordingVideo) {
//       return "";
//     }

//     final Directory? appDirectory = await getExternalStorageDirectory();
//     final String videoDirectory = '${appDirectory!.path}/Videos';
//     print("VideoDirectory" + videoDirectory);
//     await Directory(videoDirectory).create(recursive: true);
//     /*final String currentTime =
//         "$countVideos" + DateTime.now().millisecondsSinceEpoch.toString();*/
//     final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
//     final String filePath = '$videoDirectory/$currentTime.mp4';
//     try {
//       await controller!.startVideoRecording();

//       videoPath = filePath;

//       //check video path
//       print(videoPath);
//     } on CameraException catch (e) {
//       _showCameraException(e);
//       return "";
//     }

//     return filePath;
//   }

//   //show camera exception

//   void _showCameraException(CameraException e) {
//     String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
//     print(errorText);
//     setState(() {
//       cameraCrash = true;
//     });
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
//         elevation: 0.0,
//         backgroundColor: Colors.transparent,
//         //show here exception widget
//         child: Text("Camera stop working"),
//       ),
//     );
//   }

//   //start timer
//   Timer? timer;
//   startTimer() {
//     timer = Timer.periodic(new Duration(milliseconds: 100), (timer) {
//       setState(() {
//         print(timer.tick);
//         videoProgressPercent += 1 / (videoLength * 10);
//         print(videoProgressPercent);
//         if (videoProgressPercent >= 1) {
//           videoProgressPercent = 1;
//           timer.cancel();
//           _onStopButtonPressed();
//         }
//       });
//     });
//   }

// //handle stop button

//   _onStopButtonPressed() {
//     setState(() {
//       //work of upload here...
//       showProgress = false;
//       videoRecorded = false;
//       print("showing dialog");
//       isDialog = true;
//     });
//     _stopVideoRecording().then((String outputVideo) async {
//       print("_loadingStreamCtrl.true");
//       setState(() {
//         print("dissmiss dialog");
//         isDialog = false;
//       });

// //      _loadingStreamCtrl.sink.add(true);
//       if (mounted)
//         setState(() {
//           showDialog(
//               context: context,
//               builder: (context) {
//                 return FutureProgressDialog(
//                   playVideo(outputVideo),
//                   message: Text("Loading..."),
//                 );
//               });
//         });
//     });
//   }

//   late String reelPath;
  //stop video here
//   Future<String> _stopVideoRecording() async {
//     print("sdsds");
//     setState(() {
//       isUploading = true;
//       print("_loadingStreamCtrl.true");
// //      _loadingStreamCtrl.sink.add(true);
//     });
//     //assetsAudioPlayer.pause();
//     if (!controller!.value.isRecordingVideo) {
//       return "";
//     }
//     try {
//       XFile videoFile = await controller!.stopVideoRecording();
//       videoPath = videoFile.path;
//       print(videoFile.path);
//     } on CameraException catch (e) {
//       _showCameraException(e);
//       return "";
//     }

//     final Directory? appDirectory = await getExternalStorageDirectory();
//     final String outputDirectory = '${appDirectory!.path}/outputVideos';
//     await Directory(outputDirectory).create(recursive: true);
//     /*final String currentTime =
//         "$countVideos" + DateTime.now().millisecondsSinceEpoch.toString();*/
//     final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
//     final String outputVideo = '$outputDirectory/$currentTime.mp4';
//     print(outputVideo);

//     // final String thumbNail = '$outputDirectory/${currentTime}.png';
//     // final String thumbGif = '$outputDirectory/${currentTime}.gif';
//     // Directory appDocDir = await getApplicationDocumentsDirectory();
//     // String appDocPath = appDocDir.path;
//     // String aFPath = '${appDirectory.path}/Audios/$audioFile';
//     String responseVideo = "";
// //    _loadingStreamCtrl.sink.add(true);

//     final info = await VideoCompress.compressVideo(
//       videoPath!,
//       quality: VideoQuality.MediumQuality,
//       deleteOrigin: true,
//     );

//     print("compressed");

//     setState(() {
//       if (info != null) {
//         videoPath = info.path;
//         reelPath = info.path!;

//       }
//     });

//     print("Merge Audio");

//     if (responseVideo != '') {

//     }

//     return reelPath;
//   }

  //start video player

//handle resume here

//   void onResumeButtonPressed() {
//     //assetsAudioPlayer.play();
//     resumeVideoRecording().then((_) {
//       if (mounted)
//         setState(() {
//           videoRecorded = true;
//           startTimer();
//         });
//     });
//   }

//   Future<void> resumeVideoRecording() async {
//     if (!controller!.value.isRecordingVideo) {
//       return;
//     }

//     try {
//       await controller!.resumeVideoRecording();
//     } on CameraException catch (e) {
//       _showCameraException(e);
//       rethrow;
//     }
//   }

// //handle pause action button
//   void onPauseButtonPressed() async {
//     pauseVideoRecording().then((_) {
//       if (mounted)
//         setState(() {
//           videoRecorded = false;
//           timer!.cancel();
//         });
//     });
//   }

//   Future<void> pauseVideoRecording() async {
//     if (!controller!.value.isRecordingVideo) {
//       return null;
//     }

//     try {
//       await controller!.pauseVideoRecording();
//     } on CameraException catch (e) {
//       _showCameraException(e);
//       rethrow;
//     }
//   }

//for stop video recording

  // Future<void> playVideo(String filePath) async {
  //   Future.delayed(Duration(seconds: 5), () {
  //     Navigator.of(context).push(MaterialPageRoute(
  //         builder: (context) => AddVideoFilter(videoPath: filePath)));
  //   });
  // }

  // showLoade() async {
  //   /*   final ProgressDialog pr = ProgressDialog(context, isDismissible: false);
  //   pr.style(message: "Loading...");
  //   isDialog == true ? await pr.show() : await pr.hide(); */
  // }

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
