import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/app/data/provider/daylesson_service.dart';
import 'package:web_project/app/ui/widget/actionListTileWidget.dart';
import 'package:web_project/app/ui/page/actionSelector.dart';
import 'package:web_project/app/data/provider/lesson_service.dart';
import 'package:web_project/app/ui/page/sequenceLibrary.dart';
import 'package:web_project/app/ui/widget/buttonWidget.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/ui/widget/lessonActionListTileWidget.dart';
import 'package:web_project/main.dart';
import 'package:web_project/app/data/model/userInfo.dart'
    as CustomUserInfo; // 다른 페키지와 클래스 명이 겹치는 경우 alias 선언해서 사용

import '../app/data/provider/auth_service.dart';
import '../app/data/model/color.dart';
import '../app/function/globalFunction.dart';
import '../app/ui/widget/globalWidget.dart';
import '../app/ui/page/memberInfo.dart';

String now = DateFormat("yyyy-MM-dd").format(DateTime.now());

//TextEditingController nameController = TextEditingController();
//TextEditingController apratusNameController = TextEditingController();
//TextEditingController actionNameController = TextEditingController();
TextEditingController lessonDateController = TextEditingController(text: now);
//TextEditingController gradeController = TextEditingController(text: "50");
TextEditingController todayNoteController = TextEditingController();

/// 시퀀스 이름 컨트롤러
TextEditingController sequenceNameController = TextEditingController();

/// 시퀀스 hint 이름 디폴트
int customSequenceNumber = 1;
String customSequenceName = '커스텀 시퀀스 ${customSequenceNumber}';

/// 시퀀스 이름 포커스 노드
FocusNode sequenceNameFocusNode = FocusNode();

FocusNode lessonDateFocusNode = FocusNode();

// 가변적으로 TextFields
List<TextEditingController> totalNoteControllers = [];

// 가변적으로 TextFields DocId 집합 (전체삭제시 필요)
List<String> totalNoteTextFieldDocId = new List.empty(growable: true);
List<TmpLessonInfo> tmpLessonInfoList = new List.empty(growable: true);

//List<String> totalNotes = new List.empty(growable: true);

GlobalFunction globalFunction = GlobalFunction();

//예외처리 : 동작이 없을 경우 저장을 막는 용도로 사용
bool actionSelectMode = false;

//초기상태
bool checkInitState = true;

//날짜 변경할 경우 데이터 다시 불러오기에 활용.
bool DateChangeMode = false;

//totalNoteControllers,totalNoteTextFieldDocId index 에러 방지
bool flagIndexErr = true;

String lessonDate = now;
int additionalActionlength = 0;

String selectedDropdown = '기구';
List<String> dropdownList = [
  'REFORMER',
  'CADILLAC',
  'CHAIR',
  'LADDER BARREL',
  'SPRING BOARD',
  'SPINE CORRECTOR',
  'MAT',
  'OTHERS',
];

double sliderValue = 50;

String editDocId = "";
String editApparatusName = "";
String editLessonDate = "";
String editGrade = "";
String editTotalNote = "";

bool keyboardOpenBefore = false;
String todayNotedocId = "";
String todayNoteView = "";

// List resultActionList = [];

bool isSequenceSaveChecked = false;
bool isTicketCountChecked = true;

bool isFirst = true;

List lessonActionList = [];
List dayLessonList = [];

List notedActionWidget = [];
List<String> notedActionsList = [];
List deleteTargetDocIdLiet = [];

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

List<TextEditingController> txtEdtCtrlrList = [];

class LessonAdd extends StatefulWidget {
  const LessonAdd({super.key});

  @override
  State<LessonAdd> createState() => _LessonAddState();
}

class _LessonAddState extends State<LessonAdd> {
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    lessonActionList = [];
    txtEdtCtrlrList = [];
    dayLessonList = [];
    deleteTargetDocIdLiet = [];

    initStateCheck = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    isFirst = true;
    lessonDateController.clear();
    todayNoteController.clear();
    clearTotalNoteControllers();
    totalNoteTextFieldDocId.clear();
    tmpLessonInfoList.clear();
    todayNotedocId = "";
    todayNoteView = "";

    //deleteControllers();
    checkInitState = true;
    DateChangeMode = false;
    print("[LA] Dispose : checkInitState ${checkInitState} ");
    super.dispose();

    lessonActionList = [];
    txtEdtCtrlrList = [];
    dayLessonList = [];
    deleteTargetDocIdLiet = [];

    lessonAddMode = "";

