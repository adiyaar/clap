import 'dart:async';
import 'dart:convert';

import 'package:animation_wrappers/Animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';
import 'package:qvid/BottomNavigation/AddVideo/add_video.dart';
import 'package:qvid/BottomNavigation/Home/comment_sheet.dart';
import 'package:qvid/BottomNavigation/Home/following_tab.dart';
import 'package:qvid/BottomNavigation/Home/video_comment_controller.dart';
import 'package:qvid/Components/custom_button.dart';
import 'package:qvid/Components/entry_field.dart';
import 'package:qvid/Components/rotated_image.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/controller/player_screen_controller.dart';
import 'package:qvid/helper/api_handle.dart';
import 'package:qvid/model/user.dart';
import 'package:qvid/model/user_video.dart';
import 'package:qvid/model/video_comment.dart';
import 'package:qvid/utils/constaints.dart';
import 'package:qvid/widget/toast.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';

List<VideoComment> videoComments = [];

class FollowingTabPage1 extends StatelessWidget {
  final List<UserVideo> videos;
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
  final List<UserVideo> videos;
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
      print(current);
      print('Here');
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
        return VideoPage(widget.videos[position].videoName,
            isPaused: isOnPageTurning,
            pageIndex: position,
            currentPageIndex: current,
            isFollowing: widget.isFollowing,
            userVideo: firstTimeLoading == true
                ? position != widget.videoIndex!
                    ? widget.videos[position]
                    : widget.videos[widget.videoIndex!]
                : widget.videos[widget.videoIndex!]);
      },
      onPageChanged: (i) {
        setState(() {
          firstTimeLoading = true;
        });
        getUserMatchPost(widget.videos[i].id);
      },
      itemCount: widget.videos.length,
    );
  }
}

class VideoPage extends StatefulWidget {
  final String video;
  //final String image;
  final int? pageIndex;
  int? currentPageIndex;
  final bool? isPaused;
  final bool? isFollowing;
  final UserVideo? userVideo;

