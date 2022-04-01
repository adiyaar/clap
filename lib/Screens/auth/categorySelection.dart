import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/auth/basic_profile_details.dart';

import 'BasicProfile.dart';

class CategoryUser extends StatefulWidget {
  CategoryUser({Key? key}) : super(key: key);

  @override
  State<CategoryUser> createState() => _CategoryUserState();
}

class _CategoryUserState extends State<CategoryUser> {
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
                "Let's Get\nOnboarded",
                style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 10,
            ),
            Center(
                child: Text(
              'How Do You Identify Yourself As ?',
              style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            )),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BasicProfileRegistration(
                              userType: 'normal',
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(0xffF9EAEA)),
                  child: Row(
                    children: [
                      Image.network(
                        'https://media.istockphoto.com/photos/black-female-singer-singing-into-microphone-in-recording-studio-picture-id1284317705?b=1&k=20&m=1284317705&s=170667a&w=0&h=F7UoOb_dF4Jmsx2eYkWuehZn_EHvF6iYZtS260Cxn_o=',
                        width: 90,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Normal User',
                            style: GoogleFonts.nunito(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(
                            'No Direct Connection with Bollywood',
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BasicProfileRegistration(
                              userType: 'influencer',
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(0xffF9EAEA)),
                  child: Row(
                    children: [
                      Image.network(
                        'https://media.istockphoto.com/photos/black-female-singer-singing-into-microphone-in-recording-studio-picture-id1284317705?b=1&k=20&m=1284317705&s=170667a&w=0&h=F7UoOb_dF4Jmsx2eYkWuehZn_EHvF6iYZtS260Cxn_o=',
                        width: 90,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instagram Influencer',
                            style: GoogleFonts.nunito(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(
                            'Direct Connection with Social media',
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {

                
                Navigator.pushNamed(
                  context,
                  PageRoutes.personal_info,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(0xffF9EAEA)),
                  child: Row(
                    children: [
                      Image.network(
                        'https://media.istockphoto.com/photos/black-female-singer-singing-into-microphone-in-recording-studio-picture-id1284317705?b=1&k=20&m=1284317705&s=170667a&w=0&h=F7UoOb_dF4Jmsx2eYkWuehZn_EHvF6iYZtS260Cxn_o=',
                        width: 90,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bollywood Celebrity',
                            style: GoogleFonts.nunito(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(
                            'Direct Connection with Bollywood',
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ],
                      )
                    ],
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
