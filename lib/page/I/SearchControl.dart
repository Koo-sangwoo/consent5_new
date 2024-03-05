import 'dart:async';

import 'package:consent5/WebService/httpService.dart';
import 'package:consent5/getx_controller/consent_search_controller.dart';
import 'package:consent5/getx_controller/patient_detail_controller.dart';
import 'package:consent5/getx_controller/patient_search_value_controller.dart';
import 'package:consent5/getx_controller/visible_controller.dart';
import 'package:consent5/page/I/common_widget/all_consent_widget.dart';
import 'package:consent5/page/I/common_widget/drop_down_builder.dart';
import 'package:consent5/page/I/common_widget/patient_info_widget.dart';
import 'package:consent5/page/I/common_widget/unfinished_widget.dart';
import 'package:consent5/page/I/common_widget/written_consent_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class PatientIWidget extends StatefulWidget {
  final String categoryCode;

  /// 기능위젯 총집합
  /// 카테고리 코드(categoryCode)인자값에 따라 위젯 빌드가 다르다.
  const PatientIWidget({super.key, required this.categoryCode});

  @override
  _PatientIWidgetState createState() => _PatientIWidgetState();
}

class _PatientIWidgetState extends State<PatientIWidget> {
  Map<String, dynamic>? result;

  // TEST 앱으로 인해 존재하는 파라미터
  List<String> docList = ['담당의', '이아진', '구상우', '엄재홍']; // 의사 리스트
  List<String> deptList = ['진료과', '신경과', '정형외과', '이비인후과']; // 진료과 리스트
  List<String> wardList = ['병동', 'A5', 'A6', 'C3']; // 병실 리스트
  List<String> anesList = ['마취구분', 'Local', 'MAC', 'General']; // 마취 리스트
  List<String> surgeryList = ['수술구분', '정규', '응급', '추가']; // 수술 리스트
  List<String> laboratoryList = ['검사구분', '과내검사실', '기능검사실', '내시경실']; // 검사구분 리스트
  List<String> laboratoryList2 = ['검사실', '과내검사실', '기능검사실', '내시경실']; // 검사실 리스트
  String dateText = "입원일";
  String docText = "지정의";
  String alertText = "진단명";
  String wardValue = '병동';
  String deptValue = '진료과';
  String docValue = '진료 ';

  TextEditingController dateController = TextEditingController();

  // 상태관리 컨트롤러 최상위 위젯에서 초기화
  final VisibleController _visibleController = Get.put(VisibleController());

  final SearchWordController _searchWordController =
      Get.put(SearchWordController());

  final PatientSearchValueController _patientSearchValueController =
      Get.put(PatientSearchValueController());

  final PatientDetailController _patientDetailController =
      Get.find();

  // 동의서 검색 라디오 타입 변수
  int consentSearchType = 1;

