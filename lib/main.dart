import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FB;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_project/app/controller/memberInfo_controller.dart';
import 'package:web_project/app/data/provider/analyticLog.dart';
import 'package:web_project/app/data/provider/action_service.dart';
import 'package:web_project/app/data/provider/daylesson_service.dart';
import 'package:web_project/app/data/provider/lesson_service.dart';
import 'package:web_project/app/data/provider/memberTicket_service.dart';
import 'package:web_project/app/data/provider/member_service.dart';
import 'package:web_project/app/data/provider/report_service.dart';
import 'package:web_project/app/data/provider/sequenceCustom_service.dart';
import 'package:web_project/app/data/provider/sequenceRecent_service.dart';
import 'package:web_project/app/data/provider/ticketLibrary_service.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/data/model/globalVariables.dart';
import 'package:web_project/app/ui/widget/globalWidgetDashboard.dart';
import 'package:web_project/app/data/model/local_info.dart';
import 'package:web_project/app/controller/login_controller.dart';
import 'package:web_project/app/ui/page/sign_up.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io' show HttpHeaders, Platform;
import 'package:http/http.dart' as http;

import 'app/data/provider/auth_service.dart';
import 'app/data/provider/calendar_service.dart';
import 'app/data/model/color.dart';
import 'app/config/firebase_options.dart';
import 'app/function/globalFunction.dart';
import 'app/ui/page/lessonDetail.dart';
import 'app/ui/page/memberList.dart';
import 'app/ui/widget/globalWidget.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_web/webview_flutter_web.dart';

MemberInfoController memberInfoController = MemberInfoController();

GlobalVariables globalVariables = GlobalVariables();

// ?????? ????????? Controller
LoginController loginController = LoginController();

// GA ??? ?????? ?????? ??????
String screenName = "?????? ?????????";

bool adminMode = false;

GlobalFunction globalfunction = GlobalFunction();

late SharedPreferences prefs;

bool isLogInActiveChecked = false;

late TextEditingController emailController;
late TextEditingController passwordController;

TextEditingController switchController =
    TextEditingController(text: "??????????????? ????????????");

String? userEmail;
String? userPassword;

ActionService actionService = ActionService();

TicketLibraryService ticketLibraryService = TicketLibraryService();

MemberTicketService memberTicketService = MemberTicketService();

DayLessonService daylessonService = DayLessonService();

enum LoginPlatform {
  kakao,
  none, // logout
}

LoginPlatform loginPlatform = LoginPlatform.none;

bool isKakaoInstalled = false;

bool isEmailLoginDeactivated = true;

