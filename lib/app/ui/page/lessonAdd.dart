import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/ui/widget/globalWidget.dart';

String pageName = "노트추가";

class LessonAdd extends StatefulWidget {
  const LessonAdd({super.key});

  @override
  State<LessonAdd> createState() => _LessonAddState();
}

class _LessonAddState extends State<LessonAdd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.secondaryBackground,
      appBar: BaseAppBarMethod(context, pageName, (){
        Navigator.pop(context);
      }, [
        Padding(padding: EdgeInsets.only(right: 10),
        child: TextButton(onPressed: (){
          /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("일별노트 또는 동작선택중 하나는 필수입력해주세요."),
                      ));

                      saveMethod(lessonService, lessonDateArg, lessonAddMode,
                          customUserInfo, dayLessonService); 
                          
                          Navigator.pop(context);
                          */
        }, child: Text('완료',
        style: TextStyle(color: Palette.textBlue,
        fontSize: 16),),),)
      ], null),
      body: CenterConstrainedBody(child: Container(alignment: Alignment.topCenter,
      child: SafeArea(child: SingleChildScrollView(physics: BouncingScrollPhysics(),child: Container(),)),))
    );
  }
}