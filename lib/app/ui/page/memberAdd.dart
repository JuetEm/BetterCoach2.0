import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/provider/member_service.dart';
import 'package:web_project/app/ui/page/memberTicketManage.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/ui/widget/ticketWidget.dart';
import 'package:web_project/app/data/model/userInfo.dart'
    as CustomUserInfo; // 다른 페키지와 클래스 명이 겹치는 경우 alias 선언해서 사용
import 'package:web_project/app/data/model/userInfo.dart';

import 'actionSelector.dart';
import '../../data/provider/auth_service.dart';
import '../widget/baseTableCalendar.dart';
import '../../data/model/color.dart';
import '../../function/globalFunction.dart';
import '../widget/globalWidget.dart';
import 'memberInfo.dart';
import 'memberList.dart';
import 'membershipList.dart';

String memberAddMode = "추가";

bool initState = true;

late CustomUserInfo.UserInfo? customUserInfo;

final goalList = [
  "체형교정",
  "자세개선",
  "다이어트",
  "유연성 향상",
  "운동능력 향상",
  "통증개선",
  "재활",
  "건강증진",
  "바디라인개선",
  "산전필라테스",
  "산후필라테스",
  "키성장",
  "골프필라테스",
  "바프촬영",
  "기타"
];
List<String> selectedGoals = [];
List<Color> goalTileColorList = [];
List<Color> goalTextColorList = [];

final bodyAnalyzedList = [
  "거북목",
  "일자목",
  "라운드 숄더",
  "어깨 불균형",
  "플랫백",
  "흉추측만",
  "요추측만",
  "스웨이백",
  "척추전만",
  "척추후만",
  "골반틀어짐",
  "O 다리",
  "X 다리",
  "요족",
  "평발",
];
List<String> selelctedAnalyzedList = [];
List<Color> bodyTileColorList = [];
List<Color> bodyTextColorList = [];

final medicalHistoryList = [
  "목",
  "어깨",
  "골반",
  "팔꿈치",
  "손목",
  "허리",
  "고관절",
  "무릎",
  "발목",
  "기타"
];
List<String> selectedHistoryList = [];
List<Color> historyTileColorList = [];
List<Color> historyTextColorList = [];

String pageTitle = "회원등록";

GlobalFunction globalFunction = GlobalFunction();

String now = DateFormat("yyyy-MM-dd").format(DateTime.now());
TextEditingController nameController = TextEditingController();
TextEditingController registerDateController = TextEditingController(text: now);
TextEditingController phoneNumberController = TextEditingController();
TextEditingController registerTypeController = TextEditingController();
TextEditingController goalController = TextEditingController();
TextEditingController bodyAnalyzeController = TextEditingController();
TextEditingController medicalHistoryController = TextEditingController();
TextEditingController infoController = TextEditingController();
TextEditingController noteController = TextEditingController();
TextEditingController commentController = TextEditingController();

FocusNode nameFocusNode = FocusNode();
FocusNode registerDateFocusNode = FocusNode();
FocusNode phoneNumberFocusNode = FocusNode();
FocusNode registerTypeFocusNode = FocusNode();
FocusNode memberShipFocusNode = FocusNode();
FocusNode goalFocusNode = FocusNode();
FocusNode bodyAnalyzeFocusNode = FocusNode();
FocusNode medicalHistoryFocusNode = FocusNode();
FocusNode commentFocusNode = FocusNode();

bool keyboardOpenBefore = false;

List resultMemberList = [];
List resultActionList = [];

class MemberAdd extends StatefulWidget {
  const MemberAdd({super.key});

  @override
  State<MemberAdd> createState() => _MemberAddState();
}

class _MemberAddState extends State<MemberAdd> {
  @override
  void dispose() {
    // TODO: implement dispose
    //selectedGoals.clear();
    //selelctedAnalyzedList.clear();
    //selectedHistoryList.clear();

    initState = true;
    print("[MA] Dispose : initState ${initState} ");
    super.dispose();
  }

  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser()!;

    final argsList =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    memberAddMode = argsList[0];

    print(
        "[MA]시작 : memberAddMode - ${memberAddMode} / initState - ${initState}");
    print("resultActionList : ${resultActionList}");

