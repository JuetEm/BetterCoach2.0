import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbols.dart';
import 'package:web_project/app/data/model/color.dart';

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
  String? totalNote = ""; // 동작별 노트x
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
    this.uid = uid;
  }

  String getMemberId() {
    return this.memberId;
  }

  setMemberId(String memberId) {
    this.memberId = memberId;
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
    this.phonenumber = phonenumber;
  }

  String getLessonDate() {
    return this.lessonDate;
  }

  setLessonDate(String lessonDate) {
    this.lessonDate = lessonDate;
  }

  String? getActionName(){
    return this.actionName;
  }

  setActionNate(String actionName){
    this.actionName = actionName;
  }

  String? getGrade(){
    return this.grade;
  }

  setGrade(String grade){
    this.grade = grade;
  }

  int? getPos(){
    return this.pos;
  }

  setPos(int pos){
    this.pos = pos;
  }

  String? getTotalNote(){
    return this.totalNote;
  }

  setTotalNote(String totakNote){
    this.totalNote = totakNote;
  }

  String? getApratusName(){
    return this.apratusName;
  }

  setAparatunName(String aparatusName){
    this.apratusName = aparatusName;
  }

  Timestamp? getanTimestamp(){
    return this.dlTimestamp;
  }

  setanTimestamp(Timestamp andTimestamp){
    this.anTimestamp = andTimestamp;
  }

  String? getTodayNote(){
    return this.todayNote;
  }

  setTodayNote(String tadayNote){             
    this.totalNote = tadayNote;
  }

  Timestamp? getDltimestamp(){
    return dlTimestamp;
  }

  setDltimestap(Timestamp timestamp){
    this.dlTimestamp = timestamp;
  }

  String getPosition(){
    return this.position;
  }

  setPosition(String position){
    this.position = position;
  }

  bool? getNoteSelected(){
    return this.noteSelected;
  }             

  setNoteSelected(bool setNetdSelected){
    this.noteSelected = setNetdSelected;
  }         

  String? getAnId(){
    return this.anId;
  }

  setAnId(String Andi){
    this.anId = Andi;
  }

  String? getDnId(){
    return this.dlId;
  }

  setDnId(String Dldi){
    this.dlId = Dldi;
  }


}
