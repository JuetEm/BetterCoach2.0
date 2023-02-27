import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/app/data/provider/memberTicket_service.dart';
import 'package:web_project/app/ui/page/memberInfo.dart';
import 'package:web_project/app/ui/page/memberTicketList.dart';
import 'package:web_project/app/ui/page/ticketLibraryList.dart';
import 'package:web_project/app/data/provider/auth_service.dart';
import 'package:web_project/app/ui/widget/baseTableCalendar.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/function/globalFunction.dart';
import 'package:web_project/app/ui/widget/globalWidget.dart';
import 'package:web_project/app/ui/page/locationAdd.dart';
import 'package:web_project/main.dart';
import 'package:web_project/app/ui/widget/ticketWidget.dart';
import 'package:web_project/app/data/model/userInfo.dart';

GlobalFunction globalFunction = GlobalFunction();

String screenName = "수강권 추가";

String calendarName = "";

bool isTicketTitleOffStaged = true;
bool calendarIsOffStaged = true;
String selectedticketName = "";

List<DropDownValueModel> tickets = [
  DropDownValueModel(name: '직접입력', value: '직접입력', toolTipMsg: '직접입력')
];

late SingleValueDropDownController ticketMakeController;

late FocusNode textFieldFocusNode;

late TextEditingController ticketCountLeftController;
late TextEditingController ticketCountAllController;
late TextEditingController ticketTitleController;
late TextEditingController ticketDescriptionController;
late TextEditingController ticketStartDateController;
late TextEditingController ticketEndDateController;
late TextEditingController ticketDateLeftController;

int ticketUsingCount = 0;

int ticketCountLeft = 0;
int ticketCountAll = 0;
String ticketTitle = "";
String ticketDescription = "";
String ticketStartDate = "";
String ticketEndDate = "";
int ticketDateLeft = 0;

bool isFirst = true;

bool isContainedCheck(List checkList, String memberId, String tickeTitle) {
  bool isContained = false;

  for (int i = 0; i < checkList.length; i++) {
    if (checkList[i]['memberId'] == memberId) {
      if (checkList[i]['ticketTitle'] == tickeTitle) {
        isContained = true;
        break;
      }
    }
  }
  return isContained;
}

String getTodayDate() {
  String today = "";

  today = DateFormat("yyyy-MM-dd").format(DateTime.now());
  print("today : ${today}");
  return today.substring(0, 10);
}

String getMonthLateDate() {
  String today = "";

  DateTime now = DateTime.now();

  today = DateFormat("yyyy-MM-dd")
      .format(DateTime(now.year, now.month + 1, now.day - 1));
  print("month today : ${today}");
  return today.substring(0, 10);
}

class MemberTicketMake extends StatefulWidget {
  UserInfo? userInfo;
  String? ticketTitle;
  MemberTicketMake(this.userInfo, this.ticketTitle, {super.key});
  MemberTicketMake.getUserInfo(this.userInfo, {super.key});

  @override
  State<MemberTicketMake> createState() => _MemberTicketMakeState();
}

