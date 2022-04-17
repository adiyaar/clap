import 'dart:convert';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:qvid/Screens/chat/chat_details.dart';

import 'package:qvid/Theme/colors.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/model/chat_user.dart';
import 'package:qvid/model/user.dart';
import 'package:qvid/utils/constaints.dart';
import 'package:qvid/widget/toast.dart';

// class ConverationChats extends StatefulWidget {
//   @override
//   _ConverationChatsState createState() => _ConverationChatsState();
// }

// class _ConverationChatsState extends State<ConverationChats> {
//   bool isLoading = false;

//   List<ChatUser> primaryUsers = [];
//   List<ChatUser> suggestedUsers = [];
//   String? userId;
//   @override
//   void initState() {
//     isLoading = true;
//     Future.delayed(Duration(seconds: 1), () {
//       findUser().then((value) => {getChatUser(userId!), getSuggested(userId!)});
//     });

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(100.0),
//           child: AppBar(
//             systemOverlayStyle:
//                 SystemUiOverlayStyle(statusBarColor: buttonColor),
//             iconTheme: IconThemeData(color: buttonColor),
//             actions: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.only(right: 20),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(context, PageRoutes.search_user);
//                   },
//                   child: Icon(
//                     Icons.search,
//                     size: 30,
//                     color: buttonColor,
//                   ),
//                 ),
//               )
//             ],
//             bottom: PreferredSize(
//               preferredSize: Size.fromHeight(0.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: TabBar(
//                   labelColor: buttonColor,
//                   unselectedLabelColor: Colors.white,
//                   labelStyle: Theme.of(context).textTheme.headline6,
//                   //indicator: BoxDecoration(color: Colors.red),
//                   indicatorColor: Colors.red,
//                   isScrollable: false,
//                   tabs: <Widget>[
//                     Tab(text: "Primary"),
//                     Tab(text: "Suggestion"),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         body: Stack(
//           children: [
//             isLoading == false
//                 ? TabBarView(
//                     physics: BouncingScrollPhysics(),
//                     children: <Widget>[
//                       FadedSlideAnimation(
//                         PrimaryChats(
//                           users: primaryUsers,
//                         ),
//                         beginOffset: Offset(0, 0.3),
//                         endOffset: Offset(0, 0),
//                         slideCurve: Curves.linearToEaseOut,
//                       ),
//                       FadedSlideAnimation(
//                         SuggestionChats(users: suggestedUsers),
//                         beginOffset: Offset(0, 0.3),
//                         endOffset: Offset(0, 0),
//                         slideCurve: Curves.linearToEaseOut,
//                       )
//                     ],
//                   )
//                 : SpinKitFadingCircle(
//                     color: buttonColor,
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<List<ChatUser>> getChatUser(String userId) async {
//     Response response = await Apis().getChatUserList(userId);
//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);
//       String res = data['res'];
//       String msg = data['msg'];
//       if (res == "success") {
//         var re = data['data'] as List;
//         print("sdsd");
//         print(re.length);
//         if (mounted)
//           setState(() {
//             primaryUsers =
//                 re.map<ChatUser>((e) => ChatUser.fromJson(e)).toList();
//             isLoading = false;
//           });
//         return re.map<ChatUser>((e) => ChatUser.fromJson(e)).toList();
//       } else {
//         print("error");
//         MyToast(message: msg).toast;
//         setState(() {
//           isLoading = false;
//         });
//         return [];
//       }
//     } else {
//       throw Exception('Failed to load album');
//     }
//   }

//   Future<List<ChatUser>> getSuggested(String userId) async {
//     Response response = await Apis().getSuggestedUserList(userId);
//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);
//       String res = data['res'];
//       String msg = data['msg'];
//       if (res == "success") {
//         var re = data['data'] as List;
//         print("sdsd");
//         print(re.length);
//         if (mounted)
//           setState(() {
//             suggestedUsers =
//                 re.map<ChatUser>((e) => ChatUser.fromJson(e)).toList();
//             isLoading = false;
//           });
//         return re.map<ChatUser>((e) => ChatUser.fromJson(e)).toList();
//       } else {
//         print("error");
//         MyToast(message: msg).toast;
//         setState(() {
//           isLoading = false;
//         });
//         return [];
//       }
//     } else {
//       throw Exception('Failed to load album');
//     }
//   }

//   Future findUser() async {
//     var result = await MyPrefManager.prefInstance().getData("user");
//     User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
//     //print(user.id + user.name);
//     setState(() {
//       userId = user.id;
//     });

//     //MyToast(message: user.id).toast;
//   }
// }

class ConversationChatsScreen extends StatefulWidget {
  final List<ChatUser> userChats;
  final String userId;
  ConversationChatsScreen(
      {Key? key, required this.userChats, required this.userId})
      : super(key: key);

  @override
  State<ConversationChatsScreen> createState() =>
      _ConversationChatsScreenState();
}

class _ConversationChatsScreenState extends State<ConversationChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('Chats',
              style: GoogleFonts.nunito(
                  fontSize: 22, fontWeight: FontWeight.bold))),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.userChats.length,
        itemBuilder: (context, index) {
          return new Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatScreen(
                                receiver: widget.userChats[index],
                                userId: widget.userId,
                              )));
                },
                child: new ListTile(
                  leading: new CircleAvatar(
                    foregroundColor: Theme.of(context).primaryColor,
                    radius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: widget.userChats[index].image != null
                        ? NetworkImage(
                            Constraints.IMAGE_BASE_URL +
                                widget.userChats[index].image!,
                          )
                        : NetworkImage(
                            'https://images.unsplash.com/photo-1644982647711-9129d2ed7ceb?ixlib=rb-1.2.1&ixid=MnwxMjA3fDF8MHxzZWFyY2h8MTV8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=600&q=60'),
                  ),
                  title: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                        widget.userChats[index].name!,
                        style: new TextStyle(fontWeight: FontWeight.bold),
                      ),
                      new Text(
                        widget.userChats[index].chatTime!,
                        style:
                            new TextStyle(color: Colors.grey, fontSize: 14.0),
                      ),
                    ],
                  ),
                  subtitle: new Container(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: new Text(
                      widget.userChats[index].message!,
                      style: new TextStyle(color: Colors.grey, fontSize: 15.0),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
