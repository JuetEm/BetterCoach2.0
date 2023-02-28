import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_project/app/data/provider/sequenceCustom_service.dart';
import 'package:web_project/main.dart';

class ImportSequenceController {
  ImportSequenceController();

  SequenceCustomService sequenceCustomService = SequenceCustomService();

  Future<List> readCustomSequenceAtFirstTime(String uid) {
    Future<List> result = sequenceCustomService.read(uid);
    return result;
  }

  int readCustomSequenceTopNumber(String uid) {
    var num = sequenceCustomService.readCustomSequenceTopNum(uid);
  
    print("num : ${num}");
    return num ?? 0;
  }

  createCustomSequence(
      String uid,
      String memberId,
      String todayNote,
      List actionList,
      bool isfavorite,
      int like,
      Timestamp timestamp,
      String sequenceTitle) async {
        
    int num = readCustomSequenceTopNumber(uid);
    int rNum = 0;
    num == 0 ? rNum = 1 : rNum = num;

    sequenceTitle.trim().isEmpty
        ? sequenceTitle = "커스텀 시퀀스 ${rNum}"
        : sequenceTitle = sequenceTitle;

    var result = await sequenceCustomService.create(
      uid,
      memberId,
      rNum,
      todayNote,
      actionList,
      isfavorite,
      like,
      timestamp,
      sequenceTitle,
    );

    return result;
  }
}