    if (memberAddMode == "수정" && initState == true) {
      // 이전 화면에서 보낸 변수 받기
      customUserInfo = argsList[1];
      print(
          "[MA]회원수정 정보 받아오기 - customUserInfo.selectedGoals / ${customUserInfo?.selectedGoals}");

      print(
          "MemberAdd : customUserInfo.selectedBodyAnalyzed : ${customUserInfo?.selectedBodyAnalyzed}");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        nameController.text = customUserInfo!.name;
        registerDateController.text = customUserInfo!.registerDate;
        phoneNumberController.text = customUserInfo!.phoneNumber;
        registerTypeController.text = customUserInfo!.registerType;
        goalController.text = customUserInfo!.goal;
        infoController.text = customUserInfo!.info;
        noteController.text = customUserInfo!.note;
        commentController.text = customUserInfo!.comment;
        medicalHistoryController.text = customUserInfo!.medicalHistories;
        bodyAnalyzeController.text = customUserInfo!.bodyAnalyzed;
      });

      initState = false;
      //에러 제어하기 위해 추가.https://github.com/flutter/flutter/issues/17647

      selectedGoals = customUserInfo!.selectedGoals;
      selelctedAnalyzedList = customUserInfo!.selectedBodyAnalyzed;
      selectedHistoryList = customUserInfo!.selectedMedicalHistories;

      print(
          "[MA]변수받아오기 : selectedGoals - ${customUserInfo!.selectedGoals} / ${customUserInfo!.selectedBodyAnalyzed} / ${customUserInfo!.selectedMedicalHistories}");
    } else if (memberAddMode == "추가" && initState == true) {
      resultMemberList = argsList[1];
      resultActionList = argsList[2];
      // 이전 화면에서 보낸 변수 받기
      print("[MA] : 신규추가 등록일 오늘로 설정 memberAddMode - ${memberAddMode}");
      registerDateController.text = now;
      selectedGoals = [];
      selelctedAnalyzedList = [];
      selectedHistoryList = [];
      initState = false;
    }

    // selectedGoals 값 반영하여 FilterChips 동적 생성
    var goalChips = [];
    goalChips = makeChips(goalChips, selectedGoals, Palette.backgroundOrange);

    // selelctedAnalyzedList 값 반영하여 FilterChips 동적 생성
    var bodyAnalyzedChips = [];
    bodyAnalyzedChips =
        makeChips(bodyAnalyzedChips, selelctedAnalyzedList, Palette.grayEE);

    // medicalHistoryList 값 반영하여 FilterChips 동적 생성
    var medicalHistoriesChips = [];
    medicalHistoriesChips = makeChips(
        medicalHistoriesChips, selectedHistoryList, Palette.backgroundBlue);

    String imgUrl =
        "https://newsimg.hankookilbo.com/cms/articlerelease/2021/01/07/0de90f3e-d3fa-452e-a471-aa0bec4a1252.jpg";

    if (memberAddMode == "추가") {
      pageTitle = "회원등록";
    } else {
      pageTitle = "회원정보수정";
    }
    return Consumer<MemberService>(
      builder: (context, memberService, child) {
        // if (MediaQuery.of(context).viewInsets.bottom == 0) {
        //   if (keyboardOpenBefore) {
        //     FocusScopeNode currentFocus = FocusScope.of(context);
        //     if (!currentFocus.hasPrimaryFocus) {
        //       currentFocus.unfocus();
        //     } // 키보드 닫기 이벤트
        //     keyboardOpenBefore = false;
        //   }
        // } else {
        //   keyboardOpenBefore = true;
        // }
        return Scaffold(
          backgroundColor: Palette.secondaryBackground,
          appBar: BaseAppBarMethod(context, pageTitle, () {
            if (memberAddMode == "수정") {
              List tmpResultList = [];
              tmpResultList.add(customUserInfo);
              tmpResultList.add(resultMemberList);
              tmpResultList.add(resultActionList);
              Navigator.pop(context, tmpResultList);
            } else {
              List tmpResultList = [];
              tmpResultList.add(resultMemberList);
              tmpResultList.add(resultActionList);

              Navigator.pop(context, tmpResultList);
            }

            globalFunction.clearTextEditController([
              nameController,
              registerDateController,
              phoneNumberController,
              registerTypeController,
              goalController,
              bodyAnalyzeController,
              medicalHistoryController,
              infoController,
              noteController,
              commentController,
            ]);
            registerDateController.text = now;
          }, null, null),
          body: CenterConstrainedBody(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(0),
                // padding: EdgeInsets.only(
                //     bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    /// 압력기본정보
                    Container(
                      color: Palette.mainBackground,
                      padding: const EdgeInsets.all(20),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '기본정보',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.gray00,
                                  ),
                                ),
                                Text('*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Palette.buttonOrange,
                                    ))
                              ],
                            ),

                            SizedBox(height: 10),
                            Divider(height: 1),
                            SizedBox(height: 10),

                            /// 이름 입력창
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Palette.gray99,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: BaseTextField(
                                    customController: nameController,
                                    customFocusNode: nameFocusNode,
                                    hint: "회원명(9자 이하)",
                                    showArrow: false,
                                    customFunction: () {},
                                    maxLength: 10,
                                  ),
                                ),
                              ],
                            ),

                            /// 등록일 입력창
                            Container(
                              child: Material(
                                color: Palette.mainBackground,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    globalFunction.getDateFromCalendar(
                                        context,
                                        registerDateController,
                                        "등록일",
                                        registerDateController.text);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Palette.gray99,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            textAlign: TextAlign.start,
                                            enabled: false,
                                            maxLines: null,
                                            controller: registerDateController,
                                            focusNode: registerDateFocusNode,
                                            autofocus: true,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: '등록일을 선택하세요.',
                                              hintStyle: TextStyle(
                                                  color: Palette.gray99,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            style: TextStyle(
                                              color: Palette.gray00,
                                            ),
                                          ),
                                        ),
                                        Text('등록일 선택하기',
                                            style: TextStyle(
                                                color: Palette.gray99)),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          color: Palette.gray99,
                                          size: 16,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            /// 전화번호 입력창
                            Row(
                              children: [
                                Icon(
                                  Icons.call,
                                  color: Palette.gray99,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: BaseTextField(
                                    customController: phoneNumberController,
                                    customFocusNode: phoneNumberFocusNode,
                                    hint: "전화번호",
                                    showArrow: false,
                                    customFunction: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// 입력창_수강정보
                    Container(
                      color: Palette.mainBackground,
                      padding: const EdgeInsets.all(20),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /// Title

                            Row(
                              children: [
                                Text(
                                  '수강정보',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.gray00,
                                  ),
                                ),
                                Spacer(),
                                // Text(
                                //   '추가',
                                //   style: TextStyle(
                                //     fontSize: 14,
                                //     color: Palette.gray00,
                                //   ),
                                // ),
                                // SizedBox(width: 10)
                              ],
                            ),

                            SizedBox(height: 10),
                            Divider(height: 1),
                            SizedBox(height: 10),

                            /// 수강권 추가
                            Container(
                              alignment: Alignment.center,

                              /// bool 수강권 유무 체크하는 변수 필요
                              /// is수강권있니? = false로 선언 되어야 함.
                              child: false
                                  ? TicketWidget(
                                      ticketTitle: "재등록 수강권",
                                      ticketDescription:
                                          "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔",
                                      ticketStartDate: "2023.01.14",
                                      ticketEndDate: "2023.02.13",
                                      ticketCountAll: 20,
                                      ticketCountLeft: 13,
                                      isAlive: true,
                                      // function OnTap 기능을 붙여주세요
                                      customFunctionOnTap: () {},
                                      // customFunctionOnTap: () async {
                                      //   print("수강권 추가 onTap!!");
                                      //   var result = await // 저장하기 성공시 Home로 이동
                                      //       Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             TicketManage.getUserInfo(
                                      //                 userInfo)),
                                      //   ).then((value) {
                                      //     print("수강권 추가 result");
                                      //     setState(() {
                                      //       print(
                                      //           "memberInfo then setState called!");
                                      //     });
                                      //     parent?.setState(() {
                                      //       print(
                                      //           "memberInfo then parent setState called!");
                                      //     });
                                      //   });
                                      // },
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                                width: 2,
                                                color: Palette.grayEE)),
                                        child: InkWell(
                                          onTap: () {
                                            /// 비워둔 온탭입니다. 기능을 붙여주세요
                                          },
                                          // onTap: () async {
                                          //   print("수강권 추가 onTap!!");
                                          //   var result =
                                          //       await // 저장하기 성공시 Home로 이동
                                          //       Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             TicketManage.getUserInfo(
                                          //                 userInfo)),
                                          //   ).then((value) {
                                          //     print("수강권 추가 result");
                                          //     setState(() {
                                          //       print(
                                          //           "memberInfo then setState called!");
                                          //     });
                                          //     parent?.setState(() {
                                          //       print(
                                          //           "memberInfo then parent setState called!");
                                          //     });
                                          //   });
                                          // },
                                          child: Container(
                                            width: 280,
                                            height: 140,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "수강권 추가하기",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Palette.gray99),
                                                ),
                                                Icon(
                                                  Icons.add_circle_outline,
                                                  color: Palette.gray99,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// ### 이전 수강정보 부분은 나중에 삭제하는걸루 ###

                    /*
                    /// 입력창_수강정보
                    Container(
                      color: Palette.mainBackground,
                      padding: const EdgeInsets.all(20),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /// Title
          
                            Row(
                              children: [
                                Text(
                                  '수강정보',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.gray00,
                                  ),
                                ),
                                Spacer(),
                                // Text(
                                //   '추가',
                                //   style: TextStyle(
                                //     fontSize: 14,
                                //     color: Palette.gray00,
                                //   ),
                                // ),
                                // SizedBox(width: 10)
                              ],
                            ),
          
                            SizedBox(height: 10),
                            Divider(height: 1),
                            SizedBox(height: 10),
          
                            /// 등록횟수입력창
                            BaseTextField(
                              customController: registerTypeController,
                              customFocusNode: registerTypeFocusNode,
                              hint: "등록횟수입력",
                              showArrow: true,
                              customFunction: () {
                                String lessonCount = registerTypeController.text;
                                showModalBottomSheet<void>(
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  backgroundColor: Colors.white,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      padding: const EdgeInsets.all(30),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                                width: double.infinity,
                                                alignment: Alignment.topLeft,
                                                child: const Text(
                                                  '수강일을 입력해주세요.',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Palette.gray00,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            SizedBox(height: 10),
          
                                            BaseTextField(
                                              customController:
                                                  membershipController,
                                              customFocusNode:
                                                  memberShipFocusNode,
                                              hint: "횟수입력",
                                              showArrow: false,
                                              customFunction: () {},
                                            ),
          
                                            SizedBox(height: 10),
          
                                            /// 수강권 선택 버튼
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30.0),
                                                ),
                                                elevation: 0,
                                                backgroundColor:
                                                    Palette.buttonOrange,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                        horizontal: 90),
                                                child: Text("확인",
                                                    style:
                                                        TextStyle(fontSize: 16)),
                                              ),
                                              onPressed: () {
                                                final authService =
                                                    context.read<AuthService>();
                                                final user =
                                                    authService.currentUser()!;
                                                print("확인 버튼");
                                                // create bucket
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text("횟수 입력 성공"),
                                                ));
                                                // 저장하기 성공시 Home로 이동
                                                Navigator.pop(context,
                                                    membershipController.text);
          
                                                registerTypeController.text =
                                                    membershipController.text;
          
                                                membershipController.text = "";
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
          
                                // _getMembership(context, lessonCount);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    */

                    /// 입력창_운동목표
                    Container(
                      color: Palette.mainBackground,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /// Title
                            /// 운동 목표
                            customGoalGridView(
                                context,
                                goalController,
                                "운동목표",
                                "목표를 선택해주세요.",
                                goalList,
                                selectedGoals,
                                goalTileColorList,
                                goalTextColorList),

                            Divider(height: 1),
                            SizedBox(height: 10),

                            Offstage(
                              offstage: selectedGoals.isEmpty,
                              child: Container(
                                height: 30,
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (final chip in goalChips)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              4.0, 0, 4, 0),
                                          child: chip,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// 운동목표 입력창
                            BaseTextField(
                              customController: goalController,
                              customFocusNode: goalFocusNode,
                              hint: "기타 특이사항이 있다면 작성해주세요.",
                              showArrow: false,
                              customFunction: () {},
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// 체형 분석
                    Container(
                      color: Palette.mainBackground,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /// 체형분석
                            customBodyGridView(
                              context,
                              bodyAnalyzeController,
                              "체형분석",
                              "체형 특이사항을 선택해주세요.",
                              bodyAnalyzedList,
                              selelctedAnalyzedList,
                              bodyTileColorList,
                              bodyTextColorList,
                            ),

                            Divider(height: 1),
                            SizedBox(height: 10),

                            /// 칩들
                            Offstage(
                              //offstage: false,
                              offstage: selelctedAnalyzedList.isEmpty,
                              child: Container(
                                height: 30,
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (final chip in bodyAnalyzedChips)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              4.0, 0, 4, 0),
                                          child: chip,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// 체형분석 입력창
                            BaseTextField(
                              customController: bodyAnalyzeController,
                              customFocusNode: bodyAnalyzeFocusNode,
                              hint: "기타 특이사항이 있다면 작성해주세요.",
                              showArrow: false,
                              customFunction: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// 통증/상해/병력
                    Container(
                      color: Palette.mainBackground,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /// 통증/상해/병력
                            customMedicalHistoryGridView(
                                context,
                                medicalHistoryController,
                                "통증/상해/병력",
                                "통증/상해 부위를 선택해주세요.",
                                medicalHistoryList,
                                selectedHistoryList,
                                historyTileColorList,
                                historyTextColorList),

                            Divider(height: 1),
                            SizedBox(height: 10),

                            Offstage(
                              offstage: selectedHistoryList.isEmpty,
                              child: Container(
                                height: 30,
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (final chip in medicalHistoriesChips)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              4.0, 0, 4, 0),
                                          child: chip,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// 통증/상해/병력 입력창
                            BaseTextField(
                              customController: medicalHistoryController,
                              customFocusNode: medicalHistoryFocusNode,
                              hint: "기타 특이사항이 있다면 작성해주세요.",
                              showArrow: false,
                              customFunction: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// 입력창_특이사항
                    Container(
                      color: Palette.mainBackground,
                      padding: const EdgeInsets.all(20),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /// Title

                            Row(
                              children: [
                                Text(
                                  '특이사항',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.gray00,
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),

                            SizedBox(height: 10),
                            Divider(height: 1),
                            SizedBox(height: 10),

                            /// 특이사항 입력창
                            BaseTextField(
                              customController: commentController,
                              customFocusNode: commentFocusNode,
                              hint: "회원님의 특이사항을 입력하세요",
                              showArrow: false,
                              customFunction: () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// 추가 버튼
                    SizedBox(height: 40),
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
                        child: Text("저장하기", style: TextStyle(fontSize: 16)),
                      ),
                      onPressed: () async {
                        if (memberAddMode == "추가") {
                          print("추가 버튼");
                          // create bucket
                          if (globalFunction.textNullCheck(
                              context, nameController, "이름")) {
                            customUserInfo = null;
                            // globalFunction.textNullCheck(
                            //     context, registerDateController, "등록일") &&
                            // globalFunction.textNullCheck(
                            //     context, phoneNumberController, "전화번호") &&
                            // globalFunction.textNullCheck(
                            //     context, registerTypeController, "등록횟수입력") &&
                            // globalFunction.textNullCheck(
                            //     context, goalController, "운동목표") &&
                            // globalFunction.textNullCheck(
                            //     context, infoController, "통증/상해/병력") &&
                            // globalFunction.textNullCheck(
                            //     context, noteController, "체형분석")) {
                            var docId = await memberService
                                .create(
                                    name: nameController.text,
                                    registerDate: registerDateController.text,
                                    phoneNumber: phoneNumberController.text,
                                    registerType: registerTypeController.text,
                                    goal: goalController.text,
                                    selectedGoals: selectedGoals,
                                    bodyAnalyzed: bodyAnalyzeController.text,
                                    selectedBodyAnalyzed: selelctedAnalyzedList,
                                    medicalHistories:
                                        medicalHistoryController.text,
                                    selectedMedicalHistories:
                                        selectedHistoryList,
                                    info: infoController.text,
                                    note: noteController.text,
                                    comment: commentController.text,
                                    uid: user.uid,
                                    onSuccess: () {
                                      // 저장하기 성공
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("저장하기 성공"),
                                      ));
                                    },
                                    onError: () {
                                      print("저장하기 ERROR");
                                    })
                                .then((value) {
                              print("value : ${value}");
                              customUserInfo = UserInfo(
                                  value,
                                  user.uid,
                                  nameController.text,
                                  registerDateController.text,
                                  phoneNumberController.text,
                                  registerTypeController.text,
                                  goalController.text,
                                  selectedGoals,
                                  bodyAnalyzeController.text,
                                  selelctedAnalyzedList,
                                  medicalHistoryController.text,
                                  selectedHistoryList,
                                  infoController.text,
                                  noteController.text,
                                  commentController.text,
                                  true,
                                  false);
                            }).onError((error, stackTrace) {
                              print("error : ${error}");
                              print("stackTrace : ${stackTrace}");
                            }).whenComplete(() async {
                              print("whenComplete is called");
                              List tmpResultList = [];
                              List updatedList = [];
                              await memberService
                                  .readMemberListAtFirstTime(user.uid)
                                  .then((value) {
                                updatedList.addAll(value);
                              });
                              tmpResultList.add(updatedList);
                              tmpResultList.add(resultActionList);
                              Navigator.pop(context, tmpResultList);

                              globalFunction.clearTextEditController([
                                nameController,
                                registerDateController,
                                phoneNumberController,
                                registerTypeController,
                                goalController,
                                bodyAnalyzeController,
                                medicalHistoryController,
                                infoController,
                                noteController,
                                commentController,
                              ]);
                              registerDateController.text = now;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("항목을 모두 입력해주세요."),
                            ));
                          }
                        } else {
                          /// 수정처리(업데이트)
                          if (globalFunction.textNullCheck(
                              context, nameController, "이름")) {
                            memberService.update(
                                docId: customUserInfo!.docId,
                                name: nameController.text,
                                registerDate: registerDateController.text,
                                phoneNumber: phoneNumberController.text,
                                registerType: registerTypeController.text,
                                goal: goalController.text,
                                selectedGoals: selectedGoals,
                                bodyAnalyzed: bodyAnalyzeController.text,
                                selectedBodyAnalyzed: selelctedAnalyzedList,
                                medicalHistories: medicalHistoryController.text,
                                selectedMedicalHistories: selectedHistoryList,
                                info: infoController.text,
                                note: noteController.text,
                                comment: commentController.text,
                                uid: customUserInfo!.uid,
                                onSuccess: () async {
                                  // 저장하기 성공
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text("저장하기 성공"),
                                  ));

                                  //userinfoupdate.mid = nameController.text;

                                  //List<UserInfo> userupdateInfo
                                  UserInfo userInfouUpdate = UserInfo(
                                      customUserInfo!.docId,
                                      customUserInfo!.uid,
                                      nameController.text,
                                      registerDateController.text,
                                      phoneNumberController.text,
                                      registerTypeController.text,
                                      goalController.text,
                                      selectedGoals,
                                      bodyAnalyzeController.text,
                                      selelctedAnalyzedList,
                                      medicalHistoryController.text,
                                      selectedHistoryList,
                                      infoController.text,
                                      noteController.text,
                                      commentController.text,
                                      true,
                                      false);

                                  //memberInfo.notifyListeners();
                                  // 저장하기 성공시 MemberInfo로 이동
                                  List tmpResultList = [];
                                  List updatedList = [];
                                  await memberService
                                      .readMemberListAtFirstTime(user.uid)
                                      .then((value) {
                                    updatedList.addAll(value);
                                  });
                                  tmpResultList.add(userInfouUpdate);
                                  tmpResultList.add(updatedList);
                                  tmpResultList.add(resultActionList);
                                  Navigator.pop(context, tmpResultList
                                      // MaterialPageRoute(
                                      //   builder: (context) => MemberInfo(),
                                      //   // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                                      //   settings: RouteSettings(
                                      //     arguments: userInfouUpdate,
                                      //   ),
                                      // ),
                                      );

                                  globalFunction.clearTextEditController([
                                    nameController,
                                    registerDateController,
                                    phoneNumberController,
                                    registerTypeController,
                                    goalController,
                                    bodyAnalyzeController,
                                    medicalHistoryController,
                                    infoController,
                                    noteController,
                                    commentController,
                                  ]);
                                },
                                onError: () {
                                  print("저장하기 ERROR");
                                });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("항목을 모두 입력해주세요."),
                            ));
                          }
                        }
                      },
                    ),

                    Offstage(
                      offstage: (memberAddMode == "추가"),
                      child: Column(
                        children: [
                          /// 삭제 버튼
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text("삭제하기",
                                  style: TextStyle(
                                      fontSize: 16, color: Palette.textRed)),
                            ),
                            onPressed: () async {
                              print("${customUserInfo!.docId}");
                              // create bucket
                              final retvaldelte =
                                  await showAlertDialog(context);
                              if (retvaldelte == "OK") {
                                memberService.delete(
                                    docId: customUserInfo!.docId,
                                    onSuccess: () {
                                      // 삭제하기 성공
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("삭제하기 성공"),
                                      ));

                                      //userinfoupdate.mid = nameController.text;

                                      // 삭제하기 성공시 MemberList로 이동
                                      Navigator.pop(context);
                                      //Navigator.of(context)
                                      //    .popUntil((route) => route.isFirst);

                                      // Navigator.pushReplacement(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //       builder: (context) => MemberList()),
                                      // );

                                      globalFunction.clearTextEditController([
                                        nameController,
                                        registerDateController,
                                        phoneNumberController,
                                        registerTypeController,
                                        goalController,
                                        bodyAnalyzeController,
                                        medicalHistoryController,
                                        infoController,
                                        noteController,
                                        commentController,
                                      ]);
                                    },
                                    onError: () {
                                      print("삭제하기 ERROR");
                                    });
                              }

                              //if (showAlertDialog(context) == "OK"){
                              //
                            },
                          ),
                        ],
                      ),
                    ),

                    /// 취소버튼
                    SizedBox(height: 6),
                    TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            foregroundColor: Palette.gray00,
                            textStyle:
                                TextStyle(fontWeight: FontWeight.normal)),
                        onPressed: () {
                          /// Pop 함수 입력
                          if (memberAddMode == "수정") {
                            print(
                                "MemberAdd : 취소하고 나가기 : customUserInfo.selectedBodyAnalyzed : ${customUserInfo!.selectedBodyAnalyzed}");
                            Navigator.pop(context, customUserInfo);
                          } else {
                            Navigator.pop(context);
                            globalFunction.clearTextEditController([
                              nameController,
                              registerDateController,
                              phoneNumberController,
                              registerTypeController,
                              goalController,
                              bodyAnalyzeController,
                              medicalHistoryController,
                              infoController,
                              noteController,
                              commentController,
                            ]);
                          }
                        },
                        child: Text(
                          '취소하고 나가기',
                          selectionColor: Palette.gray00,
                        )),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          //bottomNavigationBar: BaseBottomAppBar(),
        );
      },
    );
  }

  List<dynamic> makeChips(List<dynamic> resultChips, List<String> targetList,
      Color chipBackgroundColor) {
    if (targetList.isNotEmpty) {
      resultChips = targetList
          .map((e) => FilterChip(
                label: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(e),
                    SizedBox(width: 1),
                    Icon(
                      Icons.close_outlined,
                      size: 14,
                      color: targetList.contains(e)
                          ? Palette.gray00
                          : Palette.gray99,
                    )
                  ],
                ),
                onSelected: ((value) {
                  setState(() {
                    targetList.remove(e);
                  });
                  print("value : ${value}");
                }),
                selected: targetList.contains(e),
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: targetList.contains(e)
                        ? Palette.gray00
                        : Palette.gray99),
                selectedColor: chipBackgroundColor,
                backgroundColor: Colors.transparent,
                showCheckmark: false,
                side: targetList.contains(e)
                    ? BorderSide.none
                    : BorderSide(color: Palette.grayB4),
              ))
          .toList();
    }
    print("[MA] makeChips : ${resultChips}");
    return resultChips;
  }

  Row customGoalGridView(
      BuildContext context,
      TextEditingController customController,
      String bigTitle,
      String bottomSheetTitle,
      List<String> objectList,
      List<String> resultObjectList,
      List<Color> customTileColorList,
      List<Color> customBorderColorList) {
    return Row(
      children: [
        Text(
          bigTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Palette.gray00,
          ),
        ),
        Spacer(),
        IconButton(
            onPressed: () async {
              print("신규 동작 추가");
              showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Palette.secondaryBackground,
                  context: context,
                  builder: ((context) {
                    return StatefulBuilder(
                        builder: (context, StateSetter stateSetter) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        bottomSheetTitle,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Palette.gray00,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      print(
                                          "resultObjectList : ${resultObjectList}");
                                      // String goalsSum = "";
                                      // for (int i = 0;
                                      //     i < resultObjectList.length;
                                      //     i++) {
                                      //   if (i == resultObjectList.length - 1) {
                                      //     goalsSum += resultObjectList[i];
                                      //   } else {
                                      //     goalsSum +=
                                      //         resultObjectList[i] + ", ";
                                      //   }
                                      // }
                                      // customController.text = goalsSum;
                                      customTileColorList.clear();
                                      customBorderColorList.clear();
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '선택완료',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Palette.textBlue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: GridView.builder(
                                shrinkWrap: true,
                                itemCount: objectList.length,
                                itemBuilder: ((context, index) {
                                  var value = objectList[index];
                                  // stateSetter((() {
                                  //   setState(() {
                                  if (resultObjectList.contains(value)) {
                                    customTileColorList
                                        .add(Palette.backgroundOrange);
                                    customBorderColorList
                                        .add(Colors.transparent);
                                    // print("언제 울리니? 1 ");
                                  } else {
                                    customTileColorList.add(Colors.transparent);
                                    customBorderColorList.add(Palette.grayEE);
                                    // print("언제 울리니? 2 ");
                                  }
                                  //   });
                                  // }));

                                  // return Text(widget.optionList[index]);
                                  return InkWell(
                                    onTap: () {
                                      stateSetter(
                                        () {
                                          setState(() {
                                            if (resultObjectList
                                                .contains(value)) {
                                              customTileColorList[index] =
                                                  Colors.transparent;
                                              customBorderColorList[index] =
                                                  Palette.grayEE;
                                              resultObjectList.remove(value);
                                            } else {
                                              customTileColorList[index] =
                                                  Palette.backgroundOrange;
                                              customBorderColorList[index] =
                                                  Colors.transparent;
                                              resultObjectList.add(value);
                                            }
                                          });
                                        },
                                      );
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: customBorderColorList[
                                                    index]),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(30),
                                            ),
                                            color: customTileColorList[index]),
                                        child: Center(
                                            child: Text(
                                          value,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Palette.gray33),
                                        ))),
                                  );
                                }),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 3 / 1,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    });
                  }));

              // LessonAdd로 이동
              //
            },
            icon: Icon(
              Icons.add,
              color: Palette.textBlue,
            ))
      ],
    );
  }

