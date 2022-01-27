// class UserVideo {
//   late final String id;
//   late final String userId;
//   late final String audioId;
//   late final String title;
//   late final String videoName;
//   late final String userProfilePic;
//   late final String status;
//   late final String deleteStatus;
//   late final String date;

//   late final String time;
//   late final String description;
//   late final String coverImage;
//   String? likes;
//   late final String comment;
//   late final String share;
//   bool? likeStatus;
//   String? reelsView;

//   UserVideo(
//       {required this.id,
//       required this.userId,
//       required this.audioId,
//       required this.title,
//       required this.videoName,
//       required this.userProfilePic,
//       required this.status,
//       required this.deleteStatus,
//       required this.date,
//       required this.time,
//       required this.description,
//       required this.coverImage,
//       required this.likes,
//       required this.comment,
//       required this.share,
//       required this.likeStatus,
//       required this.reelsView});

//   UserVideo.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     audioId = json['audio_id'];
//     title = json['title'];
//     videoName = json['video_name'];
//     status = json['status'];
//     userProfilePic = json['image'];
//     deleteStatus = json['delete_status'];
//     date = json['date'];
//     time = json['time'];
//     description = json['description'];
//     coverImage = json['cover_image'];
//     likes = json['likes'];
//     comment = json['comment'];
//     share = json['share'];
//     likeStatus = json['like_status'];
//     reelsView = json['reels_view'];
//   }

//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['id'] = id;
//     _data['user_id'] = userId;
//     _data['audio_id'] = audioId;
//     _data['title'] = title;
//     _data['video_name'] = videoName;
//     _data['status'] = status;
//     _data['delete_status'] = deleteStatus;
//     _data['date'] = date;
//     _data['time'] = time;
//     _data['description'] = description;
//     _data['image'] = userProfilePic;
//     _data['cover_image'] = coverImage;
//     _data['likes'] = likes;
//     _data['comment'] = comment;
//     _data['share'] = share;
//     _data['like_status'] = likeStatus;
//     return _data;
//   }
// }







class UserVideos {
  String? id;
  String? userId;
  String? audioId;
  String? title;
  String? videoName;
  String? status;
  String? coverImage;
  String? description;
  String? deleteStatus;
  String? date;
  String? time;
  String? likes;
  String? comment;
  String? share;
  String? reelsView;
  bool? likeStatus;
  String? userName;
  String? image;
  List<Comments>? comments;

  UserVideos(
      {this.id,
      this.userId,
      this.audioId,
      this.title,
      this.videoName,
      this.status,
      this.coverImage,
      this.description,
      this.deleteStatus,
      this.date,
      this.time,
      this.likes,
      this.comment,
      this.share,
      this.reelsView,
      this.likeStatus,
      this.userName,
      this.image,
      this.comments});

  UserVideos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    audioId = json['audio_id'];
    title = json['title'];
    videoName = json['video_name'];
    status = json['status'];
    coverImage = json['cover_image'];
    description = json['description'];
    deleteStatus = json['delete_status'];
    date = json['date'];
    time = json['time'];
    likes = json['likes'];
    comment = json['comment'];
    share = json['share'];
    reelsView = json['reels_view'];
    likeStatus = json['like_status'];
    userName = json['userName'];
    image = json['image'];
    if (json['comments'] != null) {
      comments = <Comments>[];
      json['comments'].forEach((v) {
        comments!.add(new Comments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['audio_id'] = this.audioId;
    data['title'] = this.title;
    data['video_name'] = this.videoName;
    data['status'] = this.status;
    data['cover_image'] = this.coverImage;
    data['description'] = this.description;
    data['delete_status'] = this.deleteStatus;
    data['date'] = this.date;
    data['time'] = this.time;
    data['likes'] = this.likes;
    data['comment'] = this.comment;
    data['share'] = this.share;
    data['reels_view'] = this.reelsView;
    data['like_status'] = this.likeStatus;
    data['userName'] = this.userName;
    data['image'] = this.image;
    if (this.comments != null) {
      data['comments'] = this.comments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Comments {
  String? id;
  String? userId;
  String? videoId;
  String? comment;
  String? date;
  String? time;
  String? name;
  String? image;
  String? likes;
  List<Recomment>? recomment;

  Comments(
      {this.id,
      this.userId,
      this.videoId,
      this.comment,
      this.date,
      this.time,
      this.name,
      this.image,
      this.likes,
      this.recomment});

  Comments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    videoId = json['video_id'];
    comment = json['comment'];
    date = json['date'];
    time = json['time'];
    name = json['name'];
    image = json['image'];
    likes = json['likes'];
    if (json['recomment'] != null) {
      recomment = <Recomment>[];
      json['recomment'].forEach((v) {
        recomment!.add(new Recomment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['video_id'] = this.videoId;
    data['comment'] = this.comment;
    data['date'] = this.date;
    data['time'] = this.time;
    data['name'] = this.name;
    data['image'] = this.image;
    data['likes'] = this.likes;
    if (this.recomment != null) {
      data['recomment'] = this.recomment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Recomment {
  String? id;
  String? commentId;
  String? userId;
  String? text;
  String? dateAdded;
  String? name;
  String? image;
  String? likes;

  Recomment(
      {this.id,
      this.commentId,
      this.userId,
      this.text,
      this.dateAdded,
      this.name,
      this.image,
      this.likes});

  Recomment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    commentId = json['comment_id'];
    userId = json['user_id'];
    text = json['text'];
    dateAdded = json['date_added'];
    name = json['name'];
    image = json['image'];
    likes = json['likes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['comment_id'] = this.commentId;
    data['user_id'] = this.userId;
    data['text'] = this.text;
    data['date_added'] = this.dateAdded;
    data['name'] = this.name;
    data['image'] = this.image;
    data['likes'] = this.likes;
    return data;
  }
}