AnalyticLog analyticLog = AnalyticLog();

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Palette.grayFF,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized(); // main ???????????? async ???????????? ??????

  String result = await KakaoSdk.origin;
  print("origin result : ${result}");
  // ????????? ?????? ????????? init, void main ?????? ??? ??? ?????? ???????????? ?????? ??????, ????????? async ?????? ??? ???
  // ????????? ?????? ????????? https://dalgoodori.tistory.com/46 ??????
  // KakaoSdk.init(nativeAppKey: 'kakaob59deaa3a0ff4912ca55fc3d71ccd6aa');
  KakaoSdk.init(
      nativeAppKey: 'b59deaa3a0ff4912ca55fc3d71ccd6aa',
      javaScriptAppKey: 'fec10c47ab2237004c266efcb7e31726');
  prefs = await SharedPreferences.getInstance();

  isLogInActiveChecked = prefs.getBool("isLogInActiveChecked") ?? false;
  userEmail = prefs.getString("userEmail");
  userPassword = prefs.getString("userPassword");
  print("prefs check isLogInActiveChecked : ${isLogInActiveChecked}");
  print("prefs check userEmail : ${userEmail}");
  print("prefs check userPassword : ${userPassword}");

  if (kIsWeb) {
    print("Platform.kIsWeb");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    analyticLog.sendAnalyticsEvent(
        screenName, "???????????????", "????????? ?????? ?????????", "????????? ?????? ????????????");
    // WebView.platform = WebWebViewPlatform();
  } else {
    if (Platform.isAndroid) {
      print("Platform.isAndroid");
      await Firebase.initializeApp();
      analyticLog.sendAnalyticsEvent(
          screenName, "???????????????", "Android ?????? ?????????", "Android ?????? ????????????");
    } else if (Platform.isIOS) {
      print("Platform.isIOS");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      analyticLog.sendAnalyticsEvent(
          screenName, "???????????????", "IOS ?????? ?????????", "IOS ?????? ????????????");
    } else if (Platform.isMacOS) {
      print("Platform.isMacOS");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      analyticLog.sendAnalyticsEvent(
          screenName, "???????????????", "MACOS ?????? ?????????", "MACOS ?????? ????????????");
    } else if (Platform.isWindows) {
      print("Platform.isWindows");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      analyticLog.sendAnalyticsEvent(
          screenName, "???????????????", "WINDOWS ?????? ?????????", "WINDOWS ?????? ????????????");
    }
  }

  /* await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); */ // firebase ??? ??????

  AuthService authService = AuthService();
  FB.User? user = authService.currentUser();
  print("user?.email : ${user?.email}");
  print("user?.photoURL : ${user?.photoURL}");
  print("user?.displayName : ${user?.displayName}");

  if (user != null) {
    print("object user is not null");
    print("user.email : ${user.email}, user.displayName : ${user.displayName}");

    await memberService.readMemberListAtFirstTime(user.uid).then((value) {
      globalVariables.resultList.addAll(value);
      /* for (int i = 0; i < resultList.length; i++) {
        print("resultList[${i}] : ${resultList[i]}");
      } */
      print('globalVariables.resultList:${globalVariables.resultList}');
    }).onError((error, stackTrace) {
      print("111error : ${error}");
      print("stackTrace : \r\n${stackTrace}");
    }).whenComplete(() async {
      print("0 - main memberList complete!!");

      await actionService.readActionListAtFirstTime(user.uid).then((value) {
        print(
            "1. resultFirstActionList then is called!! value.length : ${value.length}");
        globalVariables.actionList.addAll(value);
      }).onError((error, stackTrace) {
        print("error : ${error}");
        print("stackTrace : \r\n${stackTrace}");
      }).whenComplete(() async {
        print("actionList await init complete!");

        await ticketLibraryService.read(user.uid).then((value) {
          globalVariables.ticketLibraryList.addAll(value);
        }).onError((error, stackTrace) {
          print("error : ${error}");
          print("stackTrace : \r\n${stackTrace}");
        }).whenComplete(() async {
          print("ticketLibraryList await init complete!");
          /* for(var i in globalVariables.ticketLibraryList){
            print("i : ${i}");
          } */
          await memberTicketService.read(user.uid).then((value) {
            globalVariables.memberTicketList.addAll(value);
          }).onError((error, stackTrace) {
            print("error : ${error}");
            print("stackTrace : \r\n${stackTrace}");
          }).whenComplete(() {
            print("memberTicketList await init complete!");
            
          });
        });
      });
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AuthService()),
            ChangeNotifierProvider(create: (context) => MemberService()),
            ChangeNotifierProvider(create: (context) => DayLessonService()),
            ChangeNotifierProvider(create: (context) => LessonService()),
            ChangeNotifierProvider(create: (context) => CalendarService()),
            ChangeNotifierProvider(create: (context) => ActionService()),
            ChangeNotifierProvider(create: (context) => ReportService()),
            ChangeNotifierProvider(create: (context) => TicketLibraryService()),
            ChangeNotifierProvider(create: (context) => MemberTicketService()),
            ChangeNotifierProvider(create: (context) => SequenceRecentService()),
            ChangeNotifierProvider(create: (context) => SequenceCustomService()),
          ],
          child: const MyApp(),
        ),
      );
    });
  } else {
    print("object user is null");
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthService()),
          ChangeNotifierProvider(create: (context) => MemberService()),
          ChangeNotifierProvider(create: (context) => DayLessonService()),
          ChangeNotifierProvider(create: (context) => LessonService()),
          ChangeNotifierProvider(create: (context) => CalendarService()),
          ChangeNotifierProvider(create: (context) => ActionService()),
          ChangeNotifierProvider(create: (context) => ReportService()),
          ChangeNotifierProvider(create: (context) => TicketLibraryService()),
          ChangeNotifierProvider(create: (context) => MemberTicketService()),
          ChangeNotifierProvider(create: (context) => SequenceRecentService()),
          ChangeNotifierProvider(create: (context) => SequenceCustomService()),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final maxWidth = 480.0;

  const MyApp({Key? key}) : super(key: key);
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    // print("resultList : ${resultList}\r\nactionList : ${actionList}");
    final user = context.read<AuthService>().currentUser();
    emailController = TextEditingController(text: userEmail);
    passwordController = TextEditingController(text: userPassword);

    /* resultList.every((element) {
      print("elements : ${element.toString()}");
      return true;
    },);
    print("resultList.toString() : ${resultList.toString()}"); */
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus(); // ????????? ?????? ?????????
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // Google Analytics ??????
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        theme: ThemeData(
            // appBarTheme: AppBarTheme(
            //     systemOverlayStyle:
            //         SystemUiOverlayStyle(statusBarColor: Palette.grayFF)),
            fontFamily: 'Pretendard',
            backgroundColor: Palette.mainBackground),
        home:
            // LoginPage()
            user == null
                ? LoginPage(analytics: analytics)
                /* : SignUp(), */ : MemberList.getMemberList(
                    globalVariables.resultList, globalVariables.actionList),
      ),
    );
  }
}

