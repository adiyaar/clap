import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:qvid/Screens/user_profile.dart';
import 'package:qvid/model/celebrity_user.dart';

import 'package:qvid/utils/constaints.dart';

class AllCelebrityList extends StatefulWidget {
  final List<CelebrityUser> celbUser;
  final String userId;
  AllCelebrityList({Key? key, required this.celbUser, required this.userId})
      : super(key: key);

  @override
  _AllCelebrityListState createState() => _AllCelebrityListState();
}

class _AllCelebrityListState extends State<AllCelebrityList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new),
          ),
          title: Text(
            "Celebrities",
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarColor: Colors.black),
        ),
        body: GridView.builder(
            itemCount: widget.celbUser.length,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.75,
                crossAxisCount: 3,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                              celbDetails: widget.celbUser[index],
                              userId: widget.userId,
                            ))),
                child: Card(
                  color: Colors.black,
                  child: GridTile(
                      header: CachedNetworkImage(
                        imageUrl: Constraints.IMAGE_BASE_URL +
                            widget.celbUser[index].image!,
                        fit: BoxFit.cover,
                      ),
                      footer: Text(
                          '${widget.celbUser[index].name!.trim()}\nMumbai - 26',
                          style: GoogleFonts.nunito(color: Colors.white)),
                      child: Container()),
                ),
              );
            }));
  }
}
