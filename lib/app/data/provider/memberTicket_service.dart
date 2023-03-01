import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_project/app/ui/page/ticketLibraryMake.dart';
import 'package:web_project/app/function/globalFunction.dart';

class MemberTicketService extends ChangeNotifier {
  CollectionReference<Map<String, dynamic>> memberTicketCollection =
      FirebaseFirestore.instance.collection('memberTicket');

      GlobalFunction globalFunction = GlobalFunction();

  Future<List> read(String uid) async {
    // .orderBy("name") // orderBy 기능을 사용하기 위해서는 console.cloud.google.com
    var result = await memberTicketCollection
        .where('uid', isEqualTo: uid)
        .orderBy('ticketTitle', descending: false)
        .get();

    List resultList = [];
    var docsLength = result.docs.length;
    var rstObj = {};
    for (int i = 0; i < docsLength; i++) {
      // print("result.docs[i].data() : ${result.docs[i].data()}");
      rstObj = result.docs[i].data();
      rstObj['id'] = result.docs[i].id;
      rstObj['ticketDateLeft'] = globalFunction.getDDayLeft(globalFunction.getDateFromTimeStamp(result.docs[i]['ticketEndDate'])); 
      resultList.add(rstObj);
    }
    return resultList;
  }

  Future<List> readByMemberTmp(String uid, String memberId) async {
    // .orderBy("name") // orderBy 기능을 사용하기 위해서는 console.cloud.google.com
    var result = await memberTicketCollection
        .where('uid', isEqualTo: uid)
        .where('memberId', isEqualTo: memberId)
        .orderBy('ticketTitle', descending: false)
        .get();

    List resultList = [];
    var docsLength = result.docs.length;
    var rstObj = {};
    for (int i = 0; i < docsLength; i++) {
      // print("result.docs[i].data() : ${result.docs[i].data()}");
      rstObj = result.docs[i].data();
      rstObj['id'] = result.docs[i].id;
      resultList.add(rstObj);
    }
    return resultList;
  }

  Future<List> readByMember(String uid, String memberId) async {
    // .orderBy("name") // orderBy 기능을 사용하기 위해서는 console.cloud.google.com
    var result = await memberTicketCollection
        .where('uid', isEqualTo: uid)
        .where('memberId', isEqualTo: memberId)
        .orderBy('ticketTitle', descending: false)
        .get();

    List resultList = [];
    var docsLength = result.docs.length;
    var rstObj = {};
    for (int i = 0; i < docsLength; i++) {
      // print("result.docs[i].data() : ${result.docs[i].data()}");
      rstObj = result.docs[i].data();
      rstObj['id'] = result.docs[i].id;
      resultList.add(rstObj);
    }
    notifyListeners();
    return resultList;
  }

  Future<String> create(
    final String uid,
    final String memberId,
    final int ticketUsingCount,
    final int ticketCountLeft,
    final int ticketCountAll,
    final String ticketTitle,
    final String ticketDescription,
    final DateTime? ticketStartDate,
    final DateTime? ticketEndDate,
    final int ticketDateLeft,
    final DateTime createDate,
    final bool isSelected,
    final bool isAlive,
  ) async {
    // report 만들기
    String id = "";
    await memberTicketCollection.add({
      'uid': uid, // 작성자 uid
      'memberId': memberId, // 회원 docId
      'ticketCountLeft': ticketCountLeft, // 수강권 남은 횟수
      'ticketUsingCount': ticketUsingCount, // 수강권 사용 횟수
      'ticketCountAll': ticketCountAll, // 수강권 총 횟수
      'ticketTitle': ticketTitle, // 수강권 명
      'ticketDescription': ticketDescription, // 수강권 설명
      'ticketStartDate': ticketStartDate, // 수강권 시작일
      'ticketEndDate': ticketEndDate, // 수강권 종료일
      'ticketDateLeft': ticketDateLeft, // 수강권 남은 일 수
      'createDate': createDate, // 수강권 생성일
      'isSelected': isSelected, // 수강권 선택 여부
      'isAlive': isAlive, //수강권 사용 가능 여부
    }).then((value) {
      id = value.id;
      print("Successfully completed");
    }, onError: (e) {
      print("Error completing: ${e}");
    });
    notifyListeners(); // 화면 갱신

    return id;
  }

  Future<String> update(
    final String uid,
    final String docId,
    final String memberId,
    final int ticketUsingCount,
    final int ticketCountLeft,
    final int ticketCountAll,
    final String ticketTitle,
    final String ticketDescription,
    final DateTime? ticketStartDate,
    final DateTime? ticketEndDate,
    final int ticketDateLeft,
    final DateTime createDate,
    final bool isSelected,
    final bool isAlive,
  ) async {
    print("rdgafdsgjhgdhgfd docId : ${docId}");
    // report 만들기
    String id = "";
    await memberTicketCollection.doc(docId).update({
      'uid': uid, // 작성자 uid
      'memberId': memberId, // 회원 아이디
      'ticketCountLeft': ticketCountLeft, // 수강권 남은 횟수
      'ticketUsingCount': ticketUsingCount, // 수강권 사용 횟수
      'ticketCountAll': ticketCountAll, // 수강권 총 횟수
      'ticketTitle': ticketTitle, // 수강권 명
      'ticketDescription': ticketDescription, // 수강권 설명
      'ticketStartDate': ticketStartDate, // 수강권 시작일
      'ticketEndDate': ticketEndDate, // 수강권 종료일
      'ticketDateLeft': ticketDateLeft, // 수강권 남을 일수
      'createDate': createDate, // 수강권 생성일
      'isSelected': isSelected, // 수강권 선택 여부
      'isAlive': isAlive, //수강권 사용 가능 여부
    }).then((value) {
      // id = value
      // id = docID;
      print("Successfully completed");
    }, onError: (e) {
      print("Error completing: ${e}");
    });
    notifyListeners(); // 화면 갱신

    return docId;
  }

  Future<String> updateTicketCountLeft(
    final String uid,
    final String docId,
    final String memberId,
    final int ticketUsingCount,
    final int ticketCountLeft,
  ) async {
    print("docId : ${docId}");
    // report 만들기
    String id = "";
    await memberTicketCollection.doc(docId).update({
      'uid': uid, // 작성자 uid
      'memberId': memberId, // 회원 아이디
      'ticketCountLeft': ticketCountLeft, // 수강권 남은 횟수
      'ticketUsingCount': ticketUsingCount, // 수강권 사용 횟수
    }).then((value) {
      // id = value
      // id = docID;
      print("Successfully completed");
    }, onError: (e) {
      print("Error completing: ${e}");
    });
    notifyListeners(); // 화면 갱신

    return docId;
  }

  void delete({
    String? docId,
    Function? onSuccess,
    Function? onError,
  }) async {
    // bucket 삭제
    await memberTicketCollection.doc(docId).delete();
    notifyListeners();
    // 화면 갱신
    onSuccess!(); // 성공시

    onError!(); // 에러시
  }
}
