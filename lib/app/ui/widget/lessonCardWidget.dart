import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/data/model/lessonNoteInfo.dart';
import 'package:web_project/app/data/model/userInfo.dart';
import 'package:web_project/app/ui/page/lessonUpdate.dart';

bool isExpanded = false;

class LessonCardWidget extends StatelessWidget {
  LessonCardWidget({
    Key? key,
    required this.userInfo,
    required this.memberId,
    required this.lessonDate,
    required this.todayNote,
    required this.lessonActionList,
  }) : super(key: key);

  final UserInfo userInfo;
  final String memberId;
  final String lessonDate;
  final String todayNote;
  final List lessonActionList;

  @override
  Widget build(BuildContext context) {
    print('###이건 되니?');
    print('###lessonActionList: $lessonActionList');
    return Container(
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
                SizedBox(
                  width: 140,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(6, 0, 10, 0),
                    child: Text(
                      '${lessonDate}',
                      style: TextStyle(
                          color: Palette.gray00, fontWeight: FontWeight.bold),
                      /* validator:
                                                                      _model.textControllerValidator.asValidator(context), */
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 0),

            /// 일별 메모 입력창
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 366),
                  width: MediaQuery.of(context).size.width - 114,
                  child: todayNote == ""
                      ? Text(
                          '-',
                          style: TextStyle(color: Palette.gray99, fontSize: 14),
                        )
                      : Text(
                          '$todayNote',
                          style: TextStyle(color: Palette.gray00, fontSize: 14),
                        ),
                ),
              )
            ]),

            const SizedBox(height: 20),

            /// 동작별 메모 (New)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                /// 동작별 메모 한 묶음.
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 10),
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: lessonActionList.length,
                      itemBuilder: (context, index) {
                        print('###빌드는 하긴 하니?');

                        // 사용한 모델 객체를 선언해 리스트[index] 로 받음
                        LessonNoteInfo lessonNoteInfo = lessonActionList[index];
                        Key? valueKey;
                        // 클래스에서 객체 꺼내 쓰는 방식
                        lessonNoteInfo.pos = index;
                        // lessonActionList[index]['pos'] = index;
                        valueKey = ValueKey(lessonNoteInfo.pos);
                        // valueKey = ValueKey(lessonActionList[index]['pos']);

                        // final doc = lessonActionList[index];

                        print("bbbbbbbb - doc : ${lessonNoteInfo}");

                        String uid = lessonNoteInfo.uid; // doc['uid']; // 강사 고유번호

                        String name = lessonNoteInfo.name; //회원이름
                        String phoneNumber =
                            lessonNoteInfo.phoneNumber.toString(); // 회원 고유번호 (전화번호로 회원 식별)
                        String? apratusName = lessonNoteInfo.apratusName; //기구이름
                        String? actionName = lessonNoteInfo.actionName; //동작이름
                        String lessonDate = lessonNoteInfo.lessonDate; //수업날짜
                        String? grade = lessonNoteInfo.grade; //수행도
                        String? totalNote = lessonNoteInfo.totalNote; //수업총메모
                        int? pos = lessonNoteInfo.pos; //수업총메모
                        bool? isSelected = lessonNoteInfo.noteSelected;

                        // bool isSelected;

                        // if (totalNote == "") {
                        //   isSelected = true;
                        // } else {
                        //   isSelected = false;
                        // }
                        print('### $index & $isSelected');

                        return Offstage(
                          key: valueKey,
                          offstage: isExpanded ? false : !isSelected!,
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    alignment: Alignment.centerLeft,
                                    width: 200,
                                    padding: EdgeInsets.only(left: 14),
                                    child: Chip(
                                      backgroundColor: totalNote == ""
                                          ? Palette.gray99
                                          : Palette.titleOrange,
                                      label: Text("$actionName",
                                          style: TextStyle(
                                              color: Palette.gray00,
                                              fontSize: 12)),
                                    )),
                                SizedBox(width: 6),
                                Container(
                                  constraints: BoxConstraints(maxWidth: 214),
                                  width:
                                      MediaQuery.of(context).size.width - 278,
                                  padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      totalNote!,
                                      style: TextStyle(
                                          color: Palette.gray00, fontSize: 12),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: IconButton(
                  icon: Icon(isExpanded
                      ? Icons.expand_less_outlined
                      : Icons.expand_more_outlined),
                  onPressed: () {
                    isExpanded = !isExpanded;
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