    initStateCheck = true;
  }

  @override
  void didUpdateWidget(covariant LessonAdd oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print("oldWidget : ${oldWidget}");
  }

  bool actionNullCheck = true;

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser()!;
    final lessonService = context.read<LessonService>();

    // TextEditController 재빌드시 초기화
    // txtEdtCtrlrList = [];

    // 이전 화면에서 보낸 변수 받기
    final argsList =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    CustomUserInfo.UserInfo customUserInfo = argsList[0];
    String lessonDateArg = argsList[1];
    List<DateTime> eventList = argsList[2];
    String lessonNoteId = argsList[3];
    String lessonAddMode = argsList[4];
    tmpLessonInfoList = argsList[5]; // null
    // resultActionList = argsList[6];

    print(
        '[LA] 시작 checkInitState - ${checkInitState} / DateChange - ${DateChangeMode} / actionNullCheck - ${actionNullCheck}');
    print(
        "[LA] 노트 관련 ${lessonDate} / ${lessonAddMode} / tmpLessonInfoList ${tmpLessonInfoList.length}");

    if (checkInitState) {
      print("INIT!!! : ${checkInitState}, DateChange:${DateChangeMode}");
      //now = DateFormat("yyyy-MM-dd").format(DateTime.now());

      if (!DateChangeMode) {
        lessonDate = argsList[1];
        lessonDateController.text = lessonDate;
      } else {
        lessonDate = lessonDateController.text;
        DateChangeMode = false;
      }
      print("Date : ${lessonDate}");

      Future<int> lenssonData = lessonService.countPos(
        user.uid,
        customUserInfo.docId,
        lessonDateController.text,
      );

      lenssonData.then((val) {
        // int가 나오면 해당 값을 출력
        print('val: $val');
        //Textfield 생성
        createControllers(val);
        //노트 삭제를 위한 변수 초기화
        //totalNoteTextFieldDocId = List<String>.filled(val, "", growable: true);

        //노트 삭제를 위한 변수 초기화
        //totalNotes = List<String>.filled(val, "", growable: true);
      }).catchError((error) {
        // error가 해당 에러를 출력
        print('error: $error');
      });

      print("초기화시컨트롤러:${totalNoteControllers}");
      print("초기화시노트아이디:${totalNoteTextFieldDocId}");

      checkInitState = !checkInitState;
      actionSelectMode = false;
      print("INIT!!!변경 : ${checkInitState}");
    }
    print("재빌드시 init상태 : ${checkInitState}");
    // if (MediaQuery.of(context).viewInsets.bottom == 0) {
    //   if (keyboardOpenBefore) {
    //     FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기 이벤트
    //     keyboardOpenBefore = false;
    //   }
    // } else {
    //   keyboardOpenBefore = true;
    // }

    return Consumer2<LessonService, DayLessonService>(
      builder: (context, lessonService, dayLessonService, child) {
        print(
            "customUserInfo.uid : ${customUserInfo.uid}, customUserInfo.docId :  ${customUserInfo.docId} lessonDateArg : ${lessonDateArg}");
        if (lessonActionList.isEmpty && lessonAddMode == "노트편집") {
          lessonService
              .readDateMemberActionNote(
                  customUserInfo.uid, customUserInfo.docId, lessonDateArg)
              .then((value) {
            print("ppppppppp - value : ${value}");
            lessonActionList.addAll(value);

            // notedActionWidget = makeChips(notedActionWidget, lessonActionList, Palette.backgroundOrange);

            lessonActionList.forEach((element) {
              txtEdtCtrlrList.add(new TextEditingController());
            });

            // setState(() {}); // 여기서 setState 호출하면 무한 획귀 오려 발생 하기도 함
            // lessonService.notifyListeners();
          });
        }
        print(
            "lessonActionList.where((element) => element['noteSelected'] == true).isNotEmpty; : ${lessonActionList.where((element) => element['noteSelected'] == true).isNotEmpty}");

        if (dayLessonList.isEmpty && lessonAddMode == "노트편집") {
          daylessonService
              .readTodayNoteOflessonDate(
                  customUserInfo.uid, customUserInfo.docId, lessonDateArg)
              .then((value) {
            dayLessonList.add(value);
            dayLessonList.forEach((element) {
              print("ppppppppp - dayLessonList - element : ${element}");
              todayNoteController.text = element[0]['todayNote'];
            });

            setState(() {});
            // lessonService.notifyListeners();
          });
        }
        print("aaaaaaaaa - lessonActionList.length ${lessonActionList.length}");
        totalNoteTextFieldDocId = [];
        lessonActionList.forEach(
          (element) {
            print("aaaaaaaaa - element['docId'] : ${element['docId']}");
            totalNoteTextFieldDocId.add(element['docId']);
          },
        );

        todayNoteController.selection = TextSelection.fromPosition(
            TextPosition(offset: todayNoteController.text.length));

        return Scaffold(
          //resizeToAvoidBottomInset: false,
          backgroundColor: Palette.secondaryBackground,
          appBar: BaseAppBarMethod(context, lessonAddMode, () {
            // 뒤로가기 선택시 MemberInfo로 이동
            Navigator.pop(context);
          }, [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: TextButton(
                  onPressed: () async {
                    print(
                        "[LA] 저장버튼실행 actionNullCheck : ${actionNullCheck}/todayNoteView : ${todayNoteView}");

                    // 오늘의 레슨 종합 레슨 기록이 비어있고, 개별 기록도 없다면 안내 메세지 보여줌
                    // 뭐 든 하나라도 있다면 저장
                    if ((todayNoteController.text.trim().isEmpty) &&
                        lessonActionList
                            .where((element) => element['noteSelected'])
                            .isEmpty) {
                      //오늘의 노트가 없는 경우, 노트 생성 및 동작 노트들 저장
                      //await todayNoteSave(
                      //    lessonService, customUserInfo, context);

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("일별노트 또는 동작선택중 하나는 필수입력해주세요."),
                      ));
                    } else {
                      print(
                          "[LA] 노트저장 DateChangeMode : ${DateChangeMode}/todayNoteView : ${todayNoteView} / checkInitState : ${checkInitState}");
                      DateChangeMode = false;

                      print("[LA] 일별메모 저장 : todayNotedocId ${todayNotedocId} ");

                      //일별 노트 저장
                      /* await todayNoteSave(
                          lessonService, customUserInfo, context); */

                      saveMethod(lessonService, lessonDateArg, lessonAddMode,
                          customUserInfo, dayLessonService);

                      // await totalNoteSave(
                      //     lessonService, customUserInfo, context);

                      lessonService.notifyListeners();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    '완료',
                    style: TextStyle(
                      color: Palette.textBlue,
                      fontSize: 16,
                    ),
                  )),
            )
          ], null),

          body: CenterConstrainedBody(
            child: Container(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: SingleChildScrollView(
                  //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: (MediaQuery.of(context).viewInsets.bottom),
                    ),
                    child: Column(
                      children: [
                        /// 입력창
                        Column(
                          children: [
                            // Text(
                            //     "변경 : ${MediaQuery.of(context).viewInsets.bottom.toString()}"),
                            // // 기구 입력창
                            // BaseModalBottomSheetButton(
                            //   bottomModalController: apratusNameController,
                            //   hint: "기구",
                            //   showButton: true,
                            //   optionList: dropdownList,
                            //   customFunction: () {},
                            // ),
                            SizedBox(height: 10),

                            /// 이름 및 수강권
                            Container(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userInfo.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '등록일: ${userInfo.registerDate}',
                                          style: TextStyle(
                                              color: Palette.gray99,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              isTicketCountChecked
                                                  ? Icons.confirmation_num
                                                  : Icons
                                                      .confirmation_num_outlined,
                                              color: isTicketCountChecked
                                                  ? Palette.buttonOrange
                                                  : Palette.gray99,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              isTicketCountChecked ? "7" : "8",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isTicketCountChecked
                                                    ? Palette.gray00
                                                    : Palette.gray99,
                                              ),
                                            ),
                                            Text(
                                              "/",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isTicketCountChecked
                                                    ? Palette.gray00
                                                    : Palette.gray99,
                                              ),
                                            ),
                                            Text(
                                              "10",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isTicketCountChecked
                                                    ? Palette.gray00
                                                    : Palette.gray99,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text("수강권 차감 여부"),
                                            Checkbox(
                                              value: isTicketCountChecked,
                                              onChanged: (value) {
                                                /// 체크 토글
                                                isTicketCountChecked =
                                                    !isTicketCountChecked;

                                                /// 화면 재빌드
                                                setState(() {});
                                              },
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 10),

                            /// 일별 메모 입력 영역
                            Container(
                              color: Palette.mainBackground,
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    /// 수업일 입력창
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Palette.gray99,
                                        ),
                                        SizedBox(width: 10),

                                        /// 새로 도전하는 수업일 입력창
                                        Container(
                                          width: 140,
                                          child: Material(
                                            color: Palette.mainBackground,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () async {
                                                await globalFunction
                                                    .getDateFromCalendar(
                                                        context,
                                                        lessonDateController,
                                                        "수업일",
                                                        lessonDateController
                                                            .text);

                                                // todayNoteController.text = "";

                                                //lessonDate = lessonDateController.text;
                                                DateChangeMode = true;
                                                checkInitState = true;
                                                print(
                                                    "[LA] 수업일변경 : lessonDateController ${lessonDateController.text} / todayNoteController ${todayNoteController.text} / DateChangeMode ${DateChangeMode}");
                                                initInpuWidget(
                                                    uid: user.uid,
                                                    docId: customUserInfo.docId,
                                                    lessonService:
                                                        lessonService);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 0, 10, 0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        textAlign:
                                                            TextAlign.start,
                                                        enabled: false,
                                                        maxLines: null,
                                                        controller:
                                                            lessonDateController,
                                                        focusNode:
                                                            lessonDateFocusNode,
                                                        autofocus: true,
                                                        obscureText: false,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText:
                                                              '날짜를 선택하세요.',
                                                          hintStyle: TextStyle(
                                                              color: Palette
                                                                  .gray99,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        style: TextStyle(
                                                            color:
                                                                Palette.gray00,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        /* validator:
                                                                                _model.textControllerValidator.asValidator(context), */
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_outlined,
                                                      color: Palette.gray99,
                                                      size: 16,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )

                                        /// 기존 수업일 입력창
                                        // Expanded(
                                        //   child: BaseTextField(
                                        //     customController: lessonDateController,
                                        //     customFocusNode: lessonDateFocusNode,
                                        //     hint: "수업일",
                                        //     showArrow: true,
                                        //     customFunction: () async {
                                        //       await globalFunction
                                        //           .getDateFromCalendar(
                                        //               context,
                                        //               lessonDateController,
                                        //               "수업일",
                                        //               lessonDateController.text);

                                        //       todayNoteController.text = "";

                                        //       //lessonDate = lessonDateController.text;
                                        //       DateChangeMode = true;
                                        //       checkInitState = true;
                                        //       print(
                                        //           "[LA] 수업일변경 : lessonDateController ${lessonDateController.text} / todayNoteController ${todayNoteController.text} / DateChangeMode ${DateChangeMode}");
                                        //       initInpuWidget(
                                        //           uid: user.uid,
                                        //           docId: customUserInfo.docId,
                                        //           lessonService: lessonService);

                                        //       // setState(() {
                                        //       //   print(
                                        //       //       "수업일변경 : ${lessonDateController.text}  - ${todayNoteController.text}");
                                        //       //   todayNoteController.text = "";
                                        //       //   print(
                                        //       //       "텍스트지우기 : ${lessonDateController.text} - ${todayNoteController.text}");
                                        //       //   //lessonDate = lessonDateController.text;
                                        //       //   DateChangeMode = true;

                                        //       //   initInpuWidget();
                                        //       // });
                                        //       // await refreshLessonDate(
                                        //       //     uid: user.uid,
                                        //       //     docId: customUserInfo.docId,
                                        //       //     lessonService: lessonService);
                                        //       //lessonService.notifyListeners();
                                        //       // setState(() {

                                        //       // });
                                        //     },
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    SizedBox(height: 0),

                                    /// 일별 메모 입력창
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Icon(
                                              Icons.text_snippet_outlined,
                                              color: Palette.gray99,
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child:
                                              // child: FutureBuilder<QuerySnapshot>(
                                              //   future: lessonService
                                              //       .readTodayNoteOflessonDate(
                                              //     user.uid,
                                              //     customUserInfo.docId,
                                              //     lessonDateController.text,
                                              //   ),
                                              //   builder: (context, snapshot) {
                                              /* print(
                                                  "문서가져오기시작 : ${lessonDateController.text}");

                                              final docsTodayNote =
                                                  snapshot.data?.docs ??
                                                      []; // 문서들 가져오기

                                              print(
                                                  "[LA] 일별노트 출력 시작 : 유/무 ${docsTodayNote.isEmpty} / todayNotedocId ${todayNotedocId} / todayNoteView ${todayNoteView} / todayNoteController ${todayNoteController}");

                                              if (docsTodayNote.isEmpty) {
                                                todayNotedocId = "";
                                                todayNoteView = "";
                                                print(
                                                    "뿌릴 일별 노트 없음 : ${todayNoteController.text}");
                                              } else {
                                                todayNoteView = docsTodayNote[0]
                                                    .get('todayNote');
                                                print(
                                                    "todayNoteView : ${todayNoteView}");
                                                todayNoteController.selection =
                                                    TextSelection.fromPosition(
                                                        TextPosition(
                                                            offset:
                                                                todayNoteController
                                                                    .text
                                                                    .length));

                                                todayNotedocId =
                                                    docsTodayNote[0].id;


                                                print(
                                                    "뿌릴 일별 노트 출력 완료 : ${todayNoteController.text} - ${todayNotedocId} ");
                                              }
                                              print(
                                                  "[LA] 일별노트 출력 결과 : todayNotedocId ${todayNotedocId} / todayNoteView ${todayNoteView} / todayNoteController ${todayNoteController}");
                                               */

                                              /// 리턴 시작
                                              // return
                                              Container(
                                            constraints:
                                                BoxConstraints(minHeight: 120),
                                            child: Container(
                                              child: TextFormField(
                                                onChanged: (value) {
                                                  // todayNoteView = value;
                                                  // 오늘의 레슨 기록 변화 시 todayNoteController에 넣는다
                                                  todayNoteController.text =
                                                      value;
                                                  todayNoteController
                                                          .selection =
                                                      TextSelection.fromPosition(
                                                          TextPosition(
                                                              offset:
                                                                  todayNoteController
                                                                      .text
                                                                      .length));
                                                },
                                                maxLines: null,
                                                controller: todayNoteController,
                                                autofocus: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.all(20),
                                                  border: InputBorder.none,
                                                  hintText: '오늘의 수업 내용을 기록해보세요',
                                                  hintStyle: TextStyle(
                                                      color: Palette.gray99,
                                                      fontSize: 14),
                                                ),
                                                style: TextStyle(
                                                    color: Palette.gray00,
                                                    fontSize: 14),
                                                /* validator:
                                                      _model.textControllerValidator.asValidator(context), */
                                              ),
                                            ),
                                          ),
                                          //   },
                                          // ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    /// 동작별 메모 (New)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: 0,
                                            ),
                                            Icon(
                                              Icons.accessibility_new_rounded,
                                              color: Palette.gray99,
                                            ),
                                          ],
                                        ),

                                        // 레슨 기록에 동작별 기록이 있으면 칩으로 보여준다.
                                        lessonActionList
                                                .where((element) =>
                                                    element['noteSelected'] ==
                                                    true)
                                                .isNotEmpty // is동작메모하나라도있니? 변수 필요
                                            /// 동작 있을 경우
                                            ? Expanded(
                                                child: ListView.builder(
                                                    padding: EdgeInsets.only(
                                                        bottom: 0),
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        lessonActionList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      /* Key? valueKey;

                                                      /* lessonActionList[index]
                                                          ['pos'] = index; */

                                                      valueKey = ValueKey(
                                                          lessonActionList[
                                                              index]['pos']); */

                                                      final doc =
                                                          lessonActionList[
                                                              index];

                                                      // print(
                                                      //     "bbbbbbbb - doc : ${doc}");

                                                      String uid =
                                                          doc['uid']; // 강사 고유번호

                                                      String name =
                                                          doc['name']; //회원이름
                                                      String phoneNumber = doc[
                                                          'phoneNumber']; // 회원 고유번호 (전화번호로 회원 식별)
                                                      String apratusName = doc[
                                                          'apratusName']; //기구이름
                                                      String actionName = doc[
                                                          'actionName']; //동작이름
                                                      String lessonDate = doc[
                                                          'lessonDate']; //수업날짜
                                                      String grade =
                                                          doc['grade']; //수행도
                                                      String totalNote = doc[
                                                          'totalNote']; //수업총메모
                                                      int pos =
                                                          doc['pos']; //수업총메모
                                                      bool isSelected =
                                                          doc['noteSelected'];

                                                      String actionNote =
                                                          doc['totalNote'];

                                                      /* if (txtEdtCtrlrList[index]
                                                          .text
                                                          .isEmpty) { */

                                                      /* } */

                                                      if (initStateCheck) {
                                                        String tmp =
                                                            txtEdtCtrlrList[
                                                                    index]
                                                                .text;
                                                        txtEdtCtrlrList[index]
                                                            .text = actionNote;
                                                        if (lessonActionList
                                                                    .length -
                                                                1 ==
                                                            index) {
                                                          initStateCheck =
                                                              false;
                                                        }
                                                      }
                                                      txtEdtCtrlrList[index]
                                                              .selection =
                                                          TextSelection.fromPosition(
                                                              TextPosition(
                                                                  offset: txtEdtCtrlrList[
                                                                          index]
                                                                      .text
                                                                      .length));

                                                      return Offstage(
                                                        /* key: valueKey, */
                                                        offstage: !isSelected,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20),
                                                                child: Chip(
                                                                  label: Text(
                                                                      "$actionName"),
                                                                  deleteIcon:
                                                                      Icon(
                                                                    Icons
                                                                        .close_sharp,
                                                                    size: 16,
                                                                  ),
                                                                  onDeleted:
                                                                      () {
                                                                    lessonActionList[
                                                                            index]
                                                                        [
                                                                        'noteSelected'] = !lessonActionList[
                                                                            index]
                                                                        [
                                                                        'noteSelected'];
                                                                    // controller의 텍스트 초기화
                                                                    txtEdtCtrlrList[
                                                                            index]
                                                                        .text = "";
                                                                    String tmp =
                                                                        txtEdtCtrlrList[index]
                                                                            .text;

                                                                    print(
                                                                        "txtEdtCtrlrList[index].text : ${txtEdtCtrlrList[index].text}");

                                                                    setState(
                                                                        () {});
                                                                  },
                                                                )),
                                                            TextFormField(
                                                              onChanged:
                                                                  (value) {
                                                                txtEdtCtrlrList[
                                                                        index]
                                                                    .text = value;
                                                                String tmp =
                                                                    txtEdtCtrlrList[
                                                                            index]
                                                                        .text;
                                                                txtEdtCtrlrList[
                                                                            index]
                                                                        .selection =
                                                                    TextSelection
                                                                        .fromPosition(TextPosition(
                                                                            offset:
                                                                                txtEdtCtrlrList[index].text.length));
                                                              },
                                                              controller:
                                                                  txtEdtCtrlrList[
                                                                      index],
                                                              maxLines: null,
                                                              autofocus: true,
                                                              obscureText:
                                                                  false,
                                                              decoration:
                                                                  InputDecoration(
                                                                /* content padding을 20이상 잡아두지 않으면,
                                                              한글 입력 시 텍스트가 위아래로 움직이는 오류 발생 */
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            20),
                                                                hintText:
                                                                    '동작 수행 시 특이사항을 남겨보세요.',
                                                                hintStyle: TextStyle(
                                                                    color: Palette
                                                                        .gray99,
                                                                    fontSize:
                                                                        14),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                              style: TextStyle(
                                                                  color: Palette
                                                                      .gray00,
                                                                  fontSize: 14),
                                                              /* validator:
                                                                  _model.textControllerValidator.asValidator(context), */
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                              )

                                            /// 동작 하나도 없을 경우
                                            : Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20),
                                                child: Text(
                                                  '아래에서 동작을 선택하여 추가해보세요.',
                                                  style: TextStyle(
                                                      color: Palette.gray99),
                                                ),
                                              )
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),

                            /// 시퀀스 영역 시작
                            SizedBox(height: 20),

                            /// 시퀀스의 헤딩 영역
                            Container(
                                padding: EdgeInsets.fromLTRB(9, 0, 20, 0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSequenceSaveChecked,
                                      onChanged: (value) {
                                        /// 체크 토글
                                        isSequenceSaveChecked =
                                            !isSequenceSaveChecked;

                                        /// 체크박스 클릭하면 포커스가 이동하는 함수
                                        if (isSequenceSaveChecked == true) {
                                          sequenceNameFocusNode.requestFocus();
                                        }

                                        /// 화면 재빌드
                                        setState(() {});
                                      },
                                    ),
                                    Text('나의 시퀀스 저장'),
                                    Spacer(),
                                    TextButton(
                                        onPressed: () {
                                          /// 저장된 시퀀스들이 있는 화면으로 이동하는 함수
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SequenceLibrary()),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.folder_outlined,
                                              color: Palette.gray99,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '불러오기',
                                              style: TextStyle(
                                                  color: Palette.gray00),
                                            )
                                          ],
                                        ))
                                  ],
                                )),

                            /// 시퀀스 제목 영역
                            Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                focusNode: sequenceNameFocusNode,
                                controller: sequenceNameController,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(

                                    /// customSequenceName:'커스텀 시퀀스 ${customSequenceNumber}'
                                    /// 중복된 값 없도록 만들어주는 숫자 변수: customSequenceNumber
                                    hintText: customSequenceName,
                                    /* 앞에 있어야 하는 함수
                                    if (저장된 시퀀스 중에 ${변수명} 있니?) {
                                      customSequenceNumber = customSequenceNumber++;
                                    } 
                                    */

                                    /* 뒤에 있어야 하는 함수
                                    if (인풋 없다면) {
                                      sequenceNameController.text = customSqeunceName;
                                    }
                                    */

                                    hintStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Palette.gray00),
                                    border: InputBorder.none),
                              ),
                            ),

                            /// 시퀀스 영역 시작
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Column(children: [
                                // 동작입력 버튼
                                GrayInkwellButton(
                                  label: '동작 추가',
                                  customFunctionOnTap: () async {
                                    //String currentAppratus =
                                    //    apratusNameController.text;
                                    String currentAppratus = "";

                                    String lessonDate =
                                        lessonDateController.text;
                                    String totalNote = "";

                                    //동작선택 모드
                                    //bool checkInitState = true;
                                    actionSelectMode = true;
                                    print(
                                        "[LA] 동작추가시작 tmpLessonInfoList : ${tmpLessonInfoList.length}");

                                    // ActionSelector 화면 진입 전에, actionSelected 초기화
                                    globalVariables.actionList
                                        .forEach((element) {
                                      element['actionSelected'] = false;
                                    });

                                    var result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ActionSelector(),
                                        fullscreenDialog: true,
                                        // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                                        settings: RouteSettings(arguments: [
                                          customUserInfo,
                                          currentAppratus,
                                          lessonDate,
                                          checkInitState,
                                          totalNote,
                                          tmpLessonInfoList,
                                          // resultActionList,
                                        ]),
                                      ),
                                    ).then((value) {
                                      if (value != null) {
                                        print(
                                            "aewregfdsfgdaf - value : ${value}");
                                        value.forEach((element) {
                                          var rElement = {
                                            'actionName': element['name'],
                                            'docId': customUserInfo.docId,
                                            'pos': lessonActionList.length,
                                            'lessonDate': lessonDateArg,
                                            'totalNote': "",
                                            'grade': '50',
                                            'uid': customUserInfo.uid,
                                            'apratusName': element['apparatus'],
                                            'timestamp': null,
                                            'name': customUserInfo.name,
                                            'phoneNumber':
                                                customUserInfo.phoneNumber,
                                            'id': null,
                                            'noteSelected': false,
                                            'position': element['name'],
                                            'deleteSelected': true,
                                          };
                                          print("rElement : ${rElement}");
                                          lessonActionList.add(rElement);
                                          txtEdtCtrlrList
                                              .add(new TextEditingController());
                                          txtEdtCtrlrList[txtEdtCtrlrList
                                                          .length -
                                                      1]
                                                  .selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset: txtEdtCtrlrList[
                                                              txtEdtCtrlrList
                                                                      .length -
                                                                  1]
                                                          .text
                                                          .length));
                                        });
                                      }

                                      return value;
                                    });

                                    /* additionalActionlength = result.length
                                            .toInt() -
                                        totalNoteTextFieldDocId.length.toInt();

                                    print(
                                        "추가된 동작 개수 : ${additionalActionlength.toString()}");

                                    // 동작추가시에 textcontroller 추가 생성
                                    createControllers(additionalActionlength); */

                                    print("동작추가시컨트롤러:${totalNoteControllers}");
                                    print(
                                        "동작추가시노트아이디:${totalNoteTextFieldDocId}");

                                    lessonService.notifyListeners();
                                  },
                                ),
                                const SizedBox(height: 20),

                                // 손재형 재정렬 가능한 리스트 시작 => 동작 목록 리스트
                                ReorderableListView.builder(
                                    padding: EdgeInsets.only(bottom: 100),
                                    onReorder: (oldIndex, newIndex) {
                                      if (newIndex > oldIndex) {
                                        newIndex -= 1;
                                      }
                                      /* final movedActionList =
                                          lessonActionList.removeAt(oldIndex);
                                      lessonActionList.insert(
                                          newIndex, movedActionList); */

                                      final movedActionList =
                                          lessonActionList.removeAt(oldIndex);
                                      lessonActionList.insert(
                                          newIndex, movedActionList);
                                    },
                                    physics: BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: lessonActionList.length,
                                    itemBuilder: (context, index) {
                                      Key? valueKey;

                                      lessonActionList[index]['pos'] = index;
                                      valueKey = ValueKey(index);

                                      final doc = lessonActionList[index];
                                      print("동작 목록 리스트 - doc : ${doc}");

                                      String uid = doc['uid']; // 강사 고유번호

                                      String name = doc['name']; //회원이름
                                      String phoneNumber = doc[
                                          'phoneNumber']; // 회원 고유번호 (전화번호로 회원 식별)
                                      String apratusName =
                                          doc['apratusName']; //기구이름
                                      String actionName =
                                          doc['actionName']; //동작이름
                                      String lessonDate =
                                          doc['lessonDate']; //수업날짜
                                      String grade = doc['grade']; //수행도
                                      String totalNote =
                                          doc['totalNote']; //수업총메모
                                      int pos = doc['pos']; //수업총메모
                                      bool isSelected = doc['noteSelected'];

                                      return GestureDetector(
                                        key: valueKey,
                                        onHorizontalDragUpdate: (details) {
                                          int sensitivity = 8;
                                          if (details.delta.dx > sensitivity) {
                                            // right swipe
                                            print(
                                                "GestureDetector right swipe");
                                            lessonActionList[index]
                                                ['deleteSelected'] = true;
                                          } else if (details.delta.dx <
                                              -sensitivity) {
                                            // left swipe
                                            print("GestureDetector left swipe");
                                            lessonActionList[index]
                                                ['deleteSelected'] = false;
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: LessonActionListTile(
                                                  actionName: actionName,
                                                  apparatus: apratusName,
                                                  position: getActionPosition(
                                                      apratusName,
                                                      actionName,
                                                      globalVariables
                                                          .actionList),
                                                  name: name,
                                                  phoneNumber: phoneNumber,
                                                  lessonDate: lessonDate,
                                                  grade: grade,
                                                  totalNote: totalNote,
                                                  docId: userInfo.docId,
                                                  memberdocId: userInfo.docId,
                                                  uid: uid,
                                                  pos: pos,
                                                  isSelected: isSelected,
                                                  isSelectable: true,
                                                  isDraggable: true,
                                                  customFunctionOnTap: () {
                                                    doc['noteSelected'] =
                                                        !doc['noteSelected'];
                                                    txtEdtCtrlrList[index]
                                                        .text = totalNote;
                                                    String tmp =
                                                        txtEdtCtrlrList[index]
                                                            .text;
                                                  }),
                                            ),
                                            Offstage(
                                              offstage: lessonActionList[index]
                                                  ['deleteSelected'],
                                              child: IconButton(
                                                onPressed: () {
                                                  // 노트편집 화면의 경우 기존 목록에서 동작을 삭제하는 경우 생길 수 있어서, 삭제이벤트 발생시 docId 수집
                                                  getDeleteTargetDocId(index);
                                                  lessonActionList
                                                      .removeAt(index);
                                                  int i = 0;
                                                  lessonActionList
                                                      .forEach((element) {
                                                    element['pos'] = i;
                                                    i++;
                                                  });
                                                  setState(() {});
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Palette.statusRed,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                /* FutureBuilder<QuerySnapshot>(
                                    future: lessonService.readNotesOflessonDate(
                                      user.uid,
                                      customUserInfo.docId,
                                      lessonDateController.text,
                                    ),
                                    builder: (context, snapshot) {
                                      print("재정렬 기능 시작");
                                      final docs =
                                          snapshot.data?.docs ?? []; // 문서들 가져오기
                                          
                                      if (docs.isEmpty) {
                                        actionNullCheck = true;
                                        print(
                                            '문서 비워져 있을경우 ActionNullCheck : ${actionNullCheck}');

                                        // 이전 값들 초기화
                                        //초기화
                                        tmpLessonInfoList.clear();
                                        for (var i = 0;
                                            i < tmpLessonInfoList.length;
                                            ++i) {
                                          print(
                                              "tmpLessonInfoList[${i}].docId : ${tmpLessonInfoList[i].docId}");
                                        }
                                        totalNoteTextFieldDocId.clear();

                                        print(
                                            "total노트 : ${totalNoteTextFieldDocId}");

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 40),
                                          child: Center(
                                            child: Text(
                                              "동작을 추가해 주세요.",
                                              style: TextStyle(
                                                  color: Palette.gray99),
                                            ),
                                            // child: CircularProgressIndicator(
                                            //   color: Palette.buttonOrange,
                                            // ),
                                          ),
                                        );
                                      } else {
                                        actionNullCheck = false;
                                        print(
                                            '문서가 있는 경우 actionNullCheck : ${actionNullCheck}');

                                        // //reorderable 드래그시 그림자/디자인 조정
                                        // Widget proxyDecorator(
                                        //     Widget child,
                                        //     int index,
                                        //     Animation<double> animation) {
                                        //   return AnimatedBuilder(
                                        //     animation: animation,
                                        //     builder: (BuildContext context,
                                        //         Widget? child) {
                                        //       return Material(
                                        //         //elevation: 0,
                                        //         color: Colors.transparent,
                                        //         //shadowColor: Palette.buttonOrange,

                                        //         child: child,
                                        //       );
                                        //     },
                                        //     child: child,
                                        //   );
                                        // }

                                        //초기화
                                        totalNoteTextFieldDocId =
                                            List<String>.filled(docs.length, "",
                                                growable: true);

                                        TmpLessonInfo tmpLessonInfo =
                                            TmpLessonInfo(
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          true,
                                        );

                                        tmpLessonInfoList =
                                            List<TmpLessonInfo>.filled(
                                                docs.length, tmpLessonInfo,
                                                growable: true);

                                        return Column(
                                          children: [
                                            
                                            ReorderableListView.builder(
                                              itemCount: docs.length,
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              //buildDefaultDragHandles: false,
                                              onReorder: ((oldIndex, newIndex) {
                                                if (newIndex > docs.length)
                                                  newIndex = docs.length;
                                                if (oldIndex < newIndex)
                                                  newIndex -= 1;
                                                docs.insert(newIndex,
                                                    docs.removeAt(oldIndex));
                                                totalNoteControllers.insert(
                                                    newIndex,
                                                    totalNoteControllers
                                                        .removeAt(oldIndex));
                                                //재정렬에 따른 컨트롤러, totalNote DocId, tmp 저장
                                                // totalNoteTextFieldDocId.insert(
                                                //     newIndex,
                                                //     totalNoteTextFieldDocId
                                                //         .removeAt(oldIndex));
                                                //재정렬에 따른 컨트롤러, totalNote DocId, tmp 저장
                                                // tmpLessonInfoList.insert(
                                                //     newIndex,
                                                //     tmpLessonInfoList
                                                //         .removeAt(oldIndex));

                                                for (int pos = 0;
                                                    pos < docs.length;
                                                    pos++) {
                                                  lessonService.updatePos(
                                                      docs[pos].id, pos);
                                                }

                                                //setState(() {});
                                              }),

                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                final doc = docs[index];
                                                print('에러포인트시작 : ${index}');

                                                totalNoteTextFieldDocId[index] =
                                                    doc.id;

                                                print(
                                                    "total노트 : ${totalNoteTextFieldDocId}");

                                                //일괄 textfeild 저장하기 위해 docID저장
                                                //예외처리 ::
                                                // if ((totalNoteTextFieldDocId.length -
                                                //         1) >=
                                                //     index) {
                                                //   totalNoteTextFieldDocId[index] =
                                                //       doc.id;
                                                //   flagIndexErr = true;
                                                // } else {
                                                //   flagIndexErr = false;
                                                // }
                                                // print(
                                                //     '에러방지실행 : ${flagIndexErr},${totalNoteTextFieldDocId.length},${index}');

                                                // print('에러포인트끝 : ${index}');

                                                String uid =
                                                    doc.get('uid'); // 강사 고유번호

                                                String name =
                                                    doc.get('name'); //회원이름
                                                String phoneNumber = doc.get(
                                                    'phoneNumber'); // 회원 고유번호 (전화번호로 회원 식별)
                                                String apratusName = doc
                                                    .get('apratusName'); //기구이름
                                                String actionName = doc
                                                    .get('actionName'); //동작이름
                                                String lessonDate = doc
                                                    .get('lessonDate'); //수업날짜
                                                String grade =
                                                    doc.get('grade'); //수행도
                                                String totalNote = doc
                                                    .get('totalNote'); //수업총메모

                                                print(
                                                    "[LA] 사용자 id tmpLessonInfo에 저장 : ${customUserInfo.docId}");

                                                tmpLessonInfo = TmpLessonInfo(
                                                  customUserInfo.docId,
                                                  apratusName,
                                                  actionName,
                                                  name,
                                                  lessonDate,
                                                  grade,
                                                  totalNote,
                                                  doc.id,
                                                  uid,
                                                  true,
                                                );

                                                tmpLessonInfoList[index] =
                                                    tmpLessonInfo;

                                                // if (tmpLessonInfoList.isEmpty) {
                                                //   tmpLessonInfoList
                                                //       .add(tmpLessonInfo);
                                                // } else {
                                                //   addTmpInfoList(tmpLessonInfoList,
                                                //       tmpLessonInfo);
                                                // }
                                                for (var i = 0;
                                                    i <
                                                        tmpLessonInfoList
                                                            .length;
                                                    ++i) {
                                                  print(
                                                      "${tmpLessonInfoList[i].docId}");
                                                }
                                                print(
                                                    "InfoList에 내용 추가 : 길이${tmpLessonInfoList.length.toString()}");
                                                //tmpLessonInfoList.add(tmpLessonInfo);

                                                //print(
                                                //    "tmpLessonInfoList:${tmpLessonInfoList[index]}");
                                                //totalNotes[index] =
                                                //    doc.get('totalNote'); //수업총메모
                                                String lessonDateTrim = " ";
                                                String apratusNameTrim = " ";
                                                int pos = doc.get('pos'); //순서
                                                // 날짜 글자 자르기
                                                if (lessonDate.length > 0) {
                                                  lessonDateTrim = lessonDate
                                                      .substring(2, 10);
                                                }
                                                // 기구 첫두글자 자르기
                                                if (apratusName.length > 0) {
                                                  apratusNameTrim = apratusName
                                                      .substring(0, 2);
                                                }

                                                // 첫 화면에서

                                                // ScaffoldMessenger.of(context)
                                                //     .showSnackBar(SnackBar(
                                                //   content: Text(
                                                //       "텍스트필드!!${initStateTextfield}"),
                                                // ));
                                                // print(
                                                //     '텍스트필드채움 : ActionSelectMode-${ActionSelectMode}');

                                                // totalNoteControllers[index].text =
                                                //     totalNote;

                                                // if (initStateTextfield) {
                                                //   //예외처리 ::
                                                //   if (totalNoteTextFieldDocId.length >
                                                //       index) {
                                                //     totalNoteControllers[index].text =
                                                //         totalNote;
                                                //   }

                                                //   if (index == (docs.length - 1)) {
                                                //     if (initStateTextfieldCnt > 2) {
                                                //       initStateTextfield = false;
                                                //       initStateTextfieldCnt = 0;
                                                //     } else {
                                                //       initStateTextfieldCnt++;
                                                //     }
                                                //     print(
                                                //         '이제안바꿔 : ${initStateTextfield}');
                                                //   }
                                                // }
                                                return Column(
                                                  key: ValueKey(doc),
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          //color: Colors.red.withOpacity(0),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 10,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            10.0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            10.0),
                                                                  ),
                                                                  color: Palette
                                                                      .titleOrange
                                                                  //color: Colors.red.withOpacity(0),
                                                                  ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              //top: 5,
                                                              //bottom: 5,
                                                              left: 10.0,
                                                              right: 10.0,
                                                            ),
                                                            child: SizedBox(
                                                              height: 40,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .drag_handle_outlined,
                                                                    color: Palette
                                                                        .gray33,
                                                                    size: 20.0,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    apratusNameTrim,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    actionName,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14.0,
                                                                    ),
                                                                  ),
                                                                  Spacer(
                                                                      flex: 1),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        barrierDismissible:
                                                                            true,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text(
                                                                              '삭제',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                            ),
                                                                            content:
                                                                                Text('동작을 삭제하시겠습니까?', style: TextStyle(fontSize: 14)),
                                                                            actions: <Widget>[
                                                                              TextButton(
                                                                                onPressed: () async {
                                                                                  await lessonService.deleteSinglelesson(
                                                                                      uid: uid,
                                                                                      memberId: customUserInfo.docId,
                                                                                      docId: doc.id,
                                                                                      lessonDate: lessonDate,
                                                                                      onSuccess: () {
                                                                                        totalNoteControllers.removeAt(index);
                                                                                        //totalNoteTextFieldDocId.removeAt(index);
                                                                                        //tmpLessonInfoList.removeAt(index);

                                                                                        //print("삭제시시컨트롤러:${totalNoteControllers}");
                                                                                        //print("삭제시노트아이디:${totalNoteTextFieldDocId}");
                                                                                      },
                                                                                      onError: () {});
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: Text(
                                                                                  '삭제',
                                                                                  style: TextStyle(fontSize: 16),
                                                                                ),
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: Text(
                                                                                  '취소',
                                                                                  style: TextStyle(fontSize: 16, color: Palette.textRed),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .remove_circle,
                                                                      color: Palette
                                                                          .statusRed,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 1,
                                                          color: Palette.grayEE,
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  true,
                                                              // ignore: unnecessary_new
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(10.0))),
                                                                  //title: Text('일별 메모 작성'),
                                                                  content:
                                                                      Builder(
                                                                    builder:
                                                                        (context) {
                                                                      // Get available height and width of the build area of this widget. Make a choice depending on the size.
                                                                      var height = MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height;
                                                                      var width = MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width;
                                                                      totalNoteControllers[index]
                                                                              .text =
                                                                          totalNote;

                                                                      return Container(
                                                                        //height:
                                                                        //    40,
                                                                        width: width -
                                                                            100,
                                                                        child:
                                                                            PopupTextField(
                                                                          customController:
                                                                              totalNoteControllers[index],
                                                                          hint:
                                                                              "동작별 메모",
                                                                          showArrow:
                                                                              false,
                                                                          customFunction:
                                                                              () async {
                                                                            //일별 노트 저장
                                                                            await totalNoteSingleSave(
                                                                                lessonService,
                                                                                totalNoteTextFieldDocId[index],
                                                                                totalNoteControllers[index].text,
                                                                                context,
                                                                                index);
                                                                          },
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  actions: <
                                                                      Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        '취소',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        print(
                                                                            "[LA] 동작별메모 저장 : totalNoteTextFieldDocId[index] / totalNoteControllers[index].text");
                                                                        //동작별 노트 저장
                                                                        await totalNoteSingleSave(
                                                                            lessonService,
                                                                            totalNoteTextFieldDocId[index],
                                                                            totalNoteControllers[index].text,
                                                                            context,
                                                                            index);
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        '저장',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Container(
                                                            //height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              10.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10.0),
                                                                    ),
                                                                    color: Palette
                                                                        .grayFA
                                                                    //color: Colors.red.withOpacity(0),
                                                                    ),
                                                            //color: Palette.grayEE,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      25,
                                                                      5,
                                                                      10,
                                                                      5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  totalNote
                                                                          .isEmpty
                                                                      ? Text(
                                                                          "동작별 메모를 남겨보세요.",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14.0,
                                                                            //fontWeight:
                                                                            //FontWeight.bold,
                                                                            color:
                                                                                Palette.gray99,
                                                                          ))
                                                                      : Text(
                                                                          ""),
                                                                  //SizedBox(width: 20),
                                                                  Expanded(
                                                                    child: Text(
                                                                      totalNote,
                                                                      // overflow:
                                                                      //     TextOverflow
                                                                      //         .fade,
                                                                      maxLines:
                                                                          10,
                                                                      softWrap:
                                                                          true,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyText1!
                                                                          .copyWith(
                                                                            fontSize:
                                                                                14.0,
                                                                            height:
                                                                                1.6, //줄간격
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  //Spacer(flex: 1),
                                                                  Icon(
                                                                    Icons
                                                                        .mode_edit,
                                                                    color: Palette
                                                                        .gray66,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                      ;
                                    }), 

                                const SizedBox(height: 30),*/
                              ]),
                            ),

                            /// 저장버튼 추가버튼 UI 수정
                            ElevatedButton(
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
                                child: Text("저장하기",
                                    style: TextStyle(fontSize: 16)),
                              ),
                              onPressed: () async {
                                print(
                                    "[LA] 저장버튼실행 actionNullCheck : ${actionNullCheck}/todayNoteView : ${todayNoteView}");

                                // 수업일, 동작선택, 필수 입력
                                if ((todayNoteController.text.trim().isEmpty) &&
                                    lessonActionList
                                        .where((element) =>
                                            element['noteSelected'])
                                        .isEmpty) {
                                  //오늘의 노트가 없는 경우, 노트 생성 및 동작 노트들 저장
                                  //await todayNoteSave(
                                  //    lessonService, customUserInfo, context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content:
                                        Text("일별노트 또는 동작선택중 하나는 필수입력해주세요."),
                                  ));
                                } else {
                                  print(
                                      "[LA] 노트저장 DateChangeMode : ${DateChangeMode}/todayNoteView : ${todayNoteView} / checkInitState : ${checkInitState}");
                                  DateChangeMode = false;

                                  print(
                                      "[LA] 일별메모 저장 : todayNotedocId ${todayNotedocId} ");

                                  //일별 노트 저장
                                  /* await todayNoteSave(
                                      lessonService, customUserInfo, context); */

                                  // await totalNoteSave(
                                  //     lessonService, customUserInfo, context);
                                  saveMethod(
                                      lessonService,
                                      lessonDateArg,
                                      lessonAddMode,
                                      customUserInfo,
                                      dayLessonService);

                                  lessonService.notifyListeners();
                                  Navigator.pop(context);
                                }
                              },
                            ),

                            const SizedBox(height: 10),
                            lessonAddMode == "노트편집"
                                ? DeleteButton(
                                    actionNullCheck: actionNullCheck,
                                    todayNotedocId: todayNotedocId,
                                    lessonService: lessonService,
                                    dayLessonService: dayLessonService,
                                    totalNoteTextFieldDocId:
                                        totalNoteTextFieldDocId,
                                  )
                                : const SizedBox(height: 15),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          //bottomNavigationBar: BaseBottomAppBar(),
        );
      },
    );
  }

  void getDeleteTargetDocId(int index) {
    print(
        "getDeleteTargetDocId - index : ${index}, lessonActionList[index]['docId'] : ${lessonActionList[index]['docId']}, lessonActionList[index]['id'] : ${lessonActionList[index]['id']}");
    deleteTargetDocIdLiet.add(lessonActionList[index]['id']);
  }

  void saveMethod(
      LessonService lessonService,
      String lessonDateArg,
      String lessonAddMode,
      CustomUserInfo.UserInfo customUserInfo,
      DayLessonService dayLessonService) {
    for (int i = 0; i < lessonActionList.length; i++) {
      /* print(
          "llllllllllll -- lessonActionList.length : ${lessonActionList.length}");
      print("llllllllllll -- lessonActionList[$i] : ${lessonActionList[i]}"); */
      /* print(
          "tllllllllllll -- xtEdtCtrlrList[$i].text : ${txtEdtCtrlrList[i].text}"); */
      if (lessonActionList.isNotEmpty && lessonAddMode == "노트편집") {
        print(
            "tllllllllllll  자자자! 노트편집!!! -- xtEdtCtrlrList[$i].text : ${txtEdtCtrlrList[i].text}");
        print(
            "lessonActionList[i]['totalNote'] : ${lessonActionList[i]['totalNote']}");
        lessonActionList[i]['totalNote'] = txtEdtCtrlrList[i].text;
        String tmp = txtEdtCtrlrList[i].text;

        print(
            "lessonActionList[i]['id'] == null? : ${lessonActionList[i]['id'] == null}");
        if (lessonActionList[i]['id'] == null) {
          lessonService.create(
            docId: lessonActionList[i]['docId'],
            uid: lessonActionList[i]['uid'],
            name: lessonActionList[i]['name'],
            phoneNumber: lessonActionList[i]['phoneNumber'],
            apratusName: lessonActionList[i]['apratusName'],
            actionName: lessonActionList[i]['actionName'],
            lessonDate: lessonDateArg,
            grade: '50',
            totalNote: txtEdtCtrlrList[i].text.trim(),
            onSuccess: () {},
            onError: () {},
          );
        } else {
          lessonService.updateLessonActionNote(
              lessonActionList[i]['id'],
              lessonActionList[i]['docId'],
              lessonActionList[i]['actionName'],
              lessonActionList[i]['apratusName'],
              lessonActionList[i]['grade'],
              lessonActionList[i]['lessonDate'],
              lessonActionList[i]['name'],
              lessonActionList[i]['phoneNumber'],
              lessonActionList[i]['pos'],
              lessonActionList[i]['timestamp'],
              lessonActionList[i]['totalNote'],
              lessonActionList[i]['uid']);
        }
      } else if (lessonActionList.isNotEmpty && lessonAddMode == "노트 추가") {
        print(
            "tllllllllllll 자자자 노트 추가!! -- xtEdtCtrlrList[$i].text : ${txtEdtCtrlrList[i].text}");
        lessonService.create(
          docId: lessonActionList[i]['docId'],
          uid: lessonActionList[i]['uid'],
          name: lessonActionList[i]['name'],
          phoneNumber: lessonActionList[i]['phoneNumber'],
          apratusName: lessonActionList[i]['apratusName'],
          actionName: lessonActionList[i]['actionName'],
          lessonDate: lessonDateArg,
          grade: '50',
          totalNote: txtEdtCtrlrList[i].text.trim(),
          onSuccess: () {},
          onError: () {},
        );
      } else {
        print(
            "tllllllllllll 자자자 그외 뭔가!! -- xtEdtCtrlrList[$i].text : ${txtEdtCtrlrList[i].text}");
      }
    }
    deleteTargetDocIdLiet.forEach((element) {
      print("deleted actions docId : element : ${element}");
      lessonService.delete(docId: element, onSuccess: () {}, onError: () {});
    });

    // print("ppppppppp - todayNoteController.text.trim() : ${todayNoteController.text.trim()}, todayNoteView : ${todayNoteView}");
    if (todayNoteController.text.trim().isNotEmpty) {
      if (lessonAddMode == "노트편집") {
        dayLessonList[0][0]['todayNote'] = todayNoteController.text.trim();
        print(
            "ppppppppp - dayLessonList[0]['id'] : ${dayLessonList[0][0]['id']}");
        daylessonService.updateDayNote(
          dayLessonList[0][0]['id'],
          dayLessonList[0][0]['docId'],
          dayLessonList[0][0]['lessonDate'],
          dayLessonList[0][0]['name'],
          dayLessonList[0][0]['todayNote'],
          dayLessonList[0][0]['uid'],
        );
      } else if (lessonAddMode == "노트 추가") {
        print("xmxmxmxmxmxmxmxmx - customUserInfo : ${customUserInfo}");
        dayLessonService.creatDayNote(
          customUserInfo.docId,
          lessonDateArg,
          customUserInfo.name,
          todayNoteController.text,
          customUserInfo.uid,
        );
      }
    }
  }

  Future<void> totalNoteSave(LessonService lessonService,
      CustomUserInfo.UserInfo customUserInfo, BuildContext context) async {
    if (todayNotedocId == "") {
      // 동작별 노트 업데이트
      for (int idx = 0; idx < totalNoteTextFieldDocId.length; idx++) {
        await lessonService.updateTotalNote(
          totalNoteTextFieldDocId[idx],
          totalNoteControllers[idx].text,
        );
      }
      // for (int idx = 0;
      await lessonService.createTodaynote(
          docId: customUserInfo.docId,
          uid: customUserInfo.uid,
          name: customUserInfo.name,
          lessonDate: lessonDateController.text,
          todayNote: todayNoteController.text,
          isRefresh: true,
          onSuccess: () {
            // 저장하기 성공
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("새로운 노트 작성"),
            ));
            lessonService.notifyListeners();

            // 저장하기 성공시 MemberInfo로 이동, 뒤로가기
            Navigator.pop(context);
          },
          onError: () {
            print("저장하기 ERROR");
          });
    } else {
      print("문서가 있는 경우.. 노트 저장");

      // 동작별 노트 업데이트
      for (int idx = 0; idx < totalNoteTextFieldDocId.length; idx++) {
        await lessonService.updateTotalNote(
          totalNoteTextFieldDocId[idx],
          totalNoteControllers[idx].text,
        );
      }

      await lessonService.updateTodayNote(
          docId: todayNotedocId,
          todayNote: todayNoteController.text,
          onSuccess: () {
            // 저장하기 성공
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("노트수정 완료"),
            ));
            // 저장하기 성공시 MemberInfo로 이동, 뒤로가기
            Navigator.pop(context);
          },
          onError: () {
            print("저장하기 ERROR");
          });
    }
  }
}

