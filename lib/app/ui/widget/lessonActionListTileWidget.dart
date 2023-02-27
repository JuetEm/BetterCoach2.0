import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/provider/lesson_service.dart';
import 'package:web_project/backup/lessonAdd.dart';
import 'package:web_project/app/data/model/color.dart';

bool isFloating = false;

late List<TmpLessonActionInfo> tmpLessonInfoList;

var actionTileColor;
var apparatusTextColor;
var actionNameTextColor;

int selectedActionCount = 0;

class LessonActionListTile extends StatefulWidget {
  LessonActionListTile({
    Key? key,

    ///동작 정보
    this.actionList,
    required this.actionName,
    required this.apparatus,
    required this.position,

    ///사람 정보
    required this.name,
    required this.phoneNumber,
    required this.lessonDate,
    required this.grade,
    required this.totalNote,
    required this.docId,
    required this.memberdocId,
    required this.uid,
    required this.pos,

    /// 기타 설정
    required this.isSelected,
    required this.isSelectable,
    required this.isDraggable,
    required this.customFunctionOnTap,
  }) : super(key: key);

  /// 동작 정보
  final List<dynamic>? actionList;
  final String actionName;
  final String apparatus;
  final String position;

  /// 사람 정보
  final String name;
  final String phoneNumber;
  final String lessonDate;
  final String grade;
  final String totalNote;
  final String docId;
  final String memberdocId;
  final String uid;
  int? pos;

  /// 기타 설정
  bool isSelected;
  final bool isSelectable;
  final bool isDraggable;

  final Function customFunctionOnTap;

  @override
  State<LessonActionListTile> createState() => _LessonActionListTileState();
}

class _LessonActionListTileState extends State<LessonActionListTile> {
  @override
  void initState() {
    super.initState();
    tmpLessonInfoList = [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    State<LessonAdd>? lessonAdd = context.findAncestorStateOfType();

    ///
    TmpLessonActionInfo tmpLessonInfo = TmpLessonActionInfo(
        widget.memberdocId,
        widget.apparatus,
        widget.actionName,
        widget.name,
        widget.lessonDate,
        widget.grade,
        widget.totalNote,
        widget.docId,
        widget.uid,
        true);

    ///
    //레슨서비스 활용
    final lessonService = context.read<LessonService>();
    // onTap 방식과는 다르게 동작해야 함

    return ListTile(
      selected: widget.isSelectable ? widget.isSelected : false,
      onTap: () {
        print(
            "apparatus : ${widget.apparatus}, actionName : ${widget.actionName}");
        // 회원 카드 선택시 MemberInfo로 이동
        // Navigator.pop(context, actionInfo);
        setState(() {
          if (manageListContaining(tmpLessonInfoList, tmpLessonInfo, true)) {
            actionTileColor = Palette.grayFA;
            apparatusTextColor = Palette.gray99;
            actionNameTextColor = Palette.gray66;

            /* print(
                "YES contain!! remove item => widget.apparatus : ${widget.uid}/${widget.docId}/${widget.lessonDate}/${widget.apparatus}, widget.actionName : ${widget.actionName}"); */
            // checkedTileList.remove(widget.pos);

            // lessonService.deleteFromActionSelect(widget.uid, widget.memberdocId,widget.lessonDate, widget.apparatus, widget.actionName);
          } else {
            actionTileColor = Palette.buttonOrange;
            apparatusTextColor = Palette.grayFF;
            actionNameTextColor = Palette.grayFF;

            /* print(
                "NOT contain!! add item => widget.apparatus : ${widget.apparatus}, widget.actionName : ${widget.actionName}"); */
            // checkedTileList.add(widget.pos);

            print("[AS createFromActionSelect - ${widget.memberdocId}]");

            /* lessonService.createFromActionSelect(
              docId: widget.memberdocId,
              uid: widget.uid,
              name: widget.name,
              phoneNumber: widget.phoneNumber,
              apratusName: widget.apparatus,
              actionName: widget.actionName,
              lessonDate: widget.lessonDate,
              grade: "50",
              totalNote: "",
              pos: null,
              onSuccess: () {
                print(
                    "동작추가 성공 : widget.apparatus : ${widget.apparatus}, widget.actionName : ${widget.actionName}");
              },
              onError: () {
                print(
                    "동작추가 에러 : widget.apparatus : ${widget.apparatus}, widget.actionName : ${widget.actionName}");
              },
            ); */
          }

          // setState 함수는 클래스 내부에서만 다시 그린다. floatingActionButton은 actionTile 클래스를 감싸고 있는
          // actionSelector 클래스에서 그리는 영역이기 때문에, 부모 클래스를 호출해서 setState 해주어야 한다.
          lessonAdd!.setState(() {
            if (tmpLessonInfoList.isNotEmpty) {
              isFloating = true;
              selectedActionCount = tmpLessonInfoList.length;
              print(
                  "isFloating isNotEmpty : tmpLessonInfoList.length : ${tmpLessonInfoList.length}");
            } else {
              isFloating = false;
              print(
                  "isFloating isEmpty : tmpLessonInfoList.length : ${tmpLessonInfoList.length}");
            }
          });
        });
        for (int i = 0; i < tmpLessonInfoList.length; i++) {
          print(
              "tmpLessonInfoList - apratusName : ${tmpLessonInfoList[i].apparatusName}, actionName : ${tmpLessonInfoList[i].actionName}");
        }
        ;
        widget.customFunctionOnTap();
        print(
            "apparatus : ${widget.apparatus}, position : ${widget.position}, actionName : ${widget.actionName}");
        // print(widget.actionList);
      },
      selectedColor: Palette.gray33,
      selectedTileColor: Palette.grayEE,
      shape: RoundedRectangleBorder(
          // side: BorderSide(color: Palette.grayEE, width: 1),
          ),
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      tileColor: Palette.mainBackground,
      visualDensity: VisualDensity(vertical: -4),
      title: Text(
        '${widget.actionName}',
        style: TextStyle(fontSize: 14, color: Palette.gray00),
      ),
      subtitle: Row(
        children: [
          Text(
            '${widget.apparatus}',
            style: TextStyle(fontSize: 12, color: Palette.gray99),
          ),
          SizedBox(width: 6),
          Text(
            '${widget.position}',
            style: TextStyle(fontSize: 12, color: Palette.gray99),
          )
        ],
      ),
      trailing: widget.isDraggable ? Icon(Icons.drag_handle) : null,
    );
  }
}

class TmpLessonActionInfo {
  TmpLessonActionInfo(
    this.memberdocId,
    this.apparatusName,
    this.actionName,
    this.name,
    this.lessonDate,
    this.grade,
    this.totalNote,
    this.docId,
    this.uid,
    this.isSelected,
  );
  String memberdocId;
  String apparatusName;
  String actionName;
  String name;
  String lessonDate;
  String grade;
  String totalNote;
  String docId;
  String uid;
  bool isSelected;
}

bool manageListContaining(List<TmpLessonActionInfo> tmpLessonInfoList,
    TmpLessonActionInfo tmpLessonInfo, bool isEditable) {
  bool isConatained = false;
  for (int i = 0; i < tmpLessonInfoList.length; i++) {
    if (tmpLessonInfoList[i].apparatusName == tmpLessonInfo.apparatusName) {
      if (tmpLessonInfoList[i].actionName == tmpLessonInfo.actionName) {
        isConatained = true;
        if (isEditable) {
          tmpLessonInfoList.removeAt(i);
        }
      }
    }
  }
  if (isEditable) {
    if (!isConatained) {
      tmpLessonInfoList.add(tmpLessonInfo);
    }
  }
  return isConatained;
}
