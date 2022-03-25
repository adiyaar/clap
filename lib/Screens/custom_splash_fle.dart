import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/IntroScreens/IntroScreen.dart';
import 'package:qvid/Screens/chat/chat_controller.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/main.dart';
import 'package:qvid/model/user.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class MySplashFile extends StatefulWidget {
  const MySplashFile({Key? key}) : super(key: key);
  @override
  State<MySplashFile> createState() => _MySplashFileState();
}

class _MySplashFileState extends State<MySplashFile> {
  ChatController chatController = Get.put(ChatController());
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      DateTime now = DateTime.now();
      var currentTime = now.hour.toString() + ":" + now.minute.toString();

      chatController.receiveMessage(
          message.notification!.body, "1", currentTime);
    });
    Future.delayed(Duration(seconds: 2), () {
      hanldleNavigation(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarBrightness:
            Brightness.light //or set color with: Color(0xFF0000FF)
        ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset(
              "assets/images/splash_logo.png",
              height: 150,
              width: 150,
            ),
          ),
        ));
  }

  hanldleNavigation(BuildContext context) async {
    var result = await MyPrefManager.prefInstance().getData("user");
    var introScreenSaw = await MyPrefManager.prefInstance().getData("intro");
    print(result);
    if (result == null && introScreenSaw == null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => WelcomeScreen()), (route) => false);
    } else if (result == null && introScreenSaw == "true") {
      Navigator.pushNamedAndRemoveUntil(
          context, PageRoutes.login_screen, (route) => false);
    } else {
      User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
      if (user.otpStatus == "true") {
        http.Response response = await Apis().getUser(user.id);
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          print(data);
          String res = data['res'];
          if (res == "success") {
            User user = User.fromMap(data['data'] as Map<String, dynamic>);
            //update shareprefernce

            bool result = await MyPrefManager.prefInstance()
                .addData("user", jsonEncode(data['data']));

            if (user.name.isEmpty) {
              print("sdsd ${user.name}");
              Navigator.of(context).pushNamedAndRemoveUntil(
                  PageRoutes.personal_info, (route) => false);
            } /* else if (user.talent.isEmpty || user.interest.isEmpty) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  PageRoutes.choose_talent, (route) => false);
            } /*  else if (user.youtubeLink.isEmpty || user.instagramLink.isEmpty) {
              */ Navigator.of(context).pushNamedAndRemoveUntil(
                  PageRoutes.social_media_info, (route) => false);
            } */
            else if (user.bio.isEmpty || user.image.isEmpty) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  PageRoutes.basic_profile_info, (route) => false);
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  PageRoutes.mycontainer, (route) => false);
            }
          } else {}
        } else {}
      } else {}
    }
  }
}
