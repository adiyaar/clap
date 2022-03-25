import 'dart:convert';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:animation_wrappers/Animations/faded_slide_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:qvid/BottomNavigation/MyProfile/applied_job_list.dart';
import 'package:qvid/BottomNavigation/MyProfile/booking/mybooking.dart';
import 'package:qvid/BottomNavigation/MyProfile/mypost_list.dart';
import 'package:qvid/BottomNavigation/MyProfile/show_gallery.dart';
import 'package:qvid/Components/tab_grid.dart';
import 'package:qvid/Components/row_item.dart';
import 'package:qvid/Components/sliver_app_delegate.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:intl/intl.dart';
import 'package:qvid/Screens/auth/show_periosnal_info.dart';
import 'package:qvid/Screens/custom_appbar.dart';
import 'package:qvid/Theme/colors.dart';

import 'package:qvid/BottomNavigation/MyProfile/edit_profile.dart';
import 'package:qvid/BottomNavigation/MyProfile/followers.dart';

import 'package:qvid/BottomNavigation/MyProfile/following.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/api_handle.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/model/user.dart' as use;
import 'package:qvid/model/user.dart';
import 'package:qvid/model/user_video.dart';
import 'package:qvid/utils/constaints.dart';
import 'package:qvid/widget/toast.dart';

class MyProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyProfileBody();
  }
}

class MyProfileBody extends StatefulWidget {
  @override
  _MyProfileBodyState createState() => _MyProfileBodyState();
}