// 운동목표 추가버튼(구)
  Column customGoalAction(
      BuildContext context,
      TextEditingController customController,
      String bigTitle,
      String bottomSheetTitle,
      List<String> objectList,
      List<String> resultObjectList,
      List<Color> customTileColorList,
      List<Color> customBorderColorList) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(0),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Palette.buttonOrange,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              color: Colors.transparent,
            ),
            height: 60,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "운동목표를 선택해 주세요 +",
                  style: TextStyle(
                    fontSize: 14,
                    color: Palette.buttonOrange,
                  ),
                ),
              ],
            ),
          ),
          onPressed: () async {
            print("신규 동작 추가");
            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Palette.secondaryBackground,
                context: context,
                builder: ((context) {
                  return StatefulBuilder(
                      builder: (context, StateSetter stateSetter) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      bottomSheetTitle,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Palette.gray00,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    print(
                                        "resultObjectList : ${resultObjectList}");
                                    // String goalsSum = "";
                                    // for (int i = 0;
                                    //     i < resultObjectList.length;
                                    //     i++) {
                                    //   if (i == resultObjectList.length - 1) {
                                    //     goalsSum += resultObjectList[i];
                                    //   } else {
                                    //     goalsSum +=
                                    //         resultObjectList[i] + ", ";
                                    //   }
                                    // }
                                    // customController.text = goalsSum;
                                    customTileColorList.clear();
                                    customBorderColorList.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '선택완료',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textBlue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: objectList.length,
                              itemBuilder: ((context, index) {
                                var value = objectList[index];
                                // stateSetter((() {
                                //   setState(() {
                                if (resultObjectList.contains(value)) {
                                  customTileColorList
                                      .add(Palette.backgroundOrange);
                                  customBorderColorList.add(Colors.transparent);
                                  // print("언제 울리니? 1 ");
                                } else {
                                  customTileColorList.add(Colors.transparent);
                                  customBorderColorList.add(Palette.grayEE);
                                  // print("언제 울리니? 2 ");
                                }
                                //   });
                                // }));

                                // return Text(widget.optionList[index]);
                                return InkWell(
                                  onTap: () {
                                    stateSetter(
                                      () {
                                        setState(() {
                                          if (resultObjectList
                                              .contains(value)) {
                                            customTileColorList[index] =
                                                Colors.transparent;
                                            customBorderColorList[index] =
                                                Palette.grayEE;
                                            resultObjectList.remove(value);
                                          } else {
                                            customTileColorList[index] =
                                                Palette.backgroundOrange;
                                            customBorderColorList[index] =
                                                Colors.transparent;
                                            resultObjectList.add(value);
                                          }
                                        });
                                      },
                                    );
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  customBorderColorList[index]),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                          color: customTileColorList[index]),
                                      child: Center(
                                          child: Text(
                                        value,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Palette.gray33),
                                      ))),
                                );
                              }),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 3 / 1,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  });
                }));

            // LessonAdd로 이동
            //
          },
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

