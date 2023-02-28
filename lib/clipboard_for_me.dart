
/*
var item = ticketList.firstWhere((element) => element['id']==expiredTicketList[index]['id']);

*/
/* import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
                Container(
                  width: 140,
                  child: Material(
                    color: Palette.mainBackground,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        await globalFunction.getDateFromCalendar(
                            context,
                            lessonDateController,
                            "수업일",
                            lessonDateController.text);

                        todayNoteController.text = "";

                        //lessonDate = lessonDateController.text;
                        DateChangeMode = true;
                        checkInitState = true;
                        print(
                            "[LA] 수업일변경 : lessonDateController ${lessonDateController.text} / todayNoteController ${todayNoteController.text} / DateChangeMode ${DateChangeMode}");
                        initInpuWidget(
                            uid: user.uid,
                            docId: customUserInfo.docId,
                            lessonService: lessonService);
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                textAlign: TextAlign.start,
                                enabled: false,
                                maxLines: null,
                                controller: lessonDateController,
                                focusNode: lessonDateFocusNode,
                                autofocus: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '날짜를 선택하세요.',
                                  hintStyle: TextStyle(
                                      color: Palette.gray99,
                                      fontWeight: FontWeight.normal),
                                ),
                                style: TextStyle(
                                    color: Palette.gray00,
                                    fontWeight: FontWeight.bold),
                                /* validator:
                                                                                _model.textControllerValidator.asValidator(context), */
                              ),
                            ),
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
                )

                /// 기존 수업일 입력창
                // Expanded(
                //   child: BaseTextField(
                //     customController: lessonDateController,
                //     customFocusNode: lessonDateFocusNode,
                //     hint: "수업일",
                //     showArrow: true,
                //     customFunction: () async {
                //       await globalFunction
                //           .getDateFromCalendar(
                //               context,
                //               lessonDateController,
                //               "수업일",
                //               lessonDateController.text);

                //       todayNoteController.text = "";

                //       //lessonDate = lessonDateController.text;
                //       DateChangeMode = true;
                //       checkInitState = true;
                //       print(
                //           "[LA] 수업일변경 : lessonDateController ${lessonDateController.text} / todayNoteController ${todayNoteController.text} / DateChangeMode ${DateChangeMode}");
                //       initInpuWidget(
                //           uid: user.uid,
                //           docId: customUserInfo.docId,
                //           lessonService: lessonService);

                //       // setState(() {
                //       //   print(
                //       //       "수업일변경 : ${lessonDateController.text}  - ${todayNoteController.text}");
                //       //   todayNoteController.text = "";
                //       //   print(
                //       //       "텍스트지우기 : ${lessonDateController.text} - ${todayNoteController.text}");
                //       //   //lessonDate = lessonDateController.text;
                //       //   DateChangeMode = true;

                //       //   initInpuWidget();
                //       // });
                //       // await refreshLessonDate(
                //       //     uid: user.uid,
                //       //     docId: customUserInfo.docId,
                //       //     lessonService: lessonService);
                //       //lessonService.notifyListeners();
                //       // setState(() {

                //       // });
                //     },
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 0),

            /// 일별 메모 입력창
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: lessonService.readTodayNoteOflessonDate(
                      user.uid,
                      customUserInfo.docId,
                      lessonDateController.text,
                    ),
                    builder: (context, snapshot) {
                      print("문서가져오기시작 : ${lessonDateController.text}");

                      final docsTodayNote =
                          snapshot.data?.docs ?? []; // 문서들 가져오기
                      //print("문서가져오기끝");

                      // 기존 저장된 값이 없으면 초기화, 동작 선택모드 일경우
                      // if (docsTodayNote.isEmpty) {
                      //   if (ActionSelectMode) {
                      //   } else {
                      //     todayNoteController.text = "";
                      //   }
                      //   todayNotedocId = "";
                      // } else {
                      //   todayNoteController.text =
                      //       docsTodayNote[0].get('todayNote');
                      //   todayNotedocId = docsTodayNote[0].id;
                      // }

                      print(
                          "[LA] 일별노트 출력 시작 : 유/무 ${docsTodayNote.isEmpty} / todayNotedocId ${todayNotedocId} / todayNoteView ${todayNoteView} / todayNoteController ${todayNoteController}");

                      if (docsTodayNote.isEmpty) {
                        todayNotedocId = "";
                        todayNoteView = "";
                        // WidgetsBinding.instance.addPostFrameCallback(
                        //     (_) => todayNoteController.clear());
                        //에러 제어하기 위해 추가.https://github.com/flutter/flutter/issues/17647
                        //todayNoteController.text = "";
                        print("뿌릴 일별 노트 없음 : ${todayNoteController.text}");
                      } else {
                        if (isFirst) {
                          todayNoteView = docsTodayNote[0].get('todayNote');
                          print("todayNoteView : ${todayNoteView}");
                          todayNoteController.text = todayNoteView;
                          //
                          todayNoteController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: todayNoteController.text.length));
                        }
                        todayNotedocId = docsTodayNote[0].id;

                        // WidgetsBinding.instance.addPostFrameCallback(
                        //     (_) => todayNoteController.text =
                        //         docsTodayNote[0].get('todayNote'));
                        //에러 제어하기 위해 추가.https://github.com/flutter/flutter/issues/17647

                        print(
                            "뿌릴 일별 노트 출력 완료 : ${todayNoteController.text} - ${todayNotedocId} ");
                      }
                      print(
                          "[LA] 일별노트 출력 결과 : todayNotedocId ${todayNotedocId} / todayNoteView ${todayNoteView} / todayNoteController ${todayNoteController}");
                      // if (initStateTextfield) {
                      //   if (docsTodayNote.isEmpty) {
                      //     todayNotedocId = "";
                      //     todayNoteController.text = "";
                      //     print("뿌릴 일별 노트 없음");
                      //   } else {
                      //     todayNoteController.text =
                      //         docsTodayNote[0].get('todayNote');
                      //     todayNotedocId = docsTodayNote[0].id;
                      //     print("뿌릴 일별 노트 출력 완료");
                      //   }
                      //   //initStateTextfield = false;
                      // }

                      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      //   content: Text("텍스트필드!!"),
                      // ));
                      // 텍스트 필드 이전
                      // return DynamicSaveTextField(
                      //   customController: todayNoteController,
                      //   hint: "일별 메모",
                      //   showArrow: false,
                      //   customFunction: () {
                      //     FocusScope.of(context).unfocus();
                      //   },
                      // );
                      // 새로 불러오기

                      /// 리턴 시작
                      return Container(
                        constraints: BoxConstraints(minHeight: 120),
                        child: Container(
                          child: TextFormField(
                            onChanged: (value) {
                              todayNoteView = value;
                              todayNoteController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: todayNoteController.text.length));
                            },
                            maxLines: null,
                            controller: todayNoteController,
                            autofocus: true,
                            obscureText: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              border: InputBorder.none,
                              hintText: '오늘의 수업 내용을 기록해보세요',
                              hintStyle: TextStyle(
                                  color: Palette.gray99, fontSize: 14),
                            ),
                            style:
                                TextStyle(color: Palette.gray00, fontSize: 14),
                            /* validator:
                                                      _model.textControllerValidator.asValidator(context), */
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
                /// 묶음 단위로 불러와져야 함.
                lessonActionList.isNotEmpty // is동작메모하나라도있니? 변수 필요
                    /// 동작 있을 경우
                    ? Expanded(
                        child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 100),
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: lessonActionList.length,
                            itemBuilder: (context, index) {
                              Key? valueKey;
                              lessonActionList[index]['pos'] = index;
                              valueKey =
                                  ValueKey(lessonActionList[index]['pos']);

                              final doc = lessonActionList[index];

                              print("bbbbbbbb - doc : ${doc}");

                              String uid = doc['uid']; // 강사 고유번호

                              String name = doc['name']; //회원이름
                              String phoneNumber =
                                  doc['phoneNumber']; // 회원 고유번호 (전화번호로 회원 식별)
                              String apratusName = doc['apratusName']; //기구이름
                              String actionName = doc['actionName']; //동작이름
                              String lessonDate = doc['lessonDate']; //수업날짜
                              String grade = doc['grade']; //수행도
                              String totalNote = doc['totalNote']; //수업총메모
                              int pos = doc['pos']; //수업총메모
                              bool isSelected = doc['selected'];

                              return Offstage(
                                key: valueKey,
                                offstage: !isSelected,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Chip(
                                          label: Text("$actionName"),
                                          deleteIcon: Icon(
                                            Icons.close_sharp,
                                            size: 16,
                                          ),
                                          onDeleted: () {},
                                        )),
                                    TextFormField(
                                      maxLines: null,
                                      autofocus: true,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        /* content padding을 20이상 잡아두지 않으면,
                                                              한글 입력 시 텍스트가 위아래로 움직이는 오류 발생 */
                                        contentPadding: EdgeInsets.all(20),
                                        hintText: '동작 수행 시 특이사항을 남겨보세요.',
                                        hintStyle: TextStyle(
                                            color: Palette.gray99,
                                            fontSize: 14),
                                        border: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                          color: Palette.gray00, fontSize: 14),
                                      /* validator:
                                                                  _model.textControllerValidator.asValidator(context), */
                                    )
                                  ],
                                ),
                              );
                            }),
                      )

                    /// 동작 하나도 없을 경우
                    : Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          '아래에서 동작을 선택하여 추가해보세요.',
                          style: TextStyle(color: Palette.gray99),
                        ),
                      )
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
 */