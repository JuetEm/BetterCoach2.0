import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/provider/member_service.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';

import '../../data/provider/auth_service.dart';
import '../widget/baseTableCalendar.dart';
import '../../data/model/color.dart';
import '../../function/globalFunction.dart';
import '../widget/globalWidget.dart';
import 'memberInfo.dart';
import 'memberList.dart';
import 'membershipList.dart';
import '../../data/model/userInfo.dart';

GlobalFunction globalFunction = GlobalFunction();

TextEditingController nameController = TextEditingController();
TextEditingController registerDateController = TextEditingController();
TextEditingController phoneNumberController = TextEditingController();
TextEditingController registerTypeController = TextEditingController();
TextEditingController goalController = TextEditingController();
TextEditingController infoController = TextEditingController();
TextEditingController noteController = TextEditingController();
TextEditingController commentController = TextEditingController();

FocusNode nameFocusNode = FocusNode();
FocusNode registerDateFocusNode = FocusNode();
FocusNode phoneNumberFocusNode = FocusNode();
FocusNode registerTypeFocusNode = FocusNode();
FocusNode goalFocusNode = FocusNode();
FocusNode infoFocusNode = FocusNode();
FocusNode noteFocusNode = FocusNode();
FocusNode commentFocusNode = FocusNode();

class MemberUpdate extends StatefulWidget {
  const MemberUpdate({super.key});

  @override
  State<MemberUpdate> createState() => _MemberUpdateState();
}

class _MemberUpdateState extends State<MemberUpdate> {
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser()!;

    // 이전 화면에서 보낸 변수 받기
    final userInfo = ModalRoute.of(context)!.settings.arguments as UserInfo;
    nameController.text = userInfo.name;
    registerDateController.text = userInfo.registerDate;
    phoneNumberController.text = userInfo.phoneNumber;
    registerTypeController.text = userInfo.registerType;
    goalController.text = userInfo.goal;
    infoController.text = userInfo.info;
    noteController.text = userInfo.note;
    commentController.text = userInfo.comment;