Future<void> totalNoteSingleSave(
  LessonService lessonService,
  String totalNoteTextFieldDocId,
  String totalNote,
  BuildContext context,
  int index,
) async {
  await lessonService.updateTotalNote(
    totalNoteTextFieldDocId,
    totalNote,
  );
  totalNoteControllers[index].clear();
  Navigator.pop(context);
  lessonService.notifyListeners();
}

Future<void> todayNoteSave(LessonService lessonService,
    CustomUserInfo.UserInfo customUserInfo, BuildContext context) async {
  if (todayNotedocId == "") {
    print(
        "[LA] todayNoteSave 새노트생성 ${lessonDateController.text} / ${todayNoteController.text}");
    // for (int idx = 0;
    await lessonService.createTodaynote(
        docId: customUserInfo.docId,
        uid: customUserInfo.uid,
        name: customUserInfo.name,
        lessonDate: lessonDateController.text,
        todayNote: todayNoteController.text,
        isRefresh: true,
        onSuccess: () {
          // 저장하기 성공
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("일별노트 저장"),
          ));
          //todayNoteController.clear();
          // Navigator.pop(context);
          //lessonService.notifyListeners();
        },
        onError: () {
          print("저장하기 ERROR");
        });
  } else {
    print(
        "[LA] todayNoteSave 노트수정 ${todayNotedocId} / ${lessonDateController.text} / ${todayNoteController.text}");

    await lessonService.updateTodayNote(
        docId: todayNotedocId,
        todayNote: todayNoteController.text,
        onSuccess: () {
          // 저장하기 성공
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("일별노트 수정"),
          ));

          // 저장하기 성공시 MemberInfo로 이동, 뒤로가기
          // Navigator.pop(context);
        },
        onError: () {
          print("저장하기 ERROR");
        });
  }
}

