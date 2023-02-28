import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/app/data/provider/member_service.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/function/globalFunction.dart';
import '../../data/provider/auth_service.dart';
import 'baseTableCalendar.dart';
import '../../../main.dart';
import '../page/memberList.dart';

import '../../data/model/color.dart';

GlobalFunction globalFunction = GlobalFunction();

GlobalKey appBapKey = GlobalKey();
GlobalKey bottomAppBapKey = GlobalKey();

showAlertDialog(BuildContext context, String title, String content) async {
  String result = await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // title: Text('정말로 삭제하시겠습니까?'),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        // content: Text("회원과 관련된 레슨노트 정보도 모두 삭제됩니다."),
        content: Text(
          content,
          style: TextStyle(fontSize: 14),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              '취소',
              style: TextStyle(color: Palette.textRed),
            ),
            onPressed: () {
              Navigator.pop(context, "Cancel");
            },
          ),
          TextButton(
            child: Text(
              '확인',
              style: TextStyle(color: Palette.textBlue),
            ),
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
    BuildContext context,
    String pageName,
    Function? customFunction,
    List<Widget>? customWidget,
    PreferredSizeWidget? customBottom) {
  return AppBar(
      bottom: customBottom,
      iconTheme: IconThemeData(color: Palette.gray66),
      // key: appBapKey,
      elevation: 0,
      backgroundColor: Palette.mainBackground,
      title: Text(
        pageName,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Palette.gray00,
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
      actions: customWidget);
}

AppBar MainAppBarMethod(BuildContext context, String pageName) {
  State<MemberList>? memberList = context.findAncestorStateOfType();
  IconData reportIcon = Icons.report_problem_outlined;
  return AppBar(
    leading: IconButton(
      onPressed: () {
        print('signOut');
        AuthService authService = AuthService();
        authService.signOut();
        // 로그인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage(
                    analytics: MyApp.analytics,
                  )),
        );
      },
      color: Palette.gray33,
      // icon: Icon(Icons.account_circle),
      icon: Icon(Icons.logout),
    ),
    elevation: 0,
    backgroundColor: Palette.mainBackground,
    title: Text(
      pageName,
      style: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Palette.gray00,
          ),
    ),
    centerTitle: true,
    // leading: IconButton(
    //   onPressed: () {},
    //   icon: Icon(Icons.calendar_month),
    // ),
    actions: [
      // IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_outlined))

      // IconButton(
      //   onPressed: () {
      //     _openEndDrawer();
      //   },
      //   icon: Icon(Icons.menu),
      // ),

      IconButton(
        onPressed: () {
          print("IconButton onPressed!!");
        },
        icon: Icon(
          reportIcon,
          color: Palette.gray66,
        ),
      ),
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
  BaseTextField({
    Key? key,
    required this.customController,
    required this.customFocusNode,
    required this.hint,
    required this.showArrow,
    required this.customFunction,
  }) : super(key: key);

  final TextEditingController customController;
  final FocusNode customFocusNode;
  final String hint;
  final showArrow;
  final Function customFunction;

  @override
  State<BaseTextField> createState() => _BaseTextFieldState();
}

class _BaseTextFieldState extends State<BaseTextField> {
  @override
  Widget build(BuildContext context) {
    //FocusNode textFocus = FocusNode();

    return Container(
      alignment: Alignment.center,
      child: TextField(
        obscureText: widget.hint.contains("비밀번호") ? true : false, // 비밀번호 안보이게
        style: TextStyle(fontSize: 16),
        //focusNode: textFocus,
        textInputAction: TextInputAction.done,
        readOnly: widget.showArrow,
        controller: widget.customController,
        focusNode: widget.customFocusNode,
        decoration: InputDecoration(
          // contentPadding: EdgeInsets.all(5),
          // labelText: widget.hint,
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
          hintStyle: TextStyle(
            fontSize: 14,
            color: Palette.gray95,
          ),
          border: InputBorder.none,
        ),
        onChanged: (text) {
          // 현재 텍스트필드의 텍스트를 출력
          // print("First text field: $text");
        },
        onEditingComplete: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
      ),
    );
  }
}

