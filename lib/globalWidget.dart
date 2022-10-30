import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:web_project/color.dart';
import 'baseTableCalendar.dart';
import 'home.dart';
import 'main.dart';
import 'memberList.dart';

import 'search.dart';
import 'color.dart';

GlobalKey appBapKey = GlobalKey();
GlobalKey bottomAppBapKey = GlobalKey();

showAlertDialog(BuildContext context, String title, String content) async {
  String result = await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // title: Text('정말로 삭제하시겠습니까?'),
        title: Text(title),
        // content: Text("회원과 관련된 레슨노트 정보도 모두 삭제됩니다."),
        content: Text(content),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Palette.buttonOrange,
            ),
            child: Text('취소'),
            onPressed: () {
              Navigator.pop(context, "Cancel");
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Palette.buttonOrange,
            ),
            child: Text('확인'),
            onPressed: () {
              Navigator.pop(context, "OK");
            },
          ),
        ],
      );
    },
  );
  return result;
}

AppBar BaseAppBarMethod(
    BuildContext context, String pageName, Function? customFunction) {
  return AppBar(
    // key: appBapKey,
    elevation: 1,
    backgroundColor: Palette.mainBackground,
    title: Text(
      pageName,
      style: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Palette.gray66,
          ),
    ),
    centerTitle: true,
    leading: IconButton(
      onPressed: () {
        if (!(customFunction == null)) {
          customFunction();
        } else {
          Navigator.pop(context);
        }
      },
      color: Palette.gray33,
      icon: pageName == "로그인" ? Icon(null) : Icon(Icons.arrow_back_ios),
    ),
  );
}

AppBar MainAppBarMethod(BuildContext context, String pageName) {
  return AppBar(
    elevation: 1,
    backgroundColor: Palette.mainBackground,
    title: Text(
      pageName,
      style: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Palette.gray66,
          ),
    ),
    centerTitle: true,
    // leading: IconButton(
    //   onPressed: () {},
    //   icon: Icon(Icons.calendar_month),
    // ),
    actions: [
      // IconButton(
      //   onPressed: () {
      //     print('profile');
      //     // 로그인 페이지로 이동
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (context) => LoginPage()),
      //     );
      //   },
      //   color: Palette.gray33,
      //   icon: Icon(Icons.account_circle),
      // ),
      // IconButton(
      //   onPressed: () {
      //     _openEndDrawer();
      //   },
      //   icon: Icon(Icons.menu),
      // ),
    ],
  );
}

class BaseBottomAppBar extends StatefulWidget {
  const BaseBottomAppBar({super.key});

  @override
  State<BaseBottomAppBar> createState() => _BaseBottomAppBarState();
}

class _BaseBottomAppBarState extends State<BaseBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      // key: bottomAppBapKey,
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      child: IconTheme(
        data: IconThemeData(color: Palette.gray66),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
          child: Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  print('MEMBERS');
                  // 회원목록 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MemberList()),
                  );
                },
                icon: Icon(Icons.supervisor_account),
                tooltip: 'MEMBERS',
              ),

              // IconButton(
              //   onPressed: () {
              //     print('note_add');
              //     // 홈 화면으로 이동
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => Home()),
              //     );
              //   },
              //   icon: Icon(Icons.home_outlined),
              //   tooltip: 'Add Class',
              // ),

              // IconButton(
              //   onPressed: () {
              //     print('search');
              //     // 서치 화면으로 이동
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => Search()),
              //     );
              //   },
              //   icon: Icon(Icons.search),
              //   tooltip: 'Search',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class BasePopupMenuButton extends StatefulWidget {
  const BasePopupMenuButton({
    Key? key,
    required this.customController,
    required this.hint,
    required this.showButton,
    required this.dropdownList,
    required this.customFunction,
  }) : super(key: key);

  final TextEditingController customController;
  final String hint;
  final bool showButton;
  final List<String> dropdownList;
  final Function customFunction;

  @override
  State<BasePopupMenuButton> createState() => _BasePopupMenuButtonState();
}

class _BasePopupMenuButtonState extends State<BasePopupMenuButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 100,
      ),
      child: TextField(
        readOnly: widget.showButton,
        controller: widget.customController,
        decoration: InputDecoration(
            labelText: widget.hint,
            suffixIcon: widget.showButton
                ? PopupMenuButton<String>(
                    itemBuilder: ((context) =>
                        widget.dropdownList.map((String item) {
                          return PopupMenuItem<String>(
                            child: Text('$item'),
                            value: item,
                          );
                        }).toList()),
                    onSelected: (value) => setState(
                      () {
                        widget.customController.text = value;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("${value} 선택 완료"),
                        ));
                      },
                    ),
                  )
                : null,
            hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            contentPadding: EdgeInsets.all(16),
            fillColor: Colors.white),
      ),
    );
  }
}

