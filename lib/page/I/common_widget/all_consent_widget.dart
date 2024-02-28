import 'dart:async';
import 'dart:convert';

import 'package:consent5/WebService/httpService.dart';
import 'package:consent5/getx_controller/consent_search_controller.dart';
import 'package:consent5/getx_controller/patient_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AllConsentWidget extends StatefulWidget {
  final bool isVerticalMode;
  final bool isVisible;
  final SearchWordController searchWordController;
  final PatientDetailController patientDetailController;

  const AllConsentWidget(
      {super.key,
      required this.isVerticalMode,
      required this.isVisible,
      required this.searchWordController,
      required this.patientDetailController});

  @override
  State<AllConsentWidget> createState() => _AllConsentWidgetState();
}

class _AllConsentWidgetState extends State<AllConsentWidget> {
  late ValueNotifier<List<bool>> checkboxValuesNotifier;
  late Future<List<dynamic>> unfinishedInfoFuture;
  List<Map<String, dynamic>> selectedData = [];
  int consentSearchType = 1;
  final _textFieldEditingController = TextEditingController();

  //controller for patient search textField
  final _textController = StreamController<String>.broadcast();

  // 상태관리 컨트롤러
  // 부모위젯에게서 인자로 컨트롤러를 초기화 후 받고, 해당 위젯의 initState함수에서 부모위젯에게 받은 객체로 초기화해주어야함
  late PatientDetailController _patientDetailController;
  late SearchWordController _searchWordController;

  // speech-to-text variable
  SpeechToText _speechToText = SpeechToText(); // STT 라이브러리 클래스
  bool _speechEnabled = false; // 스피치가 가능한지
  String _speechWords = ''; // 사용자가 말한 언어를 저장하는 변수
  bool _isListening = false; // 스피치중인지 판단하는데 사용되는 변수