// 체형분석 타이틀+버튼(신)
  Row customBodyGridView(
      BuildContext context,
      TextEditingController customController,
      String bigTitle,
      String bottomSheetTitle,
      List<String> objectList,
      List<String> resultObjectList,
      List<Color> customTileColorList,
      List<Color> customBorderColorList) {
    return Row(
      children: [
        Text(
          bigTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Palette.gray00,
          ),
        ),
        Spacer(),
        IconButton(
            onPressed: () async {
              print("신규 동작 추가");
              // Bottom Sheet 함수 작성
              showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Palette.secondaryBackground,
                  context: context,
                  builder: ((context) {
                    return StatefulBuilder(
                        builder: (context, StateSetter stateSetter) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        bottomSheetTitle,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Palette.gray00,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      print(
                                          "resultObjectList : ${resultObjectList}");
                                      // String goalsSum = "";
                                      // for (int i = 0;
                                      //     i < resultObjectList.length;
                                      //     i++) {
                                      //   if (i == resultObjectList.length - 1) {
                                      //     goalsSum += resultObjectList[i];
                                      //   } else {
                                      //     goalsSum +=
                                      //         resultObjectList[i] + ", ";
                                      //   }
                                      // }
                                      // customController.text = goalsSum;
                                      customTileColorList.clear();
                                      customBorderColorList.clear();
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '선택완료',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Palette.textBlue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: GridView.builder(
                                shrinkWrap: true,
                                itemCount: objectList.length,
                                itemBuilder: ((context, index) {
                                  var value = objectList[index];
                                  if (resultObjectList.contains(value)) {
                                    customTileColorList.add(Palette.grayEE);
                                    customBorderColorList
                                        .add(Colors.transparent);
                                    // print("언제 울리니? 1 ");
                                  } else {
                                    customTileColorList.add(Colors.transparent);
                                    customBorderColorList.add(Palette.grayEE);
                                    // print("언제 울리니? 2 ");
                                  }
                                  // return Text(widget.optionList[index]);
                                  return InkWell(
                                    onTap: () {
                                      stateSetter(
                                        () {
                                          setState(() {
                                            if (resultObjectList
                                                .contains(value)) {
                                              customTileColorList[index] =
                                                  Colors.transparent;
                                              customBorderColorList[index] =
                                                  Palette.grayEE;
                                              resultObjectList.remove(value);
                                            } else {
                                              customTileColorList[index] =
                                                  Palette.grayEE;
                                              customBorderColorList[index] =
                                                  Colors.transparent;
                                              resultObjectList.add(value);
                                            }
                                          });
                                        },
                                      );
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: customBorderColorList[
                                                    index]),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(30),
                                            ),
                                            color: customTileColorList[index]),
                                        child: Center(
                                            child: Text(
                                          value,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Palette.gray33),
                                        ))),
                                  );
                                }),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 3 / 1,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    });
                  }));

              // LessonAdd로 이동
              //
            },
            icon: Icon(
              Icons.add,
              color: Palette.textBlue,
            ))
      ],
    );
  }

