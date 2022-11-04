import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:web_project/member_service.dart';

import 'action_service.dart';
import 'globalFunction.dart';
import 'globalWidget.dart';

GlobalFunction globalfunction = GlobalFunction();

class GlobalWidgetDashboard extends StatefulWidget {
  const GlobalWidgetDashboard({super.key});

  @override
  State<GlobalWidgetDashboard> createState() => _GlobalWidgetDashboardState();
}

TextEditingController controller1 = TextEditingController();
TextEditingController controller2 = TextEditingController();
TextEditingController controller3 = TextEditingController();

class _GlobalWidgetDashboardState extends State<GlobalWidgetDashboard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ActionService>(builder: (context, actionService, child) {
      return Scaffold(
        appBar: BaseAppBarMethod(context, "글로벌 위젯 대쉬보드", null),
        body: Column(
          children: [
            // BaseContainer(
            //   docId : "///",
            //   name: "홍길동",
            //   registerDate: "20200202",
            //   goal: "체형관리",
            //   info: "인포입니다",
            //   note: "노트입니다",
            //   isActive: true,
            //   phoneNumber: "010-0000-1111",
            //   memberService : memberService,
            // ),
            BaseTextField(
              customController: controller1,
              hint: "힌트 입력",
              showArrow: true, // 화살표 보여주기
              customFunction: () {
                // 동작 DB 밀어넣기
                globalfunction.createDummy(actionService);
                Timestamp timestamp = Timestamp.now();

                print(
                    "timestamp : ${timestamp}, in one line : ${timestamp.seconds}${timestamp.nanoseconds}");
              },
            ),

            /// 기구 입력창
            BasePopupMenuButton(
              customController: controller2,
              hint: "기구",
              showButton: true,
              dropdownList: ['옵션1', '옵션2', '옵션3'],
              customFunction: () {},
            ),

            /// 기구 입력창2
            BaseModalBottomSheetButton(
              bottomModalController: controller3,
              hint: "기구2",
              showButton: true,
              optionList: [
                'REFORMER',
                'CADILLAC',
                'CHAIR',
                'LADDER BARREL',
                'SPRING BOARD',
                'SPINE CORRECTOR',
                'MAT'
              ],
              customFunction: () {},
            ),
          ],
        ),
        bottomNavigationBar: BaseBottomAppBar(),
      );
    });
  }
}
