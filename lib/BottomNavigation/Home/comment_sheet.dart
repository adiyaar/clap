import 'dart:async';
import 'dart:convert';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:qvid/BottomNavigation/Home/video_comment_controller.dart';
import 'package:qvid/Components/entry_field.dart';

import 'package:qvid/Theme/colors.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/model/user.dart';
import 'package:qvid/model/user_video.dart';
import 'package:qvid/model/video_comment.dart';
import 'package:qvid/utils/constaints.dart';
import 'package:qvid/widget/toast.dart';

class Comment {
  final String? image;
  final String? name;
  final String? comment;
  final String? time;

  Comment({this.image, this.name, this.comment, this.time});
}

TextEditingController _comment = TextEditingController();
TextEditingController _replyComment = TextEditingController();
bool isComment = false;
bool tappedLike = false;
bool tappeddislike = false;
ScrollController _controller = ScrollController();
void commentSheet(BuildContext context, [User? user, UserVideos? video]) async {
  // List<VideoComment> comments = await getVideoComment(video!.id);
  var contr = Get.put(UserVideoComment());
  print(video!.userId);
  contr.setUserId(video.id!);

  await showModalBottomSheet(
      //enableDrag: true,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          borderSide: BorderSide.none),
      context: context,
      builder: (context) => Container(
            height: MediaQuery.of(context).size.height / 1.5,
            child: Stack(
              children: <Widget>[
                FadedSlideAnimation(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "Comments",
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      Expanded(
                          child: Obx(
                        () => Padding(
                          padding: EdgeInsets.only(bottom: 100.0),
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: contr.commentList.value.length,
                              controller: _controller,
                              itemBuilder: (context, index) {
                                //print(comments[index].date);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    /* Divider(
                                      color: darkColor,
                                      thickness: 1,
                                    ), */
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                            Constraints.IMAGE_BASE_URL +
                                                contr.commentList[index].image!,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(right: 5),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade900,
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(25),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                )),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        contr.commentList[index]
                                                            .name!,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2!
                                                            .copyWith(
                                                                height: 2,
                                                                color: Colors
                                                                    .white))
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  contr.commentList[index]
                                                      .comment!,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                    /* ListTile(
                                      leading: Image.network(
                                        Constraints.IMAGE_BASE_URL +
                                            comments[index].image!,
                                        scale: 2.3,
                                      ),
                                      title: Text(comments[index].name!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                  height: 2,
                                                  color: disabledTextColor)),
                                      subtitle: RichText(
                                        text: TextSpan(children: [
                                          TextSpan(
                                            text: comments[index].comment,
                                          ),
                                          TextSpan(
                                              text: comments[index].time,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption),
                                        ]),
                                      ),
                                      trailing: ImageIcon(
                                        AssetImage('assets/icons/ic_like.png'),
                                        color: disabledTextColor,
                                      ),
                                    ), */
                                    ,
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 60.0, top: 7),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    // tappeddislike = !tappeddislike;

                                                    // print(tappeddislike);

                                                    print('h');
                                                    print(tappedLike);
                                                    commentLike(
                                                        video.userId!,
                                                        video.id!,
                                                        contr.commentList[index]
                                                            .id,
                                                        video);
                                                  },
                                                  icon: Icon(
                                                    Icons.thumb_up,
                                                    color: Colors.white,
                                                  )),
                                              Text(
                                                  contr.commentList[index]
                                                      .likesCount,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  )),
                                              TextButton(
                                                  onPressed: () {
                                                    showModalBottomSheet(
                                                        context: context,
                                                        builder:
                                                            (_) => Container(
                                                                  color:
                                                                      backgroundColor,
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  child:
                                                                      EntryField(
                                                                    controller:
                                                                        _replyComment,
                                                                    counter:
                                                                        null,
                                                                    padding: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets,
                                                                    hint:
                                                                        "Replying to ${contr.commentList[index].name!}",
                                                                    fillColor: Colors
                                                                        .grey
                                                                        .shade100,
                                                                    prefix:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              16.0,
                                                                          vertical:
                                                                              8.0),
                                                                      child: user!
                                                                              .image
                                                                              .isEmpty
                                                                          ? CircleAvatar(
                                                                              backgroundImage: AssetImage('assets/images/user.webp'),
                                                                            )
                                                                          : CircleAvatar(
                                                                              backgroundImage: NetworkImage(Constraints.IMAGE_BASE_URL + user.image),
                                                                            ),
                                                                    ),
                                                                    suffixIcon:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        if (validRecomment()) {
                                                                          //isComment = true;
                                                                          _replyComment.text =
                                                                              "";
                                                                          FocusScope.of(context)
                                                                              .unfocus();
                                                                          recomment(
                                                                              video.userId!,
                                                                              contr.commentList[index].id,
                                                                              video,
                                                                              replycomment!);

                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .send,
                                                                        color:
                                                                            mainColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ));
                                                  },
                                                  child: Text(
                                                    'Reply',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )),
                                              // contr
                                              //                 .commentList[index]
                                              //                 .replyComment[0]
                                              //                 .commentId ==
                                              //             null ||
                                              //         contr.commentList[index]
                                              //                 .replyComment ==
                                              //             0
                                              //     ? Text("")
                                              //     : Text(
                                              //         contr.commentList[index]
                                              //             .replyComment[0].text,
                                              //         style: TextStyle(
                                              //             color: Colors.white),
                                              //       )
                                            ],
                                          ),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: contr
                                                  .commentList[index]
                                                  .replyComment
                                                  .length,
                                              itemBuilder: (context, i) {
                                                return ListTile(
                                                  title: Text(
                                                    contr.commentList[index]
                                                        .replyComment[i].text,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  subtitle: Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                            Icons.thumb_up,
                                                            color:
                                                                Colors.white),
                                                        onPressed: null,
                                                      ),
                                                      Text(
                                                        contr
                                                            .commentList[index]
                                                            .replyComment[i]
                                                            .likes,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              })
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              }),
                        ),
                      ))
                    ],
                  ),
                  beginOffset: Offset(0, 0.3),
                  endOffset: Offset(0, 0),
                  slideCurve: Curves.linearToEaseOut,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      Timer(
                          Duration(milliseconds: 300),
                          () => _controller
                              .jumpTo(_controller.position.maxScrollExtent));
                    },
                    child: EntryField(
                      controller: _comment,
                      counter: null,
                      padding: MediaQuery.of(context).viewInsets,
                      hint: "Write Your comment",
                      fillColor: Colors.grey.shade100,
                      prefix: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: user!.image.isEmpty
                            ? CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/user.webp'),
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(
                                    Constraints.IMAGE_BASE_URL + user.image),
                              ),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          if (valid()) {
                            //isComment = true;
                            _comment.text = "";
                            FocusScope.of(context).unfocus();
                            commentVideo(
                                video.userId!, video.id!, comment!, video);
                          }
                        },
                        child: Icon(
                          Icons.send,
                          color: mainColor,
                        ),
                      ),
                    ),
                  ),
                ),
                /*  Align(
                    alignment: Alignment.center,
                    child: isComment == true
                        ? SpinKitFadingCircle(
                            color: buttonColor,
                            size: 60,
                          )
                        : Container()), */
              ],
            ),
          ));

