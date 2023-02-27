import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/backup/lessonAdd.dart';
import 'package:web_project/app/function/globalFunction.dart';
import 'package:web_project/main.dart';

Timestamp? timestamp = null;

class LessonService extends ChangeNotifier {
  final lessonCollection = FirebaseFirestore.instance.collection('lesson');
  final todaylessonCollection =
      FirebaseFirestore.instance.collection('daylesson');

  GlobalFunction globalFunction = GlobalFunction();

  updateLessonActionNote(
    String id,
    String docId,
    String actionName,
    String apratusName,
    String grade,
    String lessonDate,
    String name,
    String phoneNumber,
    int pos,
    Timestamp timestamp,
    String totalNote,
    String uid,
  ) {
    lessonCollection
        .doc(id)
        .update({
          'docId': docId,
          'actionName': actionName,
          'apratusName': apratusName,
          'grade': grade,
          'lessonDate': lessonDate,
          'name': name,
          'phoneNumber': phoneNumber,
          'pos': pos,
          'timestamp': timestamp,
          'totalNote': totalNote,
          'uid': uid,
        })
        .then((value) {})
        .onError((error, stackTrace) {})
        .whenComplete(() {});
  }

  Future<void> create({
    required String
        docId, // 회원 교유번호, firebase에서 생성하는 회원 (문서) 고유번호를 통해 회원 식별, 기존 전화번호르 회원 식별하는 것에서 변경
    required String uid, // 강사 고유번호
    required String name, //회원이름
    required String phoneNumber, // 회원 고유번호 (전화번호로 회원 식별) => 전화번호 식별 방식 폐기
    required String apratusName, //기구이름
    required String actionName, //동작이름
    required String lessonDate, //수업날짜
    required String grade, //수행도
    required String totalNote, //수업총메모
    int? pos, // 동작 순서
    required Function onSuccess,
    required Function onError,
  }) async {
    // 문서 만들기 set 방식 => 문서 아이디 지정 부여
    // await bucketCollection.doc("원하는 ID").set({
    //   'uid': uid, // 유저 식별자
    //   'job': job, // 하고싶은 일
    //   'isDone': false, // 완료 여부
    // });

    // 문서 만들기 add 방식 => 문서 ID를 랜덤으로 부여
    // await lessonCollection.add({
    //   'uid': uid, //강사 고유번호
    //   'name': name, //회원이름
    //   'apratusName': apratusName, //기구이름
    //   'actionName': actionName, //동작이름
    //   'lessonDate': lessonDate, //수업날짜
    //   'grade': grade, //수행도
    //   'totalNote': totalNote, //수업총메모
    // });

    print("Create Called!!");
    if (pos == null) {
      pos = await countPos(
        uid,
        docId,
        lessonDate,
      );
      print("pos Null change : ${pos}");
    }

    print('pos : ${pos}');

    timestamp = Timestamp.now();

    await lessonCollection.add({
      'docId': docId, // 회원 고유번호, 회원(문서번호)번호로 식별
      'uid': uid, //강사 고유번호
      'name': name, //회원이름
      'phoneNumber': phoneNumber,
      'apratusName': apratusName, //기구이름
      'actionName': actionName, //동작이름
      'lessonDate': lessonDate, //수업날짜
      'grade': grade, //수행도
      'totalNote': totalNote, //수업총메모
      'timestamp': timestamp,
      'pos': pos, // 순서
    }).then((value) {
      print("value : ${value}");
      onSuccess();
    }).onError((error, stackTrace) {
      print("error : ${error}");
      onError();
    });
    print("[LS] lessonNote create NofityLisners실행");
    notifyListeners(); // 화면 갱신
  }

  Future<QuerySnapshot> readTodayNoteOflessonDate(
    String uid,
    String docId,
    String lessonDate,
  ) async {
    final result;
    // 내 bucketList 가져오기
    // throw UnimplementedError(); // return 값 미구현 에러
    // uid가 현재 로그인된 유저의 uid와 일치하는 문서만 가져온다.

    result = await todaylessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .where('lessonDate', isEqualTo: lessonDate)
        .get();

    return result;
  }