//Textfield 생성
void createControllers(length) {
  DynamicController dynamicController;
  TextEditingController tmpTextEditingController;
  for (var i = 0; i < length; i++) {
    dynamicController = DynamicController("dynamicController-${i}");
    tmpTextEditingController = dynamicController.dynamicController;
    totalNoteControllers.add(tmpTextEditingController);
  }
}

//Textfield 생성
clearTotalNoteControllers() {
  //print('before:${totalNoteControllers}');
  for (var i = 0; i < totalNoteControllers.length; ++i) {
    totalNoteControllers[i].clear();
  }
  totalNoteControllers.clear();
  //totalNoteControllers = [];
  //print('after:${totalNoteControllers}');
}

//Textfield 생성
deleteControllers() {
  //print('before:${totalNoteControllers}');
  // for (var i = 0; i < totalNoteControllers.length; ++i) {
  //   totalNoteControllers[i].dispose();
  // }
  totalNoteControllers = [];
  //print('after:${totalNoteControllers}');
}

class DynamicController {
  DynamicController(this.dynamicClassName);
  TextEditingController dynamicController = TextEditingController();
  String dynamicClassName = "";
}

// 삭제버튼
class DeleteButton extends StatefulWidget {
  const DeleteButton({
    Key? key,
    required this.actionNullCheck,
    required this.todayNotedocId,
    required this.lessonService,
    required this.dayLessonService,
    required this.totalNoteTextFieldDocId,
  }) : super(key: key);

