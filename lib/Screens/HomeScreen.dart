import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:qvid/BottomNavigation/Explore/search.dart';
import 'package:qvid/BottomNavigation/MyProfile/my_profile_page.dart';
import 'package:qvid/BottomNavigation/Notifications/notification_messages.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/booking/booking.dart';
import 'package:qvid/Screens/custom_appbar.dart';
import 'package:qvid/Screens/post_list.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:flutter/services.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/api_handle.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/model/celebrity_user.dart';
import 'package:qvid/model/directory_user.dart';
import 'package:qvid/model/slider.dart';
import 'package:qvid/model/user.dart';
import 'package:qvid/model/user_post.dart';
import 'package:qvid/utils/constaints.dart' as con;
import 'package:qvid/widget/homepage_shimmer_design.dart';
import 'package:qvid/widget/toast.dart';
import 'package:qvid/widget/wishing_list.dart';
import 'package:shimmer/shimmer.dart';

List<String> carouselImages = [];

class MyContainer extends StatefulWidget {
  @override
  State<MyContainer> createState() => _MyContainerState();
}

class _MyContainerState extends State<MyContainer> {
  int currentPos = 0;
  int i = 0;
  late List<MySlider> slide;
  late String userId;
  User? userDetails;
  List<UserPost>? postList;
  List<CelebrityUser>? userList;
  List<User>? newUserList;
  bool isLoading = true;
  bool isSwitch = false;
  FirebaseMessaging? messaging;
  List<DirectoryUser> bollywoodCreativeDirectory = [];

