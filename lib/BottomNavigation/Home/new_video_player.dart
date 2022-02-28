import 'dart:async';
import 'dart:convert';

import 'package:animation_wrappers/Animations/faded_slide_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:gallery_saver/gallery_saver.dart';

import 'package:lottie/lottie.dart';
import 'package:qvid/BottomNavigation/AddVideo/add_video.dart';
import 'package:qvid/BottomNavigation/Home/comment_sheet.dart';
import 'package:qvid/BottomNavigation/Home/following_tab.dart';

import 'package:qvid/Components/entry_field.dart';
import 'package:qvid/Components/rotated_image.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/api_handle.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/model/user.dart';
import 'package:qvid/model/user_video.dart';
import 'package:qvid/model/video_comment.dart';
import 'package:qvid/utils/constaints.dart';
import 'package:qvid/widget/toast.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';

List<VideoComment> videoComments = [];
List<String> imagesInDisc1 = [
  'assets/user/user1.png',
  'assets/user/user2.png',
  'assets/user/user3.png',
];

class FollowingTabPage1 extends StatelessWidget {
  final List<UserVideos> videos;
  final List<String> images;
  final bool isFollowing;

  final int? variable;
  final int? videoIndex;

  FollowingTabPage1(this.videos, this.images, this.isFollowing, this.videoIndex,
      {this.variable});

  @override
  Widget build(BuildContext context) {
    return videos.isNotEmpty
        ? FollowingTab1Body(
            videos,
            images,
            isFollowing,
            videoIndex,
          )
        : Center(
            child: Lottie.asset(
              "assets/animation/no-data.json",
              width: 250,
              height: 250,
            ),
          );
  }
}

// ignore: must_be_immutable
class FollowingTab1Body extends StatefulWidget {
  final List<UserVideos> videos;
  final List<String> images;

  final bool isFollowing;

  int? videoIndex;

  FollowingTab1Body(
      this.videos, this.images, this.isFollowing, this.videoIndex);

  @override
  _FollowingTab1BodyState createState() => _FollowingTab1BodyState();
}

class _FollowingTab1BodyState extends State<FollowingTab1Body> {
  PageController? _pageController;

  int current = 0;

  bool isOnPageTurning = false;
  bool firstTimeLoading = false;

  void scrollListener() {
    if (isOnPageTurning &&
        _pageController!.page == _pageController!.page!.roundToDouble()) {
      print('Here2');

      setState(() {
        current = _pageController!.page!.toInt();

        isOnPageTurning = false;
      });
    } else if (!isOnPageTurning &&
        current.toDouble() != _pageController!.page) {
      // current = widget.videoIndex!;

      if ((current.toDouble() - _pageController!.page!).abs() > 0.1) {
        isOnPageTurning = true;
      }
    }
  }

  int numPage = 1;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _pageController!.addListener(scrollListener);
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      controller: _pageController,
      itemBuilder: (context, position) {
        return VideoPage(widget.videos[position].videoName!,
            isPaused: isOnPageTurning,
            pageIndex: position,
            currentPageIndex: current,
            isFollowing: widget.isFollowing,
            userVideo: position != widget.videoIndex!
                ? widget.videos[position]
                : widget.videos[widget.videoIndex!]);
      },
      itemCount: widget.videos.length,
    );
  }
}

class VideoPage extends StatefulWidget {
  final String video;
  final int? pageIndex;
  final int? currentPageIndex;
  final bool? isPaused;
  final bool? isFollowing;
  UserVideos? userVideo;

  VideoPage(this.video,
      {this.pageIndex,
      this.currentPageIndex,
      this.isPaused,
      this.isFollowing,
      this.userVideo});

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with WidgetsBindingObserver {
  void _showOverlayMuteButton(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return Center(
        child: Icon(Icons.volume_off, color: Colors.white),
      );
    });

    overlayState!.insert(overlayEntry);

