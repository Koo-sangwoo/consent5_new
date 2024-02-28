import 'package:consent5/WebService/httpService.dart';
import 'package:flutter/material.dart';

class UnfinishedWidget extends StatefulWidget {
  final bool isVerticalMode;
  final bool isVisible;
  const UnfinishedWidget(
      {super.key, required this.isVerticalMode, required this.isVisible});

  @override
  State<UnfinishedWidget> createState() => _UnfinishedWidgetState();
}

class _UnfinishedWidgetState extends State<UnfinishedWidget> {
  List<bool> checkboxValues = [];
  late ValueNotifier<List<bool>> checkboxValuesNotifier;

  List<Map<String, dynamic>> selectedData = [];
  late Future<List<dynamic>> unfinishedInfoFuture;

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
    print('처방동의서 bool 값 : ${widget.isVisible}');

    return Container(
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
        const Text("처방 동의서"),
        const Divider(thickness: 2, height: 20, color: Colors.grey),
        Expanded(
            child: widget.isVisible
                ? FutureBuilder(
              future: getUnfinishedInfo(),
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
                          return InkWell(
                            onTap: () {
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
                                    newValues[index] = newValue ?? false;
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
                                  child: Text(
                                    data[index]['FormName'],
                                    style: const TextStyle(fontSize: 12),
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
