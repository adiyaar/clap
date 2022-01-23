class VideoComment {
  String? id;
  String? userId;
  String? videoId;
  String? comment;
  String? date;
  String? time;
  String? name;
  String? image;
  String? likesCount;
  List<ReplyComment>? replyComment;

  VideoComment(
      {this.id,
      this.userId,
      this.videoId,
      this.comment,
      this.date,
      this.time,
      this.name,
      this.likesCount,
      this.replyComment,
      this.image});

  VideoComment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    videoId = json['video_id'];
    comment = json['comment'];
    date = json['date'];
    likesCount = json['likes'];
    time = json['time'];
    name = json['name'];
    image = json['image'];
    if (json['recomment'] != null) {
      replyComment = <ReplyComment>[];
      json['recomment'].forEach((v) {
        replyComment!.add(new ReplyComment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['video_id'] = this.videoId;
    data['comment'] = this.comment;
    data['likes'] = this.likesCount;
    data['date'] = this.date;
    data['time'] = this.time;
    data['name'] = this.name;
    data['image'] = this.image;
    if (this.replyComment != null) {
      data['recomment'] = this.replyComment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReplyComment {
   String? id;
  String? commentId;
  String? userId;
  String? text;
  String? dateAdded;
  String? name;
  String? image;
  String? likes;

  ReplyComment(
      {this.id,
      this.commentId,
      this.userId,
      this.text,
      this.dateAdded,
      this.name,
      this.image,
      this.likes});

  ReplyComment.fromJson(Map<String, dynamic> json) {
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