    await Future.delayed(Duration(seconds: 1));
    overlayEntry.remove();
  }

  void _showOverlayUnmuteButton(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return Center(
        child: Icon(
          Icons.volume_up,
          color: Colors.white,
        ),
      );
    });

    overlayState!.insert(overlayEntry);
    await Future.delayed(Duration(seconds: 1));
    overlayEntry.remove();
  }

  bool initialized = false;
  bool isLiked = false;
  bool isLoading = true;
  bool isHit = false;

  bool isStatus = false;
  bool downloading = false;
  var progressString = "";
  bool isPlay = false;
  User? user;
  int count = -1;

  Future<bool> _saveNetworkVideo() async {
    String path = Constraints.Video_URL + widget.userVideo!.videoName!;
    GallerySaver.saveVideo(path).then((bool? success) {
      setState(() {
        print('Video is saved');

        MyToast(message: 'Video Saved In Gallery').toast;
      });
      return true;
    });
    return false;
  }

  bool tappedLikeIcon = false;
  bool tappedDislikeIcon = false;
  TextEditingController _comment = TextEditingController();
  TextEditingController _replyComment = TextEditingController();
  bool isCommented = false;

  late VideoPlayerController _controller;
  List<String> comments = [
    'Bindaas',
    'Jhakas',
    'Awesome',
    'Hot',
    'Beautiful',
    'Classy',
    'Sexy',
    'Maza aagya',
    'Hahaha'
  ];

  late VideoPlayerController logoController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    widget.userVideo!.likeStatus == true ? isLiked = true : isLiked = false;
    fetchCurrentUser();

    _controller = VideoPlayerController.network(
        Constraints.Video_URL + widget.userVideo!.videoName!,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((value) {
        setState(() {
          _controller.addListener(() {
            setState(() {});
          });
          _controller.setLooping(true);

          _controller.play();

          initialized = true;
          isLoading = false;
        });
      });

    logoController =
        VideoPlayerController.asset("assets/audio/splash_video.mp4")
          ..initialize().then((value) {
            setState(() {
              logoController.setLooping(true);
              logoController.play();
              logoController.setVolume(0.0);
            });
          });
  }

  // @override
  // void didPopNext() {
  //   print("didPopNext");
  //   _controller.pause();

  //   super.didPopNext();
  // }

  // @override
  // void didPushNext() {
  //   print("didPushNext");
  //   _controller.pause();

  //   super.didPushNext();
  // }

  // @override
  // void didChangeDependencies() {
  //   _controller.pause();
  //   routeObserver.subscribe(
  //       this, ModalRoute.of(context) as PageRoute<dynamic>); //Subscribe it here
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    // routeObserver.unsubscribe(this);
    WidgetsBinding.instance!.removeObserver(this);

    _controller.dispose();
    logoController.dispose();
    super.dispose();
  }

  void fetchCurrentUser() async {
    User user1 = await ApiHandle.fetchUser();
    setState(() {
      user = user1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () {
            _showOverlayUnmuteButton(context);
            _controller.setVolume(1.0);
          },
          onDoubleTap: () {
            _showOverlayMuteButton(context);
            _controller.setVolume(0.0);
          },
          onLongPress: () {
            _controller.pause();
          },
          onLongPressEnd: (details) {
            _controller.play();
          },
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Opacity(opacity: 0.8, child: VideoPlayer(_controller)),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: Container(
                  height: 50,
                  width: 80,
                  child: VideoPlayer(logoController),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 25.0, right: 15.0, left: 15.0, bottom: 10.0),
                    child: Column(
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .8,
                                height: MediaQuery.of(context).size.height,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      widget.userVideo!.userName!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      widget.userVideo!.description!.trim(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: MediaQuery.of(context).size.height,
                                  decoration: BoxDecoration(
                                      // color: Colors.green
                                      ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        //color: Colors.red,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .7,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _controller.pause();

                                                showModalBottomSheet(
                                                    context: context,
                                                    builder: (_) => Container(
                                                          color:
                                                              backgroundColor,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              3,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 30.0,
                                                                    left: 10),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Choose Video Duration',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      Navigator.push(
                                                                          context,
                                                                          CupertinoPageRoute(
                                                                              builder: (_) => AddVideo(15)));
                                                                    },
                                                                    child: Text(
                                                                        '15 seconds')),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      Navigator.push(
                                                                          context,
                                                                          CupertinoPageRoute(
                                                                              builder: (_) => AddVideo(30)));
                                                                    },
                                                                    child: Text(
                                                                        '30 seconds')),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      Navigator.push(
                                                                          context,
                                                                          CupertinoPageRoute(
                                                                              builder: (_) => AddVideo(60)));
                                                                    },
                                                                    child: Text(
                                                                        '60 seconds')),
                                                              ],
                                                            ),
                                                          ),
                                                        ));
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                height: 25,
                                                width: 25,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    border: Border.all(
                                                        color: Colors.white)),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 30),
                                            InkWell(
                                              onTap: () async {
                                                _controller.pause();

                                                await Navigator.pushNamed(
                                                        context,
                                                        PageRoutes
                                                            .userProfilePage,
                                                        arguments: widget
                                                            .userVideo!.userId)
                                                    .then((value) =>
                                                        _controller.pause());
                                              },
                                              child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      Constraints
                                                              .IMAGE_BASE_URL +
                                                          widget.userVideo!
                                                              .image!)),
                                            ),
                                            SizedBox(
                                              height: 30,
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                setState(() {
                                                  widget.userVideo!
                                                              .likeStatus! ==
                                                          true
                                                      ? isLiked = false
                                                      : isLiked = true;
                                                });

                                                User user =
                                                    await ApiHandle.fetchUser();
                                                likeVideo(user.id,
                                                    widget.userVideo!.id!);
                                              },
                                              child: Container(
                                                child: Icon(
                                                  Icons.favorite,
                                                  color: isLiked == true
                                                      ? Colors.red
                                                      : Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                            isLiked == true
                                                ? Text(
                                                    (int.parse(widget.userVideo!
                                                                .likes!) +
                                                            1)
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                : Text(
                                                    widget.userVideo!.likes!,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                            SizedBox(
                                              height: 30,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _controller.pause();

                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  enableDrag: true,
                                                  builder: (_) => Container(
                                                    color: Colors.black,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Text('Comment',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        SizedBox(height: 10),
                                                        ListView.builder(
                                                            itemCount:
                                                                comments.length,
                                                            physics:
                                                                BouncingScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return ListTile(
                                                                title: Text(
                                                                    comments[
                                                                        index]),
                                                                onTap: () {
                                                                  setState(() {
                                                                    isCommented =
                                                                        true;
                                                                  });
                                                                  commentVideo(
                                                                      widget
                                                                          .userVideo!
                                                                          .userId!,
                                                                      widget
                                                                          .userVideo!
                                                                          .id!,
                                                                      comments[
                                                                          index],
                                                                      widget
                                                                          .userVideo!);
                                                                  Navigator.pop(
                                                                      context);
                                                                  _controller
                                                                      .play();
                                                                },
                                                              );
                                                            })
                                                      ],
                                                    ),
                                                  ),
                                                  context: context,
                                                );
                                              },
                                              child: ImageIcon(
                                                AssetImage(
                                                    'assets/icons/comment_white.png'),
                                                color: Colors.white,
                                              ),
                                            ),
                                            isCommented == true
                                                ? Text(
                                                    '${int.parse(widget.userVideo!.comment!) + 1}',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                : Text(
                                                    widget.userVideo!.comment!,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                            SizedBox(
                                              height: 30,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                _controller.pause();
                                                showModalBottomSheet(
                                                    backgroundColor:
                                                        Colors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                      topRight:
                                                          Radius.circular(20),
                                                      topLeft:
                                                          Radius.circular(20),
                                                    )),
                                                    context: context,
                                                    builder: (_) => ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    20),
                                                            topLeft:
                                                                Radius.circular(
                                                                    20),
                                                          ),
                                                          child: Container(
                                                            color: Colors.black,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                3,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Column(
                                                              children: [
                                                                ListTile(
                                                                  leading: Icon(
                                                                      Icons
                                                                          .ios_share,
                                                                      color: Colors
                                                                          .white),
                                                                  title: Text(
                                                                      'Share Video'),
                                                                  onTap: () {
                                                                    _controller
                                                                        .pause();
                                                                    Navigator.pop(
                                                                        context);
                                                                    _controller
                                                                        .play();
                                                                    shareApp();
                                                                  },
                                                                ),
                                                                ListTile(
                                                                  leading: Icon(
                                                                      Icons
                                                                          .download_rounded,
                                                                      color: Colors
                                                                          .white),
                                                                  title: Text(
                                                                      'Download Video'),
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);

                                                                    MyToast(
                                                                            message:
                                                                                'Downloading Started')
                                                                        .toast;
                                                                    FutureProgressDialog(
                                                                      _saveNetworkVideo(),
                                                                      message: Text(
                                                                          "Downloading..."),
                                                                    );
                                                                  },
                                                                ),
                                                                ListTile(
                                                                  leading: Icon(
                                                                      Icons
                                                                          .people,
                                                                      color: Colors
                                                                          .white),
                                                                  title: Text(
                                                                      'Make Duet'),
                                                                  onTap: () {
                                                                    _controller
                                                                        .pause();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(builder:
                                                                            (context) {
                                                                      return DuetPage(
                                                                        duetPlayer:
                                                                            _controller,
                                                                        videoName: widget
                                                                            .userVideo!
                                                                            .videoName!,
                                                                        durationofVideo:
                                                                            30,
                                                                      );
                                                                    }));
                                                                  },
                                                                ),
                                                                ListTile(
                                                                  leading: Icon(
                                                                    Icons
                                                                        .report_problem,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  title: Text(
                                                                      'Report Video'),
                                                                  onTap: () {
                                                                    _controller
                                                                        .pause();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();

                                                                    Navigator.pushNamed(
                                                                        context,
                                                                        PageRoutes
                                                                            .reportReels,
                                                                        arguments: widget
                                                                            .userVideo!
                                                                            .id);
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ));
                                              },
                                              child: Container(
                                                child: Icon(
                                                  FontAwesomeIcons.share,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 100,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              child: RotatedImage(
                                                  "assets/user/user1.png"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

//like video
  Future<void> likeVideo(String userId, String videoId) async {
    dynamic response = await Apis().likeVideo(userId, videoId);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];

      if (res == "success") {
        //MyToast(message: msg).toast;
        int cou = data['data'];
        print("like count $count");

        setState(() {
          isLiked = true;
          isHit = false;
          count = cou;
          isStatus = true;
          widget.userVideo!.likeStatus = true;
        });
        call();
      } else {
        //MyToast(message: msg).toast;

        int cou = data['data'];
        setState(() {
          isLiked = false;
          isHit = false;
          isStatus = false;
          count = cou;
          widget.userVideo!.likeStatus = false;
        });
      }
    } else {
      MyToast(message: "Server Errror");
    }
  }

  // share video
  Future<void> shareVideo(String userId, String videoId) async {
    dynamic response = await Apis().shareVideo(userId, videoId);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        MyToast(message: msg).toast;
        shareApp();
      } else {
        MyToast(message: msg).toast;
      }
    } else {
      MyToast(message: "Server Errror");
    }
  }

//gte Comment
//get List of comment

  shareApp() {
    Share.share('Bollywood clap https://example.com');
  }

  void call() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isStatus = false;
      });
    });
  }
}
