import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:qvid/Screens/chat/chat_controller.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/model/chat_message.dart';
import 'package:qvid/model/chat_user.dart';
import 'package:qvid/model/user.dart';
import 'package:qvid/utils/constaints.dart';
import 'package:qvid/widget/toast.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  ChatUser receiver;
  final String userId;
  ChatScreen({required this.receiver, required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  User? sender;
  List<ChatMessage> messages = [];
  ChatController chatController = Get.put(ChatController());
  bool isLoading = true;
  final TextEditingController _message = TextEditingController();
  ScrollController _controller = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    chatController.chatList.value = <Map>[];
    getChatMessages(widget.userId, widget.receiver.id!);
    focusNode.addListener(
      () {
        if (focusNode.hasFocus) {
          setState(() {
            showEmoji = false;
            _emojiIcon = Icon(
              FontAwesomeIcons.smileWink,
              color: Colors.grey,
              size: 20,
            );
          });
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      messages.clear();
      getChatMessages(sender!.id, widget.receiver.id!);
    }
  }

  Icon _emojiIcon = Icon(
    FontAwesomeIcons.smileWink,
    color: Colors.grey,
    size: 20,
  );
  bool showEmoji = false;
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            color: Colors.black87,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white)),
                Expanded(
                  child: Row(
                    children: [
                      widget.receiver.image!.isEmpty
                          ? const CircleAvatar(
                              backgroundImage:
                                  AssetImage("assets/images/user_icon.png"),
                              radius: 17,
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                  Constraints.IMAGE_BASE_URL +
                                      widget.receiver.image!),
                              radius: 17,
                            ),
                      const SizedBox(width: 15),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.receiver.name}",
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: 1,
                          ),
                          Text(
                            "Online",
                            style: GoogleFonts.nunito(
                                color: Colors.white, fontSize: 14),
                          )
                        ],
                      )),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.call,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.video_call,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/images/background.jpg"))),
            child: Stack(
              children: [
                Obx(
                  () => chatController.chatList.isNotEmpty
                      ? Container(
                          margin: EdgeInsets.only(bottom: 75),
                          width: double.infinity,
                          height: double.infinity,
                          child: ListView.builder(
                            itemCount: chatController.chatList.length,
                            shrinkWrap: true,
                            reverse: false,
                            controller: _controller,
                            itemBuilder: (context, index) {
                              if (chatController.chatList[index]['i'] == "2") {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Flexible(
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(12),
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(13.0),
                                            child: Text(
                                              chatController.chatList[index]
                                                  ['message'],
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(12),
                                              bottomLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(13.0),
                                            child: Text(
                                              chatController.chatList[index]
                                                  ['message'],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              // return Container(
                              //     padding: EdgeInsets.only(
                              //         left: 14,
                              //         right: 14,
                              //         top: 10,
                              //         bottom: 10),
                              //     child: Align(
                              //       alignment: (chatController.chatList[index]
                              //                   ['i'] ==
                              //               "1")
                              //           ? Alignment.topLeft
                              //           : Alignment.topRight,
                              //       child: Container(
                              //         width: chatController
                              //                     .chatList[index]['message']
                              //                     .length >
                              //                 10
                              //             ? 180
                              //             : 70,
                              //         decoration: BoxDecoration(
                              //           borderRadius: BorderRadius.only(
                              //             topRight: Radius.circular(10),
                              //             bottomLeft: Radius.circular(15),
                              //             bottomRight: Radius.circular(10),
                              //           ),
                              //           color: chatController.chatList[index]
                              //                       ['i'] ==
                              //                   "1"
                              //               ? buttonColor
                              //               : Colors.deepPurple,
                              //         ),
                              //         child: Column(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             Text(
                              //               chatController.chatList[index]
                              //                   ['message'],
                              //               style: TextStyle(
                              //                   fontSize: 15,
                              //                   color:
                              //                       /* (messages[index].id == widget.receiver.id
                              //                   ? Colors.black
                              //                   : Colors.white) */
                              //                       Colors.white),
                              //             ),
                              //             SizedBox(
                              //               height: 10,
                              //             ),
                              //             Container(
                              //               alignment: Alignment.topRight,
                              //               child: Text(
                              //                 chatController.chatList[index]
                              //                             ['time']
                              //                         .split(":")[0] +
                              //                     ":" +
                              //                     chatController
                              //                         .chatList[index]['time']
                              //                         .split(":")[1],
                              //                 style: TextStyle(
                              //                     fontSize: 15,
                              //                     color:
                              //                         /* (messages[index].id == widget.receiver.id
                              //                     ? Colors.black
                              //                     : Colors.white) */
                              //                         Colors.white),
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ));
                            },
                          ),
                        )
                      : Container(),
                ),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                      height: 75,
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onTap: () {
                                        Timer(
                                            Duration(milliseconds: 300),
                                            () => _controller.jumpTo(_controller
                                                .position.maxScrollExtent));
                                      },
                                      controller: _message,
                                      style: TextStyle(color: Colors.black),
                                      keyboardType: TextInputType.multiline,
                                      focusNode: focusNode,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        hintText: "Write a message",
                                        border: InputBorder.none,
                                        /* border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.transparent)) */
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        openBottomSheet();
                                      },
                                      child: Icon(
                                        Icons.attach_file_rounded,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          FloatingActionButton(
                            backgroundColor: Colors.black87,
                            onPressed: () {
                              if (valid()) {
                                DateTime now = DateTime.now();
                                var currentTime = now.hour.toString() +
                                    ":" +
                                    now.minute.toString();
                                chatController.receiveMessage(
                                    _message.text, "2", currentTime);

                                _message.text = "";
                                Timer(
                                    Duration(milliseconds: 100),
                                    () => _controller.jumpTo(
                                        _controller.position.maxScrollExtent));

                                sendMessage(widget.receiver.id!, sender!.id,
                                    message!.trim());
                              }
                            },
                            child: Icon(
                              Icons.send,
                            ),
                            elevation: 0,
                          ),
                        ],
                      ),
                    )),
              ],
            )),
      ),
    );
  }

  Future findUser() async {
    var result = await MyPrefManager.prefInstance().getData("user");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    //print(user.id + user.name);
    setState(() {
      sender = user;
    });

    //MyToast(message: user.id).toast;
  }

  //send Message
  Future<void> sendMessage(
      String receiverId, String senderId, String message) async {
    http.Response response =
        await Apis().sendMessages(senderId, receiverId, message);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        //MyToast(message: msg).toast;
        //isComment = false;

      } else {
        MyToast(message: msg).toast;
      }
    } else {
      MyToast(message: "Server Errror");
    }
  }

  String? message;
  bool valid() {
    message = _message.text.trim();
    if (message!.isEmpty) {
      MyToast(message: "Please Write Message").toast;
      return false;
    } else {
      return true;
    }
  }

  //load chat list

  Future<List<ChatMessage>> getChatMessages(
      String senderId, String receriverId) async {
    messages.clear();
    http.Response response = await Apis().getChatList(senderId, receriverId);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      String res = data['res'];
      String msg = data['msg'];
      if (res == "success") {
        var re = data['data'] as List;

        if (mounted)
          setState(() {
            messages =
                re.map<ChatMessage>((e) => ChatMessage.fromJson(e)).toList();
            for (int i = 0; i < messages.length; i++) {
              chatController.receiveMessage(
                  messages[i].message,
                  messages[i].senderId == senderId ? "2" : "1",
                  messages[i].time!);
              Timer(
                  Duration(milliseconds: 10),
                  () =>
                      _controller.jumpTo(_controller.position.maxScrollExtent));
            }
            isLoading = false;
          });

        return re.map<ChatMessage>((e) => ChatMessage.fromJson(e)).toList();
        //return MySlider.fromJson(data['data'] as Map<String, dynamic>);
        /* for (int i = 0; i < sliders.length; i++) {
          MySlider slider = sliders[i];
          sliderImage[i] = slider.image;
        } */

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

  void openBottomSheet() {
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Positioned(
              bottom: 90,
              left: 25,
              right: 25,
              child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Card(
                                //color: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  child: Icon(
                                    Icons.photo,
                                    size: 30,
                                    color: Colors.red,
                                  ),
                                )),
                            SizedBox(width: 10),
                            Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                child: Container(
                                    height: 60,
                                    width: 60,
                                    child: Icon(
                                      Icons.video_camera_back_outlined,
                                      color: Colors.red,
                                      size: 30,
                                    ))),
                          ],
                        )
                      ],
                    ),
                  )),
            ));
  }
}
