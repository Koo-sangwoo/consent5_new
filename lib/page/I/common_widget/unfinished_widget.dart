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
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: const Text(
            "처방동의서",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
          ),
        ),
        const Divider(
            thickness: 0.5,
            height: 20,
            color: Color.fromRGBO(233, 233, 233, 1)),
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
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                    child: Row(
                                      children: <Widget>[
                                        Text('${index+1}.'),
                                        Checkbox(
                                          value: values[index],
                                          visualDensity: VisualDensity(vertical: 1, horizontal: -4), // 크기 조절
                                          side: BorderSide(width: 1, color: Colors.grey.shade400), // 테두리 설정
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
