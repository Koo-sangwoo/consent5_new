import 'dart:collection';
import 'dart:convert';

import 'package:consent5/WebService/httpService.dart';
import 'package:consent5/getx_controller/patient_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UnfinishedWidget extends StatefulWidget {
  final bool isVerticalMode;
  final bool isVisible;
  final Map<dynamic, dynamic> patientDetail;

  const UnfinishedWidget(
      {super.key,
      required this.isVerticalMode,
      required this.isVisible,
      required this.patientDetail});

  @override
  State<UnfinishedWidget> createState() => _UnfinishedWidgetState();
}

class _UnfinishedWidgetState extends State<UnfinishedWidget> {
  List<bool> checkboxValues = [];
  int checkBoxLength = 0;
  late ValueNotifier<List<bool>> checkboxValuesNotifier;
  late PatientDetailController _patientDetailController;
  List<dynamic> selectedData = [];
  late Future<List<dynamic>> unfinishedInfoFuture;
  List<dynamic> allDataList = [];

  @override
  void initState() {
    super.initState();
    unfinishedInfoFuture = getUnfinishedInfo(); // 데이터 로드
    checkboxValuesNotifier = ValueNotifier([]);
    _patientDetailController = Get.find();
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
    unfinishedInfoFuture = getUnfinishedInfo(); // 데이터 재로드
  }

  // void reloadData() {
  //   setState(() {
  //     unfinishedInfoFuture = getUnfinishedInfo(); // 데이터 재로드
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    print('처방동의서 bool 값 : ${widget.isVisible}');
    const platform = MethodChannel('com.example.consent5/kmiPlugin');

