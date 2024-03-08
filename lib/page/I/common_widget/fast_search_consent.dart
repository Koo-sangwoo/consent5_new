import 'dart:convert';

import 'package:consent5/WebService/httpService.dart';
import 'package:consent5/getx_controller/patient_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class FastSearchWidget extends StatefulWidget {
  const FastSearchWidget({super.key});

  @override
  State<FastSearchWidget> createState() => _FastSearchWidgetState();
}

class _FastSearchWidgetState extends State<FastSearchWidget> {
  String dropdownWardValue = '병동';
  String dropdownDeptValue = '진료과';
  List<String> wardList = ['병동', '101', '102', '103'];

  List<String> deptList = ['진료과', '신경과', '정형외과', '이비인후과'];
  int selectedValue = 1; // 기본값으로 1을 설정

  bool isCheckUserWritten = false; // 내가 작성한 동의서 체크박스 옵션
  bool isChecked1 = true; // 첫 번째 체크박스 상태
  bool isChecked2 = false; // 두 번째 체크박스 상태
  String wardValue = '병동';
  String deptValue = '진료과';
  int patientVisitType = 1;

  final TextEditingController _usercontroller = TextEditingController();
  final TextEditingController _patientcontroller = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController dateController2 = TextEditingController();
  late PatientDetailController _patientDetailController;

  @override
  void initState() {
    _patientDetailController = Get.find();
  }

  @override
  void dispose() {
    // 위젯이 dispose될 때 컨트롤러도 dispose해야 합니다.
    _usercontroller.dispose();
    _patientcontroller.dispose();
    super.dispose();
  }

