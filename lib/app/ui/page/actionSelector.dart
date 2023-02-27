import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/app/ui/widget/actionListTileWidget.dart';
import 'package:web_project/app/data/model/lessonInfo.dart';
import 'package:web_project/app/data/provider/action_service.dart';
import 'package:web_project/app/data/provider/lesson_service.dart';
import 'package:web_project/app/ui/page/importSequenceFromSaved.dart';
import 'package:web_project/app/ui/widget/buttonWidget.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/main.dart';

import 'actionAdd.dart';
import '../../data/model/actionInfo.dart';
import '../../../backup/lessonAdd.dart';
import '../../data/provider/auth_service.dart';
import '../../function/globalFunction.dart';
import '../widget/globalWidget.dart';
import 'package:web_project/app/data/model/userInfo.dart'
    as CustomUserInfo; // 다른 페키지와 클래스 명이 겹치는 경우 alias 선언해서 사용

// tmpLessonInfoList 값 반영하여 FilterChips 동적 생성
var actionChips = [];

bool isReformerSelected = false;
bool isCadillacSelected = false;
bool isChairSelected = false;
bool isLadderBarrelSelected = false;
bool isSpringBoardSelected = false;
bool isSpineCorrectorSelected = false;
bool isMatSelected = false;
bool isOthersApparatusSelected = false;

bool isSupineSelected = false;
bool isSittingSelected = false;
bool isProneSelected = false;
bool isKneelingSelected = false;
bool isSideLyingSelected = false;
bool isStandingSelected = false;
bool isPlankSelected = false;
bool isQuadrupedSelected = false;
bool isOthersPositionSelected = false;

String searchString = "";

List positionArray = [];
List apparatusArray = [];

int positionFilteredSize = 0;

GlobalFunction globalFunction = GlobalFunction();

bool initStateVar = true;

bool isFullScreen = false;

TextEditingController searchController = TextEditingController();

FocusNode searchFocusNode = FocusNode();

ScrollController scrollController = ScrollController();

late bool isFloating;
late int selectedActionCount = -1;

late Color actionTileColor;
late Color apparatusTextColor;
late Color actionNameTextColor;
late List<LessonInfo> lessonInfoList;
late List<TmpLessonInfo> tmpLessonInfoList;
late List<int> checkedTileList;

late List<TmpLessonInfo> unEditedTmpLessonInfo;

// List globalVariables.actionList = [];
List searchedList = [];

// 세로 자음 검색 바 구현
List combinedLngs = [];

String currentChar = "";

// 알파벳 자모음 생성
final alphabets = List.generate(26, (index) => String.fromCharCode(index + 65));
final koreans = [
  "ㄱ",
  "ㄴ",
  "ㄷ",
  "ㄹ",
  "ㅁ",
  "ㅂ",
  "ㅅ",
  "ㅇ",
  "ㅈ",
  "ㅊ",
  "ㅋ",
  "ㅌ",
  "ㅍ",
  "ㅎ",
  /* "ㄲ",
    "ㄸ",
    "ㅃ",
    "ㅆ",
    "ㅉ", */
];

List rmNameList = [];

int _searchIndex = 0;

class ActionSelector extends StatefulWidget {
  const ActionSelector({super.key});

  @override
  State<ActionSelector> createState() => _ActionSelectorState();
}

