import 'package:flutter/material.dart';

class ShortFilmPage extends StatefulWidget {
  ShortFilmPage({Key? key}) : super(key: key);

  @override
  State<ShortFilmPage> createState() => _ShortFilmPageState();
}

class _ShortFilmPageState extends State<ShortFilmPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('CLAP Films'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new)),
        ),
        body: VideoList(
          listData: youtubeData,
        ));
  }
}

// video list api

class VideoDetail extends StatefulWidget {
  final YoutubeModel detail;

  const VideoDetail({Key? key, required this.detail}) : super(key: key);

  @override
  _VideoDetailState createState() => _VideoDetailState();
}

class _VideoDetailState extends State<VideoDetail> {
  @override
  Widget build(BuildContext context) {
    List<Widget> _layouts = [
      _videoInfo(),
      _channelInfo(),
      _moreInfo(),
      VideoList(
        listData: youtubeData,
        isMiniList: true,
      ),
    ];

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      _layouts.clear();
    }

    return Scaffold(
        body: Column(
      children: <Widget>[
        _buildVideoPlayer(context),
        Expanded(
          child: ListView(
            children: _layouts,
          ),
        )
      ],
    ));
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return Container(
      margin: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? 200.0
          : MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(widget.detail.thumbNail!),
              fit: BoxFit.cover)),
    );
  }

  Widget _videoInfo() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(widget.detail.title!),
          subtitle: Text(widget.detail.viewCount!),
          trailing: Icon(Icons.arrow_drop_down),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildButtonColumn(Icons.thumb_up, widget.detail.likeCount!),
              _buildButtonColumn(Icons.thumb_down, widget.detail.dislikeCount!),
              _buildButtonColumn(Icons.share, "Share"),
              _buildButtonColumn(Icons.cloud_download, "Download"),
              _buildButtonColumn(Icons.playlist_add, "Save"),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildButtonColumn(IconData icon, String text) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Icon(
            icon,
            color: Colors.grey[700],
          ),
        ),
        Text(
          text,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _channelInfo() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.detail.channelAvatar!),
              ),
              title: Text(
                widget.detail.channelTitle!,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text("15,000 subscribers"),
            ),
          ),
          FlatButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
              ),
              label: Text(
                "SUBSCRIBE",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }

  bool isOn = false;
  Widget _moreInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              child: Text(
            "Up next",
            style: TextStyle(color: Colors.white),
          )),
          Text(
            "Autoplay",
            style: TextStyle(color: Colors.white),
          ),
          Switch(
            activeColor: Colors.red,
            onChanged: (c) {
              setState(() {
                isOn = !isOn;
              });
            },
            value: isOn,
          ),
        ],
      ),
    );
  }
}

class YoutubeModel {
  final String? title;
  final String? description;
  final String? thumbNail;
  final String? publishedTime;
  final String? channelTitle;
  final String? channelAvatar;
  final String? viewCount;
  final String? likeCount;
  final String? dislikeCount;

  YoutubeModel(
      {this.title,
      this.description,
      this.thumbNail,
      this.publishedTime,
      this.channelTitle,
      this.channelAvatar,
      this.viewCount,
      this.likeCount,
      this.dislikeCount});
}