//Bottom Sheet

class BaseModalBottomSheetButton extends StatefulWidget {
  const BaseModalBottomSheetButton({
    Key? key,
    required this.bottomModalController,
    required this.hint,
    required this.showButton,
    required this.optionList,
    required this.customFunction,
  }) : super(key: key);

  final TextEditingController bottomModalController;
  final String hint;
  final bool showButton;
  final List<String> optionList;
  final Function customFunction;

  @override
  State<BaseModalBottomSheetButton> createState() =>
      _BaseModalBottomSheetButton();
}

class _BaseModalBottomSheetButton extends State<BaseModalBottomSheetButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 100,
      ),
      child: TextField(
        readOnly: widget.showButton,
        controller: widget.bottomModalController,
        decoration: InputDecoration(
            labelText: widget.hint,
            suffixIcon: widget.showButton
                ? IconButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.white,
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                    width: double.infinity,
                                    alignment: Alignment.topLeft,
                                    child: const Text(
                                      '기구를 선택하세요',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Palette.gray66,
                                          fontWeight: FontWeight.bold),
                                    )),
                                SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: widget.optionList.length,
                                      itemBuilder: ((context, index) {
                                        var value = widget.optionList[index];
                                        // return Text(widget.optionList[index]);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: ListTile(
                                            onTap: () {
                                              setState(
                                                () {
                                                  widget.bottomModalController
                                                      .text = value;
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content:
                                                        Text("${value} 선택 완료"),
                                                  ));
                                                },
                                              );
                                              Navigator.pop(context);
                                            },
                                            tileColor: Palette.grayEE,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                side: BorderSide(
                                                    width: 1,
                                                    color: Palette.grayFA)),
                                            title:
                                                Text(widget.optionList[index]),
                                            trailing: Icon(Icons.arrow_forward),
                                          ),
                                        );
                                      })),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.keyboard_arrow_down_outlined))
                : null,
            hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            contentPadding: EdgeInsets.all(16),
            fillColor: Colors.white),
      ),
    );
  }
}

// Text Field
class BaseTextField extends StatefulWidget {
  const BaseTextField({
    Key? key,
    required this.customController,
    required this.hint,
    required this.showArrow,
    required this.customFunction,
  }) : super(key: key);

  final TextEditingController customController;
  final String hint;
  final showArrow;
  final Function customFunction;

  @override
  State<BaseTextField> createState() => _BaseTextFieldState();
}

class _BaseTextFieldState extends State<BaseTextField> {
  @override
  Widget build(BuildContext context) {
    FocusNode textFocus = FocusNode();

    return Container(
      constraints: BoxConstraints(
        minHeight: 70,
      ),
      child: TextField(
        focusNode: textFocus,
        textInputAction: TextInputAction.done,
        readOnly: widget.showArrow,
        controller: widget.customController,
        decoration: InputDecoration(
            labelText: widget.hint,
            suffixIcon: widget.hint == "수행도"
                ? null
                : widget.hint == ""
                    ? null
                    : widget.showArrow
                        ? IconButton(
                            onPressed: () {
                              widget.customFunction();
                            },
                            icon: Icon(Icons.navigate_next),
                          )
                        : null,
            hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            contentPadding: EdgeInsets.all(16),
            fillColor: Colors.white),
        onChanged: (text) {
          // 현재 텍스트필드의 텍스트를 출력
          print("First text field: $text");
        },
        onEditingComplete: () {
          textFocus.unfocus();
        },
      ),
    );
  }
}

// Text Field

class DynamicSaveTextField extends StatefulWidget {
  const DynamicSaveTextField({
    Key? key,
    required this.customController,
    required this.hint,
    required this.showArrow,
    required this.customFunction,
  }) : super(key: key);

  final TextEditingController customController;
  final String hint;
  final showArrow;
  final Function customFunction;

  @override
  State<DynamicSaveTextField> createState() => _DynamicSaveTextFieldState();
}

