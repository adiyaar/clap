import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/auth/user_category_list.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:qvid/apis/api.dart';
import 'package:qvid/helper/my_preference.dart';
import 'package:qvid/model/user.dart';
import 'package:qvid/model/user_categories.dart';
import 'package:qvid/utils/static_list.dart';
import 'package:qvid/widget/eye_color_list.dart';
import 'package:qvid/widget/hair_color_list.dart';
import 'package:qvid/widget/hair_type_list.dart';
import 'package:qvid/widget/muliple_language_list.dart';
import 'package:qvid/widget/skin_color_list.dart';
import 'package:qvid/widget/toast.dart';

class UserPersonalInfo extends StatefulWidget {
  @override
  State<UserPersonalInfo> createState() => _UserPersonalInfoState();
}

class _UserPersonalInfoState extends State<UserPersonalInfo> {
  List<UserCategories>? list;
  String? sidList;
  List<String>? tLang;
  String _selectedGender = 'Male';
  // String tname = "",
  //     tEmailid = "",
  //     tDob = "",
  //     tSkincolor = "",
  //     tHairtype = "",
  //     tHhaircolor = "",
  //     tGender = "",
  //     tWeight = "",
  //     tChestSize = "",
  //     tWaistSize = "",
  //     tHipSize = "",
  //     tEyeColor = "",
  //     tExperienceYear = "",
  //     tState = "",
  //     tCity = "";

  String? userId;

  // String tHeight = "";

  // String industry = "";
  // String? tCountry, tBodyType, tMaeritial;

  bool passportStatus = false;
  bool drivingStatus = false;
  bool swimmingStatus = false;
  bool danceStatus = false;
  bool boldContent = false;
  bool printShootStatus = false;
  bool bodyPrintShootStatus = false;
  bool nudePrintShootStatus = false;
  bool bikiniPrintShootStatus = false;
  bool trainedActorStatus = false;
  bool unionCardStatus = false;
  bool experinceStatus = false;
  bool busyStatus = false;
  bool disablitilyStatus = false;
  bool workshopStatus = false;
  String userCategory = 'Artist';

  @override
  void initState() {
    super.initState();
    findUser();
    // loadHipSize();
  }

  TextEditingController _dob = TextEditingController(); // dob of person
  TextEditingController _email = TextEditingController(); // email
  TextEditingController _name = TextEditingController(); // name of person
  TextEditingController _intrestOfCategory = TextEditingController(); // intrest
  TextEditingController _weight = TextEditingController();
  TextEditingController _experience_area = TextEditingController();
  TextEditingController _industryOfArtist = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _pincode = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _bodyType = TextEditingController();
  TextEditingController _maritalStatus = TextEditingController();
  TextEditingController _height = TextEditingController();
  TextEditingController _chestSize = TextEditingController();
  TextEditingController _hipSize = TextEditingController();
  TextEditingController _waistSize = TextEditingController();
  TextEditingController _language = TextEditingController();
  TextEditingController _experienceYear = TextEditingController();
  TextEditingController _instituteName = TextEditingController();

  String dropdownValue = 'One';

  DateTime selectedDate = DateTime.now();
  bool iSelect = false;

  String _industryOfArtistDefault = industries[0];

  //Gender _userCategoryGender = Gender.Male;
  // String _userCategoryGender = genderList[0];

  // List<String> cat = [];
  // String defaultName = "India";
  // String uage = "";
  // int i = -1;
  // int j = -1;
  // int h = -1;
  // int l = -1;
  // int m = -1;
  // int n = -1;
  // String _chooseDate = "";

  int _currentStep = 0;

