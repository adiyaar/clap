import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/auth/login.dart';
import 'package:qvid/helper/my_preference.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: PageView(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Lottie.asset('assets/images/intro1.json',
                        height: MediaQuery.of(context).size.height / 2.5),
                    Text('Celebrity Wishing\nPlatform',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 32)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an Lorem Ipsum has been the industry's standard dummy text ever since",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff8B8B8B),
                              fontSize: 12)),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Color(0xff8B8B8B),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Color(0xff8B8B8B),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Color(0xff8B8B8B),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Lottie.network(
                        'https://assets9.lottiefiles.com/packages/lf20_ezxj8avu.json',
                        height: MediaQuery.of(context).size.height / 2.5),
                    Text('Start Creating\nYour Content',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 32)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an Lorem Ipsum has been the industry's standard dummy text ever since",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff8B8B8B),
                              fontSize: 12)),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Color(0xff8B8B8B),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Color(0xff8B8B8B),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Color(0xff8B8B8B),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Lottie.network(
                        'https://assets3.lottiefiles.com/private_files/lf30_bxssE7.json',
                        height: MediaQuery.of(context).size.height / 2.5),
                    Text('Share Your\nShort Films',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 32)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an Lorem Ipsum has been the industry's standard dummy text ever since",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff8B8B8B),
                              fontSize: 12)),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Color(0xff8B8B8B),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Color(0xff8B8B8B),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Color(0xff8B8B8B),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                height: double.infinity,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Lottie.network(
                        'https://assets5.lottiefiles.com/private_files/lf30_uvrwjrrs.json',
                        height: MediaQuery.of(context).size.height / 2.5),
                    Text('Browse Creative\nBollywood Directory',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 32)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an Lorem Ipsum has been the industry's standard dummy text ever since",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff8B8B8B),
                              fontSize: 12)),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            MyPrefManager.myPrefManager
                                .addData("intro", "true");
                            Navigator.pushNamedAndRemoveUntil(context,
                                PageRoutes.login_screen, (route) => false);
                          },
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width / 1.5,
                            alignment: Alignment.center,
                            child: Text("Let’s Begin",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20)),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