class _ActionSelectorState extends State<ActionSelector> {
  // 모음 검색 세로 바 구현 작업
  // https://github.com/thanikad/alphabetical_search
  Future<void> setSearchIndex(String searchLetter) async {
    print("searchLetter : ${searchLetter}");
    /* rmNameList.forEach((element) { 
      print("element : ${element}");
    }); */
    // setState(() {
    _searchIndex = rmNameList.indexWhere(
        (element) => element.toString().startsWith(searchLetter.toLowerCase()));
    print("_searchIndex.toDouble() : ${_searchIndex.toDouble()}");
    double contentHeight = MediaQuery.of(context).size.height > 700
        ? MediaQuery.of(context).size.height * 0.89
        : MediaQuery.of(context).size.height * 0.85;
    print("contentHeight : ${contentHeight}");
    if (_searchIndex >= 0 && scrollController.hasClients) {
      await scrollController
          .animateTo(_searchIndex.toDouble(),
              duration: Duration(milliseconds: 1), curve: Curves.ease)
          .then((value) {
        print("value : ");
      }).whenComplete(() {
        print("complete : ");
      });
      /* SchedulerBinding.instance.addPersistentFrameCallback(
        (timeStamp) async {
          await scrollController.animateTo(
              _searchIndex.toDouble(),
              duration: Duration(milliseconds: 1),
              curve: Curves.ease)/* .then((value){
                print("value : ");
              }).whenComplete((){
                print("complete : ");
              }) */;
        },
      ); */
      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /* print(
          "scrollController.position.maxScrollExtent : ${scrollController.position.maxScrollExtent}");
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 1),
          curve: Curves
              .ease); /* .then((value){
                print("value : ");
              }).whenComplete((){
                print("complete : ");
              }) */
      // scrollController.jumpTo(contentHeight);
      print("WidgetsBinding : ");
      // },);
      print("after jumpTo!!"); */
    }
    // });
  }

  @override
  void initState() {
    isFloating = false;
    selectedActionCount = 0;
    apparatusTextColor = Palette.gray99;
    actionNameTextColor = Palette.gray66;
    actionTileColor = Palette.mainBackground;
    lessonInfoList = [];
    tmpLessonInfoList = [];
    checkedTileList = [];

    combinedLngs.addAll(koreans);
    combinedLngs.addAll(alphabets);

    scrollController.addListener(() {
      print("scrollController.offset : ${scrollController.offset}");
    });
    super.initState();

    actionChips = [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // 화면 나갈때  chip 변수 초기화
    isReformerSelected = false;
    isCadillacSelected = false;
    isChairSelected = false;
    isLadderBarrelSelected = false;
    isSpringBoardSelected = false;
    isSpineCorrectorSelected = false;
    isMatSelected = false;
    isOthersApparatusSelected = false;

    isSupineSelected = false;
    isSittingSelected = false;
    isProneSelected = false;
    isKneelingSelected = false;
    isSideLyingSelected = false;
    isStandingSelected = false;
    isPlankSelected = false;
    isQuadrupedSelected = false;
    isOthersPositionSelected = false;

    positionArray = [];
    apparatusArray = [];
    initStateVar = !initStateVar;

    searchString = "";

    isFloating = false;
    selectedActionCount = 0;
    actionTileColor = Palette.mainBackground;
    lessonInfoList = [];
    tmpLessonInfoList = [];
    checkedTileList = [];

    searchController.clear();

    combinedLngs.clear();
    rmNameList.clear();
    super.dispose();

    actionChips = [];
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser()!;

    //레슨서비스 활용
    final lessonService = context.read<LessonService>();

    // 이전 화면에서 보낸 변수 받기
    final List<dynamic> args =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    final CustomUserInfo.UserInfo customUserInfo = args[0];
    final String currentApparatus = args[1];
    final String lessonDate = args[2];

    // initState = args[3];
    final String totalNote = args[4];
    tmpLessonInfoList = args[5];
    // globalVariables.actionList = args[6];

    if (rmNameList.isEmpty) {
      rmNameList = [];
      globalVariables.actionList.forEach(
        (element) {
          rmNameList.add(globalFunction.getChosungFromString(element['name']));
        },
      );
    }

    /* setState(() {
      selectedActionCount = tmpLessonInfoList.length;
    }); */
    if (tmpLessonInfoList.isNotEmpty) {
      selectedActionCount = tmpLessonInfoList.length;
      isFloating = true;
    }

    List docs = globalVariables.actionList;
    if (searchString.isNotEmpty) {
      print("searchString.isNotEmpty : ${searchString}");
      List searchedList = [];
      String varName = "";

      globalVariables.actionList.forEach((element) {
        varName = element['name'];
        // 검색 기능 함수 convert
        if (globalFunction.searchString(varName, searchString, "action")) {
          searchedList.add(element);
        }
      });
      docs = searchedList; // 문서들 가져오기
    } else {
      docs = globalVariables.actionList; // 문서들 가져오기
    }

    print(globalVariables.actionList);

    print("[AS] 시작 tmpLessonInfoList : ${tmpLessonInfoList.length}");

    if (initStateVar) {
      switch (currentApparatus) {
        case "REFORMER":
          isReformerSelected = true;
          initStateVar = !initStateVar;
          break;
        case "CADILLAC":
          isCadillacSelected = true;
          initStateVar = !initStateVar;
          ;
          break;
        case "CHAIR":
          isChairSelected = true;
          initStateVar = !initStateVar;
          ;
          break;
        case "LADDER BARREL":
          isLadderBarrelSelected = true;
          initStateVar = !initStateVar;
          ;
          break;
        case "SPRING BOARD":
          isSpringBoardSelected = true;
          initStateVar = !initStateVar;
          ;
          break;
        case "SPINE CORRECTOR":
          isSpineCorrectorSelected = true;
          initStateVar = !initStateVar;
          ;
          break;
        case "MAT":
          isMatSelected = true;
          initStateVar = !initStateVar;
          ;
          break;
        case "OTHERS":
          isOthersApparatusSelected = true;
          initStateVar = !initStateVar;
          break;
      }
    }

    if (tmpLessonInfoList.isNotEmpty) {
      actionChips = tmpLessonInfoList
          .map((e) => FilterChip(
                padding: EdgeInsets.only(bottom: 3),
                label: Row(
                  children: [
                    Text(e.actionName),
                    Icon(
                      Icons.close_outlined,
                      size: 14,
                      color: e.isSelected ? Palette.grayFF : Palette.gray99,
                    )
                  ],
                ),
                onSelected: ((value) {
                  setState(() {
                    e.isSelected = !e.isSelected;
                    TmpLessonInfo tmpLessonInfo = TmpLessonInfo(
                        e.memberdocId,
                        e.apparatusName,
                        e.actionName,
                        e.name,
                        e.lessonDate,
                        e.grade,
                        e.totalNote,
                        e.docId,
                        e.uid,
                        e.isSelected);

                    manageListContaining(
                        tmpLessonInfoList, tmpLessonInfo, true);

                    print(
                        "YES contain!! remove item => ${e.uid}/${e.memberdocId}/${e.lessonDate}/widget.apparatus : ${e.apparatusName}, widget.actionName : ${e.actionName}");
                    lessonService.deleteFromActionSelect(e.uid, e.memberdocId,
                        e.lessonDate, e.apparatusName, e.actionName);
                  });
                }),
                selected: e.isSelected,
                labelStyle: TextStyle(
                    fontSize: 12,
                    color: e.isSelected ? Palette.grayFF : Palette.gray99),
                selectedColor: Palette.buttonOrange,
                backgroundColor: Colors.transparent,
                showCheckmark: false,
                side: e.isSelected
                    ? BorderSide.none
                    : BorderSide(color: Palette.grayB4),
              ))
          .toList();
    }

    print("positionFilteredSize : ${positionFilteredSize}");
    positionFilteredSize = 0;

    final apparatusChips = [
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isMatSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side:
            isMatSelected ? BorderSide.none : BorderSide(color: Palette.grayB4),
        label: Text("MAT"),
        selected: isMatSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isMatSelected = !isMatSelected;
              print("isMatSelected : ${isMatSelected}");
              if (isMatSelected) {
                apparatusArray.add("MAT");
              } else {
                apparatusArray.remove("MAT");
              }
              print("apparatusArray : ${apparatusArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isReformerSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isReformerSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("REFORMER"),
        selected: isReformerSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isReformerSelected = !isReformerSelected;
              print("isReformerSelected : ${isReformerSelected}");
              if (isReformerSelected) {
                apparatusArray.add("RE");
              } else {
                apparatusArray.remove("RE");
              }
              print("apparatusArray : ${apparatusArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isCadillacSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isCadillacSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("CADILLAC"),
        selected: isCadillacSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isCadillacSelected = !isCadillacSelected;
              print(
                  "isSupineisCadillacSelectedSelected : ${isCadillacSelected}");
              if (isCadillacSelected) {
                apparatusArray.add("CA");
              } else {
                apparatusArray.remove("CA");
              }
              print("apparatusArray : ${apparatusArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isChairSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isChairSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("CHAIR"),
        selected: isChairSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isChairSelected = !isChairSelected;
              print("isChairSelected : ${isChairSelected}");
              if (isChairSelected) {
                apparatusArray.add("CH");
              } else {
                apparatusArray.remove("CH");
              }
              print("apparatusArray : ${apparatusArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isLadderBarrelSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isLadderBarrelSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("LADDER BARREL"),
        selected: isLadderBarrelSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isLadderBarrelSelected = !isLadderBarrelSelected;
              print("isLadderBarrelSelected : ${isLadderBarrelSelected}");
              if (isLadderBarrelSelected) {
                apparatusArray.add("BA");
              } else {
                apparatusArray.remove("BA");
              }
              print("apparatusArray : ${apparatusArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isSpringBoardSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isSpringBoardSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("SPRING BOARD"),
        selected: isSpringBoardSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isSpringBoardSelected = !isSpringBoardSelected;
              print("isSpringBoardSelected : ${isSpringBoardSelected}");
              if (isSpringBoardSelected) {
                apparatusArray.add("SB");
              } else {
                apparatusArray.remove("SB");
              }
              print("apparatusArray : ${apparatusArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isSpineCorrectorSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isSpineCorrectorSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("SPINE CORRECTOR"),
        selected: isSpineCorrectorSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isSpineCorrectorSelected = !isSpineCorrectorSelected;
              print("isSpineCorrectorSelected : ${isSpineCorrectorSelected}");
              if (isSpineCorrectorSelected) {
                apparatusArray.add("SC");
              } else {
                apparatusArray.remove("SC");
              }
              print("apparatusArray : ${apparatusArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isOthersApparatusSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isOthersApparatusSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("OTHERS"),
        selected: isOthersApparatusSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isOthersApparatusSelected = !isOthersApparatusSelected;
              print(
                  "isOthersApparatusSelectedSelected : ${isOthersApparatusSelected}");
              if (isOthersApparatusSelected) {
                apparatusArray.add("OT");
              } else {
                apparatusArray.remove("OT");
              }
              print("apparatusArray : ${apparatusArray}");
            },
          );
        },
      ),
    ];

    final positionChips = [
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isSupineSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isSupineSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("SUPINE"),
        selected: isSupineSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isSupineSelected = !isSupineSelected;
              if (isSupineSelected) {
                positionArray.add("supine");
              } else {
                positionArray.remove("supine");
              }
              print("isSupineSelected : ${isSupineSelected}");
              print("positionArray : ${positionArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isProneSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isProneSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("PRONE"),
        selected: isProneSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isProneSelected = !isProneSelected;
              if (isProneSelected) {
                positionArray.add("prone");
              } else {
                positionArray.remove("prone");
              }
              print("isProneSelected : ${isProneSelected}");
              print("positionArray : ${positionArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isSittingSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isSittingSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("SITTING"),
        selected: isSittingSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isSittingSelected = !isSittingSelected;
              if (isSittingSelected) {
                positionArray.add("sitting");
              } else {
                positionArray.remove("sitting");
              }
              print("isSittingSelected : ${isSittingSelected}");
              print("positionArray : ${positionArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isStandingSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isStandingSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("STANDING"),
        selected: isStandingSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isStandingSelected = !isStandingSelected;
              if (isStandingSelected) {
                positionArray.add("standing");
              } else {
                positionArray.remove("standing");
              }
              print("isStandingSelected : ${isStandingSelected}");
              print("positionArray : ${positionArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isKneelingSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isKneelingSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("KNEELING"),
        selected: isKneelingSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isKneelingSelected = !isKneelingSelected;
              if (isKneelingSelected) {
                positionArray.add("kneeling");
              } else {
                positionArray.remove("kneeling");
              }
              print("isKneelingSelected : ${isKneelingSelected}");
              print("positionArray : ${positionArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isSideLyingSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isSideLyingSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("SIDE LYING"),
        selected: isSideLyingSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isSideLyingSelected = !isSideLyingSelected;
              if (isSideLyingSelected) {
                positionArray.add("side lying");
              } else {
                positionArray.remove("side lying");
              }
              print("isSideLyingSelected : ${isSideLyingSelected}");
              print("positionArray : ${positionArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isQuadrupedSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isQuadrupedSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("QUADRUPED"),
        selected: isQuadrupedSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isQuadrupedSelected = !isQuadrupedSelected;
              if (isQuadrupedSelected) {
                positionArray.add("quadruped");
              } else {
                positionArray.remove("quadruped");
              }
              print("isStandingSelected : ${isPlankSelected}");
              print("positionArray : ${positionArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isPlankSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isPlankSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("PLANK"),
        selected: isPlankSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isPlankSelected = !isPlankSelected;
              if (isPlankSelected) {
                positionArray.add("plank");
              } else {
                positionArray.remove("plank");
              }
              print("isStandingSelected : ${isPlankSelected}");
              print("positionArray : ${positionArray}");
            },
          );
        },
      ),
      FilterChip(
        padding: EdgeInsets.only(bottom: 3),
        labelStyle: TextStyle(
            fontSize: 12,
            color: isOthersPositionSelected ? Palette.grayFF : Palette.gray99),
        selectedColor: Palette.buttonOrange,
        backgroundColor: Colors.transparent,
        side: isOthersPositionSelected
            ? BorderSide.none
            : BorderSide(color: Palette.grayB4),
        label: Text("OTHERS"),
        selected: isOthersPositionSelected,
        showCheckmark: false,
        onSelected: (value) {
          setState(
            () {
              isOthersPositionSelected = !isOthersPositionSelected;
              if (isOthersPositionSelected) {
                positionArray.add("others");
              } else {
                positionArray.remove("others");
              }
              print("isOthersPositionSelected : ${isOthersPositionSelected}");
              print("positionArray : ${positionArray}");
            },
          );
        },
      ),
    ];

    return MediaQuery.removePadding(
      context: context,
      removeTop: false,
      removeBottom: true,
      child: Consumer<ActionService>(builder: (context, actionService, child) {
        // if (tmpLessonInfoList.isNotEmpty) {
        //   selectedActionCount = tmpLessonInfoList.length;
        //   print(
        //       "selectedActionCount : ${selectedActionCount}, tmpLessonInfoList.length : ${tmpLessonInfoList.length}");
        // }
        return Scaffold(
          backgroundColor: Palette.secondaryBackground,
          appBar: BaseAppBarMethod(context, "동작선택", () {
            // 화면 나갈때  chip 변수 초기화
            isReformerSelected = false;
            isCadillacSelected = false;
            isChairSelected = false;
            isLadderBarrelSelected = false;
            isSpringBoardSelected = false;
            isSpineCorrectorSelected = false;
            isMatSelected = false;
            isOthersApparatusSelected = false;

            isSupineSelected = false;
            isSittingSelected = false;
            isProneSelected = false;
            isKneelingSelected = false;
            isSideLyingSelected = false;
            isStandingSelected = false;
            isPlankSelected = false;
            isQuadrupedSelected = false;
            isOthersPositionSelected = false;

            initStateVar = !initStateVar;
            positionArray = [];

            searchString = "";
            Navigator.pop(context);
          }, [
            IconButton(
                onPressed: () {
                  isFullScreen = !isFullScreen;
                  setState(() {});
                },
                icon: Icon(Icons.open_in_full))
          ], null),
          body: CenterConstrainedBody(
            child: SafeArea(
              child: Stack(
                children: [
                  /// 동작 리스트
                  ListView.builder(
                    padding: EdgeInsets.only(
                        top: isFullScreen
                            ? 0
                            : searchString.isEmpty
                                ? 190
                                : 60),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      // print("doc : ${doc}");
                      String apparatus = doc['apparatus'];
                      String otherApparatusName = doc['otherApparatusName'];
                      String position = doc['position'];
                      String name = doc['name'];
                      String lowerCaseName = doc['lowerCaseName'];
                      bool isSelected = doc['actionSelected'];
                      /* print(
                          '#####TempLEssonList: ${tmpLessonInfoList[1].toString()}');
                      inspect(tmpLessonInfoList[1]); */

                      // if (tmpLessonInfoList.any(
                      //     (element) => element['actionName'] == doc['name'])) {
                      //   isSelected = true;
                      // } else {
                      //   isSelected = doc['actionSelected'];
                      // }

                      List<dynamic> nGramizedLowerCaseName =
                          doc['nGramizedLowerCaseName'] ?? [];

                      final ActionInfo actionInfo = ActionInfo(
                        name,
                        apparatus,
                        position,
                      );
                      State<ActionSelector>? actionSelector =
                          context.findAncestorStateOfType();
                      TmpLessonInfo tmpLessonInfo = TmpLessonInfo(
                          customUserInfo.docId,
                          apparatus,
                          name,
                          customUserInfo.name,
                          lessonDate,
                          "50",
                          totalNote,
                          '',
                          user.uid,
                          true);
                      //레슨서비스 활용
                      final lessonService = context.read<LessonService>();
                      // onTap 방식과는 다르게 동작해야 함

                      if (manageListContaining(
                          tmpLessonInfoList, tmpLessonInfo, false)) {
                        isSelected = true;
                        /* print(
            "YES contain!! => widget.apparatus : ${widget.apparatus}, widget.actionName : ${widget.actionName}"); */
                      } else {
                        isSelected = false;
                        /* print(
            "NOT contain!! => widget.apparatus : ${widget.apparatus}, widget.actionName : ${widget.actionName}"); */
                      }

                      if (searchString.isEmpty) {
                        if (positionArray.isEmpty) {
                          if (apparatusArray.isEmpty) {
                            return ActionListTile(
                                actionName: name,
                                apparatus: apparatus,
                                position: position,
                                name: customUserInfo.name,
                                phoneNumber: customUserInfo.phoneNumber,
                                lessonDate: lessonDate,
                                grade: '50',
                                totalNote: totalNote,
                                docId: customUserInfo.docId,
                                memberdocId: customUserInfo.docId,
                                uid: user.uid,
                                pos: index,
                                isSelected: isSelected,
                                isSelectable: true,
                                isDraggable: false,
                                customFunctionOnTap: () {
                                  doc['actionSelected'] =
                                      !doc['actionSelected'];

                                  print(
                                      'docs[index][selected]: ${docs[index]['actionSelected']}');
                                  setState(() {});
                                });

                            // return ActionTile(
                            //     memberdocId: customUserInfo.docId,
                            //     apparatus: apparatus,
                            //     actionName: name,
                            //     name: customUserInfo.name,
                            //     phoneNumber: "temp",
                            //     lessonDate: lessonDate,
                            //     grade: "50",
                            //     totalNote: totalNote,
                            //     docId: "",
                            //     uid: user.uid,
                            //     pos: index);
                          } else {
                            if (apparatusArray.contains(apparatus)) {
                              return ActionListTile(
                                  actionName: name,
                                  apparatus: apparatus,
                                  position: position,
                                  name: customUserInfo.name,
                                  phoneNumber: customUserInfo.phoneNumber,
                                  lessonDate: lessonDate,
                                  grade: '50',
                                  totalNote: totalNote,
                                  docId: customUserInfo.docId,
                                  memberdocId: customUserInfo.docId,
                                  uid: user.uid,
                                  pos: index,
                                  isSelected: isSelected,
                                  isSelectable: true,
                                  isDraggable: false,
                                  customFunctionOnTap: () {
                                    doc['actionSelected'] =
                                        !doc['actionSelected'];

                                    print(
                                        'docs[index][selected]: ${docs[index]['actionSelected']}');
                                    setState(() {});
                                  });
                              // return ActionTile(
                              //     memberdocId: customUserInfo.docId,
                              //     apparatus: apparatus,
                              //     actionName: name,
                              //     name: customUserInfo.name,
                              //     phoneNumber: "temp",
                              //     lessonDate: lessonDate,
                              //     grade: "50",
                              //     totalNote: totalNote,
                              //     docId: "",
                              //     uid: user.uid,
                              //     pos: index);
                            } else {
                              return SizedBox.shrink();
                            }
                          }
                        } else {
                          if (positionArray.contains(position)) {
                            positionFilteredSize++;
                            if (apparatusArray.isEmpty) {
                              return ActionListTile(
                                  actionName: name,
                                  apparatus: apparatus,
                                  position: position,
                                  name: customUserInfo.name,
                                  phoneNumber: customUserInfo.phoneNumber,
                                  lessonDate: lessonDate,
                                  grade: '50',
                                  totalNote: totalNote,
                                  docId: customUserInfo.docId,
                                  memberdocId: customUserInfo.docId,
                                  uid: user.uid,
                                  pos: index,
                                  isSelected: isSelected,
                                  isSelectable: true,
                                  isDraggable: false,
                                  customFunctionOnTap: () {
                                    doc['actionSelected'] =
                                        !doc['actionSelected'];

                                    print(
                                        'docs[index][selected]: ${docs[index]['actionSelected']}');
                                    setState(() {});
                                  });
                              // return ActionTile(
                              //     memberdocId: customUserInfo.docId,
                              //     apparatus: apparatus,
                              //     actionName: name,
                              //     name: customUserInfo.name,
                              //     phoneNumber: "temp",
                              //     lessonDate: lessonDate,
                              //     grade: "50",
                              //     totalNote: totalNote,
                              //     docId: customUserInfo.docId,
                              //     uid: user.uid,
                              //     pos: index);
                            } else {
                              if (apparatusArray.contains(apparatus)) {
                                return ActionListTile(
                                    actionName: name,
                                    apparatus: apparatus,
                                    position: position,
                                    name: customUserInfo.name,
                                    phoneNumber: customUserInfo.phoneNumber,
                                    lessonDate: lessonDate,
                                    grade: '50',
                                    totalNote: totalNote,
                                    docId: customUserInfo.docId,
                                    memberdocId: customUserInfo.docId,
                                    uid: user.uid,
                                    pos: index,
                                    isSelected: isSelected,
                                    isSelectable: true,
                                    isDraggable: false,
                                    customFunctionOnTap: () {
                                      doc['actionSelected'] =
                                          !doc['actionSelected'];

                                      print(
                                          'docs[index][selected]: ${docs[index]['actionSelected']}');
                                      setState(() {});
                                    });
                                // return ActionTile(
                                //     memberdocId: customUserInfo.docId,
                                //     apparatus: apparatus,
                                //     actionName: name,
                                //     name: customUserInfo.name,
                                //     phoneNumber: "temp",
                                //     lessonDate: lessonDate,
                                //     grade: "50",
                                //     totalNote: totalNote,
                                //     docId: customUserInfo.docId,
                                //     uid: user.uid,
                                //     pos: index);
                              } else {
                                return SizedBox.shrink();
                              }
                            }
                          } else {
                            return SizedBox.shrink();
                          }
                        }
                      } else {
                        // if (lowerCaseName
                        //     .startsWith(searchString.toLowerCase())) {
                        if (positionArray.isEmpty) {
                          if (apparatusArray.isEmpty) {
                            return ActionListTile(
                                actionName: name,
                                apparatus: apparatus,
                                position: position,
                                name: customUserInfo.name,
                                phoneNumber: customUserInfo.phoneNumber,
                                lessonDate: lessonDate,
                                grade: '50',
                                totalNote: totalNote,
                                docId: customUserInfo.docId,
                                memberdocId: customUserInfo.docId,
                                uid: user.uid,
                                pos: index,
                                isSelected: isSelected,
                                isSelectable: true,
                                isDraggable: false,
                                customFunctionOnTap: () {
                                  doc['actionSelected'] =
                                      !doc['actionSelected'];

                                  print(
                                      'docs[index][selected]: ${docs[index]['actionSelected']}');
                                  setState(() {});
                                });
                            // return ActionTile(
                            //     memberdocId: customUserInfo.docId,
                            //     apparatus: apparatus,
                            //     actionName: name,
                            //     name: customUserInfo.name,
                            //     phoneNumber: "temp",
                            //     lessonDate: lessonDate,
                            //     grade: "50",
                            //     totalNote: totalNote,
                            //     docId: customUserInfo.docId,
                            //     uid: user.uid,
                            //     pos: index);
                          } else {
                            if (apparatusArray.contains(apparatus)) {
                              return ActionListTile(
                                  actionName: name,
                                  apparatus: apparatus,
                                  position: position,
                                  name: customUserInfo.name,
                                  phoneNumber: customUserInfo.phoneNumber,
                                  lessonDate: lessonDate,
                                  grade: '50',
                                  totalNote: totalNote,
                                  docId: customUserInfo.docId,
                                  memberdocId: customUserInfo.docId,
                                  uid: user.uid,
                                  pos: index,
                                  isSelected: isSelected,
                                  isSelectable: true,
                                  isDraggable: false,
                                  customFunctionOnTap: () {
                                    doc['actionSelected'] =
                                        !doc['actionSelected'];

                                    print(
                                        'docs[index][selected]: ${docs[index]['actionSelected']}');
                                    setState(() {});
                                  });
                              // return ActionTile(
                              //     memberdocId: customUserInfo.docId,
                              //     apparatus: apparatus,
                              //     actionName: name,
                              //     name: customUserInfo.name,
                              //     phoneNumber: "temp",
                              //     lessonDate: lessonDate,
                              //     grade: "50",
                              //     totalNote: totalNote,
                              //     docId: customUserInfo.docId,
                              //     uid: user.uid,
                              //     pos: index);
                            } else {
                              return SizedBox.shrink();
                            }
                          }
                        } else {
                          if (positionArray.contains(position)) {
                            positionFilteredSize++;
                            if (apparatusArray.isEmpty) {
                              return ActionListTile(
                                  actionName: name,
                                  apparatus: apparatus,
                                  position: position,
                                  name: customUserInfo.name,
                                  phoneNumber: customUserInfo.phoneNumber,
                                  lessonDate: lessonDate,
                                  grade: '50',
                                  totalNote: totalNote,
                                  docId: customUserInfo.docId,
                                  memberdocId: customUserInfo.docId,
                                  uid: user.uid,
                                  pos: index,
                                  isSelected: isSelected,
                                  isSelectable: true,
                                  isDraggable: false,
                                  customFunctionOnTap: () {
                                    doc['actionSelected'] =
                                        !doc['actionSelected'];

                                    print(
                                        'docs[index][selected]: ${docs[index]['actionSelected']}');
                                    setState(() {});
                                  });
                              // return ActionTile(
                              //     apparatus: apparatus,
                              //     actionName: name,
                              //     name: customUserInfo.name,
                              //     phoneNumber: "temp",
                              //     lessonDate: lessonDate,
                              //     grade: "50",
                              //     totalNote: totalNote,
                              //     docId: "",
                              //     memberdocId: customUserInfo.docId,
                              //     uid: user.uid,
                              //     pos: index);
                            } else {
                              if (apparatusArray.contains(apparatus)) {
                                return ActionListTile(
                                    actionName: name,
                                    apparatus: apparatus,
                                    position: position,
                                    name: customUserInfo.name,
                                    phoneNumber: customUserInfo.phoneNumber,
                                    lessonDate: lessonDate,
                                    grade: '50',
                                    totalNote: totalNote,
                                    docId: customUserInfo.docId,
                                    memberdocId: customUserInfo.docId,
                                    uid: user.uid,
                                    pos: index,
                                    isSelected: isSelected,
                                    isSelectable: true,
                                    isDraggable: false,
                                    customFunctionOnTap: () {
                                      doc['actionSelected'] =
                                          !doc['actionSelected'];

                                      print(
                                          'docs[index][selected]: ${docs[index]['actionSelected']}');
                                      setState(() {});
                                    });
                                // return ActionTile(
                                //     apparatus: apparatus,
                                //     actionName: name,
                                //     name: customUserInfo.name,
                                //     phoneNumber: "temp",
                                //     lessonDate: lessonDate,
                                //     grade: "50",
                                //     totalNote: totalNote,
                                //     docId: "",
                                //     memberdocId: customUserInfo.docId,
                                //     uid: user.uid,
                                //     pos: index);
                              } else {
                                return SizedBox.shrink();
                              }
                            }
                          } else {
                            return SizedBox.shrink();
                          }
                        }
                        // } else {
                        //   return SizedBox.shrink();
                        // }
                      }

                      // return ActionListTile(
                      //   isSelectable: true,
                      //   isSelected: isSelected,
                      //   actionList: docs,
                      //   isDraggable: false,
                      //   actionName: name,
                      //   apparatus: apparatus,
                      //   position: position,
                      //   customFunctionOnTap: () {
                      //     doc['actionSelected'] = !doc['actionSelected'];

                      //     print(
                      //         'docs[index][selected]: ${docs[index]['actionSelected']}');
                      //     setState(() {});
                      //   },
                      // );
                    },
                  ),

                  // /// 동작 리스트
                  // Expanded(
                  //   child: Stack(
                  //     children: [
                  //       globalVariables.actionList.isEmpty
                  //           ? Center(
                  //               child: CircularProgressIndicator(
                  //               color: Palette.buttonOrange,
                  //             ))
                  //           : Container(
                  //               decoration: BoxDecoration(
                  //                 color: Palette.mainBackground,
                  //                 borderRadius: BorderRadius.circular(10),
                  //               ),
                  //               child: ListView.builder(
                  //                 scrollDirection: Axis.vertical,
                  //                 controller: scrollController,
                  //                 shrinkWrap: true,
                  //                 itemCount: docs.length,
                  //                 itemBuilder:
                  //                     (BuildContext context, int index) {
                  //                   final doc = docs[index];
                  //                   // print("doc : ${doc}");
                  //                   String apparatus = doc['apparatus'];
                  //                   String otherApparatusName =
                  //                       doc['otherApparatusName'];
                  //                   String position = doc['position'];
                  //                   String name = doc['name'];
                  //                   String lowerCaseName = doc['lowerCaseName'];
                  //                   List<dynamic> nGramizedLowerCaseName =
                  //                       doc['nGramizedLowerCaseName'] ?? [];

                  //                   final ActionInfo actionInfo = ActionInfo(
                  //                     name,
                  //                     apparatus,
                  //                     position,
                  //                   );

                  //                   // print(
                  //                   //     "noteId : ${noteId}, apparatus : ${apparatus}, actionName : ${name}, nGramizedLowerCaseName : ${nGramizedLowerCaseName}");

                  //                   if (searchString.isEmpty) {
                  //                     if (positionArray.isEmpty) {
                  //                       if (apparatusArray.isEmpty) {
                  //                         return ActionTile(
                  //                             memberdocId: customUserInfo.docId,
                  //                             apparatus: apparatus,
                  //                             actionName: name,
                  //                             name: customUserInfo.name,
                  //                             phoneNumber: "temp",
                  //                             lessonDate: lessonDate,
                  //                             grade: "50",
                  //                             totalNote: totalNote,
                  //                             docId: "",
                  //                             uid: user.uid,
                  //                             pos: index);
                  //                       } else {
                  //                         if (apparatusArray
                  //                             .contains(apparatus)) {
                  //                           return ActionTile(
                  //                               memberdocId:
                  //                                   customUserInfo.docId,
                  //                               apparatus: apparatus,
                  //                               actionName: name,
                  //                               name: customUserInfo.name,
                  //                               phoneNumber: "temp",
                  //                               lessonDate: lessonDate,
                  //                               grade: "50",
                  //                               totalNote: totalNote,
                  //                               docId: "",
                  //                               uid: user.uid,
                  //                               pos: index);
                  //                         } else {
                  //                           return SizedBox.shrink();
                  //                         }
                  //                       }
                  //                     } else {
                  //                       if (positionArray.contains(position)) {
                  //                         positionFilteredSize++;
                  //                         if (apparatusArray.isEmpty) {
                  //                           return ActionTile(
                  //                               memberdocId:
                  //                                   customUserInfo.docId,
                  //                               apparatus: apparatus,
                  //                               actionName: name,
                  //                               name: customUserInfo.name,
                  //                               phoneNumber: "temp",
                  //                               lessonDate: lessonDate,
                  //                               grade: "50",
                  //                               totalNote: totalNote,
                  //                               docId: customUserInfo.docId,
                  //                               uid: user.uid,
                  //                               pos: index);
                  //                         } else {
                  //                           if (apparatusArray
                  //                               .contains(apparatus)) {
                  //                             return ActionTile(
                  //                                 memberdocId:
                  //                                     customUserInfo.docId,
                  //                                 apparatus: apparatus,
                  //                                 actionName: name,
                  //                                 name: customUserInfo.name,
                  //                                 phoneNumber: "temp",
                  //                                 lessonDate: lessonDate,
                  //                                 grade: "50",
                  //                                 totalNote: totalNote,
                  //                                 docId: customUserInfo.docId,
                  //                                 uid: user.uid,
                  //                                 pos: index);
                  //                           } else {
                  //                             return SizedBox.shrink();
                  //                           }
                  //                         }
                  //                       } else {
                  //                         return SizedBox.shrink();
                  //                       }
                  //                     }
                  //                   } else {
                  //                     // if (lowerCaseName
                  //                     //     .startsWith(searchString.toLowerCase())) {
                  //                     if (positionArray.isEmpty) {
                  //                       if (apparatusArray.isEmpty) {
                  //                         return ActionTile(
                  //                             memberdocId: customUserInfo.docId,
                  //                             apparatus: apparatus,
                  //                             actionName: name,
                  //                             name: customUserInfo.name,
                  //                             phoneNumber: "temp",
                  //                             lessonDate: lessonDate,
                  //                             grade: "50",
                  //                             totalNote: totalNote,
                  //                             docId: customUserInfo.docId,
                  //                             uid: user.uid,
                  //                             pos: index);
                  //                       } else {
                  //                         if (apparatusArray
                  //                             .contains(apparatus)) {
                  //                           return ActionTile(
                  //                               memberdocId:
                  //                                   customUserInfo.docId,
                  //                               apparatus: apparatus,
                  //                               actionName: name,
                  //                               name: customUserInfo.name,
                  //                               phoneNumber: "temp",
                  //                               lessonDate: lessonDate,
                  //                               grade: "50",
                  //                               totalNote: totalNote,
                  //                               docId: customUserInfo.docId,
                  //                               uid: user.uid,
                  //                               pos: index);
                  //                         } else {
                  //                           return SizedBox.shrink();
                  //                         }
                  //                       }
                  //                     } else {
                  //                       if (positionArray.contains(position)) {
                  //                         positionFilteredSize++;
                  //                         if (apparatusArray.isEmpty) {
                  //                           return ActionTile(
                  //                               apparatus: apparatus,
                  //                               actionName: name,
                  //                               name: customUserInfo.name,
                  //                               phoneNumber: "temp",
                  //                               lessonDate: lessonDate,
                  //                               grade: "50",
                  //                               totalNote: totalNote,
                  //                               docId: "",
                  //                               memberdocId:
                  //                                   customUserInfo.docId,
                  //                               uid: user.uid,
                  //                               pos: index);
                  //                         } else {
                  //                           if (apparatusArray
                  //                               .contains(apparatus)) {
                  //                             return ActionTile(
                  //                                 apparatus: apparatus,
                  //                                 actionName: name,
                  //                                 name: customUserInfo.name,
                  //                                 phoneNumber: "temp",
                  //                                 lessonDate: lessonDate,
                  //                                 grade: "50",
                  //                                 totalNote: totalNote,
                  //                                 docId: "",
                  //                                 memberdocId:
                  //                                     customUserInfo.docId,
                  //                                 uid: user.uid,
                  //                                 pos: index);
                  //                           } else {
                  //                             return SizedBox.shrink();
                  //                           }
                  //                         }
                  //                       } else {
                  //                         return SizedBox.shrink();
                  //                       }
                  //                     }
                  //                     // } else {
                  //                     //   return SizedBox.shrink();
                  //                     // }
                  //                   }
                  //                 },
                  //               ),
                  //             ),
                  //     ],
                  //   ),
                  // ),
                  Offstage(
                    offstage: isFullScreen,
                    child: Column(
                      children: [
                        /// 동작 검색 창
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                          color: Palette.secondaryBackground,
                          height: searchString.isEmpty ? 190 : 60,
                          child: Column(
                            children: [
                              BaseSearchTextField(
                                customController: searchController,
                                customFocusNode: searchFocusNode,
                                hint: "동작을 검색하세요.",
                                showArrow: true,
                                customFunction: () {
                                  setState(() {
                                    searchString =
                                        searchController.text.toLowerCase();
                                  });
                                },
                                clearfunction: () {
                                  setState(() {
                                    searchController.clear();
                                    searchString = "";
                                  });
                                },
                              ),
                              SizedBox(height: 5),
                              Offstage(
                                offstage: searchString.isNotEmpty,
                                child: Column(
                                  children: [
                                    SizedBox(height: 5),
                                    GrayInkwellButton(
                                      label: '신규 동작 추가',
                                      customFunctionOnTap: () async {
                                        print("신규 동작 추가");
                                        // LessonAdd로 이동
                                        final result = await showDialog(
                                          context: context,
                                          builder: (context) => StatefulBuilder(
                                            builder: (context, setState) {
                                              return ActionAdd.manageList(
                                                  globalVariables.actionList);
                                            },
                                          ),
                                        );
                                        setState(() {
                                          if (result == null) {
                                            searchString = "";
                                          } else {
                                            List resultList = result as List;
                                            String tmpSearchStr =
                                                resultList[0].toString().trim();
                                            if (tmpSearchStr.isNotEmpty) {
                                              searchController.text =
                                                  tmpSearchStr;
                                              searchString = tmpSearchStr;
                                            } else {
                                              searchString = "";
                                            }

                                            globalVariables.actionList =
                                                resultList[1];
                                          }
                                        });
                                      },
                                    ),
                                    Divider(),

                                    /// 기구 필터
                                    SizedBox(
                                      height: 30,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for (final chip in apparatusChips)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        4.0, 0, 4, 0),
                                                child: chip,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),

                                    /// 자세 필터
                                    SizedBox(
                                      height: 30,
                                      child: Center(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              for (final chip in positionChips)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          4.0, 0, 4, 0),
                                                  child: chip,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Spacer(),

                        /// 동작 추가 버튼과 칩 영역
                        Offstage(
                          offstage: searchString.isNotEmpty,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 10),
                            color: tmpLessonInfoList.isEmpty
                                ? Palette.gray00.withOpacity(0)
                                : Palette.gray00.withOpacity(0.3),
                            height: 100,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                /// 선택된 동작 칩들
                                Offstage(
                                  offstage: tmpLessonInfoList.isEmpty,
                                  child: SizedBox(
                                    height: 30,
                                    child: Center(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for (final chip in actionChips)
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4),
                                                child: chip,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),

                                /// 동작 추가 버튼
                                ElevatedButton(
                                  onPressed: () {
                                    print("동작추가");

                                    // lessonAdd
                                    if (globalVariables.actionList
                                        .where((element) =>
                                            element['actionSelected'])
                                        .isNotEmpty) {
                                      print(
                                          "동작추가 userInfo.docId : ${customUserInfo.docId}");

                                      List<DateTime> tmpEventList = [];
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("동작추가 성공"),
                                      ));

                                      // actionSelected 값이 true 이면 tmpList 에 넣어서 반환한다.
                                      List tmpResultList = [];
                                      globalVariables.actionList
                                          .forEach((element) {
                                        if (element['actionSelected'] == true) {
                                          tmpResultList.add(element);
                                        }
                                      });
                                      // actionSelected false 로 전부 초기화
                                      globalVariables.actionList
                                          .forEach((element) {
                                        if (element['actionSelected'] == true) {
                                          element['actionSelected'] = false;
                                        }
                                      });
                                      // 저장하기 성공시 MemberInfo로 이동
                                      Navigator.pop(context, tmpResultList);

                                      initStateVar = !initStateVar;
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("동작을 선택해주세요."),
                                      ));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    elevation: 0,
                                    backgroundColor: Palette.buttonOrange,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 90),
                                    child: Text(
                                        "동작추가(${tmpLessonInfoList.isEmpty ? 0 : selectedActionCount})",
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// 확인버튼
                        Offstage(
                          offstage: searchString.isEmpty,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                print("신규 동작추가 확인");
                                setState(() {
                                  searchString = "";
                                  searchController.clear();
                                  searchFocusNode.unfocus();
                                  /* scrollController.jumpTo(
                                    scrollController.position.minScrollExtent); */
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 0,
                                backgroundColor: Palette.buttonOrange,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 90),
                                child:
                                    Text("확인", style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          // bottomNavigationBar: BaseBottomAppBar(),
        );
      }),
    );
  }
}

class ActionTile extends StatefulWidget {
  ActionTile({
    Key? key,
    required this.apparatus,
    required this.actionName,
    required this.name,
    required this.phoneNumber,
    required this.lessonDate,
    required this.grade,
    required this.totalNote,
    required this.docId,
    required this.memberdocId,
    required this.uid,
    required this.pos,
  }) : super(key: key);

  final String apparatus;
  final String actionName;
  final String name;
  final String phoneNumber;
  final String lessonDate;
  final String grade;
  final String totalNote;
  final String docId;
  final String memberdocId;

  final String uid;
  int pos;
  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<ActionTile> {
  @override
  Widget build(BuildContext context) {
    State<ActionSelector>? actionSelector = context.findAncestorStateOfType();
    TmpLessonInfo tmpLessonInfo = TmpLessonInfo(
        widget.memberdocId,
        widget.apparatus,
        widget.actionName,
        widget.name,
        widget.lessonDate,
        widget.grade,
        widget.totalNote,
        widget.docId,
        widget.uid,
        true);
    //레슨서비스 활용
    final lessonService = context.read<LessonService>();
    // onTap 방식과는 다르게 동작해야 함

    setState(() {
      if (manageListContaining(tmpLessonInfoList, tmpLessonInfo, false)) {
        actionTileColor = Palette.buttonOrange;
        apparatusTextColor = Palette.grayFF;
        actionNameTextColor = Palette.grayFF;
        /* print(
            "YES contain!! => widget.apparatus : ${widget.apparatus}, widget.actionName : ${widget.actionName}"); */
      } else {
        actionTileColor = Palette.grayFA;
        apparatusTextColor = Palette.gray99;
        actionNameTextColor = Palette.gray66;
        /* print(
            "NOT contain!! => widget.apparatus : ${widget.apparatus}, widget.actionName : ${widget.actionName}"); */
      }
    });
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Palette.grayEE, width: 1),
            ),
            color: actionTileColor),
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Text(
                "${widget.apparatus}   ",
                style: TextStyle(
                  color: apparatusTextColor,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              "${widget.actionName}",
              style: TextStyle(
                  color: actionNameTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

bool manageListContaining(List<TmpLessonInfo> tmpLessonInfoList,
    TmpLessonInfo tmpLessonInfo, bool isEditable) {
  bool isConatained = false;
  for (int i = 0; i < tmpLessonInfoList.length; i++) {
    if (tmpLessonInfoList[i].apparatusName == tmpLessonInfo.apparatusName) {
      if (tmpLessonInfoList[i].actionName == tmpLessonInfo.actionName) {
        isConatained = true;
        if (isEditable) {
          tmpLessonInfoList.removeAt(i);
        }
      }
    }
  }
  if (isEditable) {
    if (!isConatained) {
      tmpLessonInfoList.add(tmpLessonInfo);
    }
  }
  return isConatained;
}

class TmpLessonInfo {
  TmpLessonInfo(
    this.memberdocId,
    this.apparatusName,
    this.actionName,
    this.name,
    this.lessonDate,
    this.grade,
    this.totalNote,
    this.docId,
    this.uid,
    this.isSelected,
  );
  String memberdocId;
  String apparatusName;
  String actionName;
  String name;
  String lessonDate;
  String grade;
  String totalNote;
  String docId;
  String uid;
  bool isSelected;
}
