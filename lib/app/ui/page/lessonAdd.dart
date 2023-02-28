import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/controller/importSequence_controller.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/app/data/provider/daylesson_service.dart';
import 'package:web_project/app/data/provider/memberTicket_service.dart';
import 'package:web_project/app/data/provider/sequenceCustom_service.dart';
import 'package:web_project/app/data/provider/sequenceRecent_service.dart';
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

import '../../data/provider/auth_service.dart';
import '../../data/model/color.dart';
import '../../function/globalFunction.dart';
import '../widget/globalWidget.dart';
import 'memberInfo.dart';

String now = DateFormat("yyyy-MM-dd").format(DateTime.now());

TextEditingController lessonDateController = TextEditingController(text: now);
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

bool isSequenceSaveChecked = false;
bool isTicketCountChecked = true;

bool isFirst = true;

List lessonActionList = [];
List dayLessonList = [];

List notedActionWidget = [];
List<String> notedActionsList = [];
List deleteTargetDocIdLiet = [];

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

    txtEdtCtrlrList = [];
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

    txtEdtCtrlrList = [];
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
    int ticketCountLeft = argsList[7];
    int ticketCountAll = argsList[8];

    print(
        '[LA] 시작 checkInitState - ${checkInitState} / DateChange - ${DateChangeMode} / actionNullCheck - ${actionNullCheck}');
    print(
        "[LA] 노트 관련 ${lessonDate} / ${lessonAddMode} / tmpLessonInfoList ${tmpLessonInfoList.length}");

    if (checkInitState) {
      print("INIT!!! : ${checkInitState}, DateChange:${DateChangeMode}");

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

    return Consumer5<LessonService, DayLessonService, MemberTicketService,
        SequenceRecentService, SequenceCustomService>(
      builder: (context, lessonService, dayLessonService, memberTicketService,
          sequenceRecentService, sequenceCustomService, child) {
        print(
            "customUserInfo.uid : ${customUserInfo.uid}, customUserInfo.docId :  ${customUserInfo.docId} lessonDateArg : ${lessonDateArg}");
        if (lessonActionList.isEmpty && lessonAddMode == "노트편집") {
          lessonService
              .readDateMemberActionNote(
                  customUserInfo.uid, customUserInfo.docId, lessonDateArg)
              .then((value) {
            print("ppppppppp - value : ${value}");
            lessonActionList.addAll(value);

            lessonActionList.forEach((element) {
              txtEdtCtrlrList.add(new TextEditingController());
            });

            // setState(() {}); // 여기서 setState 호출하면 무한 획귀 오류 발생 하기도 함
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

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("일별노트 또는 동작선택중 하나는 필수입력해주세요."),
                      ));
                    } else {
                      print(
                          "[LA] 노트저장 DateChangeMode : ${DateChangeMode}/todayNoteView : ${todayNoteView} / checkInitState : ${checkInitState}");
                      DateChangeMode = false;

                      print("[LA] 일별메모 저장 : todayNotedocId ${todayNotedocId} ");

                      print(
                          "!!!!!!!!!!!!!!!!! 완료버튼 - saveMethod START! : ${isTicketCountChecked}");
                      saveMethod(lessonService, lessonDateArg, lessonAddMode,
                          customUserInfo, dayLessonService);

                      String membetTicketId = "";
                      globalVariables.memberTicketList.forEach((element) {
                        if (element['isSelected'] == true) {
                          membetTicketId = element['id'];
                        }
                      });
                      // 멤버 티켓 정보 업데이트 => 수강권 차감 여부 체크시, 남은 횟 수 1회 차감,
                      print(
                          "!!!!!!!!!!!!!!!!! ticketCountLeft : ${ticketCountLeft}");
                      isTicketCountChecked
                          ? memberTicketService.updateTicketCountLeft(
                              userInfo.uid,
                              membetTicketId,
                              userInfo.docId,
                              ticketCountLeft - 1,
                              ticketCountAll - (ticketCountLeft - 1),
                            )
                          : null;
                      print(
                          "!!!!!!!!!!!!!!!!! ticketCountLeft - 1 : ${ticketCountLeft - 1}");

                      saveRecentSequence(
                          sequenceRecentService,
                          userInfo.uid,
                          userInfo.docId,
                          todayNoteController.text,
                          lessonActionList,
                          false,
                          0,
                          Timestamp.now(),
                          userInfo.name);
                      isSequenceSaveChecked
                          ? saveCustomSequnce(
                              sequenceCustomService,
                              userInfo.uid,
                              userInfo.docId,
                              todayNoteController.text,
                              lessonActionList,
                              false,
                              0,
                              Timestamp.now(),
                              userInfo.name,
                              sequenceNameController.text,
                            )
                          : null;

                      lessonService.notifyListeners();
                      Navigator.pop(context, lessonActionList);
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
                                              isTicketCountChecked
                                                  ? "${ticketCountLeft - 1}"
                                                  : '$ticketCountLeft',
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
                                              "$ticketCountAll",
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

                                              /// 리턴 시작

                                              Container(
                                            constraints:
                                                BoxConstraints(minHeight: 80),
                                            child: Container(
                                              child: TextFormField(
                                                onChanged: (value) {
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
                                                      final doc =
                                                          lessonActionList[
                                                              index];

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
                                                                  backgroundColor:
                                                                      Palette
                                                                          .titleOrange,
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
                                                            Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      minHeight:
                                                                          70),
                                                              child:
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
                                                                  txtEdtCtrlrList[index]
                                                                          .selection =
                                                                      TextSelection.fromPosition(TextPosition(
                                                                          offset: txtEdtCtrlrList[index]
                                                                              .text
                                                                              .length));
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
                                                                      '이번 수업에서 주목할 동작에 대해 남겨보세요.',
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
                                                                    fontSize:
                                                                        14),
                                                              ),
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
                                      ),
                                    ),
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
                                    hintStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Palette.gray00),
                                    border: InputBorder.none),
                              ),
                            ),

                            /// 시퀀스 영역 시작
                            Container(
                              width: MediaQuery.of(context).size.height * 0.8,
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
                                    globalVariables.actionList.forEach(
                                      (element) {
                                        element['actionSelected'] = false;
                                      },
                                    );

                                    var result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ActionSelector(),
                                        fullscreenDialog: true,
                                        // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                                        settings: RouteSettings(
                                          arguments: [
                                            customUserInfo,
                                            currentAppratus,
                                            lessonDate,
                                            checkInitState,
                                            totalNote,
                                            tmpLessonInfoList,
                                          ],
                                        ),
                                      ),
                                    ).then((value) {
                                      if (value != null) {
                                        print(
                                            "aewregfdsfgdaf - value : ${value}");
                                        value.forEach(
                                          (element) {
                                            var rElement = {
                                              'actionName': element['name'],
                                              'docId': customUserInfo.docId,
                                              'pos': lessonActionList.length,
                                              'lessonDate': lessonDateArg,
                                              'totalNote': "",
                                              'grade': '50',
                                              'uid': customUserInfo.uid,
                                              'apratusName':
                                                  element['apparatus'],
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
                                            txtEdtCtrlrList.add(
                                                new TextEditingController());
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
                                          },
                                        );
                                      }

                                      return value;
                                    });

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
                                            // print("GestureDetector right swipe");
                                            lessonActionList[index]
                                                ['deleteSelected'] = true;
                                          } else if (details.delta.dx <
                                              -sensitivity) {
                                            // left swipe
                                            // print("GestureDetector left swipe");
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
                                                  position: globalFunction
                                                      .getActionPosition(
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
                                                    print(
                                                        "asdfsdfsfsgfdg delete call!! index ${index}");
                                                    int tmpPos = 0;
                                                    lessonActionList
                                                        .removeAt(index);
                                                    lessonActionList
                                                        .forEach((element) {
                                                      element['pos'] = tmpPos;
                                                      tmpPos++;
                                                    });
                                                    deleteTargetDocIdLiet.add(
                                                        lessonActionList[index]
                                                            ['id']);
                                                    setState(() {});
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Palette.statusRed,
                                                  )),
                                            )
                                          ],
                                        ),
                                      );
                                    }),
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
                                saveRecentSequence(
                                  sequenceRecentService,
                                  userInfo.uid,
                                  userInfo.docId,
                                  todayNoteController.text,
                                  lessonActionList,
                                  false,
                                  0,
                                  Timestamp.now(),
                                  userInfo.name,
                                );
                                isSequenceSaveChecked
                                    ? saveCustomSequnce(
                                        sequenceCustomService,
                                        userInfo.uid,
                                        userInfo.docId,
                                        todayNoteController.text,
                                        lessonActionList,
                                        false,
                                        0,
                                        Timestamp.now(),
                                        userInfo.name,
                                        sequenceNameController.text,
                                      )
                                    : null;
                                print(
                                    "[LA] 저장버튼실행 actionNullCheck : ${actionNullCheck}/todayNoteView : ${todayNoteView}");

                                // 수업일, 동작선택, 필수 입력
                                if ((todayNoteController.text.trim().isEmpty) &&
                                    lessonActionList
                                        .where((element) =>
                                            element['noteSelected'])
                                        .isEmpty) {
                                  //오늘의 노트가 없는 경우, 노트 생성 및 동작 노트들 저장

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

                                  print(
                                      "!!!!!!!!!!!!!!!!! 저장하기 - saveMethod START : ${isTicketCountChecked}");
                                  saveMethod(
                                      lessonService,
                                      lessonDateArg,
                                      lessonAddMode,
                                      customUserInfo,
                                      dayLessonService);

                                  String membetTicketId = "";
                                  globalVariables.memberTicketList
                                      .forEach((element) {
                                    if (element['isSelected'] == true) {
                                      membetTicketId = element['id'];
                                    }
                                  });
                                  // 멤버 티켓 정보 업데이트 => 수강권 차감 여부 체크시, 남은 횟 수 1회 차감,
                                  print(
                                      "!!!!!!!!!!!!!!!!! isTicketCountChecked : ${isTicketCountChecked}");
                                  isTicketCountChecked
                                      ? memberTicketService
                                          .updateTicketCountLeft(
                                          userInfo.uid,
                                          membetTicketId,
                                          userInfo.docId,
                                          ticketCountLeft - 1,
                                          ticketCountAll -
                                              (ticketCountLeft - 1),
                                        )
                                      : null;

                                  lessonService.notifyListeners();
                                  Navigator.pop(context, lessonActionList);
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
        );
      },
    );
  }

  void getDeleteTargetDocId(int index) {
    print(
        "getDeleteTargetDocId - index : ${index}, lessonActionList[index]['docId'] : ${lessonActionList[index]['docId']}, lessonActionList[index]['id'] : ${lessonActionList[index]['id']}");
    deleteTargetDocIdLiet.add(lessonActionList[index]['id']);
  }

  void saveRecentSequence(
    SequenceRecentService sequenceRecentService,
    String uid,
    String memberId,
    String todayNote,
    List actionList, // List -> Json
    bool isfavorite, // 즐겨찾는 시퀀스 (추후 추가 가능성)
    int like, // 좋아요 수 (추후 추가 가능성)
    Timestamp timeStamp, // 꺼내 쓸 때 변환해서 씀
    String username,
  ) {
    var now = DateTime.now();
    String sequenceTitle =
        username + "님 " + DateFormat("yyyy-MM-dd HH:MM").format(now);
    sequenceRecentService.create(uid, memberId, todayNote, actionList,
        isfavorite, like, timeStamp, sequenceTitle);
  }

  void saveCustomSequnce(
    SequenceCustomService sequenceCustomService,
    String uid,
    String memberId,
    String todayNote,
    List actionList, // List -> Json
    bool isfavorite, // 즐겨찾는 시퀀스 (추후 추가 가능성)
    int like, // 좋아요 수 (추후 추가 가능성)
    Timestamp timeStamp, // 꺼내 쓸 때 변환해서 씀
    String username,
    String sequenceTitle,
  ) {
    var now = DateTime.now();

    ImportSequenceController importSequenceController =
        ImportSequenceController();
    importSequenceController.createCustomSequence(uid, memberId, todayNote,
        actionList, isfavorite, like, Timestamp.now(), sequenceTitle);
  }

  int i = 0;
  void saveMethod(
      LessonService lessonService,
      String lessonDateArg,
      String lessonAddMode,
      CustomUserInfo.UserInfo customUserInfo,
      DayLessonService dayLessonService) {
    print("asdfsdfsfsgfdg - saveMethod CALLED!! => ${i}");
    lessonActionList.forEach((element) {
      print("asdfsdfsfsgfdg -${element['actionName']} : ${element['pos']}");
    });
    for (int i = 0; i < lessonActionList.length; i++) {
      if (lessonActionList.isNotEmpty && lessonAddMode == "노트편집") {
        lessonActionList[i]['totalNote'] = txtEdtCtrlrList[i].text;
        String tmp = txtEdtCtrlrList[i].text;
        if (lessonActionList[i]['id'] == null) {
          print("asdfsdfsfsgfdg - 1");
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
          print("asdfsdfsfsgfdg - 2");
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
              txtEdtCtrlrList[i].text.trim(),
              lessonActionList[i]['uid']);
        }
      } else if (lessonActionList.isNotEmpty && lessonAddMode == "노트 추가") {
        print("asdfsdfsfsgfdg - 3");
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
        print("asdfsdfsfsgfdg - 4");
      }
    }
    deleteTargetDocIdLiet.forEach((element) {
      print("deleted actions docId : element : ${element}");
      lessonService.delete(docId: element, onSuccess: () {}, onError: () {});
    });
    deleteTargetDocIdLiet = [];
    if (todayNoteController.text.trim().isNotEmpty) {
      if (lessonAddMode == "노트편집") {
        print("asdfsdfsfsgfdg - 5");
        dayLessonList[0][0]['todayNote'] = todayNoteController.text.trim();
        daylessonService.updateDayNote(
          dayLessonList[0][0]['id'],
          dayLessonList[0][0]['docId'],
          dayLessonList[0][0]['lessonDate'],
          dayLessonList[0][0]['name'],
          dayLessonList[0][0]['todayNote'],
          dayLessonList[0][0]['uid'],
        );
      } else if (lessonAddMode == "노트 추가") {
        print("asdfsdfsfsgfdg - 6");
        dayLessonService.creatDayNote(
          customUserInfo.docId,
          lessonDateArg,
          customUserInfo.name,
          todayNoteController.text,
          customUserInfo.uid,
        );
      }
    }

    String ticketId = "";
    globalVariables.memberTicketList
            .where((element) => element['isSelect'] == true)
            .isNotEmpty
        ? globalVariables.memberTicketList.forEach((element) {
            if (element['isSelected'] == true &&
                element['memberId'] == userInfo.docId) {
              ticketId = element['id'];
            }
          })
        : ticketId = "";

    ticketId != ""
        ? dayLessonService.updateTicketUsedById(
            dayLessonList[0][0]['id'], isTicketCountChecked, ticketId)
        : null;
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
  for (var i = 0; i < totalNoteControllers.length; ++i) {
    totalNoteControllers[i].clear();
  }
  totalNoteControllers.clear();
}

//Textfield 생성
deleteControllers() {
  totalNoteControllers = [];
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
          widget.lessonService.notifyListeners(); // 화면 갱신
          Navigator.pop(context);
        }
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
}

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