class _MyProfileBodyState extends State<MyProfileBody>
    with WidgetsBindingObserver {
  use.User? userDtails;
  bool isLoading = true;
  List<UserVideos>? list;
  List<UserVideos> likedVideo = [];
  bool isCelebrity = false;
  String age = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    Future.delayed(Duration(seconds: 1), () {
      fetchUser();
    });
    //onResume();
  }

  final key = UniqueKey();
  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  late AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("app lifecycle");
    setState(() {
      _notification = state;
      print("notificaton: $_notification");
    });
    if (state == AppLifecycleState.resumed) {
      Future.delayed(Duration(seconds: 1), () {
        fetchUser();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
              child: Container(
                  margin: EdgeInsets.only(top: 0),
                  child: MyCustomAppBar(context: context, user: userDtails)
                      .myCustomAppBar),
              preferredSize: Size.fromHeight(100)),
          body: Stack(
            children: [
              DefaultTabController(
                length: 4,
                child: SafeArea(
                  child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          automaticallyImplyLeading: false,
                          expandedHeight: 220.4,
                          floating: false,
                          stretch: true,
                          actions: <Widget>[
                            Theme(
                              data: Theme.of(context).copyWith(
                                cardColor: backgroundColor,
                              ),
                              child: Container(
                                child: Text(""),
                              ),
                            )
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            background: Card(
                              color: cardColor,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: <Widget>[
                                                userDtails != null
                                                    ? CircleAvatar(
                                                        radius: 40.0,
                                                        backgroundImage:
                                                            NetworkImage(Constraints
                                                                    .IMAGE_BASE_URL +
                                                                userDtails!
                                                                    .image))
                                                    : CircleAvatar(
                                                        radius: 40.0,
                                                        backgroundImage: AssetImage(
                                                            'assets/images/user_icon.png'),
                                                      ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        userDtails == null
                                                            ? 'New user'
                                                            : userDtails!.name,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        userDtails == null
                                                            ? '@newusercategory'
                                                            : userDtails!
                                                                .userCategoryName,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        userDtails == null
                                                            ? 'age'
                                                            : "$age year",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfile()),
                                              ).then((value) => {
                                                    Future.delayed(
                                                        Duration(seconds: 1),
                                                        () {
                                                      fetchUser();
                                                    })
                                                  });
                                            },
                                            child: Card(
                                              elevation: 5,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                          /* GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  PageRoutes.setting_page);
                                            },
                                            child: Card(
                                              elevation: 5,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                child: Icon(
                                                  Icons.settings,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ) */
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: buttonColor,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyPostList(
                                                            userid:
                                                                userDtails!.id,
                                                          )));
                                            },
                                            child: Card(
                                              color: backgroundColor,
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: RowItem(
                                                    userDtails != null
                                                        ? "${userDtails!.postCount}"
                                                        : "0",
                                                    "My Jobs"),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FollowersPage(
                                                            userId:
                                                                userDtails!.id,
                                                          )));
                                            },
                                            child: Card(
                                              color: backgroundColor,
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: RowItem(
                                                    userDtails != null
                                                        ? '${userDtails!.followersTotal}'
                                                        : "0",
                                                    "Followers"),
                                              ),
                                            ),
                                          ),
                                          /*   Visibility(
                                            visible: isCelebrity == true
                                                ? true
                                                : false,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyBooking()));
                                              },
                                              child: Card(
                                                color: backgroundColor,
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(
                                                          10.0),
                                                  child: RowItem(
                                                      userDtails != null
                                                          ? '${userDtails!.bookingCount}'
                                                          : "0",
                                                      "Booking"),
                                                ),
                                              ),
                                            ),
                                          ), */
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FollowingPage(
                                                            userId:
                                                                userDtails!.id,
                                                          )));
                                            },
                                            child: Card(
                                              color: backgroundColor,
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: RowItem(
                                                    userDtails != null
                                                        ? '${userDtails!.followingTotal}'
                                                        : "0",
                                                    "Following"),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AppliedJobList(
                                                            userid:
                                                                userDtails!.id,
                                                          )));
                                            },
                                            child: Card(
                                              color: backgroundColor,
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: RowItem(
                                                  userDtails != null
                                                      ? userDtails!
                                                          .appliedJobCount!
                                                      : "0",
                                                  "Applied Jobs",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                          delegate: SliverAppBarDelegate(
                            TabBar(
                              labelColor: buttonColor,
                              unselectedLabelColor: Colors.white,
                              indicatorColor: color1,
                              tabs: [
                                Tab(icon: Icon(Icons.person)),
                                Tab(icon: Icon(Icons.video_library_sharp)),
                                Tab(icon: Icon(Icons.favorite_border)),
                                Tab(icon: Icon(Icons.medication_sharp))
                              ],
                            ),
                          ),
                          pinned: true,
                        ),
                      ];
                    },
                    body: isLoading == true
                        ? SpinKitFadingCircle(
                            color: buttonColor,
                          )
                        : TabBarView(
                            children: <Widget>[
                              FadedSlideAnimation(
                                ShowPersonalInfo(
                                  data: {"i": 2, "id": "12"},
                                ),
                                beginOffset: Offset(0, 0.3),
                                endOffset: Offset(0, 0),
                                slideCurve: Curves.linearToEaseOut,
                              ),
                              FadedSlideAnimation(
                                TabGrid(
                                  list,
                                  icon: Icons.favorite,
                                  context: context,
                                  userId: userDtails!.id,
                                ),
                                beginOffset: Offset(0, 0.3),
                                endOffset: Offset(0, 0),
                                slideCurve: Curves.linearToEaseOut,
                              ),
                              FadedSlideAnimation(
                                TabGrid(
                                  likedVideo,
                                  icon: Icons.bookmark,
                                  context: context,
                                  userId: userDtails!.id,
                                ),
                                beginOffset: Offset(0, 0.3),
                                endOffset: Offset(0, 0),
                                slideCurve: Curves.linearToEaseOut,
                              ),
                              FadedSlideAnimation(
                                ShowGallery(
                                  i: 1,
                                  userId: "",
                                ),
                                beginOffset: Offset(0, 0.3),
                                endOffset: Offset(0, 0),
                                slideCurve: Curves.linearToEaseOut,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchUser() async {
    var result = await MyPrefManager.prefInstance().getData("user");
    use.User user =
        use.User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    Response response = await Apis().getUser(user.id);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        use.User user = use.User.fromMap(data['data'] as Map<String, dynamic>);
        if (this.mounted) {
          setState(() {
            userDtails = user;
            getAge(userDtails);
            getVideoList(userDtails!.id);
            getLikedVideoList(userDtails!.id);

            isLoading = false;
            userDtails!.celebrity == "true"
                ? isCelebrity = true
                : isCelebrity = false;

            //ShowPersonalInfo.user = userDtails;
          });
        }

        //update shareprefernce
      } else {
        MyToast(message: msg).toast;
        isLoading = false;
      }
    }
  }

  //getVideo
  Future getVideoList(String userId) async {
    print("reels calls");
    List<UserVideos> userVideoList = await ApiHandle.getVideo(userId);
    print(" Length is ${userVideoList.length}");
    if (mounted) {
      setState(() {
        list = userVideoList;
      });
    }
  }

  Future getLikedVideoList(String userId) async {
    List<UserVideos> userVideoList = await ApiHandle.getLikedVideo(userId);
    if (mounted) {
      setState(() {
        likedVideo = userVideoList;

        print(" Length is ${list!.length}");
      });
    }
  }

  void getAge(use.User? userDtails) {
    //DateTime birthDate = ;
    DateTime today = DateTime.now();
    DateFormat dateFormat = DateFormat("dd MMM yyyy");
    var dobDate = dateFormat.parse(userDtails!.dob);
    int yearDiff = today.year - dobDate.year;

    if (yearDiff < 1) {
      MyToast(message: "You are not eligible").toast;
    } else {
      setState(() {
        age = "$yearDiff";
      });
    }
    print(yearDiff);
  }
}

