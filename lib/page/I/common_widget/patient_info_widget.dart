import 'dart:async';
import 'dart:math';

import 'package:consent5/WebService/httpService.dart';
import 'package:consent5/getx_controller/patient_detail_controller.dart';
import 'package:consent5/getx_controller/patient_search_value_controller.dart';
import 'package:consent5/getx_controller/visible_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PatientInfoWidget extends StatefulWidget {
  // 해당 카테고리 코드에 따라 http 요청 메소드가 바뀐다.
  final String categoryCode;
  final VisibleController visibleController;
  final PatientSearchValueController patientSearchValueController;
  final PatientDetailController patientDetailController;

  const PatientInfoWidget(
      {super.key,
      required this.categoryCode,
      required this.visibleController,
      required this.patientSearchValueController,
      required this.patientDetailController});

  @override
  State<PatientInfoWidget> createState() => _PatientInfoWidgetState();
}

class _PatientInfoWidgetState extends State<PatientInfoWidget> {
  // 2024/02/14(상태) 처방동의서 값의 변경을 전달할 용도
  late VisibleController _visibleController;
  late PatientSearchValueController _patientSearchValueController;
  late PatientDetailController _patientDetailController;

  //controller for textField value
  final _textFieldEditingController = TextEditingController();

  //controller for patient search textField
  final _textController = StreamController<String>.broadcast();

  // speech-to-text variable
  SpeechToText _speechToText = SpeechToText(); // STT 라이브러리 클래스
  bool _speechEnabled = false; // 스피치가 가능한지
  String _speechWords = ''; // 사용자가 말한 언어를 저장하는 변수
  bool _isListening = false; // 스피치중인지 판단하는데 사용되는 변수

  int? selectedIdx; // 선택된 환자의 index를 파악할 때 사용되는 변수

  String dateText = "입원일";
  String docText = "지정의";
  String alertText = "진단명";

  //2023/01/16 by sangU02 PatientList for make Future<T> or list.where();
  List<dynamic> patientsList = [];

  @override
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  @override
  void _startListening() async {
    setState(() {
      _textFieldEditingController.text = '';
      _textController.add('');
      _isListening = true; // Set the listening flag to true
    });

    await _speechToText.listen(
      onResult: _onSpeechResult,
      onSoundLevelChange: (level) {
        // You can use this callback to get the sound level during speech
        // print('Sound Level: $level');
      },
    );
  }