  final bool actionNullCheck;
  final String todayNotedocId;
  final LessonService lessonService;
  final DayLessonService dayLessonService;
  final List<String> totalNoteTextFieldDocId;

  @override
  State<DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
      ),
      child: Container(
          alignment: Alignment.center,
          width: 260,
          height: 50,
          child: Text("삭제하기",
              style: TextStyle(fontSize: 16, color: Palette.textRed))),
      onPressed: () async {
        // create bucket
        final retvaldelte = await showAlertDialog(context, '정말로 삭제하시겠습니까?',
            '해당 노트의 전체 내용이 삭제됩니다. 삭제된 내용은 이후 복구가 불가능합니다.');
        if (retvaldelte == "OK") {
          lessonActionList.forEach((element) {
            widget.lessonService
                .delete(docId: element['id'], onSuccess: () {}, onError: () {});
          });

          dayLessonList.forEach((element) {
            widget.dayLessonService.delete(
                docId: element[0]['id'], onSuccess: () {}, onError: () {});
          });

          /* if (widget.actionNullCheck) {
            print(
                "전체삭제 - 오늘노트삭제 : actionNullCheck - ${widget.actionNullCheck} / ${todayNotedocId}");
            await widget.lessonService.deleteTodayNote(
              docId: todayNotedocId,
              onSuccess: () {},
              onError: () {},
            );
          } else {
            print("전체삭제 - 오늘노트클리어 : ${todayNotedocId} ");
            await widget.lessonService.clearTodayNote(
              docId: todayNotedocId,
              onSuccess: () {},
              onError: () {},
            );
          }

          //간헐적으로 동작노트들이 삭제 되지 않는 경우가 있어 일괄삭제 batch방식 적용
          print("전체삭제 - 동작별 노트삭제 : ${totalNoteTextFieldDocId} ");
          await widget.lessonService.deleteMultilessonBatch(
            docIds: totalNoteTextFieldDocId,
            onSuccess: () {},
            onError: () {},
          ); */

          // for (int idx = 0; idx < totalNoteTextFieldDocId.length; idx++) {

          //   await widget.lessonService.deleteMultilesson(
          //     docId: totalNoteTextFieldDocId[idx],
          //     onSuccess: () {},
          //     onError: () {},
          //   );

          // }
          // 삭제하기 성공시 MemberList로 이동
          widget.lessonService.notifyListeners(); // 화면 갱신
          Navigator.pop(context);
        }

        //if (showAlertDialog(context) == "OK"){
        //
      },
    );
  }
}

