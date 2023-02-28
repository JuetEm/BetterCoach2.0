import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/app/data/model/lessonNoteInfo.dart';
import 'package:web_project/app/data/provider/lesson_service.dart';
import 'package:web_project/app/data/provider/memberTicket_service.dart';
import 'package:web_project/app/data/provider/member_service.dart';
import 'package:web_project/app/ui/page/lessonAdd.dart';
import 'package:web_project/app/ui/page/memberTicketManage.dart';
import 'package:web_project/app/ui/page/ticketLibraryMake.dart';
import 'package:web_project/app/ui/widget/baseTableCalendar.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/function/globalFunction.dart';
import 'package:web_project/app/ui/widget/globalWidget.dart';
import 'package:web_project/app/ui/page/locationAdd.dart';
import 'package:web_project/app/ui/widget/lessonCardWidget.dart';
import 'package:web_project/app/ui/widget/tableCalendarWidget.dart';
import 'package:web_project/main.dart';
import 'package:web_project/app/ui/widget/ticketWidget.dart';

import 'actionSelector.dart';
import '../../data/provider/auth_service.dart';
import '../../data/model/color.dart';

import 'lessonUpdate.dart';
import 'memberAdd.dart';
import 'memberList.dart';
import 'memberUpdate.dart';
import '../../data/model/userInfo.dart';

GlobalFunction globalFunction = GlobalFunction();

Map<DateTime, dynamic> eventSource = {};
List<DateTime> eventList = [];
String now = DateFormat("yyyy-MM-dd").format(DateTime.now());
String lessonDate = "";

String lessonNoteId = "";
String lessonAddMode = "";

bool initStateCheck = true;

int indexCheck = 0;
String listMode = "날짜별";
String viewMode = "기본정보";
String lessonDateTrim = "";
String apratusNameTrim = "";
int dayNotelessonCnt = 0;
bool favoriteMember = true;
late UserInfo userInfo;
UserInfo? tmpUserInfo = null;

List resultList = [];

List resultActionList = [];
List resultMemberList = [];

bool isNoteCalendarHided = true;

List lessonActionList = [];

// 회원 동작별 노트
List memberActionNote = [];

bool isSelectedTicketExist = false;

class MemberInfo extends StatefulWidget {
  UserInfo? userInfo;
  List tmpResultActionList = [];
  List tmpResultMemeberList = [];
  late bool isQuickAdd;

  MemberInfo({super.key});

  MemberInfo.getUserInfoAndActionList(this.userInfo, this.tmpResultMemeberList,
      this.tmpResultActionList, this.isQuickAdd,
      {super.key});

  @override
  State<MemberInfo> createState() => _MemberInfoState();
}

