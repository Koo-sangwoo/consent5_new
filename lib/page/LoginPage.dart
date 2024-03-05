import 'dart:convert';
import 'dart:io';

import 'package:consent5/getx_controller/patient_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final PatientDetailController _patientDetailController = Get.put(PatientDetailController());

  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    result = <String, dynamic>{};
    myFocusNode = FocusNode();
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
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 400,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/background.png'),
                            fit: BoxFit.fill)),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 30,
                          width: 80,
                          height: 200,
                          child: FadeInUp(
                              duration: const Duration(seconds: 1),
                              child: Container(
                                decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/light-1.png'))),
                              )),
                        ),
                        Positioned(
                          left: 140,
                          width: 80,
                          height: 150,
                          child: FadeInUp(
                              duration: const Duration(milliseconds: 1200),
                              child: Container(
                                decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/light-2.png'))),
                              )),
                        ),
                        Positioned(
                          right: 40,
                          top: 40,
                          width: 80,
                          height: 150,
                          child: FadeInUp(
                              duration: const Duration(milliseconds: 1300),
                              child: Container(
                                decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/clock.png'))),
                              )),
                        ),
                        Positioned(
                          child: FadeInUp(
                              duration: const Duration(milliseconds: 1600),
                              child: Container(
                                margin: const EdgeInsets.only(top: 50),
                                child: const Center(
                                  child: Text(
                                    "전자동의서",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: <Widget>[
                        FadeInUp(
                            duration: const Duration(milliseconds: 1800),
                            child: Container(
                              width: 350,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(143, 148, 251, 1)),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color.fromRGBO(143, 148, 251, .2),
                                        blurRadius: 20.0,
                                        offset: Offset(0, 10))
                                  ]),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Color.fromRGBO(
                                                    143, 148, 251, 1)))),
                                    child: TextField(
                                      controller: _Idcontroller,
                                      focusNode: myFocusNode,
                                      autofocus: true,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) => idTextBox = value,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "id",
                                          hintStyle:
                                              TextStyle(color: Colors.grey[700])),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      controller: _Pwcontroller,
                                      onChanged: (value) => pwTextBox = value,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "password",
                                          hintStyle:
                                              TextStyle(color: Colors.grey[700])),
                                    ),
                                  )
                                ],
                              ),
                            )),
                        const SizedBox(
                          height: 30,
                        ),
                        FadeInUp(
                            duration: const Duration(milliseconds: 1900),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(350, 50),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                ),
                                backgroundColor:
                                    const Color.fromRGBO(143, 148, 251, 1),
                              ),
                              onPressed: () async {
                                if (idTextBox!.isEmpty || pwTextBox!.isEmpty) {
                                  showDialog(
                                      context: context,
                                      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
                                      barrierDismissible: true,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          //Dialog Main Title
                                          title: const Column(
                                            children: <Widget>[
                                              Text("계정 확인"),
                                            ],
                                          ),
                                          //
                                          content: const Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "아이디 또는 비밀번호를 입력해주세요",
                                              ),
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
                                      });
                                } else {
                                  String methodName = "Login";
                                  String userId = _Idcontroller.text;
                                  String userPw = _Pwcontroller.text;
                                  String url = "";

                                  result = await makeRequest(
                                      methodName: methodName,
                                      userId: userId,
                                      userPw: userPw,
                                      url: url);

                                  if (result != null) {
                                    _storage.write(
                                      key: "userInfo",
                                      value: jsonEncode(result),
                                    );
                                    _patientDetailController.updatePatientInfo(userInfo: result);
                                    print("@@$result");

                                    if(result != null) {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                      return MainPage();
                                    }));
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
                                        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
                                        barrierDismissible: true,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0)),
                                            //Dialog Main Title
                                            title: const Column(
                                              children: <Widget>[
                                                Text("계정 확인"),
                                              ],
                                            ),
                                            //
                                            content: const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "계정을 확인해주세요",
                                                ),
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
                                        });
                                  }
                                }
                              },
                              child: const Text('LOGIN'),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
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
