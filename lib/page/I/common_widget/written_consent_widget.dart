import 'package:consent5/WebService/httpService.dart';
import 'package:consent5/getx_controller/patient_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WriteConsentWidget extends StatefulWidget {
  final bool isVisible;
  final bool isVerticalMode;
  final Map<dynamic, dynamic> patientDetail;

  const WriteConsentWidget(
      {super.key,
      required this.isVisible,
      required this.isVerticalMode,
      required this.patientDetail});
  @override
  State<WriteConsentWidget> createState() => _WriteConsentWidgetState();
}

class _WriteConsentWidgetState extends State<WriteConsentWidget> {
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
  }

  void reloadData() {
    setState(() {
      unfinishedInfoFuture = getUnfinishedInfo(); // 데이터 재로드
    });
  }

  @override
  Widget build(BuildContext context) {
    patientDetail = widget.patientDetail;

    // 유저정보와 detail 정보를 가져옴
    Map<dynamic, dynamic> detail = patientDetail;

    //
    Map<dynamic, dynamic> patientInfo = detail['detail'];

    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        alignment: Alignment.centerLeft,
        height: 250,
        width: widget.isVerticalMode ? 380 : 350,
        margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
        // color: Colors.blue,
        decoration: BoxDecoration(
          // color: Colors.blue, // 컨테이너의 배경색
          borderRadius: BorderRadius.circular(10.0),
          // 테두리의 둥근 정도
          border: Border.all(
            color: Colors.grey, // 테두리 색상
            width: 1.0, // 테두리 두께
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("작성 동의서"),
          const Divider(thickness: 2, height: 20, color: Colors.grey),
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
                                        //체크박스 갯수에 따라서 분기 처리
                                        if (selectedData.length <= 1) {
                                          // print(
                                          //     '현재 클릭한 동의서 명 --- > ${data[index]['FormName']}');
                                        } else {
                                          // print(
                                          //     '체크박스 체크된 데이터 --- > ${selectedData.length}');
                                        }
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 0, 5, 0),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6), // 가로 세로 패딩 조절
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
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
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
                                color: Colors.grey,
                                thickness: 1, // 두께를 1로 설정
                                height: 30, // 높이를 줄임
                              ),
                            );
                          } else {
                            return const Text("조회된 자료가 없습니다.");
                          }
                        } else {
                          return const Text("조회된 자료가 없습니다.");
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
        return Colors.pink.shade100;
      case '완료':
        return Colors.blue;
      case '구두':
        return Colors.red;
      case '진행':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  /// @author sangU02 <br/>
  /// @since 2023/01/06 <br/>
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