// Text Field
class PopupTextField extends StatefulWidget {
  const PopupTextField({
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
  State<PopupTextField> createState() => _PopupTextFieldState();
}

class _PopupTextFieldState extends State<PopupTextField> {
  @override
  Widget build(BuildContext context) {
    //FocusNode textFocus = FocusNode();

    return Container(
      //color: Colors.red,
      // constraints: BoxConstraints(
      //   minHeight: 40,
      // ),
      child: TextField(
        keyboardType: TextInputType.multiline,
        minLines: 3,
        maxLines: 10,
        //autofocus: true,
        //focusNode: textFocus,
        //textInputAction: TextInputAction.done,
        //readOnly: widget.showArrow,
        controller: widget.customController,
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                width: 1,
                color: Palette.buttonOrange,
                style: BorderStyle.solid,
              ),
            ),
            //labelText: widget.hint,
            //hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                width: 1,
                color: Palette.grayEE,
                style: BorderStyle.solid,
              ),
            ),
            filled: true,
            contentPadding: EdgeInsets.all(16),
            fillColor: Colors.white),
        // onEditingComplete: () {
        //   FocusScopeNode currentFocus = FocusScope.of(context);

        //   if (!currentFocus.hasPrimaryFocus) {
        //     currentFocus.unfocus();
        //   }
        //   //Navigator.pop(context);
        //},
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
    required this.customFocusNode,
    required this.hint,
    this.label,
    required this.showArrow,
    required this.customFunction,
    required this.clearfunction,
  }) : super(key: key);

  final TextEditingController customController;
  final FocusNode customFocusNode;
  final String hint;
  final String? label;
  final showArrow;
  final Function customFunction;
  final Function clearfunction;

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
        style: TextStyle(fontSize: 14),
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
          labelText: widget.label,
          suffixIcon: widget.hint == ""
              ? null
              : widget.showArrow
                  ? IconButton(
                      onPressed: () {
                        widget.clearfunction();
                      },
                      icon: Icon(Icons.clear),
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
        labelText: widget.hint,
        labelStyle:
            TextStyle(color: myFocusNode.hasFocus ? focusColor : normalColor),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Palette.gray33, width: 0),
        ),
        focusColor: focusColor,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: focusColor,
          ),
        ),
      ),
    );
  }
}

class BaseContainer extends StatefulWidget {
  const BaseContainer(
      {Key? key,
      required this.docId,
      required this.name,
      required this.registerDate,
      required this.goal,
      required this.info,
      required this.note,
      required this.isActive,
      required this.isFavorite,
      required this.phoneNumber,
      required this.memberService,
      required this.resultMemberList,
      required this.memberDayLessonCount,
      required this.customFunctionOnTap,
      required this.noteAddFunctionOnTap})
      : super(key: key);
  final String docId;
  final String name;
  final String registerDate;
  final String goal;
  final String info;
  final String note;
  final String phoneNumber;
  final bool isActive;
  final bool isFavorite;
  final MemberService memberService;
  final List resultMemberList;
  final int memberDayLessonCount;

  final Function customFunctionOnTap;
  final Function noteAddFunctionOnTap;

  @override
  State<BaseContainer> createState() => _BaseContainerState();
}

class _BaseContainerState extends State<BaseContainer> {
  bool favoriteMember = false;
  String isFavIconPath = "";
  bool _toggle = false;
  bool _toggleNote = false;

