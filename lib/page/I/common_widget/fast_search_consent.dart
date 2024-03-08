import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FastSearchWidget extends StatefulWidget {
  const FastSearchWidget({super.key});

  @override
  State<FastSearchWidget> createState() => _FastSearchWidgetState();
}

class _FastSearchWidgetState extends State<FastSearchWidget> {
  String dropdownWardValue = '병동';
  String dropdownDeptValue = '진료과';
  int selectedValue = 1; // 기본값으로 1을 설정

  bool isChecked1 = true; // 첫 번째 체크박스 상태
  bool isChecked2 = false; // 두 번째 체크박스 상태

  final TextEditingController _usercontroller = TextEditingController();
  final TextEditingController _patientcontroller = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController dateController2 = TextEditingController();

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

    return Column(
      children: [
        Expanded(
          // 이 부분을 추가하여 Container가 사용 가능한 공간을 채우도록 합니다.
          child: Row(
            children: [
              Container(
                width: 400,
                padding: const EdgeInsets.all(8.0), // 적절한 패딩 제공
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('사번'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usercontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintText: '검색',
                          hintStyle: const TextStyle(fontSize: 12.0),
                          filled: true,
                          fillColor: const Color.fromRGBO(243, 246, 255, 1),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                        ),
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      const SizedBox(height: 10),
                      const Text('환자번호'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _patientcontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintText: '검색',
                          hintStyle: const TextStyle(fontSize: 12.0),
                          filled: true,
                          fillColor: const Color.fromRGBO(243, 246, 255, 1),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                        ),
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: dropdownWardValue,
                              icon: const Icon(Icons.arrow_drop_down),
                              decoration: InputDecoration(
                                // 테두리 색상을 설정합니다. 이는 텍스트 필드가 활성화되지 않았을 때 적용됩니다.
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey
                                          .withOpacity(0.5)), // 연한 빨간색 테두리
                                ),
                                // 텍스트 필드에 포커스가 있을 때의 테두리 색상을 설정합니다.
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.yellow
                                          .withOpacity(0.5)), // 연한 빨간색 테두리
                                ),
                                // 텍스트 필드를 편집할 수 없을 때의 테두리 색상을 설정합니다.
                                // disabledBorder: OutlineInputBorder(
                                //   borderSide: BorderSide(
                                //       color: Colors.red.withOpacity(0.5)), // 연한 빨간색 테두리
                                // ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onChanged: (String? wardValue) {
                                setState(() {
                                  dropdownWardValue = wardValue!;
                                });
                              },
                              items: <String>[
                                '병동',
                                '101',
                                '102',
                                '103'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: dropdownDeptValue,
                              icon: const Icon(Icons.arrow_drop_down),
                              decoration: InputDecoration(
                                // 테두리 색상을 설정합니다. 이는 텍스트 필드가 활성화되지 않았을 때 적용됩니다.
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey
                                          .withOpacity(0.5)), // 연한 빨간색 테두리
                                ),
                                // 텍스트 필드에 포커스가 있을 때의 테두리 색상을 설정합니다.
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.yellow
                                          .withOpacity(0.5)), // 연한 빨간색 테두리
                                ),
                                // 텍스트 필드를 편집할 수 없을 때의 테두리 색상을 설정합니다.
                                // disabledBorder: OutlineInputBorder(
                                //   borderSide: BorderSide(
                                //       color: Colors.red.withOpacity(0.5)), // 연한 빨간색 테두리
                                // ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onChanged: (String? deptValue) {
                                setState(() {
                                  dropdownDeptValue = deptValue!;
                                });
                              },
                              items: <String>[
                                '진료과',
                                '신경과',
                                '정형외과',
                                '이비인후과'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      consentSearchTypeWidget(),
                      const SizedBox(
                        height: 5,
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
                                hintText: "입원일",
                                // 테두리 색상을 설정합니다. 이는 텍스트 필드가 활성화되지 않았을 때 적용됩니다.
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey
                                          .withOpacity(0.5)), // 연한 빨간색 테두리
                                ),
                                // 텍스트 필드에 포커스가 있을 때의 테두리 색상을 설정합니다.
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.yellow
                                          .withOpacity(0.5)), // 연한 빨간색 테두리
                                ),
                                // 텍스트 필드를 편집할 수 없을 때의 테두리 색상을 설정합니다.
                                // disabledBorder: OutlineInputBorder(
                                //   borderSide: BorderSide(
                                //       color: Colors.red.withOpacity(0.5)), // 연한 빨간색 테두리
                                // ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              readOnly: true,
                              // 사용자가 직접 입력하지 못하도록 설정
                              onTap: () {
                                selectDate(context); // 달력 대화 상자를 보여줍니다.
                                // print("@@$context");
                              },
                              style: const TextStyle(
                                fontSize: 11, // 원하는 텍스트 크기로 설정
                                // 다른 스타일 속성들도 여기에 추가할 수 있습니다.
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: TextField(
                              controller: dateController2,
                              decoration: InputDecoration(
                                hintText: "입원일",
                                // 테두리 색상을 설정합니다. 이는 텍스트 필드가 활성화되지 않았을 때 적용됩니다.
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey
                                          .withOpacity(0.5)), // 연한 빨간색 테두리
                                ),
                                // 텍스트 필드에 포커스가 있을 때의 테두리 색상을 설정합니다.
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.yellow
                                          .withOpacity(0.5)), // 연한 빨간색 테두리
                                ),
                                // 텍스트 필드를 편집할 수 없을 때의 테두리 색상을 설정합니다.
                                // disabledBorder: OutlineInputBorder(
                                //   borderSide: BorderSide(
                                //       color: Colors.red.withOpacity(0.5)), // 연한 빨간색 테두리
                                // ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              readOnly: true,
                              // 사용자가 직접 입력하지 못하도록 설정
                              onTap: () {
                                selectDate(context); // 달력 대화 상자를 보여줍니다.
                                // print("@@$context");
                              },
                              style: const TextStyle(
                                fontSize: 11, // 원하는 텍스트 크기로 설정
                                // 다른 스타일 속성들도 여기에 추가할 수 있습니다.
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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
                          const SizedBox(width: 30), // 체크박스 간 간격 조정
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
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              // 아이콘 색상을 검은색으로 지정
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                            ),
                            child: const Row(
                              mainAxisSize:
                                  MainAxisSize.min, // 아이콘과 텍스트를 버튼 내부 중앙에 위치시킴
                              children: [
                                Icon(Icons.refresh), // 아이콘
                                SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                                Text('초기화'), // 텍스트 추가
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (isChecked1 == true) {
                                //print('1');
                              } else {
                                //  print('2');
                              }

                              if (isChecked2 == true) {
                                //print('3');
                              } else {
                                //print('4');
                              }

                              print(_usercontroller.text);
                              print(_patientcontroller.text);
                              print(selectedValue);
                              print(dropdownDeptValue);
                              print(dropdownWardValue);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              // 아이콘 색상을 검은색으로 지정
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                            ),
                            child: const Row(
                              mainAxisSize:
                                  MainAxisSize.min, // 아이콘과 텍스트를 버튼 내부 중앙에 위치시킴
                              children: [
                                Icon(Icons.search), // 아이콘
                                SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                                Text('검색'), // 텍스트 추가
                              ],
                            ),
                          ),
                        ],
                      ),
                    ], //children
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget consentSearchTypeWidget() {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () => onChanged(1),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Radio<int>(
                  value: 1,
                  groupValue: selectedValue,
                  onChanged: (int? value) => onChanged(value!),
                ),
                const Text("전체"),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => onChanged(2),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Radio<int>(
                  value: 2,
                  groupValue: selectedValue,
                  onChanged: (int? value) => onChanged(value!),
                ),
                const Text("입원"),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => onChanged(3),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Radio<int>(
                  value: 3,
                  groupValue: selectedValue,
                  onChanged: (int? value) => onChanged(value!),
                ),
                const Text("외래"),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => onChanged(4),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Radio<int>(
                  value: 4,
                  groupValue: selectedValue,
                  onChanged: (int? value) => onChanged(value!),
                ),
                const Text("응급"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
