import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DayLessonService extends ChangeNotifier {
  final daylessonCollection =
      FirebaseFirestore.instance.collection('daylesson');

  Future<List> readLessonDayNote(
    String uid,
  ) async {
    final result;
    // 내 bucketList 가져오기
    // throw UnimplementedError(); // return 값 미구현 에러
    // uid가 현재 로그인된 유저의 uid와 일치하는 문서만 가져온다.

    result = await daylessonCollection
        .where('uid', isEqualTo: uid)
        .orderBy('docId', descending: false)
        .get();

    List resultList = [];
    var docsLength = result.docs.length;
    var rstObj = {};
    for (int i = 0; i < result.docs.length; i++) {
      rstObj = result.docs[i].data();
      rstObj['id'] = result.docs[i].id;

      // if (rstObj)
      resultList.add(rstObj);
      // print("[daylesson]result.docs[i].data() : ${result.docs[i].data()}");
      /* rstObj = result.docs[i].data();
          rstObj['id'] = result.docs[i].id;
          resultList.add(rstObj); */
    }
    // print('[daylesson]resultList:$resultList');

    notifyListeners();

    return resultList;
  }

  Future<List> readTodayNoteOflessonDate(
    String uid,
    String docId,
    String lessonDate,
  ) async {
    final result;
    // 내 bucketList 가져오기
    // throw UnimplementedError(); // return 값 미구현 에러
    // uid가 현재 로그인된 유저의 uid와 일치하는 문서만 가져온다.

    result = await daylessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .where('lessonDate', isEqualTo: lessonDate)
        .get();

    List resultList = [];
    var docsLength = result.docs.length;
    var rstObj = {};
    for (int i = 0; i < result.docs.length; i++) {
      rstObj = result.docs[i].data();
      rstObj['id'] = result.docs[i].id;

      // if (rstObj)
      resultList.add(rstObj);
      // print("[daylesson]result.docs[i].data() : ${result.docs[i].data()}");
      /* rstObj = result.docs[i].data();
          rstObj['id'] = result.docs[i].id;
          resultList.add(rstObj); */
    }
    // print('[daylesson]resultList:$resultList');

    notifyListeners();

    return resultList;
  }

  Future<List> readDaylessonListAtFirstTime(String uid) async {
    var result = await daylessonCollection
        .where('uid', isEqualTo: uid)
        .orderBy('docId', descending: false)
        .orderBy('name', descending: false)
        .get();

    List resultList = [];
    var docsLength = result.docs.length;
    var rstObj = {};
    for (int i = 0; i < result.docs.length; i++) {
      rstObj = result.docs[i].data();
      rstObj['id'] = result.docs[i].id;

      // if (rstObj)
      resultList.add(rstObj);
      // print("[daylesson]result.docs[i].data() : ${result.docs[i].data()}");
      /* rstObj = result.docs[i].data();
          rstObj['id'] = result.docs[i].id;
          resultList.add(rstObj); */
    }
    // print('[daylesson]resultList:$resultList');

    notifyListeners();
    return resultList;
  }

  updateDayNote(
    String id,
    String docId,
    String lessonDate,
    String name,
    // Timestamp,
    String todayNote,
    String uid,
  ) async {
    await daylessonCollection.doc(id).update({
      'docId': docId,
      'lessonDate': lessonDate,
      'name': name,
      'timestamp': DateTime.now(),
      'todayNote': todayNote,
      'uid': uid,
    });

    notifyListeners();
  }

  updateTicketUsedById(
    String id,
    bool ticketUsed,
    String usedTicketId,
  ) async {
    await daylessonCollection.doc(id).update({
      'ticketUsed': ticketUsed,
      'usedTicketId': usedTicketId,
    });

    notifyListeners();
  }

  creatDayNote(
    String docId,
    String lessonDate,
    String name,
    // Timestamp,
    String todayNote,
    String uid,
  ) async {
    await daylessonCollection.add({
      'docId': docId,
      'lessonDate': lessonDate,
      'name': name,
      'timestamp': DateTime.now(),
      'todayNote': todayNote,
      'uid': uid,
    });

    notifyListeners();
  }

  void delete({
    required String docId,
    required Function onSuccess,
    required Function onError,
  }) async {
    // bucket 삭제
    await daylessonCollection.doc(docId).delete();
    notifyListeners();
    // 화면 갱신
    onSuccess(); // 화면 갱신
  }
}