  VideoPage(this.video,
      {this.pageIndex,
      this.currentPageIndex,
      this.isPaused,
      this.isFollowing,
      this.userVideo});

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with RouteAware {
  var contr = Get.put(UserVideoComment());
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
  bool isPlaying = false;
  bool isStatus = false;
  bool downloading = false;
  var progressString = "";
  bool isPlay = false;
  User? user;
  int count = -1;

  bool tappedLikeIcon = false;
  bool tappedDislikeIcon = false;
  TextEditingController _comment = TextEditingController();
  TextEditingController _replyComment = TextEditingController();

  late VideoPlayerController _controller;
  void checkVideo() {
    // Implement your calls inside these conditions' bodies :
    if (_controller.value.position ==
        Duration(seconds: 0, minutes: 0, hours: 0)) {
      print('video Started');
    }

    if (_controller.value.position == _controller.value.duration) {
      print('video Ended');
    }
  }

  @override
  void initState() {
    super.initState();

    widget.userVideo!.likeStatus == true ? isLiked = true : isLiked = false;
    fetchCurrentUser();
    print("likestatus ${widget.userVideo!.likeStatus}");

    _controller = VideoPlayerController.network(
        Constraints.Video_URL + widget.userVideo!.videoName)
      ..initialize().then((value) {
        setState(() {
          _controller.setLooping(true);

          _controller.play();
          isPlaying = true;

          initialized = true;
          isLoading = false;
        });
      });

    getUserMatchPost(widget.userVideo!.id);
  }

  @override
  void didPopNext() {
    print("didPopNext");
    _controller.play();
    isPlaying = true;
    super.didPopNext();
  }

  @override
  void didPushNext() {
    print("didPushNext");
    _controller.pause();
    isPlaying = false;
    super.didPushNext();
  }

  @override
  void didChangeDependencies() {
    _controller.pause();
    routeObserver.subscribe(
        this, ModalRoute.of(context) as PageRoute<dynamic>); //Subscribe it here
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    _controller.dispose();
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
    if (widget.pageIndex == widget.currentPageIndex &&
        !widget.isPaused! &&
        initialized) {
      _controller.play();
      setState(() {
        isPlaying = true;
      });
      //isPlaying = true;
    } else {
      _controller.pause();
      setState(() {
        isPlaying = false;
      });
    }

    Get.put(UserVideoComment());

    return WillPopScope(
      onWillPop: () {
        _controller.value.isPlaying == true ? _controller.pause() : "";

        return new Future.value(true);
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: GestureDetector(
            onTap: () {
              _showOverlayMuteButton(context);
              _controller.setVolume(0.0);
            },
            onDoubleTap: () {
              _showOverlayUnmuteButton(context);
              _controller.setVolume(1.0);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        widget.userVideo!.description.trim(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        widget.userVideo!.date,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      // Row(
                                      //   children: [
                                      //     Icon(
                                      //       Icons.music_note,
                                      //       color: Colors.white,
                                      //       size: 15,
                                      //     ),
                                      //     Text(

                                      //       style: TextStyle(color: Colors.white),
                                      //     ),
                                      //   ],
                                      // )
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .7,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  _controller.pause();

                                                  Navigator.pushNamed(context,
                                                      PageRoutes.addVideoPage);
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
                                                              .userVideo!
                                                              .userId)
                                                      .then((value) =>
                                                          _controller.pause());
                                                },
                                                child: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(Constraints
                                                                .IMAGE_BASE_URL +
                                                            widget.userVideo!
                                                                .userProfilePic)),
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

                                                  User user = await ApiHandle
                                                      .fetchUser();
                                                  likeVideo(user.id,
                                                      widget.userVideo!.id);
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
                                                      (int.parse(widget
                                                                  .userVideo!
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
                                                      //enableDrag: true,
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          backgroundColor,
                                                      shape: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          25.0)),
                                                          borderSide:
                                                              BorderSide.none),
                                                      context: context,
                                                      builder: (context) =>
                                                          Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  1.5,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            10.0),
                                                                child: Stack(
                                                                  children: <
                                                                      Widget>[
                                                                    FadedSlideAnimation(
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.stretch,
                                                                        children: <
                                                                            Widget>[
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.all(20.0),
                                                                            child:
                                                                                Text(
                                                                              "Comments",
                                                                              style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.only(bottom: 100.0),
                                                                              child: ListView.builder(
                                                                                  physics: BouncingScrollPhysics(),
                                                                                  itemCount: videoComments.length,
                                                                                  // controller: _controller,
                                                                                  itemBuilder: (context, index) {
                                                                                    return Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: <Widget>[
                                                                                        SizedBox(
                                                                                          height: 10,
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                          child: Column(
                                                                                            children: [
                                                                                              Row(
                                                                                                children: [
                                                                                                  SizedBox(
                                                                                                    width: 25,
                                                                                                  ),
                                                                                                  CircleAvatar(
                                                                                                    backgroundImage: NetworkImage(
                                                                                                      Constraints.IMAGE_BASE_URL + videoComments[index].image!,
                                                                                                    ),
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    width: 15,
                                                                                                  ),
                                                                                                  Container(
                                                                                                    height: 60.0,
                                                                                                    width: MediaQuery.of(context).size.width / 1.8,
                                                                                                    decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(5.0)),
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsets.only(left: 8.0, top: 5.0),
                                                                                                      child: Column(
                                                                                                        children: [
                                                                                                          Align(alignment: Alignment.centerLeft, child: Text("@${videoComments[index].name!}", style: TextStyle(color: Colors.grey, fontSize: 13))),
                                                                                                          SizedBox(
                                                                                                            height: 5,
                                                                                                          ),
                                                                                                          Align(alignment: Alignment.centerLeft, child: Text(videoComments[index].comment!, style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  /*SizedBox(
                                                                            width:MediaQuery.of(context).size.width/4 ,
                                                                          ),*/
                                                                                                  SizedBox(
                                                                                                    width: 40,
                                                                                                  ),
                                                                                                  Column(
                                                                                                    children: [
                                                                                                      GestureDetector(
                                                                                                        onTap: () {
                                                                                                          setState(() {
                                                                                                            tappedLikeIcon = !tappedLikeIcon;
                                                                                                          });
                                                                                                          commentLike(widget.userVideo!.userId, widget.userVideo!.id, contr.commentList[index].id, widget.userVideo!);
                                                                                                        },
                                                                                                        child: Icon(
                                                                                                          Icons.favorite_rounded,
                                                                                                          color: tappedLikeIcon == true ? Colors.red : Colors.white,
                                                                                                        ),
                                                                                                      ),
                                                                                                      Text(videoComments[index].likesCount!,
                                                                                                          style: TextStyle(
                                                                                                            color: Colors.white,
                                                                                                          ))
                                                                                                    ],
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                              Column(
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.only(left: 98.0),
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          "16d",
                                                                                                          style: TextStyle(color: Colors.grey),
                                                                                                        ),
                                                                                                        SizedBox(
                                                                                                          width: 18,
                                                                                                        ),
                                                                                                        TextButton(
                                                                                                          onPressed: () {
                                                                                                            showModalBottomSheet(
                                                                                                                context: context,
                                                                                                                builder: (_) => Container(
                                                                                                                      color: backgroundColor,
                                                                                                                      width: MediaQuery.of(context).size.width,
                                                                                                                      child: EntryField(
                                                                                                                        controller: _replyComment,
                                                                                                                        counter: null,
                                                                                                                        padding: MediaQuery.of(context).viewInsets,
                                                                                                                        hint: "Replying to ${contr.commentList[index].name!}",
                                                                                                                        fillColor: Colors.grey.shade100,
                                                                                                                        prefix: Padding(
                                                                                                                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                                                                                                          child: user!.image.isEmpty
                                                                                                                              ? CircleAvatar(
                                                                                                                                  backgroundImage: AssetImage('assets/images/user.webp'),
                                                                                                                                )
                                                                                                                              : CircleAvatar(
                                                                                                                                  backgroundImage: NetworkImage(Constraints.IMAGE_BASE_URL + user!.image),
                                                                                                                                ),
                                                                                                                        ),
                                                                                                                        suffixIcon: GestureDetector(
                                                                                                                          onTap: () {
                                                                                                                            if (_replyComment.text.isNotEmpty) {
                                                                                                                              FocusScope.of(context).unfocus();
                                                                                                                              recomment(widget.userVideo!.userId, contr.commentList[index].id, widget.userVideo!, _replyComment.text);
                                                                                                                              _replyComment.text = "";
                                                                                                                              Navigator.pop(context);
                                                                                                                            } else {
                                                                                                                              MyToast(message: "Please Write a Comment");
                                                                                                                            }
                                                                                                                          },
                                                                                                                          child: Icon(
                                                                                                                            Icons.send,
                                                                                                                            color: mainColor,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ));
                                                                                                          },
                                                                                                          child: Text('Reply'),
                                                                                                        )
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                              contr.commentList[index].replyComment.length > 0
                                                                                                  ? Container(
                                                                                                      margin: EdgeInsets.only(left: 50),
                                                                                                      child: ListView.builder(
                                                                                                          shrinkWrap: true,
                                                                                                          itemCount: contr.commentList[index].replyComment.length,
                                                                                                          itemBuilder: (context, i) {
                                                                                                            return ListTile(
                                                                                                              leading: CircleAvatar(
                                                                                                                radius: 12,
                                                                                                                backgroundImage: NetworkImage(
                                                                                                                  Constraints.IMAGE_BASE_URL + contr.commentList[index].replyComment[i].image!,
                                                                                                                ),
                                                                                                              ),
                                                                                                              title: Text(
                                                                                                                contr.commentList[index].replyComment[i].name,
                                                                                                                style: TextStyle(color: Colors.white),
                                                                                                              ),
                                                                                                              subtitle: Column(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    contr.commentList[index].replyComment[i].text,
                                                                                                                    style: TextStyle(color: Colors.white),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                              trailing: IconButton(
                                                                                                                icon: Icon(
                                                                                                                  Icons.thumb_up,
                                                                                                                  color: tappedDislikeIcon == true ? Colors.red : Colors.white,
                                                                                                                  size: 20,
                                                                                                                ),
                                                                                                                onPressed: () {
                                                                                                                  setState(() {
                                                                                                                    tappedDislikeIcon = !tappedDislikeIcon;
                                                                                                                  });
                                                                                                                  MyToast(message: "Liked Successfully");
                                                                                                                },
                                                                                                              ),
                                                                                                            );
                                                                                                          }),
                                                                                                    )
                                                                                                  : SizedBox()
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  }),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      beginOffset:
                                                                          Offset(
                                                                              0,
                                                                              0.3),
                                                                      endOffset:
                                                                          Offset(
                                                                              0,
                                                                              0),
                                                                      slideCurve:
                                                                          Curves
                                                                              .linearToEaseOut,
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .bottomCenter,
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {},
                                                                        child:
                                                                            EntryField(
                                                                          controller:
                                                                              _comment,
                                                                          counter:
                                                                              null,
                                                                          padding:
                                                                              MediaQuery.of(context).viewInsets,
                                                                          hint:
                                                                              "Write Your comment",
                                                                          fillColor: Colors
                                                                              .grey
                                                                              .shade100,
                                                                          prefix:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                                                            child: user!.image.isEmpty
                                                                                ? CircleAvatar(
                                                                                    backgroundImage: AssetImage('assets/images/user.webp'),
                                                                                  )
                                                                                : CircleAvatar(
                                                                                    backgroundImage: NetworkImage(Constraints.IMAGE_BASE_URL + user!.image),
                                                                                  ),
                                                                          ),
                                                                          suffixIcon:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              if (_comment.text.isNotEmpty) {
                                                                                //isComment = true;

                                                                                FocusScope.of(context).unfocus();
                                                                                commentVideo(widget.userVideo!.userId, widget.userVideo!.id, _comment.text, widget.userVideo!);
                                                                                _comment.text = "";
                                                                              } else {
                                                                                MyToast(message: "Write Your Comment");
                                                                              }
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              Icons.send,
                                                                              color: mainColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )));
                                                },
                                                child: ImageIcon(
                                                  AssetImage(
                                                      'assets/icons/comment_white.png'),
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                widget.userVideo!.comment,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  _controller.pause();
                                                  showBottomSheet(
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
                                                                BorderRadius
                                                                    .only(
                                                              topRight: Radius
                                                                  .circular(20),
                                                              topLeft: Radius
                                                                  .circular(20),
                                                            ),
                                                            child: Container(
                                                              color:
                                                                  Colors.black,
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
                                                                      _controller
                                                                          .pause();
                                                                      Navigator.pop(
                                                                          context);
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
                                                                        return AddDuet(
                                                                            videoName:
                                                                                widget.userVideo!.videoName,
                                                                            duetVideoPlayer: _controller);
                                                                      }));
                                                                    },
                                                                  ),
                                                                  ListTile(
                                                                    leading:
                                                                        Icon(
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
          )),
    );
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

  Future<List<VideoComment>> getUserMatchPost(String userId) async {
    dynamic response = await Apis().getVideoComment(userId);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;
        videoComments.addAll(
            re.map<VideoComment>((e) => VideoComment.fromJson(e)).toList());
        return videoComments;
      } else {
        print("error");
        MyToast(message: msg).toast;
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }

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

Future<List<VideoComment>> getUserMatchPost(String userId) async {
  dynamic response = await Apis().getVideoComment(userId);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    String res = data['res'];
    String msg = data['msg'];
    if (res == "success") {
      var re = data['data'] as List;
      videoComments.addAll(
          re.map<VideoComment>((e) => VideoComment.fromJson(e)).toList());
      return videoComments;
    } else {
      print("error");
      MyToast(message: msg).toast;
      return [];
    }
  } else {
    throw Exception('Failed to load album');
  }
}