class _DynamicSaveTextFieldState extends State<DynamicSaveTextField> {
  @override
  Widget build(BuildContext context) {
    FocusNode textFocus = FocusNode();
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 70,
      ),
      child: TextField(
        textInputAction: TextInputAction.done,
        readOnly: widget.showArrow,
        controller: widget.customController,
        decoration: InputDecoration(
            labelText: widget.hint,
            hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            contentPadding: EdgeInsets.all(16),
            fillColor: Palette.grayFA),
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
        },
        // onEditingComplete: () {
        //   // 현재 텍스트필드의 텍스트를 출력
        //   widget.customFunction();
        // },
      ),
    );
  }
}

class BaseSearchTextField extends StatefulWidget {
  const BaseSearchTextField({
    Key? key,
    required this.customController,
    required this.hint,
    required this.showArrow,
    required this.customFunction,
  }) : super(key: key);

  final TextEditingController customController;
  final String hint;
  final showArrow;
  final Function customFunction;

  @override
  State<BaseSearchTextField> createState() => _BaseSearchTextFieldState();
}

class _BaseSearchTextFieldState extends State<BaseSearchTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 40,
      ),
      child: TextField(
        // minLines: 3,
        // maxLines: 10,
        // keyboardType: TextInputType.multiline,
        //textInputAction: TextInputAction.done,
        // readOnly: widget.showArrow,
        onChanged: (text) {
          print("Input Text : ${text}");
          widget.customFunction();
        },
        controller: widget.customController,
        decoration: InputDecoration(
          labelText: widget.hint,
          suffixIcon: widget.hint == ""
              ? null
              : widget.showArrow
                  ? IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.search),
                    )
                  : null,
          hintText: widget.hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          filled: true,
          contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class BaseMultiTextField extends StatefulWidget {
  const BaseMultiTextField({
    Key? key,
    required this.customController,
    required this.hint,
    required this.showArrow,
    required this.customFunction,
  }) : super(key: key);

  final TextEditingController customController;
  final String hint;
  final showArrow;
  final Function customFunction;

  @override
  State<BaseMultiTextField> createState() => _BaseMultiTextFieldState();
}

class _BaseMultiTextFieldState extends State<BaseMultiTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 70,
      ),
      child: TextField(
        minLines: 3,
        maxLines: 10,
        keyboardType: TextInputType.multiline,
        //textInputAction: TextInputAction.done,
        readOnly: widget.showArrow,
        controller: widget.customController,
        decoration: InputDecoration(
            labelText: widget.hint,
            suffixIcon: widget.hint == ""
                ? null
                : widget.showArrow
                    ? IconButton(
                        onPressed: () {
                          widget.customFunction();
                        },
                        icon: Icon(Icons.navigate_next),
                      )
                    : null,
            hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            contentPadding: EdgeInsets.all(16),
            fillColor: Colors.white),
      ),
    );
  }
}

class LoginTextField extends StatefulWidget {
  const LoginTextField({
    Key? key,
    required this.customController,
    required this.hint,
    required this.width,
    required this.height,
    required this.customFunction,
    required this.isSecure,
  }) : super(key: key);

  final TextEditingController customController;
  final String hint;
  final double width;
  final double height;
  final bool isSecure;
  final Function customFunction;

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  @override
  Widget build(BuildContext context) {
    FocusNode myFocusNode = new FocusNode();
    Color focusColor = Palette.buttonOrange;
    Color normalColor = Palette.gray66;

    return TextField(
      controller: widget.customController,
      onSubmitted: widget.customFunction(),
      obscureText: widget.isSecure, // 비밀번호여부
      style: TextStyle(color: normalColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: Palette.grayFA,
        labelText: widget.hint,
        labelStyle:
            TextStyle(color: myFocusNode.hasFocus ? focusColor : normalColor),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Palette.grayEE, width: 0),
            borderRadius: BorderRadius.circular(10)),
        focusColor: focusColor,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: focusColor,
          ),
        ),
      ),
    );
  }
}

class BaseContainer extends StatelessWidget {
  const BaseContainer({
    Key? key,
    required this.name,
    required this.registerDate,
    required this.goal,
    required this.info,
    required this.note,
    required this.isActive,
    required this.phoneNumber,
  }) : super(key: key);

