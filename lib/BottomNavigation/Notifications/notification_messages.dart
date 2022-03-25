import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:qvid/BottomNavigation/Home/new_video_player.dart';
import 'package:qvid/Screens/custom_appbar.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/api_handle.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/model/notification.dart';
import 'package:qvid/model/user.dart';
import 'package:qvid/model/user_video.dart';
import 'package:qvid/utils/constaints.dart';
import 'package:qvid/widget/toast.dart';
import 'package:video_player/video_player.dart';

class NotificationMessages extends StatefulWidget {
  @override
  _NotificationMessagesState createState() => _NotificationMessagesState();
}

class _NotificationMessagesState extends State<NotificationMessages> {
  @override
  Widget build(BuildContext context) {
    return NotificationPage();
  }
}

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  User? userDetails;
  bool isLoading = true;
  List<Notifications> notificationList = [];
  List<UserVideos> list = [];
  @override
  void initState() {
    super.initState();
    fetchUser();
    Future.delayed(Duration(seconds: 1), () {
      fetchNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Notifications',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          body: isLoading == false
              ? notificationList.isNotEmpty
                  ? ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                            color: Colors.black,
                          ),
                      itemCount: notificationList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => VideoViewFromNotification(
                                            videoName: notificationList[index]
                                                .videoName,
                                          )));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        notificationList[index]
                                            .description!
                                            .replaceAll("#", ""),
                                        style: GoogleFonts.nunito(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '1d',
                                        style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            color: Color(0xffC7C7C7)),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    child: Image.network(
                                        'https://media.istockphoto.com/photos/3d-render-clapperboard-or-film-slate-with-play-button-picture-id1303456217?b=1&k=20&m=1303456217&s=170667a&w=0&h=Vw-tl4MdOdqYtKYddOa-mlO_opEUWs4OR8nra2Vcjfw='),
                                  )
                                ],
                              ),
                            ));
                      })
                  : Center(
                      child: Lottie.network(
                        "https://assets6.lottiefiles.com/packages/lf20_0xxka1td.json",
                      ),
                    )
              : Center(
                  child: CircularProgressIndicator.adaptive(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white)))),
    );
  }

  void fetchUser() async {
    var result = await MyPrefManager.prefInstance().getData("user");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    User userDet = await ApiHandle.fetchUser();
    //print(user.id + user.name);
    setState(() {
      userDetails = userDet;
    });
  }

  Future getVideoList() async {
    var result = await MyPrefManager.prefInstance().getData("user");

    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    List<UserVideos> userVideoList = await ApiHandle.getFollowersVideo(user.id);
    setState(() {
      isLoading = false;
      list = userVideoList;
    });
  }

  Future<List<Notifications>> fetchNotification() async {
    var result = await MyPrefManager.prefInstance().getData("user");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    Response response = await Apis().getNotification(user.id);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;
        print("sdsd");
        print(re.length);

        if (mounted)
          setState(() {
            notificationList = re
                .map<Notifications>((e) => Notifications.fromJson(e))
                .toList();
            isLoading = false;
          });

        return re.map<Notifications>((e) => Notifications.fromJson(e)).toList();
      } else {
        print("error");
        MyToast(message: msg).toast;
        setState(() {
          isLoading = false;
        });
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }
}

class VideoViewFromNotification extends StatefulWidget {
  String? videoName;
  VideoViewFromNotification({Key? key, required this.videoName})
      : super(key: key);

  @override
  State<VideoViewFromNotification> createState() =>
      _VideoViewFromNotificationState();
}

class _VideoViewFromNotificationState extends State<VideoViewFromNotification> {
  late VideoPlayerController videoPlayController;

  @override
  void initState() {
    videoPlayController =
        VideoPlayerController.network(Constraints.Video_URL + widget.videoName!)
          ..initialize().then((value) {
            setState(() {
              videoPlayController.addListener(() {});
            });
            videoPlayController.play();
            videoPlayController.setLooping(true);
          });
    super.initState();
  }

  @override
  void dispose() {
    videoPlayController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        Opacity(opacity: 0.8, child: VideoPlayer(videoPlayController)),
      ]),
    ));
  }
}
