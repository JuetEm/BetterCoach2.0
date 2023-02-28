import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/provider/auth_service.dart';
import 'package:web_project/app/data/provider/sequenceCustom_service.dart';
import 'package:web_project/app/data/provider/sequenceRecent_service.dart';
import 'package:web_project/app/ui/page/importSequenceFromRecent.dart';
import 'package:web_project/app/ui/page/importSequenceFromSaved.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/ui/widget/globalWidget.dart';

// 최근 시퀀스 리스트
List recentSequenceList = [];
List rctSqcList = [];

// 저장된 시퀀스 리스트
List customSequenceList = [];
List ctmSqcList = [];

class SequenceLibrary extends StatefulWidget {
  const SequenceLibrary({super.key});

  @override
  State<SequenceLibrary> createState() => _SequenceLibraryState();
}

class _SequenceLibraryState extends State<SequenceLibrary> {
  @override
  void initState() {
    super.initState();
    recentSequenceList = [];
  }

  @override
  void dispose() {
    recentSequenceList = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: BaseAppBarMethod(context, "시퀀스 관리", () {
          Navigator.pop(context);
        },
            null,

            /// 탭바
            TabBar(
                indicatorColor: Palette.buttonOrange,
                unselectedLabelColor: Palette.gray66,
                labelColor: Palette.textOrange,
                tabs: [
                  /// 저장된 시퀀스 탭
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '저장된 시퀀스',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  /// 최근 시퀀스 탭
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '최근 시퀀스',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ])),

        /// 바디 시작
        body: CenterConstrainedBody(
          child: TabBarView(
            children: [
              /// 저장된 시퀀스 탭 내용
              Consumer<SequenceCustomService>(
                builder: (context, sequenceCustomService, child) {
                  customSequenceList.isEmpty ?
                  sequenceCustomService.read(AuthService().currentUser()!.uid)
                    .then((value) {
                      customSequenceList.addAll(value);
                      setState(() {
                        
                      });
                    }) : null;
                  return Container(
                    width: double.infinity,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: customSequenceList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ImportSequenceFromSaved()),
                            ).then((value){});
                          },
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                          tileColor: Palette.mainBackground,
                          title: Row(
                            children: [
                              Text(customSequenceList[index]['name']),
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 6),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Palette.gray99, width: 1)),
                                child: Text(
                                  '${2 * index}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              /// 최근 시퀀스 탭 내용
              Consumer<SequenceRecentService>(
                  builder: (context, sequenceRecentService, child) {
                
                recentSequenceList.isEmpty
                    ? sequenceRecentService
                        .read(AuthService().currentUser()!.uid)
                        .then((value) {
                        print("value : ${value.length}");
                        recentSequenceList.addAll(value);

                        setState(() {});
                      }).whenComplete(() {})
                    : null;
                return Container(
                  width: double.infinity,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: recentSequenceList.length,
                    itemBuilder: (context, index) {
                      print(
                          "hfduosanoirwnvioenroiger - ${recentSequenceList[index]}");
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImportSequenceFromRecent(
                                      actionList: recentSequenceList[index]
                                          ['actionList'],
                                    )),
                          ).then((value) {});
                        },
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                        tileColor: Palette.mainBackground,
                        title: Row(
                          children: [
                            Text(recentSequenceList[index]['sequenceTitle']),
                            SizedBox(width: 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 6),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Palette.gray99, width: 1)),
                              child: Text(
                                '40',
                                style: TextStyle(fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),
                      );
                    },
                  ),
                ); /*  */
              })
            ],
          ),
        ),
      ),
    );
  }
}