  @override
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    //unfinishedInfoFuture = getUnfinishedInfo(); // 데이터 로드
    checkboxValuesNotifier = ValueNotifier([]);
    _searchWordController = widget.searchWordController;
    _patientDetailController = widget.patientDetailController;
  }

  @override
  Widget build(BuildContext context) {
    String searchWord = _searchWordController.searchWord.value;
    if (widget.isVerticalMode == false) {
      print('가로모드 / ${widget.isVerticalMode}');
    } else {
      print('세로모드 / ${widget.isVerticalMode}');
    }
    // Future<List<dynamic>> searchDocList = getSearchConsent('512');
    // searchDocList.then((value) => print('동의서 검색 통신 테스트 $value'));

    return widget.isVerticalMode
        ? consentWidgetVertical(
            consentSearchType: consentSearchType,
            isVerticalMode: widget.isVerticalMode,
            consentSearchWord: searchWord)
        : consentWidgetLandScape(
            consentSearchType: consentSearchType,
            isVerticalMode: widget.isVerticalMode,
            consentSearchWord: searchWord);
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/01/18 <br/>
   * @note 가로모드의 전체동의서 위젯 함수<br/>
   * @param OrientationBuilder에서 얻는 가로,세로모드에 대한 변수
   */
  Widget consentWidgetLandScape(
      {required bool isVerticalMode,
      required int consentSearchType,
      required String consentSearchWord}) {
    print("동의서 검색 타입 : $consentSearchType");

    const platform = MethodChannel('com.example.consent5/kmiPlugin');
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        margin: const EdgeInsets.fromLTRB(5, 0, 0, 5),
        // 하단 마진 30으로 설정
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(15, 10, 0, 0),
              child: const Text("동의서 검색",
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
            ),
            consentSearchTypeWidget(consentSearchType, (int newValue) {
              setState(() {
                this.consentSearchType = newValue;
              });
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment:
                          Alignment.centerRight, // Stack 내부의 정렬 방향을 오른쪽 중앙으로 설정
                      children: <Widget>[
                        TextField(
                          controller: _textFieldEditingController,
                          // 2024/02/28
                          // 검색했다가 값을 지워서 공백값이 되면 전체 동의서리스트를 가져오게함.
                          onChanged: (String value) {
                            if (value.length == 0) {
                              print('0이다!');
                              _searchWordController.updateSearchWord("");
                              setState(() {});
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.circular(5.0), // 경계선의 둥근 모서리 반경
                            ),
                            hintText: '검색',
                            hintStyle: TextStyle(fontSize: 12.0),
                            // 힌트 텍스트의 글자 크기
                            filled: true,
                            fillColor: Color.fromRGBO(243, 246, 255, 1),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0), // 패딩
                            // TextField의 오른쪽에 IconButton을 위한 공간 확보
                          ),
                          style: TextStyle(fontSize: 12.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: 0.0), // TextField와 버튼 사이의 간격 조정
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.blue,
                            border: Border.all(
                              color: Colors.white,
                              //width: 4.0,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              _searchWordController.updateSearchWord(
                                  _textFieldEditingController.text);
                              print('동의서 검색 클릭!');
                              setState(() {
                                //검색값 가지고 재빌드함
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // ElevatedButton.icon을 위한 Container 추가
                    margin:
                        EdgeInsets.only(left: 8.0), // 검색 버튼과 AI 버튼 사이의 간격 조정
                    child: ElevatedButton.icon(
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
                  ),
                ],
              ),
            ),
            const Divider(thickness: 2, height: 20, color: Colors.grey),
            Expanded(
                child: widget.isVisible
                    ? FutureBuilder(
                        future: consentSearchType.toString() == '1'
                            ? getSearchConsent(consentSearchWord)
                            : consentSearchType.toString() == '3'
                                ? getSearchBookMarkList(consentSearchWord)
                                : getSearchConsent(consentSearchWord),
                        builder: (context, snapshot) {
                          // print(
                          //     'future builder 진입 : 검색값 => $consentSearchWord');
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            var data = snapshot.data as List<dynamic>;
                            // print('동의서 정보 : ' + data.toString());

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
                                    return InkWell(
                                      onTap: () {
                                        print('서식 데이터용 ${data[index]}');
                                        // print('즐겨찾기 여부 : ${data[index]['UseYn']}');
                                        List<Map<String, String>> consents = [];
                                        if (selectedData.length == 0) {
                                          // 서식 하나 선택시
                                          consents = [
                                            {
                                              'FormCd': data[index]['FormCd']
                                                  .toString(),
                                              'FormId': data[index]['FormId']
                                                  .toString(),
                                              'FormVersion': data[index]
                                                      ['FormVersion']
                                                  .toString(),
                                              'FormRid': data[index]['FormRid']
                                                  .toString(),
                                              'FormGuid': data[index]
                                                      ['FormGuid']
                                                  .toString(),
                                              'FormName': data[index]
                                                      ['FormName']
                                                  .toString(),
                                            }
                                          ];
                                        } else {
                                          selectedData.forEach((data) {
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
                                          print(
                                              '다중서식 정보 : ${consents.toString()}');
                                        }

                                        Map<dynamic, dynamic> params =
                                            _patientDetailController
                                                .patientDetail.value;

                                        print(
                                            "JSON 변형값 consents : ${jsonEncode(consents)}, params : ${jsonEncode(params)}");

                                        // 신규 동의서 열기 / 파라미터 전달
                                        platform.invokeMethod('openEForm', {
                                          'type': 'new',
                                          'consents': jsonEncode(consents),
                                          'params': jsonEncode(params),
                                          // 'op': 'someOperation',
                                        });
                                        //체크박스 갯수에 따라서 분기 처리
                                        if (selectedData.length <= 1) {
                                          print(
                                              '현재 클릭한 동의서 명 --- > ${data[index]['FormName']}');
                                        } else {
                                          print(
                                              '체크박스 체크된 데이터 --- > ${selectedData.length}');
                                        }
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Checkbox(
                                            value: values[index],
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
                                                if (!selectedData.any(
                                                    (element) =>
                                                        element['FormName'] ==
                                                        item['FormName'])) {
                                                  selectedData.add(item);
                                                  print(
                                                      '데이터 추가 :: ${selectedData.toString()}');
                                                }
                                              } else {
                                                // 체크박스가 해제되었을 때, 리스트에서 해당 데이터 제거
                                                selectedData.removeWhere(
                                                    (element) =>
                                                        element['FormName'] ==
                                                        item['FormName']);
                                                print(
                                                    '데이터 삭제 :: ${selectedData.toString()}');
                                              }
                                            },
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Text(
                                                  data[index]['FormName'],
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                Spacer(),
                                                IconButton(
                                                    padding: EdgeInsets.only(
                                                        right: 30),
                                                    onPressed: () {
                                                      String formId =
                                                          data[index]['FormId']
                                                              .toString();
                                                      print("@@아이콘 버튼 클릭");
                                                      print(
                                                          "클릭한 서식 id : ${data[index]['FormId']}");
                                                      if (data[index]
                                                              ['UseYN'] ==
                                                          'Y') {
                                                        print('즐겨찾기 삭제 실행');
                                                        makeRequest_deleteBookmark(
                                                            methodName:
                                                                'DeleteBookMarkConsent',
                                                            userId: '01',
                                                            userPw: '1234',
                                                            url:
                                                                'http://59.11.2.207:50089/ConsentSvc.aspx',
                                                            formId: formId);
                                                      } else {
                                                        print('즐겨찾기 추가 실행');
                                                        makeRequest_insertBookmark(
                                                            methodName:
                                                                'InsertBookMarkConsent',
                                                            userId: '01',
                                                            userPw: '1234',
                                                            url:
                                                                'http://59.11.2.207:50089/ConsentSvc.aspx',
                                                            formId: formId);
                                                      }
                                                      // 즐겨찾기 추가 or 삭제 후에는 라이프싸이클을 다시 돌린다.
                                                      setState(() {});
                                                    },
                                                    // UseYN값에 따라 아이콘 모양 결정
                                                    icon: (data[index]
                                                                ['UseYN'] ==
                                                            'Y')
                                                        ? Icon(
                                                            Icons.star,
                                                            color:
                                                                Colors.yellow,
                                                          )
                                                        : Icon(
                                                            Icons.star_border))
                                              ],
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
                                height: 0, // 높이를 줄임
                              ),
                            );
                          } else {
                            return const Text("조회된 자료가 없습니다.");
                          }
                        },
                      )
                    : Container()),
          ],
        ),
      ),
    );
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/01/18 <br/>
   * @note 세로모드의 전체동의서 위젯 함수<br/>
   * @param OrientationBuilder에서 얻는 가로,세로모드에 대한 변수
   */
  Widget consentWidgetVertical(
      {required bool isVerticalMode,
      required int consentSearchType,
      required String consentSearchWord}) {
    if (!isVerticalMode) {
      return Container();
    }
    const platform = MethodChannel('com.example.consent5/kmiPlugin');
    return Expanded(
        child: Container(
      width: MediaQuery.of(context).size.width - 10,
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey, width: 1.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(15, 10, 0, 0),
            child: const Text("동의서 검색",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
          ),
          consentSearchTypeWidget(consentSearchType, (int newValue) {
            setState(() {
              this.consentSearchType = newValue;
            });
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment:
                        Alignment.centerRight, // Stack 내부의 정렬 방향을 오른쪽 중앙으로 설정
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.circular(5.0), // 경계선의 둥근 모서리 반경
                          ),
                          hintText: '검색',
                          hintStyle: TextStyle(fontSize: 12.0),
                          // 힌트 텍스트의 글자 크기
                          filled: true,
                          fillColor: Color.fromRGBO(243, 246, 255, 1),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0), // 패딩
                          // TextField의 오른쪽에 IconButton을 위한 공간 확보
                        ),
                        style: TextStyle(fontSize: 12.0),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 0.0), // TextField와 버튼 사이의 간격 조정
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            //width: 4.0,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            // 동의서 명 검색
                            // 전체검색일때
                            if (consentSearchType.toString() == '1') {
                              _searchWordController.updateSearchWord(
                                  _textFieldEditingController.text);
                            } else if (consentSearchType.toString() == '3') {}
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // ElevatedButton.icon을 위한 Container 추가
                  margin: EdgeInsets.only(left: 8.0),
                  // 검색 버튼과 AI 버튼 사이의 간격 조정
                  child: ElevatedButton.icon(
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
                ),
              ],
            ),
          ),
          const Divider(thickness: 2, height: 20, color: Colors.grey),
          Expanded(
              child: widget.isVisible
                  ? FutureBuilder(
                      future: consentSearchType.toString() == '1'
                          ? getSearchConsent(consentSearchWord)
                          : consentSearchType.toString() == '3'
                              ? getSearchBookMarkList(consentSearchWord)
                              : getSearchConsent(consentSearchWord),
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

                          return ListView.separated(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return ValueListenableBuilder<List<bool>>(
                                valueListenable: checkboxValuesNotifier,
                                builder: (context, values, child) {
                                  return InkWell(
                                    onTap: () {
                                      print('서식 데이터용 ${data[index]}');
                                      // print('즐겨찾기 여부 : ${data[index]['UseYn']}');
                                      List<Map<String, String>> consents = [];
                                      if (selectedData.length == 0) {
                                        // 서식 하나 선택시
                                        consents = [
                                          {
                                            'FormCd': data[index]['FormCd']
                                                .toString(),
                                            'FormId': data[index]['FormId']
                                                .toString(),
                                            'FormVersion': data[index]
                                                    ['FormVersion']
                                                .toString(),
                                            'FormRid': data[index]['FormRid']
                                                .toString(),
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
                                            'FormRid':
                                                data['FormRid'].toString(),
                                            'FormGuid':
                                                data['FormGuid'].toString(),
                                            'FormName':
                                                data['FormName'].toString(),
                                          };
                                          consents.add(consentMap);
                                        });
                                        print(
                                            '다중서식 정보 : ${consents.toString()}');
                                      }

                                      Map<dynamic, dynamic> params =
                                          _patientDetailController
                                              .patientDetail.value;

                                      print(
                                          "JSON 변형값 consents : ${jsonEncode(consents)}, params : ${jsonEncode(params)}");

                                      // 신규 동의서 열기 / 파라미터 전달
                                      platform.invokeMethod('openEForm', {
                                        'type': 'new',
                                        'consents': jsonEncode(consents),
                                        'params': jsonEncode(params),
                                        // 'op': 'someOperation',
                                      });
                                      //체크박스 갯수에 따라서 분기 처리
                                      if (selectedData.length <= 1) {
                                        print(
                                            '현재 클릭한 동의서 명 --- > ${data[index]['FormName']}');
                                      } else {
                                        print(
                                            '체크박스 체크된 데이터 --- > ${selectedData.length}');
                                      }
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: values[index],
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
                                          child: Row(
                                            children: [
                                              Text(
                                                data[index]['FormName'],
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              Spacer(),
                                              IconButton(
                                                  padding: EdgeInsets.only(
                                                      right: 30),
                                                  onPressed: () {
                                                    // print("@@아이콘 버튼 클릭");
                                                  },
                                                  icon: Icon(
                                                    Icons.star,
                                                    color: (data[index]
                                                                ['UseYN'] ==
                                                            'Y')
                                                        ? Colors.yellow
                                                        : Colors.white,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(
                              color: Colors.grey,
                              thickness: 1, // 두께를 1로 설정
                              height: 0, // 높이를 줄임
                            ),
                          );
                        } else {
                          return const Text("조회된 자료가 없습니다.");
                        }
                      },
                    )
                  : Container()),
        ],
      ),
    ));
  }

  /**
   * @author sangU02 <br/>
   * @since 2023/01/06 <br/>
   * @note 동의서 리스트 조회 메서드
   */
  Future<List<dynamic>> getDocList() async {
    Future<List<dynamic>> docList = makeRequest_consentAll(
        methodName: 'GetDocList',
        userId: '01',
        userPw: '1234',
        url: 'http://59.11.2.207:50089/HospitalSvc.aspx');
    List<dynamic> getDocList = await docList;
    print('동의서 리스트 : ${getDocList.toString()}');
    return getDocList;
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/02/15 <br/>
   * @note 동의서 검색 메소드
   */
  Future<List<dynamic>> getSearchConsent(String searchWord) async {
    Future<List<dynamic>> docList = makeRequest_consentSearch(
        methodName: "GetDocList",
        userId: '01',
        userPw: '12345',
        formName: searchWord,
        url: 'http://59.11.2.207:50089/HospitalSvc.aspx');
    return docList;
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/02/26
   * @Note 즐겨찾기 동의서 목록 조회
   */
  Future<List<dynamic>> getSearchBookMarkList(String consentSearchWord) async {
    Future<List<dynamic>> bookmarkList = makeRequest_getBookmarkList(
        methodName: 'GetBookMarkList',
        userId: '01',
        userPw: '1234',
        url: 'http://59.11.2.207:50089/HospitalSvc.aspx');

    return bookmarkList;
  }

  Widget consentSearchTypeWidget(int groupValue, Function(int) onChanged) {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () => onChanged(1),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Radio<int>(
                  value: 1,
                  groupValue: groupValue,
                  onChanged: (int? value) => onChanged(value!),
                ),
                Text("전체"),
              ],
            ),
          ),
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
                  groupValue: groupValue,
                  onChanged: (int? value) => onChanged(value!),
                ),
                Text("세트동의서"),
              ],
            ),
          ),
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
                  groupValue: groupValue,
                  onChanged: (int? value) => onChanged(value!),
                ),
                Text("즐겨찾기"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<List<dynamic>> getUnfinishedInfo() async {
    Future<List<dynamic>> makeRequest2 = makeRequest_GetUnfinished(
        methodName: 'GetUnfinishedConsentSearch',
        userId: '01',
        userPw: '1234',
        url: 'http://59.11.2.207:50089/HospitalSvc.aspx');
    List<dynamic> printReq = await makeRequest2;
    return printReq;
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
    _speechWords = result.recognizedWords;
    _searchWordController.updateSearchWord(_speechWords);
    setState(() {
      print('결과 도출');
      print('결과 : $_speechWords');
      // textField에 음성인식값 추가
      _textFieldEditingController.text =
          _speechWords.split(' ')[0]; // Set the text field value
      _isListening = false;
      _textController.add(_textFieldEditingController.text);
      // 음성인식으로 검색하면
    });
    print('녹음종료 $_isListening');
  }
}