// 체형분석 추가버튼(구)
  Column customBodyAction(
      BuildContext context,
      TextEditingController customController,
      String bigTitle,
      String bottomSheetTitle,
      List<String> objectList,
      List<String> resultObjectList,
      List<Color> customTileColorList,
      List<Color> customBorderColorList) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(0),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Palette.buttonOrange,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              color: Colors.transparent,
            ),
            height: 60,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "체형분석 항목을 선택해 주세요 +",
                  style: TextStyle(
                    fontSize: 14,
                    color: Palette.buttonOrange,
                  ),
                ),
              ],
            ),
          ),
          onPressed: () async {
            print("신규 동작 추가");
            // Bottom Sheet 함수 작성
            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Palette.secondaryBackground,
                context: context,
                builder: ((context) {
                  return StatefulBuilder(
                      builder: (context, StateSetter stateSetter) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      bottomSheetTitle,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Palette.gray00,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    print(
                                        "resultObjectList : ${resultObjectList}");
                                    // String goalsSum = "";
                                    // for (int i = 0;
                                    //     i < resultObjectList.length;
                                    //     i++) {
                                    //   if (i == resultObjectList.length - 1) {
                                    //     goalsSum += resultObjectList[i];
                                    //   } else {
                                    //     goalsSum +=
                                    //         resultObjectList[i] + ", ";
                                    //   }
                                    // }
                                    // customController.text = goalsSum;
                                    customTileColorList.clear();
                                    customBorderColorList.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '선택완료',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textBlue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: objectList.length,
                              itemBuilder: ((context, index) {
                                var value = objectList[index];
                                if (resultObjectList.contains(value)) {
                                  customTileColorList.add(Palette.grayEE);
                                  customBorderColorList.add(Colors.transparent);
                                  // print("언제 울리니? 1 ");
                                } else {
                                  customTileColorList.add(Colors.transparent);
                                  customBorderColorList.add(Palette.grayEE);
                                  // print("언제 울리니? 2 ");
                                }
                                // return Text(widget.optionList[index]);
                                return InkWell(
                                  onTap: () {
                                    stateSetter(
                                      () {
                                        setState(() {
                                          if (resultObjectList
                                              .contains(value)) {
                                            customTileColorList[index] =
                                                Colors.transparent;
                                            customBorderColorList[index] =
                                                Palette.grayEE;
                                            resultObjectList.remove(value);
                                          } else {
                                            customTileColorList[index] =
                                                Palette.grayEE;
                                            customBorderColorList[index] =
                                                Colors.transparent;
                                            resultObjectList.add(value);
                                          }
                                        });
                                      },
                                    );
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  customBorderColorList[index]),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                          color: customTileColorList[index]),
                                      child: Center(
                                          child: Text(
                                        value,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Palette.gray33),
                                      ))),
                                );
                              }),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 3 / 1,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  });
                }));

            // LessonAdd로 이동
            //
          },
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