  final String name;
  final String registerDate;
  final String goal;
  final String info;
  final String note;
  final String phoneNumber;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    String nameFirst = ' ';
    if (name.length > 0) {
      nameFirst = name.substring(0, 1);
    }
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        //color: Palette.backgroundPink,
        border: Border(
          bottom: BorderSide(width: 1, color: Palette.grayEE),
        ),
      ),
      height: 81,
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Palette.grayEE,
                    // backgroundImage: NetworkImage(
                    //     'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=592&q=80'),
                    child: Text(
                      nameFirst,
                      //name == null ? "N" : name.substring(0, 1),
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Palette.gray33),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${name}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Palette.gray33,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    '등록일 : ${registerDate}',
                    style: TextStyle(
                      fontSize: 12.0,
                      //fontWeight: FontWeight.bold,
                      color: Palette.gray99,
                    ),
                  ),
                ],
              ),
              Spacer(flex: 1),
              Icon(
                Icons.arrow_forward_ios,
                color: Palette.gray99,
                size: 22.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionContainer extends StatelessWidget {
  const ActionContainer({
    Key? key,
    required this.apratusName,
    required this.actionName,
    required this.lessonDate,
    required this.grade,
    required this.totalNote,
  }) : super(key: key);

  final String apratusName;
  final String actionName;
  final String lessonDate;
  final String grade;
  final String totalNote;

  @override
  Widget build(BuildContext context) {
    String lessonDateTrim = " ";
    String apratusNameTrim = " ";
    // 날짜 글자 자르기
    if (lessonDate.length > 0) {
      lessonDateTrim = lessonDate.substring(2, 10);
    }
    // 기구 첫두글자 자르기
    if (apratusName.length > 0) {
      apratusNameTrim = apratusName.substring(0, 2);
    }
    return Padding(
      padding: const EdgeInsets.only(
        left: 30.0,
        right: 30.0,
        top: 5.0,
      ),
      child: SizedBox(
        //height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              lessonDateTrim,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 12.0,
                  ),
            ),
            const SizedBox(width: 15.0),
            Text(
              apratusNameTrim,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 12.0,
                  ),
            ),
            const SizedBox(width: 15.0),
            Expanded(
              child: Text(
                totalNote,
                overflow: TextOverflow.fade,
                maxLines: 2,
                softWrap: true,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 12.0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionContainerDate extends StatelessWidget {
  const ActionContainerDate({
    Key? key,
    required this.apratusName,
    required this.actionName,
    required this.lessonDate,
    required this.grade,
    required this.totalNote,
    required this.pos,
  }) : super(key: key);

  final String apratusName;
  final String actionName;
  final String lessonDate;
  final String grade;
  final String totalNote;
  final int pos;

  @override
  Widget build(BuildContext context) {
    String lessonDateTrim = " ";
    String apratusNameTrim = " ";
    // 날짜 글자 자르기
    if (lessonDate.length > 0) {
      lessonDateTrim = lessonDate.substring(2, 10);
    }
    // 기구 첫두글자 자르기
    if (apratusName.length > 0) {
      apratusNameTrim = apratusName.substring(0, 2);
    }
    return Padding(
      padding: const EdgeInsets.only(
        left: 30.0,
        right: 30.0,
        top: 5.0,
      ),
      child: SizedBox(
        //height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Text(
            //   pos.toString(),
            //   style: Theme.of(context).textTheme.bodyText1!.copyWith(
            //         fontSize: 12.0,
            //       ),
            // ),
            // const SizedBox(width: 15.0),
            Text(
              apratusNameTrim,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 12.0,
                  ),
            ),
            const SizedBox(width: 15.0),
            Text(
              actionName,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 12.0,
                  ),
            ),
            const SizedBox(width: 15.0),
            Expanded(
              child: Text(
                totalNote,
                overflow: TextOverflow.fade,
                maxLines: 2,
                softWrap: true,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 12.0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupActionContainer extends StatelessWidget {
  const GroupActionContainer({
    Key? key,
    required this.actionName,
  }) : super(key: key);

  final String actionName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 16,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            color: Palette.grayEE,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 30.0,
              right: 16.0,
            ),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    actionName,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Spacer(flex: 1),
                  // Icon(
                  //   Icons.arrow_forward_ios,
                  //   color: Palette.gray99,
                  //   size: 12.0,
                  // ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GroupActionContainerDate extends StatelessWidget {
  const GroupActionContainerDate({
    Key? key,
    required this.lessonDate,
  }) : super(key: key);

  final String lessonDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 16,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            color: Palette.grayEE,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 30.0,
              right: 16.0,
            ),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    lessonDate,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Spacer(flex: 1),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Palette.gray99,
                    size: 12.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
