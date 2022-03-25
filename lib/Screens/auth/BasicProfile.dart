import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/model/user.dart';
import 'package:qvid/utils/constaints.dart';

class BasicProfileRegistration extends StatefulWidget {
  final String userType;
  BasicProfileRegistration({Key? key, required this.userType})
      : super(key: key);

  @override
  State<BasicProfileRegistration> createState() =>
      _BasicProfileRegistrationState();
}

class _BasicProfileRegistrationState extends State<BasicProfileRegistration> {
  TextEditingController dateinput = TextEditingController();
  TextEditingController nameInput = TextEditingController();
  TextEditingController emailInput = TextEditingController();
  String userId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          )),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                "Few More\nDetails",
                style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                alignment: Alignment.center,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xffFFbac373737),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 5),
                  child: TextField(
                    controller: nameInput,
                    keyboardAppearance: Brightness.dark,
                    keyboardType: TextInputType.name,
                    cursorColor: Color(0xffC7C7C7),
                    toolbarOptions: ToolbarOptions(paste: true, cut: true),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'What Should we call you ?',
                        hintStyle: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                fontSize: 18,
                                color: Color(0xffFF929292),
                                fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                alignment: Alignment.center,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xffFFbac373737),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 5),
                  child: TextField(
                    controller: emailInput,
                    keyboardAppearance: Brightness.dark,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Color(0xffC7C7C7),
                    toolbarOptions: ToolbarOptions(paste: true, cut: true),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Your Email',
                        hintStyle: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                fontSize: 18,
                                color: Color(0xffFF929292),
                                fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                alignment: Alignment.center,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xffFFbac373737),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 5),
                  child: TextField(
                    controller: dateinput,
                    keyboardAppearance: Brightness.dark,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(
                              2000), //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime.now());

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('dd-MM-yyyy').format(pickedDate);

                        setState(() {
                          dateinput.text =
                              formattedDate; //set output date to TextField value.
                        });
                      } else {
                        print("Date is not selected");
                      }
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'When were you Born',
                        hintStyle: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                fontSize: 18,
                                color: Color(0xffFF929292),
                                fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Center(
              child: GestureDetector(
                onTap: () async {
                  var result =
                      await MyPrefManager.prefInstance().getData("user");
                  User user =
                      User.fromMap(jsonDecode(result) as Map<String, dynamic>);
                  //print(user.id + user.name);
                  userId = user.id;

                  Future.delayed(Duration(seconds: 1), () async {
                    if (userId != '') {
                      var url = Uri.parse(Constraints.BASE_URL);
                      var response = await http.post(url, body: {
                        "id": userId,
                        "name": nameInput.text.trim(),
                        "email": emailInput.text.trim(),
                        "dob": dateinput.text.trim(),
                        "user_type": widget.userType,
                        "flag": "UpdateDetail"
                      });

                      var responseDecoded = jsonDecode(response.body);

                      String responseCode = responseDecoded["res"];

                      if (responseCode == "success") {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          PageRoutes.mycontainer,
                          (route) => false,
                        );
                      }
                    } else {
                      print('error');
                    }
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "Proceed",
                      style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
