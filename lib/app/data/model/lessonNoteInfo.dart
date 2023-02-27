import 'package:cloud_firestore/cloud_firestore.dart';

class LessonNoteInfo {
  /** 기본정보 */
  String uid;
  String memberId;
  // String docId;
  String name;
  String? phoneNumber;
  String lessonDate;

  /**개별 동작 노트 */
  String? actionName;
  String? grade;
  int? pos;
  String? totalNote; // 동작별 노트
  String? apratusName;
  Timestamp? anTimestamp;

  /**일별 레슨 노트 */
  String? todayNote; // 일별 레슨 노트
  Timestamp? dlTimestamp;

  /** 생성 정보 */
  String position;
  bool? noteSelected;
  String? anId;
  String? dlId;

  LessonNoteInfo(
    this.uid,
    this.memberId,
    // this.docId,
    this.name,
    this.phoneNumber,
    this.lessonDate,
    this.actionName,
    this.grade,
    this.pos,
    this.totalNote,
    this.apratusName,
    this.anTimestamp,
    this.todayNote,
    this.dlTimestamp,
    this.position,
    this.noteSelected,
    this.anId,
    this.dlId,
  );
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'memberId': memberId,
        'name': name,
        'phoneNumber': phoneNumber,
        'lessonDate': lessonDate,
        'actionName': actionName,
        'grade': grade,
        'pos': pos,
        'totalNote': totalNote,
        'apratusName': apratusName,
        'anTimestamp': anTimestamp,
        'todayNote': todayNote,
        'dlTimestamp': dlTimestamp,
        'position': position,
        'noteSelected': noteSelected,
        'anId': anId,
        'dlId': dlId,
      };
}