class _MemberInfoState extends State<MemberInfo> {
  void initState() {
    //처음에만 날짜 받아옴.

    super.initState();

    if (widget.isQuickAdd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          lessonDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

          List<TmpLessonInfo> tmpLessonInfoList = [];
          eventList = [];
          lessonAddMode = "노트 추가";
          List<dynamic> args = [
            userInfo,
            lessonDate,
            eventList,
            lessonNoteId,
            lessonAddMode,
            tmpLessonInfoList,
            resultActionList,
            ticketCountLeft,
            ticketCountAll,
          ];
          print(
              "[MI] 노트추가 클릭  ${lessonDate} / ${lessonAddMode} / tmpLessonInfoList ${tmpLessonInfoList.length}");

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonAdd(),
              // setting에서 arguments로 다음 화면에 회원 정보 넘기기
              settings: RouteSettings(arguments: args),
            ),
          );
        });
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    initStateCheck = true;
    print("[MI] Dispose : initStateCheck ${initStateCheck} ");
    super.dispose();
  }

  void _refreshMemberInfo() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //final authService = context.read<AuthService>();
    //final user = authService.currentUser()!;
    final memberService = context.read<MemberService>();

    print('[MI] 시작 : initStateCheck - ${initStateCheck}');

    if (initStateCheck) {
      // 이전 화면에서 보낸 변수 받기
      // resultList = ModalRoute.of(context)!.settings.arguments as List;
      userInfo = widget.userInfo!;
      resultMemberList = widget.tmpResultMemeberList;
      resultActionList = widget.tmpResultActionList;
      initStateCheck = false;
      print("[MI]시작 - userInfo.selectedGoals / ${userInfo.selectedGoals}");
      print("[MI]시작 - userInfo.goal / ${userInfo.goal}");
    } else {
      print("[MI]시작(init아님) - userInfo.goal / ${userInfo.goal}");
    }

    // 이름 첫글자 자르기
    String nameFirst = ' ';
    if (userInfo.name.length > 0) {
      nameFirst = userInfo.name.substring(0, 1);
    }

    final lessonService = context.read<LessonService>();

    Future<int> daylessonCnt = lessonService.countTodaynote(
      userInfo.uid,
      userInfo.docId,
    );

    daylessonCnt.then((val) {
      // int가 나오면 해당 값을 출력
      print('[MI] 오늘 노트 개수 출력 : $val');
      dayNotelessonCnt = val;
      //Textfield 생성
    }).catchError((error) {
      // error가 해당 에러를 출력
      print('error: $error');
    });

    return Consumer2<LessonService, MemberService>(
      builder: (context, lessonService, memberService, child) {
        print("[MI] 빌드시작  : favoriteMember- ${favoriteMember}");
        // lessonService
        // ignore: dead_code

        lessonService
            .readMemberActionNote(
          AuthService().currentUser()!.uid,
          userInfo.docId,
        )
            .then((value) {
          memberActionNote.addAll(value);
        });

        List memberInfoTicketList = [];

        /// 메인으로 사용하는 리스트를 글로벌에서 불러와 멤버아이디로 필터링해준다.
        memberInfoTicketList = globalVariables.memberTicketList
            .where((element) => element['memberId'] == userInfo.docId)
            .toSet()
            .toList();

        // 선택된 티켓
        var selectedTicket = memberInfoTicketList.firstWhere(
            (element) => element['isSelected'] = true,
            orElse: () => null);

        // 선택된 티켓이 있으면, 선택된 티켓 존재 여부 true, 수강권 추가하기 버튼 -> 사용중인 수강권 위젯
        if (selectedTicket != null) {
          isSelectedTicketExist = true;
        } else {
          isSelectedTicketExist = false;
        }
        print('[MBL_Ticket] selectedTicket: $selectedTicket');

        return Scaffold(
          backgroundColor: Palette.secondaryBackground,
          appBar: BaseAppBarMethod(context, "회원관리", () {
            print(
                "MemberInfo : BaseAppBarMethod : userInfo.bodyAnalyzed : ${userInfo.selectedBodyAnalyzed}");
            // print("MemberInfo : BaseAppBarMethod : tmpUserInfo.bodyAnalyzed : ${tmpUserInfo!.selectedBodyAnalyzed}");
            // Navigator.pop(context,tmpUserInfo);
            Navigator.pop(context, userInfo);
          }, null, null),
          body: CenterConstrainedBody(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 22, 22, 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // FutureBuilder 예시 코드
                                    FutureBuilder(
                                      future: globalFunction.readfavoriteMember(
                                          userInfo.uid, userInfo.docId),
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        //해당 부분은 data를 아직 받아 오지 못했을 때 실행되는 부분
                                        if (snapshot.hasData == false) {
                                          return IconButton(
                                              icon: SvgPicture.asset(
                                                "assets/icons/favoriteUnselected.svg",
                                              ),
                                              iconSize: 40,
                                              onPressed: () {});
                                        }
                                        //error가 발생하게 될 경우 반환하게 되는 부분
                                        else if (snapshot.hasError) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          );
                                        }

                                        // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 부분
                                        else {
                                          print(
                                              "[MI] 즐겨찾기 로딩후 : ${snapshot.data} / ${userInfo.docId}");
                                          favoriteMember = snapshot.data;
                                          return IconButton(
                                              icon: SvgPicture.asset(
                                                favoriteMember
                                                    ? "assets/icons/favoriteSelected.svg"
                                                    : "assets/icons/favoriteUnselected.svg",
                                              ),
                                              iconSize: 40,
                                              onPressed: () async {
                                                favoriteMember =
                                                    !favoriteMember;

                                                await memberService
                                                    .updateIsFavorite(
                                                        userInfo.docId,
                                                        favoriteMember);
                                                int rstLnth = globalVariables
                                                    .resultList.length;
                                                for (int i = 0;
                                                    i < rstLnth;
                                                    i++) {
                                                  if (userInfo.docId ==
                                                      globalVariables
                                                              .resultList[i]
                                                          ['id']) {
                                                    print(
                                                        "memberInfo - widget.resultMemberList[${i}]['id'] : ${globalVariables.resultList[i]['id']}");
                                                    globalVariables
                                                                .resultList[i]
                                                            ['isFavorite'] =
                                                        !globalVariables
                                                                .resultList[i]
                                                            ['isFavorite'];
                                                    break;
                                                  }
                                                }

                                                print(
                                                    "[MI] 즐겨찾기 변경 클릭 : 변경후 - ${favoriteMember} / ${userInfo.docId}");

                                                // globalFunction.updatefavoriteMember();
                                                //lessonService.notifyListeners();

                                                //setState(() {});
                                                // setState(() {
                                                //   userInfo.isActive
                                                //       ? favoriteMember = false
                                                //       : favoriteMember = true;
                                                // }
                                                //);
                                              });
                                        }
                                      },
                                    ),

                                    Container(
                                      constraints:
                                          BoxConstraints(maxWidth: 150),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${userInfo.name}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10.0),
                                          Text(
                                            '${userInfo.phoneNumber}',
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                //fontWeight: FontWeight.bold,
                                                color: Palette.gray66),
                                          ),
                                        ],
                                      ),
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
                                              memberInfoTicketList[globalVariables
                                                          .selectedTicketIndex]
                                                      ['ticketCountLeft']
                                                  .toString(),
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
                                              memberInfoTicketList[globalVariables
                                                          .selectedTicketIndex]
                                                      ['ticketCountAll']
                                                  .toString(),
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
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: Text(
                                            '등록일: ${userInfo.registerDate}',
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                //fontWeight: FontWeight.bold,
                                                color: Palette.gray99),
                                            textAlign: TextAlign.right,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 14,
                              ),

                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                  //color: Colors.red.withOpacity(0),
                                ),
                                //padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 5,
                                      child: Material(
                                        color: Palette.mainBackground,
                                        child: InkWell(
                                          onTap: () {
                                            if (viewMode == "레슨노트") {
                                              setState(() {
                                                viewMode = "기본정보";
                                              });
                                            }
                                            ;
                                          },
                                          child: Container(
                                            height: 54,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: viewMode == "기본정보"
                                                      ? Palette.buttonOrange
                                                      : Palette.grayEE,
                                                  width: 2,
                                                ),
                                              ),
                                            ),

                                            //color: Colors.red.withOpacity(0),

                                            width: double.infinity,
                                            child: Center(
                                              child: Text(
                                                "기본정보",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: viewMode == "기본정보"
                                                      ? Palette.buttonOrange
                                                      : Palette.gray99,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 5,
                                      child: Material(
                                        color: Palette.mainBackground,
                                        child: InkWell(
                                          onTap: () {
                                            if (viewMode == "기본정보") {
                                              setState(() {
                                                viewMode = "레슨노트";
                                              });
                                            }
                                            ;
                                          },
                                          child: Container(
                                            height: 54,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: viewMode == "레슨노트"
                                                      ? Palette.buttonOrange
                                                      : Palette.grayEE,
                                                  width: 2,
                                                ),
                                              ),
                                            ),

                                            //color: Colors.red.withOpacity(0),

                                            width: double.infinity,
                                            child: Center(
                                              child: Text(
                                                "레슨노트",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: viewMode == "레슨노트"
                                                      ? Palette.buttonOrange
                                                      : Palette.gray99,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ), //   Spacer(),
                                    //   InkWell(
                                    //     onTap: () {
                                    //       if (viewMode == "기본정보") {
                                    //         setState(() {
                                    //           viewMode = "레슨노트";
                                    //         });
                                    //       }
                                    //       ;
                                    //     },
                                    //     child: SizedBox(
                                    //       child: Row(
                                    //         children: [
                                    //           Icon(
                                    //             Icons.sync,
                                    //             color: Palette.gray99,
                                    //             size: 15.0,
                                    //           ),
                                    //           SizedBox(
                                    //             width: 5,
                                    //           ),
                                    //           Text(
                                    //             "레슨노트",
                                    //             style: TextStyle(
                                    //               fontSize: 22,
                                    //               color: Palette.gray66,
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ),
                                  ],
                                ),
                              ),
                              //https://kibua20.tistory.com/232
                              viewMode == "기본정보"
                                  ? MemberInfoView(userInfo: userInfo)
                                  : LessonNoteView(
                                      userInfo: userInfo,
                                      lessonService: lessonService,
                                      //notifyParent: _refreshNoteCount,
                                    ),

                              //SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 14,
                  // ),

                  /// 추가버튼_이전
                  // ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(30.0),
                  //       ),
                  //       elevation: 0,
                  //       backgroundColor: Palette.buttonOrange,
                  //     ),
                  //     child: Padding(
                  //       padding: const EdgeInsets.symmetric(
                  //           vertical: 14, horizontal: 90),
                  //       child: Text("노트추가", style: TextStyle(fontSize: 16)),
                  //     ),
                  //     onPressed: () {
                  //       lessonDate =
                  //           DateFormat("yyyy-MM-dd").format(DateTime.now());

                  //       List<TmpLessonInfo> tmpLessonInfoList = [];
                  //       eventList = [];
                  //       lessonAddMode = "노트 추가";
                  //       List<dynamic> args = [
                  //         userInfo,
                  //         lessonDate,
                  //         eventList,
                  //         lessonNoteId,
                  //         lessonAddMode,
                  //         tmpLessonInfoList,
                  //       ];
                  //       print(
                  //           "[MI] 노트추가 클릭  ${lessonDate} / ${lessonAddMode} / tmpLessonInfoList ${tmpLessonInfoList.length}");
                  //       // LessonAdd로 이동
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => LessonAdd(),
                  //           // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                  //           settings: RouteSettings(arguments: args),
                  //         ),
                  //       );
                  //     }),

                  /// 추가 버튼
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(5, 11, 5, 24),
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(30.0),
                  //       ),
                  //       backgroundColor: Colors.transparent,
                  //       shadowColor: Colors.transparent,
                  //     ),
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         color: Palette.buttonOrange,
                  //       ),
                  //       height: 60,
                  //       width: double.infinity,
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         children: [
                  //           Text(
                  //             "노트 추가",
                  //             style: TextStyle(fontSize: 18),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     onPressed: () {
                  //       print("노트 추가");

                  //       lessonDate =
                  //           DateFormat("yyyy-MM-dd").format(DateTime.now());

                  //       List<TmpLessonInfo> tmpLessonInfoList = [];
                  //       eventList = [];
                  //       lessonAddMode = "노트 추가";
                  //       List<dynamic> args = [
                  //         userInfo,
                  //         lessonDate,
                  //         eventList,
                  //         lessonNoteId,
                  //         lessonAddMode,
                  //         tmpLessonInfoList,
                  //       ];

                  //       // LessonAdd로 이동
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => LessonAdd(),
                  //           // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                  //           settings: RouteSettings(arguments: args),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          floatingActionButton: /* viewMode == "기본정보"? null :  */ Center(
            child: Container(
              alignment: Alignment.bottomRight,
              constraints: BoxConstraints(maxWidth: 480),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    if (viewMode == "기본정보") {
                      print("회원수정");
                      String memberAddMode = "수정";
                      //UserInfo userInfo = userInfo;

                      List<dynamic> args = [
                        memberAddMode,
                        userInfo,
                        resultMemberList,
                        resultActionList,
                      ];

                      //userInfo = result;
                      print(
                          "[MI]회원수정전 정보 받아오기 - userInfo.selectedGoals / ${userInfo.selectedGoals}");
                      print(
                          "[MI]회원수정전 정보 받아오기 - userInfo.selectedGoals / ${userInfo.goal}/${userInfo.bodyAnalyzed}/${userInfo.selectedBodyAnalyzed}/${userInfo.medicalHistories}/${userInfo.selectedMedicalHistories}");

                      dynamic result = await // 저장하기 성공시 Home로 이동
                          Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemberAdd(),
                          // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                          settings: RouteSettings(
                            arguments: args,
                          ),
                        ),
                      );

                      if (result != null) {
                        List tmpResult = result as List;
                        userInfo = tmpResult[0];
                        resultMemberList = tmpResult[1];
                        resultActionList = tmpResult[2];
                        //initStateCheck = true;
                        globalFunction.updatefavoriteMember();
                        //lessonService.notifyListeners();
                      } else {
                        print("[MI]회원정보에서 수정후 삭제.. 연속닫기 - result / ${result}");
                        Navigator.pop(context);
                      }
                      //userInfo = result;
                      print(
                          "[MI]회원수정후 정보 받아오기 - userInfo.selectedGoals / ${userInfo.selectedGoals}");
                      print(
                          "[MI]회원수정전 정보 받아오기 - userInfo.goal / ${userInfo.goal}/${userInfo.bodyAnalyzed}/${userInfo.selectedBodyAnalyzed}/${userInfo.medicalHistories}/${userInfo.selectedMedicalHistories}");

                      // ).then(
                      //   (result) {
                      //     if (result != null) {
                      //       userInfo = result;
                      //       lessonService.notifyListeners();
                      //     } else {
                      //       print("[MI]회원정보에서 수정후 삭제.. 연속닫기 - result / ${result}");
                      //       Navigator.pop(context);
                      //     }
                      //     //userInfo = result;
                      //     print(
                      //         "[MI]회원수정후 정보 받아오기 - userInfo.selectedGoals / ${userInfo.selectedGoals}");
                      //   },
                      // );
                    } else {
                      // if (viewMode == "레슨노트") {

                      // print("ㅡㅑㅡㅑㅡㅑㅡㅑㅡㅑㅡㅑㅡㅑ - 여기가 울리나요?");
                      lessonDate =
                          DateFormat("yyyy-MM-dd").format(DateTime.now());

                      ticketCountLeft = memberInfoTicketList[globalVariables
                          .selectedTicketIndex]['ticketCountLeft'];
                      ticketCountAll = memberInfoTicketList[globalVariables
                          .selectedTicketIndex]['ticketCountAll'];

                      List<TmpLessonInfo> tmpLessonInfoList = [];
                      eventList = [];
                      lessonAddMode = "노트 추가";
                      List<dynamic> args = [
                        userInfo,
                        lessonDate,
                        eventList,
                        lessonNoteId,
                        lessonAddMode,
                        tmpLessonInfoList,
                        resultActionList,
                        ticketCountLeft,
                        ticketCountAll,
                      ];
                      print(
                          "[MI] 노트추가 클릭  ${lessonDate} / ${lessonAddMode} / tmpLessonInfoList ${tmpLessonInfoList.length}");

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonAdd(),
                          // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                          settings: RouteSettings(arguments: args),
                        ),
                      ).then((value) async {
                        print("^^^^^^^^^^^^^^^^ Floating Button Then!!");
                        // resultActionList = value;
                        setState(() {});
                        myData = await fetchData();
                      });
                    }
                  },
                  label: Text(
                    viewMode == "기본정보" ? '정보 수정' : '노트 작성',
                    style: TextStyle(fontSize: 16, letterSpacing: -0.2),
                  ),
                  icon: viewMode == "기본정보"
                      ? Icon(Icons.edit)
                      : Icon(Icons.post_add),
                  backgroundColor: Palette.buttonOrange,
                ),
              ),
            ),
          ),
          // Figma 확인 해보면 '기본정보' 탭에는 BottomAppBar 없는데, '동작' 탬에는 있음
          // 같은 화면인데 '기본정보' 탭에는 누락 된 듯하여 추가 BottomAppBar 함
          //bottomNavigationBar: BaseBottomAppBar(),
        );
      },
    );
  }
}

