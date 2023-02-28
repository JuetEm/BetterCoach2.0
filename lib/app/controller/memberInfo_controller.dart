import 'dart:developer';

import 'package:web_project/app/data/model/lessonInfo.dart';
import 'package:web_project/app/data/model/lessonNoteInfo.dart';
import 'package:web_project/app/data/repository/lesson_repository.dart';
import 'package:web_project/app/ui/page/lessonAdd.dart';
import 'package:web_project/main.dart';

// 챗지피티 만세! 
// class MemberInfoController {
//   MemberInfoController();

//   LessonRepository lessonRepository = LessonRepository();

//   Future<List> getLessonDayAndActionNoteData(
//       String uid, String memberId) async {
//     List lessonNoteInfoList = [];
//     LessonNoteInfo lessonNoteInfo;
//     List resultLessonNoteData = [];

//     List lessonDayNoteList = await lessonRepository.getLessonDaynNote(uid);
//     List lessonActionNoteList =
//         await lessonRepository.getLessonActionNote(uid, memberId);

//     print('###Albert, tell me ${lessonDayNoteList.length}');
//     // print('###Albert, tell me ${lessonDayNoteList}');

//     print('###Albert, tell me ${lessonActionNoteList.length}');

//     lessonDayNoteList.forEach((lNelement) {
//       lessonActionNoteList.forEach((aNelement) {
//         // print('###Albert, lNelement[docId ${lNelement['docId']}');
//         // print('###Albert, aNelement[docId ${aNelement['docId']}');
//         print('###Albert, -------------------------------------');
//         if (lNelement['lessonDate'] == aNelement['lessonDate'] &&
//             lNelement['docId'] == aNelement['docId']) {
//           // print('###Albert, lNelement[docId ${lNelement['docId']}');
//           // print('###Albert, aNelement[docId ${aNelement['docId']}');

//           lessonNoteInfo = LessonNoteInfo(
//             uid,
//             memberId,
//             lNelement['name'],
//             lNelement['phoneNumber'],
//             lNelement['lessonDate'],
//             aNelement['actionName'],
//             aNelement['grade'],
//             aNelement['pos'],
//             aNelement['totalNote'],
//             aNelement['apratusName'],
//             aNelement['timestamp'],
//             lNelement['todayNote'],
//             lNelement['timestamp'],
//             globalFunction.getActionPosition(aNelement['apratusName'], aNelement['actionName'], globalVariables.actionList),
//             aNelement['totalNote'].toString().isNotEmpty ? true : false,
//             aNelement['id'],
//             lNelement['id'],
//           );

//           lessonNoteInfoList.add(lessonNoteInfo);
//         }

//         // print(
//         //     "C'MON ALBERT - uid : ${uid}, memberId : ${memberId}, lNelement['name'] : ${lNelement['name']}, lNelement['phoneNumber'] : ${lNelement['phoneNumber']}, lNelement['lessonDate'] : ${lNelement['lessonDate']}, aNelement['actionName'] : ${aNelement['actionName']}, aNelement['grade'] : ${aNelement['grade']}, aNelement['pos'] : ${aNelement['pos']}, aNelement['totalNote'] : ${aNelement['totalNote']}, aNelement['apratusName'] : ${aNelement['apratusName']}, aNelement['timestamp'] : ${aNelement['timestamp']}, lNelement['todayNote'] : ${lNelement['todayNote']}, lNelement['timestamp'] : ${lNelement['timestamp']}, false, aNelement['id'] : ${aNelement['id']}, lNelement['id'] : ${lNelement['id']}");
//       });
//     });

//     // print("lessonNoteInfo : ${lessonNoteInfo}");
//     // inspect(lessonNoteInfoList);
//     // print('lessonNoteInfoList: ${lessonNoteInfoList.length}');
//     // print(lessonNoteInfo.actionName);

//     return lessonNoteInfoList;
//   }
// }

class MemberInfoController {
  MemberInfoController();

  LessonRepository lessonRepository = LessonRepository();

  Future<List<LessonNoteInfo>> getLessonDayAndActionNoteData(
      String uid, String memberId) async {
    List<LessonNoteInfo> lessonNoteInfoList = [];

    List lessonDayNoteList = await lessonRepository.getLessonDaynNote(uid);
    List lessonActionNoteList =
        await lessonRepository.getLessonActionNote(uid, memberId);

    Map<String, dynamic> dayNoteMap = Map.fromEntries(
      lessonDayNoteList.map(
        (dayNote) => MapEntry(
          "${dayNote['docId']}-${dayNote['lessonDate']}",
          dayNote,
        ),
      ),
    );

    lessonActionNoteList.forEach((actionNote) {
      print('###Albert, -------------------------------------');
      var key = "${actionNote['docId']}-${actionNote['lessonDate']}";
      if (dayNoteMap.containsKey(key)) {
        var dayNote = dayNoteMap[key];
        var lessonNoteInfo = LessonNoteInfo(
          uid,
          memberId,
          dayNote['name'],
          dayNote['phoneNumber'],
          dayNote['lessonDate'],
          actionNote['actionName'],
          actionNote['grade'],
          actionNote['pos'],
          actionNote['totalNote'],
          actionNote['apratusName'],
          actionNote['timestamp'],
          dayNote['todayNote'],
          dayNote['timestamp'],
          globalFunction.getActionPosition(
            actionNote['apratusName'],
            actionNote['actionName'],
            globalVariables.actionList,
          ),
          actionNote['totalNote'].toString().isNotEmpty ? true : false,
          actionNote['id'],
          dayNote['id'],
        );
        lessonNoteInfoList.add(lessonNoteInfo);
      }
    });

    return lessonNoteInfoList;
  }
}