List<YoutubeModel> youtubeData = [
  YoutubeModel(
    title: "DJ Snake - Taki Taki ft. Selena Gomez, Ozuna, Cardi B",
    description:
        "DJ Snake - Taki Taki ft. Selena Gomez, Ozuna, Cardi takes you on a ride",
    thumbNail:
        "https://i.ytimg.com/vi/ixkoVwKQaJg/hqdefault.jpg?sqp=-oaymwEZCNACELwBSFXyq4qpAwsIARUAAIhCGAFwAQ==&rs=AOn4CLDrYjizQef0rnqvBc0mZyU3k13yrg",
    publishedTime: "2 weeks ago",
    channelTitle: "DJ Snake",
    channelAvatar:
        "https://yt3.ggpht.com/a-/AN66SAzkcvkwVn1Y5Zdpb1jkn9zyJ7vGxO8qHBxCTg=s288-mo-c-c0xffffffff-rj-k-no",
    viewCount: "50M views",
    likeCount: "34K",
    dislikeCount: "2K",
  ),
  YoutubeModel(
    title: "Pixel 3 XL Second Impression: Notch City!",
    description: "Marques Brownlee gives his opinion on Pixel 3 XL",
    thumbNail:
        "https://i.ytimg.com/vi/Lg9N8XAZ6u4/hqdefault.jpg?sqp=-oaymwEZCNACELwBSFXyq4qpAwsIARUAAIhCGAFwAQ==&rs=AOn4CLC5n3UMS9pjWuzugjML9AcoqbEMOA",
    publishedTime: "16 hours ago",
    channelTitle: "Marqueus Brownlee",
    channelAvatar:
        "https://yt3.ggpht.com/a-/AN66SAwxVf-12cuqSiSP2HKPkpDqI0NCAghAiE7IVg=s288-mo-c-c0xffffffff-rj-k-no",
    viewCount: "917K views",
    likeCount: "20k",
    dislikeCount: "51",
  ),
  YoutubeModel(
    title: "Eminem - Venom",
    description:
        "Listen to Venom (Music From The Motion Picture), out now: http://smarturl.it/EminemVenom",
    thumbNail:
        "https://i.ytimg.com/vi/8CdcCD5V-d8/hqdefault.jpg?sqp=-oaymwEZCNACELwBSFXyq4qpAwsIARUAAIhCGAFwAQ==&rs=AOn4CLA7A5_7k458KMkDNG0sweixgq856g",
    publishedTime: "6 days ago",
    channelTitle: "EminemMusic",
    channelAvatar:
        "https://yt3.ggpht.com/-qtnbIDAbSNQ/AAAAAAAAAAI/AAAAAAAAAJc/Zt6FE6ofr1I/s88-nd-c-c0xffffffff-rj-k-no/photo.jpg",
    viewCount: "53M views",
    likeCount: "20k",
    dislikeCount: "51",
  ),
];

class VideoList extends StatelessWidget {
  final List<YoutubeModel> listData;
  final bool isMiniList;
  final bool isHorizontalList;

  const VideoList(
      {required this.listData,
      this.isMiniList = false,
      this.isHorizontalList = false});

  @override
  Widget build(BuildContext context) {
    final deviceOrientation = MediaQuery.of(context).orientation;
    if (isHorizontalList) {
      return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        scrollDirection: Axis.horizontal,
        itemCount: listData.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => VideoDetail(
                  detail: listData[index],
                ),
              ));
            },
            child: _buildHorizontalList(context, index),
          );
        },
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          if (isMiniList || deviceOrientation == Orientation.landscape) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => VideoDetail(
                    detail: listData[index],
                  ),
                ));
              },
              child: _buildLandscapeList(context, index),
            );
          } else {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => VideoDetail(
                    detail: listData[index],
                  ),
                ));
              },
              child: _buildPortraitList(context, index),
            );
          }
        },
        separatorBuilder: (context, index) => Divider(
          height: 1.0,
          color: Colors.grey,
        ),
        itemCount: listData.length,
      );
    }
  }

  Widget _buildPortraitList(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: 200.0,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(listData[index].thumbNail!),
                fit: BoxFit.cover),
          ),
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          dense: true,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(listData[index].channelAvatar!),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(listData[index].title!),
          ),
          subtitle: Text(
              "${listData[index].channelTitle} . ${listData[index].viewCount} . ${listData[index].publishedTime}"),
          trailing: Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Icon(Icons.more_vert)),
        ),
      ],
    );
  }

  Widget _buildLandscapeList(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: <Widget>[
          Container(
//          width: MediaQuery.of(context).size.width / 2,
            width: isMiniList
                ? MediaQuery.of(context).size.width / 2
                : 336.0 / 1.5,
            height: isMiniList ? 100.0 : 188.0 / 1.5,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(listData[index].thumbNail!),
                  fit: BoxFit.cover),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  dense: isMiniList ? true : false,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(listData[index].title!),
                  ),
                  subtitle: !isMiniList
                      ? Text(
                          "${listData[index].channelTitle} . ${listData[index].viewCount} . ${listData[index].publishedTime}")
                      : Text(
                          "${listData[index].channelTitle} . ${listData[index].viewCount}"),
                  trailing: Container(
                      margin: const EdgeInsets.only(bottom: 30.0),
                      child: Icon(Icons.more_vert)),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: !isMiniList
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(listData[index].channelAvatar!),
                        )
                      : SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, int index) {
    return Container(
      width: 336.0 / 2.2,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 4.0),
            width: 336.0 / 2.2,
            height: 188 / 2.2,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(listData[index].thumbNail!),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        listData[index].title!,
                        style: TextStyle(fontSize: 12.0),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      listData[index].channelTitle!,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.more_vert,
                size: 16.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