  Future<QuerySnapshot> readTodaynote(
    String uid,
    String docId,
  ) async {
    // uid가 현재 로그인된 유저의 uid와 일치하는 문서만 가져온다.
    return await todaylessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .orderBy("lessonDate", descending: true)
        .get();
  }

  Future<int> countTodaynote(
    String uid,
    String docId,
  ) async {
    QuerySnapshot docRaw = await todaylessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .get();
    List<DocumentSnapshot> docs = docRaw.docs;
    print('pos : ${docs.length}');

    return docs.length;
  }

  Future<void> createTodaynote({
    required String
        docId, // 회원 교유번호, firebase에서 생성하는 회원 (문서) 고유번호를 통해 회원 식별, 기존 전화번호르 회원 식별하는 것에서 변경
    required String uid, // 강사 고유번호
    required String name, //회원이름
    required String lessonDate, //수업날짜
    required String todayNote, //수업총메모
    required bool isRefresh, //수업총메모

    required Function onSuccess,
    required Function onError,
  }) async {
    // 문서 만들기 set 방식 => 문서 아이디 지정 부여
    // await bucketCollection.doc("원하는 ID").set({
    //   'uid': uid, // 유저 식별자
    //   'job': job, // 하고싶은 일
    //   'isDone': false, // 완료 여부
    // });

    timestamp = Timestamp.now();

    await todaylessonCollection.add({
      'docId': docId, // 회원 고유번호, 회원(문서번호)번호로 식별
      'uid': uid, //강사 고유번호
      'name': name, //회원이름
      'lessonDate': lessonDate, //수업날짜
      'timestamp': timestamp,
      'todayNote': todayNote,
    }).then((value) {
      print("value : ${value}");
      onSuccess();
    }).onError((error, stackTrace) {
      print("error : ${error}");
      onError();
    });
    print("[LS] createTodaynote NofityLisners실행");
    if (isRefresh) {
      notifyListeners(); // 화면 갱신
    }
  }

  Future<void> updateTodayNote({
    required String docId, //일별메모문서번호
    required String todayNote, //수업메모
    required Function onSuccess,
    required Function onError,
  }) async {
    await todaylessonCollection.doc(docId).update({
      //수업날짜
      'timestamp': timestamp,
      'todayNote': todayNote,
    });
    print("[LS] updateTodayNote NofityLisners실행");
    notifyListeners();
    onSuccess(); // 화면 갱신
  }

  Future<void> deleteTodayNote({
    required String docId,
    required Function onSuccess,
    required Function onError,
  }) async {
    print("deleteTodayNote - docId:${docId}");
    // bucket 삭제
    await todaylessonCollection.doc(docId).delete().then((value) {
      print("delete todaylesson");
    }).onError((error, stackTrace) {
      print("error : ${error}");
      onError();
    });
    //notifyListeners(); // 화면 갱신

    //onSuccess(); // 화면 갱신
  }

  Future<void> clearTodayNote({
    required String docId,
    required Function onSuccess,
    required Function onError,
  }) async {
    print("deleteTodayNote - docId:${docId}");
    // bucket 삭제
    await todaylessonCollection.doc(docId).update({'todayNote': ""});
    //notifyListeners(); // 화면 갱신

    //onSuccess(); // 화면 갱신
  }

  Future<QuerySnapshot> read(
    String uid,
    String docId,
  ) async {
    // 내 bucketList 가져오기
    // throw UnimplementedError(); // return 값 미구현 에러
    // uid가 현재 로그인된 유저의 uid와 일치하는 문서만 가져온다.
    return await lessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .get();
  }

  Future<QuerySnapshot> readNotesOfAction(
    String uid,
    String docId,
    String actionName,
    Function onSuccess,
    Function onError,
  ) async {
    // 내 bucketList 가져오기
    // throw UnimplementedError(); // return 값 미구현 에러
    // uid가 현재 로그인된 유저의 uid와 일치하는 문서만 가져온다.
    return await lessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .where('actionName', isEqualTo: actionName)
        .get()
        .then((value) {
      print("value : ${value.docs.toList()}");
      return value;
    });
  }

  Future<List> readDateMemberActionNote(
      String uid, String memberId, String date) async {
    List lessonActionResultList = [];
    var lessonActionResult = await lessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: memberId)
        .where('lessonDate', isEqualTo: date)
        .orderBy('pos', descending: false)
        .get();

