import 'dart:convert';
import 'dart:io';

import 'package:consent5/getx_controller/patient_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'MainPage.dart';
import 'package:get/get.dart';
import '../Webservice/httpService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? idTextBox = "";
  String? pwTextBox = "";
  Map<String, dynamic>? result;
  final _storage = const FlutterSecureStorage();

  final _Idcontroller = TextEditingController();
  final _Pwcontroller = TextEditingController();
  final PatientDetailController _patientDetailController =
      Get.put(PatientDetailController());

  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    result = <String, dynamic>{};
    myFocusNode = FocusNode();
    requestPermissions();
  }

  @override
  void dispose() {
    _Idcontroller.dispose();
    _Pwcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: OrientationBuilder(
        builder: (context, orientation) {
          print('로그인 화면전환');
          return orientation == Orientation.portrait
              ? buildPortraitLayout() // 세로 모드의 UI 구성
              : buildLandscapeLayout(); // 가로 모드의 UI 구성
        },
      ),
    );
  }

  Widget buildPortraitLayout() {
    // 세로 모드의 UI 구성을 반환하는 메서드
    return WillPopScope(
      onWillPop: () async {
        bool? exit = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('앱 종료'),
              content: Text('앱을 종료하시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // 취소 버튼, 아무 동작 없음
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // 확인 버튼, 앱 종료
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
        return exit ?? false; // null이면 false 반환
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 20.0), // 아이디 텍스트박스 위에 공백 추가
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1700),
                      child: Container(
                        // 로그인 화면 태블릿 이미지
                        // 이미지 너비 설정
                        height: 80,
                        width: 80,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/login_tablet.png'), // 이미지 경로 설정
                            scale: 0.1,
                            fit: BoxFit.contain, // 이미지가 컨테이너에 꽉 차도록 설정
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 20.0), // 아이디 텍스트박스 위에 공백 추가
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1700),
                      child: Container(
                        // 로그인 화면 태블릿 이미지
                        // 이미지 너비 설정
                        height: 40,
                        width: 500,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/login_clip_eform.png'), // 이미지 경로 설정
                            scale: 0.5,
                            fit: BoxFit.contain, // 이미지가 컨테이너에 꽉 차도록 설정
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 350,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(
                                      206, 206, 206, 1), // 컨테이너의 보더 색상 설정
                                ),
                                borderRadius:
                                    BorderRadius.circular(8), // 컨테이너의 라운드
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: TextField(
                                  controller: _Idcontroller,
                                  focusNode: myFocusNode,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => idTextBox = value,
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // 텍스트 필드의 보더 제거
                                    hintText: "아이디",
                                    hintStyle: TextStyle(
                                      color: Color.fromRGBO(
                                          206, 206, 206, 1), // 힌트 텍스트 색상 설정
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Color.fromRGBO(
                                          206, 206, 206, 1), // 아이콘 색상 설정
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 0,
                      ), // 아이디와 비밀번호 텍스트박스 사이에 공백 추가
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 350,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(
                                      206, 206, 206, 1), // 컨테이너의 보더 색상 설정
                                ),
                                borderRadius:
                                    BorderRadius.circular(8), // 컨테이너의 라운드
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: TextField(
                                  controller: _Pwcontroller,
                                  onChanged: (value) => pwTextBox = value,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // 텍스트 필드의 보더 제거
                                    hintText: "비밀번호",
                                    hintStyle: TextStyle(
                                      color: Color.fromRGBO(
                                          206, 206, 206, 1), // 힌트 텍스트 색상 설정
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Color.fromRGBO(
                                          206, 206, 206, 1), // 아이콘 색상 설정
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1900),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(350, 50),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 15),
                        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 8px의 모서리 설정
                        ),
                      ),
                      onPressed: () async {
                        if (idTextBox!.isEmpty || pwTextBox!.isEmpty) {
                          showDialog(
                            context: context,
                            // barrierDismissible - Dialog를 제외한 다른 화면 터치 x
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                // Dialog Main Title
                                title: const Column(
                                  children: <Widget>[
                                    Text("계정 확인"),
                                  ],
                                ),
                                // Dialog Content
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("아이디 또는 비밀번호를 입력해주세요"),
                                  ],
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: const Text("확인"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          String methodName = "Login";
                          String userId = _Idcontroller.text;
                          String userPw = _Pwcontroller.text;
                          String url = "";
                          print("로그인 로직 시작");
                          result = await makeRequest(
                            methodName: methodName,
                            userId: userId,
                            userPw: userPw,
                            url: url,
                          );

                          if (result != null) {
                            _storage.write(
                              key: "userInfo",
                              value: jsonEncode(result),
                            );
                            _patientDetailController.updatePatientInfo(
                                userInfo: result);
                            print("@@$result");

                            if (result != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return MainPage();
                                  },
                                ),
                              );
                            }

                            setState(() {
                              myFocusNode.requestFocus();
                              _Idcontroller.text = '';
                              _Pwcontroller.text = '';
                            });

                            // var userInfo =
                            //     await _storage.read(key: 'userInfo');
                            // print("@@_storage read--->$userInfo");
                            // var check = jsonDecode(userInfo!);
                            // print("@@_storage jsonencode--->" +
                            //     check['UserName']);
                          } else {
                            if (!mounted) return;
                            showDialog(
                              context: context,
                              // barrierDismissible - Dialog를 제외한 다른 화면 터치 x
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  // Dialog Main Title
                                  title: const Column(
                                    children: <Widget>[
                                      Text("계정 확인"),
                                    ],
                                  ),
                                  // Dialog Content
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("계정을 확인해주세요"),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: const Text("확인"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      },
                      child: const Text('LOGIN'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height / 2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/login_left_portrait.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLandscapeLayout() {
    // 가로 모드의 UI 구성을 반환하는 메서드
    return WillPopScope(
      onWillPop: () async {
        bool? exit = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('앱 종료'),
              content: Text('앱을 종료하시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // 취소 버튼, 아무 동작 없음
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // 확인 버튼, 앱 종료
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
        return exit ?? false; // null이면 false 반환
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  width: 900,
                  height: MediaQuery.sizeOf(context).height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage('assets/images/login_left_landscape.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20.0), // 아이디 텍스트박스 위에 공백 추가
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1700),
                        child: Container(
                          // 로그인 화면 태블릿 이미지
                          // 이미지 너비 설정
                          height: 80,
                          width: 80,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/login_tablet.png'), // 이미지 경로 설정
                              scale: 0.1,
                              fit: BoxFit.contain, // 이미지가 컨테이너에 꽉 차도록 설정
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20.0), // 아이디 텍스트박스 위에 공백 추가
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1700),
                        child: Container(
                          // 로그인 화면 태블릿 이미지
                          // 이미지 너비 설정
                          height: 40,
                          width: 500,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/login_clip_eform.png'), // 이미지 경로 설정
                              scale: 0.5,
                              fit: BoxFit.contain, // 이미지가 컨테이너에 꽉 차도록 설정
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 350,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromRGBO(
                                        206, 206, 206, 1), // 컨테이너의 보더 색상 설정
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(8), // 컨테이너의 라운드
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: TextField(
                                    controller: _Idcontroller,
                                    focusNode: myFocusNode,
                                    autofocus: true,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => idTextBox = value,
                                    decoration: InputDecoration(
                                      border: InputBorder.none, // 텍스트 필드의 보더 제거
                                      hintText: "아이디",
                                      hintStyle: TextStyle(
                                        color: Color.fromRGBO(
                                            206, 206, 206, 1), // 힌트 텍스트 색상 설정
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: Color.fromRGBO(
                                            206, 206, 206, 1), // 아이콘 색상 설정
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 0,
                        ), // 아이디와 비밀번호 텍스트박스 사이에 공백 추가
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 350,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromRGBO(
                                        206, 206, 206, 1), // 컨테이너의 보더 색상 설정
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(8), // 컨테이너의 라운드
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: TextField(
                                    controller: _Pwcontroller,
                                    onChanged: (value) => pwTextBox = value,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      border: InputBorder.none, // 텍스트 필드의 보더 제거
                                      hintText: "비밀번호",
                                      hintStyle: TextStyle(
                                        color: Color.fromRGBO(
                                            206, 206, 206, 1), // 힌트 텍스트 색상 설정
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Color.fromRGBO(
                                            206, 206, 206, 1), // 아이콘 색상 설정
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(350, 50),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 15),
                          backgroundColor:
                              const Color.fromRGBO(143, 148, 251, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // 8px의 모서리 설정
                          ),
                        ),
                        onPressed: () async {
                          if (idTextBox!.isEmpty || pwTextBox!.isEmpty) {
                            showDialog(
                              context: context,
                              // barrierDismissible - Dialog를 제외한 다른 화면 터치 x
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  // Dialog Main Title
                                  title: const Column(
                                    children: <Widget>[
                                      Text("계정 확인"),
                                    ],
                                  ),
                                  // Dialog Content
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("아이디 또는 비밀번호를 입력해주세요"),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: const Text("확인"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            String methodName = "Login";
                            String userId = _Idcontroller.text;
                            String userPw = _Pwcontroller.text;
                            String url = "";
                            print("로그인 로직 시작");
                            result = await makeRequest(
                              methodName: methodName,
                              userId: userId,
                              userPw: userPw,
                              url: url,
                            );

                            if (result != null) {
                              _storage.write(
                                key: "userInfo",
                                value: jsonEncode(result),
                              );
                              _patientDetailController.updatePatientInfo(
                                  userInfo: result);
                              print("@@$result");

                              if (result != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MainPage();
                                    },
                                  ),
                                );
                              }

                              setState(() {
                                myFocusNode.requestFocus();
                                _Idcontroller.text = '';
                                _Pwcontroller.text = '';
                              });

                              // var userInfo =
                              //     await _storage.read(key: 'userInfo');
                              // print("@@_storage read--->$userInfo");
                              // var check = jsonDecode(userInfo!);
                              // print("@@_storage jsonencode--->" +
                              //     check['UserName']);
                            } else {
                              if (!mounted) return;
                              showDialog(
                                context: context,
                                // barrierDismissible - Dialog를 제외한 다른 화면 터치 x
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    // Dialog Main Title
                                    title: const Column(
                                      children: <Widget>[
                                        Text("계정 확인"),
                                      ],
                                    ),
                                    // Dialog Content
                                    content: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("계정을 확인해주세요"),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: const Text("확인"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: const Text('LOGIN'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void requestPermissions() async {
  final Map<Permission, PermissionStatus> permissions = await [
    Permission.camera, // 카메라 권한
    Permission.photos, // 사진, 동영상 권한
    Permission.microphone, // 녹음 권한
    Permission.manageExternalStorage, // 저장소 관련 권한
  ].request();

  print('권한 요청 상태 ${permissions.toString()}');
}

// Future<Map<String, dynamic>?> someFunction() async {
//   Map<String, dynamic>? result;
//   try {
//     result = await makeRequest();
//     // 결과 사용
//     print("결과: $result");
//   } catch (error) {
//     // 오류 처리
//     result = null;
//     print("오류: $error");
//   } finally {
//     return result;
//   }
// }

// Future<Map<String, dynamic>> makeRequest() async {
//   var url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

//   Map date = {
//     "UserID": "01" // 사용자 ID
//     ,
//     "UserPassword": "test" // 사용자 PW
//   };

//   var requestParams = {
//     "methodName": 'Login',
//     "params": json.encode(date),
//     "userId": 'amdin',
//     "deviceType": "AND",
//     "deviceIdentName": "Chrome",
//     "deviceIdentIP": "172.17.200.48",
//     "deviceIdentMac": "E0AA96DEBD0A"
//   };

//   Map<String, dynamic> resultData = {};

//   try {
//     var response = await http.post(
//       Uri.parse(url),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded'
//       },
//       body: requestParams,
//       encoding: Encoding.getByName('utf-8'),
//     );

//     if (response.statusCode == 200) {
//       var data = json.decode(response.body);
//       if (data['RESULT_CODE'] == '0') {
//         // 성공 처리, JSON 데이터 반환
//         resultData = data['RESULT_DATA'];
//         // print("@@성공 ! ---> $resultData");
//       } else {
//         // 오류 정보를 JSON 형태로 반환
//         resultData = {
//           'ERROR_CODE': data['ERROR_CODE'],
//           'ERROR_MESSAGE': data['ERROR_MESSAGE']
//         };

//         // print("@@실패 ! ---> $resultData");
//       }
//     } else {
//       // 서버 오류 정보를 JSON 형태로 반환
//       resultData = {
//         'ERROR_CODE': 'Server Error',
//         'ERROR_MESSAGE':
//             'Server responded with status code: ${response.statusCode}'
//       };

//       // print("@@서버오류 ! ---> $resultData");
//     }
//   } catch (e) {
//     // 네트워크 오류 정보를 JSON 형태로 반환
//     resultData = {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()};
//     print("@@Catch ! ---> $resultData");
//   }

//   return resultData;
// }