  @override
  Widget build(BuildContext context) {
    String nameFirst = ' ';
    if (widget.name.length > 0) {
      nameFirst = widget.name.substring(0, 1);
    }

    return Row(
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 378),
          width: MediaQuery.of(context).size.width - 102,
          alignment: Alignment.center,
          child: Card(
            elevation: 0,
            margin: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              onTapDown: (details) {
                setState(() {
                  _toggle = true;
                });
              },
              onTapUp: (details) {
                setState(() {
                  _toggle = false;
                });
              },
              onTap: () {
                widget.customFunctionOnTap();
              },
              child: Container(
                height: 88,
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            /// 별모양
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: 1, color: Palette.grayF5))),
                              height: 88 - 20,
                              width: 60,
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  widget.isFavorite //svg파일이 firebase에서 안보이는 경우
                                      //https://stackoverflow.com/questions/72604523/flutter-web-svg-image-will-not-be-displayed-after-firebase-hosting
                                      ? "assets/icons/favoriteSelected.svg"
                                      : "assets/icons/favoriteUnselected.svg",
                                ),
                                iconSize: 40,
                                onPressed: () async {
                                  // favoriteMember = !widget.isFavorite;

                                  //                   for (int idx = 0; idx < totalNoteTextFieldDocId.length; idx++) {
                                  //   await lessonService.updateTotalNote(
                                  //     totalNoteTextFieldDocId[idx],
                                  //     totalNoteControllers[idx].text,
                                  //   );
                                  // }

                                  int rstLnth = widget.resultMemberList.length;
                                  for (int i = 0; i < rstLnth; i++) {
                                    if (widget.docId ==
                                        widget.resultMemberList[i]['id']) {
                                      print(
                                          "globalWidget onPressed!! widget.resultMemberList[i]['id'] : ${widget.resultMemberList[i]['id']}");
                                      if (widget.resultMemberList[i]
                                              ['isFavorite'] ==
                                          null) {
                                        widget.resultMemberList[i]
                                            ['isFavorite'] = true;
                                        print(
                                            "widget.resultMemberList[i]['isFavorite'] is null!!");
                                      } else {
                                        widget.resultMemberList[i]
                                                ['isFavorite'] =
                                            !widget.resultMemberList[i]
                                                ['isFavorite'];
                                        print(
                                            "widget.resultMemberList[i]['isFavorite'] is not null!!");
                                      }

                                      break;
                                    }
                                  }

                                  print("favoriteMember : ${favoriteMember}");

                                  await widget.memberService.updateIsFavorite(
                                      widget.docId, !widget.isFavorite);
                                  // setState(() {
                                  //   widget.isActive
                                  //       ? favoriteMember = false
                                  //       : favoriteMember = true;
                                  // });

                                  // setState(() {});

                                  globalVariables.sortList();
                                  setState(() {});
                                },
                              ),
                              // child: Image.asset(
                              //     true
                              //         ? "assets/icons/favorite_selected.svg"
                              //         : "assets/icons/favorite_unselected.svg",
                              //     width: 130),
                            )
                            // CircleAvatar(
                            //   backgroundColor: Palette.grayEE,
                            //   // backgroundImage: NetworkImage(
                            //   //     'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=592&q=80'),
                            //   child: Text(
                            //     nameFirst,
                            //     //name == null ? "N" : name.substring(0, 1),
                            //     style: TextStyle(
                            //         fontSize: 20.0,
                            //         fontWeight: FontWeight.bold,
                            //         color: Palette.gray33),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(width: 15),
                        Container(
                          constraints: BoxConstraints(maxWidth: 130),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.name}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Palette.gray00,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                '등록일 : ${widget.registerDate}',
                                style: TextStyle(
                                  fontSize: 12,
                                  //fontWeight: FontWeight.bold,
                                  color: Palette.grayB4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /* Icon(
                          Icons.arrow_forward_ios,
                          color: Palette.gray95,
                          size: 22.0,
                        ), */
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate(target: _toggle ? 1 : 0)
              .scaleXY(end: 0.95, duration: 100.ms),
        ),
        SizedBox(width: 8),
        Container(
          child: Card(
            color: true ? Palette.buttonOrange : Palette.gray99,
            elevation: 0,
            margin: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // 노트 개수 UI
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              onTapDown: (details) {
                setState(() {
                  _toggleNote = true;
                });
              },
              onTapUp: (details) {
                setState(() {
                  _toggleNote = false;
                });
              },
              onTap: () {
                print('노트추가 버튼 클릭');
                widget.noteAddFunctionOnTap();
              },
              child: Container(
                width: 64,
                height: 88,
                padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                child: SizedBox(
                  height: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.post_add_outlined,
                        color: Palette.grayFF,
                      ),
                      SizedBox(width: 3),
                      Text(
                        "${widget.memberDayLessonCount}",
                        style: TextStyle(
                            color: Palette.grayFF,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate(target: _toggleNote ? 1 : 0)
              .scaleXY(end: 0.95, duration: 100.ms),
        )
      ],
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
    return Container(
      padding: const EdgeInsets.only(
        left: 14.0,
        right: 14.0,
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
    return Container(
        padding: EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
        child: Chip(label: Text(actionName)));

    Column(
      children: [
        SizedBox(
          height: 16,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            color: Palette.grayEE,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 14.0,
              right: 14.0,
            ),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    actionName,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 14.0,
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