    var docsALength = lessonActionResult.docs.length;
    var rstAObj = {};
    for (int i = 0; i < docsALength; i++) {
      print(
          "readDateMemberComplexNote - lessonActionResult.docs[i].data() : ${lessonActionResult.docs[i].data()}");
      rstAObj = lessonActionResult.docs[i].data();
      rstAObj['id'] = lessonActionResult.docs[i].id;

      rstAObj['noteSelected'] =
          rstAObj['totalNote'].toString().trim().isNotEmpty ? true : false;
      rstAObj['deleteSelected'] = true;
      rstAObj['position'] = getActionPosition(rstAObj['apratusName'],
          rstAObj['actionName'], globalVariables.actionList);
      lessonActionResultList.add(rstAObj);
    }

    /* List lessonNoteResultList = [];
    var lessonNoteResult = await todaylessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: memberId)
        .where('lessonDate', isEqualTo: date)
        .get();

    var docsNLength = lessonNoteResult.docs.length;
    var rstNObj = {};
    for (int i = 0; i < docsNLength; i++) {
      print("readDateMemberComplexNote - lessonNoteResult.docs[i].data() : ${lessonNoteResult.docs[i].data()}");
      rstNObj = lessonNoteResult.docs[i].data();
      rstNObj['id'] = lessonNoteResult.docs[i].id;

      lessonNoteResultList.add(rstNObj);
    } */

    //  notifyListeners();