  @override
  Widget build(BuildContext context) {
    print('로그인한 유저 정보 : ${_patientDetailController.patientDetail.value}');

    if (dateController.text == "") {
      dateController.text = getToday();
    }

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

    // 2024/1/5 by sangU02
    return OrientationBuilder(builder: (context, orientation) {
      // 세로모드인가 가로모드인가
      bool isVerticalMode = orientation == Orientation.portrait;

      print("세로인가 가로인가? 구란가 진짠가? $isVerticalMode");

      return GestureDetector(
        // 키보드를 내리기 위한 GestureDetector 추가 From sangU02 2024/01/18
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Row(
          // 동의서 검색탭 디자인 수정을 위한 요소 추가 by sangU02
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      searchOptionBar(widget.categoryCode,
                          _patientSearchValueController, isVerticalMode),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      PatientInfoWidget(
                        visibleController: _visibleController,
                        categoryCode: widget.categoryCode,
                        patientSearchValueController:
                            _patientSearchValueController,
                        patientDetailController: _patientDetailController,
                      ),
                      Column(
                        children: [
                          // 처방 동의서 위젯
                          // Obx => 컨트롤러값의 변화를 감지하고 리빌드하는 GetX의 클래스
                          Obx(() => UnfinishedWidget(
                              isVerticalMode: isVerticalMode,
                              isVisible: _visibleController.isVisible.value)),
                          // 작성 동의서 위젯
                          // 위와 동일
                          Obx(() => WriteConsentWidget(
                                isVerticalMode: isVerticalMode,
                                isVisible: _visibleController.isVisible.value,
                                patientDetail: {
                                  'detail': _patientDetailController
                                      .patientDetail['detail']!,
                                  'params': _patientDetailController
                                      .patientDetail['params']!,
                                },
                              )),
                        ],
                      ),
                      // consentWidgetLandScape(isVerticalMode: isVerticalMode)
                    ],
                  ),
                ),
                isVerticalMode
                    ? Obx(() => AllConsentWidget(
                          isVerticalMode: isVerticalMode,
                          isVisible: _visibleController.isVisible.value,
                          searchWordController: _searchWordController,
                          patientDetailController: _patientDetailController,
                        ))
                    : Container()
              ],
            ),
            isVerticalMode
                ? Container()
                : Obx(() => AllConsentWidget(
                      isVerticalMode: isVerticalMode,
                      isVisible: _visibleController.isVisible.value,
                      searchWordController: _searchWordController,
                      patientDetailController: _patientDetailController,
                    ))
          ],
        ),
      );
    });
  }

  Future<void> requestPermissions() async {
    final List<Permission> permissions = [
      Permission.camera, // 카메라 권한
      Permission.photos, // 사진, 동영상 권한
      Permission.microphone, // 녹음 권한
      Permission.manageExternalStorage // 저장소 관련 권한
    ];
    for (var permission in permissions) {
      if (!await permission.request().isGranted) {
        print('${permission.toString()} 권한을 요청합니다.');
      } else {
        print('${permission.toString()} 권한을 이미 가지고 있습니다.');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    result = <String, dynamic>{};
    // 여기에 초기화 로직을 추가하세요
    // 권한 검증/요청부
    requestPermissions();
  }

  String getToday() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    return formatter.format(now);
  }

  /**
   * 검색옵션 날짜 세팅 함수
   */
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

  /**
   * @author sangU02
   * @since 2024/02/14
   * @note 카테고리에 따른 검색옵션 위젯 반환
   */
  Widget searchOptionBar(
      String categoryCode,
      PatientSearchValueController patientSearchValueController,
      bool isVerticalMode) {
    Widget searchOption = Text("검색옵션 생성 오류 발생");
    switch (categoryCode) {
      case "I":
        searchOption = Container(
          width: isVerticalMode ? 800 : 805,
          height: 40,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: "$dateText",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  ),
                  // 포커싱 잡혔을때 노란색은 쫌;;
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black.withOpacity(0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  suffixIcon: Icon(Icons.calendar_today),
                  suffixIconColor: Colors.grey.withOpacity(0.5),
                ),
                readOnly: true,
                onTap: () {
                  _visibleController.toggleVisiblity(false);
                  selectDate(context);
                },
                style: const TextStyle(
                  fontSize: 11,
                ),
              )),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: wardList[0],
                  icon: const Icon(
                    Icons.expand_more,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    _visibleController.toggleVisiblity(false);
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      wardValue = value!;
                    });
                  },
                  items: wardList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
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
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      deptValue = value!;
                    });
                  },
                  items: deptList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: docList[0],
                  icon: const Icon(
                    Icons.expand_more,
                    color: Colors.grey,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      docValue = value!;
                    });
                  },
                  items: docList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 50),
              // 2024/02/29 by sangU02 디자인 수정
              IconButton(
                  visualDensity: VisualDensity(horizontal: -3, vertical: -1),
                  // 아이콘과 텍스트 간격 조절
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.search),
                  iconSize: 33,
                  color: Colors.grey,
                  onPressed: () {
                    print("@검색클릭");
                    _patientSearchValueController.searchValueUpdate(
                      dateController.text,
                      wardValue,
                      deptValue,
                      docValue,
                    );
                  }),
              SizedBox(
                width: 10,
              ),
              IconButton(
                visualDensity: VisualDensity(horizontal: -3, vertical: -1),
                // 아이콘과 텍스트 간격 조절
                padding: EdgeInsets.zero,
                color: Colors.grey,
                icon: const Icon(Icons.refresh_rounded),
                iconSize: 33,
                onPressed: () {
                  print("@새로고침클릭");
                  // 설정 로직 수행
                },
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        );
        break;
      // 외래
      case "O":
        searchOption = SizedBox(
          width: isVerticalMode ? 800 : 805,
          height: 40,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: "$dateText",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  ),
                  // 포커싱 잡혔을때 노란색은 쫌;;
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black.withOpacity(0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  suffixIcon: Icon(Icons.calendar_today),
                  suffixIconColor: Colors.grey.withOpacity(0.5),
                ),
                readOnly: true,
                onTap: () {
                  _visibleController.toggleVisiblity(false);
                  selectDate(context);
                },
                style: const TextStyle(
                  fontSize: 11,
                ),
              )),
              const SizedBox(width: 10), // 요소 사이 간격
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: deptList[0],
                  icon: const Icon(
                    Icons.expand_more,
                    color: Colors.grey,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      deptValue = value!;
                    });
                  },
                  items: deptList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: docList[0],
                  icon: const Icon(
                    Icons.expand_more,
                    color: Colors.grey,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      docValue = value!;
                    });
                  },
                  items: docList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 50), // 요소 사이 간격
              IconButton(
                  visualDensity: VisualDensity(horizontal: -3, vertical: -1),
                  // 아이콘과 텍스트 간격 조절
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.search),
                  iconSize: 33,
                  color: Colors.grey,
                  onPressed: () {
                    print("@검색클릭");
                    _patientSearchValueController.searchValueUpdate(
                      dateController.text,
                      wardValue,
                      deptValue,
                      docValue,
                    );
                  }),
              SizedBox(
                width: 10,
              ),
              IconButton(
                visualDensity: VisualDensity(horizontal: -3, vertical: -1),
                // 아이콘과 텍스트 간격 조절
                padding: EdgeInsets.zero,
                color: Colors.grey,
                icon: const Icon(Icons.refresh_rounded),
                iconSize: 33,
                onPressed: () {
                  print("@새로고침클릭");
                  // 설정 로직 수행
                },
              ),
              SizedBox(
                width: 10,
              ),
              // Text(_isListening ? '녹음 중...' : ''),
            ],
          ),
        );
        break;
      // 응급
      case "E":
        List<String> emerDeptList = ["응급의학과"];
        searchOption = SizedBox(
          width: isVerticalMode ? 800 : 805,
          height: 40,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: "$dateText",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  ),
                  // 포커싱 잡혔을때 노란색은 쫌;;
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.withOpacity(0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  suffixIcon: Icon(Icons.calendar_today),
                  suffixIconColor: Colors.grey.withOpacity(0.5),
                ),
                readOnly: true,
                onTap: () {
                  _visibleController.toggleVisiblity(false);
                  selectDate(context);
                },
                style: const TextStyle(
                  fontSize: 11,
                ),
              )),
              const SizedBox(width: 10), // 요소 사이 간격
              DropDownBuilder(menuList: emerDeptList),
              const SizedBox(
                width: 10,
              ),
              DropDownBuilder(menuList: docList),
              const SizedBox(width: 50), // 요소 사이 간격
              IconButton(
                  visualDensity: VisualDensity(horizontal: -3, vertical: -1),
                  // 아이콘과 텍스트 간격 조절
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.search),
                  iconSize: 33,
                  color: Colors.grey,
                  onPressed: () {
                    print("@검색클릭");
                    _patientSearchValueController.searchValueUpdate(
                      dateController.text,
                      wardValue,
                      deptValue,
                      docValue,
                    );
                  }),
              SizedBox(
                width: 10,
              ),
              IconButton(
                visualDensity: VisualDensity(horizontal: -3, vertical: -1),
                // 아이콘과 텍스트 간격 조절
                padding: EdgeInsets.zero,
                color: Colors.grey,
                icon: const Icon(Icons.refresh_rounded),
                iconSize: 33,
                onPressed: () {
                  print("@새로고침클릭");
                  // 설정 로직 수행
                },
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        );
        break;
      // 수술
      case "S":
        searchOption = SizedBox(
          width: isVerticalMode ? 800 : 805,
          height: 40,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: "$dateText",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  ),
                  // 포커싱 잡혔을때 노란색은 쫌;;
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black.withOpacity(0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  suffixIcon: Icon(Icons.calendar_today),
                  suffixIconColor: Colors.grey.withOpacity(0.5),
                ),
                readOnly: true,
                onTap: () {
                  _visibleController.toggleVisiblity(false);
                  selectDate(context);
                },
                style: const TextStyle(
                  fontSize: 11,
                ),
              )),
              const SizedBox(width: 10), // 요소 사이 간격
              DropDownBuilder(menuList: deptList),
              const SizedBox(width: 10), // 요소 사이 간격
              DropDownBuilder(menuList: anesList),
              const SizedBox(
                width: 10,
              ),
              DropDownBuilder(menuList: docList),
              const SizedBox(width: 10), // 요소 사이 간격
              ElevatedButton(
                // 바코드 스캔 버튼
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min, // 아이콘과 텍스트를 버튼 내부 중앙에 위치시킴
                  children: const [
                    Icon(Icons.search), // 아이콘
                    SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                    Text('검색'), // 텍스트 추가
                  ],
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  // 아이콘 색상을 검은색으로 지정
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  print("@새로고침클릭");
                  // 설정 로직 수행
                },
              ),
              // Text(_isListening ? '녹음 중...' : ''),
            ],
          ),
        );
        break;
      // 검사실
      case "INS":
        searchOption = SizedBox(
          width: isVerticalMode ? 800 : 805,
          height: 40,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      hintText: "$dateText",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                      // 포커싱 잡혔을때 노란색은 쫌;;
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.black.withOpacity(0.5)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      suffixIcon: Icon(
                          Icons.calendar_today
                      ),
                      suffixIconColor: Colors.grey.withOpacity(0.5),
                    ),
                    readOnly: true,
                    onTap: () {
                      _visibleController.toggleVisiblity(false);
                      selectDate(context);
                    },
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  )),
              const SizedBox(width: 10), // 요소 사이 간격
              DropDownBuilder(menuList: laboratoryList),
              const SizedBox(
                width: 10,
              ),
              DropDownBuilder(menuList: laboratoryList2),
              const SizedBox(width: 10), // 요소 사이 간격
              ElevatedButton(
                // 바코드 스캔 버튼
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min, // 아이콘과 텍스트를 버튼 내부 중앙에 위치시킴
                  children: const [
                    Icon(Icons.search), // 아이콘
                    SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                    Text('검색'), // 텍스트 추가
                  ],
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  // 아이콘 색상을 검은색으로 지정
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  print("@새로고침클릭");
                  // 설정 로직 수행
                },
              ),
              // Text(_isListening ? '녹음 중...' : ''),
            ],
          ),
        );
        break;
      // 빠른 조회
      case "FAST":
        break;
    }

    return searchOption!;
  }

// 2024/01/16 by sangU02 http 요청 return value TEST
// Future<List<dynamic>> patientInfo = getPatientInfo();
// List<dynamic> patients = [];
// patientInfo.then((value) => print(value[0]));
// patientInfo.then((value) => patients = value);
// patientInfo.then((value) => print(patients[0]['PatientCode']));
// Future<List<dynamic>> consentInfo = getDocList();
// List<dynamic> docs = [];
// consentInfo.then((value) => print('서식 리턴 데이터 : $value'));
// consentInfo.then((value) => docs = value);
// print('들어간 docs value : $docs');
// List<dynamic> unfinishedList;
// getUnfinishedInfo().then((value) {
//   unfinishedList = value;
//   print('앱 위젯에서 ${unfinishedList}');
//   print('처방동의서 데이터 : ${unfinishedList.toString()}');
// });
}
