import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:web_project/app/data/provider/action_service.dart';
import 'package:web_project/app/data/provider/member_service.dart';

import '../ui/widget/baseTableCalendar.dart';
import '../ui/widget/bottomSheetContent.dart';

List firstChars = [
  "ㄱ",
  "ㄲ",
  "ㄴ",
  "ㄷ",
  "ㄸ",
  "ㄹ",
  "ㅁ",
  "ㅂ",
  "ㅃ",
  "ㅅ",
  "ㅆ",
  "ㅇ",
  "ㅈ",
  "ㅉ",
  "ㅊ",
  "ㅋ",
  "ㅌ",
  "ㅍ",
  "ㅎ"
];
List middleChars = [
  "ㅏ",
  "ㅐ",
  "ㅑ",
  "ㅒ",
  "ㅓ",
  "ㅔ",
  "ㅕ",
  "ㅖ",
  "ㅗ",
  "ㅘ",
  "ㅙ",
  "ㅚ",
  "ㅛ",
  "ㅜ",
  "ㅝ",
  "ㅞ",
  "ㅟ",
  "ㅠ",
  "ㅡ",
  "ㅢ",
  "ㅣ"
];

List lastChars = [
  "",
  "ㄱ",
  "ㄲ",
  "ㄳ",
  "ㄴ",
  "ㄵ",
  "ㄶ",
  "ㄷ",
  "ㄹ",
  "ㄺ",
  "ㄻ",
  "ㄼ",
  "ㄽ",
  "ㄾ",
  "ㄿ",
  "ㅀ",
  "ㅁ",
  "ㅂ",
  "ㅄ",
  "ㅅ",
  "ㅆ",
  "ㅇ",
  "ㅈ",
  "ㅊ",
  "ㅋ",
  "ㅌ",
  "ㅍ",
  "ㅎ"
];

class GlobalFunction {
  GlobalFunction();

  /* final firestore = FirebaseFirestore.instance;

  Future<void> readMemberListAtFirstTime(String uid) async {
    var result = await firestore.collection('member').where('uid', isEqualTo: uid)
        .orderBy('name', descending: false)
        .get();
        for(int i=0; i<result.docs.length; i++){
          print("result.docs[i].data() : ${result.docs[i].data()}");
        }
  } */
  String getActionPosition(
    String apparatunName, String actionName, List actionList) {
  String position = "";

  for (int i = 0; i < actionList.length; i++) {
    if ((actionList[i]['apparatus'] == apparatunName) &&
        (actionList[i]['name'] == actionName)) {
      position = actionList[i]['position'];
      break;
    }
  }

  return position;
}

  String getDateFromTimeStamp(var timestamp) {
    String date = "";

    date = DateFormat("yyyy-MM-dd").format(timestamp.toDate());

    return date;
  }

  int getDDayLeft(String date) {
    var _toDay = DateTime.now();
    // date = "2023-02-24";
    int difference =
        int.parse(_toDay.difference(DateTime.parse(date)).inDays.toString());

    print("difference : ${difference}");

    return difference;
  }

  Future<bool> readfavoriteMember(String uid, String docId) async {
    bool result = false;
    MemberService memberService = MemberService();
    await memberService
        .readIsFavorite(
      uid,
      docId,
    )
        .then((val) {
      result = val;
      print('[MI]회원정보 화면 _readfavoriteMember : 즐겨찾기 ${val}');
    });
    return result;
  }

  void updatefavoriteMember() {}

  Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  String getChosungFromString(String name) {
    String result = "";
    bool isKoreanName = RegExp(r'^[ㄱ-ㅎ|ㅏ-ㅑ|가-힣]*$').hasMatch(name);
    // print("isKoreanName : ${isKoreanName}");
    if (isKoreanName) {
      String element = "";
      String tmpStr = "";
      String varName = name;
      element = varName;

      var base = ((element.codeUnits[0].toInt()) - ('가'.codeUnits[0].toInt()));

      var firstCharPeriod = ('까'.codeUnits[0] - '가'.codeUnits[0]).toInt();
      var middleCharPeriod = ('개'.codeUnits[0] - '가'.codeUnits[0]).toInt();
      var chosung = firstChars[(base / firstCharPeriod).toInt()];
      // print("chosung : ${chosung}");
      var joongsung = middleChars[
          (((base - (firstCharPeriod)) / middleCharPeriod) % 21).toInt()];
      // print("joongsung : ${joongsung}");
      var jongsung = lastChars[base % 28];
      // print("jongsung : ${jongsung}");

      result = chosung;
    } else {
      String firstChar = name.trim().toLowerCase().substring(0, 1);
      // print("firstChar : ${firstChar}");
      result = firstChar;
    }

    return result;
  }

  // https://smilehugo.tistory.com/entry/javascript-algorithm-a-korean-character-breakdown-into-array
  bool searchString(String name, String searchString, String searchType) {
    print("convertStringArray is called => searchString : ${searchString}");
    bool result = false;
    List searchedList = [];
    String varName = "";

    varName = name.trim();
    print("varName : ${varName}");
    List varStrList = [];
    varName.characters.forEach((element) {
      varStrList.add(element);
    });
    List searchStrList = [];
    searchString.characters.forEach((element) {
      searchStrList.add(element);
    });

    String nameChoString = "";
    String nameChoJoongJongString = "";
    String searchChoString = "";
    String searchChoJoongJongString = "";

    List nameChoList = [];
    List targetNameList = [];
    // if (isKorean(varName)) {
    bool isKoreanSearchString =
        RegExp(r'^[ㄱ-ㅎ|ㅏ-ㅑ|가-힣]*$').hasMatch(searchString);
    bool isKoreanNameString = RegExp(r'^[ㄱ-ㅎ|ㅏ-ㅑ|가-힣]*$').hasMatch(name);
    print("isKoreanSearchString : ${isKoreanSearchString}");
    print("isKoreanNameString : ${isKoreanNameString}");
    if (isKoreanSearchString && isKoreanNameString) {
      String element = "";
      String tmpStr = "";
      for (int i = 0; i < varStrList.length; i++) {
        element = varStrList[i];

        var base =
            ((element.codeUnits[0].toInt()) - ('가'.codeUnits[0].toInt()));

        var firstCharPeriod = ('까'.codeUnits[0] - '가'.codeUnits[0]).toInt();
        var middleCharPeriod = ('개'.codeUnits[0] - '가'.codeUnits[0]).toInt();
        var chosung = firstChars[(base / firstCharPeriod).toInt()];
        print("chosung : ${chosung}");
        var joongsung = middleChars[
            (((base - (firstCharPeriod)) / middleCharPeriod) % 21).toInt()];
        // print("joongsung : ${joongsung}");
        var jongsung = lastChars[base % 28];
        // print("jongsung : ${jongsung}");

        nameChoJoongJongString += chosung + joongsung + jongsung;
        nameChoString += chosung;
        tmpStr = varName.substring(0, i + 1);
        targetNameList.add(tmpStr);
        // print("varName.substring(0,${i}+1) : ${varName.substring(0,i+1)}");
      }

      List resultList = [];
      for (int i = 0; i < targetNameList.length; i++) {
        resultList.add(targetNameList[i] +
            nameChoString.substring(i + 1, nameChoString.length));
        print("resultList[${i}] : ${resultList[i]}");
        if (targetNameList.length - 1 == i) {
          resultList.add(nameChoString);
        }
      }

      for (int i = 0; i < searchStrList.length; i++) {
        element = searchStrList[i];
        if (element.codeUnits[0] >= 12593 && element.codeUnits[0] <= 12643) {
          searchChoJoongJongString += element;
        } else {
          var base =
              ((element.codeUnits[0].toInt()) - ('가'.codeUnits[0].toInt()));

          var firstCharPeriod = ('까'.codeUnits[0] - '가'.codeUnits[0]).toInt();
          var middleCharPeriod = ('개'.codeUnits[0] - '가'.codeUnits[0]).toInt();
          var chosung = firstChars[(base / firstCharPeriod).toInt()];
          print("chosung : ${chosung}");
          var joongsung = middleChars[
              (((base - (firstCharPeriod)) / middleCharPeriod) % 21).toInt()];
          // print("joongsung : ${joongsung}");
          var jongsung = lastChars[base % 28];
          // print("jongsung : ${jongsung}");

          searchChoJoongJongString += chosung + joongsung + jongsung;
          searchChoString += chosung;
        }
      }

      /* if (nameChoString.contains(searchChoString)) {
        result = true;
      }else if(varName.contains(searchChoString)){
        result = true;
      } */
      if (searchChoJoongJongString.isNotEmpty &&
          nameChoJoongJongString.contains(searchChoJoongJongString)) {
        print("nameChoJoongJongString : ${nameChoJoongJongString}");
        print("searchChoJoongJongString : ${searchChoJoongJongString}");
        List tmpChoList = nameChoJoongJongString.characters.toList();
        List tmpSrchList = searchChoJoongJongString.characters.toList();
        for (int i = 0; i < nameChoJoongJongString.length; i++) {
          if (tmpSrchList.length > i) {
            if (tmpChoList[i] == tmpSrchList[i]) {
              result = true;
            } else {
              result = false;
              break;
            }
          }
        }
      } else if (nameChoString.contains(searchChoString)) {
        /* for (int i = 0; i < resultList.length; i++) {
          if (resultList[i].contains(searchChoString)) {
            print("resultList[${i}] : ${resultList[i]}");
            result = true;
            break;
          }
        } */
        List tmpChoList = nameChoString.characters.toList();
        List tmpSrchList = searchString.characters.toList();
        for (int i = 0; i < nameChoString.length; i++) {
          if (tmpSrchList.length > i) {
            if (tmpChoList[i] == tmpSrchList[i]) {
              result = true;
            } else {
              result = false;
              break;
            }
          }
        }
      }
    } else {
      if (varName.trim().toLowerCase().contains(searchString.toLowerCase())) {
        if (searchType == "member") {
          List tmpChoList = varName.trim().toLowerCase().characters.toList();
          List tmpSrchList = searchString.toLowerCase().characters.toList();
          for (int i = 0; i < varName.trim().length; i++) {
            if (tmpSrchList.length > i) {
              if (tmpChoList[i] == tmpSrchList[i]) {
                result = true;
              } else {
                result = false;
                break;
              }
            }
          }
        } else if (searchType == "action") {
          result = true;
        }
      }
    }

    return result;
  }

  /* isKorean함수는 말 그대로 해당 String이 한글인지 확인하는 함수이다.
      한글을 Unicode로 바꾸었을때 자음들은 12593부터 12643사이의 값을 가진다
      자음과 모음을 합친 경우 -> '가' 부터 '힣'까지의 값들은 44032부터 55203까지의 값을 가진다.
      그렇기에 확인하고자 하는 String을 Unicode로 변환후 해당값을 확인하면 된다. */
  bool isKorean(String searchString) {
    bool isKorean = false;
    int inputToUniCode = searchString.codeUnits[0];
    print("inputToUniCode : ${inputToUniCode}");

    isKorean = (inputToUniCode >= 12593 && inputToUniCode <= 12643)
        ? true
        : (inputToUniCode >= 44032 && inputToUniCode <= 55203)
            ? true
            : false;

    return isKorean;
  }