class LessonNoteView extends StatefulWidget {
  const LessonNoteView({
    Key? key,
    required this.userInfo,
    required this.lessonService,
    //required this.notifyParent,
  }) : super(key: key);

  final UserInfo userInfo;
  final LessonService lessonService;
  //final Function() notifyParent;

  @override
  State<LessonNoteView> createState() => _LessonNoteViewState();
}

class _LessonNoteViewState extends State<LessonNoteView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
        color: Palette.mainBackground,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ///
        /// 헤딩 영역: 총 개수, 캘린더 버튼, 동작별/날짜별 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //
              // 총 노트 개수
              Text(
                '총 ${dayNotelessonCnt}개',
                style: TextStyle(
                  fontSize: 14,
                  color: Palette.gray66,
                ),
              ),
              Spacer(),
              // 캘린더 버튼
              Offstage(
                offstage: listMode == "동작별" ? true : false,
                child: Material(
                  child: InkWell(
                    onTap: () {
                      isNoteCalendarHided = !isNoteCalendarHided;
                      setState(() {});
                      print('Calender Button Clicked');
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Palette.grayF5,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: Palette.gray99,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '캘린더',
                            style: TextStyle(
                              fontSize: 14,
                              color: Palette.gray33,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              // 동작별/날짜별 버튼
              Material(
                child: InkWell(
                  onTap: () {
                    if (listMode == "동작별") {
                      setState(() {
                        listMode = "날짜별";
                      });
                    } else {
                      setState(() {
                        listMode = "동작별";
                      });
                    }
                    ;
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Palette.grayF5,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sync,
                          color: Palette.gray99,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          listMode == "동작별" ? "날짜별" : "동작별",
                          style: TextStyle(
                            fontSize: 14,
                            color: Palette.gray33,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 10,
          color: Palette.secondaryBackground,
        ),

        // 캘린더 시작
        Offstage(
          offstage: isNoteCalendarHided,
          child: TableCalendarWidget(
            selectedDate: "",
            customFunctionOnDaySelected: () {},
          )
              .animate(target: !isNoteCalendarHided ? 1 : 0)
              .fadeIn(duration: 300.ms)
              .animate(target: isNoteCalendarHided ? 1 : 0)
              .fadeOut(duration: 300.ms),
        ),

        /// 새로운 레슨 노트 보기 리스트 시작
        FutureBuilder<QuerySnapshot>(
            future: widget.lessonService.read(
              widget.userInfo.uid,
              widget.userInfo.docId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                print("ConnectionState.waiting : ${ConnectionState.waiting}");
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Palette.buttonOrange,
                  )),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                print("ConnectionState.done : ${ConnectionState.done}");
                final doc = snapshot.data?.docs ?? []; // 문서들 가져오기

                print(
                    "[MI] 노트 유무 체크 - doc:${doc.length}/${widget.userInfo.uid}/${widget.userInfo.docId}");
                if (doc.isEmpty && dayNotelessonCnt == 0) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Text("첫번째 노트를 작성해보세요!"),
                      ),
                    ],
                  );
                } else if (doc.isEmpty && dayNotelessonCnt > 0) {
                  print("동작은 없는데, 일별노트는 있는 경우");
                  if (listMode == "동작별") {
                    return Column(
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: Text("노트에서 동작을 추가해보세요!"),
                        ),
                      ],
                    );
                  } else {
                    // List<TmpLessonInfo> tmpLessonInfoList = [];
                    return NoteListDateCategory(
                      docs: doc,
                      userInfo: widget.userInfo,
                      lessonService: widget.lessonService,
                      memberActionNote: memberActionNote,
                    );
                  }
                } else {
                  print("왜가리지?");
                  if (listMode == "동작별") {
                    return NoteListActionCategory(
                        docs: doc, userInfo: widget.userInfo);
                  } else {
                    // List<TmpLessonInfo> tmpLessonInfoList = [];
                    return NoteListDateCategory(
                      docs: doc,
                      userInfo: widget.userInfo,
                      lessonService: widget.lessonService,
                      memberActionNote: memberActionNote,
                    );
                  }
                }
              } else {
                print("ConnectionState.else");
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 120),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Palette.buttonOrange,
                    ),
                  ),
                );
              }
            }),

        SizedBox(
          height: 14,
        ),
      ]),
    );
  }
}