// 통증상해병력 타이틀+버튼(신)
  Row customMedicalHistoryGridView(
      BuildContext context,
      TextEditingController customController,
      String bigTitle,
      String bottomSheetTitle,
      List<String> objectList,
      List<String> resultObjectList,
      List<Color> customTileColorList,
      List<Color> customBorderColorList) {
    return Row(
      children: [
        Text(
          bigTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Palette.gray00,
          ),
        ),
        Spacer(),
        IconButton(
            onPressed: () async {
              print("신규 동작 추가");
              // Bottom Sheet 함수 작성
              showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Palette.secondaryBackground,
                  context: context,
                  builder: ((context) {
                    return StatefulBuilder(
                        builder: (context, StateSetter stateSetter) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        bottomSheetTitle,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Palette.gray00,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      print(
                                          "resultObjectList : ${resultObjectList}");
                                      // String goalsSum = "";
                                      // for (int i = 0;
                                      //     i < resultObjectList.length;
                                      //     i++) {
                                      //   if (i == resultObjectList.length - 1) {
                                      //     goalsSum += resultObjectList[i];
                                      //   } else {
                                      //     goalsSum +=
                                      //         resultObjectList[i] + ", ";
                                      //   }
                                      // }
                                      // customController.text = goalsSum;
                                      customTileColorList.clear();
                                      customBorderColorList.clear();
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '선택완료',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Palette.textBlue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: GridView.builder(
                                shrinkWrap: true,
                                itemCount: objectList.length,
                                itemBuilder: ((context, index) {
                                  var value = objectList[index];
                                  // stateSetter((() {
                                  //   setState(() {
                                  if (resultObjectList.contains(value)) {
                                    customTileColorList
                                        .add(Palette.backgroundBlue);
                                    customBorderColorList
                                        .add(Colors.transparent);
                                    // print("언제 울리니? 1 ");
                                  } else {
                                    customTileColorList.add(Colors.transparent);
                                    customBorderColorList.add(Palette.grayEE);
                                    // print("언제 울리니? 2 ");
                                  }
                                  //   });
                                  // }));

                                  // return Text(widget.optionList[index]);
                                  return InkWell(
                                    onTap: () {
                                      stateSetter(
                                        () {
                                          setState(() {
                                            if (resultObjectList
                                                .contains(value)) {
                                              customTileColorList[index] =
                                                  Colors.transparent;
                                              customBorderColorList[index] =
                                                  Palette.grayEE;
                                              resultObjectList.remove(value);
                                            } else {
                                              customTileColorList[index] =
                                                  Palette.backgroundBlue;
                                              customBorderColorList[index] =
                                                  Colors.transparent;
                                              resultObjectList.add(value);
                                            }
                                          });
                                        },
                                      );
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: customBorderColorList[
                                                    index]),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(30),
                                            ),
                                            color: customTileColorList[index]),
                                        child: Center(
                                            child: Text(
                                          value,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Palette.gray33),
                                        ))),
                                  );
                                }),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 3 / 1,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    });
                  }));

              // LessonAdd로 이동
              //
            },
            icon: Icon(
              Icons.add,
              color: Palette.textBlue,
            ))
      ],
    );
  }