  @override
  void initState() {
    messaging = FirebaseMessaging.instance;
    getToken(messaging);
    getBollyWoodDirectoryList();

    Future.delayed(Duration(seconds: 1), () async {
      await fetchUser();
      fetchSlider();

      loadCelebrityWishes();
      loadNewUser();
      //loadCelebrityWishesh();
      getUserMatchPost(userId).then((list) => {
            setState(() {
              //postList = re.map<UserPost>((e) => UserPost.fromJson(e)).toList();
              postList = list;
            })
          });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    carouselImages.clear();
    clearShareData();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness:
            Brightness.light //or set color with: Color(0xFF0000FF)
        ));
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, PageRoutes.broadcastPage,
                arguments: userDetails!.id);
          },
          backgroundColor: Colors.white,
          child: Image.asset(
            "assets/images/broadcast.png",
            width: 27,
            height: 27,
            color: Colors.red,
          ),
        ),
        drawer: Container(
          width: MediaQuery.of(context).size.width / 2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12.0),
              ),
              color: Color(0xffF9EAEA)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 2.0,
              sigmaY: 2.0,
            ),
            child: Drawer(
              child: ListView(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: Text('CLAP',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold, fontSize: 23)),
                  ),
                  SizedBox(height: 8),
                  userDetails == null
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProfileBaseScreen(userDetails: userDetails,)));
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage:
                                AssetImage('assets/images/user_icon.png'),
                            radius: 35,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProfileBaseScreen(userDetails: userDetails,)));
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: CachedNetworkImageProvider(
                                con.Constraints.IMAGE_BASE_URL +
                                    userDetails!.image),
                            radius: 35,
                          ),
                        ),
                  SizedBox(height: 3),
                  Center(
                    child: userDetails == null
                        ? Text("Guest",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                            ))
                        : Text(userDetails!.name,
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                            )),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ListTile(
                    title: Text('Search',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 17)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => Search()));
                    },
                  ),
                  ListTile(
                    title: Text('My Job Status',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 17)),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('My Bookings',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 17)),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('Short Films',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 17)),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('Reels',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 17)),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('Notifications',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 17)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => NotificationMessages()));
                    },
                  ),
                  ListTile(
                    title: Text('LogOut',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 17)),
                    onTap: () {
                      Navigator.pop(context);
                      MyPrefManager.prefInstance().removeData("user");
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        PageRoutes.login_screen,
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: Text('CLAP',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          actions: [
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, PageRoutes.conversation_screen),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset('assets/images/message.png'),
              ),
            )
          ],
        ),
        body: isLoading == true
            ? Shimmer.fromColors(
                baseColor: Colors.grey.shade900,
                highlightColor: cardColor,
                enabled: true,
                child: ShimmerLayout(context: context).shimmerDesign)
            : ListView(
                scrollDirection: Axis.vertical,
                //shrinkWrap: true,
                padding: EdgeInsets.all(0),
                children: [
                  SizedBox(
                    height: 165.0,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 165.0,
                        aspectRatio: 3.0,
                        autoPlay: true,
                        reverse: false,
                        autoPlayInterval: Duration(seconds: 3),
                        scrollDirection: Axis.horizontal,
                        viewportFraction: 1,
                      ),
                      items: carouselImages.map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(
                                    top: 5, bottom: 5, left: 10, right: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5)),
                                child: carouselImages.length == 0
                                    ? Image.asset(
                                        "assets/images/slider3.jpg",
                                        fit: BoxFit.fill,
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                            imageUrl:
                                                con.Constraints.BANNER_URL +
                                                    carouselImages[currentPos],
                                            fit: BoxFit.fill,
                                            placeholder: (context, url) =>
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 100.0,
                                                  child: Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade900,
                                                    highlightColor:
                                                        Colors.grey.shade700,
                                                    enabled: true,
                                                    child: Container(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )),
                                      ));
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Explore The Bollywood Creative Directory',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                    child: Text(
                      'Access a large database of celebrities to make your\nmoments memorable',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          color: Color(0xffA0A0A0),
                          fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                        itemCount: 5,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index) {
                          return index == 4
                              ? GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, PageRoutes.directory_screen),
                                  child: Container(
                                    width: 100,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 30),
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                                backgroundColor: Colors.black,
                                                radius: 18),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 30,
                                            )
                                          ],
                                        ),
                                        Text(
                                          "View More",
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 48,
                                          backgroundImage: NetworkImage(
                                              'https://media.istockphoto.com/photos/the-musicians-were-playing-rock-music-on-stage-there-was-an-audience-picture-id1319479588?b=1&k=20&m=1319479588&s=170667a&w=0&h=bunblYyTDA_vnXu-nY4x4oa7ke6aiiZKntZ5mfr-4aM='),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                            bollywoodCreativeDirectory[index]
                                                .userCateory!,
                                            style: GoogleFonts.nunito(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                  ),
                                );
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Latest Requirement',
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, PageRoutes.allPostList),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Text(
                            'View All',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff878686),
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      postList == null || postList!.isEmpty
                          ? Container()
                          : ListView.separated(
                              separatorBuilder: (context, index) => Divider(
                                    color: Colors.black,
                                  ),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: postList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                UserPost userPost = postList![index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    // margin: EdgeInsets.all(5),
                                    width: double.infinity,
                                    //color: postColor,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      color: Color(0xffF2D4D4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          userPost.postDescription!
                                              .toUpperCase(),
                                          style: GoogleFonts.nunito(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Location - ${userPost.postLocation}',
                                          style: GoogleFonts.nunito(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          'Last Update - ${userPost.date}',
                                          style: GoogleFonts.nunito(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTap: () => shareApp(),
                                                  child: Text(
                                                    'Share Job',
                                                    style: GoogleFonts.nunito(
                                                        color:
                                                            Color(0xffFF0000),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () =>
                                                      Navigator.pushNamed(
                                                          context,
                                                          PageRoutes
                                                              .post_full_view,
                                                          arguments: userPost),
                                                  child: Text(
                                                    'View More',
                                                    style: GoogleFonts.nunito(
                                                        color:
                                                            Color(0xffFF0000),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    User user = await ApiHandle
                                                        .fetchUser();
                                                    userPost.postType ==
                                                                "Artist" ||
                                                            userPost.postType ==
                                                                "Model"
                                                        ? Navigator.pushNamed(
                                                            context,
                                                            PageRoutes
                                                                .applied_details,
                                                            arguments: userPost)
                                                        : showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                FutureProgressDialog(
                                                                    applyJob(
                                                                        userPost
                                                                            .id!,
                                                                        "",
                                                                        null)));
                                                  },
                                                  child: Text(
                                                    'Apply Now',
                                                    style: GoogleFonts.nunito(
                                                        color:
                                                            Color(0xffFF0000),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )
                                              ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Celebrity Wishes',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, PageRoutes.allCelebrityList),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Text(
                                'View All',
                                style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff878686),
                                    fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      userList != null
                          ? SizedBox(
                              height: 180,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: userList!.length > 5
                                      ? 5
                                      : userList!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return index == 4
                                        ? GestureDetector(
                                            onTap: () => Navigator.pushNamed(
                                                context,
                                                PageRoutes.allCelebrityList),
                                            child: Container(
                                              width: 100,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 30),
                                                  Stack(
                                                    children: [
                                                      CircleAvatar(
                                                          backgroundColor:
                                                              Colors.black,
                                                          radius: 18),
                                                      Icon(
                                                        Icons.arrow_forward,
                                                        color: Colors.white,
                                                        size: 30,
                                                      )
                                                    ],
                                                  ),
                                                  Text(
                                                    "View More",
                                                    style: GoogleFonts.nunito(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  PageRoutes.userProfilePage,
                                                  arguments:
                                                      userList![index].id);
                                            },
                                            child: WisheshList(
                                                    context1: context,
                                                    user: userList![index],
                                                    userId: userId)
                                                .list,
                                          );
                                  }),
                            )
                          : Container(),
                      // Visibility(
                      //   visible: userDetails != null
                      //       ? userDetails!.celebrity == "false"
                      //           ? false
                      //           : true
                      //       : false,
                      //   child: Card(
                      //     color: cardColor,
                      //     elevation: 1,
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(5)),
                      //     child: Container(
                      //       padding: EdgeInsets.all(10),
                      //       width: MediaQuery.of(context).size.width,
                      //       decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Padding(
                      //             padding: const EdgeInsets.only(left: 10),
                      //             child: Text(
                      //               "Booking History",
                      //               style: TextStyle(
                      //                 fontSize: 20,
                      //                 color: Colors.blue,
                      //                 fontFamily: 'Times',
                      //                 //fontWeight: FontWeight.bold
                      //               ),
                      //             ),
                      //           ),
                      //           Row(
                      //             children: [
                      //               Expanded(
                      //                 child: Padding(
                      //                   padding:
                      //                       const EdgeInsets.only(left: 10),
                      //                   child: Text(
                      //                     "Check Your Booking History",
                      //                     style: TextStyle(
                      //                         color: Colors.white,
                      //                         fontSize: 14),
                      //                   ),
                      //                 ),
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.only(
                      //                     right: 20, bottom: 5),
                      //                 child: GestureDetector(
                      //                   onTap: () {
                      //                     Navigator.push(
                      //                         context,
                      //                         MaterialPageRoute(
                      //                             builder: (context) =>
                      //                                 BookingList(
                      //                                     type: "booked_me")));
                      //                   },
                      //                   child: Container(
                      //                     padding: EdgeInsets.only(
                      //                         left: 20, right: 20),
                      //                     alignment: Alignment.center,
                      //                     height: 40,
                      //                     child: Text(
                      //                       "View",
                      //                       style: TextStyle(
                      //                           fontSize: 14,
                      //                           fontWeight: FontWeight.bold,
                      //                           color: goldColor),
                      //                     ),
                      //                     decoration: BoxDecoration(
                      //                         border:
                      //                             Border.all(color: goldColor),
                      //                         borderRadius:
                      //                             BorderRadius.circular(20)),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 5,
                      ),
                      Center(
                          child: Text(
                        'CLAP',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )),
                      Center(
                          child: Text(
                        'Made with ❤️ in India',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }

  Future<List<MySlider>> loadSlider() async {
    Response response = await Apis().getSlider();
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      if (res == "success") {
        var re = data['data'] as List;

        return re.map<MySlider>((e) => MySlider.fromJson(e)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }

  void fetchSlider() async {
    loadSlider().then((slide) => {
          for (int i = 0; i < slide.length; i++)
            {carouselImages.add(slide[i].image)}
        });
  }

  //fetch matching post

  Future<List<DirectoryUser>> getBollyWoodDirectoryList() async {
    var result = await MyPrefManager.prefInstance().getData("user");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    Response response = await Apis().getDirectory(user.id);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;
        bollywoodCreativeDirectory =
            re.map<DirectoryUser>((e) => DirectoryUser.fromJson(e)).toList();
        return bollywoodCreativeDirectory;
      } else {
        MyToast(message: msg).toast;
        setState(() {
          //isSearching = false;
          isLoading = false;
        });
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List<UserPost>> getUserMatchPost(String userId) async {
    Response response = await Apis().getMatchingPost(userId);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      print(data);
      if (res == "success") {
        var re = data['data'] as List;
        print("sdsd");
        print(re.length);
        setState(() {
          isLoading = false;
        });
        return re.map<UserPost>((e) => UserPost.fromJson(e)).toList();
        //return MySlider.fromJson(data['data'] as Map<String, dynamic>);
        /* for (int i = 0; i < sliders.length; i++) {
          MySlider slider = sliders[i];
          sliderImage[i] = slider.image;
        } */

      } else {
        setState(() {
          isLoading = false;
        });
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<void> fetchUser() async {
    var result = await MyPrefManager.prefInstance().getData("user");

    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    User userDet = await ApiHandle.fetchUser();
    //print(user.id + user.name);
    if (mounted) {
      setState(() {
        userId = user.id;
        userDetails = userDet;
      });
    }
  }

  Future<List<CelebrityUser>> loadCelebrityWishes() async {
    var result = await MyPrefManager.prefInstance().getData("user");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    Response response = await Apis().getCelebrity(user.id);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;
        print("sdsd");
        print(re.length);
        setState(() {
          isLoading = false;
        });
        userList =
            re.map<CelebrityUser>((e) => CelebrityUser.fromJson(e)).toList();
        return re.map<CelebrityUser>((e) => CelebrityUser.fromJson(e)).toList();

        //return MySlider.fromJson(data['data'] as Map<String, dynamic>);
        /* for (int i = 0; i < sliders.length; i++) {
          MySlider slider = sliders[i]; 
          sliderImage[i] = slider.image;
        } */

      } else {
        print("error");
        setState(() {
          isLoading = false;
        });
        MyToast(message: msg).toast;
        return [];
      }
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future loadNewUser() async {
    var result = await MyPrefManager.prefInstance().getData("user");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    Response response = await Apis().getNewUser(user.id);
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;
        print("sdsd");
        print(re.length);

        if (mounted)
          setState(() {
            newUserList = re.map<User>((e) => User.fromMap(e)).toList();
            isLoading = false;
          });

        return re.map<UserPost>((e) => UserPost.fromJson(e)).toList();
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

  void getToken(FirebaseMessaging? messaging) async {
    String? token = await messaging!.getToken();
    updateToken(token);
    print(token);
  }

  void updateToken(String? token) async {
    var result = await MyPrefManager.prefInstance().getData("user");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    Response res = await Apis().updateToken(user.id, token!);
    print(res.body);
    var statusCode = res.statusCode;
    if (statusCode == 200) {
      var response = jsonDecode(res.body);
      String re = response["res"];
      String msg = response["msg"];
      if (re == "success") {
        // MyToast(message: msg).toast;
      } else {
        //MyToast(message: msg).toast;
      }
    }
  }

  Future addToFavorurite(String? id) async {
    var result = await MyPrefManager.prefInstance().getData("user");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    Response res = await Apis().addFavouriteJob(user.id, id!);
    var statusCode = res.statusCode;
    if (statusCode == 200) {
      var response = jsonDecode(res.body);
      String re = response["res"];
      String msg = response["msg"];
      if (re == "success") {
        MyToast(message: msg).toast;
      } else {
        MyToast(message: msg).toast;
      }
    }
  }

  Future applyJob(String postId, String type, File? file) async {
    // var s=SingleSelectChip(lang).createState().getSelectedItem();
    //print(s);
    var result = await MyPrefManager.prefInstance().getData("user");
    print("hello");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    Response res = await Apis().applyPost(user.id, postId, type, file);
    print("hello");
    var statusCode = res.statusCode;
    if (statusCode == 200) {
      var response = jsonDecode(res.body);
      print(response);
      String re = response["res"];
      String msg = response["msg"];
      if (re == "success") {
        MyToast(message: msg).toast;
        /* Future.delayed(
            Duration(seconds: 1),
            () => Navigator.pushNamedAndRemoveUntil(
                context, PageRoutes.bottomNavigation, (route) => false)); */
      } else {
        MyToast(message: msg).toast;
      }
    }
  }

  void clearShareData() async {
    bool result = await MyPrefManager.prefInstance().addData("New", "");
  }

  // void fetchData() async {
  //   se = await MyPrefManager.prefInstance().getData("New");
  // }
}
