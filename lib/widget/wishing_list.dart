import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:http/http.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/model/celebrity_user.dart';
import 'package:qvid/utils/constaints.dart';
import 'package:qvid/widget/popuptemplate/template.dart';
import 'package:qvid/widget/toast.dart';
import 'package:shimmer/shimmer.dart';

class WisheshList {
  final BuildContext context1;
  final CelebrityUser user;
  final String userId;
  WisheshList(
      {required this.context1, required this.user, required this.userId});

  Padding get list => Padding(
      padding: EdgeInsets.only(top: 5, left: 5, right: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          //gradient: LinearGradient(colors: [buttonColor, Colors.black87])
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            user.image!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(90.0),
                    child: CachedNetworkImage(
                      height: 100,
                      width: 100,
                      imageUrl: Constraints.IMAGE_BASE_URL + user.image!,
                      errorWidget: (context, url, error) => ClipRRect(
                        borderRadius: BorderRadius.circular(90.0),
                        child: Image.asset(
                          "assets/images/banner 1.png",
                          height: 100,
                          width: 100,
                        ),
                      ),
                      fit: BoxFit.cover,
                      placeholder: (context, value) => Shimmer.fromColors(
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)))),
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        enabled: true,
                        direction: ShimmerDirection.rtl,
                        period: Duration(seconds: 2),
                      ),
                    ),
                  )
                : Image.asset(
                    "assets/images/banner 1.png",
                    height: 100,
                    width: 100,
                    fit: BoxFit.fill,
                  ),
            /* user.image!.isNotEmpty
                ? Image.asset(
                    "assets/images/banner 1.png",
                    fit: BoxFit.fill,
                    height: 150,
                  )
                : Image.network(
                    Constraints.IMAGE_BASE_URL + user.image!,
                    height: 120,
                    fit: BoxFit.cover,
                  ), */
            /* ? CircleAvatar(
                    radius: 40.0,
                    backgroundImage: AssetImage('assets/user/user1.png'))
                : CircleAvatar(
                    radius: 40.0,
                    backgroundImage:
                        NetworkImage(Constraints.IMAGE_BASE_URL + user.image!),
                  ), */
            SizedBox(
              height: 10,
            ),
            Text(
              "${user.name!}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          
          ],
        ),
      ));
}
