import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:qvid/Screens/auth/categorySelection.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/widget/toast.dart';

class OtpScreen extends StatefulWidget {
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController _otp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map;
    final mobile = data['mobile'];
    final userType = data['user_type'];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Lottie.network(
                "https://assets3.lottiefiles.com/packages/lf20_2rhnd8qq.json",
                width: 160,
                height: 160,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                "OTP Sent",
                style: GoogleFonts.nunito(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: Text(
                  "We have sent a text message on\n$mobile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffC7C7C7)),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            PinCodeTextField(
              controller: _otp,
              mainAxisAlignment: MainAxisAlignment.center,
              appContext: context,
              pastedTextStyle: TextStyle(
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
              ),
              length: 4,
              obscureText: false,
              obscuringCharacter: '*',
              animationType: AnimationType.fade,
              /* validator: (v) {
                if (v!.length < 4) {
                  return "Plese Enter 4 digit otp";
                } else {
                  return null;
                }
              }, */
              pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 45,
                  fieldOuterPadding: EdgeInsets.all(10),
                  fieldWidth: 45,
                  inactiveColor: Color(0xffC4C4C4),
                  activeColor: Colors.white
                  //activeFillColor:
                  //   hasError ? Colors.orange : Colors.white,
                  ),
              cursorColor: disabledTextColor,
              animationDuration: Duration(milliseconds: 300),
              textStyle:
                  TextStyle(fontSize: 20, height: 1.6, color: Colors.black),
              enableActiveFill: false,
              keyboardType: TextInputType.number,
              boxShadows: [
                BoxShadow(
                  offset: Offset(0, 0),
                  color: Color(0xffC4C4C4),
                  blurRadius: 0,
                )
              ],
              onCompleted: (v) {},
              onChanged: (value) {},
              beforeTextPaste: (text) {
                print("Allowing to paste $text");

                return true;
              },
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) =>
                        FutureProgressDialog(resendOtp(mobile)));
              },
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Resend OTP ?",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
            ),
            SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () {
                String otp = _otp.text;
                if (otp.isEmpty) {
                  MyToast(message: "Please Enter Otp").toast;
                } else if (otp.length < 4) {
                  MyToast(message: "Please Enter 4 digit Otp").toast;
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => FutureProgressDialog(
                          otpVerify(mobile, otp, userType)));
                }
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
            SizedBox(
              height: 70,
            ),
          ],
        ),
      ),
    );
  }

  Future otpVerify(String mobile, String otp, String userType) async {
    Response resp = await Apis().verifyOtp(mobile, otp);
    if (resp.statusCode == 200) {
      var response = jsonDecode(resp.body);
      String res = response['res'];
      String msg = response['msg'];
      if (res == "success") {
        var data = response['data'];

        //get SharedPrefercne
        bool result = await MyPrefManager.prefInstance()
            .addData("user", jsonEncode(data));
        if (result == true) {
          print("add");
        } else {
          print("sorry");
        }

        print(data.toString());
        print(userType);
        Future.delayed(Duration(seconds: 1), () {
          //Navigator.of(context).pop();
          if (userType == "New") {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => CategoryUser()));
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              PageRoutes.mycontainer,
              (route) => false,
            );
          }
          // userType == "New"
          //     // ? Navigator.pushNamed(context, PageRoutes.personal_info,
          //     //     arguments: mobile)

          //     : Navigator.pushNamedAndRemoveUntil(
          //         context,
          //         PageRoutes.mycontainer,
          //         (route) => false,
          //       );
        });
      } else {
        MyToast(message: msg).toast;
      }
    } else {
      MyToast(message: "Retry").toast;
    }
  }

  Future resendOtp(String mobile) async {
    Response resp = await Apis().resendOtp(mobile);
    if (resp.statusCode == 200) {
      var response = jsonDecode(resp.body);
      String res = response['res'];
      String msg = response['msg'];
      if (res == "success") {
        MyToast(message: msg).toast;
      } else {
        MyToast(message: msg).toast;
      }
    } else {
      MyToast(message: "Retry").toast;
    }
  }
}
