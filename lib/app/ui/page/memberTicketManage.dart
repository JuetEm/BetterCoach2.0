import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/controller/memberTicket_controller.dart';
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

/** 메인으로 사용하는 리스트, uid, memberId로 filtering 된다. */
List memberManageTicketList = [];

/** 사용 가능한 수강권 리스트 isAlive = true */
List activeTicketList = [];
/** 만료된 수강권 리스트 isAlive = false */
List expiredTicketList = [];

/** 사용가능한 수강권 리스트 닫혔는지 */
bool isActiveTicketListHided = false;

/** 만료된 수강권 리스트 닫혔는지 */
bool isExpiredTicketListHided = true;

/** 리스트 내에 true 혹은 false값을 가진 내용물 수를 세준다 */
int getListCnt(List tList, bool checkVal) {
  int cnt = 0;

  cnt = tList
      .where((element) =>
          element['isAlive'] == checkVal &&
          element['memberId'] == userInfo.docId)
      .length;

  return cnt;
}

List tmpTMList = [];
List tmpActiveList = [];
List tmpExpiredList = [];

// widget.userInfo,activeTicketList[index]['ticketTitle']

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
    tmpTMList = [];
    activeTicketList = [];
    expiredTicketList = [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tmpTMList = [];
    activeTicketList = [];
    expiredTicketList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberTicketService>(
      builder: (context, memberTicketService, child) {
        // tmpTMList = [];
        // activeTicketList = [];
        // expiredTicketList = [];
        // DB 방식으로 전환
        tmpTMList.isEmpty
            ? 
            memberTicketService
                .readByMember(userInfo.uid, userInfo.docId)
                .then((value) {
                tmpTMList.addAll(value);
                setState(() {});
              }) : tmpTMList = tmpTMList;

        activeTicketList.isEmpty
            ? activeTicketList =
                tmpTMList.where((element) => element['isAlive']).toList()
            : activeTicketList = activeTicketList;

        expiredTicketList.isEmpty
            ? expiredTicketList =
                tmpTMList.where((element) => !element['isAlive']).toList()
            : expiredTicketList = expiredTicketList;

        return Scaffold(
          backgroundColor: Palette.secondaryBackground,
          appBar: BaseAppBarMethod(context, "수강권 관리", () {
            print("dafjkelwnovkneo 수강권 관리 백 이벤트");

            if (memberManageTicketList.isEmpty) {
              Navigator.pop(context, 0);
            } else {
              /// pop할 시 컨텐츠
              for (int i = 0; i < memberManageTicketList.length; i++) {
                var element = memberManageTicketList[i];

                if (element['isSelected'] == true) {
                  Navigator.pop(context, i);
                  print("euovjnosdjabndvoisdioasadfjoisnisd - ${i}");
                  break;
                } else if (memberManageTicketList.length - 1 == i) {
                  Navigator.pop(context, -1);
                } else {
                  Navigator.pop(context, -2);
                }
              }
            }
          }, [
            TextButton(
                onPressed: () {
                  int tmpIndex = 0;

                  // 업데이트 전 클로벌 변수 초기화
                  // globalVariables.memberTicketList = [];
                  // 완료 시 글로벌 티켓리스트 업데이트
                  MemberTicketController().update(
                      memberManageTicketList, globalVariables.memberTicketList);
                  globalVariables.memberTicketList.forEach(
                    (element) {
                      // print("fdsaewqghqerfdxf element => ${element}");
                    },
                  );

                  setState(() {});
                  final selectedTicket = memberManageTicketList.firstWhere(
                      (ticket) => ticket['isSelected'],
                      orElse: () => null);

                  if (selectedTicket != null) {
                    memberTicketService
                        .update(
                          AuthService().currentUser()!.uid,
                          selectedTicket['id'],
                          widget.userInfo!.docId,
                          selectedTicket['ticketUsingCount'],
                          selectedTicket['ticketCountLeft'],
                          selectedTicket['ticketCountAll'],
                          selectedTicket['ticketTitle'],
                          selectedTicket['ticketDescription'],
                          DateTime.parse(globalFunction.getDateFromTimeStamp(
                              selectedTicket['ticketStartDate'])),
                          DateTime.parse(globalFunction.getDateFromTimeStamp(
                              selectedTicket['ticketEndDate'])),
                          selectedTicket['ticketDateLeft'],
                          DateTime.now(),
                          selectedTicket['isSelected'],
                          selectedTicket['isAlive'],
                        )
                        .then((_) {});
                  }
                  
                  print("dnasofnopwmenfjnweikewop tmpIndex : ${tmpIndex}");
                  Navigator.pop(
                    context,
                    tmpIndex,
                  );
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
                                    // 즐겨찾기 버튼 클릭 시 토글
                                    favoriteMember = !favoriteMember;

                                    // 멤버ID를 이용하여 favorite bool 값 업데이트
                                    await memberService.updateIsFavorite(
                                        widget.userInfo!.docId, favoriteMember);

                                    // # Faovrite 반영된 멤버리스트를 Globale에 업로드
                                    //  ## id 일치하는 element 찾아 선언
                                    final item =
                                        globalVariables.resultList.firstWhere(
                                      (element) =>
                                          element['id'] ==
                                          widget.userInfo?.docId,
                                      orElse: () => null,
                                    );
                                    //  ## item이 null값 아닐 경우  일치하는 element 찾아 선언
                                    if (item != null) {
                                      item['isFavorite'] =
                                          item['isFavorite'] == null
                                              ? true
                                              : !item['isFavorite'];
                                      print(
                                          "memberInfo - widget.resultMemberList[i]['id'] : ${item['id']}");
                                    }
                                    ;

                                    print(
                                        "[TM] 즐겨찾기 변경 클릭 : 변경후 - ${favoriteMember} / ${widget.userInfo!.docId}");
                                    setState(
                                      () {
                                        print("ticketManage setState called!");
                                      },
                                    );
                                  },
                                );
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
                                                widget.userInfo,(){
                                                  print("러야ㅐㄴ미ㅜㄹㄷ조려노랴ㅐㅓ -노티파이 펑션 전달!!!");
                                                  setState(() {
                                                    
                                                  });
                                                })),
                                  ).then(
                                    (value) {
                                      print("수강권 추가 result");
                                      setState(() {
                                        
                                      });
                                    },
                                  );
                                },
                                label: '수강권 추가하기',
                                addIcon: true),
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
                                    isActiveTicketListHided =
                                        !isActiveTicketListHided;

                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "사용 가능한 수강권(${getListCnt(activeTicketList, true)})",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Palette.gray66,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          isActiveTicketListHided
                                              ? Icons.expand_more
                                              : Icons.expand_less,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                ////// 사용 가능한 수강권 리스트

                                Offstage(
                                  offstage: isActiveTicketListHided,
                                  child: Container(
                                    child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: activeTicketList.length,
                                      itemBuilder:
                                          ((BuildContext context, int index) {
                                        return Container(
                                          alignment: Alignment.center,
                                          child: TicketWidget(
                                            customFunctionOnTap: () {
                                              // 티켓 선택 함수
                                              // 탭시 계속 오류 발생시켜서 3/1 새벽 주석
                                              MemberTicketController()
                                                  .ticketSelect(
                                                memberManageTicketList, // Member의 전체 Ticket List
                                                activeTicketList,
                                                globalVariables
                                                    .memberTicketList, // 현재 상태의 Ticket List
                                                index, // 인덱스
                                              );

                                              activeTicketList[index]
                                                  ['isSelected'] = true;

                                              /// 글로벌 업데이트
                                              MemberTicketController().update(
                                                  memberManageTicketList,
                                                  globalVariables
                                                      .memberTicketList);

                                              setState(() {});
                                            },
                                            customFunctionOnLongPress:
                                                () async {
                                              tmpTMList = [];
                                              activeTicketList = [];
                                              expiredTicketList = [];
                                              var value;
                                              if(index != null && activeTicketList.isNotEmpty){
                                                value = activeTicketList[index]['ticketTitle'];
                                              }else{
                                                value = null;
                                              }
                                               
                                              var result =
                                                  await // 저장하기 성공시 Home로 이동
                                                  Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MemberTicketMake(
                                                            widget.userInfo,
                                                            value,(){
                                                              print("조아!?");
                                                              setState(() {
                                                                
                                                              });
                                                            })),
                                              ).then(
                                                (value) {
                                                  print("수강권 추가 result");
                                                  setState(() {});
                                                },
                                              );
                                            },
                                            selected: activeTicketList[index]
                                                ['isSelected'],
                                            ticketCountLeft: int.parse(
                                                activeTicketList[index]
                                                        ['ticketCountLeft']
                                                    .toString()),
                                            ticketCountAll: int.parse(
                                                activeTicketList[index]
                                                        ['ticketCountAll']
                                                    .toString()),
                                            ticketTitle: activeTicketList[index]
                                                ['ticketTitle'],
                                            ticketDescription:
                                                activeTicketList[index]
                                                    ['ticketDescription'],
                                            ticketStartDate: globalFunction
                                                .getDateFromTimeStamp(
                                                    activeTicketList[index]
                                                        ['ticketStartDate']),
                                            ticketEndDate: globalFunction
                                                .getDateFromTimeStamp(
                                                    activeTicketList[index]
                                                        ['ticketEndDate']),
                                            isAlive: activeTicketList[index]
                                                ['isAlive'],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),

                                /// 만료된 수강권 리스트

                                /// /// 타이틀 + Expand버튼
                                InkWell(
                                  onTap: () {
                                    /// 리스트 오픈 토글
                                    isExpiredTicketListHided =
                                        !isExpiredTicketListHided;
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "만료된 수강권(${getListCnt(expiredTicketList, false)})",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Palette.gray66,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          isExpiredTicketListHided
                                              ? Icons.expand_more
                                              : Icons.expand_less,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                ////// 만료된 수강권 리스트
                                Offstage(
                                  offstage: isExpiredTicketListHided,
                                  child: Container(
                                    width: double.infinity,
                                    child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      controller: scrollController,
                                      shrinkWrap: true,
                                      itemCount: expiredTicketList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          alignment: Alignment.center,
                                          child: TicketWidget(
                                            customFunctionOnTap: () {
                                              // 티켓 선택 함수
                                              MemberTicketController()
                                                  .ticketSelect(
                                                memberManageTicketList, // Member의 전체 Ticket List
                                                expiredTicketList,
                                                globalVariables
                                                    .memberTicketList, // 현재 상태의 Ticket List
                                                index, // 인덱스
                                              );

                                              expiredTicketList[index]
                                                  ['isSelected'] = true;

                                              /// 글로벌 업데이트
                                              MemberTicketController().update(
                                                  memberManageTicketList,
                                                  globalVariables
                                                      .memberTicketList);

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
                                                    widget.userInfo,
                                                    expiredTicketList[index]
                                                        ['ticketTitle'],(){
                                                          print("그래!!");
                                                          
                                                          setState(() {
                                                            
                                                          });
                                                        }
                                                  ),
                                                ),
                                              ).then(
                                                (value) {
                                                  print("수강권 추가 result");
                                                  setState(() {});
                                                },
                                              );
                                            },
                                            selected: expiredTicketList[index]
                                                ['isSelected'],
                                            ticketCountLeft:
                                                expiredTicketList[index]
                                                    ['ticketCountLeft'],
                                            ticketCountAll:
                                                expiredTicketList[index]
                                                    ['ticketCountAll'],
                                            ticketTitle:
                                                expiredTicketList[index]
                                                    ['ticketTitle'],
                                            ticketDescription:
                                                expiredTicketList[index]
                                                    ['ticketDescription'],
                                            ticketStartDate: globalFunction
                                                .getDateFromTimeStamp(
                                                    expiredTicketList[index]
                                                        ['ticketStartDate']),
                                            ticketEndDate: globalFunction
                                                .getDateFromTimeStamp(
                                                    expiredTicketList[index]
                                                        ['ticketEndDate']),
                                            isAlive: expiredTicketList[index]
                                                ['isAlive'],
                                          ),
                                        );
                                      },
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