int ticketIndex = 0;

List memberTicketList = [];

class MemberInfoView extends StatefulWidget {
  const MemberInfoView({
    Key? key,
    required this.userInfo,
  }) : super(key: key);

  final UserInfo userInfo;

  @override
  State<MemberInfoView> createState() => _MemberInfoViewState();
}

class _MemberInfoViewState extends State<MemberInfoView> {
  @override
  void initState() {
    super.initState();
    ticketIndex = 0;
  }

  @override
  void dispose() {
    super.dispose();
    ticketIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    // 등록 된 수강권이 있으면 회원관리 기본정보 화면에 수강권 자동 선택

    _MemberInfoState? parent =
        context.findAncestorStateOfType<_MemberInfoState>();
    // selectedGoals 값 반영하여 FilterChips 동적 생성
    var goalChips = [];
    goalChips = makeChips(
        goalChips, widget.userInfo.selectedGoals, Palette.backgroundOrange);
    // selelctedAnalyzedList 값 반영하여 FilterChips 동적 생성
    var bodyAnalyzedChips = [];
    bodyAnalyzedChips = makeChips(bodyAnalyzedChips,
        widget.userInfo.selectedBodyAnalyzed, Palette.grayEE);

    // medicalHistoryList 값 반영하여 FilterChips 동적 생성
    var medicalHistoriesChips = [];
    medicalHistoriesChips = makeChips(medicalHistoriesChips,
        widget.userInfo.selectedMedicalHistories, Palette.backgroundBlue);

    print(
        "[MI] 운동목표 칩셋출력 : selectedGoals비었니.? ${widget.userInfo.selectedGoals.isEmpty}");
    print("[MI] 운동목표 칩셋출력 : goalChips ${goalChips}");

    return Consumer<MemberTicketService>(
        builder: (context, memberTicketService, child) {
      List memberInfoTicketList = [];

      /// 메인으로 사용하는 리스트를 글로벌에서 불러와 멤버아이디로 필터링해준다.
      memberInfoTicketList = globalVariables.memberTicketList
          .where((element) => element['memberId'] == userInfo.docId)
          .toSet()
          .toList();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
          color: Palette.mainBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5.0),

            Text(
              '수강정보',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.gray66,
              ),
            ),
            const SizedBox(height: 10),

            /// 티켓모양 수강권
            Container(
              alignment: Alignment.center,
              child: isSelectedTicketExist
                  ? TicketWidget(
                      ticketTitle: memberInfoTicketList[ticketIndex]
                          ['ticketTitle'],
                      ticketDescription: globalVariables
                          .memberTicketList[ticketIndex]['ticketDescription'],
                      ticketStartDate: globalFunction.getDateFromTimeStamp(
                          memberInfoTicketList[ticketIndex]['ticketStartDate']),
                      ticketEndDate: globalFunction.getDateFromTimeStamp(
                          memberInfoTicketList[ticketIndex]['ticketEndDate']),
                      ticketCountAll: memberInfoTicketList[ticketIndex]
                          ['ticketCountAll'],
                      ticketCountLeft: memberInfoTicketList[ticketIndex]
                          ['ticketCountLeft'],
                      isAlive: memberInfoTicketList[ticketIndex]['isAlive'],
                      customFunctionOnTap: () async {
                        print("수강권 추가 onTap!!");
                        var result = await // 저장하기 성공시 Home로 이동
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MemberTicketManage.getUserInfo(
                                      memberInfoTicketList, widget.userInfo)),
                        ).then((value) {
                          ticketIndex = value;
                          print("수강권 클릭 result : ${value}");
                          setState(() {
                            print("memberInfo then setState called!");
                          });
                          parent?.setState(() {
                            print("memberInfo then parent setState called!");
                          });
                        });
                      },
                      customFunctionOnLongPress: () {},
                    )
                  : AddTicketWidget(
                      label: '수강권 선택하기',
                      addIcon: true,
                      customFunctionOnTap: () async {
                        var result = await // 저장하기 성공시 Home로 이동
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MemberTicketManage.getUserInfo(
                                      memberInfoTicketList, widget.userInfo)),
                        ).then((value) {
                          ticketIndex = value;

                          print("수강권 선택 result : ${value}");
                          setState(() {
                            print("memberInfo then setState called!");
                          });
                          parent?.setState(() {
                            print("memberInfo then parent setState called!");
                          });
                        });
                      },
                    ),
            ),
            SizedBox(
              height: 20,
            ),
            Divider(),
            SizedBox(
              height: 20,
            ),
            Text(
              '수강정보',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.gray66,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '등록횟수 : ${widget.userInfo.registerType}',
              style: TextStyle(
                  fontSize: 14.0,
                  //fontWeight: FontWeight.bold,
                  color: Palette.gray99),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 20),
            Divider(),
            SizedBox(
              height: 20,
            ),
            Text(
              '운동목표',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.gray66,
              ),
            ),
            const SizedBox(height: 10),
            Offstage(
              offstage: widget.userInfo.selectedGoals.isEmpty,
              child: Wrap(
                direction: Axis.horizontal, // 나열 방향
                alignment: WrapAlignment.start, // 정렬 방식
                spacing: 5, // 좌우 간격
                runSpacing: 5,
                children: [
                  for (final chip in goalChips)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4.0, 0, 4, 0),
                      child: chip,
                    ),
                ],
              ),
            ),
            Offstage(
              offstage: widget.userInfo.goal.isEmpty,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    widget.userInfo.goal,
                    style: TextStyle(
                      fontSize: 14,
                      //fontWeight: FontWeight.bold,
                      color: Palette.gray99,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(),
            SizedBox(
              height: 20,
            ),
            Text(
              '체형분석',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.gray66,
              ),
            ),
            const SizedBox(height: 10),
            Offstage(
              offstage: widget.userInfo.selectedBodyAnalyzed.isEmpty,
              child: Wrap(
                direction: Axis.horizontal, // 나열 방향
                alignment: WrapAlignment.start, // 정렬 방식
                spacing: 5, // 좌우 간격
                runSpacing: 5,
                children: [
                  for (final chip in bodyAnalyzedChips)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4.0, 0, 4, 0),
                      child: chip,
                    ),
                ],
              ),
            ),
            Offstage(
              offstage: widget.userInfo.bodyAnalyzed.isEmpty,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    widget.userInfo.bodyAnalyzed,
                    style: TextStyle(
                      fontSize: 14,
                      //fontWeight: FontWeight.bold,
                      color: Palette.gray99,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(),
            SizedBox(
              height: 20,
            ),
            Text(
              '통증/상해/병력',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Palette.gray66),
            ),
            const SizedBox(height: 10),
            Offstage(
              offstage: widget.userInfo.selectedMedicalHistories.isEmpty,
              child: Wrap(
                direction: Axis.horizontal, // 나열 방향
                alignment: WrapAlignment.start, // 정렬 방식
                spacing: 5, // 좌우 간격
                runSpacing: 5,
                children: [
                  for (final chip in medicalHistoriesChips)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4.0, 0, 4, 0),
                      child: chip,
                    ),
                ],
              ),
            ),
            Offstage(
              offstage: widget.userInfo.medicalHistories.isEmpty,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    widget.userInfo.medicalHistories,
                    style: TextStyle(
                      fontSize: 14,
                      //fontWeight: FontWeight.bold,
                      color: Palette.gray99,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(),
            SizedBox(
              height: 20,
            ),
            Text(
              '특이사항',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.gray66,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.userInfo.comment,
              style: TextStyle(
                fontSize: 14,
                //fontWeight: FontWeight.bold,
                color: Palette.gray99,
              ),
            ),

            SizedBox(height: 20),
            /* Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(36.0),
                    ),
                    color: Palette.grayB4,
                  ),
                  height: 40,
                  width: 160,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "정보 수정",
                        style: TextStyle(fontSize: 14, color: Palette.grayFF),
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  print("회원수정");
                  String memberAddMode = "수정";
    
                  List<dynamic> args = [
                    memberAddMode,
                    widget.userInfo,
                  ];
    
                  await // 저장하기 성공시 Home로 이동
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberAdd(),
                      // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                      settings: RouteSettings(
                        arguments: args,
                      ),
                    ),
                  ).then(
                    (result) {
                      if (result != null) {
                        userInfo = result;
                      } else {
                        print("[MI]회원정보에서 수정후 삭제.. 연속닫기 - result / ${result}");
                        Navigator.pop(context);
                      }
                    },
                  );
    
                  //userInfo = result;
                  print("[MI]회원수정후 정보 받아오기 - userInfo / ${userInfo}");
                },
              ),
            ), */
            SizedBox(height: 80),
          ],
        ),
      );
    });
  }

  List<dynamic> makeChips(List<dynamic> resultChips, List<String> targetList,
      Color chipBackgroundColor) {
    resultChips = targetList
        .map((e) => Chip(
            label: Text(e),
            // onSelected: ((value) {
            //   setState(() {
            //     targetList.remove(e);
            //   });
            //   print("value : ${value}");
            // }),
            // selected: targetList.contains(e),
            labelStyle: TextStyle(fontSize: 12, color: Palette.gray00),
            // selectedColor: Palette.buttonOrange,
            backgroundColor: chipBackgroundColor,
            // showCheckmark: false,
            side: BorderSide(color: Palette.grayFF)))
        .toList();
    // .map((e) => Chip(
    //     label: Row(
    //       children: [
    //         Text(e),
    //         Icon(
    //           Icons.close_outlined,
    //           size: 14,
    //           color:
    //               targetList.contains(e) ? Palette.grayFF : Palette.gray99,
    //         )
    //       ],
    //     ),
    //     // onSelected: ((value) {
    //     //   setState(() {
    //     //     targetList.remove(e);
    //     //   });
    //     //   print("value : ${value}");
    //     // }),
    //     // selected: targetList.contains(e),
    //     labelStyle: TextStyle(fontSize: 12, color: Palette.grayFF),
    //     // selectedColor: Palette.buttonOrange,
    //     backgroundColor: Palette.buttonOrange,
    //     // showCheckmark: false,
    //     side: BorderSide(color: Palette.grayB4)))
    // .toList();

    print("[MI] makeChips : ${resultChips}");
    return resultChips;
  }
}

