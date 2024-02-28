import 'dart:async';

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

    if (widget.categoryCode == 'O' || widget.categoryCode == 'E') {
      dateText = '진료일';
    } else if (widget.categoryCode == 'S') {
      docText = '수술의';
      dateText = '수술일';
      alertText = '수술명';
    } else if (widget.categoryCode == 'INS') {
      dateText = '검사일';
      alertText = '검사명';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
      // by sangU 2024/01/16
      alignment: Alignment.centerLeft,
      width: 400,
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
      child: Obx(() =>
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  // 환자 정보 위젯 검색 / 환자 검색
                  children: [
                    const Text("환자 정보"),
                    SizedBox(
                      width: 10,
                    ),
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
                      ),
                      label: Text(
                        'AI',
                        style: TextStyle(
                          fontSize: 14, // 텍스트 크기 조정
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8), // 버튼 패딩 조정
                      ),
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
                          _textFieldEditingController.text = barcodeScanResult;
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
                        primary: Colors.white, // 버튼 배경 색상
                        onPrimary: Color.fromRGBO(
                            103, 80, 164, 1), // 버튼 전경 색상 (텍스트 및 아이콘)
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8), // 버튼 패딩
                      ),
                    )
                  ],
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
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1, // 테두리 두께 줄임
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 1), // 내부 패딩 조정
                          ),
                          style: TextStyle(
                            fontSize: 10, // 입력 텍스트의 글자 크기 조정
                          ),
                        ),
                      );
                    }),
              ],
            ),
            const Divider(thickness: 2, height: 20, color: Colors.grey),
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
                            future: _patientSearchValueController
                                .getInPatientInfo(),
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
                                  return ListView.builder(
                                      itemCount: data.length,
                                      itemBuilder: (context, index) {
                                        isSelected = index == selectedIdx;

                                        // print("@@isSelected$index");
                                        //print("@@selectedIdx$selectedIdx");

                                        // 각 환자 정보를 Card로 표시합니다.
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              // print('isVisible true');
                                              selectedIdx = index;
                                              _visibleController
                                                  .toggleVisiblity(
                                                      true); // true
                                              Map<String, dynamic>
                                                  patientDetail = data[index];
                                              // print('선택한 환자 상세정보 : ${patientDetail.toString()}');
                                              _patientDetailController
                                                  .updatePatientInfo(
                                                      patientInfo:
                                                          patientDetail);

                                              // 2024/02/28 by sangU02 작성동의서로 인해 클릭시 다시 빌드

                                              // isVisible =
                                              // true; // 처방동의서 등이 보이도록
                                              // print("@@Selected index: $selectedIdx");
                                            });

                                            // 클릭한 카드의 데이터에 접근
                                            var selectedData = data[index];

                                            // 콘솔에 선택된 데이터 출력 (또는 다른 처리)
                                            // print("@@클릭한 카드 데이터: $selectedData");
                                            // print("@@클릭한 환자이름: ${selectedData['PatientName']}");
                                          },
                                          //카드색깔 변경
                                          child: Card(
                                            color: isSelected

                                                ///클릭했을 때 카드 색깔 변경
                                                ? Color.fromRGBO(
                                                    248, 249, 255, 1)

                                                ///선택 안했을 때 카드 색깔 변경
                                                ///기본 flutter 카드 색상
                                                : Color.fromRGBO(
                                                    249, 249, 249, 1),
                                            elevation: isSelected ? 10 : 2,
                                            // 선택된 카드에 더 높은 elevation
                                            shadowColor: isSelected
                                                ? Colors.black12
                                                : Colors.white,
                                            shape: isSelected
                                                ? RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    side: BorderSide(
                                                        color: Colors
                                                            .blue.shade300,
                                                        width: 2))
                                                : RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                            //카드 사이 사이 간격
                                            margin: const EdgeInsets.all(5.0),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '${data[index]['PatientName']}',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      patientConsentInfo(
                                                          consentType: data[
                                                                  index]
                                                              ['PatientCode']),
                                                      patientConsentInfo(
                                                          consentType: data[
                                                                  index]
                                                              ['ClnDeptCode']),
                                                      Expanded(
                                                        child: SizedBox(
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                patientConsentInfo(
                                                                    consentType:
                                                                        '임시',
                                                                    consentNum:
                                                                        '3'),
                                                                patientConsentInfo(
                                                                    consentType:
                                                                        '완료',
                                                                    consentNum:
                                                                        '4')
                                                              ]),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle
                                                                  .of(context)
                                                              .style,
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                                text: '병동/병실: ',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700)),
                                                            TextSpan(
                                                                text:
                                                                    '${data[index]['Ward']}/${data[index]['Room']}'),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 80,
                                                      ),
                                                      RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle
                                                                  .of(context)
                                                              .style,
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                                text: '나이/성별: ',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700)),
                                                            TextSpan(
                                                                text:
                                                                    '${data[index]['Age']} / ${data[index]['Sex']}'),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Row(
                                                    children: [
                                                      RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle
                                                                  .of(context)
                                                              .style,
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                                text:
                                                                    '${dateText}: ',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700)),
                                                            TextSpan(
                                                                text:
                                                                    '${data[index]['AdmissionDate']}'),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 72,
                                                      ),
                                                      RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle
                                                                  .of(context)
                                                              .style,
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                                text:
                                                                    '$docText: ',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700)),
                                                            TextSpan(
                                                                text:
                                                                    '${data[index]['ChargeName']}'),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style,
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text:
                                                                '$alertText: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700)),
                                                        TextSpan(
                                                            text:
                                                                '${data[index]['DiagName']}'),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
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
                              if (snapshot.data != null &&
                                  snapshot.data != '') {
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
                              return ListView.builder(
                                  itemCount: searchList.length,
                                  itemBuilder: (context, index) {
                                    bool isSelected = index == selectedIdx;

                                    // print("@@isSelected$index");
                                    //print("@@selectedIdx$selectedIdx");

                                    // 각 환자 정보를 Card로 표시합니다.
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          // print('isVisible true');
                                          selectedIdx = index;
                                          _visibleController
                                              .toggleVisiblity(true); // true
                                          Map<String, dynamic> patientDetail =
                                              searchList[index];
                                          // print('선택한 환자 상세정보 : ${patientDetail.toString()}');
                                          // 2023/02/27 환자 상세정보 상태관리
                                          _patientDetailController
                                              .updatePatientInfo(
                                                  patientInfo: patientDetail);

                                          // isVisible =
                                          // true; // 처방동의서 등이 보이도록
                                          // print("@@Selected index: $selectedIdx");
                                        });

                                        // 클릭한 카드의 데이터에 접근
                                        var selectedData = searchList[index];

                                        // 콘솔에 선택된 데이터 출력 (또는 다른 처리)
                                        // print("@@클릭한 카드 데이터: $selectedData");
                                        // print("@@클릭한 환자이름: ${selectedData['PatientName']}");
                                      },
                                      //카드색깔 변경
                                      child: Card(
                                        color: isSelected

                                            ///클릭했을 때 카드 색깔 변경
                                            ? Color.fromRGBO(248, 249, 255, 1)

                                            ///선택 안했을 때 카드 색깔 변경
                                            ///기본 flutter 카드 색상
                                            : Color.fromRGBO(249, 249, 249, 1),
                                        elevation: isSelected ? 10 : 2,
                                        // 선택된 카드에 더 높은 elevation
                                        shadowColor: isSelected
                                            ? Colors.black12
                                            : Colors.white,
                                        shape: isSelected
                                            ? RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                side: BorderSide(
                                                    color: Colors.blue.shade300,
                                                    width: 2))
                                            : RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                        //카드 사이 사이 간격
                                        margin: const EdgeInsets.all(5.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    '${searchList[index]['PatientName']}',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  patientConsentInfo(
                                                      consentType:
                                                          searchList[index]
                                                              ['PatientCode']),
                                                  patientConsentInfo(
                                                      consentType:
                                                          searchList[index]
                                                              ['ClnDeptCode']),
                                                  Expanded(
                                                    child: SizedBox(
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            patientConsentInfo(
                                                                consentType:
                                                                    '임시',
                                                                consentNum:
                                                                    '3'),
                                                            patientConsentInfo(
                                                                consentType:
                                                                    '완료',
                                                                consentNum: '4')
                                                          ]),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style,
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: '병동/병실: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700)),
                                                        TextSpan(
                                                            text:
                                                                '${searchList[index]['Ward']}/${searchList[index]['Room']}'),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 80,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style,
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: '나이/성별: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700)),
                                                        TextSpan(
                                                            text:
                                                                '${searchList[index]['Age']} / ${searchList[index]['Sex']}'),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Row(
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style,
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text:
                                                                '${dateText}: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700)),
                                                        TextSpan(
                                                            text:
                                                                '${searchList[index]['AdmissionDate']}'),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 72,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style,
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: '$docText: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700)),
                                                        TextSpan(
                                                            text:
                                                                '${searchList[index]['ChargeName']}'),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: DefaultTextStyle.of(
                                                          context)
                                                      .style,
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: '$alertText: ',
                                                        style: TextStyle(
                                                            color: Colors.grey
                                                                .shade700)),
                                                    TextSpan(
                                                        text:
                                                            '${searchList[index]['DiagName']}'),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            }))),
          ])),
    );
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/01/18 <br/>
   * @note 환자정보 맨 윗줄 위젯 <br/>
   * ex data : patientCode/ClnDeptCode/ConsentCount <br/>
   * consentNum은 알림 표시를 위해 서식에 대한 정보를 그릴때만 인자로 입력
   */
  Widget patientConsentInfo({required String consentType, String? consentNum}) {
    Color textColor = Colors.lightGreen;
    if (consentType == '임시') {
      textColor = Colors.grey;
    } else if (isNumeric(consentType)) {
      textColor = const Color.fromRGBO(115, 140, 241, 1);
    } else if (isEnglish(consentType)) {
      textColor = const Color.fromRGBO(53, 158, 255, 1);
    }
    // print('consent type : $consentType , ${isEnglish(consentType)}');
    return consentNum != null
        ? Stack(
            clipBehavior: Clip.none,
            // 요소가 범위 밖으로 나가도 나타
            children: [
              // 다른 위젯들을 추가
              Container(
                height: 25,
                margin: isEnglish(consentType)
                    ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
                    : const EdgeInsets.fromLTRB(10, 0, 0, 0),
                // 과코드일때만 위젯의 왼쪽 마진을 줄인다.
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.5)),
                child: Text(
                  consentType,
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
              ),

              // 알림 아이콘
              Positioned(
                top: -11.0,
                right: -11.0,
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red[200], // 알림 아이콘의 배경색
                  ),
                  child: Text(
                    consentNum!,
                    // 알림 개수
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          )
        : Container(
            height: 25,
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.5)),
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
