import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:qvid/Routes/routes.dart';
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
  String tname = "",
      tEmailid = "",
      tDob = "",
      tSkincolor = "",
      tHairtype = "",
      tHhaircolor = "",
      tGender = "",
      tWeight = "",
      tChestSize = "",
      tWaistSize = "",
      tHipSize = "",
      tEyeColor = "",
      tExperienceYear = "",
      tState = "",
      tCity = "";

  String? userId;

  String tHeight = "";

  String industry = "";
  String? tCountry, tBodyType, tMaeritial;
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

  @override
  void initState() {
    super.initState();
    findUser();
    // loadHipSize();
  }

  TextEditingController _dob = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _category = TextEditingController();
  TextEditingController _weight = TextEditingController();
  TextEditingController _experience_area = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _pincode = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _experienceYear = TextEditingController();
  TextEditingController _instituteName = TextEditingController();

  String dropdownValue = 'One';

  DateTime selectedDate = DateTime.now();
  bool iSelect = false;

  //Gender _userCategoryGender = Gender.Male;
  // String _userCategoryGender = genderList[0];
  String _userCategory = categoryList[0];
  String _userCategoryGender = categorygender[0];
  List<String> cat = [];
  String defaultName = "India";
  String uage = "";
  int i = -1;
  int j = -1;
  int h = -1;
  int l = -1;
  int m = -1;
  int n = -1;
  String _chooseDate = "";
  getAge(DateTime dateString) {
    String datePattern = "dd-MM-yyyy";

    DateTime birthDate = dateString;
    DateTime today = DateTime.now();

    int yearDiff = today.year - birthDate.year;
    if (yearDiff < 1) {
      MyToast(message: "You are not eligible").toast;
      _dob.text = "";
      uage = "";
    } else {
      uage = "${yearDiff}";
    }
    print(yearDiff);
  }

  void openCupterTinoDatePicker() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
            child: Container(
                height: 350,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 30,
                            ),
                          )),
                    ),
                    Container(
                      height: 200,
                      child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: DateTime.now(),
                          onDateTimeChanged: (val) {
                            setState(() {
                              print("${val.day}/${val.month}/${val.year}");
                              DateFormat dateFormat = DateFormat("dd MMM yyyy");
                              String date = dateFormat.format(val);
                              _chooseDate = date;
                              print(date);
                              //_chosenDateTime = val;
                            });
                          }),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(15),
                              alignment: Alignment.center,
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              decoration: BoxDecoration(
                                  color: buttonColor,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_chooseDate.isEmpty) {
                                MyToast(message: "Please Choose date").toast;
                                return;
                              } else {
                                Navigator.pop(context);
                                _dob.text = _chooseDate;
                                //getAge(selectedDate);
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(15),
                              alignment: Alignment.center,
                              child: Text(
                                "Ok",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              decoration: BoxDecoration(
                                  color: buttonColor,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ))));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1100, 1),
        lastDate: DateTime(2501));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        DateFormat dateFormat = DateFormat("dd MMM yyyy");
        String date = dateFormat.format(selectedDate);
        _dob.text = date;
        getAge(selectedDate);
      });
  }

  int _currentStep = 0;

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
                          'Personal Details',
                          style: GoogleFonts.nunito(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 0
                            ? StepState.complete
                            : StepState.disabled,
                        content: Container()),
                    Step(
                        title: Text(
                          'Personal Details',
                          style: GoogleFonts.nunito(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 1
                            ? StepState.complete
                            : StepState.disabled,
                        content: Container()),
                    Step(
                        title: Text(
                          'Personal Details',
                          style: GoogleFonts.nunito(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 2
                            ? StepState.complete
                            : StepState.disabled,
                        content: Container())
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
    _currentStep < 2 ? setState(() => _currentStep += 1) : null;
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

  Future updatePersionalDetails(
      String id,
      String name,
      String email,
      String gender,
      String dob,
      String language,
      String skinColor,
      String hairStyle,
      String hairColor,
      String expertise,
      String country,
      String ustate,
      String city,
      String weight,
      String height,
      String chest,
      String waist,
      String hip,
      String eye,
      String passportStatus,
      String drivingStatus,
      String swimmingStatus,
      String danceStatus,
      String boldContentStatus,
      String printShootStatus,
      String bodyPrintShootStatus,
      String nudePrintShootStatus,
      String bikiniPrintShootStatus,
      String treainedActorStatus,
      String unionCardStatus,
      String experienceStatus,
      String expericenceYear,
      String expericenceArea,
      String instituteName
      //String busyStatus
      ) async {
    Response res = await Apis().updatePersionalDetails(
        id,
        name,
        email,
        gender,
        dob,
        language,
        skinColor,
        hairStyle,
        hairColor,
        expertise,
        country,
        ustate,
        city,
        weight,
        height,
        _userCategoryGender != "Transgender"
            ? _userCategoryGender == "Male"
                ? chest
                : ""
            : chest,
        _userCategoryGender != "Transgender"
            ? _userCategoryGender == "Male"
                ? ""
                : chest
            : "",
        waist,
        hip,
        eye,
        passportStatus,
        drivingStatus,
        swimmingStatus,
        danceStatus,
        boldContentStatus,
        printShootStatus,
        bodyPrintShootStatus,
        nudePrintShootStatus,
        bikiniPrintShootStatus,
        treainedActorStatus,
        unionCardStatus,
        experienceStatus,
        expericenceYear,
        expericenceArea,
        //busyStatus,
        disablitilyStatus == true ? "Yes" : "No",
        tBodyType == null ? "" : tBodyType!,
        tMaeritial == null ? "" : tMaeritial!,
        _userCategory,
        workshopStatus == true ? "Yes" : "No",
        instituteName,
        _address.text,
        _pincode.text,
        industry);
    var statusCode = res.statusCode;
    if (statusCode == 200) {
      var response = jsonDecode(res.body);
      String re = response["res"];
      String msg = response["msg"];
      if (re == "success") {
        Future.delayed(Duration(microseconds: 1), () {
          Navigator.pushNamed(context, PageRoutes.basic_profile_info);
          MyToast(message: msg).toast;
        });
      } else {
        MyToast(message: msg).toast;
      }
    }
  }

  //validation
  bool valid() {
    tname = _name.text;
    tEmailid = _email.text;
    tDob = _dob.text;
    tLang = LanguageList(lang, 1).createState().getSelectedList();
    tSkincolor = SkinColorSelectChip(skinColor).createState().getSelectedItem();
    tHairtype = HairTypeSelectChip(hair).createState().getSelectedItem();
    tHhaircolor =
        HairColorSelectChip(hairColor).createState().getSelectedItem();
    //tGender = GenderSelectChip(gender).createState().getSelectedItem();
    tGender = _userCategoryGender;
    tState = _state.text;
    tCity = _city.text;
    tEyeColor = EyeColorSelectChip(hair).createState().getSelectedItem();
    print(_userCategory);
    tWeight = _weight.text;
    print(tHairtype);
    if (tname.isEmpty) {
      MyToast(message: "Please Enter your name").toast;
      return false;
    } else if (tEmailid.isEmpty) {
      MyToast(message: "Please Enter your Email Id").toast;
      return false;
    } else if (tDob.isEmpty) {
      MyToast(message: "Please Enter your Dob").toast;
      return false;
    } /*  else if (tWeight.isEmpty) {
      MyToast(message: "Please Enter Your  Weight").toast;
      return false;
    } */
    else if (tCountry == null || tCountry!.isEmpty) {
      MyToast(message: "Please Choose Country").toast;
      return false;
    } else if (tState.isEmpty) {
      MyToast(message: "Please Choose State").toast;
      return false;
    } else if (tCity.isEmpty) {
      MyToast(message: "Plese Choose Your City").toast;
      return false;
    } else if (industry.isEmpty) {
      MyToast(message: "Plese Choose Your industry").toast;
      return false;
    } else if (_userCategory == "Artist" || _userCategory == "Model") {
      if (tLang!.isEmpty) {
        MyToast(message: "Please Choose Your Language").toast;
        return false;
      } else if (tHeight.isEmpty) {
        MyToast(message: "Please Choose Your Height").toast;
        return false;
      } else if (tChestSize.isEmpty) {
        MyToast(
          message: _userCategoryGender != "Transgender"
              ? _userCategoryGender == "Male"
                  ? "Please Choose Your Chest Size"
                  : "Please Choose Your Beast Size"
              : "Please Choose Your Chest Size",
        ).toast;
        return false;
      } else if (tWaistSize.isEmpty) {
        MyToast(message: "Please Choose Your Waist Size");
        return false;
      } else if (tHipSize.isEmpty) {
        MyToast(message: "Please Choose Your Hip Size");
        return false;
      } else if (tSkincolor.isEmpty) {
        MyToast(message: "Please Choose Your Skin Color").toast;
        return false;
      } else if (tHairtype.isEmpty) {
        MyToast(message: "Please Choose Your Hair Type").toast;
        return false;
      } else if (tHhaircolor.isEmpty) {
        MyToast(message: "Please Choose Your Hair Color").toast;
        return false;
      } else if (tEyeColor.isEmpty) {
        MyToast(message: "Please Choose Your Eye Color").toast;
        return false;
      } else if (tGender.isEmpty) {
        MyToast(message: "Please Choose Your Gender").toast;
        return false;
      }
      return true;
    } else if (_category.text.isEmpty) {
      MyToast(message: "Please Select Your Expertise").toast;
      return false;
    } else {
      return true;
    }
  }

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