  @override
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false; // Set the listening flag to false
    });
  }

  @override
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      // print('결과 도출');
      _speechWords = result.recognizedWords;
      // print('결과 : $_speechWords');
      _textFieldEditingController.text =
          _speechWords.split(' ')[0]; // Set the text field value
      _isListening = false;
      _textController.add(_textFieldEditingController.text);
    });
    // print('녹음종료 $_isListening');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initSpeech();

    // 부모 위젯에게 받은 상태관리 컨트롤러를 해당 위젯의 컨트롤러로 초기화
    // 컨트롤러 의존성 주입
    _visibleController = widget.visibleController;
    _patientSearchValueController = widget.patientSearchValueController;
    _patientDetailController = widget.patientDetailController;
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected = false;

    late Future<List<dynamic>>
        patientInfoFuture; // 카테고리에 따른 환자 값을 가지는 변수(입원, 외래..)

    Future<List<dynamic>> emerPatientInfo =
        _patientSearchValueController.getEmerPatientInfo();
    emerPatientInfo.then((value) => print('아아아아아아아아아ㅏ $value'));
    Future<List<dynamic>> outPatientInfo =
        _patientSearchValueController.getOutPatientInfo();
    outPatientInfo.then((value) => print('아아아아아아ㅏ외래 $value'));

    switch (widget.categoryCode) {
      case 'I':
        patientInfoFuture = _patientSearchValueController.getInPatientInfo();
        break;

      case 'O':
        patientInfoFuture = _patientSearchValueController.getOutPatientInfo();
        dateText = '진료일';
        break;

      case 'E':
        patientInfoFuture = _patientSearchValueController.getEmerPatientInfo();
        dateText = '입원일';
        docText = '응급의';
        break;

      case 'S':
        patientInfoFuture = _patientSearchValueController.getInPatientInfo();
        docText = '수술의';
        dateText = '수술일';
        alertText = '수술명';
        break;

      case 'INS':
        patientInfoFuture = _patientSearchValueController.getInPatientInfo();
        dateText = '검사일';
        alertText = '검사명';
        break;

      default:
        patientInfoFuture = _patientSearchValueController.getInPatientInfo();
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
      // by sangU 2024/01/16
      alignment: Alignment.centerLeft,
      width: 400,
      // 2024/02/29 by sangU02 기존 top margin = 10 / bottom margin = 5
      margin: const EdgeInsets.fromLTRB(5, 15, 5, 10),
      // color: Colors.blue,
      decoration: BoxDecoration(
          // color: Colors.blue, // 컨테이너의 배경색
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              spreadRadius: 3,
              blurRadius: 30,
            )
          ]
          // 테두리의 둥근 정도
          // border: Border.all(
          //   color: Colors.grey, // 테두리 색상
          //   width: 1.0, // 테두리 두께
          // ),
          ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // 환자 정보 위젯 검색 / 환자 검색
                children: [
                  const Text(
                    "환자 정보",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_speechToText.isNotListening) {
                            // 만약 현재 speech-to-text가 중단된 상태라면 시작
                            print('녹음시작');
                            _startListening();
                          } else {
                            print('녹음 중지');
                            // 만약 현재 speech-to-text가 작동 중이라면 중지
                            _stopListening();
                          }
                        },
                        icon: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          size: 20, // 아이콘 크기 조정
                          color: _isListening
                              ? Color.fromRGBO(255, 255, 255, 1)
                              : Color.fromRGBO(115, 140, 243, 1),
                        ),
                        label: Text(
                          'AI',
                          style: TextStyle(
                              fontSize: 14,
                              color: _isListening
                                  ? Color.fromRGBO(255, 255, 255, 1)
                                  : Color.fromRGBO(
                                      115, 140, 243, 1) // 텍스트 크기 조정
                              ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8), // 버튼 패딩 조정
                          backgroundColor: _isListening
                              ? Color.fromRGBO(115, 140, 243, 1)
                              : Color.fromRGBO(255, 255, 255, 1),
                          shape: RoundedRectangleBorder(
                            // 여기서 수정되었습니다.
                            borderRadius: BorderRadius.circular(30.0),
                            // 테두리의 둥근 정도를 설정
                            side: BorderSide(
                              color: _isListening
                                  ? Color.fromRGBO(255, 255, 255, 1)
                                  : Color.fromRGBO(115, 140, 243, 1), // 테두리 색상
                              width: 0.5, // 테두리 두께
                            ), // 버튼 패딩
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                          // 바코드 스캔 버튼
                          onPressed: () async {
                            // print('스캐너 클릭');
                            _textFieldEditingController.text = '';
                            _textController.add('');

                            String barcodeScanResult =
                                await FlutterBarcodeScanner.scanBarcode(
                              "#004297",
                              "Cancel",
                              false,
                              ScanMode.BARCODE,
                            );

                            if (barcodeScanResult != '-1') {
                              // print('@@스캔 결과 : $barcodeScanResult}');
                              _textFieldEditingController.text =
                                  barcodeScanResult;
                              _textController.add(barcodeScanResult);
                            } else {
                              print('사용자가 취소했습니다.');
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // 아이콘과 텍스트를 가까이 배치
                            children: [
                              Icon(
                                Icons.bar_chart_outlined,
                                size: 20, // 아이콘 크기
                              ),
                              SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                              Text(
                                '바코드',
                                style: TextStyle(
                                  fontSize: 14, // 텍스트 크기
                                ),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            // 버튼 배경 색상
                            onPrimary: Color.fromRGBO(115, 140, 243, 1)
                            // 텍스트 크기 조정
                            ,
                            // 버튼 전경 색상 (텍스트 및 아이콘)
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              // 여기서 수정되었습니다.
                              borderRadius: BorderRadius.circular(30.0),
                              // 테두리의 둥근 정도를 설정
                              side: BorderSide(
                                color:
                                    Color.fromRGBO(115, 140, 243, 1), // 테두리 색상
                                width: 0.5, // 테두리 두께
                              ), // 버튼 패딩
                            ),
                          ))
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            StreamBuilder<String>(
                // 환자 정보 검색창, 입력값 마다 stream을 통해 지속적인 검색기능 실현
                stream: _textController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // _textFieldEditingController.text = snapshot!.data.toString(); 숫자로 할때 적용
                  }
                  return SizedBox(
                    height: 40,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _textFieldEditingController,
                        onChanged: (value) {
                          _textController.add(value);
                        },
                        onTap: () {
                          selectedIdx = -1;
                          // 기존 작성동의서나 처방동의서가 보이면 안됨
                          print("isvisible false 이벤트 ");
                          // 나머지요소들 안보이게
                          _visibleController.toggleVisiblity(false);

                          // 선택된 환자 디자인 해제
                          setState(() {
                            isSelected = false;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: '환자명을 입력하세요',
                          labelStyle: TextStyle(
                              fontSize: 10, // 글자 크기 조정
                              color: Color.fromRGBO(233, 233, 233, 1)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, // 테두리 두께 줄임
                                color: Color.fromRGBO(233, 233, 233, 1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, // 테두리 두께 줄임
                                color: Color.fromRGBO(233, 233, 233, 1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, // 테두리 두께 줄임
                                color: Color.fromRGBO(233, 233, 233, 1)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 1), // 내부 패딩 조정
                        ),
                        style: TextStyle(
                            fontSize: 10, // 입력 텍스트의 글자 크기 조정
                            color: Colors.black87),
                      ),
                    ),
                  );
                }),
            SizedBox(
              height: 10,
            )
          ],
        ),
        const Divider(
            thickness: 0.5, height: 0, color: Color.fromRGBO(233, 233, 233, 1)),
        Expanded(
            child: RefreshIndicator(
                // by sangU02 2024/1/5
                onRefresh: () async {
                  // print('새로고침');
                  setState(() {});
                },
                //2024/01/16 by sangU02 입력값에 따른 정보 교체
                child: patientsList.length == 0
                    ? FutureBuilder(
                        future: patientInfoFuture,
                        builder: (context, snapshot) {
                          // print('future builder');
                          var data = snapshot.data;
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            patientsList =
                                data!; // connection이 waiting이 아닌이상 null일수가 없는 변수
                            // print(
                            //     '-------to data length : ${data!.length}------------------');
                            selectedIdx;

                            try {
                              return patientDataToCategoryCode(
                                  categoryCode: widget.categoryCode,
                                  patientData: data);
                            } catch (e) {
                              print("예외 발생 : $e");
                              return Center(
                                child: Text('데이터가 없습니다.'),
                              );
                            }
                          }
                        })
                    : // 데이터가 존재할때는 등록된 변수를 통해 해당 값안에서 스트림의 값이 포함된 것만 위젯을 등록한다.
                    StreamBuilder(
                        stream: _textController.stream,
                        builder: (context, snapshot) {
                          // print('stream builder ');
                          var searchList = [];
                          if (snapshot.data != null && snapshot.data != '') {
                            // 환자명이냐, 환자번호이냐를 한글,영어냐, 숫자이냐로 구분
                            //  searchList = patientsList
                            //     .where((element) => element['PatientName'].contains(snapshot.data!))
                            //     .toList();
                            String searchText = snapshot.data!;

                            // 입력값이 숫자인 경우
                            if (isNumeric(searchText)) {
                              searchList = patientsList
                                  .where((element) => element['PatientCode']
                                      .contains(searchText))
                                  .toList();
                            }
                            // 입력값이 영어인 경우
                            else if (isEnglish(searchText)) {
                              searchList = patientsList
                                  .where((element) => element['PatientName']
                                      .toLowerCase()
                                      .contains(searchText.toLowerCase()))
                                  .toList();
                            }
                            // 입력값이 한글인 경우
                            else {
                              searchList = patientsList
                                  .where((element) => element['PatientName']
                                      .contains(searchText))
                                  .toList();
                            }
                          } else {
                            // 검색창에 아무런 입력도 없을경우
                            // print('else');
                            searchList = patientsList;
                          }
                          // print('@@searchList 내용 : $searchList');
                          return patientDataToCategoryCode(
                              categoryCode: widget.categoryCode,
                              patientData: searchList);
                        }))),
      ]),
    );
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/01/18 <br/>
   * @note 환자정보 맨 아래줄 위젯 <br/>
   * ex data : patientCode/ClnDeptCode/ConsentCount <br/>
   * consentNum은 알림 표시를 위해 서식에 대한 정보를 그릴때만 인자로 입력
   */
  Widget patientConsentInfo({required String consentType, String? consentNum}) {
    Color textColor = Color.fromRGBO(255, 255, 255, 1); // 완료
    if (isNumeric(consentType)) {
      // 환자 번호
      textColor = const Color.fromRGBO(115, 140, 241, 1);
    } else if (isEnglish(consentType)) {
      // 환자 진료과
      textColor = const Color.fromRGBO(53, 158, 255, 1);
    }

    Color consentBackColor = Color.fromRGBO(115, 140, 243, 1);
    switch (consentType) {
      case '진행':
        consentBackColor = Color.fromRGBO(81, 203, 188, 1);
        break;
      case '완료':
        consentBackColor = Color.fromRGBO(167, 129, 248, 1);
        break;
      case '응급':
        consentBackColor = Color.fromRGBO(235, 133, 133, 1);
        break;
      case '구두':
        consentBackColor = Color.fromRGBO(253, 170, 46, 1);
        break;
    }
    // print('consent type : $consentType , ${isEnglish(consentType)}');
    return consentNum != null
        ? Container(
            height: 30,
            margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
            // 과코드일때만 위젯의 왼쪽 마진을 줄인다.
            padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
            decoration: BoxDecoration(
                color: consentBackColor,
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                Text(
                  consentType,
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
                SizedBox(
                  width: 4,
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      consentNum,
                      style: TextStyle(fontSize: 10, color: consentBackColor),
                    ),
                  ),
                )
              ],
            ),
          )
        : Container(
            // 환자번호와 환자 진료과코드를 나타내는 위젯
            height: 30,
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
                color: isNumeric(consentType)
                    ? Color.fromRGBO(240, 242, 255, 1)
                    : Color.fromRGBO(236, 246, 255, 1),
                borderRadius: BorderRadius.circular(15)),
            child: Text(
              consentType,
              style: TextStyle(color: textColor),
            ),
          );
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/2/14 <br/>
   * @apinote 외래환자 정보 요청 메소드
   */
  Future<List<dynamic>> getOutpatientInfo(
      {required String clnDate,
      required String docName,
      required String dept}) async {
    Future<List<dynamic>> outPatientFuture = makeRequest_outPatient(
        methodName: "getOutPatientSearch",
        userId: '01',
        userPw: '1234',
        url: 'http://59.11.2.207:50089/HospitalSvc.aspx',
        clnDate: clnDate,
        docName: docName,
        dept: dept);

    List<dynamic> printReq = await outPatientFuture;

    return printReq;
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/03/26 <br/>
   * @note 카테고리별 환자 리스트 위젯 <br/>
   * 인자는 카테고리 코드와 환자 데이터리스트의 인덱스 VO(Map<String,dynamic>
   */
  Widget patientDataToCategoryCode(
      {required String categoryCode, required List<dynamic> patientData}) {
    if (categoryCode == 'I') {
      return ListView.builder(
        itemCount: patientData.length,
        itemBuilder: (context, index) {
          bool isSelected = index == selectedIdx;
          return InkWell(
            onTap: () {
              setState(() {
                selectedIdx = index;
                _visibleController.toggleVisiblity(true);
                Map<String, dynamic> patientDetail = patientData[index];
                _patientDetailController.updatePatientInfo(
                    patientInfo: patientDetail);
              });

              // 클릭한 카드의 데이터에 접근
              var selectedData = patientData[index];
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromRGBO(250, 251, 255, 1)
                    : Colors.white,
                border: Border(
                  bottom: isSelected
                      ? BorderSide(
                          width: 1.0, color: Color.fromRGBO(115, 140, 243, 1))
                      : const BorderSide(
                          width: 0.5,
                          color: Color.fromRGBO(233, 233, 233, 1),
                        ),
                  top: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                  left: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                  right: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${patientData[index]['PatientName']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        patientConsentInfo(
                            consentType: patientData[index]['PatientCode']),
                        patientConsentInfo(
                            consentType: patientData[index]['ClnDeptCode']),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '병동/병실: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text:
                                    '${patientData[index]['Ward']}/${patientData[index]['Room']}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 80),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '나이/성별: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text:
                                    '${patientData[index]['Age']} / ${patientData[index]['Sex']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '${dateText}: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['AdmissionDate']}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 72),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '$docText: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['ChargeName']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: '$alertText: ',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          TextSpan(
                            text: '${patientData[index]['DiagName']}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          patientConsentInfo(
                              consentType: '임시', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '완료', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '응급', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '구두', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '진행', consentNum: '3'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else if (categoryCode == 'O') {
      // 외래 환자
      return ListView.builder(
        itemCount: patientData.length,
        itemBuilder: (context, index) {
          bool isSelected = index == selectedIdx;
          return InkWell(
            onTap: () {
              setState(() {
                selectedIdx = index;
                _visibleController.toggleVisiblity(true);
                Map<String, dynamic> patientDetail = patientData[index];
                _patientDetailController.updatePatientInfo(
                    patientInfo: patientDetail);
              });

              // 클릭한 카드의 데이터에 접근
              var selectedData = patientData[index];
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromRGBO(250, 251, 255, 1)
                    : Colors.white,
                border: Border(
                  bottom: isSelected
                      ? BorderSide(
                          width: 1.0, color: Color.fromRGBO(115, 140, 243, 1))
                      : const BorderSide(
                          width: 0.5,
                          color: Color.fromRGBO(233, 233, 233, 1),
                        ),
                  top: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                  left: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                  right: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${patientData[index]['PatientName']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        patientConsentInfo(
                            consentType: patientData[index]['PatientCode']),
                        patientConsentInfo(
                            consentType: patientData[index]['ClnDeptCode']),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '진단명: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['DiagName']}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 73),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '나이/성별: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text:
                                    '${patientData[index]['Age']} / ${patientData[index]['Sex']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '${dateText}: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['ClinicalDate']}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 72),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '$docText: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['ChargeName']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: '진료과: ',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          TextSpan(
                            text: '외과',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          patientConsentInfo(
                              consentType: '임시', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '완료', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '응급', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '구두', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '진행', consentNum: '3'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else if (categoryCode == 'E') {
      // 응급 환자
      return ListView.builder(
        itemCount: patientData.length,
        itemBuilder: (context, index) {
          bool isSelected = index == selectedIdx;
          return InkWell(
            onTap: () {
              setState(() {
                selectedIdx = index;
                _visibleController.toggleVisiblity(true);
                Map<String, dynamic> patientDetail = patientData[index];
                _patientDetailController.updatePatientInfo(
                    patientInfo: patientDetail);
              });

              // 클릭한 카드의 데이터에 접근
              var selectedData = patientData[index];
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromRGBO(250, 251, 255, 1)
                    : Colors.white,
                border: Border(
                  bottom: isSelected
                      ? BorderSide(
                          width: 1.0, color: Color.fromRGBO(115, 140, 243, 1))
                      : const BorderSide(
                          width: 0.5,
                          color: Color.fromRGBO(233, 233, 233, 1),
                        ),
                  top: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                  left: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                  right: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${patientData[index]['PatientName']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        patientConsentInfo(
                            consentType: patientData[index]['PatientCode']),
                        patientConsentInfo(
                            consentType: patientData[index]['ClnDeptCode']),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '병상번호: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: 'ER - ${patientData[index]['Bedno']}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 87),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '나이/성별: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text:
                                    '${patientData[index]['Age']} / ${patientData[index]['Sex']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '${dateText}: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['ClinicalDate']}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 72),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '$docText: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['ChargeName']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: '$alertText: ',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          TextSpan(
                            text: '${patientData[index]['DiagName']}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          patientConsentInfo(
                              consentType: '임시', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '완료', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '응급', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '구두', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '진행', consentNum: '3'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else if (categoryCode == 'S') {
      // 수술 환자
      return ListView.builder(
        itemCount: patientData.length,
        itemBuilder: (context, index) {
          bool isSelected = index == selectedIdx;
          return InkWell(
            onTap: () {
              setState(() {
                selectedIdx = index;
                _visibleController.toggleVisiblity(true);
                Map<String, dynamic> patientDetail = patientData[index];
                _patientDetailController.updatePatientInfo(
                    patientInfo: patientDetail);
              });

              // 클릭한 카드의 데이터에 접근
              var selectedData = patientData[index];
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromRGBO(250, 251, 255, 1)
                    : Colors.white,
                border: Border(
                  bottom: isSelected
                      ? BorderSide(
                          width: 1.0, color: Color.fromRGBO(115, 140, 243, 1))
                      : const BorderSide(
                          width: 0.5,
                          color: Color.fromRGBO(233, 233, 233, 1),
                        ),
                  top: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                  left: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                  right: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${patientData[index]['PatientName']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        patientConsentInfo(
                            consentType: patientData[index]['PatientCode']),
                        patientConsentInfo(
                            consentType: patientData[index]['ClnDeptCode']),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '병동/병실: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text:
                                    '${patientData[index]['Ward']}/${patientData[index]['Room']}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 80),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '나이/성별: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text:
                                    '${patientData[index]['Age']} / ${patientData[index]['Sex']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '${dateText}: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['AdmissionDate']}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 72),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '$docText: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['ChargeName']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: '$alertText: ',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          TextSpan(
                            text: '${patientData[index]['DiagName']}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          patientConsentInfo(
                              consentType: '임시', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '완료', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '응급', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '구두', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '진행', consentNum: '3'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else if (categoryCode == 'INS') {
      // 검사실 환자
      return ListView.builder(
        itemCount: patientData.length,
        itemBuilder: (context, index) {
          bool isSelected = index == selectedIdx;
          return InkWell(
            onTap: () {
              setState(() {
                selectedIdx = index;
                _visibleController.toggleVisiblity(true);
                Map<String, dynamic> patientDetail = patientData[index];
                _patientDetailController.updatePatientInfo(
                    patientInfo: patientDetail);
              });

              // 클릭한 카드의 데이터에 접근
              var selectedData = patientData[index];
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromRGBO(250, 251, 255, 1)
                    : Colors.white,
                border: Border(
                  bottom: isSelected
                      ? BorderSide(
                          width: 1.0, color: Color.fromRGBO(115, 140, 243, 1))
                      : const BorderSide(
                          width: 0.5,
                          color: Color.fromRGBO(233, 233, 233, 1),
                        ),
                  top: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                  left: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                  right: BorderSide(
                      width: 1.0,
                      color: isSelected
                          ? const Color.fromRGBO(115, 140, 243, 1)
                          : Colors.transparent),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${patientData[index]['PatientName']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        patientConsentInfo(
                            consentType: patientData[index]['PatientCode']),
                        patientConsentInfo(
                            consentType: patientData[index]['ClnDeptCode']),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '병동/병실: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text:
                                    '${patientData[index]['Ward']}/${patientData[index]['Room']}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 80),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '나이/성별: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text:
                                    '${patientData[index]['Age']} / ${patientData[index]['Sex']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '${dateText}: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['AdmissionDate']}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 72),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '$docText: ',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextSpan(
                                text: '${patientData[index]['ChargeName']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: '$alertText: ',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          TextSpan(
                            text: '${patientData[index]['DiagName']}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          patientConsentInfo(
                              consentType: '임시', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '완료', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '응급', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '구두', consentNum: '3'),
                          patientConsentInfo(
                              consentType: '진행', consentNum: '3'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Text('잘못된 카테고리입니다.'),
      );
    }
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/01/16 <br/>
   * @note 문자열 데이터가 숫자값인지 판별
   */
  bool isNumeric(String str) {
    // 숫자 여부를 체크하는 함수
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/01/16 <br/>
   * @note 문자열 데이터가 영어값인지 판별
   */
  bool isEnglish(String str) {
    // 영어 여부를 체크하는 함수
    if (str == null) {
      return false;
    }
    return RegExp(r'^[a-zA-Z]+$').hasMatch(str);
  }
}
