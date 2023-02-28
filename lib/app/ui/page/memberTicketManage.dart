import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/app/data/provider/memberTicket_service.dart';
import 'package:web_project/app/ui/page/memberInfo.dart';
import 'package:web_project/app/ui/page/memberList.dart';
import 'package:web_project/app/data/provider/auth_service.dart';
import 'package:web_project/app/ui/page/memberTicketMake.dart';
import 'package:web_project/app/ui/page/ticketLibraryMake.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/function/globalFunction.dart';
import 'package:web_project/app/ui/widget/globalWidget.dart';
import 'package:web_project/main.dart';
import 'package:web_project/app/ui/widget/ticketWidget.dart';
import 'package:web_project/app/data/model/userInfo.dart';
import 'package:web_project/app/ui/widget/ticketWidget.dart';

int ticketCnt = 0; // 사용가능한 수강권 개수
int expiredTicketCnt = 0; // 만료된 수강권 개수

GlobalFunction globalFunction = GlobalFunction();

bool favoriteMember = true;

/**메인으로 사용하는 리스트 함수, uid, memberId로 filtering 된다. */
List ticketList = [];

/** 사용가능한 수강권 리스트 열렸는지 */
bool isActiveTicketListOpened = true;

/** 만료된 수강권 리스트 열렸는지 */
bool isExpiredTicketListOpened = true;

int getListCnt(List tList, bool checkVal) {
  int cnt = 0;
  for (var i in tList) {
    // print("Active cnt : ${i}");
    if (i['isAlive'] == checkVal && i['memberId'] == userInfo.docId) {
      cnt++;
    }
  }
  return cnt;
}

class MemberTicketManage extends StatefulWidget {
  UserInfo? userInfo;
  List? memberTList;
  MemberTicketManage({super.key});
  MemberTicketManage.getUserInfo(this.memberTList, this.userInfo, {super.key});

  @override
  State<MemberTicketManage> createState() => _MemberTicketManageState();
}