class _MemberTicketMakeState extends State<MemberTicketMake> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    analyticLog.sendAnalyticsEvent(
        screenName, "수강권추가_이벤트_init", "init 테스트 스트링", "init 테스트 파라미터");

    ticketMakeController = SingleValueDropDownController();
    textFieldFocusNode = FocusNode();

    ticketCountLeftController = TextEditingController();
    ticketCountAllController = TextEditingController();
    ticketTitleController = TextEditingController();
    ticketDescriptionController = TextEditingController();
    ticketStartDateController = TextEditingController();
    ticketEndDateController = TextEditingController();
    ticketDateLeftController = TextEditingController();

    ticketStartDateController.text = getTodayDate();
    ticketStartDate = getTodayDate();
    ticketEndDateController.text = getMonthLateDate();
    ticketEndDate = getMonthLateDate();

    ticketDateLeft = globalFunction.getDDayLeft(ticketEndDate);

    calendarName = "";

    isTicketTitleOffStaged = true;

    isFirst = true;

    // widget.ticketTitle = null;
    // print("widget.ticketTitle : ${widget.ticketTitle}");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    ticketMakeController.dispose();
    textFieldFocusNode.dispose();

    ticketCountLeftController.dispose();
    ticketCountAllController.dispose();
    ticketTitleController.dispose();
    ticketDescriptionController.dispose();
    ticketStartDateController.dispose();
    ticketEndDateController.dispose();

    ticketCountLeft = 0;
    ticketCountAll = 0;
    ticketTitle = "";
    ticketDescription = "";
    ticketStartDate = "";
    ticketEndDate = "";
    ticketDateLeft = 0;

    calendarName = "";

    isTicketTitleOffStaged = true;

    isFirst = true;

    // widget.ticketTitle = null;
  }

  @override
  Widget build(BuildContext context) {
    tickets = [
      DropDownValueModel(
          name: '직접입력', value: userInfo.docId, toolTipMsg: '직접입력'),
    ];

    // 수강권 선택해서 들어오는 경우 값 매치 해주기
    if (widget.ticketTitle != null && isFirst) {
      for (int i = 0; i < globalVariables.memberTicketList.length; i++) {
        if (widget.ticketTitle ==
                globalVariables.memberTicketList[i]['ticketTitle'] &&
            widget.userInfo!.docId ==
                globalVariables.memberTicketList[i]['memberId']) {
          var model = DropDownValueModel(
              name: globalVariables.memberTicketList[i]['ticketTitle'],
              value: userInfo.docId,
              toolTipMsg: globalVariables.memberTicketList[i]['id']);
          ticketMakeController.setDropDown(model);
          ticketCountAllController.text =
              globalVariables.memberTicketList[i]['ticketCountAll'].toString();
          ticketCountAll =
              globalVariables.memberTicketList[i]['ticketCountAll'];
          ticketTitleController.text =
              globalVariables.memberTicketList[i]['ticketTitle'];
          ticketTitle = globalVariables.memberTicketList[i]['ticketTitle'];
          ticketDescriptionController.text =
              globalVariables.memberTicketList[i]['ticketDescription'];
          ticketDescription =
              globalVariables.memberTicketList[i]['ticketDescription'];
          // 변수 초기화
          // widget.ticketTitle = null;
          isFirst = false;
          break;
        }
      }

      for (var ticketVal in globalVariables.memberTicketList) {
        // print("ticketVal : $ticketVal");
        if (ticketVal['memberId'] == widget.userInfo!.docId) {
          var model = DropDownValueModel(
              name: ticketVal['ticketTitle'],
              value: userInfo.docId,
              toolTipMsg: ticketVal['id']);
          tickets.add(model);
        }
      }
    } else {
      for (var ticketVal in globalVariables.ticketLibraryList) {
        // print("ticketVal : $ticketVal");
        if (ticketVal['uid'] == widget.userInfo!.uid) {
          var model = DropDownValueModel(
              name: ticketVal['ticketTitle'],
              value: userInfo.docId,
              toolTipMsg: ticketVal['id']);
          tickets.add(model);
        }
      }
    }
    return Consumer<MemberTicketService>(
      builder: (context, memberTicketService, child) {
        return Scaffold(
          appBar: BaseAppBarMethod(context, "수강권 추가", () {
            Navigator.pop(context, widget.userInfo);
          }, [
            TextButton(
              onPressed: () async {
                if (DateTime.parse(ticketEndDateController.text).difference(
                        DateTime.parse(ticketStartDateController.text)) <
                    Duration.zero) {
                  return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('수강권을 저장할 수 없음'),
                        content: Text('수강 시작일은 수강 종료일 이전이어야 합니다.'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                '확인',
                                style: TextStyle(
                                    color: Palette.textRed, fontSize: 16),
                              ))
                        ],
                      );
                    },
                  );
                }

                ticketDateLeft = globalFunction.getDDayLeft(ticketEndDate);
                print(
                    "MemberTicketMake AppBar TextButton is called! ticketMakeController.dropDownValue?.value.toString().trim() : ${ticketMakeController.dropDownValue?.value.toString().trim()}");
                /* List tmpNameList = [];
                globalVariables.memberTicketList.forEach((element) {
                  tmpNameList.add(element['ticketTitle']);
                }); */
                if (ticketMakeController.dropDownValue?.name
                        .toString()
                        .trim() ==
                    null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("수강권을 선택하세요."),
                  ));
                } else if (isTicketTitleOffStaged == false &&
                    ticketTitleController.text.trim() == "") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("수강권 명을 입력하세요."),
                  ));
                } else if (isTicketTitleOffStaged == false &&
                    isContainedCheck(
                        globalVariables.memberTicketList,
                        ticketMakeController.dropDownValue!.value,
                        ticketTitleController.text.trim())) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("같은 이름의 수강권이 존재합니다. 다른 이름을 사용해주세요."),
                  ));
                } else if (ticketCountAllController.text.trim() == "") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("수강 횟수를 입력하세요."),
                  ));
                } /* else if (ticketStartDateController.text.trim() == "") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("수강 시작일을 선택하세요."),
                  ));
                } else if (ticketEndDateController.text.trim() == "") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("수강 종료일을 선택하세요."),
                  ));
                }  */
                else if (ticketDescriptionController.text.trim() == "") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("수강권 설명을 입력하세요."),
                  ));
                } else {
                  if (widget.ticketTitle == null) {
                    if (isContainedCheck(
                        globalVariables.memberTicketList,
                        ticketMakeController.dropDownValue!.value,
                        ticketTitleController.text.trim())) {
                      ticketCountLeft = ticketCountAll;
                      memberTicketService
                          .update(
                        AuthService().currentUser()!.uid,
                        ticketMakeController.dropDownValue!.toolTipMsg
                            .toString(),
                        ticketMakeController.dropDownValue!.value,
                        ticketUsingCount,
                        ticketCountLeft,
                        ticketCountAll,
                        ticketTitle,
                        ticketDescription,
                        Timestamp.fromDate(DateTime.parse(ticketStartDate))
                            .toDate(),
                        Timestamp.fromDate(DateTime.parse(ticketEndDate))
                            .toDate(),
                        ticketDateLeft,
                        Timestamp.fromDate(DateTime.now()).toDate(),
                        false,
                        true,
                      )
                          .then((value) {
                        print("${screenName} - 티켓 라이브러리 생성 update is called!");
                        for (int i = 0;
                            i < globalVariables.memberTicketList.length;
                            i++) {
                          if (ticketTitle ==
                              globalVariables.memberTicketList[i]
                                  ['ticketTitle']) {
                            globalVariables.memberTicketList[i]
                                ['ticketCountAll'] = ticketCountAll;
                            globalVariables.memberTicketList[i]
                                ['ticketUsingCount'] = 0;
                            globalVariables.memberTicketList[i]
                                ['ticketDateLeft'] = ticketDateLeft;
                            globalVariables.memberTicketList[i]
                                    ['ticketEndDate'] =
                                Timestamp.fromDate(
                                    DateTime.parse(ticketEndDate));
                            globalVariables.memberTicketList[i]['uid'] =
                                AuthService().currentUser()!.uid;
                            globalVariables.memberTicketList[i]
                                ['ticketCountLeft'] = ticketCountLeft;
                            globalVariables.memberTicketList[i]['createDate'] =
                                Timestamp.fromDate(DateTime.now()).toDate();
                            globalVariables.memberTicketList[i]
                                ['ticketDescription'] = ticketDescription;
                            globalVariables.memberTicketList[i]
                                    ['ticketStartDate'] =
                                Timestamp.fromDate(
                                    DateTime.parse(ticketStartDate));
                            globalVariables.memberTicketList[i]['isSelected'] =
                                false;
                            globalVariables.memberTicketList[i]['isAlive'] =
                                true;
                            print(
                                "update globalVariables.memberTicketList : ${globalVariables.memberTicketList}");
                            break;
                          }
                        }
                        Navigator.pop(context);
                      });
                    } else {
                      ticketCountLeft = ticketCountAll;
                      await memberTicketService
                          .create(
                        AuthService().currentUser()!.uid,
                        ticketMakeController.dropDownValue!.value,
                        ticketUsingCount,
                        ticketCountLeft,
                        ticketCountAll,
                        ticketTitle,
                        ticketDescription,
                        Timestamp.fromDate(DateTime.parse(ticketStartDate))
                            .toDate(),
                        Timestamp.fromDate(DateTime.parse(ticketEndDate))
                            .toDate(),
                        ticketDateLeft,
                        Timestamp.fromDate(DateTime.now()).toDate(),
                        false,
                        true,
                      )
                          .then((value) {
                        print("${screenName} - 티켓 라이브러리 생성 create is called!");

                        globalVariables.memberTicketList.add({
                          "ticketCountAll": ticketCountAll,
                          "ticketUsingCount": 0,
                          "ticketDateLeft": ticketDateLeft,
                          "ticketEndDate":
                              Timestamp.fromDate(DateTime.parse(ticketEndDate)),
                          "uid": AuthService().currentUser()!.uid,
                          "ticketCountLeft": ticketCountLeft,
                          "createDate":
                              Timestamp.fromDate(DateTime.now()).toDate(),
                          "ticketDescription": ticketDescription,
                          "ticketStartDate": Timestamp.fromDate(
                              DateTime.parse(ticketStartDate)),
                          "ticketTitle": ticketTitle,
                          "memberId": ticketMakeController.dropDownValue!.value,
                          "id": value,
                          "isSelected": false,
                          "isAlive": true,
                        });
                        globalVariables.memberTicketList.sort((a, b) =>
                            (a['ticketTitle']).compareTo(b['ticketTitle']));
                        print(
                            "create globalVariables.memberTicketList : ${globalVariables.memberTicketList}");

                        Navigator.pop(context);
                      });
                    }
                  } else {
                    if (isTicketTitleOffStaged) {
                      ticketCountLeft = ticketCountAll;
                      memberTicketService
                          .update(
                        AuthService().currentUser()!.uid,
                        ticketMakeController.dropDownValue!.toolTipMsg
                            .toString(),
                        ticketMakeController.dropDownValue!.value,
                        ticketUsingCount,
                        ticketCountLeft,
                        ticketCountAll,
                        ticketTitle,
                        ticketDescription,
                        Timestamp.fromDate(DateTime.parse(ticketStartDate))
                            .toDate(),
                        Timestamp.fromDate(DateTime.parse(ticketEndDate))
                            .toDate(),
                        ticketDateLeft,
                        Timestamp.fromDate(DateTime.now()).toDate(),
                        false,
                        true,
                      )
                          .then((value) {
                        print("${screenName} - 티켓 라이브러리 생성 update is called!");
                        for (int i = 0;
                            i < globalVariables.memberTicketList.length;
                            i++) {
                          if (ticketTitle ==
                              globalVariables.memberTicketList[i]
                                  ['ticketTitle']) {
                            globalVariables.memberTicketList[i]
                                ['ticketCountAll'] = ticketCountAll;
                            globalVariables.memberTicketList[i]
                                ['ticketUsingCount'] = 0;
                            globalVariables.memberTicketList[i]
                                ['ticketDateLeft'] = ticketDateLeft;
                            globalVariables.memberTicketList[i]
                                    ['ticketEndDate'] =
                                Timestamp.fromDate(
                                    DateTime.parse(ticketEndDate));
                            globalVariables.memberTicketList[i]['uid'] =
                                AuthService().currentUser()!.uid;
                            globalVariables.memberTicketList[i]
                                ['ticketCountLeft'] = ticketCountLeft;
                            globalVariables.memberTicketList[i]['createDate'] =
                                Timestamp.fromDate(DateTime.now()).toDate();
                            globalVariables.memberTicketList[i]
                                ['ticketDescription'] = ticketDescription;
                            globalVariables.memberTicketList[i]
                                    ['ticketStartDate'] =
                                Timestamp.fromDate(
                                    DateTime.parse(ticketStartDate));
                            globalVariables.memberTicketList[i]['isSelected'] =
                                false;
                            globalVariables.memberTicketList[i]['isAlive'] =
                                true;
                            print(
                                "update globalVariables.memberTicketList : ${globalVariables.memberTicketList}");
                            break;
                          }
                        }
                        Navigator.pop(context);
                      });
                    } else {
                      ticketCountLeft = ticketCountAll;
                      await memberTicketService
                          .create(
                        AuthService().currentUser()!.uid,
                        ticketMakeController.dropDownValue!.value,
                        ticketUsingCount,
                        ticketCountLeft,
                        ticketCountAll,
                        ticketTitle,
                        ticketDescription,
                        Timestamp.fromDate(DateTime.parse(ticketStartDate))
                            .toDate(),
                        Timestamp.fromDate(DateTime.parse(ticketEndDate))
                            .toDate(),
                        ticketDateLeft,
                        Timestamp.fromDate(DateTime.now()).toDate(),
                        false,
                        true,
                      )
                          .then((value) {
                        print("${screenName} - 티켓 라이브러리 생성 create is called!");

                        globalVariables.memberTicketList.add({
                          "ticketCountAll": ticketCountAll,
                          "ticketUsingCount": 0,
                          "ticketDateLeft": ticketDateLeft,
                          "ticketEndDate":
                              Timestamp.fromDate(DateTime.parse(ticketEndDate)),
                          "uid": AuthService().currentUser()!.uid,
                          "ticketCountLeft": ticketCountLeft,
                          "createDate":
                              Timestamp.fromDate(DateTime.now()).toDate(),
                          "ticketDescription": ticketDescription,
                          "ticketStartDate": Timestamp.fromDate(
                              DateTime.parse(ticketStartDate)),
                          "ticketTitle": ticketTitle,
                          "memberId": ticketMakeController.dropDownValue!.value,
                          "id": value,
                          "isSelected": false,
                          "isAlive": true,
                        });
                        globalVariables.memberTicketList.sort((a, b) =>
                            (a['ticketTitle']).compareTo(b['ticketTitle']));
                        print(
                            "create globalVariables.memberTicketList : ${globalVariables.memberTicketList}");

                        Navigator.pop(context);
                      });
                    }
                  }
                }
              },
              child: Text(
                "완료",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ], null),
          body: CenterConstrainedBody(
            child: Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /// 수강권 명 입력
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("수강권 명",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 200),
                                        child: AlertDialog(
                                          title: Row(
                                            children: [
                                              Text('수강권명'),
                                              Spacer(),
                                              TextButton(
                                                child: Text("완료"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                          // titlePadding: EdgeInsets.all(0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                          content: widget.ticketTitle != null
                                              ? MemberTicketList(
                                                  widget.userInfo!.docId,
                                                  globalVariables
                                                      .memberTicketList,
                                                  () {
                                                    if (globalVariables
                                                        .memberTicketList
                                                        .isEmpty) {
                                                      ticketMakeController
                                                          .setDropDown(
                                                        DropDownValueModel(
                                                            name: '직접입력',
                                                            value:
                                                                userInfo.docId,
                                                            toolTipMsg: '직접입력'),
                                                      );
                                                      ticketTitle = "";
                                                      ticketTitleController
                                                          .text = "";
                                                      ticketCountAll = 0;
                                                      ticketCountAllController
                                                              .text =
                                                          ticketCountAll
                                                              .toString();
                                                      ticketStartDate = "";
                                                      ticketStartDateController
                                                          .text = "";
                                                      ticketEndDate = "";
                                                      ticketEndDateController
                                                          .text = "";
                                                      ticketDescription = "";
                                                      ticketDescriptionController
                                                          .text = "";
                                                      ticketCountLeft = 0;
                                                      ticketCountLeftController
                                                              .text =
                                                          ticketCountLeft
                                                              .toString();
                                                    }

                                                    setState(() {});
                                                  },
                                                )
                                              : TicketLibraryList(
                                                  globalVariables
                                                      .ticketLibraryList,
                                                  () {}),
                                        ));
                                  });
                            },
                            child: Text(
                              "편집",
                              style: TextStyle(
                                  fontSize: 16, color: Palette.statusRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropDownTextField(
                      controller: ticketMakeController,
                      isEnabled: true,
                      clearOption: false,
                      enableSearch: true,
                      textFieldFocusNode: textFieldFocusNode,
                      // searchFocusNode: searchFocusNode,
                      clearIconProperty: IconProperty(
                          icon: Icons.close, color: Palette.gray66),
                      textFieldDecoration: InputDecoration(
                        hintText: "수강권을 선택하세요.",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.all(20),
                        fillColor: Colors.white,
                      ),
                      searchDecoration: InputDecoration(
                        hintText: "검색하고 싶은 수강권을 입력하세요",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.all(16),
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        print("position validator value : ${value}");
                        if (value == null) {
                          return "required field";
                        } else {
                          return null;
                        }
                      },
                      dropDownItemCount: tickets.length,
                      dropDownList: tickets,
                      onChanged: (val) {
                        print("position onChange val : ${val}");
                        print(
                            "ticketMakeController.dropDownValue : ${ticketMakeController.dropDownValue!.name}");
                        selectedticketName =
                            ticketMakeController.dropDownValue!.name;

                        if (selectedticketName == "직접입력") {
                          isTicketTitleOffStaged = false;
                          ticketTitle = "";
                          ticketTitleController.text = "";

                          ticketCountAll = 0;
                          ticketCountAllController.text = "";

                          ticketStartDate = getTodayDate();
                          ticketStartDateController.text = getTodayDate();

                          ticketEndDate = getMonthLateDate();
                          ticketEndDateController.text = getMonthLateDate();

                          ticketDescription = "";
                          ticketDescriptionController.text = "";
                        } else {
                          isTicketTitleOffStaged = true;
                          ticketTitle = selectedticketName;

                          if (widget.ticketTitle == null) {
                            for (var ticketVal
                                in globalVariables.ticketLibraryList) {
                              if (ticketVal['ticketTitle'] == ticketTitle &&
                                  ticketVal['uid'] ==
                                      AuthService().currentUser()!.uid) {
                                ticketCountAll = ticketVal['ticketCountAll'];
                                ticketCountAllController.text =
                                    ticketCountAll.toString();

                                ticketStartDate = getTodayDate();
                                ticketStartDateController.text =
                                    ticketStartDate;

                                ticketEndDate = getMonthLateDate();
                                ticketEndDateController.text = ticketEndDate;

                                ticketDescription =
                                    ticketVal['ticketDescription'];
                                ticketDescriptionController.text =
                                    ticketDescription;

                                break;
                              }
                            }
                          } else {
                            for (var ticketVal
                                in globalVariables.memberTicketList) {
                              if (ticketVal['ticketTitle'] == ticketTitle &&
                                  ticketVal['memberId'] ==
                                      widget.userInfo!.docId) {
                                ticketCountAll = ticketVal['ticketCountAll'];
                                ticketCountAllController.text =
                                    ticketCountAll.toString();

                                ticketStartDate =
                                    globalFunction.getDateFromTimeStamp(
                                        ticketVal['ticketStartDate']);
                                ticketStartDateController.text =
                                    ticketStartDate;

                                ticketEndDate =
                                    globalFunction.getDateFromTimeStamp(
                                        ticketVal['ticketEndDate']);
                                ticketEndDateController.text = ticketEndDate;

                                ticketDescription =
                                    ticketVal['ticketDescription'];
                                ticketDescriptionController.text =
                                    ticketDescription;

                                break;
                              }
                            }
                          }
                        }
                        setState(() {});
                      },
                    ),

                    /// 직접 입력 선택 시
                    Offstage(
                      offstage: isTicketTitleOffStaged,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: TextField(
                          maxLength: 12,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          onChanged: (value) {
                            ticketTitle = value;
                            setState(() {});
                          },
                          controller: ticketTitleController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Palette.grayFF,
                            // labelText: '수강권 이름',
                            hintText: '수강권 이름을 입력하세요',
                            labelStyle: TextStyle(color: Palette.gray00),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                  width: 1, color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                  width: 1, color: Colors.transparent),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                          // keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// 수강 횟수 입력
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        children: [
                          Text("수강 횟수",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: TextField(
                        maxLength: 3,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            ticketCountAll = int.parse(value);
                          }

                          setState(() {});
                        },
                        controller: ticketCountAllController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Palette.grayFF,
                          // labelText: '수강 횟수',
                          hintText: '수강 횟수를 입력하세요',
                          labelStyle: TextStyle(color: Palette.gray00),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.transparent),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  children: [
                                    Text("수강 시작일",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 4, 8),
                                child: InkWell(
                                  onTap: () {
                                    print("수강 시작일 inkWell onTap called!");
                                    calendarIsOffStaged = false;
                                    calendarName = "수강 시작일";
                                    setState(() {});
                                  },
                                  child: TextField(
                                    controller: ticketStartDateController,
                                    onTap: () {
                                      print("수강 시작일 Textfiled onTap called!");
                                    },
                                    style: TextStyle(
                                        color: calendarName == "수강 시작일"
                                            ? Palette.textRed
                                            : Palette.gray00),
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Palette.grayFF,
                                      // labelText: '수강 시작일',
                                      hintText: '수강권 시작일을 입력하세요',
                                      labelStyle:
                                          TextStyle(color: Palette.gray00),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.transparent),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.transparent),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.transparent),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                      ),
                                    ),
                                    // keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// 수강 종료일 선택
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  children: [
                                    Text("수강 종료일",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
                                child: InkWell(
                                  onTap: () {
                                    print("수강 종료일 inkWell onTap called!");
                                    calendarIsOffStaged = false;
                                    calendarName = "수강 종료일";
                                    setState(() {});
                                  },
                                  child: TextField(
                                    controller: ticketEndDateController,
                                    onTap: () {
                                      print("수강 종료일 TextField onTap called!");
                                    },
                                    style: TextStyle(
                                        decoration: DateTime.parse(
                                                        ticketEndDateController
                                                            .text)
                                                    .difference(DateTime.parse(
                                                        ticketStartDateController
                                                            .text)) <
                                                Duration.zero
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: calendarName == "수강 종료일"
                                            ? Palette.textRed
                                            : Palette.gray00),
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Palette.grayFF,
                                      // labelText: '수강 종료일',
                                      hintText: '수강권 종료일을 입력하세요',
                                      labelStyle:
                                          TextStyle(color: Palette.gray00),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.transparent),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.transparent),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.transparent),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                      ),
                                    ),
                                    // keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    Offstage(
                      offstage: calendarIsOffStaged,
                      child: Container(
                        constraints: BoxConstraints.tight(Size.fromHeight(530)),
                        child: BaseTableCalendar(() {
                          calendarIsOffStaged = !calendarIsOffStaged;
                          // git test
                          print("ticketStartDate : $ticketStartDate}");
                          print("ticketEndDate : $ticketEndDate}");
                          setState(() {});
                        }, true,
                            selectedDate: "",
                            pageName: calendarName,
                            eventList: [],
                            hideBottonDateText: false,
                            hideButton: false),
                      )
                          .animate(target: !calendarIsOffStaged ? 1 : 0)
                          .fadeIn(duration: 300.ms)
                          .animate(target: calendarIsOffStaged ? 1 : 0)
                          .fadeOut(duration: 300.ms),
                    ),

                    /// 수강권 설명
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        children: [
                          Text("수강권 설명",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: TextField(
                        maxLength: 30,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        onChanged: (value) {
                          ticketDescription = value;
                          setState(() {});
                        },
                        controller: ticketDescriptionController,
                        minLines: 3,
                        maxLines: 20,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(20),
                          filled: true,
                          fillColor: Palette.grayFF,
                          // labelText: '수강권 설명',
                          hintText: '예) 신규 20회 + 이벤트로 서비스 3회 드림',
                          labelStyle: TextStyle(color: Palette.gray00),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.transparent),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                        // keyboardType: TextInputType.emailAddress,
                      ),
                    ),

                    /// 수강권 미리보기
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        children: [
                          Text("미리보기",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    TicketWidget(
                      customFunctionOnTap: () {},
                      // customFunctionOnHover: (){},
                      ticketCountLeft: ticketCountAll,
                      ticketCountAll: ticketCountAll,
                      ticketTitle: ticketTitle,
                      ticketDescription: ticketDescription,
                      ticketStartDate: ticketStartDate,
                      ticketEndDate: ticketEndDate,
                    )
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