    return lessonActionResultList;
  }

  Future<List> readMemberActionNote(
    String uid,
    String memberId,
  ) async {
    List lessonActionResultList = [];
    var lessonActionResult = await lessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: memberId)
        .orderBy('pos', descending: false)
        .get();

    var docsALength = lessonActionResult.docs.length;
    var rstAObj = {};
    for (int i = 0; i < docsALength; i++) {
      print(
          "readDateMemberComplexNote - lessonActionResult.docs[i].data() : ${lessonActionResult.docs[i].data()}");
      rstAObj = lessonActionResult.docs[i].data();
      rstAObj['id'] = lessonActionResult.docs[i].id;

      rstAObj['noteSelected'] =
          rstAObj['totalNote'].toString().trim().isNotEmpty ? true : false;
      rstAObj['deleteSelected'] = true;
      rstAObj['position'] = getActionPosition(rstAObj['apratusName'],
          rstAObj['actionName'], globalVariables.actionList);
      lessonActionResultList.add(rstAObj);
    }

    return lessonActionResultList;
  }

  Future<QuerySnapshot> readNotesOflessonDate(
    String uid,
    String docId,
    String lessonDate,
  ) async {
    // 내 bucketList 가져오기
    // throw UnimplementedError(); // return 값 미구현 에러
    // uid가 현재 로그인된 유저의 uid와 일치하는 문서만 가져온다.
    // print(
    //     "날짜별 데이터 읽기 : uid : ${uid}-docId : ${docId}-lessonDate : ${lessonDate}");
    print("readNotesOflessonDate : ${lessonDate}");
    return await lessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .where('lessonDate', isEqualTo: lessonDate)
        .orderBy('pos', descending: false)
        .get();
  }

  Future<void> updatePos(
    String docId,
    int pos,
  ) async {
    final result = await lessonCollection.doc(docId).update({
      'pos': pos,
    });
    //notifyListeners(); // 화면 갱신
  }

  Future<int> countPos(
    String uid,
    String docId,
    String lessonDate,
  ) async {
    QuerySnapshot docRaw = await lessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .where('lessonDate', isEqualTo: lessonDate)
        .orderBy("pos", descending: false)
        .get();
    List<DocumentSnapshot> docs = docRaw.docs;
    print('[LS] countPos 실행 - pos : ${docs.length}');

    return docs.length;
  }

  Future<void> update(
    String docId,
    String apratusName,
    String actionName,
    String lessonDate,
    String grade,
    String totalNote,
  ) async {
    // bucket isActive 업데이트
    print(
        "update docId : ${docId}, apratusName : ${apratusName}, lessonDate ${lessonDate}, totalNote : ${totalNote}");
    final result = await lessonCollection.doc(docId).update({
      'apratusName': apratusName,
      'actionName': actionName,
      'lessonDate': lessonDate,
      'grade': grade,
      'totalNote': totalNote,
    });
    print('[LS] lesson Note 실행 - NotifyListner');
    notifyListeners(); // 화면 갱신
  }

  Future<void> updateTotalNote(
    String docId,
    String totalNote,
  ) async {
    final result = await lessonCollection.doc(docId).update({
      'totalNote': totalNote,
    });
    print('[LS] updateTotalNote : ${docId} - ${totalNote}');
    // 화면 갱신
  }

  Future<void> updateposition(String docId, bool isActive) async {
    // bucket isActive 업데이트

    await lessonCollection.doc(docId).update({'isActive': isActive});
    print('[LS] updateposition 실행 - NotifyListner');
    notifyListeners(); // 화면 갱신
  }

  Future<void> deleteSinglelesson({
    required String uid,
    required String memberId,
    required String docId,
    required String lessonDate,
    required Function onSuccess,
    required Function onError,
  }) async {
    print("[LS] deleteSinglelesson - uid : ${uid}, docId : ${docId}");
    //일별 노트가 없을 경우 일별노트 생성
    QuerySnapshot docRawTodayNote = await todaylessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: memberId)
        .where('lessonDate', isEqualTo: lessonDate)
        .get();

    QuerySnapshot docRaw = await lessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: memberId)
        .where('lessonDate', isEqualTo: lessonDate)
        .get();
    print(
        "[LS] 마지막 동작노트 삭제시, 일별노트가 없으면 삭제,${docRawTodayNote.docs.isNotEmpty} / docRaw.docs.length - ${docRaw.docs.length}");

    if (docRawTodayNote.docs.isNotEmpty && (docRaw.docs.length < 2)) {
      if (docRawTodayNote.docs.first['todayNote'] == "") {
        print("[LS] 마지막 동작노트 삭제 실행 : ${docRawTodayNote.docs.first.id}");
        await deleteTodayNote(
          docId: docRawTodayNote.docs.first.id,
          onSuccess: () {},
          onError: () {},
        );
      }
    }

    print("삭제할 docId : ${docId}");
    // bucket 삭제
    await lessonCollection.doc(docId).delete().then((value) {
      print("[LS] deleteSinglelesson 실행 - delete then");
      onSuccess(); // 화면 갱신
    }).onError((error, stackTrace) {
      print("[LS] deleteSinglelesson 실행 - delete error : ${error}");
    });
    print('[LS] deleteSinglelesson 실행 - NotifyListner');
    notifyListeners(); // 화면 갱신
  }

  Future<void> deleteMultilesson({
    required String docId,
    required Function onSuccess,
    required Function onError,
  }) async {
    // bucket 삭제
    await lessonCollection.doc(docId).delete().then((value) {
      print("[LS] deleteMultilesson 실행 - delete then");
      onSuccess(); // 화면 갱신
      print('[LS] deleteMultilesson 실행 - notifyListeners');
      //notifyListeners();
      // 화면 갱신
    }).onError((error, stackTrace) {
      print("[LS] deleteMultilesson 실행 - delete error : ${error}");
    });
  }

  Future<void> deleteMultilessonBatch({
    required List<String> docIds,
    required Function onSuccess,
    required Function onError,
  }) async {
    // Get a new write batch
    final batch = FirebaseFirestore.instance.batch();

    for (var i = 0; i < docIds.length; ++i) {
      batch.delete(lessonCollection.doc(docIds[i]));
    }

    batch.commit();
    // // bucket 삭제
    // await lessonCollection.doc(docId).delete().then((value) {
    //   print("[LS] deleteMultilesson 실행 - delete then");
    //   onSuccess(); // 화면 갱신
    //   print('[LS] deleteMultilesson 실행 - notifyListeners');
    //   //notifyListeners();
    //   // 화면 갱신
    // }).onError((error, stackTrace) {
    //   print("[LS] deleteMultilesson 실행 - delete error : ${error}");
    // });
  }

  Future<void> deleteFromActionSelect(String uid, String docId,
      String lessonDate, String apparatusName, String actionName) async {
    //일별 노트가 없을 경우 일별노트 생성
    QuerySnapshot docRawTodayNote = await todaylessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .where('lessonDate', isEqualTo: lessonDate)
        .get();

    QuerySnapshot docRaw = await lessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .where('lessonDate', isEqualTo: lessonDate)
        .where('apratusName', isEqualTo: apparatusName)
        .where('actionName', isEqualTo: actionName)
        .get();

    print(
        "[LS] deleteFromActionSelect - uid : ${uid}, docId : ${docId}, apparatusName : ${apparatusName}, actionName : ${actionName}");
    print(
        "[LS] 마지막 동작노트 삭제시, 일별노트가 없으면 삭제,${docRawTodayNote.docs.isNotEmpty} / docRaw.docs.length - ${docRaw.docs.length}");

    if (docRawTodayNote.docs.isNotEmpty && (docRaw.docs.length < 2)) {
      if (docRawTodayNote.docs.first['todayNote'] == "") {
        print("[LS] 마지막 동작노트 삭제 실행 : ${docRawTodayNote.docs.first.id}");
        await deleteTodayNote(
          docId: docRawTodayNote.docs.first.id,
          onSuccess: () {},
          onError: () {},
        );
      }
    }

    String noteId = docRaw.docs.first.id;
    print(
        "[LS] deleteFromActionSelect - noteId : ${noteId}, lessonDate : ${lessonDate}, apparatusName : ${apparatusName}, actionName : ${actionName}");
    await lessonCollection.doc(noteId).delete().then((value) {
      print("[LS] deleteFromActionSelect - delete then");
    }).onError((error, stackTrace) {
      print("[LS] deleteFromActionSelect - delete error : ${error}");
    });
  }

  Future<void> createFromActionSelect({
    required String
        docId, // 회원 교유번호, firebase에서 생성하는 회원 (문서) 고유번호를 통해 회원 식별, 기존 전화번호르 회원 식별하는 것에서 변경
    required String uid, // 강사 고유번호
    required String name, //회원이름
    required String phoneNumber, // 회원 고유번호 (전화번호로 회원 식별) => 전화번호 식별 방식 폐기
    required String apratusName, //기구이름
    required String actionName, //동작이름
    required String lessonDate, //수업날짜
    required String grade, //수행도
    required String totalNote, //수업총메모
    int? pos,
    required Function onSuccess,
    required Function onError,
  }) async {
    print("[LS] createFromActionSelect - Create Called!!");
    if (pos == null) {
      pos = await countPos(
        uid,
        docId,
        lessonDate,
      );
      print("pos Null change : ${pos}");
    }

    print('pos : ${pos}');

    timestamp = Timestamp.now();

    //일별 노트가 없을 경우 일별노트 생성
    QuerySnapshot docRaw = await todaylessonCollection
        .where('uid', isEqualTo: uid)
        .where('docId', isEqualTo: docId)
        .where('lessonDate', isEqualTo: lessonDate)
        .get();

    if (docRaw.docs.isEmpty) {
      //
      print("[LS] 일별노트가 없으면,${docRaw.docs.isEmpty}");
      await createTodaynote(
          docId: docId,
          uid: uid,
          name: name,
          lessonDate: lessonDate,
          todayNote: "",
          isRefresh: false,
          onSuccess: () {},
          onError: () {});
    }

    await lessonCollection.add({
      'docId': docId, // 회원 고유번호, 회원(문서번호)번호로 식별
      'uid': uid, //강사 고유번호
      'name': name, //회원이름
      'phoneNumber': phoneNumber,
      'apratusName': apratusName, //기구이름
      'actionName': actionName, //동작이름
      'lessonDate': lessonDate, //수업날짜
      'grade': grade, //수행도
      'totalNote': totalNote, //수업총메모
      'timestamp': timestamp,
      'pos': pos, // 순서
    }).then((value) {
      print("[LS] createFromActionSelect then - value : ${value}");

      onSuccess();
    }).onError((error, stackTrace) {
      print("[LS] createFromActionSelect then - error : ${error}");
      onError();
    });
    //notifyListeners(); // 화면 갱신
  }

  void delete({
    required String docId,
    required Function onSuccess,
    required Function onError,
  }) async {
    // bucket 삭제
    await lessonCollection.doc(docId).delete();

    // 화면 갱신
    onSuccess(); // 화면 갱신

    notifyListeners();
  }
}
