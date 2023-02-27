import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/data/model/userInfo.dart';
import 'package:web_project/app/ui/page/memberInfo.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/ui/widget/globalWidget.dart';

// appBar 출력 화면이름
String pageName = "노트추가";

// 수강권 사용/차감 체크박스 변수
bool isTicketCountChecked = true;

class LessonAdd extends StatefulWidget {
  UserInfo userInfo;
  LessonAdd(this.userInfo, {super.key});

  @override
  State<LessonAdd> createState() => _LessonAddState();
}

class _LessonAddState extends State<LessonAdd> {
  @override
  Widget build(BuildContext context) {
    return Consumer2(
      builder: (context, value, value2, child) {
        return Scaffold(
            backgroundColor: Palette.secondaryBackground,
            appBar: BaseAppBarMethod(context, pageName, () {
              Navigator.pop(context);
            }, [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: () {
                    /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("일별노트 또는 동작선택중 하나는 필수입력해주세요."),
                      ));

                      saveMethod(lessonService, lessonDateArg, lessonAddMode,
                          customUserInfo, dayLessonService); 
                          
                          Navigator.pop(context);
                          */
                  },
                  child: Text(
                    '완료',
                    style: TextStyle(color: Palette.textBlue, fontSize: 16),
                  ),
                ),
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
                      Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
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
                                        widget.userInfo.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '등록일 : ${widget.userInfo.registerDate}',
                                        style: TextStyle(
                                          color: Palette.gray99,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 6,
                                      ),
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
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        children: [
                                          Text("수강권 차감 여부"),
                                          Checkbox(
                                            value: isTicketCountChecked,
                                            onChanged: (value) {
                                              isTicketCountChecked =
                                                  !isTicketCountChecked;

                                              setState(() {});
                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            )));
      },
    );
  }
}
