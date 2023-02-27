import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/app/ui/page/actionSelector.dart';
import 'package:web_project/app/data/provider/daylesson_service.dart';
import 'package:web_project/app/data/provider/member_service.dart';
import 'package:web_project/app/ui/page/lessonAdd.dart';
import 'package:web_project/app/ui/page/report.dart';
import 'package:web_project/app/ui/page/sequenceLibrary.dart';
import 'package:web_project/app/ui/page/ticketLibraryManage.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';

import '../../data/provider/auth_service.dart';
import '../../data/model/color.dart';
import '../../function/globalFunction.dart';
import '../widget/globalWidget.dart';
import '../../../main.dart';
import 'memberAdd.dart';
import 'memberInfo.dart';
import '../../data/model/userInfo.dart';

int searchResultCnt = 0;

List mainSearchedList = [];

GlobalFunction globalFunction = GlobalFunction();

// GA 용 화면 이름 정의
String screenName = "회원 목록";

MemberService memberService = MemberService();

List<UserInfo> userInfoList = [];

String conutMemberList = "";

String memberAddMode = "추가";

TextEditingController searchController = TextEditingController();

FocusNode searchFocusNode = FocusNode();

String searchString = "";

List combinedLngs = [];

// 자음 검색 세로 바 작업
ScrollController scrollController = ScrollController();

String currentChar = "";