    return Consumer<MemberService>(
      builder: (context, memberService, child) {
        return Scaffold(
          backgroundColor: Palette.secondaryBackground,
          appBar: BaseAppBarMethod(context, "회원정보 변경", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemberList(),
              ),
            );

            globalFunction.clearTextEditController([
              nameController,
              registerDateController,
              phoneNumberController,
              registerTypeController,
              goalController,
              infoController,
              noteController,
              commentController,
            ]);
          }, null, null),
          body: CenterConstrainedBody(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  /// 입력창
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // SizedBox(
                          //   height: 200,
                          //   width: 200,
                          //   child: ClipRRect(
                          //     borderRadius: BorderRadius.circular(100),
                          //     child: Image.network(
                          //       imgUrl,
                          //       fit: BoxFit.fill,
                          //     ),
                          //   ),
                          // ),

                          /// 이름 입력창
                          BaseTextField(
                            customController: nameController,
                            customFocusNode: nameFocusNode,
                            hint: "이름",
                            showArrow: false,
                            customFunction: () {},
                          ),

                          /// 등록일 입력창
                          BaseTextField(
                            customController: registerDateController,
                            customFocusNode: registerDateFocusNode,
                            hint: "등록일",
                            showArrow: true,
                            customFunction: () {
                              globalFunction.getDateFromCalendar(
                                  context,
                                  registerDateController,
                                  "등록일",
                                  registerDateController.text);
                            },
                          ),

                          /// 전화번호 입력창
                          BaseTextField(
                            customController: phoneNumberController,
                            customFocusNode: phoneNumberFocusNode,
                            hint: "전화번호",
                            showArrow: false,
                            customFunction: () {},
                          ),

                          /// 등록횟수입력창
                          BaseTextField(
                            customController: registerTypeController,
                            customFocusNode: registerTypeFocusNode,
                            hint: "등록횟수입력",
                            showArrow: true,
                            customFunction: () {
                              String lessonCount = registerTypeController.text;
                              _getMembership(context, lessonCount);
                            },
                          ),

                          /// 운동목표 입력창
                          BaseTextField(
                            customController: goalController,
                            customFocusNode: goalFocusNode,
                            hint: "운동목표",
                            showArrow: false,
                            customFunction: () {},
                          ),

                          /// 신체 특이사항/체형분석 입력창
                          BaseTextField(
                            customController: infoController,
                            customFocusNode: infoFocusNode,
                            hint: "통증/상해/병력",
                            showArrow: false,
                            customFunction: () {},
                          ),

                          /// 체형분석 입력창
                          BaseTextField(
                            customController: noteController,
                            customFocusNode: noteFocusNode,
                            hint: "체형분석",
                            showArrow: false,
                            customFunction: () {},
                          ),

                          /// 특이사항 입력창
                          BaseTextField(
                            customController: commentController,
                            customFocusNode: commentFocusNode,
                            hint: "특이사항",
                            showArrow: false,
                            customFunction: () {},
                          ),
                          Divider(height: 1),

                          /// 추가 버튼
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
                              child:
                                  Text("저장하기", style: TextStyle(fontSize: 18)),
                            ),
                            onPressed: () {
                              //print("${userInfo.mid}");
                              // create bucket

                              // if (globalFunction.textNullCheck(
                              //     context, nameController, "이름")) {
                              //   memberService.update(
                              //       docId: userInfo.docId,
                              //       name: nameController.text,
                              //       registerDate: registerDateController.text,
                              //       phoneNumber: phoneNumberController.text,
                              //       registerType: registerTypeController.text,
                              //       goal: goalController.text,

                              //       info: infoController.text,
                              //       note: noteController.text,
                              //       uid: user.uid,
                              //       comment: commentController.text,
                              //       onSuccess: () {
                              //         // 저장하기 성공
                              //         ScaffoldMessenger.of(context)
                              //             .showSnackBar(SnackBar(
                              //           content: Text("저장하기 성공"),
                              //         ));

                              //         //userinfoupdate.mid = nameController.text;

                              //         //List<UserInfo> userupdateInfo
                              //         UserInfo userInfouUpdate = UserInfo(
                              //             userInfo.docId,
                              //             userInfo.uid,
                              //             nameController.text,
                              //             registerDateController.text,
                              //             phoneNumberController.text,
                              //             registerTypeController.text,
                              //             goalController.text,
                              //             [],
                              //             "",
                              //             [],
                              //             "",
                              //             [],
                              //             infoController.text,
                              //             noteController.text,
                              //             commentController.text,
                              //             true);

                              //         // 저장하기 성공시 MemberInfo로 이동
                              //         Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //             builder: (context) => MemberInfo(),
                              //             // setting에서 arguments로 다음 화면에 회원 정보 넘기기
                              //             settings: RouteSettings(
                              //               arguments: userInfouUpdate,
                              //             ),
                              //           ),
                              //         );

                              //         globalFunction.clearTextEditController([
                              //           nameController,
                              //           registerDateController,
                              //           phoneNumberController,
                              //           registerTypeController,
                              //           goalController,
                              //           infoController,
                              //           noteController,
                              //           commentController,
                              //         ]);
                              //       },
                              //       onError: () {
                              //         print("저장하기 ERROR");
                              //       });
                              // } else {
                              //   ScaffoldMessenger.of(context)
                              //       .showSnackBar(SnackBar(
                              //     content: Text("항목을 모두 입력해주세요."),
                              //   ));
                              // }
                            },
                          ),

                          SizedBox(height: 20),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 0,
                              backgroundColor: Palette.mainBackground,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 90),
                              child: Text("삭제하기",
                                  style: TextStyle(
                                      fontSize: 18, color: Palette.textRed)),
                            ),
                            onPressed: () async {
                              print("${userInfo.docId}");
                              // create bucket
                              final retvaldelte =
                                  await showAlertDialog(context);
                              if (retvaldelte == "OK") {
                                memberService.delete(
                                    docId: userInfo.docId,
                                    onSuccess: () {
                                      // 삭제하기 성공
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("삭제하기 성공"),
                                      ));

                                      //userinfoupdate.mid = nameController.text;

                                      // 삭제하기 성공시 MemberList로 이동
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MemberList(),
                                        ),
                                      );

                                      globalFunction.clearTextEditController([
                                        nameController,
                                        registerDateController,
                                        phoneNumberController,
                                        registerTypeController,
                                        goalController,
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
                  ),
                ],
              ),
            ),
          ),
          //bottomNavigationBar: BaseBottomAppBar(),
        );
      },
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