class NoteListActionCategory extends StatefulWidget {
  const NoteListActionCategory({
    Key? key,
    required this.docs,
    required this.userInfo,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<Object?>> docs;
  final UserInfo userInfo;

  @override
  State<NoteListActionCategory> createState() => _NoteListActionCategoryState();
}

// List lessonActionList = [];

//     lessonActionList = globalVariables.lessonNoteGlobalList
//                     .where((element) => element.lessonDate == lessonDate)
//                     .toList();

class _NoteListActionCategoryState extends State<NoteListActionCategory> {
  @override
  Widget build(BuildContext context) {
    // Set<List> setList;
    // setList = widget.docs
    //     .where(
    //         (doc) => doc['apparatusName'] != null && doc['actionName'] != null)
    //     .map((doc) => [doc['apparatusName'], doc['actionName']])
    //     .toSet();

    // return Container(
    //   constraints: BoxConstraints(maxWidth: 4720),
    //   padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
    //   width: MediaQuery.of(context).size.height * 100,
    //   child: ListView.separated(
    //     shrinkWrap: true,
    //     itemCount: widget.docs.length,
    //     itemBuilder: (context, index) {
    //       return IntrinsicHeight(
    //         child: Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             SizedBox(
    //               width: 210,
    //               child: Chip(
    //                   label: Text('Shoulder Adduction Double Arms',
    //                       style: TextStyle(fontSize: 12))),
    //             ),
    //             VerticalDivider(),
    //             SizedBox(width: 5),
    //             Container(
    //               constraints: BoxConstraints(maxWidth: 210),
    //               width: (MediaQuery.of(context).size.width - 272) *
    //                   actionNoteCount /
    //                   100,
    //               child: Container(
    //                 decoration: BoxDecoration(
    //                     color: Palette.buttonOrange,
    //                     borderRadius: BorderRadius.circular(10)),
    //                 width: 10,
    //               ),
    //             )
    //           ],
    //         ),
    //       );
    //     },
    //     separatorBuilder: (context, index) {
    //       return SizedBox(height: 2);
    //     },
    //   ),
    // );

    return GroupedListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      elements: widget.docs,
      groupBy: (element) => element['actionName'],
      groupSeparatorBuilder: (String value) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
        child: GroupActionContainer(actionName: value),
      ),
      itemBuilder: (BuildContext context, dynamic ddocs) {
        // 달력기능 개발 중
        // DateTime eventDate = DateTime.parse(
        //     docs['lessonDate'].toString());
        // eventList.add(eventDate);

        print("indexCheck : ${indexCheck}");

        print(
            "docID : ??? , apratusName : ${ddocs['apratusName']}, actionName :${ddocs['actionName']}, lessonDate : ${ddocs['lessonDate']}, grade: ${ddocs['grade']}, totalNote : ${ddocs['totalNote']}");
        indexCheck++;

        return ActionContainer(
            apratusName: ddocs['apratusName'],
            actionName: ddocs['actionName'],
            lessonDate: ddocs['lessonDate'],
            grade: ddocs['grade'],
            totalNote: ddocs['totalNote']);
      },
      itemComparator: (item1, item2) =>
          item2['lessonDate'].compareTo(item1['lessonDate']), // optional
      order: GroupedListOrder.ASC,
    );
  }
}