Widget profileHeaderWidget(BuildContext context) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(color: Colors.black),
    child: Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xff74EDED),
                backgroundImage:
                    NetworkImage("https://placeimg.com/640/480/people"),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Text(
                        "23",
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Posts",
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Column(
                    children: [
                      Text(
                        "1.5M",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Followers",
                        style: TextStyle(
                          letterSpacing: 0.4,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Column(
                    children: [
                      Text(
                        "234",
                        style: TextStyle(
                          letterSpacing: 0.4,
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Following",
                        style: TextStyle(
                          letterSpacing: 0.4,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "John Doe",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            "Lorem Ipsum",
            style: TextStyle(
              letterSpacing: 0.4,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          actions(context),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    ),
  );
}

Widget actions(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: OutlinedButton(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text("Edit Profile", style: TextStyle(color: Colors.white)),
          ),
          style: OutlinedButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size(0, 30),
              side: BorderSide(
                color: Colors.grey.shade400,
              )),
          onPressed: () {},
        ),
      ),
    ],
  );
}

class ProfileBaseScreen extends StatefulWidget {
  final User? userDetails;
  ProfileBaseScreen({Key? key, required this.userDetails}) : super(key: key);

  @override
  _ProfileBaseScreenState createState() => _ProfileBaseScreenState();
}

class _ProfileBaseScreenState extends State<ProfileBaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: Container(
          child: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              'Profile',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () => print("Add"),
              )
            ],
          ),
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // profileHeaderWidget(context),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.black),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 18.0, right: 18.0, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color(0xff74EDED),
                                  backgroundImage: CachedNetworkImageProvider(
                                      Constraints.IMAGE_BASE_URL +
                                          widget.userDetails!.image),
                                ),
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        widget.userDetails!.reelsCount == null
                                            ? Text(
                                                "0",
                                                style: GoogleFonts.nunito(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                            : Text(
                                                widget.userDetails!.reelsCount
                                                    .toString(),
                                                style: GoogleFonts.nunito(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                        Text(
                                          "Posts",
                                          style: GoogleFonts.nunito(
                                            fontSize: 15,
                                            color: Colors.white,
                                            letterSpacing: 0.4,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Column(
                                      children: [
                                        widget.userDetails!.followersTotal ==
                                                null
                                            ? Text(
                                                '0',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                            : Text(
                                                widget
                                                    .userDetails!.followersTotal
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                        Text(
                                          "Followers",
                                          style: TextStyle(
                                            letterSpacing: 0.4,
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Column(
                                      children: [
                                        widget.userDetails!.followingTotal ==
                                                null
                                            ? Text(
                                                '0',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                            : Text(
                                                widget
                                                    .userDetails!.followingTotal
                                                    .toString(),
                                                style: TextStyle(
                                                  letterSpacing: 0.4,
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                        Text(
                                          "Following",
                                          style: TextStyle(
                                            letterSpacing: 0.4,
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              widget.userDetails!.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            widget.userDetails!.city == ""
                                ? Text(
                                    '',
                                    style: TextStyle(
                                      letterSpacing: 0.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    widget.userDetails!.city,
                                    style: TextStyle(
                                      letterSpacing: 0.4,
                                      color: Colors.white,
                                    ),
                                  ),
                            SizedBox(
                              height: 20,
                            ),
                            actions(context),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: <Widget>[
              Material(
                color: Colors.black,
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[400],
                  indicatorWeight: 1,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.grid_on_sharp,
                        color: Colors.white,
                      ),
                    ),
                    Tab(icon: Icon(Icons.tv_rounded)),
                    Tab(icon: Icon(Icons.video_call)),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Gallery(
                        userId: widget.userDetails!.id,
                        userDetails: widget.userDetails),
                    Igtv(),
                    Reels(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Gallery extends StatefulWidget {
  final String? userId;
  final User? userDetails;
  Gallery({Key? key, required this.userId, required this.userDetails})
      : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  OverlayEntry? _popupDialog;

  List<UserVideos> userVideos = [];
  bool isUserVideoLoading = true;

  Future getVideoList(String userId) async {
    List<UserVideos> response = await ApiHandle.getVideo(userId);

    setState(() {
      userVideos = response;

      isUserVideoLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getVideoList(widget.userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isUserVideoLoading
          ? Container(
              child: Center(
                child: Text(
                  'Fetching Videos',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            )
          : userVideos.length == 0
              ? Center(
                  child: Text('No Videos'),
                )
              : GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  children: userVideos
                      .map((e) => _createGridTileWidget(e.coverImage!))
                      .toList(),
                ),
    );
  }

  Widget _createGridTileWidget(String url) => Builder(
        builder: (context) => GestureDetector(
          onLongPress: () {
            _popupDialog = _createPopupDialog(url);
            Overlay.of(context)!.insert(_popupDialog!);
          },
          onLongPressEnd: (details) => _popupDialog?.remove(),
          child: Image.network(Constraints.COVER_IMAGE_URL + url,
              fit: BoxFit.cover, errorBuilder: (BuildContext context,
                  Object exception, StackTrace? stackTrace) {
            return Image.asset(
              "assets/images/splash_logo.png",
              fit: BoxFit.cover,
            );
          }),
        ),
      );

  OverlayEntry _createPopupDialog(String url) {
    return OverlayEntry(
      builder: (context) => AnimatedDialog(
        child: _createPopupContent(url),
      ),
    );
  }

  Widget _createPhotoTitle(String profileurl) => Container(
      width: double.infinity,
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
              Constraints.IMAGE_BASE_URL + profileurl),
        ),
        title: Text(
          'john.doe',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ));

  Widget _createActionBar() => Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.favorite_border,
              color: Colors.black,
            ),
            Icon(
              Icons.chat_bubble_outline_outlined,
              color: Colors.black,
            ),
            Icon(
              Icons.send,
              color: Colors.black,
            ),
          ],
        ),
      );

  Widget _createPopupContent(String url) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _createPhotoTitle(widget.userDetails!.image),
              Image.network(
                Constraints.COVER_IMAGE_URL + url,
                fit: BoxFit.cover,
                height: 300,
                width: MediaQuery.of(context).size.width - 32,
              ),
              _createActionBar(),
            ],
          ),
        ),
      );
}

class AnimatedDialog extends StatefulWidget {
  const AnimatedDialog({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => AnimatedDialogState();
}

class AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? opacityAnimation;
  Animation<double>? scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    scaleAnimation =
        CurvedAnimation(parent: controller!, curve: Curves.easeOutExpo);
    opacityAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
        CurvedAnimation(parent: controller!, curve: Curves.easeOutExpo));

    controller!.addListener(() => setState(() {}));
    controller!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(opacityAnimation!.value),
      child: Center(
        child: FadeTransition(
          opacity: scaleAnimation!,
          child: ScaleTransition(
            scale: scaleAnimation!,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class Reels extends StatelessWidget {
  const Reels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class Igtv extends StatelessWidget {
  const Igtv({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