class _MemberTicketManageState extends State<MemberTicketManage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberTicketService>(
      builder: (context, memberTicketService, child) {
        /// 메인으로 사용하는 리스트를 글로벌에서 불러와 멤버아이디로 필터링해준다.
        ticketList = globalVariables.memberTicketList
            .where((element) => element['memberId'] == userInfo.docId)
            // .toSet()
            .toList();

        // print('####Timmy ticketList: $ticketList');
        // print('####Timmy ticketList.length: ${ticketList.length}');
        // print(
        //     '####Timmy globalVariables.memberTicketList.length: ${globalVariables.memberTicketList.length}');

        return Scaffold(
          backgroundColor: Palette.secondaryBackground,
          appBar: BaseAppBarMethod(context, "수강권 관리", () {
            /// pop할 시 컨텐츠
            for (int i = 0; i < ticketList.length; i++) {
              var element = ticketList[i];

              if (element['isSelected'] == true) {
                Navigator.pop(context, i);
                break;
              } else if (globalVariables.memberTicketList.length - 1 == i) {
                Navigator.pop(context, -1);
              }
            }
          }, [
            TextButton(
                onPressed: () {
                  int tmpIndex = 0;
                  ticketList = widget.memberTList!;
                  for (int i = 0; i < ticketList.length; i++) {
                    var element = ticketList[i];

                    if (element['isSelected'] == true) {
                      memberTicketService
                          .update(
                            AuthService().currentUser()!.uid,
                            element['id'],
                            widget.userInfo!.docId,
                            element['ticketUsingCount'],
                            element['ticketCountLeft'],
                            element['ticketCountAll'],
                            element['ticketTitle'],
                            element['ticketDescription'],
                            DateTime.parse(globalFunction.getDateFromTimeStamp(
                                element['ticketStartDate'])),
                            DateTime.parse(globalFunction.getDateFromTimeStamp(
                                element['ticketEndDate'])),
                            element['ticketDateLeft'],
                            DateTime.now(),
                            element['isSelected'],
                            element['isAlive'],
                          )
                          .then((value) {});
                      tmpIndex = i;
                      break;
                    }
                  }
                  Navigator.pop(context, tmpIndex);
                },
                child: Text(
                  "완료",
                  style: TextStyle(fontSize: 16),
                ))
          ], null),
          body: CenterConstrainedBody(
            child: SafeArea(
              child: Column(
                children: [
                  /// 헤더: 회원명/전화번호/등록일
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder(
                            future: globalFunction.readfavoriteMember(
                                widget.userInfo!.uid, widget.userInfo!.docId),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
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
                                    "[TM] 즐겨찾기 로딩후 : ${snapshot.data} / ${widget.userInfo!.docId}");
                                favoriteMember = snapshot.data;
                                return IconButton(
                                    icon: SvgPicture.asset(
                                      favoriteMember
                                          ? "assets/icons/favoriteSelected.svg"
                                          : "assets/icons/favoriteUnselected.svg",
                                    ),
                                    iconSize: 40,
                                    onPressed: () async {
                                      favoriteMember = !favoriteMember;

                                      await memberService.updateIsFavorite(
                                          widget.userInfo!.docId,
                                          favoriteMember);
                                      int rstLnth =
                                          globalVariables.resultList.length;
                                      for (int i = 0; i < rstLnth; i++) {
                                        if (widget.userInfo!.docId ==
                                            globalVariables.resultList[i]
                                                ['id']) {
                                          print(
                                              "memberInfo - widget.resultMemberList[${i}]['id'] : ${globalVariables.resultList[i]['id']}");
                                          if (globalVariables.resultList[i]
                                                  ['isFavorite'] ==
                                              null) {
                                            globalVariables.resultList[i]
                                                ['isFavorite'] = true;
                                          } else {
                                            globalVariables.resultList[i]
                                                    ['isFavorite'] =
                                                !globalVariables.resultList[i]
                                                    ['isFavorite'];
                                          }

                                          break;
                                        }
                                      }

                                      print(
                                          "[TM] 즐겨찾기 변경 클릭 : 변경후 - ${favoriteMember} / ${widget.userInfo!.docId}");
                                      setState(() {
                                        print("ticketManage setState called!");
                                      });
                                    });
                              }
                            }),

                        // 이름, 전화번호
                        Container(
                          constraints: BoxConstraints(maxWidth: 150),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.userInfo!.name}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '${widget.userInfo!.phoneNumber}',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    //fontWeight: FontWeight.bold,
                                    color: Palette.gray66),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        // 등록일
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '등록일',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  //fontWeight: FontWeight.bold,
                                  color: Palette.gray99),
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              '${widget.userInfo!.registerDate}',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  //fontWeight: FontWeight.bold,
                                  color: Palette.gray99),
                              textAlign: TextAlign.right,
                            ),
                            // Text(
                            //   '남은횟수 : ${userInfo.registerType}',
                            //   style: TextStyle(
                            //       fontSize: 14.0,
                            //       //fontWeight: FontWeight.bold,
                            //       color: Palette.gray99),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// 스크롤 가능 영역
                  Expanded(
                    child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(
                        children: [
                          // 수강권 추가 버튼
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            color: Palette.mainBackground,
                            child: AddTicketWidget(
                                customFunctionOnTap: () async {
                                  var result = await // 저장하기 성공시 Home로 이동
                                      Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MemberTicketMake.getUserInfo(
                                                widget.userInfo)),
                                  ).then((value) {
                                    print("수강권 추가 result");
                                  });
                                },
                                label: '수강권 추가하기',
                                addIcon: true),

                            // ### 기존 버튼 -> 문제 없을 시 삭제
                            // child: TextButton(
                            //   onPressed: () async {
                            //     var result = await // 저장하기 성공시 Home로 이동
                            //         Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (context) =>
                            //               MemberTicketMake.getUserInfo(
                            //                   widget.userInfo)),
                            //     ).then((value) {
                            //       print("수강권 추가 result");
                            //     });
                            //   },
                            //   child: Container(
                            //     height: 50,
                            //     decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(10),
                            //         border:
                            //             Border.all(color: Palette.gray99, width: 2)),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Text(
                            //           "수강권 추가하기",
                            //           style: TextStyle(
                            //               fontSize: 16, color: Palette.gray66),
                            //         ),
                            //         Icon(
                            //           Icons.add_circle_outline,
                            //           color: Palette.gray66,
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          ),

                          /// 수강권 리스트 영역 시작
                          Container(
                            constraints: BoxConstraints(minHeight: 700),
                            color: Palette.mainBackground,
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                /// 사용 가능한 수강권 리스트

                                ////// 타이틀 + Expand 버튼
                                InkWell(
                                  onTap: () {
                                    /// 리스트 오픈 토글
                                    isActiveTicketListOpened =
                                        !isActiveTicketListOpened;

                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "사용 가능한 수강권(${getListCnt(globalVariables.memberTicketList, true)})",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Palette.gray66,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          isActiveTicketListOpened
                                              ? Icons.expand_more
                                              : Icons.expand_less,
                                        )
                                      ],
                                    ),
                                  ),
                                ),

                                ////// 사용 가능한 수강권 리스트

                                Offstage(
                                  offstage: isActiveTicketListOpened,
                                  child: Container(
                                    child: Column(
                                      children: [
                                        ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: globalVariables
                                                .memberTicketList.length,
                                            itemBuilder: ((BuildContext context,
                                                int index) {
                                              print(
                                                  "widget.memberTList![index]['ticketCountLeft'] : ${widget.memberTList![index]['ticketCountLeft']} ");
                                              if (widget.memberTList![index]
                                                          ['memberId'] ==
                                                      widget.userInfo!.docId &&
                                                  widget.memberTList![index]
                                                          ['isAlive'] ==
                                                      true) {
                                                return Container(
                                                  alignment: Alignment.center,
                                                  child: TicketWidget(
                                                    customFunctionOnLongPress:
                                                        () async {
                                                      var result =
                                                          await // 저장하기 성공시 Home로 이동
                                                          Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                MemberTicketMake(
                                                                    widget
                                                                        .userInfo,
                                                                    widget.memberTList![
                                                                            index]
                                                                        [
                                                                        'ticketTitle'])),
                                                      ).then((value) {
                                                        print("수강권 추가 result");
                                                      });
                                                    },
                                                    selected: widget
                                                            .memberTList![index]
                                                        ['isSelected'],
                                                    ticketCountLeft: int.parse(
                                                        widget
                                                            .memberTList![index]
                                                                [
                                                                'ticketCountLeft']
                                                            .toString()),
                                                    ticketCountAll: int.parse(
                                                        widget
                                                            .memberTList![index]
                                                                [
                                                                'ticketCountAll']
                                                            .toString()),
                                                    ticketTitle: widget
                                                            .memberTList![index]
                                                        ['ticketTitle'],
                                                    ticketDescription: widget
                                                            .memberTList![index]
                                                        ['ticketDescription'],
                                                    ticketStartDate: globalFunction
                                                        .getDateFromTimeStamp(
                                                            widget.memberTList![
                                                                    index][
                                                                'ticketStartDate']),
                                                    ticketEndDate: globalFunction
                                                        .getDateFromTimeStamp(
                                                            widget.memberTList![
                                                                    index][
                                                                'ticketEndDate']),
                                                    // ticketDateLeft: int.parse(
                                                    //     widget
                                                    //         .memberTList![index]
                                                    //             [
                                                    //             'ticketDateLeft']
                                                    //         .toString()),
                                                    customFunctionOnTap: () {
                                                      for (int i = 0;
                                                          i <
                                                              widget
                                                                  .memberTList!
                                                                  .length;
                                                          i++) {
                                                        if (i == index) {
                                                          widget.memberTList![i]
                                                                  [
                                                                  'isSelected'] =
                                                              !widget.memberTList![
                                                                      i][
                                                                  'isSelected'];
                                                        } else {
                                                          widget.memberTList![i]
                                                                  [
                                                                  'isSelected'] =
                                                              false;
                                                        }
                                                      }
                                                      print(
                                                          "widget.memberTList![index]['selectedUi'] : ${widget.memberTList![index]['selectedUi']}");
                                                      setState(() {});
                                                    },
                                                  ),
                                                );
                                              } else {
                                                return SizedBox.shrink();
                                              }
                                            })),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),

                                /// 만료된 수강권 리스트

                                /// /// 타이틀 + Expand버튼
                                InkWell(
                                  onTap: () {
                                    /// 리스트 오픈 토글
                                    isExpiredTicketListOpened =
                                        !isExpiredTicketListOpened;
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "만료된 수강권(${getListCnt(globalVariables.memberTicketList, false)})",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Palette.gray66,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          isExpiredTicketListOpened
                                              ? Icons.expand_more
                                              : Icons.expand_less,
                                        )
                                      ],
                                    ),
                                  ),
                                ),

                                ////// 만료된 수강권 리스트
                                Offstage(
                                  offstage: isExpiredTicketListOpened,
                                  child: Container(
                                    width: double.infinity,
                                    child: Container(
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        controller: scrollController,
                                        shrinkWrap: true,
                                        itemCount: globalVariables
                                            .memberTicketList.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          // print("Expired - globalVariables.memberTicketList : ${globalVariables.memberTicketList}");
                                          if (widget.memberTList![index]
                                                      ['memberId'] ==
                                                  widget.userInfo!.docId &&
                                              widget.memberTList![index]
                                                      ['isAlive'] ==
                                                  false) {
                                            return Container(
                                                alignment: Alignment.center,
                                                child: TicketWidget(
                                                    customFunctionOnTap: () {
                                                      for (int i = 0;
                                                          i <
                                                              widget
                                                                  .memberTList!
                                                                  .length;
                                                          i++) {
                                                        if (i == index) {
                                                          widget.memberTList![i]
                                                                  [
                                                                  'isSelected'] =
                                                              !widget.memberTList![
                                                                      i][
                                                                  'isSelected'];
                                                        } else {
                                                          widget.memberTList![i]
                                                                  [
                                                                  'isSelected'] =
                                                              false;
                                                        }
                                                      }
                                                      print(
                                                          "widget.memberTList![index]['isSelected'] : ${widget.memberTList![index]['selectedUi']}");
                                                      setState(() {});
                                                    },
                                                    customFunctionOnLongPress:
                                                        () async {
                                                      var result =
                                                          await // 저장하기 성공시 Home로 이동
                                                          Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                MemberTicketMake(
                                                                    widget
                                                                        .userInfo,
                                                                    widget.memberTList![
                                                                            index]
                                                                        [
                                                                        'ticketTitle'])),
                                                      ).then((value) {
                                                        print("수강권 추가 result");
                                                      });
                                                    },
                                                    selected: widget
                                                            .memberTList![index]
                                                        ['isSelected'],
                                                    ticketCountLeft:
                                                        widget.memberTList![index]
                                                            ['ticketCountLeft'],
                                                    ticketCountAll:
                                                        widget.memberTList![index]
                                                            ['ticketCountAll'],
                                                    ticketTitle:
                                                        widget.memberTList![index]
                                                            ['ticketTitle'],
                                                    ticketDescription: widget
                                                            .memberTList![index]
                                                        ['ticketDescription'],
                                                    ticketStartDate: globalFunction
                                                        .getDateFromTimeStamp(
                                                            widget.memberTList![index]['ticketStartDate']),
                                                    ticketEndDate: globalFunction.getDateFromTimeStamp(widget.memberTList![index]['ticketEndDate'])));
                                            // ticketDateLeft: widget.memberTList![index]['ticketDateLeft']));
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