  String getToday(String check) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    if (check == "F") {
      // 3일 전 날짜 계산
      DateTime threeDaysAgo = now.subtract(const Duration(days: 3));
      return formatter.format(threeDaysAgo);
    } else {
      return formatter.format(now);
    }
  }

  void onChanged(int newValue) {
    setState(() {
      selectedValue = newValue; // 선택된 값으로 상태 업데이트
    });
  }

  Future<List<dynamic>> getFastConsents() async {
    List<dynamic> makeRequest2 = await makeRequest_fastSearch(
        methodName: 'Get_Fast_Consents',
        userId: '01',
        userPw: '1234',
        url: 'http://59.11.2.207:50089/ConsentSvc.aspx');
    List<dynamic> printReq = await makeRequest2;
    print("빠른조회 리턴값 : $printReq");

    return printReq;
  }

  @override
  Widget build(BuildContext context) {
    Future<void> selectDate(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        // locale: const Locale('ko', 'KR'), // 날짜 선택기에 한국어 로케일 적용
      );
      if (pickedDate != null && pickedDate != DateTime.now()) {
        setState(() {
          // DateFormat을 사용하여 날짜 형식을 지정합니다.
          // 예: 2023년 12월 26일 형식으로 표시하려면 yyyy년 MM월 dd일 형식을 사용합니다.
          // 다음과 같이 DateFormat을 사용하여 날짜 형식을 변경할 수 있습니다:
          // dateController.text = DateFormat('yyyy년 MM월 dd일').format(pickedDate);
          dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
        });
      }
    }

    String dateText = getToday('F');
    String dateText2 = getToday('now');

    return Container(
      color: Color.fromRGBO(239, 243, 250, 1),
      child: Row(
        children: [
          Column(
            children: [
              Expanded(
                // 이 부분을 추가하여 Container가 사용 가능한 공간을 채우도록 합니다.
                child: Row(
                  children: [
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.05),
                                spreadRadius: 3,
                                blurRadius: 30)
                          ]),
                      width: MediaQuery.of(context).size.width * 0.35,
                      // 적절한 패딩 제공
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isCheckUserWritten,
                                  visualDensity: VisualDensity(
                                      vertical: -4, horizontal: -4),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isCheckUserWritten = value!;
                                    });
                                  },
                                  // 크기 조절
                                  side: BorderSide(
                                      width: 1,
                                      color: Color.fromRGBO(202, 202, 202, 1)),
                                ),
                                const Text("내가 작성한 동의서만 조회"),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            const Text('사번'),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _usercontroller,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(
                                      12), // 경계선의 둥근 모서리 반경
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // 평상시의 textField외곽선에 대한 선 지정
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(
                                        233, 233, 233, 1), // 활성화된 상태의 테두리 색상
                                    width: 1.0, // 활성화된 상태의 테두리 두께
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      12.0), // 활성화된 상태의 테두리 모서리 반경
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // 텍스트 필드에 포커싱이 잡혀있을때(커서가 잡혀있을때)
                                  borderSide: BorderSide(
                                      color: const Color.fromRGBO(
                                          233, 233, 233, 1),
                                      width: 1.0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                              ),
                              style: const TextStyle(fontSize: 12.0),
                            ),
                            const SizedBox(height: 20),
                            const Text('환자번호'),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _patientcontroller,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(
                                      12), // 경계선의 둥근 모서리 반경
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // 평상시의 textField외곽선에 대한 선 지정
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(
                                        233, 233, 233, 1), // 활성화된 상태의 테두리 색상
                                    width: 1.0, // 활성화된 상태의 테두리 두께
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      12.0), // 활성화된 상태의 테두리 모서리 반경
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // 텍스트 필드에 포커싱이 잡혀있을때(커서가 잡혀있을때)
                                  borderSide: BorderSide(
                                      color: const Color.fromRGBO(
                                          233, 233, 233, 1),
                                      width: 1.0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                              ),
                              style: const TextStyle(fontSize: 12.0),
                            ),
                            const SizedBox(height: 20),
                            Text('진료과 / 병동 선택'),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: wardList[0],
                                    icon: const Icon(
                                      Icons.expand_more,
                                      color: Colors.grey,
                                    ),
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(
                                                233, 233, 233, 1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(
                                                233, 233, 233, 1)),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() {
                                        wardValue = value!;
                                      });
                                    },
                                    items: wardList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: (wardValue == '병동')
                                                  ? Colors.grey
                                                  : Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: deptList[0],
                                    icon: const Icon(
                                      Icons.expand_more,
                                      color: Colors.grey,
                                    ),
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(
                                                233, 233, 233, 1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(
                                                233, 233, 233, 1)),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() {
                                        deptValue = value!;
                                      });
                                    },
                                    items: deptList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: (deptValue == '진료과')
                                                  ? Colors.grey
                                                  : Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Text('출력일'),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextField(
                                  controller: dateController,
                                  decoration: InputDecoration(
                                    hintText: "$dateText",
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(233, 233, 233, 1)),
                                    ),
                                    // 포커싱 잡혔을때 노란색은 쫌;;
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black.withOpacity(0.5)),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    suffixIcon: Icon(Icons.calendar_today),
                                    suffixIconColor:
                                        Colors.grey.withOpacity(0.5),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    selectDate(context);
                                  },
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                )),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '~',
                                  style: TextStyle(
                                      color: Color.fromRGBO(167, 167, 167, 1)),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                    child: TextField(
                                  controller: dateController,
                                  decoration: InputDecoration(
                                    hintText: "$dateText2",
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(233, 233, 233, 1)),
                                    ),
                                    // 포커싱 잡혔을때 노란색은 쫌;;
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black.withOpacity(0.5)),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    suffixIcon: Icon(Icons.calendar_today),
                                    suffixIconColor:
                                        Colors.grey.withOpacity(0.5),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    selectDate(context);
                                  },
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                )),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('방문 유형'),
                            consentSearchTypeWidget(patientVisitType,
                                (int newValue) {
                              setState(() {
                                this.patientVisitType = newValue;
                              });
                            }),
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('동의서 유형'),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isChecked1,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isChecked1 = value!;
                                            });
                                          },
                                        ),
                                        const Text("임시저장"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isChecked2,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isChecked2 = value!;
                                            });
                                          },
                                        ),
                                        const Text("인증저장"),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '총 조회건수 : 37건',
                                  style: TextStyle(
                                      color: Color.fromRGBO(135, 139, 157, 1)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // 버튼 클릭 시 실행할 작업
                                        setState(() {
                                          // 초기화 옵션
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromRGBO(255, 255, 255, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          side: BorderSide(
                                            color: Color.fromRGBO(
                                                115, 140, 243, 1),
                                            // 테두리 색상
                                            width: 0.5, // 테두리 두께
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        // Row의 크기를 내용물 크기에 맞게 조정
                                        children: <Widget>[
                                          Icon(
                                            Icons.refresh,
                                            size: 33,
                                            color: Color.fromRGBO(
                                                115, 140, 243, 1),
                                          ),
                                          SizedBox(
                                              width: 4), // 아이콘과 텍스트 사이의 공간 조정
                                          Text(
                                            '초기화',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color.fromRGBO(
                                                    115, 140, 243, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // 버튼 클릭 시 실행할 작업
                                        // 빠른조회 메서드
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromRGBO(255, 255, 255, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          side: BorderSide(
                                            color: Color.fromRGBO(
                                                115, 140, 243, 1),
                                            // 테두리 색상
                                            width: 0.5, // 테두리 두께
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        // Row의 크기를 내용물 크기에 맞게 조정
                                        children: <Widget>[
                                          Icon(
                                            Icons.search,
                                            size: 33,
                                            color: Color.fromRGBO(
                                                115, 140, 243, 1),
                                          ),
                                          SizedBox(
                                              width: 4), // 아이콘과 텍스트 사이의 공간 조정
                                          Text(
                                            '검색',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color.fromRGBO(
                                                    115, 140, 243, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ], //children
                        ),
                      ),
                    ), // 빠른 조회 조회조건 끝
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            // 조회된 데이터
            child: Column(
              children: [
                Row(
                  // 상단 헤더
                  children: [
                    Expanded(
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(color: Colors.green),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(30, 5, 0, 0),
                          child: const Row(
                            children: [
                              Text(
                                '저장상태',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                '등록번호',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                '진료과/진료의',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                width: 50,
                              ),
                              Text(
                                '병동',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                width: 80,
                              ),
                              Text(
                                '출력일시',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                width: 100,
                              ),
                              Text(
                                '서식명',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                    child: Container(
                  color: Colors.red,
                  child: FutureBuilder(
                      future: getFastConsents(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // 데이터 받아오는중..
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.connectionState ==
                                ConnectionState.done &&
                            snapshot.hasData) {
                          // 데이터를 정상적으로 받아왔으면
                          var data = snapshot.data as List<dynamic>; // 변수에 저장

                          print("FutureBuilder data Length : ${data.length}");

                          return ListView.separated(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              String korSaveType = setSaveTypeString(
                                  consentType: data[index]['ConsentState']);

                              return InkWell(
                                child: Container(
                                  height: 80,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 95, // 저장상태
                                        child: Center(
                                          child: Text(
                                            korSaveType,
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 100, // 등록번호
                                        child: Center(
                                          child: Text(
                                            data[index]['PatientCode'],
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 110, // 진료과
                                        child: Center(
                                          child: Text(
                                            '${data[index]['ChargeName']}/${data[index]['ClnDeptCd']}',
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 50, // 병동
                                        child: Center(
                                          child: Text(
                                            data[index]['Ward'],
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 150, // 출력일시
                                        child: Center(
                                          child: Text(
                                            data[index]['ModifyDateTime'],
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 200, // 서식명
                                        child: Center(
                                          child: Text(
                                            data[index]['FormName'],
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  const platform = MethodChannel(
                                      'com.example.consent5/kmiPlugin');

                                  String consentType = 'temp';
                                  if (data[index]['ConsentState'] ==
                                      'ELECTR_CMP') {
                                    consentType = 'end';
                                  }

                                  List<Map<String, String>> saveConsent = [
                                    {
                                      'ConsentMstRid': data[index]
                                              ['ConsentMstRid']
                                          .toString(),
                                      'FormCd':
                                          data[index]['FormCd'].toString(),
                                      'FormId':
                                          data[index]['FormId'].toString(),
                                      'FormVersion':
                                          data[index]['FormVersion'].toString(),
                                      'FormRid':
                                          data[index]['FormRid'].toString(),
                                      'FormGuid':
                                          data[index]['FormGuid'].toString(),
                                    }
                                  ];

                                  Map<dynamic, dynamic> mapData =
                                      _patientDetailController
                                          .patientDetail.value;

                                  Map<dynamic, dynamic> params =
                                      mapData['detail'];

                                  showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text(
                                              '${data[index]['ConsentName']} 서식을 열겠습니까?'),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  platform.invokeMethod(
                                                      'openEForm', {
                                                    'type': consentType,
                                                    'consents':
                                                        jsonEncode(saveConsent),
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
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(
                              color: Color.fromRGBO(233, 233, 233, 1),
                              thickness: 0.5, // 두께를 1로 설정
                              height: 0, // 높이를 줄임
                            ),
                          );
                        }
                        return Container();
                      }),
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget consentSearchTypeWidget(int groupValue, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () => onChanged(1),
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Radio<int>(
                  value: 1,
                  visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                  // 크기 조절
                  groupValue: groupValue,
                  onChanged: (int? value) => onChanged(value!),
                  activeColor: groupValue == 1
                      ? Color.fromRGBO(115, 140, 241, 1)
                      : Color.fromRGBO(177, 177, 177, 1),
                ),
                Text(
                  "전체",
                  style: TextStyle(
                      color: groupValue == 1
                          ? Color.fromRGBO(115, 140, 241, 1)
                          : null),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        InkWell(
          onTap: () => onChanged(2),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Radio<int>(
                  value: 2,
                  visualDensity: VisualDensity(vertical: 1, horizontal: -4),
                  // 크기 조절 ** 라디오나 체크박스의 마진등을 조절시 사용
                  groupValue: groupValue,
                  onChanged: (int? value) => onChanged(value!),
                  activeColor: Color.fromRGBO(115, 140, 241, 1),
                ),
                Text(
                  "입원",
                  style: TextStyle(
                      color: groupValue == 2
                          ? Color.fromRGBO(115, 140, 241, 1)
                          : null),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        InkWell(
          onTap: () => onChanged(3),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Radio<int>(
                  value: 3,
                  visualDensity: VisualDensity(vertical: 1, horizontal: -4),
                  // 크기 조절
                  groupValue: groupValue,
                  onChanged: (int? value) => onChanged(value!),
                  activeColor: groupValue == 3
                      ? Color.fromRGBO(115, 140, 241, 1)
                      : Color.fromRGBO(177, 177, 177, 1),
                ),
                Text(
                  "외래",
                  style: TextStyle(
                      color: groupValue == 3
                          ? Color.fromRGBO(115, 140, 241, 1)
                          : null),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        InkWell(
          onTap: () => onChanged(4),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Radio<int>(
                  value: 4,
                  visualDensity: VisualDensity(vertical: 1, horizontal: -4),
                  // 크기 조절
                  groupValue: groupValue,
                  onChanged: (int? value) => onChanged(value!),
                  activeColor: groupValue == 4
                      ? Color.fromRGBO(115, 140, 241, 1)
                      : Color.fromRGBO(177, 177, 177, 1),
                ),
                Text(
                  "응급",
                  style: TextStyle(
                      color: groupValue == 4
                          ? Color.fromRGBO(115, 140, 241, 1)
                          : null),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String setSaveTypeString({required String consentType}) {
    String saveType = '완료';
    if (consentType == 'TEMP') {
      saveType = '임시';
    }
    return saveType;
  }
}