void initInpuWidget({
  required String uid,
  required String docId,
  required LessonService lessonService,
}) async {
  todayNoteController.text = "";
  clearTotalNoteControllers();
  totalNoteTextFieldDocId.clear();
  tmpLessonInfoList.clear();
  todayNotedocId = "";
  todayNoteView = "";
  DateChangeMode = false;

  print(
      "[LA] 수업일변경 - initInpuWidget/초기화 : ${todayNoteController} / ${totalNoteTextFieldDocId} / ${tmpLessonInfoList}");

  lessonDate = lessonDateController.text;

  int lenssonData = await lessonService.countPos(
    uid,
    docId,
    lessonDateController.text,
  );

  //Textfield 생성
  createControllers(lenssonData);

  print(
      "[LA] 수업일변경 - initInpuWidget/재생성 totalNoteControllers${totalNoteControllers} / totalNoteTextFieldDocId${totalNoteTextFieldDocId} / tmpLessonInfoList${tmpLessonInfoList})");
  print("[LA] 수업일변경 - notifyListeners / ${checkInitState}");
  lessonService.notifyListeners();
  // 에러 발생해서 정리..
//     The following assertion was thrown while dispatching notifications for TextEditingController:
// setState() or markNeedsBuild() called during build.
  // setState(() {
  //   sliderValue = 50;
  // });
}

// Future<void> refreshLessonDate({
//   required String uid,
//   required String docId,
//   required LessonService lessonService,
// }) async {
//   print("REFRESH!!!");
//   //now = DateFormat("yyyy-MM-dd").format(DateTime.now());
//   lessonDate = lessonDateController.text;
//   print("Date : ${lessonDate}");

//   int lenssonData = await lessonService.countPos(
//     uid,
//     docId,
//     lessonDateController.text,
//   );

//   //Textfield 생성
//   createControllers(lenssonData);
//   //노트 삭제를 위한 변수 초기화

//   print("초기화시컨트롤러:${totalNoteControllers}");
//   print("초기화시노트아이디:${totalNoteTextFieldDocId}");
// }

void addTmpInfoList(
    List<TmpLessonInfo> tmpLessonInfoList, TmpLessonInfo tmpLessonInfo) {
  bool isNew = true;
  for (int i = 0; i < tmpLessonInfoList.length; i++) {
    if (tmpLessonInfoList[i].docId == tmpLessonInfo.docId) {
      isNew = false;
    }
  }
  if (isNew) {
    tmpLessonInfoList.add(tmpLessonInfo);
  }
}