//comment video
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

Future<void> commentVideo(
    String userId, String videoId, String comment, UserVideos video) async {
  print(userId + videoId + comment);
  var result = await MyPrefManager.prefInstance().getData("user");
  User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
  dynamic response = await Apis().commentVideo(user.id, videoId, comment);
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    String res = data['res'];

    String msg = data['msg'];
    if (res == "success") {
      MyToast(message: msg).toast;
      isComment = false;

      Get.find<UserVideoComment>().setUserId(video.id!);
    } else {
      MyToast(message: msg).toast;
    }
  } else {
    MyToast(message: "Server Errror");
  }
}

Future<void> commentLike(
    String userId, String videoId, String commentId, UserVideos video) async {
  print(userId + videoId + commentId);
  var result = await MyPrefManager.prefInstance().getData("user");
  User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
  dynamic response = await Apis().commentLike(user.id, videoId, commentId);
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    String res = data['res'];

    String msg = data['msg'];
    if (res == "success") {
      MyToast(message: msg).toast;
      // isComment = false;
      tappedLike = true;
      Get.find<UserVideoComment>().setUserId(video.id!);
      // Timer(Duration(milliseconds: 300),
      //     () => _controller.jumpTo(_controller.position.maxScrollExtent));
    } else {
      MyToast(message: msg).toast;
    }
  } else {
    MyToast(message: "Server Errror");
  }
}

Future<void> recomment(String userId, String commentId, UserVideos video,
    String replyingComment) async {
  print(userId + commentId);
  var result = await MyPrefManager.prefInstance().getData("user");
  User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
  dynamic response =
      await Apis().recomment(user.id, replyingComment, commentId);
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    String res = data['res'];

    String msg = data['msg'];
    if (res == "success") {
      MyToast(message: msg).toast;
      // isComment = false;

      Get.find<UserVideoComment>().setUserId(video.id!);
      // Timer(Duration(milliseconds: 300),
      //     () => _controller.jumpTo(_controller.position.maxScrollExtent));
    } else {
      MyToast(message: msg).toast;
    }
  } else {
    MyToast(message: "Server Errror");
  }
}

Future<List<VideoComment>> getVideoComment(String videoId) async {
  dynamic response = await Apis().getVideoComment(videoId);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    String res = data['res'];
    String msg = data['msg'];
    if (res == "success") {
      var re = data['data'] as List;

      return re.map<VideoComment>((e) => VideoComment.fromJson(e)).toList();
    } else {
      print("error");
      MyToast(message: msg).toast;
      return [];
    }
  } else {
    throw Exception('Failed to load album');
  }
}

String? comment;
bool valid() {
  comment = _comment.text;
  if (comment!.isEmpty) {
    MyToast(message: "Please Write Your comment").toast;
    print("dsdsd");
    return false;
  } else {
    return true;
  }
}

String? replycomment;
bool validRecomment() {
  replycomment = _replyComment.text;
  if (replycomment!.isEmpty) {
    MyToast(message: "Please Write Your comment").toast;

    return false;
  } else {
    return true;
  }
}
