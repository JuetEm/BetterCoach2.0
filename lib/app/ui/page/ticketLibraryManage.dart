import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/app/data/provider/ticketLibrary_service.dart';
import 'package:web_project/app/ui/page/ticketLibraryMake.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/ui/widget/globalWidget.dart';
import 'package:web_project/main.dart';
import 'package:web_project/app/ui/widget/ticketWidget.dart';
import 'package:web_project/app/data/model/userInfo.dart';

class TicketLibraryManage extends StatefulWidget {
  const TicketLibraryManage({this.TicketLibraryManageList, super.key});

  final List? TicketLibraryManageList;

  @override
  State<TicketLibraryManage> createState() => _TicketLibraryManageState();
}

class _TicketLibraryManageState extends State<TicketLibraryManage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TicketLibraryService>(
        builder: (context, TicketLibraryService, child) {
      return Scaffold(
        appBar: BaseAppBarMethod(context, "수강권 라이브러리", () {
          Navigator.pop(context);
        }, null, null),
        body: CenterConstrainedBody(
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: [
                // 수강권 추가 버튼
                AddTicketWidget(
                    label: '수강권 추가하가',
                    addIcon: true,
                    customFunctionOnTap: () async {
                      var result = await // 저장하기 성공시 Home로 이동
                          Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TicketLibraryMake(() {}, null)),
                      ).then((value) {
                        print("수강권 추가 result");
                        setState(() {});
                      });
                    }),

                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 30),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: widget.TicketLibraryManageList!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      alignment: Alignment.center,
                      child: TicketWidget(
                        customFunctionOnTap: () async {
                          var result = await // 저장하기 성공시 Home로 이동
                              Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TicketLibraryMake(
                                    () {},
                                    widget.TicketLibraryManageList![index]
                                        ['ticketTitle'])),
                          ).then((value) {
                            print("수강권 추가 result");
                            setState(() {});
                          });
                        },
                        ticketCountLeft: globalVariables
                            .ticketLibraryList[index]['ticketCountAll'],
                        ticketCountAll: globalVariables.ticketLibraryList[index]
                            ['ticketCountAll'],
                        ticketTitle: globalVariables.ticketLibraryList[index]
                            ['ticketTitle'],
                        ticketDescription: globalVariables
                            .ticketLibraryList[index]['ticketDescription'],
                        ticketStartDate: globalVariables
                                .ticketLibraryList[index]['ticketStartDate'] ??
                            "0000-00-00",
                        ticketEndDate: globalVariables.ticketLibraryList[index]
                                ['ticketEndDate'] ??
                            "0000-00-00",
                        // ticketDateLeft: globalVariables.ticketLibraryList[index]
                        //     ['ticketDateLeft'],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
