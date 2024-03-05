import 'dart:convert';

import 'package:consent5/WebService/httpService.dart';
import 'package:consent5/getx_controller/patient_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class WriteConsentWidget extends StatefulWidget {
  final bool isVisible;
  final bool isVerticalMode;
  final Map<dynamic, dynamic> patientDetail;


  const WriteConsentWidget(
      {super.key,
      required this.isVisible,
      required this.isVerticalMode,
      required this.patientDetail,
      });

  @override
  State<WriteConsentWidget> createState() => _WriteConsentWidgetState();
}

class _WriteConsentWidgetState extends State<WriteConsentWidget> with WidgetsBindingObserver{
  List<bool> checkboxValues = [];
  late ValueNotifier<List<bool>> checkboxValuesNotifier;
  List<Map<String, dynamic>> selectedData = [];
  late Future<List<dynamic>> unfinishedInfoFuture;
  late Map<dynamic, dynamic> patientDetail;

  @override
  void initState() {
    super.initState();
    unfinishedInfoFuture = getUnfinishedInfo(); // 데이터 로드
    checkboxValuesNotifier = ValueNotifier([]);
    WidgetsBinding.instance?.addObserver(this); // 생성시 위젯상태를 감지하는 옵저버 추가
  }

  void reloadData() {
    setState(() {
      unfinishedInfoFuture = getUnfinishedInfo(); // 데이터 재로드
    });
  }
  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this); // 종료시 사라짐
    super.dispose();
  }


  // widgetBinding객체를 통해 외부앱 -> 업무앱 이동을 감지해서 setState실행(데이터 최신화)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        // setState를 호출하여 화면을 다시 그립니다.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    patientDetail = widget.patientDetail;

    // 유저정보와 detail 정보를 가져옴
    Map<dynamic, dynamic> detail = patientDetail;

    //
    Map<dynamic, dynamic> patientInfo = detail['detail'];
    const platform = MethodChannel('com.example.consent5/kmiPlugin');

    return Expanded(
      child: Container(
        // padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        alignment: Alignment.centerLeft,
        height: 250,
        width: widget.isVerticalMode ? 375 : 380,
        margin: widget.isVerticalMode
            ? const EdgeInsets.fromLTRB(5, 5, 10, 5)
            : const EdgeInsets.fromLTRB(5, 5, 5, 10),
        // 기존 right margin = 5;
        // color: Colors.blue,
        decoration: BoxDecoration(
            // color: Colors.blue, // 컨테이너의 배경색
            borderRadius: BorderRadius.circular(20.0),
            // 테두리의 둥근 정도
            color: Colors.white),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
              child: const Text(
                "작성동의서",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
              )),
          const Divider(
              thickness: 0.5,
              height: 20,
              color: Color.fromRGBO(233, 233, 233, 1)),
          Expanded(
              child: widget.isVisible
                  ? FutureBuilder(
                      future: getConsents(patientInfo['PatientCode']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.connectionState ==
                                ConnectionState.done &&
                            snapshot.hasData) {
                          var data = snapshot.data as List<dynamic>;

                          checkboxValuesNotifier.value =
                              List.generate(data.length, (index) => false);
                          selectedData.clear(); //

                          if (checkboxValuesNotifier.value.isEmpty) {
                            checkboxValuesNotifier.value =
                                List.generate(data.length, (index) => false);
                          }
                          if (data.isNotEmpty) {
                            return ListView.separated(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return ValueListenableBuilder<List<bool>>(
                                  valueListenable: checkboxValuesNotifier,
                                  builder: (context, values, child) {
                                    return InkWell(
                                      onTap: () {
                                        print(
                                            '선택한 동의서 Rid : ${data[index]['ConsentMstRid']} / 선택한 동의서 저장타입 : ${data[index]['ConsentState']}');
                                        String consentType = 'temp';
                                        String korConsentType = '';
                                        // String formNames = data[index]['FormName'];

                                        List<Map<String, String>> saveConsent =
                                            [
                                          {
                                            'ConsentMstRid': data[index]
                                                    ['ConsentMstRid']
                                                .toString(),
                                            'FormCd': data[index]['FormCd'].toString(),
                                            'FormId': data[index]['FormId'].toString(),
                                            'FormVersion':
                                            data[index]['FormVersion'].toString(),
                                            'FormRid':
                                            data[index]['FormRid'].toString(),
                                            'FormGuid':
                                            data[index]['FormGuid'].toString(),
                                          }
                                        ];
                                        // 환자 상세정보
                                        Map<dynamic, dynamic> params = detail;


                                        if (data[index]['ConsentState'] ==
                                            'ELECTR_CMP') {
                                          consentType = 'end';
                                        }

                                        if (consentType == 'temp') {
                                          korConsentType = '임시저장';
                                        } else {
                                          korConsentType = '인증저장';
                                        }

                                        showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    "${korConsentType}서식 열기"),
                                                content: Text(' 서식을 열겠습니까?'),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        platform.invokeMethod(
                                                            'openEForm', {
                                                          'type': consentType,
                                                          'consents':
                                                              jsonEncode(
                                                                  saveConsent),
                                                          'params': jsonEncode(
                                                              params),
                                                          // 'op': 'someOperation',
                                                        });
                                                      },
                                                      child: Text('확인')),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('취소'))
                                                ],
                                              );
                                            });
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                20, 0, 5, 0),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4), // 가로 세로 패딩 조절
                                            decoration: BoxDecoration(
                                              color: getContainerColor(data[
                                                      index]
                                                  ['ConsentStateDisp']), // 배경색
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      15), // 모서리 둥글기
                                            ),
                                            child: Text(
                                              data[index]['ConsentStateDisp'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: getConsentTextColor(
                                                    data[index]
                                                        ['ConsentStateDisp']),
                                                fontWeight: FontWeight
                                                    .bold, // 글자 두께를 더 두껍게 설정
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '[${data[index]['ModifyDateTime'].toString().substring(0, 10)}] ' +
                                                  data[index]['ConsentName'],
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                color: Color.fromRGBO(233, 233, 233, 1),
                                thickness: 0.5, // 두께를 1로 설정
                                height: 30, // 높이를 줄임
                              ),
                            );
                          } else {
                            return Center(child: const Text("조회된 자료가 없습니다."));
                          }
                        } else {
                          return Center(child: const Text("조회된 자료가 없습니다."));
                        }
                      },
                    )
                  : Container()),
        ]),
      ),
    );
  }

  Color getContainerColor(String consentStateDisp) {
    switch (consentStateDisp) {
      case '임시':
        return Color.fromRGBO(240, 242, 255, 1);
      case '완료':
        return Color.fromRGBO(115, 140, 241, 1);
      case '구두':
        return Colors.red;
      case '진행':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/02/29 <br/>
   * @note 작성동의서 상태 텍스트 글자
   */
  Color getConsentTextColor(String consentState) {
    switch (consentState) {
      case '임시':
        return Color.fromRGBO(115, 140, 241, 1);
      case '완료':
        return Color.fromRGBO(255, 255, 255, 1);
      case '구두':
        return Colors.red;
      case '진행':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  /// @author sangU02 <br/>
  /// @since 2024/01/06 <br/>
  /// @note 동의서 리스트 조회 메서드
  Future<List<dynamic>> getConsents(String patientCode) async {
    Future<List<dynamic>> consentList = makeRequest_getConsents(
        methodName: 'GetConsents',
        userId: '01',
        userPw: '1234',
        patientCode: patientCode,
        url: 'http://59.11.2.207:50089/ConsentSvc.aspx');

    List<dynamic> getConsentsList = await consentList;
    return getConsentsList;
  }

  /// @author sangU02 <br/>
  /// @since 2023/01/06 <br/>
  /// @note 환자 처방동의서 리스트
  Future<List<dynamic>> getUnfinishedInfo() async {
    Future<List<dynamic>> makeRequest2 = makeRequest_GetUnfinished(
        methodName: 'GetUnfinishedConsentSearch',
        userId: '01',
        userPw: '1234',
        url: 'http://59.11.2.207:50089/HospitalSvc.aspx');
    List<dynamic> printReq = await makeRequest2;
    return printReq;
  }

  void _handleCheckboxChanged(int index, bool? newValue) {
    setState(() {
      checkboxValues[index] = newValue ?? false;
    });
  }
}