// String calDate = "2023-02-25";
class NoteListDateCategory extends StatefulWidget {
  const NoteListDateCategory({
    Key? key,
    required this.docs,
    required this.userInfo,
    required this.lessonService,
    required this.memberActionNote,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<Object?>> docs;
  final UserInfo userInfo;
  final LessonService lessonService;
  final memberActionNote;

  @override
  State<NoteListDateCategory> createState() => _NoteListDateCategoryState();
}

class _NoteListDateCategoryState extends State<NoteListDateCategory> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 16,
        ),
        FutureBuilder<QuerySnapshot>(
          future: widget.lessonService.readTodaynote(
            widget.userInfo.uid,
            widget.userInfo.docId,
          ),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? []; // 문서들 가져오기
            List<bool> isExpandedList = [];
            if (docs.isEmpty) {
              return Center(child: Text(" "));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (BuildContext context, int index) {
                final doc = docs[index];
                String memberId = widget.userInfo.docId;
                String name = doc.get('name');
                String lessonDate = doc.get('lessonDate');
                String todayNote = doc.get('todayNote');
                print("################  YYYY lessonDate : ${lessonDate}");

                /// lessonActionList 날짜로 필터 해줌
                lessonActionList = globalVariables.lessonNoteGlobalList
                    .where((element) => element.lessonDate == lessonDate)
                    .toList();

                print('###lessonActionList ${lessonActionList.length}');
                isExpandedList.add(false);

                return Offstage(
                  offstage: false, // calDate == lessonDate ? false : true,
                  child: InkWell(
                      onTap: () {
                        List<TmpLessonInfo> tmpLessonInfoList = [];
                        eventList = [];
                        lessonAddMode = "노트편집";
                        List<dynamic> args = [
                          userInfo,
                          lessonDate,
                          eventList,
                          lessonNoteId,
                          lessonAddMode,
                          tmpLessonInfoList,
                          resultActionList,
                          ticketCountLeft,
                          ticketCountAll
                        ];
                        print("args.length : ${args.length}");
                        print("[MI]LessonCard-lessonDate : ${lessonDate}");

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonAdd(),
                            // GlobalWidgetDashboard(), //
                            // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                            settings: RouteSettings(arguments: args),
                          ),
                        ).then((value) {});
                      },
                      child: LessonCardWidget(
                        userInfo: widget.userInfo,
                        memberId: memberId,
                        lessonDate: lessonDate,
                        todayNote: todayNote,
                        lessonActionList: lessonActionList,
                        isExpanded: isExpandedList[index],
                      )),
                );

                // return LessonCard(
                //   userInfo: widget.userInfo,
                //   memberId: memberId,
                //   lessonDate: lessonDate,
                //   todayNote: todayNote,
                //   lessonService: widget.lessonService,
                // );
              },
              separatorBuilder: ((context, index) => Container(
                    color: Palette.secondaryBackground,
                    height: 10,
                  )),
            );
          },
        ),
      ],
    );
  }
}