/// ????????? ?????????
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    // TODO: implement initState
    print("init ?????????!");
    // GA ????????? ?????? ?????????

    analyticLog.sendAnalyticsEvent(
        screenName, "?????????_?????????_init", "init ????????? ?????????", "init ????????? ????????????");

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    globalVariables.resultList = [];
    globalVariables.actionList = [];
  }

  @override
  Widget build(BuildContext context) {
    // globalVariables.sortList();
    userEmail = prefs.getString("userEmail");
    userPassword = prefs.getString("userPassword");
    print("prefs check isLogInActiveChecked : ${isLogInActiveChecked}");
    print("prefs check userEmail : ${userEmail}");
    print("prefs check userPassword : ${userPassword}");

    emailController = TextEditingController(text: userEmail);
    passwordController = TextEditingController(text: userPassword);

    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser();
        return Scaffold(
          backgroundColor: Palette.grayFF,
          // ???????????? ?????? ????????? ?????? appBar ??????
          // appBar: BaseAppBarMethod(context, "?????????", null),
          body: CenterConstrainedBody(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// ?????? ?????? ????????? ??????
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 120),
                        SizedBox(
                          height: 100,
                          child:
                              Image.asset("assets/images/logo.png", width: 230),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          child: Column(
                            children: [
                              Text(
                                "???????????? ????????? ?????? ?????? ?????? ?????????",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Palette.textOrange,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 80),
                  Offstage(
                    offstage: isEmailLoginDeactivated,
                    child: Column(children: [
                      /// ?????????
                      LoginTextField(
                        customController: emailController,
                        hint: "?????????",
                        width: 100,
                        height: 100,
                        customFunction: () {},
                        isSecure: false,
                      ),
                      SizedBox(height: 10),

                      /// ????????????
                      LoginTextField(
                        customController: passwordController,
                        hint: "????????????",
                        width: 100,
                        height: 100,
                        customFunction: () {},
                        isSecure: true,
                      ),
                      SizedBox(height: 10),

                      Center(
                        child: SizedBox(
                          height: 40,
                          width: 200,
                          child: TextField(
                            readOnly: true,
                            controller: switchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: Switch(
                                value: isLogInActiveChecked,
                                onChanged: (value) {
                                  setState(() {
                                    isLogInActiveChecked =
                                        !isLogInActiveChecked;
                                    // if (isLogInActiveChecked) {
                                    prefs.setString(
                                        "userEmail", emailController.text);
                                    prefs.setString("userPassword",
                                        passwordController.text);
                                    // }
                                    print(
                                        "isLogInActiveChecked : ${isLogInActiveChecked}");
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 26),

                      /// ????????? ?????? ?????? ??????
                      Text(
                        "*????????? ??????????????? ????????? ???????????? ????????????.",
                        style: TextStyle(color: Palette.gray99),
                      ),
                      SizedBox(height: 20),

                      /// ????????? ????????? ??????
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(0),
                          elevation: 0,
                          backgroundColor: Palette.buttonOrange,
                        ),
                        onPressed: () {
                          loginMethod(context, authService);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mail),
                              SizedBox(width: 4),
                              Text("???????????? ???????????????",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ]),
                  ),

                  // ?????????????????? ????????? ??????
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(0),
                      elevation: 0,
                      backgroundColor: Palette.buttonKakao,
                    ),
                    onPressed: () async {
                      analyticLog.sendAnalyticsEvent(screenName, "????????????_???????????????",
                          "????????? ????????? ????????? ?????????", "????????? ????????? ????????? ????????????");
                      try {
                        if (kIsWeb) {
                          // web ?????? ????????? ??????
                          print("JAVASCRIPT - ?????????????????? ????????? ??????");
                          loginController.kakaoSignIn().then((value) {
                            print("value : ${value}");
                            loginWithCurrentUser(value, context);
                          });
                        } else {
                          // Navtive App ?????? ????????? ??????
                          print("NATIVE - ?????????????????? ????????? ??????");
                          loginController.kakaoSignIn().then((value) {
                            print("value : ${value}");
                            loginWithCurrentUser(value, context);
                          });
                        }
                      } catch (error) {
                        print('?????????????????? ????????? ?????? - error : ${error}');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                child: Image.asset("assets/images/kakao.png")),
                            SizedBox(width: 5),
                            Text("???????????? ???????????????",
                                style: TextStyle(
                                    fontSize: 16, color: Palette.gray00)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Apple??? ????????? ??????
                  ElevatedButton(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SizedBox(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 16,
                              child: Image.asset("assets/images/apple.png")),
                          SizedBox(width: 5),
                          Text("Apple??? ???????????????", style: TextStyle(fontSize: 16)),
                        ],
                      )),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(0),
                      elevation: 0,
                      backgroundColor: Palette.gray00,
                    ),
                    onPressed: () async {
                      analyticLog.sendAnalyticsEvent(screenName, "Apple???_???????????????",
                          "Apple??? ??????????????? ????????? ?????????", "Apple??? ??????????????? ????????? ????????????");
                      /* try {
                        isKakaoInstalled = await isKakaoTalkInstalled();
                        print("isKakaoInstalled : ${isKakaoInstalled}");
                        if (kIsWeb) {
                          // web ?????? ????????? ??????
                        } else {
                          OAuthToken token = isKakaoInstalled
                              ? await UserApi.instance.loginWithKakaoTalk()
                              : await UserApi.instance.loginWithKakaoAccount();
                          print("?????????????????? ????????? ?????? - token : ${token}");
                          final url = Uri.https('kapi.kakao.com', '/v2/user/me');
                          final response = await http.get(
                            url,
                            headers: {
                              HttpHeaders.authorizationHeader:
                                  'Bearer ${token.accessToken}'
                            },
                          );
          
                          final profileInfo = json.decode(response.body);
                          print("profileInfo.toString() : " +
                              profileInfo.toString());
                        }
                      } catch (error) {
                        print('?????????????????? ????????? ?????? - error : ${error}');
                      } */
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("?????? ????????? ????????? ?????? ?????? ????????????."),
                      ));
                    },
                  ),
                  SizedBox(height: 10),

                  // Google??? ????????? ??????
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Palette.grayB4, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(0),
                      elevation: 0,
                      backgroundColor: Palette.grayFF,
                    ),
                    onPressed: () async {
                      print("Google onPress ????????????!");
                      analyticLog.sendAnalyticsEvent(
                          screenName,
                          "Google???_???????????????",
                          "Google??? ??????????????? ????????? ?????????",
                          "Google??? ??????????????? ????????? ????????????");
                      try {
                        // if (Platform.isIOS || Platform.isAndroid) {

                        loginController.googleSignIn().then((value) {
                          print("value : ${value}");
                          loginWithCurrentUser(value, context);
                        });
                        // } else {
                        //   signInWithGoogle();
                        // }
                      } catch (error) {
                        print('Google??? ????????? ?????? - error : ${error}');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SizedBox(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 16,
                              child: Image.asset("assets/images/google.png")),
                          SizedBox(width: 5),
                          Text("Google??? ???????????????",
                              style: TextStyle(
                                  fontSize: 16, color: Palette.gray00)),
                        ],
                      )),
                    ),
                  ),
                  SizedBox(height: 10),

                  /// ????????? ?????? ???????????? ??????
                  TextButton(
                    onPressed: () {
                      analyticLog.sendAnalyticsEvent(screenName, "?????????_??????_????????????",
                          "????????? ?????? ???????????? ????????? ?????????", "????????? ?????? ???????????? ????????? ????????????");
                      loginMethodforDemo(context, authService);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("????????? ?????? ????????????",
                                style: TextStyle(
                                    fontSize: 14, color: Palette.gray66)),
                            Icon(
                              size: 14,
                              Icons.arrow_forward,
                              color: Palette.gray66,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      isEmailLoginDeactivated = !isEmailLoginDeactivated;
                      setState(() {});
                    },
                    child: Padding(
                      padding: EdgeInsets.all(14.0),
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("????????? ?????????",
                                style: TextStyle(
                                    fontSize: 14, color: Palette.gray66)),
                            Icon(
                              size: 14,
                              Icons.arrow_forward,
                              color: Palette.gray66,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  /* 
                  /// ???????????? ??????
                  ElevatedButton(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text("????????????", style: TextStyle(fontSize: 16)),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Palette.buttonOrange,
                    ),
                    onPressed: () async {
                      // ????????????
                      print("sign up");
                      Map locationMap = await getLocalInfos();
          
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SignUp.getLocationMap(locationMap)),
                      );
                    },
                  ),
                  SizedBox(height: 30), */

                  //   // ??????????????? ??????
                  //   ElevatedButton(
                  //     child: Text("???????????????", style: TextStyle(fontSize: 20)),
                  //     onPressed: () {
                  //       // ?????????
                  //       authService.signIn(
                  //         email: emailController.text,
                  //         password: passwordController.text,
                  //         onSuccess: () {
                  //           // ????????? ??????
                  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //             content: Text("????????? ??????"),
                  //           ));
                  //           // ????????? ????????? Home??? ??????
                  //           Navigator.pushReplacement(
                  //             context,
                  //             MaterialPageRoute(builder: (_) => HomePage()),
                  //           );
                  //         },
                  //         onError: (err) {
                  //           // ?????? ??????
                  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //             content: Text(err),
                  //           ));
                  //         },
                  //       );
                  //     },
                  //   ),
                  //   SizedBox(height: 10),

                  //   /// Cloud Storage ???????????? ??????
                  //   ElevatedButton(
                  //     child: Text("???????????? ????????????", style: TextStyle(fontSize: 20)),
                  //     onPressed: () {
                  //       // ????????????
                  //       print("cloud storage");
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (_) => CloudStorage()),
                  //       );
                  //     },
                  //   ),
                  //   SizedBox(height: 10),

                  /// ????????? ???????????? ??????
                  // ElevatedButton(
                  //   child: Text("????????? ?????? ????????????", style: TextStyle(fontSize: 20)),
                  //   onPressed: () {
                  //     // ????????????
                  //     print("global widget");
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => GlobalWidgetDashboard(),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map> getLocalInfos() async {
    String urlString = "https://www.icanidevelop.com/getLocalInfos";
    var url = Uri.parse(urlString);
    var response = await http.get(url);
    print("response.statusCode : ${response.statusCode}");
    final List<LocalInfo> ilList = jsonDecode(response.body)
        .map<LocalInfo>((json) => LocalInfo.fromJson(json))
        .toList();

    Map resultObj = {};
    Map resultMap = {};
    List resultList = [];
    List totalTownList = [];
    String region = "";
    ilList.forEach(
      (apiElement) {
        // print("apiElement.id['\$oid'] : ${apiElement.id['\$oid']}");
        // print("apiElement.title : ${apiElement.title}");
        // print("apiElement : ${apiElement.info}");
        List infoList = apiElement.info;
        region = "";
        apiElement.info.forEach((infoElement) {
          // print("infoElement[0] : ${infoElement[0]}");
          Map ifMap = infoElement[0];
          // print("ifMap.keys.toList()[0] : ${ifMap.keys.toList()[0]}");
          region = ifMap.keys.toList()[0].toString().split("??????")[0];
          resultMap = {};
          totalTownList = [];
          List resultMapList = ifMap.keys.toList();
          infoElement.forEach((mElement) {
            // print("mElement : ${mElement}");
            Map jMap = mElement;

            jMap.keys.forEach((kElement) {
              /* print(
                  "=========================================== ${kElement} ==========================================="); */

              List jList = jMap[kElement];
              resultList = [];
              jList.forEach((lElement) {
                /* print("lElement : ${lElement}"); */

                resultList.add(lElement);
                /* if (!lElement.toString().contains("??????")) {
                  totalTownList.add(lElement);
                } */
                totalTownList.add(lElement);
              });
              resultMap[kElement] = resultList;
              /* print(
                    "jMap[jmKeyList.length-1] : ${resultMapList[resultMapList.length-1]}"); */
              if (resultMapList[resultMapList.length - 1] ==
                  kElement.toString()) {
                /* print(
                    "jmKeyList[jmKeyList.length-1] : ${resultMapList[resultMapList.length-1]}");
                print("kElement : ${kElement}"); */
                resultMap[jMap.keys.first] = totalTownList;
              }
              // print("resultMap[${kElement}] : ${resultMap[kElement]}");
            });
          });
          resultObj.putIfAbsent(region, () => resultMap);
        });
      },
    );

    /* resultObj.forEach((key, value) {
      print("key : ${key}");
      value.forEach((key, value) {
        print("second key : ${key}");
        print("value : ${value}");
      });
    }); */

    return resultObj;
  }

  void loginMethod(BuildContext context, AuthService authService) {
    if (globalfunction.textNullCheck(
          context,
          emailController,
          "?????????",
        ) &&
        globalfunction.textNullCheck(
          context,
          passwordController,
          "????????????",
        )) {
      // ?????????
      authService.signIn(
        email: emailController.text,
        password: passwordController.text,
        onSuccess: () {
          AuthService authService = AuthService();
          var cUser = authService.currentUser();
          Future<List> resultFirstMemberList =
              memberService.readMemberListAtFirstTime(cUser!.uid);

          resultFirstMemberList.then((value) {
            print(
                "resultFirstMemberList then is called!! value.length : ${value.length}");
            globalVariables.resultList.addAll(value);
            /* for (int i = 0; i < value.length; i++) {
              print("value[${i}] : ${value[i]}");
            } */
          }).onError((error, stackTrace) {
            print("error : ${error}");
            print("stackTrace : \r\n${stackTrace}");
          }).whenComplete(() async {
            print("memberList await init complete!");

            Future<List> resultFirstActionList =
                actionService.readActionListAtFirstTime(cUser.uid);

            resultFirstActionList.then((value) {
              print(
                  "2. resultFirstActionList then is called!! value.length : ${value.length}");
              globalVariables.actionList.addAll(value);
            }).onError((error, stackTrace) {
              print("error : ${error}");
              print("stackTrace : \r\n${stackTrace}");
            }).whenComplete(() async {
              print("actionList await init complete!");

              await ticketLibraryService.read(cUser.uid).then((value) {
                globalVariables.ticketLibraryList.addAll(value);
              }).onError((error, stackTrace) {
                print("error : ${error}");
                print("stackTrace : \r\n${stackTrace}");
              }).whenComplete(() async {
                print("ticketLibraryList await init complete!");

                await memberTicketService.read(cUser.uid).then((value) {
                  globalVariables.memberTicketList.addAll(value);
                }).onError((error, stackTrace) {
                  print("error : ${error}");
                  print("stackTrace : \r\n${stackTrace}");
                }).whenComplete(() {
                  print("memberTicketList await init complete!");
                  // ????????? ??????
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("????????? ??????"),
                  ));
                  // ????????? ????????? Home??? ??????
                  /*  Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MemberList()),
              //MaterialPageRoute(builder: (_) => Mainpage()),
            ); */
                  List<dynamic> args = [
                    globalVariables.resultList,
                    globalVariables.actionList
                  ];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberList(),
                      // setting?????? arguments??? ?????? ????????? ?????? ?????? ?????????
                      settings: RouteSettings(arguments: args),
                    ),
                  );

                  emailController.clear();
                  passwordController.clear();
                });
              });
            });
          });
        },
        onError: (err) {
          // ?????? ??????
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(err),
          ));
        },
      );

      prefs.setBool("isLogInActiveChecked", isLogInActiveChecked);

      if (isLogInActiveChecked) {
        prefs.setString("userEmail", emailController.text);
        prefs.setString("userPassword", passwordController.text);
        print("switch on isLogInActiveChecked : ${isLogInActiveChecked}");
      } else {
        prefs.setString("userEmail", "");
        prefs.setString("userPassword", "");
        print("switch off isLogInActiveChecked : ${isLogInActiveChecked}");
      }
    }
  }

  void loginMethodforDemo(BuildContext context, AuthService authService) {
    if (true) {
      // ?????????
      authService.signIn(
        email: "demo@demo.com",
        password: "123456",
        onSuccess: () {
          AuthService authService = AuthService();
          var cUser = authService.currentUser();
          loginWithCurrentUser(cUser, context);
        },
        onError: (err) {
          // ?????? ??????
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(err),
          ));
        },
      );

      prefs.setBool("isLogInActiveChecked", isLogInActiveChecked);

      if (isLogInActiveChecked) {
        prefs.setString("userEmail", emailController.text);
        prefs.setString("userPassword", passwordController.text);
        print("switch on isLogInActiveChecked : ${isLogInActiveChecked}");
      } else {
        prefs.setString("userEmail", "");
        prefs.setString("userPassword", "");
        print("switch off isLogInActiveChecked : ${isLogInActiveChecked}");
      }
    }
  }

  void loginWithCurrentUser(FB.User? cUser, BuildContext context) {
    Future<List> resultFirstMemberList =
        memberService.readMemberListAtFirstTime(cUser!.uid);

    resultFirstMemberList.then((value) {
      print(
          "resultFirstMemberList then is called!! value.length : ${value.length}");
      globalVariables.resultList = [];
      globalVariables.resultList.addAll(value);
      /* for (int i = 0; i < value.length; i++) {
        print("value[${i}] : ${value[i]}");
      } */
    }).onError((error, stackTrace) {
      print("error : ${error}");
      print("stackTrace : \r\n${stackTrace}");
    }).whenComplete(() async {
      print("memberList await init complete!");

      Future<List> resultFirstActionList =
          actionService.readActionListAtFirstTime(cUser.uid);

      resultFirstActionList.then((value) {
        print(
            "3. resultFirstActionList then is called!! value.length : ${value.length}");
        globalVariables.actionList = [];
        globalVariables.actionList.addAll(value);
      }).onError((error, stackTrace) {
        print("error : ${error}");
        print("stackTrace : \r\n${stackTrace}");
      }).whenComplete(() async {
        print("actionList await init complete!");

        await ticketLibraryService.read(cUser.uid).then((value) {
          globalVariables.ticketLibraryList.addAll(value);
        }).onError((error, stackTrace) {
          print("error : ${error}");
          print("stackTrace : \r\n${stackTrace}");
        }).whenComplete(() async {
          print("ticketLibraryList await init complete!");

          await memberTicketService.read(cUser.uid).then((value) {
            globalVariables.memberTicketList.addAll(value);
          }).onError((error, stackTrace) {
            print("error : ${error}");
            print("stackTrace : \r\n${stackTrace}");
          }).whenComplete(() {
            print("memberTicketList await init complete!");
            // ????????? ??????
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("????????? ??????"),
            ));
            // ????????? ????????? Home??? ??????
            /*  Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MemberList()),
        //MaterialPageRoute(builder: (_) => Mainpage()),
      ); */
            List<dynamic> args = [
              globalVariables.resultList,
              globalVariables.actionList
            ];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemberList(),
                // setting?????? arguments??? ?????? ????????? ?????? ?????? ?????????
                settings: RouteSettings(arguments: args),
              ),
            );

            emailController.clear();
            passwordController.clear();
          });
        });
      });
    });
  }
}