// 통증상해병력 추가버튼(구)
  Column customMedicalHistoryAction(
      BuildContext context,
      TextEditingController customController,
      String bigTitle,
      String bottomSheetTitle,
      List<String> objectList,
      List<String> resultObjectList,
      List<Color> customTileColorList,
      List<Color> customBorderColorList) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(0),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Palette.buttonOrange,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              color: Colors.transparent,
            ),
            height: 60,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "통증/상해/병력 부위를 선택해 주세요 +",
                  style: TextStyle(
                    fontSize: 14,
                    color: Palette.buttonOrange,
                  ),
                ),
              ],
            ),
          ),
          onPressed: () async {
            print("신규 동작 추가");
            // Bottom Sheet 함수 작성
            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Palette.secondaryBackground,
                context: context,
                builder: ((context) {
                  return StatefulBuilder(
                      builder: (context, StateSetter stateSetter) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      bottomSheetTitle,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Palette.gray00,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    print(
                                        "resultObjectList : ${resultObjectList}");
                                    // String goalsSum = "";
                                    // for (int i = 0;
                                    //     i < resultObjectList.length;
                                    //     i++) {
                                    //   if (i == resultObjectList.length - 1) {
                                    //     goalsSum += resultObjectList[i];
                                    //   } else {
                                    //     goalsSum +=
                                    //         resultObjectList[i] + ", ";
                                    //   }
                                    // }
                                    // customController.text = goalsSum;
                                    customTileColorList.clear();
                                    customBorderColorList.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '선택완료',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textBlue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: objectList.length,
                              itemBuilder: ((context, index) {
                                var value = objectList[index];
                                // stateSetter((() {
                                //   setState(() {
                                if (resultObjectList.contains(value)) {
                                  customTileColorList
                                      .add(Palette.backgroundBlue);
                                  customBorderColorList.add(Colors.transparent);
                                  // print("언제 울리니? 1 ");
                                } else {
                                  customTileColorList.add(Colors.transparent);
                                  customBorderColorList.add(Palette.grayEE);
                                  // print("언제 울리니? 2 ");
                                }
                                //   });
                                // }));

                                // return Text(widget.optionList[index]);
                                return InkWell(
                                  onTap: () {
                                    stateSetter(
                                      () {
                                        setState(() {
                                          if (resultObjectList
                                              .contains(value)) {
                                            customTileColorList[index] =
                                                Colors.transparent;
                                            customBorderColorList[index] =
                                                Palette.grayEE;
                                            resultObjectList.remove(value);
                                          } else {
                                            customTileColorList[index] =
                                                Palette.backgroundBlue;
                                            customBorderColorList[index] =
                                                Colors.transparent;
                                            resultObjectList.add(value);
                                          }
                                        });
                                      },
                                    );
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  customBorderColorList[index]),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                          color: customTileColorList[index]),
                                      child: Center(
                                          child: Text(
                                        value,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Palette.gray33),
                                      ))),
                                );
                              }),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 3 / 1,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  });
                }));

            // LessonAdd로 이동
            //
          },
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  void _getMembership(BuildContext context, String lessonCount) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => MembershipList(
                lessonCount: lessonCount,
              )),
    );

    if (!(result == null)) {
      registerTypeController.text = result;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("선택 된 수강권 : ${result}"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("수강권을 선택해주세요."),
      ));
    }
  }
}

showAlertDialog(BuildContext context) async {
  String result = await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('정말로 삭제하시겠습니까?'),
        content: Text("회원과 관련된 레슨노트 정보도 모두 삭제됩니다."),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Palette.buttonOrange,
            ),
            child: Text('취소'),
            onPressed: () {
              Navigator.pop(context, "Cancel");
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Palette.buttonOrange,
            ),
            child: Text('확인'),
            onPressed: () {
              Navigator.pop(context, "OK");
            },
          ),
        ],
      );
    },
  );
  return result;
}
