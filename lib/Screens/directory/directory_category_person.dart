import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/model/directory_user.dart';
import 'package:qvid/widget/toast.dart';

class UserListFromDirectory extends StatefulWidget {
  final String categoryName;
  final String categoryId;
  final String userId;
  UserListFromDirectory(
      {Key? key,
      required this.categoryId,
      required this.categoryName,
      required this.userId})
      : super(key: key);

  @override
  State<UserListFromDirectory> createState() => _UserListFromDirectoryState();
}

class _UserListFromDirectoryState extends State<UserListFromDirectory> {
  List<DirectoryUser> userListofCategory = [];
  bool isLoading = true;

  Future getUsers() async {
    Response response =
        await Apis().getDirectoryByCategory(widget.categoryId, widget.userId);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      String res = data['res'];
      var list = data['data'] as List;

      if (res == 'success') {
        setState(() {
          userListofCategory = list
              .map<DirectoryUser>((e) => DirectoryUser.fromJson(e))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          userListofCategory = [];
          isLoading = false;
        });
      }
    }
    // MyToast(message: 'Something Went Wrong').toast;
    setState(() {
      isLoading = false;
      userListofCategory = [];
    });
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new)),
        title: Text(
          widget.categoryName,
          style: GoogleFonts.nunito(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : userListofCategory.length == 0
              ? Center(
                  child: Text(
                    'No Users',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : GridView.builder(
                  itemCount: userListofCategory.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.75,
                      crossAxisCount: 3,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0),
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 150,
                        child: Column(
                          children: [
                            ClipOval(
                              child: CachedNetworkImage(
                                  imageUrl:
                                      'https://media.istockphoto.com/photos/the-musicians-were-playing-rock-music-on-stage-there-was-an-audience-picture-id1319479588?b=1&k=20&m=1319479588&s=170667a&w=0&h=bunblYyTDA_vnXu-nY4x4oa7ke6aiiZKntZ5mfr-4aM='),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(userListofCategory[i].name!,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    );
                  }),
    );
  }
}