/* /// ????????????
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController jobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser()!;
    return Consumer<BucketService>(
      builder: (context, bucketService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("?????? ?????????"),
            actions: [
              TextButton(
                child: Text(
                  "????????????",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  print("sign out");
                  // ????????????
                  context.read<AuthService>().signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              /// ?????????
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    /// ????????? ?????????
                    Expanded(
                      child: TextField(
                        controller: jobController,
                        decoration: InputDecoration(
                          hintText: "?????? ?????? ?????? ??????????????????.",
                        ),
                      ),
                    ),

                    /// ?????? ??????
                    ElevatedButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        // create bucket
                        if (jobController.text.isNotEmpty) {
                          print("create bucket");
                          bucketService.create(jobController.text, user.uid);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 1),

              /// ?????? ?????????
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                    future: bucketService.read(user.uid),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? []; // ????????? ????????????
                      if (docs.isEmpty) {
                        return Center(child: Text("?????? ???????????? ??????????????????."));
                      }
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          String job = doc.get('job');
                          bool isDone = doc.get('isDone');
                          return ListTile(
                            title: Text(
                              job,
                              style: TextStyle(
                                fontSize: 24,
                                color: isDone ? Colors.grey : Colors.black,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            // ?????? ????????? ??????
                            trailing: IconButton(
                              icon: Icon(CupertinoIcons.delete),
                              onPressed: () {
                                // ?????? ?????? ?????????
                                bucketService.delete(doc.id);
                              },
                            ),
                            onTap: () {
                              // ????????? ???????????? isDone ????????????
                              bucketService.update(doc.id, !isDone);
                            },
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        );
      },
    );
  }
} */
