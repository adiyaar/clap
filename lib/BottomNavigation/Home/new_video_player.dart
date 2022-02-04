import 'dart:async';
import 'dart:convert';

import 'package:animation_wrappers/Animations/faded_slide_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
import 'package:qvid/model/user.dart';
import 'package:qvid/model/user_video.dart';
import 'package:qvid/model/video_comment.dart';
import 'package:qvid/utils/constaints.dart';
import 'package:qvid/widget/toast.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';

List<VideoComment> videoComments = [];

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
  final UserVideos? userVideo;

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

  bool tappedLikeIcon = false;
  bool tappedDislikeIcon = false;
  TextEditingController _comment = TextEditingController();
  TextEditingController _replyComment = TextEditingController();

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    widget.userVideo!.likeStatus == true ? isLiked = true : isLiked = false;
    fetchCurrentUser();

    _controller = VideoPlayerController.network(
        Constraints.Video_URL + widget.userVideo!.videoName!)
      ..initialize().then((value) {
        setState(() {
          _controller.setLooping(true);

          _controller.play();


          initialized = true;
          isLoading = false;
        });
      });
  }

  @override
  void didPopNext() {
    print("didPopNext");
    _controller.pause();

    super.didPopNext();
  }

  @override
  void didPushNext() {
    print("didPushNext");
    _controller.pause();

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
    // if (widget.pageIndex == widget.currentPageIndex &&
    //     !widget.isPaused! &&
    //     initialized) {
    //   _controller.play();
    //
    // } else {
    //   _controller.pause();
    //
    // }

    return Scaffold(
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

                                                showModalBottomSheet(context: context, builder: (_)=>Container(
                                                  color: backgroundColor,
                                                  height: MediaQuery.of(context).size.height/3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 30.0,left: 10),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                      Text('Choose Video Duration',style: TextStyle(color: Colors.white),),
                                                      TextButton(onPressed: (){
                                                        Navigator.pop(context);
                                                        Navigator.push(context, CupertinoPageRoute(builder: (_)=>AddVideo(15)));
                                                      }, child: Text('15 seconds')),
                                                      TextButton(onPressed: (){
                                                        Navigator.pop(context);
                                                        Navigator.push(context, CupertinoPageRoute(builder: (_)=>AddVideo(30)));
                                                      }, child: Text('30 seconds')),
                                                      TextButton(onPressed: (){
                                                        Navigator.pop(context);
                                                        Navigator.push(context, CupertinoPageRoute(builder: (_)=>AddVideo(60)));
                                                      }, child: Text('60 seconds')),
                                                    ],),
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

                                                User user = await ApiHandle
                                                    .fetchUser();
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
                                                                                shrinkWrap: true,
                                                                                physics: BouncingScrollPhysics(),
                                                                                itemCount: widget.userVideo!.comments!.length,
                                                                                // controller: _controller,
                                                                                itemBuilder: (context, index) {
                                                                                  return Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: <Widget>[
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
                                                                                                    Constraints.IMAGE_BASE_URL + widget.userVideo!.comments![index].image!,
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
                                                                                                        Align(alignment: Alignment.centerLeft, child: Text("@${widget.userVideo!.comments![index].name!}", style: TextStyle(color: Colors.grey, fontSize: 13))),
                                                                                                        SizedBox(
                                                                                                          height: 5,
                                                                                                        ),
                                                                                                        Align(alignment: Alignment.centerLeft, child: Text(widget.userVideo!.comments![index].comment!.trim(), style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
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
                                                                                                        commentLike(widget.userVideo!.userId!, widget.userVideo!.id!, widget.userVideo!.comments![index].id!, widget.userVideo!);
                                                                                                      },
                                                                                                      child: Icon(
                                                                                                        Icons.favorite_rounded,
                                                                                                        color: tappedLikeIcon == true ? Colors.red : Colors.white,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(widget.userVideo!.comments![index].likes!,
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
                                                                                                  padding: const EdgeInsets.only(left: 78.0),
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        '2 hrs',
                                                                                                        style: TextStyle(color: Colors.grey),
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        width: 10,
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
                                                                                                                        hint: "Replying to ${widget.userVideo!.comments![index].name!}",
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
                                                                                                                              recomment(widget.userVideo!.userId!, widget.userVideo!.comments![index].id!, widget.userVideo!, _replyComment.text);
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
                                                                                                          child: Text(
                                                                                                            'Reply',
                                                                                                            style: TextStyle(color: Colors.white),
                                                                                                          )),
                                                                                                      widget.userVideo!.comments![index].recomment!.length > 0
                                                                                                          ? TextButton(
                                                                                                              onPressed: () {
                                                                                                                showModalBottomSheet(
                                                                                                                    context: context,
                                                                                                                    builder: (_) => Container(
                                                                                                                          height: MediaQuery.of(context).size.height / 1.5,
                                                                                                                          color: backgroundColor,
                                                                                                                          child: Column(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                                                            children: [
                                                                                                                              Padding(
                                                                                                                                padding: EdgeInsets.all(20.0),
                                                                                                                                child: Text(
                                                                                                                                  "Replied Comments",
                                                                                                                                  style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Expanded(
                                                                                                                                child: Padding(
                                                                                                                                  padding: EdgeInsets.only(bottom: 100.0),
                                                                                                                                  child: ListView.builder(
                                                                                                                                      shrinkWrap: true,
                                                                                                                                      physics: BouncingScrollPhysics(),
                                                                                                                                      itemCount: widget.userVideo!.comments![index].recomment!.length,
                                                                                                                                      // controller: _controller,
                                                                                                                                      itemBuilder: (context, index) {
                                                                                                                                        return Column(
                                                                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                                          children: <Widget>[
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
                                                                                                                                                          Constraints.IMAGE_BASE_URL + widget.userVideo!.comments![index].recomment![index].image!,
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
                                                                                                                                                              Align(alignment: Alignment.centerLeft, child: Text("@${widget.userVideo!.comments![index].recomment![index].name!}", style: TextStyle(color: Colors.grey, fontSize: 13))),
                                                                                                                                                              SizedBox(
                                                                                                                                                                height: 5,
                                                                                                                                                              ),
                                                                                                                                                              Align(alignment: Alignment.centerLeft, child: Text(widget.userVideo!.comments![index].recomment![index].text!.trim(), style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
                                                                                                                                                            ],
                                                                                                                                                          ),
                                                                                                                                                        ),
                                                                                                                                                      ),
                                                                                                                                                      SizedBox(
                                                                                                                                                        width: 40,
                                                                                                                                                      ),
                                                                                                                                                      Column(
                                                                                                                                                        children: [
                                                                                                                                                          GestureDetector(
                                                                                                                                                            onTap: () {
                                                                                                                                                              // commentLike(widget.userVideo!.userId!, widget.userVideo!.id!, widget.userVideo!.comments![index].id!, widget.userVideo!);
                                                                                                                                                            },
                                                                                                                                                            child: Icon(
                                                                                                                                                              Icons.favorite_rounded,
                                                                                                                                                              color: tappedLikeIcon == true ? Colors.red : Colors.white,
                                                                                                                                                            ),
                                                                                                                                                          ),
                                                                                                                                                          Text(widget.userVideo!.comments![index].recomment![index].likes!,
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
                                                                                                                                                        padding: const EdgeInsets.only(left: 78.0),
                                                                                                                                                        child: Row(
                                                                                                                                                          children: [
                                                                                                                                                            Text(
                                                                                                                                                              '2 hrs',
                                                                                                                                                              style: TextStyle(color: Colors.grey),
                                                                                                                                                            ),
                                                                                                                                                            SizedBox(
                                                                                                                                                              width: 10,
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
                                                                                                                                                                              hint: "Replying to ${widget.userVideo!.comments![index].recomment![index].name!}",
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
                                                                                                                                                                                    recomment(widget.userVideo!.userId!, widget.userVideo!.comments![index].recomment![index].id!, widget.userVideo!, _replyComment.text);
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
                                                                                                                                                                child: Text(
                                                                                                                                                                  'Reply',
                                                                                                                                                                  style: TextStyle(color: Colors.white),
                                                                                                                                                                )),
                                                                                                                                                          ],
                                                                                                                                                        ),
                                                                                                                                                      ),
                                                                                                                                                    ],
                                                                                                                                                  ),
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
                                                                                                                        ));
                                                                                                              },
                                                                                                              child: Text(
                                                                                                                'View Replies',
                                                                                                                style: TextStyle(color: Colors.white),
                                                                                                              ))
                                                                                                          : SizedBox()
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            // videoComments[index].replyComment!.length >= 0
                                                                                            //     ? Container(
                                                                                            //         margin: EdgeInsets.only(left: 50),
                                                                                            //         child: ListView.builder(
                                                                                            //             shrinkWrap: true,
                                                                                            //             itemCount: videoComments[index].replyComment!.length,
                                                                                            //             itemBuilder: (context, i) {
                                                                                            //               return ListTile(
                                                                                            //                 leading: CircleAvatar(
                                                                                            //                   radius: 12,
                                                                                            //                   backgroundImage: NetworkImage(
                                                                                            //                     Constraints.IMAGE_BASE_URL + videoComments[index].replyComment![i].image!,
                                                                                            //                   ),
                                                                                            //                 ),
                                                                                            //                 title: Text(
                                                                                            //                   videoComments[index].replyComment![i].name!,
                                                                                            //                   style: TextStyle(color: Colors.white),
                                                                                            //                 ),
                                                                                            //                 subtitle: Text(
                                                                                            //                   videoComments[index].replyComment![i].text!,
                                                                                            //                   style: TextStyle(color: Colors.white),
                                                                                            //                 ),
                                                                                            //                 trailing: IconButton(
                                                                                            //                   icon: Icon(
                                                                                            //                     Icons.favorite,
                                                                                            //                     color: tappedDislikeIcon == true ? Colors.red : Colors.white,
                                                                                            //                     size: 20,
                                                                                            //                   ),
                                                                                            //                   onPressed: () {
                                                                                            //                     setState(() {
                                                                                            //                       tappedDislikeIcon = !tappedDislikeIcon;
                                                                                            //                     });
                                                                                            //                     MyToast(message: "Liked Successfully");
                                                                                            //                   },
                                                                                            //                 ),
                                                                                            //               );
                                                                                            //             }),
                                                                                            //       )
                                                                                            //     : SizedBox()
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
                                                                              commentVideo(widget.userVideo!.userId!, widget.userVideo!.id!, _comment.text, widget.userVideo!);
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
                                                                      return DuetPage(
                                                                        duetPlayer:
                                                                            _controller,
                                                                        videoName: widget
                                                                            .userVideo!
                                                                            .videoName!, durationofVideo: 30,
                                                                      );

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
