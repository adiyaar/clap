import 'dart:convert';

import 'package:http/http.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/model/audio.dart';
import 'package:qvid/model/user.dart';
import 'package:qvid/model/user_video.dart';
import 'package:qvid/widget/toast.dart';

class ApiHandle {
  static Future fetchUser() async {
    var result = await MyPrefManager.prefInstance().getData("user");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);

    Response response = await Apis().getUser(user.id);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        User user = User.fromMap(data['data'] as Map<String, dynamic>);
        return user;
        //update shareprefernce
      } else {
        MyToast(message: msg).toast;
        return "";
      }
    }
  }

  static Future<User?> getUserById(String userId) async {
    User? user;
    Response response = await Apis().getUser(userId);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        user = User.fromMap(data['data'] as Map<String, dynamic>);
        return user;
        //update shareprefernce
      } else {
        user = null;
        return user;
      }
    } else {
      return user;
    }
  }

  //get Video
  //get User Video
  static Future<List<UserVideos>> getVideo(String userId) async {
    Response response = await Apis().getVideo(userId);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;

        print(re.length);

        return re.map<UserVideos>((e) => UserVideos.fromJson(e)).toList();
        

      } else {
        print("error");
        MyToast(message: msg).toast;
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }

  static Future<List<UserVideos>> getLikedVideo(String userId) async {
    Response response = await Apis().getLikedVideo(userId);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;
        print("sdsd");
        print(re.length);

        return re.map<UserVideos>((e) => UserVideos.fromJson(e)).toList();
        //return MySlider.fromJson(data['data'] as Map<String, dynamic>);
        /* for (int i = 0; i < sliders.length; i++) {
          MySlider slider = sliders[i];
          sliderImage[i] = slider.image;
        } */

      } else {
        print("error");
        MyToast(message: msg).toast;
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }

  static Future<List<UserVideos>> getFollowersVideo(String userId) async {
    Response response = await Apis().getFollowersVideo(userId);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;

        print(re.length);

        return re.map<UserVideos>((e) => UserVideos.fromJson(e)).toList();
      } else {
        print("error");
        MyToast(message: msg).toast;
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }

  static Future getCount(String countOf, String videoId) async {
    Response response = await Apis().getCount(countOf, videoId);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        print(data);

        //return MySlider.fromJson(data['data'] as Map<String, dynamic>);
        /* for (int i = 0; i < sliders.length; i++) {
          MySlider slider = sliders[i];
          sliderImage[i] = slider.image;
        } */

      } else {
        MyToast(message: msg).toast;
        return [];
      }
    }
  }

  static Future<List<UserVideos>> getReleatedVideo(
      String userId, String gender) async {
    Response response = await Apis().getRelatedVideo(userId, gender);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;

        return re.map<UserVideos>((e) => UserVideos.fromJson(e)).toList();
        //return MySlider.fromJson(data['data'] as Map<String, dynamic>);
        /* for (int i = 0; i < sliders.length; i++) {
          MySlider slider = sliders[i];
          sliderImage[i] = slider.image;
        } */

      } else {
        print("error");
        MyToast(message: msg).toast;
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }
  // like video

  static Future<List<Audio>> getNewReleaseAudio() async {
    Response response = await Apis().getNewAudio();
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;
        print("sdsd");
        print(re.length);

        return re.map<Audio>((e) => Audio.fromJson(e)).toList();
        //return MySlider.fromJson(data['data'] as Map<String, dynamic>);
        /* for (int i = 0; i < sliders.length; i++) {
          MySlider slider = sliders[i];
          sliderImage[i] = slider.image;
        } */

      } else {
        print("error");
        MyToast(message: msg).toast;
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }
}