class LessonCard extends StatelessWidget {
  const LessonCard({
    Key? key,
    required this.userInfo,
    required this.memberId,
    required this.lessonDate,
    required this.todayNote,
    required this.lessonService,
  }) : super(key: key);

  final UserInfo userInfo;
  final String memberId;
  final String lessonDate;
  final String todayNote;
  final LessonService lessonService;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Palette.grayEE, width: 1),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          color: Palette.secondaryBackground,
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                List<TmpLessonInfo> tmpLessonInfoList = [];
                eventList = [];
                lessonAddMode = "노트편집";
                List<dynamic> args = [
                  userInfo,
                  lessonDate,
                  eventList,
                  lessonNoteId,
                  lessonAddMode,
                  tmpLessonInfoList,
                  resultActionList,
                ];
                print("args.length : ${args.length}");
                print("[MI]LessonCard-lessonDate : ${lessonDate}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonAdd(),
                    // GlobalWidgetDashboard(), //
                    // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                    settings: RouteSettings(arguments: args),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  //color: Palette.grayEE
                  color: Colors.red.withOpacity(0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    width: double.infinity,
                    height: 38,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              lessonDate,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Palette.gray33,
                              ),
                            ),
                            Spacer(flex: 1),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Palette.gray99,
                              size: 12.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Palette.grayFF,
                  //color: Palette.buttonOrange,
                  border: Border(
                      bottom: BorderSide(width: 1, color: Palette.grayEE))
                  //color: Colors.red.withOpacity(0),
                  ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 38,
                  ),
                  width: double.infinity,
                  //height: 38,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expanded(
                      //   child: Text(
                      //     todayNote,
                      //     //overflow: TextOverflow.fade,
                      //     maxLines: 3,
                      //     softWrap: true,
                      //     style:
                      //         Theme.of(context).textTheme.bodyText1!.copyWith(
                      //               fontSize: 14.0,
                      //             ),
                      //   ),
                      // ),
                      Text(
                        "${todayNote}",
                        overflow: TextOverflow.fade,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Palette.gray66,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Palette.grayFF,
                //color: Colors.red.withOpacity(0),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 10,
              ),
            ),
            FutureBuilder<QuerySnapshot>(
              future: lessonService.readNotesOflessonDate(
                userInfo.uid,
                memberId,
                lessonDate,
              ),
              builder: (context, snapshot) {
                final lessonData = snapshot.data?.docs ?? []; // 문서들 가져오기
                // if (lessonData.isEmpty) {
                //   return Container(
                //       decoration: BoxDecoration(
                //         color: Palette.grayFF,
                //         //color: Colors.red.withOpacity(0),
                //       ),
                //       child: Text("123"));
                // }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: lessonData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final doc = lessonData[index];
                    int pos = doc.get('pos');
                    String actionName = doc.get('actionName');
                    String apratusName = doc.get('apratusName');
                    String totalNote = doc.get('totalNote');
                    // 날짜 글자 자르기
                    if (lessonDate.length > 0) {
                      lessonDateTrim = lessonDate.substring(2, 10);
                    }
                    // 기구 첫두글자 자르기
                    if (apratusName.length > 0) {
                      apratusNameTrim = apratusName.substring(0, 2);
                    }

                    return Container(
                        decoration: BoxDecoration(
                          color: Palette.grayFF,
                          //color: Colors.red.withOpacity(0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 14.0,
                            right: 14.0,
                            top: 5.0,
                          ),
                          child: SizedBox(
                            //height: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(index.toString() + " - "),
                                Text(
                                  apratusNameTrim,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.gray66,
                                  ),
                                  // style: Theme.of(context)
                                  //     .textTheme
                                  //     .bodyText1!
                                  //     .copyWith(
                                  //       fontSize: 12.0,
                                  //     ),
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  actionName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.gray66,
                                  ),
                                  // style: Theme.of(context)
                                  //     .textTheme
                                  //     .bodyText1!
                                  //     .copyWith(
                                  //       fontSize: 12.0,
                                  //     ),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    totalNote,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: true,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                          fontSize: 12.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ));
                  },

                  //   Text(
                  //       "${pos.toString()}-${actionName}-${aparatusName}-${totalNote}");
                  // },
                  separatorBuilder: ((context, index) => Divider(
                        height: 0,
                      )),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Palette.grayFF, width: 1),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                color: Palette.grayFF,
              ),
              child: const SizedBox(
                width: double.infinity,
                height: 20,
              ),
            )
          ],
        ));
  }
}