    return Container(
      alignment: Alignment.centerLeft,
      height: 250,
      width: widget.isVerticalMode ? 375 : 380,
      margin: widget.isVerticalMode
          ? const EdgeInsets.fromLTRB(5, 15, 10, 5)
          : const EdgeInsets.fromLTRB(5, 15, 5, 10),
      // 기존 right margin = 5;
      // color: Colors.blue,
      decoration: BoxDecoration(
          color: Colors.white,
          // color: Colors.blue, // 컨테이너의 배경색
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              spreadRadius: 3,
              blurRadius: 30,
            )
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "처방동의서",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
              ),
              Container(
                  width: 100,
                  height: 30,
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(
                              color : Color.fromRGBO(115, 140, 243, 1),
                              width: 0.5, // 테두리 두께
                          )
                        )
                      ),
                      onPressed: () async { // 모든 처방동의서를 열 것인지 물어본다.
                        List<dynamic> fdata = await getUnfinishedInfo();
                        List<Map<String, String>> consents = [];
                        fdata.forEach((data) {
                          Map<String, String> consentMap = {
                            'FormCd':
                            data['FormCd'].toString(),
                            'FormId':
                            data['FormId'].toString(),
                            'FormVersion': data['FormVersion']
                                .toString(),
                            'FormRid':
                            data['FormRid'].toString(),
                            'FormGuid':
                            data['FormGuid'].toString(),
                            'FormName':
                            data['FormName'].toString(),
                          };
                          consents.add(consentMap);
                        });

                        String formNames = '';

                        // 환자정보 세팅
                        Map<dynamic, dynamic> params =
                            _patientDetailController
                                .patientDetail.value;

                        for(int i = 0; i < 2; i++){
                          if(formNames == ''){
                            formNames = consents[0]['FormName']!;
                          }else{
                            formNames += '외 ${consents.length-1}개의 ';
                          }
                        }

                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                    '${formNames} 서식을 열겠습니까?'),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop();
                                        platform.invokeMethod(
                                            'openEForm', {
                                          'type': 'new',
                                          'consents':
                                          jsonEncode(
                                              consents),
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
                      child: Text(
                        '전체선택',
                        style: TextStyle(fontSize: 12, color: Color.fromRGBO(115, 140, 243, 1)),
                      ))),
            ],
          ),
        ),
        const Divider(
            thickness: 0.5,
            height: 20,
            color: Color.fromRGBO(233, 233, 233, 1)),
        Expanded(
            child: widget.isVisible
                ? FutureBuilder(
                    future: unfinishedInfoFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
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


                        return ListView.separated(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return ValueListenableBuilder<List<bool>>(
                              valueListenable: checkboxValuesNotifier,
                              builder: (context, values, child) {
                                allDataList = data;
                                return InkWell(
                                  onTap: () {
                                    print('서식 데이터용 ${data[index]}');
                                    // print('즐겨찾기 여부 : ${data[index]['UseYn']}');
                                    List<Map<String, String>> consents = [];
                                    if (selectedData.length == 0) {
                                      // 서식 하나 선택시
                                      consents = [
                                        {
                                          'FormCd':
                                              data[index]['FormCd'].toString(),
                                          'FormId':
                                              data[index]['FormId'].toString(),
                                          'FormVersion': data[index]
                                                  ['FormVersion']
                                              .toString(),
                                          'FormRid':
                                              data[index]['FormRid'].toString(),
                                          'FormGuid': data[index]['FormGuid']
                                              .toString(),
                                          'FormName': data[index]['FormName']
                                              .toString(),
                                        }
                                      ];
                                    } else {
                                      selectedData.forEach((data) {
                                        Map<String, String> consentMap = {
                                          'FormCd': data['FormCd'].toString(),
                                          'FormId': data['FormId'].toString(),
                                          'FormVersion':
                                              data['FormVersion'].toString(),
                                          'FormRid': data['FormRid'].toString(),
                                          'FormGuid':
                                              data['FormGuid'].toString(),
                                          'FormName':
                                              data['FormName'].toString(),
                                        };
                                        consents.add(consentMap);
                                      });
                                      print('다중서식 정보 : ${consents.toString()}');
                                    }

                                    Map<dynamic, dynamic> params =
                                        _patientDetailController
                                            .patientDetail.value;

                                    String formNames = '';
                                    if (selectedData.length < 2) { // 체크박스가 하나만 체크되었거나, 하나도체크가되지않았을때
                                      formNames = data[index]['FormName'];
                                    } else {
                                      for(int i = 0; i < 2; i++){
                                        if(i == 0){
                                          formNames = consents[0]['FormName']!;
                                        }else{
                                          formNames += '외 ${consents.length-1}개의 ';
                                        }
                                      }
                                    }
                                    print(
                                        "JSON 변형값 consents : ${jsonEncode(consents)}, params : ${jsonEncode(params)}");

                                    // 서식 오픈 여부를 결정하는 alert 창
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content:
                                                Text(selectedData.length == data.length ? '모든 처방동의서를 열겠습니까?' : '${formNames} 서식을 열겠습니까?'),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    platform.invokeMethod(
                                                        'openEForm', {
                                                      'type': 'new',
                                                      'consents':
                                                          jsonEncode(consents),
                                                      'params':
                                                          jsonEncode(params),
                                                      // 'op': 'someOperation',
                                                    });
                                                  },
                                                  child: Text('확인')),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('취소'))
                                            ],
                                          );
                                        });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                    child: Row(
                                      children: <Widget>[
                                        Text('${index + 1}.'),
                                        Checkbox(
                                          value: values[index],
                                          visualDensity: VisualDensity(
                                              vertical: 1, horizontal: -4),
                                          // 크기 조절
                                          side: BorderSide(
                                              width: 1,
                                              color: Colors.grey.shade400),
                                          // 테두리 설정
                                          onChanged: (bool? newValue) {
                                            var newValues =
                                                List<bool>.from(values);
                                            newValues[index] =
                                                newValue ?? false;
                                            checkboxValuesNotifier.value =
                                                newValues;

                                            Map<String, dynamic> item =
                                                data[index];
                                            if (newValue == true) {
                                              // 체크박스가 선택되었을 때, 리스트에 해당 데이터가 없으면 추가
                                              if (!selectedData.any((element) =>
                                                  element['FormName'] ==
                                                  item['FormName'])) {
                                                selectedData.add(item);
                                              }
                                              print('selectedData 인서트 ');
                                            } else {
                                              // 체크박스가 해제되었을 때, 리스트에서 해당 데이터 제거
                                              selectedData.removeWhere(
                                                  (element) =>
                                                      element['FormName'] ==
                                                      item['FormName']);
                                            }
                                          },
                                        ),
                                        Expanded(
                                          child: Text(
                                            data[index]['FormName'],
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            color: Color.fromRGBO(233, 233, 233, 1),
                            thickness: 0.5, // 두께를 1로 설정
                            height: 0, // 높이를 줄임
                          ),
                        );
                      } else {
                        return const Text("조회된 자료가 없습니다.");
                      }
                    },
                  )
                : Container()),
      ]),
    );
  }

  /// @author sangU02 <br/>
  /// @since 2023/01/06 <br/>
  /// @note 환자 처방동의서 리스트
  Future<List<dynamic>> getUnfinishedInfo() async {
    Future<List<dynamic>> makeRequest2 = makeRequest_GetUnfinished(
        methodName: 'GetUnfinishedConsentSearch',
        userId: '02',
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
