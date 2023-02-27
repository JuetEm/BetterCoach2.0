import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/data/model/userInfo.dart';
import 'package:web_project/app/function/globalFunction.dart';
import 'package:web_project/app/ui/page/memberInfo.dart' as M;
import 'package:web_project/app/ui/page/sequenceLibrary.dart';
import 'package:web_project/app/ui/widget/buttonWidget.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/ui/widget/globalWidget.dart';
import 'package:web_project/app/ui/widget/lessonActionListTileWidget.dart';
import 'package:web_project/backup/lessonAdd.dart';
import 'package:web_project/main.dart';

// appBar 출력 화면이름
String pageName = "노트추가";

// 수강권 사용/차감 체크박스 변수
bool isTicketCountChecked = true;
bool isSequenceSaveChecked = false;

GlobalFunction globalFunction = GlobalFunction();

String customSequenceName = '커스텀 시퀀스 ${customSequenceNumber}';

TextEditingController sequenceNameController = TextEditingController();
TextEditingController lessonDateController = TextEditingController(text: M.now);
TextEditingController todayNoteController = TextEditingController();
FocusNode sequenceNameFocusNode = FocusNode();

FocusNode lessonDateFocusNode = FocusNode();

List<TextEditingController> txtEdtCtrlrList = [];

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
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            color: Palette.mainBackground,
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Palette.gray99,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
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
                                                        hintText: '날짜를 선택하세요.',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Palette.gray99,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      style: TextStyle(
                                                        color: Palette.gray00,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
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
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 0,
                                  ),
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
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: Container(
                                          constraints:
                                              BoxConstraints(minHeight: 120),
                                          child: Container(
                                            child: TextFormField(
                                              onChanged: (value) {},
                                              maxLength: null,
                                              controller: todayNoteController,
                                              autofocus: true,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.all(20),
                                                  border: InputBorder.none,
                                                  hintText:
                                                      '오늘의 수업 내용을 기록해보세요.',
                                                  hintStyle: TextStyle(
                                                      color: Palette.gray99,
                                                      fontSize: 14)),
                                              style: TextStyle(
                                                  color: Palette.gray00,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
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
                                      // 변수로 offset 구분
                                      true
                                          ? Expanded(
                                              child: ListView.builder(
                                                padding:
                                                    EdgeInsets.only(bottom: 0),
                                                physics:
                                                    BouncingScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: 10,
                                                itemBuilder: (context, index) {
                                                  return Offstage(
                                                    offstage: false,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20),
                                                          child: Chip(
                                                            label: Text("동작명"),
                                                            deleteIcon: Icon(
                                                              Icons.close_sharp,
                                                              size: 16,
                                                            ),
                                                            onDeleted: () {
                                                              // delete action
                                                            },
                                                          ),
                                                        ),
                                                        TextFormField(
                                                          onChanged: (value) {},
                                                          controller:
                                                              null, // txtEdtCtrlrList[],
                                                          maxLines: null,
                                                          autofocus: true,
                                                          obscureText: false,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    20),
                                                            hintText:
                                                                '동작 수행 시 특이사항을 남겨보세요.',
                                                            hintStyle: TextStyle(
                                                                color: Palette
                                                                    .gray99,
                                                                fontSize: 14),
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                          style: TextStyle(
                                                              color: Palette
                                                                  .gray00,
                                                              fontSize: 14),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20),
                                              child: Text(
                                                '아래에서 동작을 선택하여 추가해보세요ㅣ',
                                                style: TextStyle(
                                                    color: Palette.gray99),
                                              ),
                                            )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(9, 0, 20, 0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSequenceSaveChecked,
                                  onChanged: (value) {
                                    isSequenceSaveChecked =
                                        !isSequenceSaveChecked;

                                    if (isSequenceSaveChecked == true) {
                                      sequenceNameFocusNode.requestFocus();
                                    }

                                    setState(() {});
                                  },
                                ),
                                Text('나의 시퀀스 저장'),
                                Spacer(),
                                TextButton(
                                    onPressed: () {
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
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          '불러오기',
                                          style:
                                              TextStyle(color: Palette.gray00),
                                        )
                                      ],
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              focusNode: sequenceNameFocusNode,
                              controller: sequenceNameController,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                  hintText: customSequenceName,
                                  hintStyle: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Palette.gray00),
                                  border: InputBorder.none),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                GrayInkwellButton(
                                  label: '동작 추가',
                                  customFunctionOnTap: () {
                                    globalVariables.actionList
                                        .forEach((element) {
                                      element['actionSelected'] = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ReorderableListView.builder(
                            padding: EdgeInsets.only(bottom: 100),
                            onReorder: (oldIndex, newIndex) {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              /* final movedActionList =
                                          lessonActionList.removeAt(oldIndex);
                                      lessonActionList.insert(
                                          newIndex, movedActionList); */

                              final movedActionList =
                                  lessonActionList.removeAt(oldIndex);
                              lessonActionList.insert(
                                  newIndex, movedActionList);
                            },
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 100,
                            itemBuilder: (context, index) {
                              Key? valueKey;

                              return GestureDetector(
                                key: valueKey,
                                onHorizontalDragUpdate: (details) {
                                  int sensitivity = 8;
                                  if (details.delta.dx > sensitivity) {
                                    print("GestureDetector right swipe");
                                  } else if (details.delta.dx < -sensitivity) {
                                    print("GestureDetector left swipe");
                                  }
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: SizedBox
                                            .shrink() // LessonActionListTile(actionName: actionName, apparatus: apparatus, position: position, name: name, phoneNumber: phoneNumber, lessonDate: lessonDate, grade: grade, totalNote: totalNote, docId: docId, memberdocId: memberdocId, uid: uid, pos: pos, isSelected: isSelected, isSelectable: isSelectable, isDraggable: isDraggable, customFunctionOnTap: customFunctionOnTap)
                                        ),
                                    Offstage(
                                      offstage: false,
                                      child: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.delete,
                                            color: Palette.statusRed,
                                          )),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                              backgroundColor: Palette.buttonOrange,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 90),
                              child: Text(
                                "저장하기",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            onPressed: () {},
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(height: 15,),// DeleteButton(actionNullCheck: actionNullCheck, todayNotedocId: todayNotedocId, lessonService: lessonService, dayLessonService: dayLessonService, totalNoteTextFieldDocId: totalNoteTextFieldDocId)
                          const SizedBox(height: 30,) 
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
