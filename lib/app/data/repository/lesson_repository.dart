import 'package:web_project/app/data/provider/auth_service.dart';
import 'package:web_project/app/data/provider/daylesson_service.dart';
import 'package:web_project/app/data/provider/lesson_service.dart';

class LessonRepository {
  LessonRepository();

  LessonService lessonService = LessonService();
  DayLessonService dayLessonService = DayLessonService();

  /// User Id와 Member Id 일치하는 레슨, 동작 리스트 가져오기
  Future<List> getLessonActionNote(String uid, String memberId) async {
    List resultList = [];
    await lessonService.readMemberActionNote(uid, memberId).then((value) {
      resultList.addAll(value);
    });
    return resultList;
  }

  /// User Id 일치하는 일별 노트 리스트 가져오기
  Future<List> getLessonDaynNote(String uid) async {
    List resultList = [];
    await dayLessonService.readLessonDayNote(uid).then((value) {
      resultList.addAll(value);
    });
    return resultList;
  }
}