  List<UserCategories> availableCategories = [];
  Future loadCategies(categoryName) async {
    Response response = await Apis().getCategories(categoryName);
    var statusCode = response.statusCode;
    print(response.body);
    if (statusCode == 200) {
      var data = jsonDecode(response.body);
      String res = data['res'];

      if (res == "success") {
        var cat = data['data'] as List;

        setState(() {
          availableCategories = cat
              .map<UserCategories>((e) => UserCategories.fromJson(e))
              .toList();
        });
        return availableCategories;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back_ios_new, color: Colors.white)),
      ),
      body: Container(
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
          Expanded(
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.black,
                primaryColorLight: Colors.black,
                primarySwatch: Colors.orange,
              ),
              child: Stepper(
                  currentStep: _currentStep,
                  onStepTapped: (step) => tapped(step),
                  onStepContinue: continued,
                  onStepCancel: cancel,
                  physics: ScrollPhysics(),
                  steps: [
                    Step(
                        title: Text(
                          'Basic Details',
                          style: GoogleFonts.nunito(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 0
                            ? StepState.complete
                            : StepState.disabled,
                        content: Container(
                          child: Column(
                            children: [
                              TextField(
                                controller: _name, // enter name
                                keyboardAppearance: Brightness.dark,
                                keyboardType: TextInputType.name,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                toolbarOptions:
                                    ToolbarOptions(paste: true, cut: true),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'John Doe',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _email, // enter email
                                keyboardAppearance: Brightness.dark,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                toolbarOptions:
                                    ToolbarOptions(paste: true, cut: true),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'someone@example.com',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _dob, // enter name
                                keyboardAppearance: Brightness.dark,
                                style: GoogleFonts.nunito(color: Colors.white),
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(
                                          1900), //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime.now());

                                  if (pickedDate != null) {
                                    String formattedDate =
                                        DateFormat('dd-MM-yyyy')
                                            .format(pickedDate);

                                    setState(() {
                                      _dob.text =
                                          formattedDate; //set output date to TextField value.
                                    });
                                  } else {
                                    print("Date is not selected");
                                  }
                                },
                                // keyboardType: TextInputType.name,
                                cursorColor: Color(0xffC7C7C7),
                                toolbarOptions:
                                    ToolbarOptions(paste: true, cut: true),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: '27 March 1987',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text('Select Your Gender',
                                    style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Wrap(
                                children: [
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Male',
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        groupValue: _selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Male',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Female',
                                        groupValue: _selectedGender,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Female',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Others',
                                        groupValue: _selectedGender,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Others',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Vendor/Company',
                                        groupValue: _selectedGender,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Vendor/Company',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                    Step(
                        title: Text(
                          'More About You',
                          style: GoogleFonts.nunito(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 1
                            ? StepState.complete
                            : StepState.disabled,
                        content: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Select Your Category',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Wrap(
                                children: [
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Artist',
                                        groupValue: userCategory,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            userCategory = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Artist',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Model',
                                        groupValue: userCategory,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            userCategory = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Model',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Director',
                                        groupValue: userCategory,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            userCategory = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Director',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Creative Director',
                                        groupValue: userCategory,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            userCategory = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Creative Director',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Creative Head',
                                        groupValue: userCategory,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            userCategory = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Creative Head',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Writer',
                                        groupValue: userCategory,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            userCategory = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Writer',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Musician',
                                        groupValue: userCategory,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            userCategory = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Musician',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Technician & Vendors',
                                        groupValue: userCategory,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            userCategory = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Technician & Vendors',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Producer & Production House',
                                        groupValue: userCategory,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        onChanged: (value) {
                                          setState(() {
                                            userCategory = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Producer & Production House',
                                        style: GoogleFonts.nunito(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Select Your Instrest Area',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              TextField(
                                controller: _intrestOfCategory,
                                keyboardAppearance: Brightness.dark,
                                style: GoogleFonts.nunito(color: Colors.white),
                                readOnly: true,
                                onTap: () async {
                                  loadCategies(userCategory);

                                  Future.delayed(Duration(seconds: 1), () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled:
                                          true, // set this to true
                                      builder: (_) {
                                        return DraggableScrollableSheet(
                                          expand: false,
                                          builder: (_, controller) {
                                            return Container(
                                                color: Colors.black,
                                                child: StatefulBuilder(builder:
                                                    (BuildContext context,
                                                        listState) {
                                                  return ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        availableCategories
                                                            .length,
                                                    controller:
                                                        controller, // set this too
                                                    itemBuilder: (_, i) =>
                                                        ListTile(
                                                      title: Text(
                                                        availableCategories[i]
                                                            .name,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      onTap: () {
                                                        listState(() {
                                                          Navigator.pop(
                                                              context);
                                                          _intrestOfCategory
                                                                  .text =
                                                              availableCategories[
                                                                      i]
                                                                  .name;
                                                        });
                                                      },
                                                    ),
                                                  );
                                                }));
                                          },
                                        );
                                      },
                                    );
                                  });
                                },
                                cursorColor: Color(0xffC7C7C7),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Select Your Intrest Area',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              TextField(
                                controller: _address, // enter add
                                keyboardAppearance: Brightness.dark,

                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                toolbarOptions:
                                    ToolbarOptions(paste: true, cut: true),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Enter Your Address',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _city, // enter name
                                keyboardAppearance: Brightness.dark,

                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                toolbarOptions:
                                    ToolbarOptions(paste: true, cut: true),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Enter Your City',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _state, // enter name
                                keyboardAppearance: Brightness.dark,
                                keyboardType: TextInputType.name,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                toolbarOptions:
                                    ToolbarOptions(paste: true, cut: true),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Enter Your State',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _pincode, // enter name
                                keyboardAppearance: Brightness.dark,
                                keyboardType: TextInputType.phone,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                toolbarOptions:
                                    ToolbarOptions(paste: true, cut: true),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Enter Your Pincode',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _industryOfArtist, // enter name
                                keyboardAppearance: Brightness.dark,
                                readOnly: true,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                onTap: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (_) => Container(
                                            color: Colors.black,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: industries.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title:
                                                        Text(industries[index]),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _industryOfArtist.text =
                                                          industries[index];
                                                    },
                                                  );
                                                }),
                                          ));
                                },

                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Choose Your Industry',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                        )),
                    Step(
                        title: Text(
                          'Finish',
                          style: GoogleFonts.nunito(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 2
                            ? StepState.complete
                            : StepState.disabled,
                        content: Container(
                          child: Column(
                            children: [
                              TextField(
                                controller: _weight, // enter name
                                keyboardAppearance: Brightness.dark,
                                keyboardType: TextInputType.number,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),

                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Enter Your Weight in Kgs',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _bodyType, // enter name
                                keyboardAppearance: Brightness.dark,
                                readOnly: true,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                onTap: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (_) => Container(
                                            color: Colors.black,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: bodyType.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title:
                                                        Text(bodyType[index]),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _bodyType.text =
                                                          bodyType[index];
                                                    },
                                                  );
                                                }),
                                          ));
                                },

                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Choose Your Industry',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _maritalStatus, // enter name
                                keyboardAppearance: Brightness.dark,
                                readOnly: true,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                onTap: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (_) => Container(
                                            color: Colors.black,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    maritialStatus.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Text(
                                                        maritialStatus[index]),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _maritalStatus.text =
                                                          maritialStatus[index];
                                                    },
                                                  );
                                                }),
                                          ));
                                },

                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Choose Your Marital Status',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _height, // enter name
                                keyboardAppearance: Brightness.dark,
                                readOnly: true,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                onTap: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (_) => Container(
                                            color: Colors.black,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: height.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Text(height[index]),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _height.text =
                                                          height[index];
                                                    },
                                                  );
                                                }),
                                          ));
                                },

                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Choose Your Height',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _chestSize, // enter name
                                keyboardAppearance: Brightness.dark,
                                readOnly: true,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                onTap: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (_) => Container(
                                            color: Colors.black,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: chestSize.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title:
                                                        Text(chestSize[index]),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _chestSize.text =
                                                          chestSize[index];
                                                    },
                                                  );
                                                }),
                                          ));
                                },

                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Choose Your Chest Size (inch)',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _hipSize, // enter name
                                keyboardAppearance: Brightness.dark,
                                readOnly: true,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                onTap: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (_) => Container(
                                            color: Colors.black,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: hiPSize.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Text(hiPSize[index]),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _hipSize.text =
                                                          hiPSize[index];
                                                    },
                                                  );
                                                }),
                                          ));
                                },

                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Choose Your Hip Size (inch)',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _waistSize, // enter name
                                keyboardAppearance: Brightness.dark,
                                readOnly: true,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                onTap: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (_) => Container(
                                            color: Colors.black,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: waistSize.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title:
                                                        Text(waistSize[index]),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _waistSize.text =
                                                          waistSize[index];
                                                    },
                                                  );
                                                }),
                                          ));
                                },

                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Choose Your Waist Size(inch)',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: _language, // enter name
                                keyboardAppearance: Brightness.dark,
                                readOnly: true,
                                cursorColor: Color(0xffC7C7C7),
                                style: GoogleFonts.nunito(color: Colors.white),
                                onTap: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (_) => Container(
                                            color: Colors.black,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: lang.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Text(lang[index]),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _language.text =
                                                          lang[index];
                                                    },
                                                  );
                                                }),
                                          ));
                                },

                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'Choose Your Spoken Language',
                                    hintStyle: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xffFF929292),
                                            fontWeight: FontWeight.w700))),
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                        ))
                  ]),
            ),
          )
        ],
      )),
    );
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    _currentStep < 2 ? setState(() => _currentStep += 1) : updateProfile();
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  Future findUser() async {
    var result = await MyPrefManager.prefInstance().getData("user");
    User user = User.fromMap(jsonDecode(result) as Map<String, dynamic>);
    //print(user.id + user.name);
    userId = user.id;
  }

  updateProfile() async {
    Response response = await Apis().updatePersionalDetails(
        userId!,
        _name.text.trim(),
        _email.text.trim(),
        _selectedGender,
        _dob.text,
        _language.text,
        skinColor[0],
        hair[0],
        hairColor[0],
        userCategory,
        'INDIA',
        _state.text,
        _city.text,
        _weight.text,
        _height.text,
        _chestSize.text,
        _chestSize.text,
        _waistSize.text,
        _hipSize.text,
        eyeColor[0],
        passportStatus.toString(),
        drivingStatus.toString(),
        swimmingStatus.toString(),
        danceStatus.toString(),
        boldContent.toString(),
        printShootStatus.toString(),
        bodyPrintShootStatus.toString(),
        nudePrintShootStatus.toString(),
        bikiniPrintShootStatus.toString(),
        trainedActorStatus.toString(),
        unionCardStatus.toString(),
        experinceStatus.toString(),
        '3',
        '',
        disablitilyStatus.toString(),
        _bodyType.text,
        _maritalStatus.toString(),
        'Bollywood Celebrity',
        workshopStatus.toString(),
        '',
        _address.text.trim(),
        _pincode.text.trim(),
        _industryOfArtist.text.trim());

    int statusCode = response.statusCode;

    if (statusCode == 200) {
      var result = jsonDecode(response.body);
      String re = result["res"];
      String msg = result["msg"];
      if (re == "success") {
        Future.delayed(Duration(microseconds: 1), () {
          Navigator.pushNamed(context, PageRoutes.basic_profile_info);
          MyToast(message: msg).toast;
        });
      } else {
        MyToast(message: msg).toast;
      }
    } else {
      MyToast(message: 'Server Error').toast;
    }
  }

  
  // bool valid() {
  //   tname = _name.text;
  //   tEmailid = _email.text;
  //   tDob = _dob.text;
  //   tLang = LanguageList(lang, 1).createState().getSelectedList();
  //   tSkincolor = SkinColorSelectChip(skinColor).createState().getSelectedItem();
  //   tHairtype = HairTypeSelectChip(hair).createState().getSelectedItem();
  //   tHhaircolor =
  //       HairColorSelectChip(hairColor).createState().getSelectedItem();
  //   //tGender = GenderSelectChip(gender).createState().getSelectedItem();
  //   tGender = _userCategoryGender;
  //   tState = _state.text;
  //   tCity = _city.text;
  //   tEyeColor = EyeColorSelectChip(hair).createState().getSelectedItem();
  //   print(_userCategory);
  //   tWeight = _weight.text;
  //   print(tHairtype);
  //   if (tname.isEmpty) {
  //     MyToast(message: "Please Enter your name").toast;
  //     return false;
  //   } else if (tEmailid.isEmpty) {
  //     MyToast(message: "Please Enter your Email Id").toast;
  //     return false;
  //   } else if (tDob.isEmpty) {
  //     MyToast(message: "Please Enter your Dob").toast;
  //     return false;
  //   } /*  else if (tWeight.isEmpty) {
  //     MyToast(message: "Please Enter Your  Weight").toast;
  //     return false;
  //   } */
  //   else if (tCountry == null || tCountry!.isEmpty) {
  //     MyToast(message: "Please Choose Country").toast;
  //     return false;
  //   } else if (tState.isEmpty) {
  //     MyToast(message: "Please Choose State").toast;
  //     return false;
  //   } else if (tCity.isEmpty) {
  //     MyToast(message: "Plese Choose Your City").toast;
  //     return false;
  //   } else if (industry.isEmpty) {
  //     MyToast(message: "Plese Choose Your industry").toast;
  //     return false;
  //   } else if (_userCategory == "Artist" || _userCategory == "Model") {
  //     if (tLang!.isEmpty) {
  //       MyToast(message: "Please Choose Your Language").toast;
  //       return false;
  //     } else if (tHeight.isEmpty) {
  //       MyToast(message: "Please Choose Your Height").toast;
  //       return false;
  //     } else if (tChestSize.isEmpty) {
  //       MyToast(
  //         message: _userCategoryGender != "Transgender"
  //             ? _userCategoryGender == "Male"
  //                 ? "Please Choose Your Chest Size"
  //                 : "Please Choose Your Beast Size"
  //             : "Please Choose Your Chest Size",
  //       ).toast;
  //       return false;
  //     } else if (tWaistSize.isEmpty) {
  //       MyToast(message: "Please Choose Your Waist Size");
  //       return false;
  //     } else if (tHipSize.isEmpty) {
  //       MyToast(message: "Please Choose Your Hip Size");
  //       return false;
  //     } else if (tSkincolor.isEmpty) {
  //       MyToast(message: "Please Choose Your Skin Color").toast;
  //       return false;
  //     } else if (tHairtype.isEmpty) {
  //       MyToast(message: "Please Choose Your Hair Type").toast;
  //       return false;
  //     } else if (tHhaircolor.isEmpty) {
  //       MyToast(message: "Please Choose Your Hair Color").toast;
  //       return false;
  //     } else if (tEyeColor.isEmpty) {
  //       MyToast(message: "Please Choose Your Eye Color").toast;
  //       return false;
  //     } else if (tGender.isEmpty) {
  //       MyToast(message: "Please Choose Your Gender").toast;
  //       return false;
  //     }
  //     return true;
  //   } else if (_category.text.isEmpty) {
  //     MyToast(message: "Please Select Your Expertise").toast;
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  void loadHipSize() {
    for (int i = 30; i < 61; i++) {
      hiPSize.add(i.toString());
    }
    for (int i = 16; i < 65; i++) {
      chestSize.add(i.toString());
      waistSize.add(i.toString());
    }
  }

  String listToString(List<String> list) {
    String data = "";
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        data = list[i];
      } else {
        data += "," + list[i];
      }
    }
    return data;
  }
}