class MemberList extends StatefulWidget {
  List tmpMemberList = [];
  List tmpActionList = [];
  MemberList({super.key});
  MemberList.getMemberList(this.tmpMemberList, this.tmpActionList, {super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  IconData reportIcon = Icons.report_outlined;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // 알파벳 자모음 생성
  final alphabets =
      List.generate(26, (index) => String.fromCharCode(index + 65));
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

  int _searchIndex = 0;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  // 모음 검색 세로 바 구현 작업
  // https://github.com/thanikad/alphabetical_search
  void setSearchIndex(String searchLetter) {
    List rmNameList = [];
    globalVariables.resultList.forEach(
      (element) {
        rmNameList.add(globalFunction.getChosungFromString(element['name']));
      },
    );
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
      print(
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
      print("after jumpTo!!");
    }
    // });
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }

  void _refreshMemberCount(value) {
    setState(() {
      conutMemberList = value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    globalVariables.sortList();

    reportIcon = Icons.report_outlined;

    analyticLog.sendAnalyticsEvent(screenName, "init", "init 스트링", "init파라미터");

    print("MemberList InitState Called!!");
    // 모음 검색 세로 바 구현 작업
    combinedLngs.addAll(koreans);
    combinedLngs.addAll(alphabets);
    scrollController = ScrollController(initialScrollOffset: 0);
    scrollController.addListener(() {
      // print("Listening!");
      // print("scrollController.offset : ${scrollController.offset}");
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    scrollController.dispose();

    widget.tmpActionList = [];
    widget.tmpMemberList = [];

    analyticLog.sendAnalyticsEvent(
        screenName, "dispose", "dispose 스트링", "dispose 파라미터");
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser()!;
    print("몇 번 그리나요? - build");
    //user.uid = '11';
    // 로그인 화면에서 보낸 멤러 리트스 변수 받기
    List<dynamic> argsList = [];
    argsList =
        (ModalRoute.of(context)!.settings.arguments ?? []) as List<dynamic>;
    print("argsList.length : ${argsList.length}");
    // resultMemberList 비었을 경우에만 받아온다.
    if (argsList.length > 0) {
      if (globalVariables.resultList.isEmpty) {
        globalVariables.resultList = argsList[0];
        print(
            "2. resultMemberList.length : ${globalVariables.resultList.length}");
      }

      if (globalVariables.actionList.isEmpty) {
        globalVariables.actionList = argsList[1];
        print(
            "2. resultActionList.length : ${globalVariables.actionList.length}");
      }
    }

    return Consumer<MemberService>(
      builder: (context, memberService, child) {
        print("몇 번 그리나요? - Consumer");

        return Scaffold(
          drawerScrimColor: Palette.gray66,
          drawer: SafeArea(
            child: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  // 프로젝트에 assets 폴더 생성 후 이미지 2개 넣기
                  // pubspec.yaml 파일에 assets 주석에 이미지 추가하기
                  // UserAccountsDrawerHeader(
                  //   // currentAccounticture: CircleAvatar(
                  //   //   // 현재 계정 이미지 set
                  //   //   backgroundImage: AssetImage('assets/profile.png'),
                  //   //   backgroundColor: Colors.white,
                  //   // ),
                  //   // otherAccountsPictures: <Widget>[
                  //   //   // 다른 계정 이미지[] set
                  //   //   CircleAvatar(
                  //   //     backgroundColor: Colors.white,
                  //   //     backgroundImage: AssetImage('assets/profile2.png'),
                  //   //   ),
                  //   //   // CircleAvatar(
                  //   //   //   backgroundColor: Colors.white,
                  //   //   //   backgroundImage: AssetImage('assets/profile2.png'),
                  //   //   // )
                  //   // ],
                  //   accountName: Text('GANGPRO'),
                  //   accountEmail: Text('gangpro@email.com'),
                  //   onDetailsPressed: () {
                  //     print('arrow is clicked');
                  //   },
                  //   decoration: BoxDecoration(
                  //     color: Palette.buttonOrange,
                  //   ),
                  // ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: SizedBox(
                        width: 190,
                        child: Image.asset("assets/images/logo.png")),
                  ),
                  // ListTile(
                  //   leading: Icon(
                  //     Icons.person,
                  //     color: Palette.gray66,
                  //   ),
                  //   title: Text('내 프로필'),
                  //   onTap: () {
                  //     print('내 프로필 is clicked');
                  //   },
                  //   trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  // ),
                  ListTile(
                    leading: Icon(
                      Icons.confirmation_number_outlined,
                      color: Palette.gray66,
                    ),
                    title: Text('수강권 라이브러리'),
                    onTap: () async {
                      print('수강권 라이브러리 is clicked');
                      var result = await // 저장하기 성공시 Home로 이동
                          Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TicketLibraryManage(
                                  TicketLibraryManageList:
                                      globalVariables.ticketLibraryList,
                                )),
                      ).then((value) {
                        print("수강권 추가 result");
                      });
                    },
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Palette.gray66,
                    ),
                    title: Text('개인정보처리방침'),
                    onTap: () {
                      print('개인정보처리방침 is clicked');
                      launchUrl(Uri.parse(
                          'https://huslxl.notion.site/9eec26cf46b941c4960209b419d41fbc'));
                    },
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Palette.gray66,
                    ),
                    title: Text('서비스 이용약관'),
                    onTap: () {
                      print('서비스 이용약관 is clicked');
                      launchUrl(Uri.parse(
                          'https://huslxl.notion.site/51d75d9fb0af4c64be5ec95f16fe6289'));
                    },
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Palette.gray66,
                    ),
                    title: Text('로그아웃'),
                    onTap: () {
                      print('signOut');
                      AuthService authService = AuthService();
                      authService.signOut();
                      // 로그인 페이지로 이동
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage(
                                  analytics: MyApp.analytics,
                                )),
                      );
                    },
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Palette.secondaryBackground,
          // key: _scaffoldKey,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Palette.gray66),
            elevation: 0,
            backgroundColor: Palette.mainBackground,
            title: Text(
              "회원목록",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Palette.gray00,
                  ),
            ),
            centerTitle: true,
            // leading: IconButton(
            //   onPressed: () {},
            //   icon: Icon(Icons.calendar_month),
            // ),
            actions: [
              /// 회원 추가 버튼
              InkWell(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                onTap: () {
                  print("회원추가");
                  memberAddMode = "추가";

                  List<dynamic> args = [
                    memberAddMode,
                    globalVariables.resultList,
                    globalVariables.actionList,
                  ];

                  // 저장하기 성공시 Home로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // 로그아웃 용 야매버튼
                      // builder: (context) =>
                      //     LoginPage(analytics: MyApp.analytics),
                      // 이게 진짜 버튼
                      builder: (context) => MemberAdd(),
                      // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                      settings: RouteSettings(
                        arguments: args,
                      ),
                    ),
                  ).then((value) {
                    globalVariables.sortList();
                    List tmpResultList = value as List;
                    // print("어디지?");
                    setState(() {
                      globalVariables.resultList = tmpResultList[0];
                      globalVariables.actionList = tmpResultList[1];
                    });
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.person_add),
                ),
              ),
              InkWell(
                onTapDown: (details) async {
                  print("IconButton onTapDown!! details : ${details}");

                  setState(() {
                    reportIcon = Icons.report;
                  });

                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Report()),
                  ).then((value) {
                    print("Navigator.push value : ${value}");

                    setState(() {
                      reportIcon = Icons.report_outlined;
                    });
                  });
                },
                onTapUp: (details) {
                  print("IconButton onTapUp!! details : ${details}");
                  setState(() {
                    reportIcon = Icons.report_outlined;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(reportIcon),
                ),
              ),
              SizedBox(width: 10)
            ],
          ),

          body: CenterConstrainedBody(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BaseSearchTextField(
                      customController: searchController,
                      customFocusNode: searchFocusNode,
                      hint: "이름을 검색하세요.",
                      showArrow: true,
                      customFunction: () {
                        searchString = searchController.text.toLowerCase();
                        setState(() {
                          print("search custom function setState called!");
                        });
                      },
                      clearfunction: () {
                        setState(() {
                          searchController.clear();
                          searchString = "";
                        });
                      },
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text(
                          /* searchString == "" ?  */ '총 ${globalVariables.resultList.length} 명' /*  : '검색 결과 ${searchResultCnt} 명' */,
                          style: TextStyle(color: Palette.gray7B),
                        ),
                        Spacer(),
                        // Text(
                        //   '최근 수업순',
                        //   style: TextStyle(color: Palette.gray7B),
                        // ),
                        // Icon(Icons.keyboard_arrow_down_outlined)
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                            padding: EdgeInsets.only(bottom: 20),
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              print("몇 번 그리나요? - ListView.builder");
                              final docs;

                              if (searchString.isNotEmpty) {
                                print(
                                    "searchString.isNotEmpty : ${searchString}");
                                mainSearchedList = [];
                                String varName = "";

                                globalVariables.resultList.forEach((element) {
                                  varName = element['name'];
                                  // 검색 기능 함수 convert
                                  if (globalFunction.searchString(
                                      varName, searchString, "member")) {
                                    mainSearchedList.add(element);
                                  }
                                });
                                print(
                                    "mainSearchedList.length : ${mainSearchedList.length}");
                                docs = mainSearchedList; // 문서들 가져오기
                              } else {
                                globalVariables.sortList();
                                docs = globalVariables.resultList; // 문서들 가져오기
                                print('docs = ${docs[0]}');
                              }
                              /* 멤버 리트스 최초 1번 받아오기 리뉴얼 작업위해 주석 - 정규호 2022/11/23 
                              FutureBuilder<QuerySnapshot>(
                                //future: memberService.read(
                                //    'w5ahp6WhpQdLgqNhA6B8afrWWeA3', 'name'),
                                future: memberService.read(user.uid, 'name'),
                                builder: (context, snapshot) {
                                  final docs = snapshot.data?.docs ?? []; // 문서들 가져오기
                                  */

                              //해당 함수는 빌드가 끝난 다음 수행 된다.
                              //https://velog.io/@jun7332568/%ED%94%8C%EB%9F%AC%ED%84%B0flutter-setState-or-markNeedsBuild-called-during-build.-%EC%98%A4%EB%A5%98-%ED%95%B4%EA%B2%B0
                              /* WidgetsBinding.instance!
                                  .addPostFrameCallback((_) {
                                if (conutMemberList != docs.length.toString()) {
                                  _refreshMemberCount(docs.length.toString());
                                }
                              }); */

                              // 위 refreshMemberCount 아래에 있어야 회원 목록 없을 때 총 0 명 리턴
                              if (docs.isEmpty) {
                                return Center(child: Text("회원 목록을 준비 중입니다."));
                              }

                              return NotificationListener(
                                onNotification: (notification) {
                                  if (notification is UserScrollNotification) {
                                    /* if(scrollController.offset != scrollController.position.maxScrollExtent && docs){
          
                                    } */
                                  }
                                  // print("notification : ${notification}");
                                  return false;
                                },
                                child: ListView.separated(
                                  physics: PageScrollPhysics(),
                                  controller: scrollController,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    //  print("몇 번 그리나요? - ListView.separated");
                                    final doc = docs[index];
                                    // print("doc : ${doc}");
                                    String docId = doc['id'];
                                    String name = doc['name'] ?? "";
                                    String registerDate =
                                        doc['registerDate'] ?? "";
                                    String phoneNumber =
                                        doc['phoneNumber'] ?? "";
                                    String registerType =
                                        doc['registerType'] ?? "";
                                    String goal = doc['goal'] ?? "";
                                    int memberDayLessonCount =
                                        doc['memberDaylessonCount'] ?? 0;
                                    List<String> selectedGoals =
                                        List<String>.from(
                                            doc['selectedGoals'] ?? []);
                                    /* print(
                                        "[ML] ListView 회원정보 가져오기 selectedGoals : ${selectedGoals}"); */
                                    String bodyAnalyzed =
                                        doc['bodyanalyzed'] ?? "";
                                    /* print(
                                        "[ML] ListView 회원정보 가져오기 bodyAnalyzed : ${bodyAnalyzed}"); */
                                    List<String> selectedBodyAnalyzed =
                                        List<String>.from(
                                            doc['selectedBodyAnalyzed'] ?? []);

                                    String medicalHistories =
                                        doc['medicalHistories'] ?? "";
                                    List<String> selectedMedicalHistories =
                                        List<String>.from(
                                            doc['selectedMedicalHistories'] ??
                                                []);

                                    String info = doc['info'] ?? "";
                                    String note = doc['note'] ?? "";
                                    String comment = doc['comment'] ?? "";
                                    bool isActive = doc['isActive'];
                                    bool isFavorite =
                                        doc['isFavorite'] ?? false;

                                    // print("${screenName} name : ${name}, isFavorite : ${isFavorite}");

                                    UserInfo userInfo = UserInfo(
                                      doc['id'],
                                      user.uid,
                                      name,
                                      registerDate,
                                      phoneNumber,
                                      registerType,
                                      goal,
                                      selectedGoals,
                                      bodyAnalyzed,
                                      selectedBodyAnalyzed,
                                      medicalHistories,
                                      selectedMedicalHistories,
                                      info,
                                      note,
                                      comment,
                                      isActive,
                                      isFavorite,
                                    );

                                    return BaseContainer(
                                      docId: docId,
                                      name: name,
                                      registerDate: registerDate,
                                      goal: goal,
                                      info: info,
                                      note: note,
                                      phoneNumber: phoneNumber,
                                      isActive: isActive,
                                      isFavorite: isFavorite,
                                      memberService: memberService,
                                      resultMemberList:
                                          globalVariables.resultList,
                                      memberDayLessonCount:
                                          memberDayLessonCount,

                                      /// 회원카드 선택 시 함수
                                      customFunctionOnTap: () async {
                                        await memberInfoController
                                            .getLessonDayAndActionNoteData(
                                                userInfo.uid, userInfo.docId)
                                            .then((value) {
                                          globalVariables.lessonNoteGlobalList
                                              .addAll(value);

                                          print(
                                              "### globalVariables.lessonNoteGlobalList ${globalVariables.lessonNoteGlobalList}");
                                        });

                                        // 회원 카드 선택시 MemberInfo로 이동
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MemberInfo
                                                .getUserInfoAndActionList(
                                                    userInfo,
                                                    globalVariables.resultList,
                                                    globalVariables.actionList,
                                                    false),
                                            // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                                            /* settings: RouteSettings(
                                            arguments: userInfo
                                          ), */
                                          ),
                                        ).then((result) {
                                          globalVariables.sortList();
                                          // print("MemberList : userInfo.bodyAnalyzed : ${userInfo.selectedBodyAnalyzed}");
                                          // UserInfo tmpUserInfo = result;
                                          // print("MemberList : tmpUserInfo.bodyAnalyzed : ${tmpUserInfo.selectedBodyAnalyzed}");
                                          setState(() {
                                            print(
                                                "memberList - memberinfo pop setState!!");
                                          });
                                        });
                                      },

                                      /// 노트 추가 버튼
                                      noteAddFunctionOnTap: () async {
                                        print('노트 추가 버튼 클릭!');

                                        bool isQuickAdd = true;

                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MemberInfo
                                                .getUserInfoAndActionList(
                                                    userInfo,
                                                    globalVariables.resultList,
                                                    globalVariables.actionList,
                                                    true),
                                            // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                                            /* settings: RouteSettings(
                                            arguments: userInfo
                                          ), */
                                          ),
                                        ).then((result) {
                                          globalVariables.sortList();
                                          // print("MemberList : userInfo.bodyAnalyzed : ${userInfo.selectedBodyAnalyzed}");
                                          // UserInfo tmpUserInfo = result;
                                          // print("MemberList : tmpUserInfo.bodyAnalyzed : ${tmpUserInfo.selectedBodyAnalyzed}");
                                          setState(() {
                                            print(
                                                "memberList - memberinfo pop setState!!");
                                          });
                                        });

                                        setState(() {});
                                      },
                                    ).animate().slide(
                                        begin: Offset(0, 0.5),
                                        curve: Curves.easeOut,
                                        duration: 500.ms);
                                  },
                                  separatorBuilder: ((context, index) =>
                                      SizedBox(height: 8)),
                                ),
                              );
                            },
                          ),
                          // 자음 검색 세로 바 구현 작업
                          /* GestureDetector(
                            onVerticalDragUpdate: (details) {
                              print(
                                  "update details.localPosition.dy : ${details.localPosition.dy}");
                              print("update currentChar : ${currentChar}");
                              setSearchIndex(currentChar);
                            },
                            onVerticalDragStart: (details) {
                              print(
                                  "start details.localPosition.dy : ${details.localPosition.dy}");
                              print("start currentChar : ${currentChar}");
                              setSearchIndex(currentChar);
                            },
                            onVerticalDragEnd: (details) {
                              print("End currentChar : ${currentChar}");
                              setState(() {
                                currentChar = "";
                              });
                            },
                            child: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: combinedLngs
                                    .map((character) => InkWell(
                                          onTap: () async {
                                            print("character : ${character}");
                                            setState(() {
                                              currentChar = character;
                                            });
          
                                            setSearchIndex(currentChar);
          
                                            Future.delayed(Duration(seconds: 3),
                                                () {
                                              setState(() {
                                                currentChar = "";
                                              });
                                            });
          
                                            /* currentChar = character; */
                                            
                                          },
                                          child: Text(
                                            character,
                                            style: TextStyle(
                                                fontSize: (MediaQuery.of(context).size.height/65).floorToDouble()),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                          currentChar.isEmpty
                              ? Container()
                              : Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    color: Colors.black.withAlpha(80),
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      currentChar,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 36.0),
                                    ),
                                  ),
                                ) */
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