  void showBottomSheetContent(BuildContext context,
      {Function? customEditFunction, Function? customDeleteFunction}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (context) {
        return BottomSheetContent(
          customEditFunction: customEditFunction,
          customDeleteFunction: customDeleteFunction,
        );
      },
    );
  }

  void inititalizeBools(List<bool> boolList, bool initState) {
    for (int i = 0; i < boolList.length; i++) {
      boolList[i] = initState;
    }
  }

  void clearTextEditController(List<TextEditingController> controllerList) {
    for (int i = 0; i < controllerList.length; i++) {
      controllerList[i].clear();
    }
  }

  getWidgetSize(GlobalKey key) {
    if (key.currentContext != null) {
      final RenderBox renderBox =
          key.currentContext!.findRenderObject() as RenderBox;

      Size size = renderBox.size;
      return size;
    }
  }

  bool textNullCheck(
    BuildContext context,
    TextEditingController checkController,
    String controllerName,
  ) {
    bool notEmpty = true;
    String tmpVal = checkController.text.trim();
    if (!tmpVal.isNotEmpty) {
      print("${controllerName} is Empty");
      notEmpty = !notEmpty;

      // 로그인 성공
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${controllerName} 항목을 입력 해주세요."),
      ));
    }

    return notEmpty;
  }

  bool selectNullCheck(
    BuildContext context,
    SingleValueDropDownController checkController,
    String controllerName,
  ) {
    bool notEmpty = true;
    if (!checkController.dropDownValue!.value.isNotEmpty) {
      print("${controllerName} is Empty");
      notEmpty = !notEmpty;

      // 로그인 성공
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${controllerName} 항목을 입력 해주세요."),
      ));
    }

    return notEmpty;
  }

  Future<void> getDateFromCalendar(
      BuildContext context,
      TextEditingController customController,
      String pageName,
      String selectedDate) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BaseTableCalendar(
            () {},
            false,
            selectedDate: selectedDate,
            pageName: pageName,
            eventList: [],
            hideBottonDateText: false,
            hideButton: false,
          ),
          fullscreenDialog: true,
        ));

    if (!(result == null)) {
      String formatedDate = DateFormat("yyyy-MM-dd")
          .format(DateTime(result.year, result.month, result.day));

      customController.text = formatedDate;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${pageName} : ${formatedDate}"),
        ),
      );
      (context as Element).reassemble();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${pageName}을 선택해주세요."),
      ));
    }
  }

  void createDummy(ActionService actionService) {
    // DB INSERT NEW TEST
    actionService.createDummy("TEST1", "TEST1", "supine", "TEST1", "Ab Prep",
        "TEST1", "AB PREP", "ab prep", ["TEST1", "test1"]);

    // DB SEARCH TMP
    // actionService.createDummy("MAT", "", "supine", "", "Ab Prep", "김주아",
    //     "AB PREP", "ab prep", ["ab", "prep"]);
    // actionService.createDummy("MAT", "", "sitting", "", "Abs Series", "김주아",
    //     "ABS SERIES", "abs series", ["abs", "series"]);
    // actionService.createDummy("RE", "", "supine", "", "Adductor Stretch", "김주아",
    //     "ADDUCTOR STRETCH", "adductor stretch", ["adductor", "stretch"]);
    // actionService.createDummy("CA", "", "supine", "", "Airplane", "김주아",
    //     "AIRPLANE", "airplane", ["airplane"]);
    // actionService.createDummy("RE", "", "kneeling", "", "Arm Circles", "김주아",
    //     "ARM CIRCLES", "arm circles", ["arm", "circles"]);
    // actionService.createDummy("CH", "", "standing", "", "Arm Frog", "김주아",
    //     "ARM FROG", "arm frog", ["arm", "frog"]);
    // actionService.createDummy("CA", "", "sitting", "", "Back Rowing", "김주아",
    //     "BACK ROWING", "back rowing", ["back", "rowing"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Back Rowing Prep",
    //     "김주아",
    //     "BACK ROWING PREP",
    //     "back rowing prep",
    //     ["back", "rowing", "prep"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "sitting",
    //     "",
    //     "Back Rowing Prep Series",
    //     "김주아",
    //     "BACK ROWING PREP SERIES",
    //     "back rowing prep series",
    //     ["back", "rowing", "prep", "series"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Balance Control Back",
    //     "김주아",
    //     "BALANCE CONTROL BACK",
    //     "balance control back",
    //     ["balance", "control", "back"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "plank",
    //     "",
    //     "Balance Control Front",
    //     "김주아",
    //     "BALANCE CONTROL FRONT",
    //     "balance control front",
    //     ["balance", "control", "front"]);
    // actionService.createDummy("MAT", "", "sitting", "", "Balance Point", "김주아",
    //     "BALANCE POINT", "balance point", ["balance", "point"]);
    // actionService.createDummy("BA", "", "standing", "", "Ballet Stretch", "김주아",
    //     "BALLET STRETCH", "ballet stretch", ["ballet", "stretch"]);
    // actionService.createDummy("RE", "", "supine", "", "Bend&Stretch", "김주아",
    //     "BEND&STRETCH", "bend&stretch", ["bend&stretch"]);
    // actionService.createDummy("MAT", "", "sitting", "", "Boomerang", "김주아",
    //     "BOOMERANG", "boomerang", ["boomerang"]);
    // actionService.createDummy("MAT", "", "prone", "", "Breast Stroke", "김주아",
    //     "BREAST STROKE", "breast stroke", ["breast", "stroke"]);
    // actionService.createDummy("MAT", "", "supine", "", "Breathing", "김주아",
    //     "BREATHING", "breathing", ["breathing"]);
    // actionService.createDummy("CA", "", "supine", "", "Breathing", "김주아",
    //     "BREATHING", "breathing", ["breathing"]);
    // actionService.createDummy("MAT", "", "quadruped", "", "Cat Stretch", "김주아",
    //     "CAT STRETCH", "cat stretch", ["cat", "stretch"]);
    // actionService.createDummy("RE", "", "kneeling", "", "Chest Expansion",
    //     "김주아", "CHEST EXPANSION", "chest expansion", ["chest", "expansion"]);
    // actionService.createDummy("MAT", "", "side lying", "", "Clam Shell", "김주아",
    //     "CLAM SHELL", "clam shell", ["clam", "shell"]);
    // actionService.createDummy("MAT", "", "supine", "", "Control Balance", "김주아",
    //     "CONTROL BALANCE", "control balance", ["control", "balance"]);
    // actionService.createDummy("RE", "", "supine", "", "Coordination", "김주아",
    //     "COORDINATION", "coordination", ["coordination"]);
    // actionService.createDummy("MAT", "", "supine", "", "Corkscrew", "김주아",
    //     "CORKSCREW", "corkscrew", ["corkscrew"]);
    // actionService.createDummy("RE", "", "supine", "", "Corscrew", "김주아",
    //     "CORSCREW", "corscrew", ["corscrew"]);
    // actionService.createDummy(
    //     "MAT", "", "sitting", "", "Crab", "김주아", "CRAB", "crab", ["crab"]);
    // actionService.createDummy("MAT", "", "supine", "", "Criss Cross", "김주아",
    //     "CRISS CROSS", "criss cross", ["criss", "cross"]);
    // actionService.createDummy("MAT", "", "prone", "", "Double Leg Kicks", "김주아",
    //     "DOUBLE LEG KICKS", "double leg kicks", ["double", "leg", "kicks"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "supine",
    //     "",
    //     "Double Leg Stretch",
    //     "김주아",
    //     "DOUBLE LEG STRETCH",
    //     "double leg stretch",
    //     ["double", "leg", "stretch"]);
    // actionService.createDummy("RE", "", "quadruped", "", "Down Stretch", "김주아",
    //     "DOWN STRETCH", "down stretch", ["down", "stretch"]);
    // actionService.createDummy("RE", "", "standing", "", "Elephant", "김주아",
    //     "ELEPHANT", "elephant", ["elephant"]);
    // actionService.createDummy("RE", "", "supine", "", "Footwork Series", "김주아",
    //     "FOOTWORK SERIES", "footwork series", ["footwork", "series"]);
    // actionService.createDummy("CH", "", "sitting", "", "Footwork Series", "김주아",
    //     "FOOTWORK SERIES", "footwork series", ["footwork", "series"]);
    // actionService.createDummy(
    //     "RE", "", "supine", "", "Frog", "김주아", "FROG", "frog", ["frog"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "prone",
    //     "",
    //     "Frog Hip Extension",
    //     "김주아",
    //     "FROG HIP EXTENSION",
    //     "frog hip extension",
    //     ["frog", "hip", "extension"]);
    // actionService.createDummy("CA", "", "sitting", "", "Front Rowing", "김주아",
    //     "FRONT ROWING", "front rowing", ["front", "rowing"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Front Rowing Prep",
    //     "김주아",
    //     "FRONT ROWING PREP",
    //     "front rowing prep",
    //     ["front", "rowing", "prep"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "sitting",
    //     "",
    //     "Front Rowing Prep Series",
    //     "김주아",
    //     "FRONT ROWING PREP SERIES",
    //     "front rowing prep series",
    //     ["front", "rowing", "prep", "series"]);
    // actionService.createDummy("RE", "", "standing", "", "Front Split", "김주아",
    //     "FRONT SPLIT", "front split", ["front", "split"]);
    // actionService.createDummy("CA", "", "supine", "", "Full Hanging", "김주아",
    //     "FULL HANGING", "full hanging", ["full", "hanging"]);
    // actionService.createDummy("CA", "", "prone", "", "Full Swan", "김주아",
    //     "FULL SWAN", "full swan", ["full", "swan"]);
    // actionService.createDummy("CH", "", "standing", "", "Going Up Front", "김주아",
    //     "GOING UP FRONT", "going up front", ["going", "up", "front"]);
    // actionService.createDummy("CH", "", "standing", "", "Going Up Side", "김주아",
    //     "GOING UP SIDE", "going up side", ["going", "up", "side"]);
    // actionService.createDummy("CA", "", "supine", "", "Half Hanging", "김주아",
    //     "HALF HANGING", "half hanging", ["half", "hanging"]);
    // actionService.createDummy("MAT", "", "sitting", "", "Half Roll Back", "김주아",
    //     "HALF ROLL BACK", "half roll back", ["half", "roll", "back"]);
    // actionService.createDummy("MAT", "", "prone", "", "Half Swan", "김주아",
    //     "HALF SWAN", "half swan", ["half", "swan"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "supine",
    //     "",
    //     "Hams Press Hips Down",
    //     "김주아",
    //     "HAMS PRESS HIPS DOWN",
    //     "hams press hips down",
    //     ["hams", "press", "hips", "down"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "supine",
    //     "",
    //     "Hams Press Hips Up",
    //     "김주아",
    //     "HAMS PRESS HIPS UP",
    //     "hams press hips up",
    //     ["hams", "press", "hips", "up"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "standing",
    //     "",
    //     "Hanging Pull Ups",
    //     "김주아",
    //     "HANGING PULL UPS",
    //     "hanging pull ups",
    //     ["hanging", "pull", "ups"]);
    // actionService.createDummy("MAT", "", "supine", "", "High Bicycle", "김주아",
    //     "HIGH BICYCLE", "high bicycle", ["high", "bicycle"]);
    // actionService.createDummy("MAT", "", "supine", "", "High Scissors", "김주아",
    //     "HIGH SCISSORS", "high scissors", ["high", "scissors"]);
    // actionService.createDummy("MAT", "", "sitting", "", "Hip Circles", "김주아",
    //     "HIP CIRCLES", "hip circles", ["hip", "circles"]);
    // actionService.createDummy("CA", "", "side lying", "", "Hip Opener", "김주아",
    //     "HIP OPENER", "hip opener", ["hip", "opener"]);
    // actionService.createDummy("MAT", "", "supine", "", "Hip Release", "김주아",
    //     "HIP RELEASE", "hip release", ["hip", "release"]);
    // actionService.createDummy("MAT", "", "supine", "", "Hip Roll", "김주아",
    //     "HIP ROLL", "hip roll", ["hip", "roll"]);
    // actionService.createDummy("CH", "", "sitting", "", "Horse Back", "김주아",
    //     "HORSE BACK", "horse back", ["horse", "back"]);
    // actionService.createDummy("BA", "", "sitting", "", "Horse Back", "김주아",
    //     "HORSE BACK", "horse back", ["horse", "back"]);
    // actionService.createDummy("MAT", "", "supine", "", "Hundred", "김주아",
    //     "HUNDRED", "hundred", ["hundred"]);
    // actionService.createDummy("RE", "", "supine", "", "Hundred", "김주아",
    //     "HUNDRED", "hundred", ["hundred"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "supine",
    //     "",
    //     "Imprinting Transition",
    //     "김주아",
    //     "IMPRINTING TRANSITION",
    //     "imprinting transition",
    //     ["imprinting", "transition"]);
    // actionService.createDummy("MAT", "", "supine", "", "Jack Knife", "김주아",
    //     "JACK KNIFE", "jack knife", ["jack", "knife"]);
    // actionService.createDummy("CH", "", "supine", "", "Jack Knife", "김주아",
    //     "JACK KNIFE", "jack knife", ["jack", "knife"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "standing",
    //     "",
    //     "Knee Raise Series",
    //     "김주아",
    //     "KNEE RAISE SERIES",
    //     "knee raise series",
    //     ["knee", "raise", "series"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "quadruped",
    //     "",
    //     "Knee Stretch Arches",
    //     "김주아",
    //     "KNEE STRETCH ARCHES",
    //     "knee stretch arches",
    //     ["knee", "stretch", "arches"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "quadruped",
    //     "",
    //     "Knee Stretch Knees Off",
    //     "김주아",
    //     "KNEE STRETCH KNEES OFF",
    //     "knee stretch knees off",
    //     ["knee", "stretch", "knees", "off"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "quadruped",
    //     "",
    //     "Knee Stretch Round",
    //     "김주아",
    //     "KNEE STRETCH ROUND",
    //     "knee stretch round",
    //     ["knee", "stretch", "round"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "quadruped",
    //     "",
    //     "Knee Stretch Series",
    //     "김주아",
    //     "KNEE STRETCH SERIES",
    //     "knee stretch series",
    //     ["knee", "stretch", "series"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "kneeling",
    //     "",
    //     "Kneeling Ballet Stretches",
    //     "김주아",
    //     "KNEELING BALLET STRETCHES",
    //     "kneeling ballet stretches",
    //     ["kneeling", "ballet", "stretches"]);
    // actionService.createDummy("CA", "", "kneeling", "", "Kneeling Cat", "김주아",
    //     "KNEELING CAT", "kneeling cat", ["kneeling", "cat"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "kneeling",
    //     "",
    //     "Kneeling Chest Expansion",
    //     "김주아",
    //     "KNEELING CHEST EXPANSION",
    //     "kneeling chest expansion",
    //     ["kneeling", "chest", "expansion"]);
    // actionService.createDummy("CH", "", "kneeling", "", "Kneeling Mermaid",
    //     "김주아", "KNEELING MERMAID", "kneeling mermaid", ["kneeling", "mermaid"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "kneeling",
    //     "",
    //     "Kneeling Side Kick",
    //     "김주아",
    //     "KNEELING SIDE KICK",
    //     "kneeling side kick",
    //     ["kneeling", "side", "kick"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "kneeling",
    //     "",
    //     "Kneeling Side Kicks",
    //     "김주아",
    //     "KNEELING SIDE KICKS",
    //     "kneeling side kicks",
    //     ["kneeling", "side", "kicks"]);
    // actionService.createDummy("BA", "", "standing", "", "Lay Backs", "김주아",
    //     "LAY BACKS", "lay backs", ["lay", "backs"]);
    // actionService.createDummy("RE", "", "supine", "", "Leg Circles", "김주아",
    //     "LEG CIRCLES", "leg circles", ["leg", "circles"]);
    // actionService.createDummy("MAT", "", "plank", "", "Leg Pull Back", "김주아",
    //     "LEG PULL BACK", "leg pull back", ["leg", "pull", "back"]);
    // actionService.createDummy("MAT", "", "plank", "", "Leg Pull Front", "김주아",
    //     "LEG PULL FRONT", "leg pull front", ["leg", "pull", "front"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "supine",
    //     "",
    //     "Leg Spring Series",
    //     "김주아",
    //     "LEG SPRING SERIES",
    //     "leg spring series",
    //     ["leg", "spring", "series"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "side lying",
    //     "",
    //     "Leg Spring Side Kick Series",
    //     "김주아",
    //     "LEG SPRING SIDE KICK SERIES",
    //     "leg spring side kick series",
    //     ["leg", "spring", "side", "kick", "series"]);
    // actionService.createDummy("RE", "", "supine", "", "Leg Strap Series", "김주아",
    //     "LEG STRAP SERIES", "leg strap series", ["leg", "strap", "series"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Long Back Stretch",
    //     "김주아",
    //     "LONG BACK STRETCH",
    //     "long back stretch",
    //     ["long", "back", "stretch"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "prone",
    //     "",
    //     "Long Box Backstroke",
    //     "김주아",
    //     "LONG BOX BACKSTROKE",
    //     "long box backstroke",
    //     ["long", "box", "backstroke"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "prone",
    //     "",
    //     "Long Box Horse Back",
    //     "김주아",
    //     "LONG BOX HORSE BACK",
    //     "long box horse back",
    //     ["long", "box", "horse", "back"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "prone",
    //     "",
    //     "Long Box Pulling Straps",
    //     "김주아",
    //     "LONG BOX PULLING STRAPS",
    //     "long box pulling straps",
    //     ["long", "box", "pulling", "straps"]);
    // actionService.createDummy("RE", "", "prone", "", "Long Box Series", "김주아",
    //     "LONG BOX SERIES", "long box series", ["long", "box", "series"]);
    // actionService.createDummy("RE", "", "prone", "", "Long Box T Shape", "김주아",
    //     "LONG BOX T SHAPE", "long box t shape", ["long", "box", "t", "shape"]);
    // actionService.createDummy("RE", "", "prone", "", "Long Box Teaser", "김주아",
    //     "LONG BOX TEASER", "long box teaser", ["long", "box", "teaser"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "supine",
    //     "",
    //     "Long Spine Massage",
    //     "김주아",
    //     "LONG SPINE MASSAGE",
    //     "long spine massage",
    //     ["long", "spine", "massage"]);
    // actionService.createDummy("RE", "", "plank", "", "Long Stretch", "김주아",
    //     "LONG STRETCH", "long stretch", ["long", "stretch"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "plank",
    //     "",
    //     "Long Stretch Series",
    //     "김주아",
    //     "LONG STRETCH SERIES",
    //     "long stretch series",
    //     ["long", "stretch", "series"]);
    // actionService.createDummy("MAT", "", "supine", "", "Lower And Lift", "김주아",
    //     "LOWER AND LIFT", "lower and lift", ["lower", "and", "lift"]);
    // actionService.createDummy("RE", "", "supine", "", "Lower And Lift", "김주아",
    //     "LOWER AND LIFT", "lower and lift", ["lower", "and", "lift"]);
    // actionService.createDummy(
    //     "CH", "", "standing", "", "Lunge", "김주아", "LUNGE", "lunge", ["lunge"]);
    // actionService.createDummy("MAT", "", "sitting", "", "Mermaid", "김주아",
    //     "MERMAID", "mermaid", ["mermaid"]);
    // actionService.createDummy("CA", "", "sitting", "", "Mermaid", "김주아",
    //     "MERMAID", "mermaid", ["mermaid"]);
    // actionService.createDummy("CH", "", "sitting", "", "Mermaid", "김주아",
    //     "MERMAID", "mermaid", ["mermaid"]);
    // actionService.createDummy("CA", "", "supine", "", "Midback Series", "김주아",
    //     "MIDBACK SERIES", "midback series", ["midback", "series"]);
    // actionService.createDummy("CA", "", "supine", "", "Monkey", "김주아", "MONKEY",
    //     "monkey", ["monkey"]);
    // actionService.createDummy("CH", "", "standing", "", "Mountain Climb", "김주아",
    //     "MOUNTAIN CLIMB", "mountain climb", ["mountain", "climb"]);
    // actionService.createDummy("MAT", "", "sitting", "", "Neck Pull", "김주아",
    //     "NECK PULL", "neck pull", ["neck", "pull"]);
    // actionService.createDummy("CH", "", "prone", "", "One Arm Press", "김주아",
    //     "ONE ARM PRESS", "one arm press", ["one", "arm", "press"]);
    // actionService.createDummy("MAT", "", "sitting", "", "Open Leg Rocker",
    //     "김주아", "OPEN LEG ROCKER", "open leg rocker", ["open", "leg", "rocker"]);
    // actionService.createDummy("RE", "", "supine", "", "Overhead", "김주아",
    //     "OVERHEAD", "overhead", ["overhead"]);
    // actionService.createDummy("CA", "", "supine", "", "Parakeet", "김주아",
    //     "PARAKEET", "parakeet", ["parakeet"]);
    // actionService.createDummy("RE", "", "supine", "", "Pelvic Lift", "김주아",
    //     "PELVIC LIFT", "pelvic lift", ["pelvic", "lift"]);
    // actionService.createDummy("MAT", "", "supine", "", "Pelvic Movement", "김주아",
    //     "PELVIC MOVEMENT", "pelvic movement", ["pelvic", "movement"]);
    // actionService.createDummy("CA", "", "sitting", "", "Port De Bras", "김주아",
    //     "PORT DE BRAS", "port de bras", ["port", "de", "bras"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "sitting",
    //     "",
    //     "Press Down Teaser",
    //     "김주아",
    //     "PRESS DOWN TEASER",
    //     "press down teaser",
    //     ["press", "down", "teaser"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "prone",
    //     "",
    //     "Prone Heel Squeeze",
    //     "김주아",
    //     "PRONE HEEL SQUEEZE",
    //     "prone heel squeeze",
    //     ["prone", "heel", "squeeze"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "prone",
    //     "",
    //     "Prone Leg Lift Series",
    //     "김주아",
    //     "PRONE LEG LIFT SERIES",
    //     "prone leg lift series",
    //     ["prone", "leg", "lift", "series"]);
    // actionService.createDummy(
    //     "BA",
    //     "",
    //     "prone",
    //     "",
    //     "Prone Leg Lift Series",
    //     "김주아",
    //     "PRONE LEG LIFT SERIES",
    //     "prone leg lift series",
    //     ["prone", "leg", "lift", "series"]);
    // actionService.createDummy("CH", "", "standing", "", "Pull Up", "김주아",
    //     "PULL UP", "pull up", ["pull", "up"]);
    // actionService.createDummy("CH", "", "standing", "", "Push Down", "김주아",
    //     "PUSH DOWN", "push down", ["push", "down"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "standing",
    //     "",
    //     "Push Down With One Arm",
    //     "김주아",
    //     "PUSH DOWN WITH ONE ARM",
    //     "push down with one arm",
    //     ["push", "down", "with", "one", "arm"]);
    // actionService.createDummy("CA", "", "sitting", "", "Push Through", "김주아",
    //     "PUSH THROUGH", "push through", ["push", "through"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "supine",
    //     "",
    //     "Push Thru With Feet",
    //     "김주아",
    //     "PUSH THRU WITH FEET",
    //     "push thru with feet",
    //     ["push", "thru", "with", "feet"]);
    // actionService.createDummy("MAT", "", "plank", "", "Push Ups", "김주아",
    //     "PUSH UPS", "push ups", ["push", "ups"]);
    // actionService.createDummy("MAT", "", "prone", "", "Rocking", "김주아",
    //     "ROCKING", "rocking", ["rocking"]);
    // actionService.createDummy("CA", "", "sitting", "", "Roll Back Bar", "김주아",
    //     "ROLL BACK BAR", "roll back bar", ["roll", "back", "bar"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "sitting",
    //     "",
    //     "Roll Back With One Arm",
    //     "김주아",
    //     "ROLL BACK WITH ONE ARM",
    //     "roll back with one arm",
    //     ["roll", "back", "with", "one", "arm"]);
    // actionService.createDummy("CA", "", "sitting", "", "Roll Down", "김주아",
    //     "ROLL DOWN", "roll down", ["roll", "down"]);
    // actionService.createDummy("BA", "", "sitting", "", "Roll Down Round", "김주아",
    //     "ROLL DOWN ROUND", "roll down round", ["roll", "down", "round"]);
    // actionService.createDummy(
    //     "BA",
    //     "",
    //     "sitting",
    //     "",
    //     "Roll Down Straight",
    //     "김주아",
    //     "ROLL DOWN STRAIGHT",
    //     "roll down straight",
    //     ["roll", "down", "straight"]);
    // actionService.createDummy("MAT", "", "supine", "", "Roll Over", "김주아",
    //     "ROLL OVER", "roll over", ["roll", "over"]);
    // actionService.createDummy("CH", "", "supine", "", "Roll Over", "김주아",
    //     "ROLL OVER", "roll over", ["roll", "over"]);
    // actionService.createDummy("CA", "", "supine", "", "Roll Up", "김주아",
    //     "ROLL UP", "roll up", ["roll", "up"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "sitting",
    //     "",
    //     "Rolling Like A Ball",
    //     "김주아",
    //     "ROLLING LIKE A BALL",
    //     "rolling like a ball",
    //     ["rolling", "like", "a", "ball"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Rowing 90 Degrees",
    //     "김주아",
    //     "ROWING 90 DEGREES",
    //     "rowing 90 degrees",
    //     ["rowing", "90", "degrees"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Rowing From The Chest",
    //     "김주아",
    //     "ROWING FROM THE CHEST",
    //     "rowing from the chest",
    //     ["rowing", "from", "the", "chest"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Rowing From The Hips",
    //     "김주아",
    //     "ROWING FROM THE HIPS",
    //     "rowing from the hips",
    //     ["rowing", "from", "the", "hips"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Rowing Hug The Tree",
    //     "김주아",
    //     "ROWING HUG THE TREE",
    //     "rowing hug the tree",
    //     ["rowing", "hug", "the", "tree"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Rowing Into The Sternum",
    //     "김주아",
    //     "ROWING INTO THE STERNUM",
    //     "rowing into the sternum",
    //     ["rowing", "into", "the", "sternum"]);
    // actionService.createDummy("RE", "", "sitting", "", "Rowing Salute", "김주아",
    //     "ROWING SALUTE", "rowing salute", ["rowing", "salute"]);
    // actionService.createDummy("RE", "", "sitting", "", "Rowing Series", "김주아",
    //     "ROWING SERIES", "rowing series", ["rowing", "series"]);
    // actionService.createDummy("RE", "", "sitting", "", "Rowing Shave", "김주아",
    //     "ROWING SHAVE", "rowing shave", ["rowing", "shave"]);
    // actionService.createDummy("RE", "", "supine", "", "Running", "김주아",
    //     "RUNNING", "running", ["running"]);
    // actionService.createDummy("RE", "", "standing", "", "Russian Split", "김주아",
    //     "RUSSIAN SPLIT", "russian split", ["russian", "split"]);
    // actionService.createDummy(
    //     "MAT", "", "sitting", "", "Saw", "김주아", "SAW", "saw", ["saw"]);
    // actionService.createDummy("CH", "", "prone", "", "Scapula Isolation", "김주아",
    //     "SCAPULA ISOLATION", "scapula isolation", ["scapula", "isolation"]);
    // actionService.createDummy("MAT", "", "supine", "", "Scapula Movement",
    //     "김주아", "SCAPULA MOVEMENT", "scapula movement", ["scapula", "movement"]);
    // actionService.createDummy("MAT", "", "supine", "", "Scissors", "김주아",
    //     "SCISSORS", "scissors", ["scissors"]);
    // actionService.createDummy(
    //     "MAT", "", "sitting", "", "Seal", "김주아", "SEAL", "seal", ["seal"]);
    // actionService.createDummy("RE", "", "supine", "", "Semi-Circle", "김주아",
    //     "SEMI-CIRCLE", "semi-circle", ["semi-circle"]);
    // actionService.createDummy("RE", "", "sitting", "", "Short Box Round", "김주아",
    //     "SHORT BOX ROUND", "short box round", ["short", "box", "round"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Short Box Series",
    //     "김주아",
    //     "SHORT BOX SERIES",
    //     "short box series",
    //     ["short", "box", "series"]);
    // actionService.createDummy(
    //     "BA",
    //     "",
    //     "sitting",
    //     "",
    //     "Short Box Series",
    //     "김주아",
    //     "SHORT BOX SERIES",
    //     "short box series",
    //     ["short", "box", "series"]);
    // actionService.createDummy("RE", "", "sitting", "", "Short Box Side", "김주아",
    //     "SHORT BOX SIDE", "short box side", ["short", "box", "side"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Short Box Straight",
    //     "김주아",
    //     "SHORT BOX STRAIGHT",
    //     "short box straight",
    //     ["short", "box", "straight"]);
    // actionService.createDummy("RE", "", "sitting", "", "Short Box Tree", "김주아",
    //     "SHORT BOX TREE", "short box tree", ["short", "box", "tree"]);
    // actionService.createDummy("RE", "", "sitting", "", "Short Box Twist", "김주아",
    //     "SHORT BOX TWIST", "short box twist", ["short", "box", "twist"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Short Box Twist And Reach",
    //     "김주아",
    //     "SHORT BOX TWIST AND REACH",
    //     "short box twist and reach",
    //     ["short", "box", "twist", "and", "reach"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "supine",
    //     "",
    //     "Short Spine Massage",
    //     "김주아",
    //     "SHORT SPINE MASSAGE",
    //     "short spine massage",
    //     ["short", "spine", "massage"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "supine",
    //     "",
    //     "Shoulder And Chest Opener",
    //     "김주아",
    //     "SHOULDER AND CHEST OPENER",
    //     "shoulder and chest opener",
    //     ["shoulder", "and", "chest", "opener"]);
    // actionService.createDummy("MAT", "", "supine", "", "Shoulder Bridge", "김주아",
    //     "SHOULDER BRIDGE", "shoulder bridge", ["shoulder", "bridge"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "sitting",
    //     "",
    //     "Side Arm Sitting",
    //     "김주아",
    //     "SIDE ARM SITTING",
    //     "side arm sitting",
    //     ["side", "arm", "sitting"]);
    // actionService.createDummy("MAT", "", "sitting", "", "Side Bend", "김주아",
    //     "SIDE BEND", "side bend", ["side", "bend"]);
    // actionService.createDummy("CA", "", "side lying", "", "Side Bend", "김주아",
    //     "SIDE BEND", "side bend", ["side", "bend"]);
    // actionService.createDummy("BA", "", "standing", "", "Side Bend", "김주아",
    //     "SIDE BEND", "side bend", ["side", "bend"]);
    // actionService.createDummy("MAT", "", "supine", "", "Side Kick Beats", "김주아",
    //     "SIDE KICK BEATS", "side kick beats", ["side", "kick", "beats"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Kick Bicycle",
    //     "김주아",
    //     "SIDE KICK BICYCLE",
    //     "side kick bicycle",
    //     ["side", "kick", "bicycle"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Kick Big Circles",
    //     "김주아",
    //     "SIDE KICK BIG CIRCLES",
    //     "side kick big circles",
    //     ["side", "kick", "big", "circles"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Kick Big Scissors",
    //     "김주아",
    //     "SIDE KICK BIG SCISSORS",
    //     "side kick big scissors",
    //     ["side", "kick", "big", "scissors"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Kick Developpe",
    //     "김주아",
    //     "SIDE KICK DEVELOPPE",
    //     "side kick developpe",
    //     ["side", "kick", "developpe"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Kick Front Back",
    //     "김주아",
    //     "SIDE KICK FRONT BACK",
    //     "side kick front back",
    //     ["side", "kick", "front", "back"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Kick Hot Potato",
    //     "김주아",
    //     "SIDE KICK HOT POTATO",
    //     "side kick hot potato",
    //     ["side", "kick", "hot", "potato"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Kick Inner Thigh",
    //     "김주아",
    //     "SIDE KICK INNER THIGH",
    //     "side kick inner thigh",
    //     ["side", "kick", "inner", "thigh"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Kick Series",
    //     "김주아",
    //     "SIDE KICK SERIES",
    //     "side kick series",
    //     ["side", "kick", "series"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Kick Small Circles",
    //     "김주아",
    //     "SIDE KICK SMALL CIRCLES",
    //     "side kick small circles",
    //     ["side", "kick", "small", "circles"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Kick Up Down",
    //     "김주아",
    //     "SIDE KICK UP DOWN",
    //     "side kick up down",
    //     ["side", "kick", "up", "down"]);
    // actionService.createDummy("BA", "", "side lying", "", "Side Leg Lift",
    //     "김주아", "SIDE LEG LIFT", "side leg lift", ["side", "leg", "lift"]);
    // actionService.createDummy(
    //     "BA",
    //     "",
    //     "side lying",
    //     "",
    //     "Side Lying Stretch",
    //     "김주아",
    //     "SIDE LYING STRETCH",
    //     "side lying stretch",
    //     ["side", "lying", "stretch"]);
    // actionService.createDummy("BA", "", "standing", "", "Side Sit Up", "김주아",
    //     "SIDE SIT UP", "side sit up", ["side", "sit", "up"]);
    // actionService.createDummy("RE", "", "standing", "", "Side Split", "김주아",
    //     "SIDE SPLIT", "side split", ["side", "split"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "supine",
    //     "",
    //     "Single Leg Circles",
    //     "김주아",
    //     "SINGLE LEG CIRCLES",
    //     "single leg circles",
    //     ["single", "leg", "circles"]);
    // actionService.createDummy("MAT", "", "prone", "", "Single Leg Kicks", "김주아",
    //     "SINGLE LEG KICKS", "single leg kicks", ["single", "leg", "kicks"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "sitting",
    //     "",
    //     "Single Leg Press",
    //     "김주아",
    //     "SINGLE LEG PRESS",
    //     "single leg press",
    //     ["single", "leg", "press"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "supine",
    //     "",
    //     "Single Leg Stretch",
    //     "김주아",
    //     "SINGLE LEG STRETCH",
    //     "single leg stretch",
    //     ["single", "leg", "stretch"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "sitting",
    //     "",
    //     "Sitthing Triceps Press",
    //     "김주아",
    //     "SITTHING TRICEPS PRESS",
    //     "sitthing triceps press",
    //     ["sitthing", "triceps", "press"]);
    // actionService.createDummy("CA", "", "sitting", "", "Sitting Cat", "김주아",
    //     "SITTING CAT", "sitting cat", ["sitting", "cat"]);
    // actionService.createDummy(
    //     "BA",
    //     "",
    //     "sitting",
    //     "",
    //     "Sitting Leg Series",
    //     "김주아",
    //     "SITTING LEG SERIES",
    //     "sitting leg series",
    //     ["sitting", "leg", "series"]);
    // actionService.createDummy(
    //     "RE", "", "standing", "", "Snake", "김주아", "SNAKE", "snake", ["snake"]);
    // actionService.createDummy(
    //     "MAT",
    //     "",
    //     "sitting",
    //     "",
    //     "Spine Stretch Forward",
    //     "김주아",
    //     "SPINE STRETCH FORWARD",
    //     "spine stretch forward",
    //     ["spine", "stretch", "forward"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "sitting",
    //     "",
    //     "Spine Stretch Forward",
    //     "김주아",
    //     "SPINE STRETCH FORWARD",
    //     "spine stretch forward",
    //     ["spine", "stretch", "forward"]);
    // actionService.createDummy("MAT", "", "sitting", "", "Spine Twist", "김주아",
    //     "SPINE TWIST", "spine twist", ["spine", "twist"]);
    // actionService.createDummy("CA", "", "standing", "", "Spread Eagle", "김주아",
    //     "SPREAD EAGLE", "spread eagle", ["spread", "eagle"]);
    // actionService.createDummy(
    //     "CA", "", "standing", "", "Squat", "김주아", "SQUAT", "squat", ["squat"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "standing",
    //     "",
    //     "Standing Ballet Stretches",
    //     "김주아",
    //     "STANDING BALLET STRETCHES",
    //     "standing ballet stretches",
    //     ["standing", "ballet", "stretches"]);
    // actionService.createDummy("CA", "", "standing", "", "Standing Cat", "김주아",
    //     "STANDING CAT", "standing cat", ["standing", "cat"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "standing",
    //     "",
    //     "Standing Chest Expansion",
    //     "김주아",
    //     "STANDING CHEST EXPANSION",
    //     "standing chest expansion",
    //     ["standing", "chest", "expansion"]);
    // actionService.createDummy(
    //     "BA",
    //     "",
    //     "standing",
    //     "",
    //     "Standing Roll Back",
    //     "김주아",
    //     "STANDING ROLL BACK",
    //     "standing roll back",
    //     ["standing", "roll", "back"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "standing",
    //     "",
    //     "Standing Roll Down",
    //     "김주아",
    //     "STANDING ROLL DOWN",
    //     "standing roll down",
    //     ["standing", "roll", "down"]);
    // actionService.createDummy(
    //     "BA",
    //     "",
    //     "standing",
    //     "",
    //     "Standing Side Leg Lift",
    //     "김주아",
    //     "STANDING SIDE LEG LIFT",
    //     "standing side leg lift",
    //     ["standing", "side", "leg", "lift"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "standing",
    //     "",
    //     "Standing Single Leg Press",
    //     "김주아",
    //     "STANDING SINGLE LEG PRESS",
    //     "standing single leg press",
    //     ["standing", "single", "leg", "press"]);
    // actionService.createDummy(
    //     "CA",
    //     "",
    //     "standing",
    //     "",
    //     "Standing Spred Eagle",
    //     "김주아",
    //     "STANDING SPRED EAGLE",
    //     "standing spred eagle",
    //     ["standing", "spred", "eagle"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Stomach Massage Reach Up",
    //     "김주아",
    //     "STOMACH MASSAGE REACH UP",
    //     "stomach massage reach up",
    //     ["stomach", "massage", "reach", "up"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Stomach Massage Round",
    //     "김주아",
    //     "STOMACH MASSAGE ROUND",
    //     "stomach massage round",
    //     ["stomach", "massage", "round"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Stomach Massage Series",
    //     "김주아",
    //     "STOMACH MASSAGE SERIES",
    //     "stomach massage series",
    //     ["stomach", "massage", "series"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Stomach Massage Straight",
    //     "김주아",
    //     "STOMACH MASSAGE STRAIGHT",
    //     "stomach massage straight",
    //     ["stomach", "massage", "straight"]);
    // actionService.createDummy(
    //     "RE",
    //     "",
    //     "sitting",
    //     "",
    //     "Stomach Massage Twist",
    //     "김주아",
    //     "STOMACH MASSAGE TWIST",
    //     "stomach massage twist",
    //     ["stomach", "massage", "twist"]);
    // actionService.createDummy(
    //     "MAT", "", "prone", "", "Swan", "김주아", "SWAN", "swan", ["swan"]);
    // actionService.createDummy(
    //     "RE", "", "prone", "", "Swan", "김주아", "SWAN", "swan", ["swan"]);
    // actionService.createDummy(
    //     "CA", "", "prone", "", "Swan", "김주아", "SWAN", "swan", ["swan"]);
    // actionService.createDummy(
    //     "BA", "", "prone", "", "Swan", "김주아", "SWAN", "swan", ["swan"]);
    // actionService.createDummy("MAT", "", "prone", "", "Swan Dive", "김주아",
    //     "SWAN DIVE", "swan dive", ["swan", "dive"]);
    // actionService.createDummy("CH", "", "prone", "", "Swan Dive", "김주아",
    //     "SWAN DIVE", "swan dive", ["swan", "dive"]);
    // actionService.createDummy("BA", "", "prone", "", "Swan Dive", "김주아",
    //     "SWAN DIVE", "swan dive", ["swan", "dive"]);
    // actionService.createDummy(
    //     "CH",
    //     "",
    //     "prone",
    //     "",
    //     "Swan Dive From Floor",
    //     "김주아",
    //     "SWAN DIVE FROM FLOOR",
    //     "swan dive from floor",
    //     ["swan", "dive", "from", "floor"]);
    // actionService.createDummy(
    //     "BA",
    //     "",
    //     "standing",
    //     "",
    //     "Swedish Bar Stretch",
    //     "김주아",
    //     "SWEDISH BAR STRETCH",
    //     "swedish bar stretch",
    //     ["swedish", "bar", "stretch"]);
    // actionService.createDummy("MAT", "", "prone", "", "Swimming", "김주아",
    //     "SWIMMING", "swimming", ["swimming"]);
    // actionService.createDummy("MAT", "", "supine", "", "Teaser", "김주아",
    //     "TEASER", "teaser", ["teaser"]);
    // actionService.createDummy("CA", "", "supine", "", "Teaser", "김주아", "TEASER",
    //     "teaser", ["teaser"]);
    // actionService.createDummy("RE", "", "standing", "", "Tendon Stretch", "김주아",
    //     "TENDON STRETCH", "tendon stretch", ["tendon", "stretch"]);
    // actionService.createDummy("CH", "", "standing", "", "Tendon Stretch", "김주아",
    //     "TENDON STRETCH", "tendon stretch", ["tendon", "stretch"]);
    // actionService.createDummy("MAT", "", "supine", "", "The Hundred", "김주아",
    //     "THE HUNDRED", "the hundred", ["the", "hundred"]);
    // actionService.createDummy("MAT", "", "supine", "", "The Roll Up", "김주아",
    //     "THE ROLL UP", "the roll up", ["the", "roll", "up"]);
    // actionService.createDummy("MAT", "", "kneeling", "", "Thigh Stretch", "김주아",
    //     "THIGH STRETCH", "thigh stretch", ["thigh", "stretch"]);
    // actionService.createDummy("RE", "", "kneeling", "", "Thigh Stretch", "김주아",
    //     "THIGH STRETCH", "thigh stretch", ["thigh", "stretch"]);
    // actionService.createDummy("CA", "", "kneeling", "", "Thigh Stretch", "김주아",
    //     "THIGH STRETCH", "thigh stretch", ["thigh", "stretch"]);
    // actionService.createDummy("MAT", "", "supine", "", "Toe Tap", "김주아",
    //     "TOE TAP", "toe tap", ["toe", "tap"]);
    // actionService.createDummy(
    //     "CA", "", "supine", "", "Tower", "김주아", "TOWER", "tower", ["tower"]);
    // actionService.createDummy("CH", "", "prone", "", "Triceps", "김주아",
    //     "TRICEPS", "triceps", ["triceps"]);
    // actionService.createDummy(
    //     "RE", "", "standing", "", "Twist", "김주아", "TWIST", "twist", ["twist"]);
    // actionService.createDummy("RE", "", "standing", "", "Up Stretch", "김주아",
    //     "UP STRETCH", "up stretch", ["up", "stretch"]);
    // actionService.createDummy("CA", "", "supine", "", "Upper Abs Curl", "김주아",
    //     "UPPER ABS CURL", "upper abs curl", ["upper", "abs", "curl"]);

    // DB INSERT NEW
    // actionService.create(
    //     "MAT", "", "supine", "", "Ab Prep", "김주아", "AB PREP", "ab prep");
    // actionService.create("MAT", "", "sitting", "", "Abs Series", "김주아",
    //     "ABS SERIES", "abs series");
    // actionService.create("RE", "", "supine", "", "Adductor Stretch", "김주아",
    //     "ADDUCTOR STRETCH", "adductor stretch");
    // actionService.create(
    //     "CA", "", "supine", "", "Airplane", "김주아", "AIRPLANE", "airplane");
    // actionService.create("RE", "", "kneeling", "", "Arm Circles", "김주아",
    //     "ARM CIRCLES", "arm circles");
    // actionService.create(
    //     "CH", "", "standing", "", "Arm Frog", "김주아", "ARM FROG", "arm frog");
    // actionService.create("CA", "", "sitting", "", "Back Rowing", "김주아",
    //     "BACK ROWING", "back rowing");
    // actionService.create("RE", "", "sitting", "", "Back Rowing Prep", "김주아",
    //     "BACK ROWING PREP", "back rowing prep");
    // actionService.create("CA", "", "sitting", "", "Back Rowing Prep Series",
    //     "김주아", "BACK ROWING PREP SERIES", "back rowing prep series");
    // actionService.create("RE", "", "sitting", "", "Balance Control Back", "김주아",
    //     "BALANCE CONTROL BACK", "balance control back");
    // actionService.create("RE", "", "plank", "", "Balance Control Front", "김주아",
    //     "BALANCE CONTROL FRONT", "balance control front");
    // actionService.create("MAT", "", "sitting", "", "Balance Point", "김주아",
    //     "BALANCE POINT", "balance point");
    // actionService.create("BA", "", "standing", "", "Ballet Stretch", "김주아",
    //     "BALLET STRETCH", "ballet stretch");
    // actionService.create("RE", "", "supine", "", "Bend&Stretch", "김주아",
    //     "BEND&STRETCH", "bend&stretch");
    // actionService.create(
    //     "MAT", "", "sitting", "", "Boomerang", "김주아", "BOOMERANG", "boomerang");
    // actionService.create("MAT", "", "prone", "", "Breast Stroke", "김주아",
    //     "BREAST STROKE", "breast stroke");
    // actionService.create(
    //     "MAT", "", "supine", "", "Breathing", "김주아", "BREATHING", "breathing");
    // actionService.create(
    //     "CA", "", "supine", "", "Breathing", "김주아", "BREATHING", "breathing");
    // actionService.create("MAT", "", "quadruped", "", "Cat Stretch", "김주아",
    //     "CAT STRETCH", "cat stretch");
    // actionService.create("RE", "", "kneeling", "", "Chest Expansion", "김주아",
    //     "CHEST EXPANSION", "chest expansion");
    // actionService.create("MAT", "", "side lying", "", "Clam Shell", "김주아",
    //     "CLAM SHELL", "clam shell");
    // actionService.create("MAT", "", "supine", "", "Control Balance", "김주아",
    //     "CONTROL BALANCE", "control balance");
    // actionService.create("RE", "", "supine", "", "Coordination", "김주아",
    //     "COORDINATION", "coordination");
    // actionService.create(
    //     "MAT", "", "supine", "", "Corkscrew", "김주아", "CORKSCREW", "corkscrew");
    // actionService.create(
    //     "RE", "", "supine", "", "Corscrew", "김주아", "CORSCREW", "corscrew");
    // actionService.create(
    //     "MAT", "", "sitting", "", "Crab", "김주아", "CRAB", "crab");
    // actionService.create("MAT", "", "supine", "", "Criss Cross", "김주아",
    //     "CRISS CROSS", "criss cross");
    // actionService.create("MAT", "", "prone", "", "Double Leg Kicks", "김주아",
    //     "DOUBLE LEG KICKS", "double leg kicks");
    // actionService.create("MAT", "", "supine", "", "Double Leg Stretch", "김주아",
    //     "DOUBLE LEG STRETCH", "double leg stretch");
    // actionService.create("RE", "", "quadruped", "", "Down Stretch", "김주아",
    //     "DOWN STRETCH", "down stretch");
    // actionService.create(
    //     "RE", "", "standing", "", "Elephant", "김주아", "ELEPHANT", "elephant");
    // actionService.create("RE", "", "supine", "", "Footwork Series", "김주아",
    //     "FOOTWORK SERIES", "footwork series");
    // actionService.create("CH", "", "sitting", "", "Footwork Series", "김주아",
    //     "FOOTWORK SERIES", "footwork series");
    // actionService.create("RE", "", "supine", "", "Frog", "김주아", "FROG", "frog");
    // actionService.create("MAT", "", "prone", "", "Frog Hip Extension", "김주아",
    //     "FROG HIP EXTENSION", "frog hip extension");
    // actionService.create("CA", "", "sitting", "", "Front Rowing", "김주아",
    //     "FRONT ROWING", "front rowing");
    // actionService.create("RE", "", "sitting", "", "Front Rowing Prep", "김주아",
    //     "FRONT ROWING PREP", "front rowing prep");
    // actionService.create("CA", "", "sitting", "", "Front Rowing Prep Series",
    //     "김주아", "FRONT ROWING PREP SERIES", "front rowing prep series");
    // actionService.create("RE", "", "standing", "", "Front Split", "김주아",
    //     "FRONT SPLIT", "front split");
    // actionService.create("CA", "", "supine", "", "Full Hanging", "김주아",
    //     "FULL HANGING", "full hanging");
    // actionService.create(
    //     "CA", "", "prone", "", "Full Swan", "김주아", "FULL SWAN", "full swan");
    // actionService.create("CH", "", "standing", "", "Going Up Front", "김주아",
    //     "GOING UP FRONT", "going up front");
    // actionService.create("CH", "", "standing", "", "Going Up Side", "김주아",
    //     "GOING UP SIDE", "going up side");
    // actionService.create("CA", "", "supine", "", "Half Hanging", "김주아",
    //     "HALF HANGING", "half hanging");
    // actionService.create("MAT", "", "sitting", "", "Half Roll Back", "김주아",
    //     "HALF ROLL BACK", "half roll back");
    // actionService.create(
    //     "MAT", "", "prone", "", "Half Swan", "김주아", "HALF SWAN", "half swan");
    // actionService.create("CH", "", "supine", "", "Hams Press Hips Down", "김주아",
    //     "HAMS PRESS HIPS DOWN", "hams press hips down");
    // actionService.create("CH", "", "supine", "", "Hams Press Hips Up", "김주아",
    //     "HAMS PRESS HIPS UP", "hams press hips up");
    // actionService.create("CA", "", "standing", "", "Hanging Pull Ups", "김주아",
    //     "HANGING PULL UPS", "hanging pull ups");
    // actionService.create("MAT", "", "supine", "", "High Bicycle", "김주아",
    //     "HIGH BICYCLE", "high bicycle");
    // actionService.create("MAT", "", "supine", "", "High Scissors", "김주아",
    //     "HIGH SCISSORS", "high scissors");
    // actionService.create("MAT", "", "sitting", "", "Hip Circles", "김주아",
    //     "HIP CIRCLES", "hip circles");
    // actionService.create("CA", "", "side lying", "", "Hip Opener", "김주아",
    //     "HIP OPENER", "hip opener");
    // actionService.create("MAT", "", "supine", "", "Hip Release", "김주아",
    //     "HIP RELEASE", "hip release");
    // actionService.create(
    //     "MAT", "", "supine", "", "Hip Roll", "김주아", "HIP ROLL", "hip roll");
    // actionService.create("CH", "", "sitting", "", "Horse Back", "김주아",
    //     "HORSE BACK", "horse back");
    // actionService.create("BA", "", "sitting", "", "Horse Back", "김주아",
    //     "HORSE BACK", "horse back");
    // actionService.create(
    //     "MAT", "", "supine", "", "Hundred", "김주아", "HUNDRED", "hundred");
    // actionService.create(
    //     "RE", "", "supine", "", "Hundred", "김주아", "HUNDRED", "hundred");
    // actionService.create("MAT", "", "supine", "", "Imprinting Transition",
    //     "김주아", "IMPRINTING TRANSITION", "imprinting transition");
    // actionService.create("MAT", "", "supine", "", "Jack Knife", "김주아",
    //     "JACK KNIFE", "jack knife");
    // actionService.create("CH", "", "supine", "", "Jack Knife", "김주아",
    //     "JACK KNIFE", "jack knife");
    // actionService.create("CH", "", "standing", "", "Knee Raise Series", "김주아",
    //     "KNEE RAISE SERIES", "knee raise series");
    // actionService.create("RE", "", "quadruped", "", "Knee Stretch Arches",
    //     "김주아", "KNEE STRETCH ARCHES", "knee stretch arches");
    // actionService.create("RE", "", "quadruped", "", "Knee Stretch Knees Off",
    //     "김주아", "KNEE STRETCH KNEES OFF", "knee stretch knees off");
    // actionService.create("RE", "", "quadruped", "", "Knee Stretch Round", "김주아",
    //     "KNEE STRETCH ROUND", "knee stretch round");
    // actionService.create("RE", "", "quadruped", "", "Knee Stretch Series",
    //     "김주아", "KNEE STRETCH SERIES", "knee stretch series");
    // actionService.create("CA", "", "kneeling", "", "Kneeling Ballet Stretches",
    //     "김주아", "KNEELING BALLET STRETCHES", "kneeling ballet stretches");
    // actionService.create("CA", "", "kneeling", "", "Kneeling Cat", "김주아",
    //     "KNEELING CAT", "kneeling cat");
    // actionService.create("CA", "", "kneeling", "", "Kneeling Chest Expansion",
    //     "김주아", "KNEELING CHEST EXPANSION", "kneeling chest expansion");
    // actionService.create("CH", "", "kneeling", "", "Kneeling Mermaid", "김주아",
    //     "KNEELING MERMAID", "kneeling mermaid");
    // actionService.create("MAT", "", "kneeling", "", "Kneeling Side Kick", "김주아",
    //     "KNEELING SIDE KICK", "kneeling side kick");
    // actionService.create("CH", "", "kneeling", "", "Kneeling Side Kicks", "김주아",
    //     "KNEELING SIDE KICKS", "kneeling side kicks");
    // actionService.create(
    //     "BA", "", "standing", "", "Lay Backs", "김주아", "LAY BACKS", "lay backs");
    // actionService.create("RE", "", "supine", "", "Leg Circles", "김주아",
    //     "LEG CIRCLES", "leg circles");
    // actionService.create("MAT", "", "plank", "", "Leg Pull Back", "김주아",
    //     "LEG PULL BACK", "leg pull back");
    // actionService.create("MAT", "", "plank", "", "Leg Pull Front", "김주아",
    //     "LEG PULL FRONT", "leg pull front");
    // actionService.create("CA", "", "supine", "", "Leg Spring Series", "김주아",
    //     "LEG SPRING SERIES", "leg spring series");
    // actionService.create(
    //     "CA",
    //     "",
    //     "side lying",
    //     "",
    //     "Leg Spring Side Kick Series",
    //     "김주아",
    //     "LEG SPRING SIDE KICK SERIES",
    //     "leg spring side kick series");
    // actionService.create("RE", "", "supine", "", "Leg Strap Series", "김주아",
    //     "LEG STRAP SERIES", "leg strap series");
    // actionService.create("RE", "", "sitting", "", "Long Back Stretch", "김주아",
    //     "LONG BACK STRETCH", "long back stretch");
    // actionService.create("RE", "", "prone", "", "Long Box Backstroke", "김주아",
    //     "LONG BOX BACKSTROKE", "long box backstroke");
    // actionService.create("RE", "", "prone", "", "Long Box Horse Back", "김주아",
    //     "LONG BOX HORSE BACK", "long box horse back");
    // actionService.create("RE", "", "prone", "", "Long Box Pulling Straps",
    //     "김주아", "LONG BOX PULLING STRAPS", "long box pulling straps");
    // actionService.create("RE", "", "prone", "", "Long Box Series", "김주아",
    //     "LONG BOX SERIES", "long box series");
    // actionService.create("RE", "", "prone", "", "Long Box T Shape", "김주아",
    //     "LONG BOX T SHAPE", "long box t shape");
    // actionService.create("RE", "", "prone", "", "Long Box Teaser", "김주아",
    //     "LONG BOX TEASER", "long box teaser");
    // actionService.create("RE", "", "supine", "", "Long Spine Massage", "김주아",
    //     "LONG SPINE MASSAGE", "long spine massage");
    // actionService.create("RE", "", "plank", "", "Long Stretch", "김주아",
    //     "LONG STRETCH", "long stretch");
    // actionService.create("RE", "", "plank", "", "Long Stretch Series", "김주아",
    //     "LONG STRETCH SERIES", "long stretch series");
    // actionService.create("MAT", "", "supine", "", "Lower And Lift", "김주아",
    //     "LOWER AND LIFT", "lower and lift");
    // actionService.create("RE", "", "supine", "", "Lower And Lift", "김주아",
    //     "LOWER AND LIFT", "lower and lift");
    // actionService.create(
    //     "CH", "", "standing", "", "Lunge", "김주아", "LUNGE", "lunge");
    // actionService.create(
    //     "MAT", "", "sitting", "", "Mermaid", "김주아", "MERMAID", "mermaid");
    // actionService.create(
    //     "CA", "", "sitting", "", "Mermaid", "김주아", "MERMAID", "mermaid");
    // actionService.create(
    //     "CH", "", "sitting", "", "Mermaid", "김주아", "MERMAID", "mermaid");
    // actionService.create("CA", "", "supine", "", "Midback Series", "김주아",
    //     "MIDBACK SERIES", "midback series");
    // actionService.create(
    //     "CA", "", "supine", "", "Monkey", "김주아", "MONKEY", "monkey");
    // actionService.create("CH", "", "standing", "", "Mountain Climb", "김주아",
    //     "MOUNTAIN CLIMB", "mountain climb");
    // actionService.create(
    //     "MAT", "", "sitting", "", "Neck Pull", "김주아", "NECK PULL", "neck pull");
    // actionService.create("CH", "", "prone", "", "One Arm Press", "김주아",
    //     "ONE ARM PRESS", "one arm press");
    // actionService.create("MAT", "", "sitting", "", "Open Leg Rocker", "김주아",
    //     "OPEN LEG ROCKER", "open leg rocker");
    // actionService.create(
    //     "RE", "", "supine", "", "Overhead", "김주아", "OVERHEAD", "overhead");
    // actionService.create(
    //     "CA", "", "supine", "", "Parakeet", "김주아", "PARAKEET", "parakeet");
    // actionService.create("RE", "", "supine", "", "Pelvic Lift", "김주아",
    //     "PELVIC LIFT", "pelvic lift");
    // actionService.create("MAT", "", "supine", "", "Pelvic Movement", "김주아",
    //     "PELVIC MOVEMENT", "pelvic movement");
    // actionService.create("CA", "", "sitting", "", "Port De Bras", "김주아",
    //     "PORT DE BRAS", "port de bras");
    // actionService.create("CH", "", "sitting", "", "Press Down Teaser", "김주아",
    //     "PRESS DOWN TEASER", "press down teaser");
    // actionService.create("MAT", "", "prone", "", "Prone Heel Squeeze", "김주아",
    //     "PRONE HEEL SQUEEZE", "prone heel squeeze");
    // actionService.create("MAT", "", "prone", "", "Prone Leg Lift Series", "김주아",
    //     "PRONE LEG LIFT SERIES", "prone leg lift series");
    // actionService.create("BA", "", "prone", "", "Prone Leg Lift Series", "김주아",
    //     "PRONE LEG LIFT SERIES", "prone leg lift series");
    // actionService.create(
    //     "CH", "", "standing", "", "Pull Up", "김주아", "PULL UP", "pull up");
    // actionService.create(
    //     "CH", "", "standing", "", "Push Down", "김주아", "PUSH DOWN", "push down");
    // actionService.create("CH", "", "standing", "", "Push Down With One Arm",
    //     "김주아", "PUSH DOWN WITH ONE ARM", "push down with one arm");
    // actionService.create("CA", "", "sitting", "", "Push Through", "김주아",
    //     "PUSH THROUGH", "push through");
    // actionService.create("CA", "", "supine", "", "Push Thru With Feet", "김주아",
    //     "PUSH THRU WITH FEET", "push thru with feet");
    // actionService.create(
    //     "MAT", "", "plank", "", "Push Ups", "김주아", "PUSH UPS", "push ups");
    // actionService.create(
    //     "MAT", "", "prone", "", "Rocking", "김주아", "ROCKING", "rocking");
    // actionService.create("CA", "", "sitting", "", "Roll Back Bar", "김주아",
    //     "ROLL BACK BAR", "roll back bar");
    // actionService.create("CA", "", "sitting", "", "Roll Back With One Arm",
    //     "김주아", "ROLL BACK WITH ONE ARM", "roll back with one arm");
    // actionService.create(
    //     "CA", "", "sitting", "", "Roll Down", "김주아", "ROLL DOWN", "roll down");
    // actionService.create("BA", "", "sitting", "", "Roll Down Round", "김주아",
    //     "ROLL DOWN ROUND", "roll down round");
    // actionService.create("BA", "", "sitting", "", "Roll Down Straight", "김주아",
    //     "ROLL DOWN STRAIGHT", "roll down straight");
    // actionService.create(
    //     "MAT", "", "supine", "", "Roll Over", "김주아", "ROLL OVER", "roll over");
    // actionService.create(
    //     "CH", "", "supine", "", "Roll Over", "김주아", "ROLL OVER", "roll over");
    // actionService.create(
    //     "CA", "", "supine", "", "Roll Up", "김주아", "ROLL UP", "roll up");
    // actionService.create("MAT", "", "sitting", "", "Rolling Like A Ball", "김주아",
    //     "ROLLING LIKE A BALL", "rolling like a ball");
    // actionService.create("RE", "", "sitting", "", "Rowing 90 Degrees", "김주아",
    //     "ROWING 90 DEGREES", "rowing 90 degrees");
    // actionService.create("RE", "", "sitting", "", "Rowing From The Chest",
    //     "김주아", "ROWING FROM THE CHEST", "rowing from the chest");
    // actionService.create("RE", "", "sitting", "", "Rowing From The Hips", "김주아",
    //     "ROWING FROM THE HIPS", "rowing from the hips");
    // actionService.create("RE", "", "sitting", "", "Rowing Hug The Tree", "김주아",
    //     "ROWING HUG THE TREE", "rowing hug the tree");
    // actionService.create("RE", "", "sitting", "", "Rowing Into The Sternum",
    //     "김주아", "ROWING INTO THE STERNUM", "rowing into the sternum");
    // actionService.create("RE", "", "sitting", "", "Rowing Salute", "김주아",
    //     "ROWING SALUTE", "rowing salute");
    // actionService.create("RE", "", "sitting", "", "Rowing Series", "김주아",
    //     "ROWING SERIES", "rowing series");
    // actionService.create("RE", "", "sitting", "", "Rowing Shave", "김주아",
    //     "ROWING SHAVE", "rowing shave");
    // actionService.create(
    //     "RE", "", "supine", "", "Running", "김주아", "RUNNING", "running");
    // actionService.create("RE", "", "standing", "", "Russian Split", "김주아",
    //     "RUSSIAN SPLIT", "russian split");
    // actionService.create("MAT", "", "sitting", "", "Saw", "김주아", "SAW", "saw");
    // actionService.create("CH", "", "prone", "", "Scapula Isolation", "김주아",
    //     "SCAPULA ISOLATION", "scapula isolation");
    // actionService.create("MAT", "", "supine", "", "Scapula Movement", "김주아",
    //     "SCAPULA MOVEMENT", "scapula movement");
    // actionService.create(
    //     "MAT", "", "supine", "", "Scissors", "김주아", "SCISSORS", "scissors");
    // actionService.create(
    //     "MAT", "", "sitting", "", "Seal", "김주아", "SEAL", "seal");
    // actionService.create("RE", "", "supine", "", "Semi-Circle", "김주아",
    //     "SEMI-CIRCLE", "semi-circle");
    // actionService.create("RE", "", "sitting", "", "Short Box Round", "김주아",
    //     "SHORT BOX ROUND", "short box round");
    // actionService.create("RE", "", "sitting", "", "Short Box Series", "김주아",
    //     "SHORT BOX SERIES", "short box series");
    // actionService.create("BA", "", "sitting", "", "Short Box Series", "김주아",
    //     "SHORT BOX SERIES", "short box series");
    // actionService.create("RE", "", "sitting", "", "Short Box Side", "김주아",
    //     "SHORT BOX SIDE", "short box side");
    // actionService.create("RE", "", "sitting", "", "Short Box Straight", "김주아",
    //     "SHORT BOX STRAIGHT", "short box straight");
    // actionService.create("RE", "", "sitting", "", "Short Box Tree", "김주아",
    //     "SHORT BOX TREE", "short box tree");
    // actionService.create("RE", "", "sitting", "", "Short Box Twist", "김주아",
    //     "SHORT BOX TWIST", "short box twist");
    // actionService.create("RE", "", "sitting", "", "Short Box Twist And Reach",
    //     "김주아", "SHORT BOX TWIST AND REACH", "short box twist and reach");
    // actionService.create("RE", "", "supine", "", "Short Spine Massage", "김주아",
    //     "SHORT SPINE MASSAGE", "short spine massage");
    // actionService.create("CA", "", "supine", "", "Shoulder And Chest Opener",
    //     "김주아", "SHOULDER AND CHEST OPENER", "shoulder and chest opener");
    // actionService.create("MAT", "", "supine", "", "Shoulder Bridge", "김주아",
    //     "SHOULDER BRIDGE", "shoulder bridge");
    // actionService.create("CA", "", "sitting", "", "Side Arm Sitting", "김주아",
    //     "SIDE ARM SITTING", "side arm sitting");
    // actionService.create(
    //     "MAT", "", "sitting", "", "Side Bend", "김주아", "SIDE BEND", "side bend");
    // actionService.create("CA", "", "side lying", "", "Side Bend", "김주아",
    //     "SIDE BEND", "side bend");
    // actionService.create(
    //     "BA", "", "standing", "", "Side Bend", "김주아", "SIDE BEND", "side bend");
    // actionService.create("MAT", "", "supine", "", "Side Kick Beats", "김주아",
    //     "SIDE KICK BEATS", "side kick beats");
    // actionService.create("MAT", "", "side lying", "", "Side Kick Bicycle",
    //     "김주아", "SIDE KICK BICYCLE", "side kick bicycle");
    // actionService.create("MAT", "", "side lying", "", "Side Kick Big Circles",
    //     "김주아", "SIDE KICK BIG CIRCLES", "side kick big circles");
    // actionService.create("MAT", "", "side lying", "", "Side Kick Big Scissors",
    //     "김주아", "SIDE KICK BIG SCISSORS", "side kick big scissors");
    // actionService.create("MAT", "", "side lying", "", "Side Kick Developpe",
    //     "김주아", "SIDE KICK DEVELOPPE", "side kick developpe");
    // actionService.create("MAT", "", "side lying", "", "Side Kick Front Back",
    //     "김주아", "SIDE KICK FRONT BACK", "side kick front back");
    // actionService.create("MAT", "", "side lying", "", "Side Kick Hot Potato",
    //     "김주아", "SIDE KICK HOT POTATO", "side kick hot potato");
    // actionService.create("MAT", "", "side lying", "", "Side Kick Inner Thigh",
    //     "김주아", "SIDE KICK INNER THIGH", "side kick inner thigh");
    // actionService.create("MAT", "", "side lying", "", "Side Kick Series", "김주아",
    //     "SIDE KICK SERIES", "side kick series");
    // actionService.create("MAT", "", "side lying", "", "Side Kick Small Circles",
    //     "김주아", "SIDE KICK SMALL CIRCLES", "side kick small circles");
    // actionService.create("MAT", "", "side lying", "", "Side Kick Up Down",
    //     "김주아", "SIDE KICK UP DOWN", "side kick up down");
    // actionService.create("BA", "", "side lying", "", "Side Leg Lift", "김주아",
    //     "SIDE LEG LIFT", "side leg lift");
    // actionService.create("BA", "", "side lying", "", "Side Lying Stretch",
    //     "김주아", "SIDE LYING STRETCH", "side lying stretch");
    // actionService.create("BA", "", "standing", "", "Side Sit Up", "김주아",
    //     "SIDE SIT UP", "side sit up");
    // actionService.create("RE", "", "standing", "", "Side Split", "김주아",
    //     "SIDE SPLIT", "side split");
    // actionService.create("MAT", "", "supine", "", "Single Leg Circles", "김주아",
    //     "SINGLE LEG CIRCLES", "single leg circles");
    // actionService.create("MAT", "", "prone", "", "Single Leg Kicks", "김주아",
    //     "SINGLE LEG KICKS", "single leg kicks");
    // actionService.create("CH", "", "sitting", "", "Single Leg Press", "김주아",
    //     "SINGLE LEG PRESS", "single leg press");
    // actionService.create("MAT", "", "supine", "", "Single Leg Stretch", "김주아",
    //     "SINGLE LEG STRETCH", "single leg stretch");
    // actionService.create("CH", "", "sitting", "", "Sitthing Triceps Press",
    //     "김주아", "SITTHING TRICEPS PRESS", "sitthing triceps press");
    // actionService.create("CA", "", "sitting", "", "Sitting Cat", "김주아",
    //     "SITTING CAT", "sitting cat");
    // actionService.create("BA", "", "sitting", "", "Sitting Leg Series", "김주아",
    //     "SITTING LEG SERIES", "sitting leg series");
    // actionService.create(
    //     "RE", "", "standing", "", "Snake", "김주아", "SNAKE", "snake");
    // actionService.create("MAT", "", "sitting", "", "Spine Stretch Forward",
    //     "김주아", "SPINE STRETCH FORWARD", "spine stretch forward");
    // actionService.create("CH", "", "sitting", "", "Spine Stretch Forward",
    //     "김주아", "SPINE STRETCH FORWARD", "spine stretch forward");
    // actionService.create("MAT", "", "sitting", "", "Spine Twist", "김주아",
    //     "SPINE TWIST", "spine twist");
    // actionService.create("CA", "", "standing", "", "Spread Eagle", "김주아",
    //     "SPREAD EAGLE", "spread eagle");
    // actionService.create(
    //     "CA", "", "standing", "", "Squat", "김주아", "SQUAT", "squat");
    // actionService.create("CA", "", "standing", "", "Standing Ballet Stretches",
    //     "김주아", "STANDING BALLET STRETCHES", "standing ballet stretches");
    // actionService.create("CA", "", "standing", "", "Standing Cat", "김주아",
    //     "STANDING CAT", "standing cat");
    // actionService.create("CA", "", "standing", "", "Standing Chest Expansion",
    //     "김주아", "STANDING CHEST EXPANSION", "standing chest expansion");
    // actionService.create("BA", "", "standing", "", "Standing Roll Back", "김주아",
    //     "STANDING ROLL BACK", "standing roll back");
    // actionService.create("CH", "", "standing", "", "Standing Roll Down", "김주아",
    //     "STANDING ROLL DOWN", "standing roll down");
    // actionService.create("BA", "", "standing", "", "Standing Side Leg Lift",
    //     "김주아", "STANDING SIDE LEG LIFT", "standing side leg lift");
    // actionService.create("CH", "", "standing", "", "Standing Single Leg Press",
    //     "김주아", "STANDING SINGLE LEG PRESS", "standing single leg press");
    // actionService.create("CA", "", "standing", "", "Standing Spred Eagle",
    //     "김주아", "STANDING SPRED EAGLE", "standing spred eagle");
    // actionService.create("RE", "", "sitting", "", "Stomach Massage Reach Up",
    //     "김주아", "STOMACH MASSAGE REACH UP", "stomach massage reach up");
    // actionService.create("RE", "", "sitting", "", "Stomach Massage Round",
    //     "김주아", "STOMACH MASSAGE ROUND", "stomach massage round");
    // actionService.create("RE", "", "sitting", "", "Stomach Massage Series",
    //     "김주아", "STOMACH MASSAGE SERIES", "stomach massage series");
    // actionService.create("RE", "", "sitting", "", "Stomach Massage Straight",
    //     "김주아", "STOMACH MASSAGE STRAIGHT", "stomach massage straight");
    // actionService.create("RE", "", "sitting", "", "Stomach Massage Twist",
    //     "김주아", "STOMACH MASSAGE TWIST", "stomach massage twist");
    // actionService.create("MAT", "", "prone", "", "Swan", "김주아", "SWAN", "swan");
    // actionService.create("RE", "", "prone", "", "Swan", "김주아", "SWAN", "swan");
    // actionService.create("CA", "", "prone", "", "Swan", "김주아", "SWAN", "swan");
    // actionService.create("BA", "", "prone", "", "Swan", "김주아", "SWAN", "swan");
    // actionService.create(
    //     "MAT", "", "prone", "", "Swan Dive", "김주아", "SWAN DIVE", "swan dive");
    // actionService.create(
    //     "CH", "", "prone", "", "Swan Dive", "김주아", "SWAN DIVE", "swan dive");
    // actionService.create(
    //     "BA", "", "prone", "", "Swan Dive", "김주아", "SWAN DIVE", "swan dive");
    // actionService.create("CH", "", "prone", "", "Swan Dive From Floor", "김주아",
    //     "SWAN DIVE FROM FLOOR", "swan dive from floor");
    // actionService.create("BA", "", "standing", "", "Swedish Bar Stretch", "김주아",
    //     "SWEDISH BAR STRETCH", "swedish bar stretch");
    // actionService.create(
    //     "MAT", "", "prone", "", "Swimming", "김주아", "SWIMMING", "swimming");
    // actionService.create(
    //     "MAT", "", "supine", "", "Teaser", "김주아", "TEASER", "teaser");
    // actionService.create(
    //     "CA", "", "supine", "", "Teaser", "김주아", "TEASER", "teaser");
    // actionService.create("RE", "", "standing", "", "Tendon Stretch", "김주아",
    //     "TENDON STRETCH", "tendon stretch");
    // actionService.create("CH", "", "standing", "", "Tendon Stretch", "김주아",
    //     "TENDON STRETCH", "tendon stretch");
    // actionService.create("MAT", "", "supine", "", "The Hundred", "김주아",
    //     "THE HUNDRED", "the hundred");
    // actionService.create("MAT", "", "supine", "", "The Roll Up", "김주아",
    //     "THE ROLL UP", "the roll up");
    // actionService.create("MAT", "", "kneeling", "", "Thigh Stretch", "김주아",
    //     "THIGH STRETCH", "thigh stretch");
    // actionService.create("RE", "", "kneeling", "", "Thigh Stretch", "김주아",
    //     "THIGH STRETCH", "thigh stretch");
    // actionService.create("CA", "", "kneeling", "", "Thigh Stretch", "김주아",
    //     "THIGH STRETCH", "thigh stretch");
    // actionService.create(
    //     "MAT", "", "supine", "", "Toe Tap", "김주아", "TOE TAP", "toe tap");
    // actionService.create(
    //     "CA", "", "supine", "", "Tower", "김주아", "TOWER", "tower");
    // actionService.create(
    //     "CH", "", "prone", "", "Triceps", "김주아", "TRICEPS", "triceps");
    // actionService.create(
    //     "RE", "", "standing", "", "Twist", "김주아", "TWIST", "twist");
    // actionService.create("RE", "", "standing", "", "Up Stretch", "김주아",
    //     "UP STRETCH", "up stretch");
    // actionService.create("CA", "", "supine", "", "Upper Abs Curl", "김주아",
    //     "UPPER ABS CURL", "upper abs curl");

    // DB INSERT TEST
    // actionService.create(
    //     "TEST", "supine", "Ab Prep", "김주아", "AB PREP", "ab prep");

    // 3차 검색 기능 위헤 편집
    // actionService.create(
    //     "MAT", "supine", "Ab Prep", "김주아", "AB PREP", "ab prep");
    // actionService.create(
    //     "MAT", "sitting", "Abs Series", "김주아", "ABS SERIES", "abs series");
    // actionService.create("RE", "supine", "Adductor Stretch", "김주아",
    //     "ADDUCTOR STRETCH", "adductor stretch");
    // actionService.create(
    //     "CA", "supine", "Airplane", "김주아", "AIRPLANE", "airplane");
    // actionService.create(
    //     "RE", "kneeling", "Arm Circles", "김주아", "ARM CIRCLES", "arm circles");
    // actionService.create(
    //     "CH", "standing", "Arm Frog", "김주아", "ARM FROG", "arm frog");
    // actionService.create(
    //     "CA", "sitting", "Back Rowing", "김주아", "BACK ROWING", "back rowing");
    // actionService.create("RE", "sitting", "Back Rowing Prep", "김주아",
    //     "BACK ROWING PREP", "back rowing prep");
    // actionService.create("CA", "sitting", "Back Rowing Prep Series", "김주아",
    //     "BACK ROWING PREP SERIES", "back rowing prep series");
    // actionService.create("RE", "sitting", "Balance Control Back", "김주아",
    //     "BALANCE CONTROL BACK", "balance control back");
    // actionService.create("RE", "plank", "Balance Control Front", "김주아",
    //     "BALANCE CONTROL FRONT", "balance control front");
    // actionService.create("MAT", "sitting", "Balance Point", "김주아",
    //     "BALANCE POINT", "balance point");
    // actionService.create("BA", "standing", "Ballet Stretch", "김주아",
    //     "BALLET STRETCH", "ballet stretch");
    // actionService.create(
    //     "RE", "supine", "Bend&Stretch", "김주아", "BEND&STRETCH", "bend&stretch");
    // actionService.create(
    //     "MAT", "sitting", "Boomerang", "김주아", "BOOMERANG", "boomerang");
    // actionService.create("MAT", "prone", "Breast Stroke", "김주아",
    //     "BREAST STROKE", "breast stroke");
    // actionService.create(
    //     "MAT", "supine", "Breathing", "김주아", "BREATHING", "breathing");
    // actionService.create(
    //     "CA", "supine", "Breathing", "김주아", "BREATHING", "breathing");
    // actionService.create(
    //     "MAT", "quadruped", "Cat Stretch", "김주아", "CAT STRETCH", "cat stretch");
    // actionService.create("RE", "kneeling", "Chest Expansion", "김주아",
    //     "CHEST EXPANSION", "chest expansion");
    // actionService.create(
    //     "MAT", "side lying", "Clam Shell", "김주아", "CLAM SHELL", "clam shell");
    // actionService.create("MAT", "supine", "Control Balance", "김주아",
    //     "CONTROL BALANCE", "control balance");
    // actionService.create(
    //     "RE", "supine", "Coordination", "김주아", "COORDINATION", "coordination");
    // actionService.create(
    //     "MAT", "supine", "Corkscrew", "김주아", "CORKSCREW", "corkscrew");
    // actionService.create(
    //     "RE", "supine", "Corscrew", "김주아", "CORSCREW", "corscrew");
    // actionService.create("MAT", "sitting", "Crab", "김주아", "CRAB", "crab");
    // actionService.create(
    //     "MAT", "supine", "Criss Cross", "김주아", "CRISS CROSS", "criss cross");
    // actionService.create("MAT", "prone", "Double Leg Kicks", "김주아",
    //     "DOUBLE LEG KICKS", "double leg kicks");
    // actionService.create("MAT", "supine", "Double Leg Stretch", "김주아",
    //     "DOUBLE LEG STRETCH", "double leg stretch");
    // actionService.create("RE", "quadruped", "Down Stretch", "김주아",
    //     "DOWN STRETCH", "down stretch");
    // actionService.create(
    //     "RE", "standing", "Elephant", "김주아", "ELEPHANT", "elephant");
    // actionService.create("RE", "supine", "Footwork Series", "김주아",
    //     "FOOTWORK SERIES", "footwork series");
    // actionService.create("CH", "sitting", "Footwork Series", "김주아",
    //     "FOOTWORK SERIES", "footwork series");
    // actionService.create("RE", "supine", "Frog", "김주아", "FROG", "frog");
    // actionService.create("MAT", "prone", "Frog Hip Extension", "김주아",
    //     "FROG HIP EXTENSION", "frog hip extension");
    // actionService.create(
    //     "CA", "sitting", "Front Rowing", "김주아", "FRONT ROWING", "front rowing");
    // actionService.create("RE", "sitting", "Front Rowing Prep", "김주아",
    //     "FRONT ROWING PREP", "front rowing prep");
    // actionService.create("CA", "sitting", "Front Rowing Prep Series", "김주아",
    //     "FRONT ROWING PREP SERIES", "front rowing prep series");
    // actionService.create(
    //     "RE", "standing", "Front Split", "김주아", "FRONT SPLIT", "front split");
    // actionService.create(
    //     "CA", "supine", "Full Hanging", "김주아", "FULL HANGING", "full hanging");
    // actionService.create(
    //     "CA", "prone", "Full Swan", "김주아", "FULL SWAN", "full swan");
    // actionService.create("CH", "standing", "Going Up Front", "김주아",
    //     "GOING UP FRONT", "going up front");
    // actionService.create("CH", "standing", "Going Up Side", "김주아",
    //     "GOING UP SIDE", "going up side");
    // actionService.create(
    //     "CA", "supine", "Half Hanging", "김주아", "HALF HANGING", "half hanging");
    // actionService.create("MAT", "sitting", "Half Roll Back", "김주아",
    //     "HALF ROLL BACK", "half roll back");
    // actionService.create(
    //     "MAT", "prone", "Half Swan", "김주아", "HALF SWAN", "half swan");
    // actionService.create("CH", "supine", "Hams Press Hips Down", "김주아",
    //     "HAMS PRESS HIPS DOWN", "hams press hips down");
    // actionService.create("CH", "supine", "Hams Press Hips Up", "김주아",
    //     "HAMS PRESS HIPS UP", "hams press hips up");
    // actionService.create("CA", "standing", "Hanging Pull Ups", "김주아",
    //     "HANGING PULL UPS", "hanging pull ups");
    // actionService.create(
    //     "MAT", "supine", "High Bicycle", "김주아", "HIGH BICYCLE", "high bicycle");
    // actionService.create("MAT", "supine", "High Scissors", "김주아",
    //     "HIGH SCISSORS", "high scissors");
    // actionService.create(
    //     "MAT", "sitting", "Hip Circles", "김주아", "HIP CIRCLES", "hip circles");
    // actionService.create(
    //     "CA", "side lying", "Hip Opener", "김주아", "HIP OPENER", "hip opener");
    // actionService.create(
    //     "MAT", "supine", "Hip Release", "김주아", "HIP RELEASE", "hip release");
    // actionService.create(
    //     "MAT", "supine", "Hip Roll", "김주아", "HIP ROLL", "hip roll");
    // actionService.create(
    //     "CH", "sitting", "Horse Back", "김주아", "HORSE BACK", "horse back");
    // actionService.create(
    //     "BA", "sitting", "Horse Back", "김주아", "HORSE BACK", "horse back");
    // actionService.create(
    //     "MAT", "supine", "Hundred", "김주아", "HUNDRED", "hundred");
    // actionService.create(
    //     "RE", "supine", "Hundred", "김주아", "HUNDRED", "hundred");
    // actionService.create("MAT", "supine", "Imprinting Transition", "김주아",
    //     "IMPRINTING TRANSITION", "imprinting transition");
    // actionService.create(
    //     "MAT", "supine", "Jack Knife", "김주아", "JACK KNIFE", "jack knife");
    // actionService.create(
    //     "CH", "supine", "Jack Knife", "김주아", "JACK KNIFE", "jack knife");
    // actionService.create("CH", "standing", "Knee Raise Series", "김주아",
    //     "KNEE RAISE SERIES", "knee raise series");
    // actionService.create("RE", "quadruped", "Knee Stretch Arches", "김주아",
    //     "KNEE STRETCH ARCHES", "knee stretch arches");
    // actionService.create("RE", "quadruped", "Knee Stretch Knees Off", "김주아",
    //     "KNEE STRETCH KNEES OFF", "knee stretch knees off");
    // actionService.create("RE", "quadruped", "Knee Stretch Round", "김주아",
    //     "KNEE STRETCH ROUND", "knee stretch round");
    // actionService.create("RE", "quadruped", "Knee Stretch Series", "김주아",
    //     "KNEE STRETCH SERIES", "knee stretch series");
    // actionService.create("CA", "kneeling", "Kneeling Ballet Stretches", "김주아",
    //     "KNEELING BALLET STRETCHES", "kneeling ballet stretches");
    // actionService.create("CA", "kneeling", "Kneeling Cat", "김주아",
    //     "KNEELING CAT", "kneeling cat");
    // actionService.create("CA", "kneeling", "Kneeling Chest Expansion", "김주아",
    //     "KNEELING CHEST EXPANSION", "kneeling chest expansion");
    // actionService.create("CH", "kneeling", "Kneeling Mermaid", "김주아",
    //     "KNEELING MERMAID", "kneeling mermaid");
    // actionService.create("MAT", "kneeling", "Kneeling Side Kick", "김주아",
    //     "KNEELING SIDE KICK", "kneeling side kick");
    // actionService.create("CH", "kneeling", "Kneeling Side Kicks", "김주아",
    //     "KNEELING SIDE KICKS", "kneeling side kicks");
    // actionService.create(
    //     "BA", "standing", "Lay Backs", "김주아", "LAY BACKS", "lay backs");
    // actionService.create(
    //     "RE", "supine", "Leg Circles", "김주아", "LEG CIRCLES", "leg circles");
    // actionService.create("MAT", "plank", "Leg Pull Back", "김주아",
    //     "LEG PULL BACK", "leg pull back");
    // actionService.create("MAT", "plank", "Leg Pull Front", "김주아",
    //     "LEG PULL FRONT", "leg pull front");
    // actionService.create("CA", "supine", "Leg Spring Series", "김주아",
    //     "LEG SPRING SERIES", "leg spring series");
    // actionService.create("CA", "side lying", "Leg Spring Side Kick Series",
    //     "김주아", "LEG SPRING SIDE KICK SERIES", "leg spring side kick series");
    // actionService.create("RE", "supine", "Leg Strap Series", "김주아",
    //     "LEG STRAP SERIES", "leg strap series");
    // actionService.create("RE", "sitting", "Long Back Stretch", "김주아",
    //     "LONG BACK STRETCH", "long back stretch");
    // actionService.create("RE", "prone", "Long Box Backstroke", "김주아",
    //     "LONG BOX BACKSTROKE", "long box backstroke");
    // actionService.create("RE", "prone", "Long Box Horse Back", "김주아",
    //     "LONG BOX HORSE BACK", "long box horse back");
    // actionService.create("RE", "prone", "Long Box Pulling Straps", "김주아",
    //     "LONG BOX PULLING STRAPS", "long box pulling straps");
    // actionService.create("RE", "prone", "Long Box Series", "김주아",
    //     "LONG BOX SERIES", "long box series");
    // actionService.create("RE", "prone", "Long Box T Shape", "김주아",
    //     "LONG BOX T SHAPE", "long box t shape");
    // actionService.create("RE", "prone", "Long Box Teaser", "김주아",
    //     "LONG BOX TEASER", "long box teaser");
    // actionService.create("RE", "supine", "Long Spine Massage", "김주아",
    //     "LONG SPINE MASSAGE", "long spine massage");
    // actionService.create(
    //     "RE", "plank", "Long Stretch", "김주아", "LONG STRETCH", "long stretch");
    // actionService.create("RE", "plank", "Long Stretch Series", "김주아",
    //     "LONG STRETCH SERIES", "long stretch series");
    // actionService.create("MAT", "supine", "Lower And Lift", "김주아",
    //     "LOWER AND LIFT", "lower and lift");
    // actionService.create("RE", "supine", "Lower And Lift", "김주아",
    //     "LOWER AND LIFT", "lower and lift");
    // actionService.create("CH", "standing", "Lunge", "김주아", "LUNGE", "lunge");
    // actionService.create(
    //     "MAT", "sitting", "Mermaid", "김주아", "MERMAID", "mermaid");
    // actionService.create(
    //     "CA", "sitting", "Mermaid", "김주아", "MERMAID", "mermaid");
    // actionService.create(
    //     "CH", "sitting", "Mermaid", "김주아", "MERMAID", "mermaid");
    // actionService.create("CA", "supine", "Midback Series", "김주아",
    //     "MIDBACK SERIES", "midback series");
    // actionService.create("CA", "supine", "Monkey", "김주아", "MONKEY", "monkey");
    // actionService.create("CH", "standing", "Mountain Climb", "김주아",
    //     "MOUNTAIN CLIMB", "mountain climb");
    // actionService.create(
    //     "MAT", "sitting", "Neck Pull", "김주아", "NECK PULL", "neck pull");
    // actionService.create("CH", "prone", "One Arm Press", "김주아", "ONE ARM PRESS",
    //     "one arm press");
    // actionService.create("MAT", "sitting", "Open Leg Rocker", "김주아",
    //     "OPEN LEG ROCKER", "open leg rocker");
    // actionService.create(
    //     "RE", "supine", "Overhead", "김주아", "OVERHEAD", "overhead");
    // actionService.create(
    //     "CA", "supine", "Parakeet", "김주아", "PARAKEET", "parakeet");
    // actionService.create(
    //     "RE", "supine", "Pelvic Lift", "김주아", "PELVIC LIFT", "pelvic lift");
    // actionService.create("MAT", "supine", "Pelvic Movement", "김주아",
    //     "PELVIC MOVEMENT", "pelvic movement");
    // actionService.create(
    //     "CA", "sitting", "Port De Bras", "김주아", "PORT DE BRAS", "port de bras");
    // actionService.create("CH", "sitting", "Press Down Teaser", "김주아",
    //     "PRESS DOWN TEASER", "press down teaser");
    // actionService.create("MAT", "prone", "Prone Heel Squeeze", "김주아",
    //     "PRONE HEEL SQUEEZE", "prone heel squeeze");
    // actionService.create("MAT", "prone", "Prone Leg Lift Series", "김주아",
    //     "PRONE LEG LIFT SERIES", "prone leg lift series");
    // actionService.create("BA", "prone", "Prone Leg Lift Series", "김주아",
    //     "PRONE LEG LIFT SERIES", "prone leg lift series");
    // actionService.create(
    //     "CH", "standing", "Pull Up", "김주아", "PULL UP", "pull up");
    // actionService.create(
    //     "CH", "standing", "Push Down", "김주아", "PUSH DOWN", "push down");
    // actionService.create("CH", "standing", "Push Down With One Arm", "김주아",
    //     "PUSH DOWN WITH ONE ARM", "push down with one arm");
    // actionService.create(
    //     "CA", "sitting", "Push Through", "김주아", "PUSH THROUGH", "push through");
    // actionService.create("CA", "supine", "Push Thru With Feet", "김주아",
    //     "PUSH THRU WITH FEET", "push thru with feet");
    // actionService.create(
    //     "MAT", "plank", "Push Ups", "김주아", "PUSH UPS", "push ups");
    // actionService.create(
    //     "MAT", "prone", "Rocking", "김주아", "ROCKING", "rocking");
    // actionService.create("CA", "sitting", "Roll Back Bar", "김주아",
    //     "ROLL BACK BAR", "roll back bar");
    // actionService.create("CA", "sitting", "Roll Back With One Arm", "김주아",
    //     "ROLL BACK WITH ONE ARM", "roll back with one arm");
    // actionService.create(
    //     "CA", "sitting", "Roll Down", "김주아", "ROLL DOWN", "roll down");
    // actionService.create("BA", "sitting", "Roll Down Round", "김주아",
    //     "ROLL DOWN ROUND", "roll down round");
    // actionService.create("BA", "sitting", "Roll Down Straight", "김주아",
    //     "ROLL DOWN STRAIGHT", "roll down straight");
    // actionService.create(
    //     "MAT", "supine", "Roll Over", "김주아", "ROLL OVER", "roll over");
    // actionService.create(
    //     "CH", "supine", "Roll Over", "김주아", "ROLL OVER", "roll over");
    // actionService.create(
    //     "CA", "supine", "Roll Up", "김주아", "ROLL UP", "roll up");
    // actionService.create("MAT", "sitting", "Rolling Like A Ball", "김주아",
    //     "ROLLING LIKE A BALL", "rolling like a ball");
    // actionService.create("RE", "sitting", "Rowing 90 Degrees", "김주아",
    //     "ROWING 90 DEGREES", "rowing 90 degrees");
    // actionService.create("RE", "sitting", "Rowing From The Chest", "김주아",
    //     "ROWING FROM THE CHEST", "rowing from the chest");
    // actionService.create("RE", "sitting", "Rowing From The Hips", "김주아",
    //     "ROWING FROM THE HIPS", "rowing from the hips");
    // actionService.create("RE", "sitting", "Rowing Hug The Tree", "김주아",
    //     "ROWING HUG THE TREE", "rowing hug the tree");
    // actionService.create("RE", "sitting", "Rowing Into The Sternum", "김주아",
    //     "ROWING INTO THE STERNUM", "rowing into the sternum");
    // actionService.create("RE", "sitting", "Rowing Salute", "김주아",
    //     "ROWING SALUTE", "rowing salute");
    // actionService.create("RE", "sitting", "Rowing Series", "김주아",
    //     "ROWING SERIES", "rowing series");
    // actionService.create(
    //     "RE", "sitting", "Rowing Shave", "김주아", "ROWING SHAVE", "rowing shave");
    // actionService.create(
    //     "RE", "supine", "Running", "김주아", "RUNNING", "running");
    // actionService.create("RE", "standing", "Russian Split", "김주아",
    //     "RUSSIAN SPLIT", "russian split");
    // actionService.create("MAT", "sitting", "Saw", "김주아", "SAW", "saw");
    // actionService.create("CH", "prone", "Scapula Isolation", "김주아",
    //     "SCAPULA ISOLATION", "scapula isolation");
    // actionService.create("MAT", "supine", "Scapula Movement", "김주아",
    //     "SCAPULA MOVEMENT", "scapula movement");
    // actionService.create(
    //     "MAT", "supine", "Scissors", "김주아", "SCISSORS", "scissors");
    // actionService.create("MAT", "sitting", "Seal", "김주아", "SEAL", "seal");
    // actionService.create(
    //     "RE", "supine", "Semi-Circle", "김주아", "SEMI-CIRCLE", "semi-circle");
    // actionService.create("RE", "sitting", "Short Box Round", "김주아",
    //     "SHORT BOX ROUND", "short box round");
    // actionService.create("RE", "sitting", "Short Box Series", "김주아",
    //     "SHORT BOX SERIES", "short box series");
    // actionService.create("BA", "sitting", "Short Box Series", "김주아",
    //     "SHORT BOX SERIES", "short box series");
    // actionService.create("RE", "sitting", "Short Box Side", "김주아",
    //     "SHORT BOX SIDE", "short box side");
    // actionService.create("RE", "sitting", "Short Box Straight", "김주아",
    //     "SHORT BOX STRAIGHT", "short box straight");
    // actionService.create("RE", "sitting", "Short Box Tree", "김주아",
    //     "SHORT BOX TREE", "short box tree");
    // actionService.create("RE", "sitting", "Short Box Twist", "김주아",
    //     "SHORT BOX TWIST", "short box twist");
    // actionService.create("RE", "sitting", "Short Box Twist And Reach", "김주아",
    //     "SHORT BOX TWIST AND REACH", "short box twist and reach");
    // actionService.create("RE", "supine", "Short Spine Massage", "김주아",
    //     "SHORT SPINE MASSAGE", "short spine massage");
    // actionService.create("CA", "supine", "Shoulder And Chest Opener", "김주아",
    //     "SHOULDER AND CHEST OPENER", "shoulder and chest opener");
    // actionService.create("MAT", "supine", "Shoulder Bridge", "김주아",
    //     "SHOULDER BRIDGE", "shoulder bridge");
    // actionService.create("CA", "sitting", "Side Arm Sitting", "김주아",
    //     "SIDE ARM SITTING", "side arm sitting");
    // actionService.create(
    //     "MAT", "sitting", "Side Bend", "김주아", "SIDE BEND", "side bend");
    // actionService.create(
    //     "CA", "side lying", "Side Bend", "김주아", "SIDE BEND", "side bend");
    // actionService.create(
    //     "BA", "standing", "Side Bend", "김주아", "SIDE BEND", "side bend");
    // actionService.create("MAT", "supine", "Side Kick Beats", "김주아",
    //     "SIDE KICK BEATS", "side kick beats");
    // actionService.create("MAT", "side lying", "Side Kick Bicycle", "김주아",
    //     "SIDE KICK BICYCLE", "side kick bicycle");
    // actionService.create("MAT", "side lying", "Side Kick Big Circles", "김주아",
    //     "SIDE KICK BIG CIRCLES", "side kick big circles");
    // actionService.create("MAT", "side lying", "Side Kick Big Scissors", "김주아",
    //     "SIDE KICK BIG SCISSORS", "side kick big scissors");
    // actionService.create("MAT", "side lying", "Side Kick Developpe", "김주아",
    //     "SIDE KICK DEVELOPPE", "side kick developpe");
    // actionService.create("MAT", "side lying", "Side Kick Front Back", "김주아",
    //     "SIDE KICK FRONT BACK", "side kick front back");
    // actionService.create("MAT", "side lying", "Side Kick Hot Potato", "김주아",
    //     "SIDE KICK HOT POTATO", "side kick hot potato");
    // actionService.create("MAT", "side lying", "Side Kick Inner Thigh", "김주아",
    //     "SIDE KICK INNER THIGH", "side kick inner thigh");
    // actionService.create("MAT", "side lying", "Side Kick Series", "김주아",
    //     "SIDE KICK SERIES", "side kick series");
    // actionService.create("MAT", "side lying", "Side Kick Small Circles", "김주아",
    //     "SIDE KICK SMALL CIRCLES", "side kick small circles");
    // actionService.create("MAT", "side lying", "Side Kick Up Down", "김주아",
    //     "SIDE KICK UP DOWN", "side kick up down");
    // actionService.create("BA", "side lying", "Side Leg Lift", "김주아",
    //     "SIDE LEG LIFT", "side leg lift");
    // actionService.create("BA", "side lying", "Side Lying Stretch", "김주아",
    //     "SIDE LYING STRETCH", "side lying stretch");
    // actionService.create(
    //     "BA", "standing", "Side Sit Up", "김주아", "SIDE SIT UP", "side sit up");
    // actionService.create(
    //     "RE", "standing", "Side Split", "김주아", "SIDE SPLIT", "side split");
    // actionService.create("MAT", "supine", "Single Leg Circles", "김주아",
    //     "SINGLE LEG CIRCLES", "single leg circles");
    // actionService.create("MAT", "prone", "Single Leg Kicks", "김주아",
    //     "SINGLE LEG KICKS", "single leg kicks");
    // actionService.create("CH", "sitting", "Single Leg Press", "김주아",
    //     "SINGLE LEG PRESS", "single leg press");
    // actionService.create("MAT", "supine", "Single Leg Stretch", "김주아",
    //     "SINGLE LEG STRETCH", "single leg stretch");
    // actionService.create("CH", "sitting", "Sitthing Triceps Press", "김주아",
    //     "SITTHING TRICEPS PRESS", "sitthing triceps press");
    // actionService.create(
    //     "CA", "sitting", "Sitting Cat", "김주아", "SITTING CAT", "sitting cat");
    // actionService.create("BA", "sitting", "Sitting Leg Series", "김주아",
    //     "SITTING LEG SERIES", "sitting leg series");
    // actionService.create("RE", "standing", "Snake", "김주아", "SNAKE", "snake");
    // actionService.create("MAT", "sitting", "Spine Stretch Forward", "김주아",
    //     "SPINE STRETCH FORWARD", "spine stretch forward");
    // actionService.create("CH", "sitting", "Spine Stretch Forward", "김주아",
    //     "SPINE STRETCH FORWARD", "spine stretch forward");
    // actionService.create(
    //     "MAT", "sitting", "Spine Twist", "김주아", "SPINE TWIST", "spine twist");
    // actionService.create("CA", "standing", "Spread Eagle", "김주아",
    //     "SPREAD EAGLE", "spread eagle");
    // actionService.create("CA", "standing", "Squat", "김주아", "SQUAT", "squat");
    // actionService.create("CA", "standing", "Standing Ballet Stretches", "김주아",
    //     "STANDING BALLET STRETCHES", "standing ballet stretches");
    // actionService.create("CA", "standing", "Standing Cat", "김주아",
    //     "STANDING CAT", "standing cat");
    // actionService.create("CA", "standing", "Standing Chest Expansion", "김주아",
    //     "STANDING CHEST EXPANSION", "standing chest expansion");
    // actionService.create("BA", "standing", "Standing Roll Back", "김주아",
    //     "STANDING ROLL BACK", "standing roll back");
    // actionService.create("CH", "standing", "Standing Roll Down", "김주아",
    //     "STANDING ROLL DOWN", "standing roll down");
    // actionService.create("BA", "standing", "Standing Side Leg Lift", "김주아",
    //     "STANDING SIDE LEG LIFT", "standing side leg lift");
    // actionService.create("CH", "standing", "Standing Single Leg Press", "김주아",
    //     "STANDING SINGLE LEG PRESS", "standing single leg press");
    // actionService.create("CA", "standing", "Standing Spred Eagle", "김주아",
    //     "STANDING SPRED EAGLE", "standing spred eagle");
    // actionService.create("RE", "sitting", "Stomach Massage Reach Up", "김주아",
    //     "STOMACH MASSAGE REACH UP", "stomach massage reach up");
    // actionService.create("RE", "sitting", "Stomach Massage Round", "김주아",
    //     "STOMACH MASSAGE ROUND", "stomach massage round");
    // actionService.create("RE", "sitting", "Stomach Massage Series", "김주아",
    //     "STOMACH MASSAGE SERIES", "stomach massage series");
    // actionService.create("RE", "sitting", "Stomach Massage Straight", "김주아",
    //     "STOMACH MASSAGE STRAIGHT", "stomach massage straight");
    // actionService.create("RE", "sitting", "Stomach Massage Twist", "김주아",
    //     "STOMACH MASSAGE TWIST", "stomach massage twist");
    // actionService.create("MAT", "prone", "Swan", "김주아", "SWAN", "swan");
    // actionService.create("RE", "prone", "Swan", "김주아", "SWAN", "swan");
    // actionService.create("CA", "prone", "Swan", "김주아", "SWAN", "swan");
    // actionService.create("BA", "prone", "Swan", "김주아", "SWAN", "swan");
    // actionService.create(
    //     "MAT", "prone", "Swan Dive", "김주아", "SWAN DIVE", "swan dive");
    // actionService.create(
    //     "CH", "prone", "Swan Dive", "김주아", "SWAN DIVE", "swan dive");
    // actionService.create(
    //     "BA", "prone", "Swan Dive", "김주아", "SWAN DIVE", "swan dive");
    // actionService.create("CH", "prone", "Swan Dive From Floor", "김주아",
    //     "SWAN DIVE FROM FLOOR", "swan dive from floor");
    // actionService.create("BA", "standing", "Swedish Bar Stretch", "김주아",
    //     "SWEDISH BAR STRETCH", "swedish bar stretch");
    // actionService.create(
    //     "MAT", "prone", "Swimming", "김주아", "SWIMMING", "swimming");
    // actionService.create("MAT", "supine", "Teaser", "김주아", "TEASER", "teaser");
    // actionService.create("CA", "supine", "Teaser", "김주아", "TEASER", "teaser");
    // actionService.create("RE", "standing", "Tendon Stretch", "김주아",
    //     "TENDON STRETCH", "tendon stretch");
    // actionService.create("CH", "standing", "Tendon Stretch", "김주아",
    //     "TENDON STRETCH", "tendon stretch");
    // actionService.create(
    //     "MAT", "supine", "The Hundred", "김주아", "THE HUNDRED", "the hundred");
    // actionService.create(
    //     "MAT", "supine", "The Roll Up", "김주아", "THE ROLL UP", "the roll up");
    // actionService.create("MAT", "kneeling", "Thigh Stretch", "김주아",
    //     "THIGH STRETCH", "thigh stretch");
    // actionService.create("RE", "kneeling", "Thigh Stretch", "김주아",
    //     "THIGH STRETCH", "thigh stretch");
    // actionService.create("CA", "kneeling", "Thigh Stretch", "김주아",
    //     "THIGH STRETCH", "thigh stretch");
    // actionService.create(
    //     "MAT", "supine", "Toe Tap", "김주아", "TOE TAP", "toe tap");
    // actionService.create("CA", "supine", "Tower", "김주아", "TOWER", "tower");
    // actionService.create("CH", "prone", "Triceps", "김주아", "TRICEPS", "triceps");
    // actionService.create("RE", "standing", "Twist", "김주아", "TWIST", "twist");
    // actionService.create(
    //     "RE", "standing", "Up Stretch", "김주아", "UP STRETCH", "up stretch");
    // actionService.create("CA", "supine", "Upper Abs Curl", "김주아",
    //     "UPPER ABS CURL", "upper abs curl");

    // 2차 주아님 동작 추가
    // actionService.create(
    //     "MAT", "supine", "Ab Prep", "김주아", "Ab Prep", "Ab Prep");
    // actionService.create(
    //     "MAT", "sitting", "Abs Series", "김주아", "Abs Series", "Abs Series");
    // actionService.create("RE", "supine", "Adductor Stretch", "김주아",
    //     "Adductor Stretch", "Adductor Stretch");
    // actionService.create(
    //     "CA", "supine", "Airplane", "김주아", "Airplane", "Airplane");
    // actionService.create(
    //     "RE", "kneeling", "Arm Circles", "김주아", "Arm Circles", "Arm Circles");
    // actionService.create(
    //     "CH", "standing", "Arm Frog", "김주아", "Arm Frog", "Arm Frog");
    // actionService.create(
    //     "CA", "sitting", "Back Rowing", "김주아", "Back Rowing", "Back Rowing");
    // actionService.create("RE", "sitting", "Back Rowing Prep", "김주아",
    //     "Back Rowing Prep", "Back Rowing Prep");
    // actionService.create("CA", "sitting", "Back Rowing Prep Series", "김주아",
    //     "Back Rowing Prep Series", "Back Rowing Prep Series");
    // actionService.create("RE", "sitting", "Balance Control Back", "김주아",
    //     "Balance Control Back", "Balance Control Back");
    // actionService.create("RE", "plank", "Balance Control Front", "김주아",
    //     "Balance Control Front", "Balance Control Front");
    // actionService.create("MAT", "sitting", "Balance Point", "김주아",
    //     "Balance Point", "Balance Point");
    // actionService.create("BA", "standing", "Ballet Stretch", "김주아",
    //     "Ballet Stretch", "Ballet Stretch");
    // actionService.create(
    //     "RE", "supine", "Bend&Stretch", "김주아", "Bend&Stretch", "Bend&Stretch");
    // actionService.create(
    //     "MAT", "sitting", "Boomerang", "김주아", "Boomerang", "Boomerang");
    // actionService.create("MAT", "prone", "Breast Stroke", "김주아",
    //     "Breast Stroke", "Breast Stroke");
    // actionService.create(
    //     "MAT", "supine", "Breathing", "김주아", "Breathing", "Breathing");
    // actionService.create(
    //     "CA", "supine", "Breathing", "김주아", "Breathing", "Breathing");
    // actionService.create(
    //     "MAT", "quadruped", "Cat Stretch", "김주아", "Cat Stretch", "Cat Stretch");
    // actionService.create("RE", "kneeling", "Chest Expansion", "김주아",
    //     "Chest Expansion", "Chest Expansion");
    // actionService.create(
    //     "MAT", "side lying", "Clam Shell", "김주아", "Clam Shell", "Clam Shell");
    // actionService.create("MAT", "supine", "Control Balance", "김주아",
    //     "Control Balance", "Control Balance");
    // actionService.create(
    //     "RE", "supine", "Coordination", "김주아", "Coordination", "Coordination");
    // actionService.create(
    //     "MAT", "supine", "Corkscrew", "김주아", "Corkscrew", "Corkscrew");
    // actionService.create(
    //     "RE", "supine", "Corscrew", "김주아", "Corscrew", "Corscrew");
    // actionService.create("MAT", "sitting", "Crab", "김주아", "Crab", "Crab");
    // actionService.create(
    //     "MAT", "supine", "Criss Cross", "김주아", "Criss Cross", "Criss Cross");
    // actionService.create("MAT", "prone", "Double Leg Kicks", "김주아",
    //     "Double Leg Kicks", "Double Leg Kicks");
    // actionService.create("MAT", "supine", "Double Leg Stretch", "김주아",
    //     "Double Leg Stretch", "Double Leg Stretch");
    // actionService.create("RE", "quadruped", "Down Stretch", "김주아",
    //     "Down Stretch", "Down Stretch");
    // actionService.create(
    //     "RE", "standing", "Elephant", "김주아", "Elephant", "Elephant");
    // actionService.create("RE", "supine", "Footwork Series", "김주아",
    //     "Footwork Series", "Footwork Series");
    // actionService.create("CH", "sitting", "Footwork Series", "김주아",
    //     "Footwork Series", "Footwork Series");
    // actionService.create("RE", "supine", "Frog", "김주아", "Frog", "Frog");
    // actionService.create("MAT", "prone", "Frog Hip Extension", "김주아",
    //     "Frog Hip Extension", "Frog Hip Extension");
    // actionService.create(
    //     "CA", "sitting", "Front Rowing", "김주아", "Front Rowing", "Front Rowing");
    // actionService.create("RE", "sitting", "Front Rowing Prep", "김주아",
    //     "Front Rowing Prep", "Front Rowing Prep");
    // actionService.create("CA", "sitting", "Front Rowing Prep Series", "김주아",
    //     "Front Rowing Prep Series", "Front Rowing Prep Series");
    // actionService.create(
    //     "RE", "standing", "Front Split", "김주아", "Front Split", "Front Split");
    // actionService.create(
    //     "CA", "supine", "Full Hanging", "김주아", "Full Hanging", "Full Hanging");
    // actionService.create(
    //     "CA", "prone", "Full Swan", "김주아", "Full Swan", "Full Swan");
    // actionService.create("CH", "standing", "Going Up Front", "김주아",
    //     "Going Up Front", "Going Up Front");
    // actionService.create("CH", "standing", "Going Up Side", "김주아",
    //     "Going Up Side", "Going Up Side");
    // actionService.create(
    //     "CA", "supine", "Half Hanging", "김주아", "Half Hanging", "Half Hanging");
    // actionService.create("MAT", "sitting", "Half Roll Back", "김주아",
    //     "Half Roll Back", "Half Roll Back");
    // actionService.create(
    //     "MAT", "prone", "Half Swan", "김주아", "Half Swan", "Half Swan");
    // actionService.create("CH", "supine", "Hams Press Hips Down", "김주아",
    //     "Hams Press Hips Down", "Hams Press Hips Down");
    // actionService.create("CH", "supine", "Hams Press Hips Up", "김주아",
    //     "Hams Press Hips Up", "Hams Press Hips Up");
    // actionService.create("CA", "standing", "Hanging Pull Ups", "김주아",
    //     "Hanging Pull Ups", "Hanging Pull Ups");
    // actionService.create(
    //     "MAT", "supine", "High Bicycle", "김주아", "High Bicycle", "High Bicycle");
    // actionService.create("MAT", "supine", "High Scissors", "김주아",
    //     "High Scissors", "High Scissors");
    // actionService.create(
    //     "MAT", "sitting", "Hip Circles", "김주아", "Hip Circles", "Hip Circles");
    // actionService.create(
    //     "CA", "side lying", "Hip Opener", "김주아", "Hip Opener", "Hip Opener");
    // actionService.create(
    //     "MAT", "supine", "Hip Release", "김주아", "Hip Release", "Hip Release");
    // actionService.create(
    //     "MAT", "supine", "Hip Roll", "김주아", "Hip Roll", "Hip Roll");
    // actionService.create(
    //     "CH", "sitting", "Horse Back", "김주아", "Horse Back", "Horse Back");
    // actionService.create(
    //     "BA", "sitting", "Horse Back", "김주아", "Horse Back", "Horse Back");
    // actionService.create(
    //     "MAT", "supine", "Hundred", "김주아", "Hundred", "Hundred");
    // actionService.create(
    //     "RE", "supine", "Hundred", "김주아", "Hundred", "Hundred");
    // actionService.create("MAT", "supine", "Imprinting Transition", "김주아",
    //     "Imprinting Transition", "Imprinting Transition");
    // actionService.create(
    //     "MAT", "supine", "Jack Knife", "김주아", "Jack Knife", "Jack Knife");
    // actionService.create(
    //     "CH", "supine", "Jack Knife", "김주아", "Jack Knife", "Jack Knife");
    // actionService.create("CH", "standing", "Knee Raise Series", "김주아",
    //     "Knee Raise Series", "Knee Raise Series");
    // actionService.create("RE", "quadruped", "Knee Stretch Arches", "김주아",
    //     "Knee Stretch Arches", "Knee Stretch Arches");
    // actionService.create("RE", "quadruped", "Knee Stretch Knees Off", "김주아",
    //     "Knee Stretch Knees Off", "Knee Stretch Knees Off");
    // actionService.create("RE", "quadruped", "Knee Stretch Round", "김주아",
    //     "Knee Stretch Round", "Knee Stretch Round");
    // actionService.create("RE", "quadruped", "Knee Stretch Series", "김주아",
    //     "Knee Stretch Series", "Knee Stretch Series");
    // actionService.create("CA", "kneeling", "Kneeling Ballet Stretches", "김주아",
    //     "Kneeling Ballet Stretches", "Kneeling Ballet Stretches");
    // actionService.create("CA", "kneeling", "Kneeling Cat", "김주아",
    //     "Kneeling Cat", "Kneeling Cat");
    // actionService.create("CA", "kneeling", "Kneeling Chest Expansion", "김주아",
    //     "Kneeling Chest Expansion", "Kneeling Chest Expansion");
    // actionService.create("CH", "kneeling", "Kneeling Mermaid", "김주아",
    //     "Kneeling Mermaid", "Kneeling Mermaid");
    // actionService.create("MAT", "kneeling", "Kneeling Side Kick", "김주아",
    //     "Kneeling Side Kick", "Kneeling Side Kick");
    // actionService.create("CH", "kneeling", "Kneeling Side Kicks", "김주아",
    //     "Kneeling Side Kicks", "Kneeling Side Kicks");
    // actionService.create(
    //     "BA", "standing", "Lay Backs", "김주아", "Lay Backs", "Lay Backs");
    // actionService.create(
    //     "RE", "supine", "Leg Circles", "김주아", "Leg Circles", "Leg Circles");
    // actionService.create("MAT", "plank", "Leg Pull Back", "김주아",
    //     "Leg Pull Back", "Leg Pull Back");
    // actionService.create("MAT", "plank", "Leg Pull Front", "김주아",
    //     "Leg Pull Front", "Leg Pull Front");
    // actionService.create("CA", "supine", "Leg Spring Series", "김주아",
    //     "Leg Spring Series", "Leg Spring Series");
    // actionService.create("CA", "side lying", "Leg Spring Side Kick Series",
    //     "김주아", "Leg Spring Side Kick Series", "Leg Spring Side Kick Series");
    // actionService.create("RE", "supine", "Leg Strap Series", "김주아",
    //     "Leg Strap Series", "Leg Strap Series");
    // actionService.create("RE", "sitting", "Long Back Stretch", "김주아",
    //     "Long Back Stretch", "Long Back Stretch");
    // actionService.create("RE", "prone", "Long Box Backstroke", "김주아",
    //     "Long Box Backstroke", "Long Box Backstroke");
    // actionService.create("RE", "prone", "Long Box Horse Back", "김주아",
    //     "Long Box Horse Back", "Long Box Horse Back");
    // actionService.create("RE", "prone", "Long Box Pulling Straps", "김주아",
    //     "Long Box Pulling Straps", "Long Box Pulling Straps");
    // actionService.create("RE", "prone", "Long Box Series", "김주아",
    //     "Long Box Series", "Long Box Series");
    // actionService.create("RE", "prone", "Long Box T Shape", "김주아",
    //     "Long Box T Shape", "Long Box T Shape");
    // actionService.create("RE", "prone", "Long Box Teaser", "김주아",
    //     "Long Box Teaser", "Long Box Teaser");
    // actionService.create("RE", "supine", "Long Spine Massage", "김주아",
    //     "Long Spine Massage", "Long Spine Massage");
    // actionService.create(
    //     "RE", "plank", "Long Stretch", "김주아", "Long Stretch", "Long Stretch");
    // actionService.create("RE", "plank", "Long Stretch Series", "김주아",
    //     "Long Stretch Series", "Long Stretch Series");
    // actionService.create("MAT", "supine", "Lower And Lift", "김주아",
    //     "Lower And Lift", "Lower And Lift");
    // actionService.create("RE", "supine", "Lower And Lift", "김주아",
    //     "Lower And Lift", "Lower And Lift");
    // actionService.create("CH", "standing", "Lunge", "김주아", "Lunge", "Lunge");
    // actionService.create(
    //     "MAT", "sitting", "Mermaid", "김주아", "Mermaid", "Mermaid");
    // actionService.create(
    //     "CA", "sitting", "Mermaid", "김주아", "Mermaid", "Mermaid");
    // actionService.create(
    //     "CH", "sitting", "Mermaid", "김주아", "Mermaid", "Mermaid");
    // actionService.create("CA", "supine", "Midback Series", "김주아",
    //     "Midback Series", "Midback Series");
    // actionService.create("CA", "supine", "Monkey", "김주아", "Monkey", "Monkey");
    // actionService.create("CH", "standing", "Mountain Climb", "김주아",
    //     "Mountain Climb", "Mountain Climb");
    // actionService.create(
    //     "MAT", "sitting", "Neck Pull", "김주아", "Neck Pull", "Neck Pull");
    // actionService.create("CH", "prone", "One Arm Press", "김주아", "One Arm Press",
    //     "One Arm Press");
    // actionService.create("MAT", "sitting", "Open Leg Rocker", "김주아",
    //     "Open Leg Rocker", "Open Leg Rocker");
    // actionService.create(
    //     "RE", "supine", "Overhead", "김주아", "Overhead", "Overhead");
    // actionService.create(
    //     "CA", "supine", "Parakeet", "김주아", "Parakeet", "Parakeet");
    // actionService.create(
    //     "RE", "supine", "Pelvic Lift", "김주아", "Pelvic Lift", "Pelvic Lift");
    // actionService.create("MAT", "supine", "Pelvic Movement", "김주아",
    //     "Pelvic Movement", "Pelvic Movement");
    // actionService.create(
    //     "CA", "sitting", "Port De Bras", "김주아", "Port De Bras", "Port De Bras");
    // actionService.create("CH", "sitting", "Press Down Teaser", "김주아",
    //     "Press Down Teaser", "Press Down Teaser");
    // actionService.create("MAT", "prone", "Prone Heel Squeeze", "김주아",
    //     "Prone Heel Squeeze", "Prone Heel Squeeze");
    // actionService.create("MAT", "prone", "Prone Leg Lift Series", "김주아",
    //     "Prone Leg Lift Series", "Prone Leg Lift Series");
    // actionService.create("BA", "prone", "Prone Leg Lift Series", "김주아",
    //     "Prone Leg Lift Series", "Prone Leg Lift Series");
    // actionService.create(
    //     "CH", "standing", "Pull Up", "김주아", "Pull Up", "Pull Up");
    // actionService.create(
    //     "CH", "standing", "Push Down", "김주아", "Push Down", "Push Down");
    // actionService.create("CH", "standing", "Push Down With One Arm", "김주아",
    //     "Push Down With One Arm", "Push Down With One Arm");
    // actionService.create(
    //     "CA", "sitting", "Push Through", "김주아", "Push Through", "Push Through");
    // actionService.create("CA", "supine", "Push Thru With Feet", "김주아",
    //     "Push Thru With Feet", "Push Thru With Feet");
    // actionService.create(
    //     "MAT", "plank", "Push Ups", "김주아", "Push Ups", "Push Ups");
    // actionService.create(
    //     "MAT", "prone", "Rocking", "김주아", "Rocking", "Rocking");
    // actionService.create("CA", "sitting", "Roll Back Bar", "김주아",
    //     "Roll Back Bar", "Roll Back Bar");
    // actionService.create("CA", "sitting", "Roll Back With One Arm", "김주아",
    //     "Roll Back With One Arm", "Roll Back With One Arm");
    // actionService.create(
    //     "CA", "sitting", "Roll Down", "김주아", "Roll Down", "Roll Down");
    // actionService.create("BA", "sitting", "Roll Down Round", "김주아",
    //     "Roll Down Round", "Roll Down Round");
    // actionService.create("BA", "sitting", "Roll Down Straight", "김주아",
    //     "Roll Down Straight", "Roll Down Straight");
    // actionService.create(
    //     "MAT", "supine", "Roll Over", "김주아", "Roll Over", "Roll Over");
    // actionService.create(
    //     "CH", "supine", "Roll Over", "김주아", "Roll Over", "Roll Over");
    // actionService.create(
    //     "CA", "supine", "Roll Up", "김주아", "Roll Up", "Roll Up");
    // actionService.create("MAT", "sitting", "Rolling Like A Ball", "김주아",
    //     "Rolling Like A Ball", "Rolling Like A Ball");
    // actionService.create("RE", "sitting", "Rowing 90 Degrees", "김주아",
    //     "Rowing 90 Degrees", "Rowing 90 Degrees");
    // actionService.create("RE", "sitting", "Rowing From The Chest", "김주아",
    //     "Rowing From The Chest", "Rowing From The Chest");
    // actionService.create("RE", "sitting", "Rowing From The Hips", "김주아",
    //     "Rowing From The Hips", "Rowing From The Hips");
    // actionService.create("RE", "sitting", "Rowing Hug The Tree", "김주아",
    //     "Rowing Hug The Tree", "Rowing Hug The Tree");
    // actionService.create("RE", "sitting", "Rowing Into The Sternum", "김주아",
    //     "Rowing Into The Sternum", "Rowing Into The Sternum");
    // actionService.create("RE", "sitting", "Rowing Salute", "김주아",
    //     "Rowing Salute", "Rowing Salute");
    // actionService.create("RE", "sitting", "Rowing Series", "김주아",
    //     "Rowing Series", "Rowing Series");
    // actionService.create(
    //     "RE", "sitting", "Rowing Shave", "김주아", "Rowing Shave", "Rowing Shave");
    // actionService.create(
    //     "RE", "supine", "Running", "김주아", "Running", "Running");
    // actionService.create("RE", "standing", "Russian Split", "김주아",
    //     "Russian Split", "Russian Split");
    // actionService.create("MAT", "sitting", "Saw", "김주아", "Saw", "Saw");
    // actionService.create("CH", "prone", "Scapula Isolation", "김주아",
    //     "Scapula Isolation", "Scapula Isolation");
    // actionService.create("MAT", "supine", "Scapula Movement", "김주아",
    //     "Scapula Movement", "Scapula Movement");
    // actionService.create(
    //     "MAT", "supine", "Scissors", "김주아", "Scissors", "Scissors");
    // actionService.create("MAT", "sitting", "Seal", "김주아", "Seal", "Seal");
    // actionService.create(
    //     "RE", "supine", "Semi-Circle", "김주아", "Semi-Circle", "Semi-Circle");
    // actionService.create("RE", "sitting", "Short Box Round", "김주아",
    //     "Short Box Round", "Short Box Round");
    // actionService.create("RE", "sitting", "Short Box Series", "김주아",
    //     "Short Box Series", "Short Box Series");
    // actionService.create("BA", "sitting", "Short Box Series", "김주아",
    //     "Short Box Series", "Short Box Series");
    // actionService.create("RE", "sitting", "Short Box Side", "김주아",
    //     "Short Box Side", "Short Box Side");
    // actionService.create("RE", "sitting", "Short Box Straight", "김주아",
    //     "Short Box Straight", "Short Box Straight");
    // actionService.create("RE", "sitting", "Short Box Tree", "김주아",
    //     "Short Box Tree", "Short Box Tree");
    // actionService.create("RE", "sitting", "Short Box Twist", "김주아",
    //     "Short Box Twist", "Short Box Twist");
    // actionService.create("RE", "sitting", "Short Box Twist And Reach", "김주아",
    //     "Short Box Twist And Reach", "Short Box Twist And Reach");
    // actionService.create("RE", "supine", "Short Spine Massage", "김주아",
    //     "Short Spine Massage", "Short Spine Massage");
    // actionService.create("CA", "supine", "Shoulder And Chest Opener", "김주아",
    //     "Shoulder And Chest Opener", "Shoulder And Chest Opener");
    // actionService.create("MAT", "supine", "Shoulder Bridge", "김주아",
    //     "Shoulder Bridge", "Shoulder Bridge");
    // actionService.create("CA", "sitting", "Side Arm Sitting", "김주아",
    //     "Side Arm Sitting", "Side Arm Sitting");
    // actionService.create(
    //     "MAT", "sitting", "Side Bend", "김주아", "Side Bend", "Side Bend");
    // actionService.create(
    //     "CA", "side lying", "Side Bend", "김주아", "Side Bend", "Side Bend");
    // actionService.create(
    //     "BA", "standing", "Side Bend", "김주아", "Side Bend", "Side Bend");
    // actionService.create("MAT", "supine", "Side Kick Beats", "김주아",
    //     "Side Kick Beats", "Side Kick Beats");
    // actionService.create("MAT", "side lying", "Side Kick Bicycle", "김주아",
    //     "Side Kick Bicycle", "Side Kick Bicycle");
    // actionService.create("MAT", "side lying", "Side Kick Big Circles", "김주아",
    //     "Side Kick Big Circles", "Side Kick Big Circles");
    // actionService.create("MAT", "side lying", "Side Kick Big Scissors", "김주아",
    //     "Side Kick Big Scissors", "Side Kick Big Scissors");
    // actionService.create("MAT", "side lying", "Side Kick Developpe", "김주아",
    //     "Side Kick Developpe", "Side Kick Developpe");
    // actionService.create("MAT", "side lying", "Side Kick Front Back", "김주아",
    //     "Side Kick Front Back", "Side Kick Front Back");
    // actionService.create("MAT", "side lying", "Side Kick Hot Potato", "김주아",
    //     "Side Kick Hot Potato", "Side Kick Hot Potato");
    // actionService.create("MAT", "side lying", "Side Kick Inner Thigh", "김주아",
    //     "Side Kick Inner Thigh", "Side Kick Inner Thigh");
    // actionService.create("MAT", "side lying", "Side Kick Series", "김주아",
    //     "Side Kick Series", "Side Kick Series");
    // actionService.create("MAT", "side lying", "Side Kick Small Circles", "김주아",
    //     "Side Kick Small Circles", "Side Kick Small Circles");
    // actionService.create("MAT", "side lying", "Side Kick Up Down", "김주아",
    //     "Side Kick Up Down", "Side Kick Up Down");
    // actionService.create("BA", "side lying", "Side Leg Lift", "김주아",
    //     "Side Leg Lift", "Side Leg Lift");
    // actionService.create("BA", "side lying", "Side Lying Stretch", "김주아",
    //     "Side Lying Stretch", "Side Lying Stretch");
    // actionService.create(
    //     "BA", "standing", "Side Sit Up", "김주아", "Side Sit Up", "Side Sit Up");
    // actionService.create(
    //     "RE", "standing", "Side Split", "김주아", "Side Split", "Side Split");
    // actionService.create("MAT", "supine", "Single Leg Circles", "김주아",
    //     "Single Leg Circles", "Single Leg Circles");
    // actionService.create("MAT", "prone", "Single Leg Kicks", "김주아",
    //     "Single Leg Kicks", "Single Leg Kicks");
    // actionService.create("CH", "sitting", "Single Leg Press", "김주아",
    //     "Single Leg Press", "Single Leg Press");
    // actionService.create("MAT", "supine", "Single Leg Stretch", "김주아",
    //     "Single Leg Stretch", "Single Leg Stretch");
    // actionService.create("CH", "sitting", "Sitthing Triceps Press", "김주아",
    //     "Sitthing Triceps Press", "Sitthing Triceps Press");
    // actionService.create(
    //     "CA", "sitting", "Sitting Cat", "김주아", "Sitting Cat", "Sitting Cat");
    // actionService.create("BA", "sitting", "Sitting Leg Series", "김주아",
    //     "Sitting Leg Series", "Sitting Leg Series");
    // actionService.create("RE", "standing", "Snake", "김주아", "Snake", "Snake");
    // actionService.create("MAT", "sitting", "Spine Stretch Forward", "김주아",
    //     "Spine Stretch Forward", "Spine Stretch Forward");
    // actionService.create("CH", "sitting", "Spine Stretch Forward", "김주아",
    //     "Spine Stretch Forward", "Spine Stretch Forward");
    // actionService.create(
    //     "MAT", "sitting", "Spine Twist", "김주아", "Spine Twist", "Spine Twist");
    // actionService.create("CA", "standing", "Spread Eagle", "김주아",
    //     "Spread Eagle", "Spread Eagle");
    // actionService.create("CA", "standing", "Squat", "김주아", "Squat", "Squat");
    // actionService.create("CA", "standing", "Standing Ballet Stretches", "김주아",
    //     "Standing Ballet Stretches", "Standing Ballet Stretches");
    // actionService.create("CA", "standing", "Standing Cat", "김주아",
    //     "Standing Cat", "Standing Cat");
    // actionService.create("CA", "standing", "Standing Chest Expansion", "김주아",
    //     "Standing Chest Expansion", "Standing Chest Expansion");
    // actionService.create("BA", "standing", "Standing Roll Back", "김주아",
    //     "Standing Roll Back", "Standing Roll Back");
    // actionService.create("CH", "standing", "Standing Roll Down", "김주아",
    //     "Standing Roll Down", "Standing Roll Down");
    // actionService.create("BA", "standing", "Standing Side Leg Lift", "김주아",
    //     "Standing Side Leg Lift", "Standing Side Leg Lift");
    // actionService.create("CH", "standing", "Standing Single Leg Press", "김주아",
    //     "Standing Single Leg Press", "Standing Single Leg Press");
    // actionService.create("CA", "standing", "Standing Spred Eagle", "김주아",
    //     "Standing Spred Eagle", "Standing Spred Eagle");
    // actionService.create("RE", "sitting", "Stomach Massage Reach Up", "김주아",
    //     "Stomach Massage Reach Up", "Stomach Massage Reach Up");
    // actionService.create("RE", "sitting", "Stomach Massage Round", "김주아",
    //     "Stomach Massage Round", "Stomach Massage Round");
    // actionService.create("RE", "sitting", "Stomach Massage Series", "김주아",
    //     "Stomach Massage Series", "Stomach Massage Series");
    // actionService.create("RE", "sitting", "Stomach Massage Straight", "김주아",
    //     "Stomach Massage Straight", "Stomach Massage Straight");
    // actionService.create("RE", "sitting", "Stomach Massage Twist", "김주아",
    //     "Stomach Massage Twist", "Stomach Massage Twist");
    // actionService.create("MAT", "prone", "Swan", "김주아", "Swan", "Swan");
    // actionService.create("RE", "prone", "Swan", "김주아", "Swan", "Swan");
    // actionService.create("CA", "prone", "Swan", "김주아", "Swan", "Swan");
    // actionService.create("BA", "prone", "Swan", "김주아", "Swan", "Swan");
    // actionService.create(
    //     "MAT", "prone", "Swan Dive", "김주아", "Swan Dive", "Swan Dive");
    // actionService.create(
    //     "CH", "prone", "Swan Dive", "김주아", "Swan Dive", "Swan Dive");
    // actionService.create(
    //     "BA", "prone", "Swan Dive", "김주아", "Swan Dive", "Swan Dive");
    // actionService.create("CH", "prone", "Swan Dive From Floor", "김주아",
    //     "Swan Dive From Floor", "Swan Dive From Floor");
    // actionService.create("BA", "standing", "Swedish Bar Stretch", "김주아",
    //     "Swedish Bar Stretch", "Swedish Bar Stretch");
    // actionService.create(
    //     "MAT", "prone", "Swimming", "김주아", "Swimming", "Swimming");
    // actionService.create("MAT", "supine", "Teaser", "김주아", "Teaser", "Teaser");
    // actionService.create("CA", "supine", "Teaser", "김주아", "Teaser", "Teaser");
    // actionService.create("RE", "standing", "Tendon Stretch", "김주아",
    //     "Tendon Stretch", "Tendon Stretch");
    // actionService.create("CH", "standing", "Tendon Stretch", "김주아",
    //     "Tendon Stretch", "Tendon Stretch");
    // actionService.create(
    //     "MAT", "supine", "The Hundred", "김주아", "The Hundred", "The Hundred");
    // actionService.create(
    //     "MAT", "supine", "The Roll Up", "김주아", "The Roll Up", "The Roll Up");
    // actionService.create("MAT", "kneeling", "Thigh Stretch", "김주아",
    //     "Thigh Stretch", "Thigh Stretch");
    // actionService.create("RE", "kneeling", "Thigh Stretch", "김주아",
    //     "Thigh Stretch", "Thigh Stretch");
    // actionService.create("CA", "kneeling", "Thigh Stretch", "김주아",
    //     "Thigh Stretch", "Thigh Stretch");
    // actionService.create(
    //     "MAT", "supine", "Toe Tap", "김주아", "Toe Tap", "Toe Tap");
    // actionService.create("CA", "supine", "Tower", "김주아", "Tower", "Tower");
    // actionService.create("CH", "prone", "Triceps", "김주아", "Triceps", "Triceps");
    // actionService.create("RE", "standing", "Twist", "김주아", "Twist", "Twist");
    // actionService.create(
    //     "RE", "standing", "Up Stretch", "김주아", "Up Stretch", "Up Stretch");
    // actionService.create("CA", "supine", "Upper Abs Curl", "김주아",
    //     "Upper Abs Curl", "Upper Abs Curl");

    // 1차 운동 목록
    // actionService.create("MAT", "supine", "Hundred", "HUNDRED", "hundred");
    // actionService.create("MAT", "supine", "Roll Up", "ROLL UP", "roll up");
    // actionService.create(
    //     "MAT", "supine", "Roll Over", "ROLL OVER", "roll over");
    // actionService.create("MAT", "supine", "Single Leg Circles",
    //     "SINGLE LEG CIRCLES", "single leg circles");
    // actionService.create("MAT", "supine", "Rolling Like A Ball",
    //     "ROLLING LIKE A BALL", "rolling like a ball");
    // actionService.create("MAT", "supine", "Single Leg Stretch",
    //     "SINGLE LEG STRETCH", "single leg stretch");
    // actionService.create("MAT", "supine", "Double Leg Stretch",
    //     "DOUBLE LEG STRETCH", "double leg stretch");
    // actionService.create("MAT", "supine", "Scissors", "SCISSORS", "scissors");
    // actionService.create(
    //     "MAT", "supine", "Lower And Lift", "LOWER AND LIFT", "lower and lift");
    // actionService.create(
    //     "MAT", "supine", "Criss Cross", "CRISS CROSS", "criss cross");
    // actionService.create("MAT", "sitting", "Spine Stretch Forward",
    //     "SPINE STRETCH FORWARD", "spine stretch forward");
    // actionService.create("MAT", "sitting", "Open Leg Rocker", "OPEN LEG ROCKER",
    //     "open leg rocker");
    // actionService.create(
    //     "MAT", "supine", "Corkscrew", "CORKSCREW", "corkscrew");
    // actionService.create("MAT", "supine", "Saw", "SAW", "saw");
    // actionService.create("MAT", "prone", "Swan Dive", "SWAN DIVE", "swan dive");
    // actionService.create("MAT", "prone", "Single Leg Kicks", "SINGLE LEG KICKS",
    //     "single leg kicks");
    // actionService.create("MAT", "prone", "Double Leg Kicks", "DOUBLE LEG KICKS",
    //     "double leg kicks");
    // actionService.create(
    //     "MAT", "kneeling", "Thigh Stretch", "THIGH STRETCH", "thigh stretch");
    // actionService.create(
    //     "MAT", "sitting", "Neck Pull", "NECK PULL", "neck pull");
    // actionService.create(
    //     "MAT", "supine", "High Scissors", "HIGH SCISSORS", "high scissors");
    // actionService.create(
    //     "MAT", "supine", "High Bicycle", "HIGH BICYCLE", "high bicycle");
    // actionService.create("MAT", "supine", "Shoulder Bridge", "SHOULDER BRIDGE",
    //     "shoulder bridge");
    // actionService.create(
    //     "MAT", "sitting", "Spine Twist", "SPINE TWIST", "spine twist");
    // actionService.create(
    //     "MAT", "supine", "Jack Knife", "JACK KNIFE", "jack knife");
    // actionService.create("MAT", "side lying", "Side Kick Front&Back",
    //     "SIDE KICK FRONT&BACK", "side kick front&back");
    // actionService.create("MAT", "side lying", "Side Kick Up&Down",
    //     "SIDE KICK UP&DOWN", "side kick up&down");
    // actionService.create("MAT", "side lying", "Side Kick Small Circles",
    //     "SIDE KICK SMALL CIRCLES", "side kick small circles");
    // actionService.create("MAT", "side lying", "Side Kick Bicycle",
    //     "SIDE KICK BICYCLE", "side kick bicycle");
    // actionService.create("MAT", "side lying", "Side Kick Developpe",
    //     "SIDE KICK DEVELOPPE", "side kick developpe");
    // actionService.create("MAT", "side lying", "Side Kick Inner Thigh",
    //     "SIDE KICK INNER THIGH", "side kick inner thigh");
    // actionService.create("MAT", "side lying", "Side Kick Hot Potato",
    //     "SIDE KICK HOT POTATO", "side kick hot potato");
    // actionService.create("MAT", "side lying", "Side Kick Big Scissors",
    //     "SIDE KICK BIG SCISSORS", "side kick big scissors");
    // actionService.create("MAT", "side lying", "Side Kick Big Circles",
    //     "SIDE KICK BIG CIRCLES", "side kick big circles");
    // actionService.create("MAT", "supine", "Teaser 1", "TEASER 1", "teaser 1");
    // actionService.create(
    //     "MAT", "supine", "Teaser 2,3", "TEASER 2,3", "teaser 2,3");
    // actionService.create(
    //     "MAT", "sitting", "Hip Circles", "HIP CIRCLES", "hip circles");
    // actionService.create("MAT", "prone", "Swimming", "SWIMMING", "swimming");
    // actionService.create(
    //     "MAT", "prone", "Leg Pull Front", "LEG PULL FRONT", "leg pull front");
    // actionService.create(
    //     "MAT", "prone", "Leg Pull Back", "LEG PULL BACK", "leg pull back");
    // actionService.create("MAT", "kneeling", "Kneeling Side Kick",
    //     "KNEELING SIDE KICK", "kneeling side kick");
    // actionService.create(
    //     "MAT", "side lying", "Side Bend", "SIDE BEND", "side bend");
    // actionService.create(
    //     "MAT", "sitting", "Boomerang", "BOOMERANG", "boomerang");
    // actionService.create("MAT", "sitting", "Seal", "SEAL", "seal");
    // actionService.create("MAT", "kneeling", "Crab", "CRAB", "crab");
    // actionService.create("MAT", "prone", "Rocking", "ROCKING", "rocking");
    // actionService.create("MAT", "supine", "Control Balance", "CONTROL BALANCE",
    //     "control balance");
    // actionService.create("MAT", "standing", "Push Ups", "PUSH UPS", "push ups");
    // actionService.create("RE", "supine", "Footwork Series", "FOOTWORK SERIES",
    //     "footwork series");
    // actionService.create("RE", "supine", "Hundred", "HUNDRED", "hundred");
    // actionService.create("RE", "supine", "Overhead", "OVERHEAD", "overhead");
    // actionService.create(
    //     "RE", "supine", "Coordination", "COORDINATION", "coordination");
    // actionService.create("RE", "sitting", "Back Rowing Series",
    //     "BACK ROWING SERIES", "back rowing series");
    // actionService.create("RE", "sitting", "Front Rowing Series",
    //     "FRONT ROWING SERIES", "front rowing series");
    // actionService.create("RE", "prone", "Swan", "SWAN", "swan");
    // actionService.create("RE", "prone", "Long Box Pulling Strap",
    //     "LONG BOX PULLING STRAP", "long box pulling strap");
    // actionService.create("RE", "supine", "Long Box Backstroke",
    //     "LONG BOX BACKSTROKE", "long box backstroke");
    // actionService.create("RE", "supine", "Long Box Teaser", "LONG BOX TEASER",
    //     "long box teaser");
    // actionService.create("RE", "sitting", "Long Box Horseback",
    //     "LONG BOX HORSEBACK", "long box horseback");
    // actionService.create("RE", "sitting", "Short Box Series",
    //     "SHORT BOX SERIES", "short box series");
    // actionService.create(
    //     "RE", "prone", "Long Stretch", "LONG STRETCH", "long stretch");
    // actionService.create(
    //     "RE", "prone", "Down Stretch", "DOWN STRETCH", "down stretch");
    // actionService.create("RE", "standing", "Elephant", "ELEPHANT", "elephant");
    // actionService.create("RE", "sitting", "Long Back Stretch",
    //     "LONG BACK STRETCH", "long back stretch");
    // actionService.create("RE", "sitting", "Stomach Massage Series",
    //     "STOMACH MASSAGE SERIES", "stomach massage series");
    // actionService.create(
    //     "RE", "standing", "Tendon Stretch", "TENDON STRETCH", "tendon stretch");
    // actionService.create("RE", "supine", "Short Spine Massage",
    //     "SHORT SPINE MASSAGE", "short spine massage");
    // actionService.create(
    //     "RE", "supine", "Semi-Circle", "SEMI-CIRCLE", "semi-circle");
    // actionService.create("RE", "kneeling", "Chest Expansion", "CHEST EXPANSION",
    //     "chest expansion");
    // actionService.create(
    //     "RE", "kneeling", "Thigh Stretch", "THIGH STRETCH", "thigh stretch");
    // actionService.create(
    //     "RE", "kneeling", "Arm Circles", "ARM CIRCLES", "arm circles");
    // actionService.create(
    //     "RE", "standing", "Snake&Twist", "SNAKE&TWIST", "snake&twist");
    // actionService.create("RE", "supine", "Corkscrew", "CORKSCREW", "corkscrew");
    // actionService.create("RE", "supine", "Long Spine Massage",
    //     "LONG SPINE MASSAGE", "long spine massage");
    // actionService.create(
    //     "RE", "supine", "Leg Circles", "LEG CIRCLES", "leg circles");
    // actionService.create("RE", "supine", "Frog", "FROG", "frog");
    // actionService.create("RE", "kneeling", "Knee Stretch Series",
    //     "KNEE STRETCH SERIES", "knee stretch series");
    // actionService.create("RE", "supine", "Running", "RUNNING", "running");
    // actionService.create(
    //     "RE", "supine", "Pelvic Lift", "PELVIC LIFT", "pelvic lift");
    // actionService.create("RE", "prone", "Balance Control Front",
    //     "BALANCE CONTROL FRONT", "balance control front");
    // actionService.create("RE", "supine", "Balance Control Back",
    //     "BALANCE CONTROL BACK", "balance control back");
    // actionService.create(
    //     "RE", "standing", "Side Split", "SIDE SPLIT", "side split");
    // actionService.create(
    //     "RE", "standing", "Front Split", "FRONT SPLIT", "front split");
    // actionService.create(
    //     "RE", "standing", "Russian Split", "RUSSIAN SPLIT", "russian split");
    // actionService.create(
    //     "CA", "sitting", "Roll Down", "ROLL DOWN", "roll down");
    // actionService.create("CA", "sitting", "Roll Down With One Arm",
    //     "ROLL DOWN WITH ONE ARM", "roll down with one arm");
    // actionService.create("CA", "supine", "Airplane", "AIRPLANE", "airplane");
    // actionService.create("CA", "supine", "Breathing", "BREATHING", "breathing");
    // actionService.create("CA", "standing", "Standing Ballet Stretches",
    //     "STANDING BALLET STRETCHES", "standing ballet stretches");
    // actionService.create("CA", "kneeling", "Kneeling Ballet Stretches",
    //     "KNEELING BALLET STRETCHES", "kneeling ballet stretches");
    // actionService.create("CA", "supine", "Shoulder And Chest Opener",
    //     "SHOULDER AND CHEST OPENER", "shoulder and chest opener");
    // actionService.create("CA", "supine", "Teaser", "TEASER", "teaser");
    // actionService.create(
    //     "CA", "sitting", "Sitting Cat", "SITTING CAT", "sitting cat");
    // actionService.create(
    //     "CA", "kneeling", "Kneeling Cat", "KNEELING CAT", "kneeling cat");
    // actionService.create(
    //     "CA", "standing", "Standing Cat", "STANDING CAT", "standing cat");
    // actionService.create("CA", "prone", "Swan", "SWAN", "swan");
    // actionService.create("CA", "prone", "Full Swan", "FULL SWAN", "full swan");
    // actionService.create(
    //     "CA", "sitting", "Push Through", "PUSH THROUGH", "push through");
    // actionService.create("CA", "sitting", "Mermaid", "MERMAID", "mermaid");
    // actionService.create(
    //     "CA", "supine", "Midback Series", "MIDBACK SERIES", "midback series");
    // actionService.create("CA", "sitting", "Back Rowing Series",
    //     "BACK ROWING SERIES", "back rowing series");
    // actionService.create("CA", "sitting", "Front Rowing Series",
    //     "FRONT ROWING SERIES", "front rowing series");
    // actionService.create("CA", "standing", "Chest Expansion", "CHEST EXPANSION",
    //     "chest expansion");
    // actionService.create("CA", "supine", "Leg Spring Series",
    //     "LEG SPRING SERIES", "leg spring series");
    // actionService.create("CA", "side lying", "Leg Spring Side Lying",
    //     "LEG SPRING SIDE LYING", "leg spring side lying");
    // actionService.create(
    //     "CA", "side lying", "Side Bend", "SIDE BEND", "side bend");
    // actionService.create(
    //     "CA", "standing", "Spread Eagle", "SPREAD EAGLE", "spread eagle");
    // actionService.create("CA", "standing", "Hanging Pull Ups",
    //     "HANGING PULL UPS", "hanging pull ups");
    // actionService.create("CA", "supine", "Push Thru With Feet",
    //     "PUSH THRU WITH FEET", "push thru with feet");
    // actionService.create("CA", "supine", "Tower", "TOWER", "tower");
    // actionService.create("CA", "supine", "Monkey", "MONKEY", "monkey");
    // actionService.create(
    //     "CA", "side lying", "Hip Opener", "HIP OPENER", "hip opener");
    // actionService.create("CA", "standing", "Squat", "SQUAT", "squat");
    // actionService.create(
    //     "CA", "supine", "Half Hanging", "HALF HANGING", "half hanging");
    // actionService.create(
    //     "CA", "supine", "Full Hanging", "FULL HANGING", "full hanging");
    // actionService.create("CA", "supine", "Leg Spring Series",
    //     "LEG SPRING SERIES", "leg spring series");
    // actionService.create("CA", "kneeling", "Kneeling Chest Expansion",
    //     "KNEELING CHEST EXPANSION", "kneeling chest expansion");
    // actionService.create(
    //     "CA", "kneeling", "Thigh Stretch", "THIGH STRETCH", "thigh stretch");
    // actionService.create("CH", "sitting", "Footwork Series", "FOOTWORK SERIES",
    //     "footwork series");
    // actionService.create("CH", "sitting", "Single Leg Press",
    //     "SINGLE LEG PRESS", "single leg press");
    // actionService.create(
    //     "CH", "standing", "Push Down", "PUSH DOWN", "push down");
    // actionService.create("CH", "standing", "Pull Up", "PULL UP", "pull up");
    // actionService.create("CH", "standing", "Standing Single Leg Press",
    //     "STANDING SINGLE LEG PRESS", "standing single leg press");
    // actionService.create("CH", "sitting", "Spine Stretch Forward",
    //     "SPINE STRETCH FORWARD", "spine stretch forward");
    // actionService.create("CH", "sitting", "Press Down Teaser",
    //     "PRESS DOWN TEASER", "press down teaser");
    // actionService.create(
    //     "CH", "standing", "Going Up Front", "GOING UP FRONT", "going up front");
    // actionService.create(
    //     "CH", "standing", "Knee Raises", "KNEE RAISES", "knee raises");
    // actionService.create("CH", "prone", "Scapula Isolation Prone",
    //     "SCAPULA ISOLATION PRONE", "scapula isolation prone");
    // actionService.create("CH", "prone", "One Arm Push Prone",
    //     "ONE ARM PUSH PRONE", "one arm push prone");
    // actionService.create("CH", "sitting", "Triceps Press Sitting",
    //     "TRICEPS PRESS SITTING", "triceps press sitting");
    // actionService.create("CH", "standing", "Push Down With One Arm",
    //     "PUSH DOWN WITH ONE ARM", "push down with one arm");
    // actionService.create("CH", "standing", "Arm Frog", "ARM FROG", "arm frog");
    // actionService.create("CH", "supine", "Roll Over", "ROLL OVER", "roll over");
    // actionService.create(
    //     "CH", "supine", "Jack Knife", "JACK KNIFE", "jack knife");
    // actionService.create("CH", "prone", "Swan Dive From Floor",
    //     "SWAN DIVE FROM FLOOR", "swan dive from floor");
    // actionService.create("CH", "prone", "Swan Dive", "SWAN DIVE", "swan dive");
    // actionService.create("CH", "sitting", "Mermaid", "MERMAID", "mermaid");
    // actionService.create("CH", "kneeling", "Mermaid Kneeling",
    //     "MERMAID KNEELING", "mermaid kneeling");
    // actionService.create(
    //     "CH", "sitting", "Horse Back", "HORSE BACK", "horse back");
    // actionService.create(
    //     "CH", "standing", "Mountain Climb", "MOUNTAIN CLIMB", "mountain climb");
    // actionService.create(
    //     "BA", "standing", "Ballet Stretch", "BALLET STRETCH", "ballet stretch");
    // actionService.create("BA", "standing", "Swedish Bar Stretch",
    //     "SWEDISH BAR STRETCH", "swedish bar stretch");
    // actionService.create(
    //     "BA", "sitting", "Horse Back", "HORSE BACK", "horse back");
    // actionService.create(
    //     "BA", "standing", "Side Bend", "SIDE BEND", "side bend");
    // actionService.create(
    //     "BA", "standing", "Side Sit Up", "SIDE SIT UP", "side sit up");
    // actionService.create("BA", "sitting", "Short Box Series",
    //     "SHORT BOX SERIES", "short box series");
    // actionService.create(
    //     "BA", "sitting", "Roll Down", "ROLL DOWN", "roll down");
    // actionService.create("BA", "prone", "Swan", "SWAN", "swan");
    // actionService.create("BA", "prone", "Swan Dive", "SWAN DIVE", "swan dive");
    // actionService.create("BA", "prone", "Prone Leg Series", "PRONE LEG SERIES",
    //     "prone leg series");
    // actionService.create(
    //     "BA", "side lying", "Side Leg Lift", "SIDE LEG LIFT", "side leg lift");
    // actionService.create("BA", "sitting", "Sitting Leg Series",
    //     "SITTING LEG SERIES", "sitting leg series");
    // actionService.create(
    //     "BA", "standing", "Lay Backs", "LAY BACKS", "lay backs");
    // actionService.create("BA", "standing", "Standing Roll Back",
    //     "STANDING ROLL BACK", "standing roll back");
    // actionService.create("BA", "side lying", "Side Lying Stretch",
    //     "SIDE LYING STRETCH", "side lying stretch");

    // actionService.create("MAT", "supine", "Ab Prep", "김주아");
    // actionService.create("MAT", "sitting", "Abs Series", "김주아");
    // actionService.create("RE", "supine", "Adductor Stretch", "김주아");
    // actionService.create("CA", "supine", "Airplane", "김주아");
    // actionService.create("RE", "kneeling", "Arm Circles", "김주아");
    // actionService.create("CH", "standing", "Arm Frog", "김주아");
    // actionService.create("CA", "sitting", "Back Rowing", "김주아");
    // actionService.create("RE", "sitting", "Back Rowing Prep", "김주아");
    // actionService.create("CA", "sitting", "Back Rowing Prep Series", "김주아");
    // actionService.create("RE", "sitting", "Balance Control Back", "김주아");
    // actionService.create("RE", "plank", "Balance Control Front", "김주아");
    // actionService.create("MAT", "sitting", "Balance Point", "김주아");
    // actionService.create("BA", "standing", "Ballet Stretch", "김주아");
    // actionService.create("RE", "supine", "Bend&Stretch", "김주아");
    // actionService.create("MAT", "sitting", "Boomerang", "김주아");
    // actionService.create("MAT", "prone", "Breast Stroke", "김주아");
    // actionService.create("MAT", "supine", "Breathing", "김주아");
    // actionService.create("CA", "supine", "Breathing", "김주아");
    // actionService.create("MAT", "quadruped", "Cat Stretch", "김주아");
    // actionService.create("RE", "kneeling", "Chest Expansion", "김주아");
    // actionService.create("MAT", "side lying", "Clam Shell", "김주아");
    // actionService.create("MAT", "supine", "Control Balance", "김주아");
    // actionService.create("RE", "supine", "Coordination", "김주아");
    // actionService.create("MAT", "supine", "Corkscrew", "김주아");
    // actionService.create("RE", "supine", "Corscrew", "김주아");
    // actionService.create("MAT", "sitting", "Crab", "김주아");
    // actionService.create("MAT", "supine", "Criss Cross", "김주아");
    // actionService.create("MAT", "prone", "Double Leg Kicks", "김주아");
    // actionService.create("MAT", "supine", "Double Leg Stretch", "김주아");
    // actionService.create("RE", "quadruped", "Down Stretch", "김주아");
    // actionService.create("RE", "standing", "Elephant", "김주아");
    // actionService.create("RE", "supine", "Footwork Series", "김주아");
    // actionService.create("CH", "sitting", "Footwork Series", "김주아");
    // actionService.create("RE", "supine", "Frog", "김주아");
    // actionService.create("MAT", "prone", "Frog Hip Extension", "김주아");
    // actionService.create("CA", "sitting", "Front Rowing", "김주아");
    // actionService.create("RE", "sitting", "Front Rowing Prep", "김주아");
    // actionService.create("CA", "sitting", "Front Rowing Prep Series", "김주아");
    // actionService.create("RE", "standing", "Front Split", "김주아");
    // actionService.create("CA", "supine", "Full Hanging", "김주아");
    // actionService.create("CA", "prone", "Full Swan", "김주아");
    // actionService.create("CH", "standing", "Going Up Front", "김주아");
    // actionService.create("CH", "standing", "Going Up Side", "김주아");
    // actionService.create("CA", "supine", "Half Hanging", "김주아");
    // actionService.create("MAT", "sitting", "Half Roll Back", "김주아");
    // actionService.create("MAT", "prone", "Half Swan", "김주아");
    // actionService.create("CH", "supine", "Hams Press Hips Down", "김주아");
    // actionService.create("CH", "supine", "Hams Press Hips Up", "김주아");
    // actionService.create("CA", "standing", "Hanging Pull Ups", "김주아");
    // actionService.create("MAT", "supine", "High Bicycle", "김주아");
    // actionService.create("MAT", "supine", "High Scissors", "김주아");
    // actionService.create("MAT", "sitting", "Hip Circles", "김주아");
    // actionService.create("CA", "side lying", "Hip Opener", "김주아");
    // actionService.create("MAT", "supine", "Hip Release", "김주아");
    // actionService.create("MAT", "supine", "Hip Roll", "김주아");
    // actionService.create("CH", "sitting", "Horse Back", "김주아");
    // actionService.create("BA", "sitting", "Horse Back", "김주아");
    // actionService.create("MAT", "supine", "Hundred", "김주아");
    // actionService.create("RE", "supine", "Hundred", "김주아");
    // actionService.create("MAT", "supine", "Imprinting Transition", "김주아");
    // actionService.create("MAT", "supine", "Jack Knife", "김주아");
    // actionService.create("CH", "supine", "Jack Knife", "김주아");
    // actionService.create("CH", "standing", "Knee Raise Series", "김주아");
    // actionService.create("RE", "quadruped", "Knee Stretch Arches", "김주아");
    // actionService.create("RE", "quadruped", "Knee Stretch Knees Off", "김주아");
    // actionService.create("RE", "quadruped", "Knee Stretch Round", "김주아");
    // actionService.create("RE", "quadruped", "Knee Stretch Series", "김주아");
    // actionService.create("CA", "kneeling", "Kneeling Ballet Stretches", "김주아");
    // actionService.create("CA", "kneeling", "Kneeling Cat", "김주아");
    // actionService.create("CA", "kneeling", "Kneeling Chest Expansion", "김주아");
    // actionService.create("CH", "kneeling", "Kneeling Mermaid", "김주아");
    // actionService.create("MAT", "kneeling", "Kneeling Side Kick", "김주아");
    // actionService.create("CH", "kneeling", "Kneeling Side Kicks", "김주아");
    // actionService.create("BA", "standing", "Lay Backs", "김주아");
    // actionService.create("RE", "supine", "Leg Circles", "김주아");
    // actionService.create("MAT", "plank", "Leg Pull Back", "김주아");
    // actionService.create("MAT", "plank", "Leg Pull Front", "김주아");
    // actionService.create("CA", "supine", "Leg Spring Series", "김주아");
    // actionService.create(
    //     "CA", "side lying", "Leg Spring Side Kick Series", "김주아");
    // actionService.create("RE", "supine", "Leg Strap Series", "김주아");
    // actionService.create("RE", "sitting", "Long Back Stretch", "김주아");
    // actionService.create("RE", "prone", "Long Box Backstroke", "김주아");
    // actionService.create("RE", "prone", "Long Box Horse Back", "김주아");
    // actionService.create("RE", "prone", "Long Box Pulling Straps", "김주아");
    // actionService.create("RE", "prone", "Long Box Series", "김주아");
    // actionService.create("RE", "prone", "Long Box T Shape", "김주아");
    // actionService.create("RE", "prone", "Long Box Teaser", "김주아");
    // actionService.create("RE", "supine", "Long Spine Massage", "김주아");
    // actionService.create("RE", "plank", "Long Stretch", "김주아");
    // actionService.create("RE", "plank", "Long Stretch Series", "김주아");
    // actionService.create("MAT", "supine", "Lower And Lift", "김주아");
    // actionService.create("RE", "supine", "Lower And Lift", "김주아");
    // actionService.create("CH", "standing", "Lunge", "김주아");
    // actionService.create("MAT", "sitting", "Mermaid", "김주아");
    // actionService.create("CA", "sitting", "Mermaid", "김주아");
    // actionService.create("CH", "sitting", "Mermaid", "김주아");
    // actionService.create("CA", "supine", "Midback Series", "김주아");
    // actionService.create("CA", "supine", "Monkey", "김주아");
    // actionService.create("CH", "standing", "Mountain Climb", "김주아");
    // actionService.create("MAT", "sitting", "Neck Pull", "김주아");
    // actionService.create("CH", "prone", "One Arm Press", "김주아");
    // actionService.create("MAT", "sitting", "Open Leg Rocker", "김주아");
    // actionService.create("RE", "supine", "Overhead", "김주아");
    // actionService.create("CA", "supine", "Parakeet", "김주아");
    // actionService.create("RE", "supine", "Pelvic Lift", "김주아");
    // actionService.create("MAT", "supine", "Pelvic Movement", "김주아");
    // actionService.create("CA", "sitting", "Port De Bras", "김주아");
    // actionService.create("CH", "sitting", "Press Down Teaser", "김주아");
    // actionService.create("MAT", "prone", "Prone Heel Squeeze", "김주아");
    // actionService.create("MAT", "prone", "Prone Leg Lift Series", "김주아");
    // actionService.create("BA", "prone", "Prone Leg Lift Series", "김주아");
    // actionService.create("CH", "standing", "Pull Up", "김주아");
    // actionService.create("CH", "standing", "Push Down", "김주아");
    // actionService.create("CH", "standing", "Push Down With One Arm", "김주아");
    // actionService.create("CA", "sitting", "Push Through", "김주아");
    // actionService.create("CA", "supine", "Push Thru With Feet", "김주아");
    // actionService.create("MAT", "plank", "Push Ups", "김주아");
    // actionService.create("MAT", "prone", "Rocking", "김주아");
    // actionService.create("CA", "sitting", "Roll Back Bar", "김주아");
    // actionService.create("CA", "sitting", "Roll Back With One Arm", "김주아");
    // actionService.create("CA", "sitting", "Roll Down", "김주아");
    // actionService.create("BA", "sitting", "Roll Down Round", "김주아");
    // actionService.create("BA", "sitting", "Roll Down Straight", "김주아");
    // actionService.create("MAT", "supine", "Roll Over", "김주아");
    // actionService.create("CH", "supine", "Roll Over", "김주아");
    // actionService.create("CA", "supine", "Roll Up", "김주아");
    // actionService.create("MAT", "sitting", "Rolling Like A Ball", "김주아");
    // actionService.create("RE", "sitting", "Rowing 90 Degrees", "김주아");
    // actionService.create("RE", "sitting", "Rowing From The Chest", "김주아");
    // actionService.create("RE", "sitting", "Rowing From The Hips", "김주아");
    // actionService.create("RE", "sitting", "Rowing Hug The Tree", "김주아");
    // actionService.create("RE", "sitting", "Rowing Into The Sternum", "김주아");
    // actionService.create("RE", "sitting", "Rowing Salute", "김주아");
    // actionService.create("RE", "sitting", "Rowing Series", "김주아");
    // actionService.create("RE", "sitting", "Rowing Shave", "김주아");
    // actionService.create("RE", "supine", "Running", "김주아");
    // actionService.create("RE", "standing", "Russian Split", "김주아");
    // actionService.create("MAT", "sitting", "Saw", "김주아");
    // actionService.create("CH", "prone", "Scapula Isolation", "김주아");
    // actionService.create("MAT", "supine", "Scapula Movement", "김주아");
    // actionService.create("MAT", "supine", "Scissors", "김주아");
    // actionService.create("MAT", "sitting", "Seal", "김주아");
    // actionService.create("RE", "supine", "Semi-Circle", "김주아");
    // actionService.create("RE", "sitting", "Short Box Round", "김주아");
    // actionService.create("RE", "sitting", "Short Box Series", "김주아");
    // actionService.create("BA", "sitting", "Short Box Series", "김주아");
    // actionService.create("RE", "sitting", "Short Box Side", "김주아");
    // actionService.create("RE", "sitting", "Short Box Straight", "김주아");
    // actionService.create("RE", "sitting", "Short Box Tree", "김주아");
    // actionService.create("RE", "sitting", "Short Box Twist", "김주아");
    // actionService.create("RE", "sitting", "Short Box Twist And Reach", "김주아");
    // actionService.create("RE", "supine", "Short Spine Massage", "김주아");
    // actionService.create("CA", "supine", "Shoulder And Chest Opener", "김주아");
    // actionService.create("MAT", "supine", "Shoulder Bridge", "김주아");
    // actionService.create("CA", "sitting", "Side Arm Sitting", "김주아");
    // actionService.create("MAT", "sitting", "Side Bend", "김주아");
    // actionService.create("CA", "side lying", "Side Bend", "김주아");
    // actionService.create("BA", "standing", "Side Bend", "김주아");
    // actionService.create("MAT", "supine", "Side Kick Beats", "김주아");
    // actionService.create("MAT", "side lying", "Side Kick Bicycle", "김주아");
    // actionService.create("MAT", "side lying", "Side Kick Big Circles", "김주아");
    // actionService.create("MAT", "side lying", "Side Kick Big Scissors", "김주아");
    // actionService.create("MAT", "side lying", "Side Kick Developpe", "김주아");
    // actionService.create("MAT", "side lying", "Side Kick Front Back", "김주아");
    // actionService.create("MAT", "side lying", "Side Kick Hot Potato", "김주아");
    // actionService.create("MAT", "side lying", "Side Kick Inner Thigh", "김주아");
    // actionService.create("MAT", "side lying", "Side Kick Series", "김주아");
    // actionService.create("MAT", "side lying", "Side Kick Small Circles", "김주아");
    // actionService.create("MAT", "side lying", "Side Kick Up Down", "김주아");
    // actionService.create("BA", "side lying", "Side Leg Lift", "김주아");
    // actionService.create("BA", "side lying", "Side Lying Stretch", "김주아");
    // actionService.create("BA", "standing", "Side Sit Up", "김주아");
    // actionService.create("RE", "standing", "Side Split", "김주아");
    // actionService.create("MAT", "supine", "Single Leg Circles", "김주아");
    // actionService.create("MAT", "prone", "Single Leg Kicks", "김주아");
    // actionService.create("CH", "sitting", "Single Leg Press", "김주아");
    // actionService.create("MAT", "supine", "Single Leg Stretch", "김주아");
    // actionService.create("CH", "sitting", "Sitthing Triceps Press", "김주아");
    // actionService.create("CA", "sitting", "Sitting Cat", "김주아");
    // actionService.create("BA", "sitting", "Sitting Leg Series", "김주아");
    // actionService.create("RE", "standing", "Snake", "김주아");
    // actionService.create("MAT", "sitting", "Spine Stretch Forward", "김주아");
    // actionService.create("CH", "sitting", "Spine Stretch Forward", "김주아");
    // actionService.create("MAT", "sitting", "Spine Twist", "김주아");
    // actionService.create("CA", "standing", "Spread Eagle", "김주아");
    // actionService.create("CA", "standing", "Squat", "김주아");
    // actionService.create("CA", "standing", "Standing Ballet Stretches", "김주아");
    // actionService.create("CA", "standing", "Standing Cat", "김주아");
    // actionService.create("CA", "standing", "Standing Chest Expansion", "김주아");
    // actionService.create("BA", "standing", "Standing Roll Back", "김주아");
    // actionService.create("CH", "standing", "Standing Roll Down", "김주아");
    // actionService.create("BA", "standing", "Standing Side Leg Lift", "김주아");
    // actionService.create("CH", "standing", "Standing Single Leg Press", "김주아");
    // actionService.create("CA", "standing", "Standing Spred Eagle", "김주아");
    // actionService.create("RE", "sitting", "Stomach Massage Reach Up", "김주아");
    // actionService.create("RE", "sitting", "Stomach Massage Round", "김주아");
    // actionService.create("RE", "sitting", "Stomach Massage Series", "김주아");
    // actionService.create("RE", "sitting", "Stomach Massage Straight", "김주아");
    // actionService.create("RE", "sitting", "Stomach Massage Twist", "김주아");
    // actionService.create("MAT", "prone", "Swan", "김주아");
    // actionService.create("RE", "prone", "Swan", "김주아");
    // actionService.create("CA", "prone", "Swan", "김주아");
    // actionService.create("BA", "prone", "Swan", "김주아");
    // actionService.create("MAT", "prone", "Swan Dive", "김주아");
    // actionService.create("CH", "prone", "Swan Dive", "김주아");
    // actionService.create("BA", "prone", "Swan Dive", "김주아");
    // actionService.create("CH", "prone", "Swan Dive From Floor", "김주아");
    // actionService.create("BA", "standing", "Swedish Bar Stretch", "김주아");
    // actionService.create("MAT", "prone", "Swimming", "김주아");
    // actionService.create("MAT", "supine", "Teaser", "김주아");
    // actionService.create("CA", "supine", "Teaser", "김주아");
    // actionService.create("RE", "standing", "Tendon Stretch", "김주아");
    // actionService.create("CH", "standing", "Tendon Stretch", "김주아");
    // actionService.create("MAT", "supine", "The Hundred", "김주아");
    // actionService.create("MAT", "supine", "The Roll Up", "김주아");
    // actionService.create("MAT", "kneeling", "Thigh Stretch", "김주아");
    // actionService.create("RE", "kneeling", "Thigh Stretch", "김주아");
    // actionService.create("CA", "kneeling", "Thigh Stretch", "김주아");
    // actionService.create("MAT", "supine", "Toe Tap", "김주아");
    // actionService.create("CA", "supine", "Tower", "김주아");
    // actionService.create("CH", "prone", "Triceps", "김주아");
    // actionService.create("RE", "standing", "Twist", "김주아");
    // actionService.create("RE", "standing", "Up Stretch", "김주아");
    // actionService.create("CA", "supine", "Upper Abs Curl", "김주아");
  }
}
