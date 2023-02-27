import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbols.dart';

class LessonCardProvider with ChangeNotifier {
  /** 기본정보 */
  String uid = "";
  String memberId = "";
  // String docId;
  String name = "";
  String? phonenumber = "";
  String lessonDate = "";

  /**개별 동작 노트 */
  String? actionName = "";
  String? grade = "";
  int? pos = 0;
  String? totalNote = ""; // 동작별 노트
  String? apratusName = "";
  Timestamp? anTimestamp;

  /**일별 레슨 노트 */
  String? todayNote = ""; // 일별 레슨 노트
  Timestamp? dlTimestamp;

  /** 생성 정보 */
  String position = "";
  bool? noteSelected;
  String? anId = "";
  String? dlId = "";

  String getUid() {
    return this.uid;
  }

  setUid(String uid) {
    this.uid;
  }

  String getMemberId() {
    return this.memberId;
  }

  setMemberId(String) {
    this.memberId;
  }

  String getName() {
    return this.name;
  }

  setName(String name) {
    this.name = name;
  }

  String? getPhonenumber() {
    return this.phonenumber;
  }

  setPhoneumber(String phonenumber) {
    this.phonenumber;
  }

  String getLessonDate() {
    return this.lessonDate;
  }

  setLessonDate(String lessonDate) {
    this.lessonDate;
  }

  String? getActionName(){
    return this.actionName;
  }

  String? getGrade(){
    return this.grade;
  }

  setGrade(String grade){
    this.grade;
  }

  int? getPos(){
    return this.pos;
  }

  setPos(int pos){
    this.pos;
  }

  String? getTotalNote(){
    return this.totalNote;
  }

  setTotalNote(String totakNote){
    this.totalNote;
  }

  String? getApratusName(){
    return this.apratusName;
  }

  setAparatunName(String aparatusName){
    this.apratusName;
  }

  getanTimestamp(){
    return this.dlTimestamp;
  }

  setanTimestamp(){
    this.anTimestamp;
  }

  String? getTodayNote(){
    return this.todayNote;
  }

  setTodayNote(){
    this.totalNote;
  }

  getDltimestamp(){
    return dlTimestamp;
  }

  setDltimestap(DateTime dateTime){
    this.dlTimestamp;
  }

  String getPosition(){
    return this.position;
  }

  setPosition(String position){
    this.poss
  }x


}
