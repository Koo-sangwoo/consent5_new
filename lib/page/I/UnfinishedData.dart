import 'package:flutter/material.dart';

class unfinishedInfo extends StatefulWidget {
  final String patientCode;
  final String os;
  const unfinishedInfo({
    super.key,
    required this.patientCode,
    required this.os,
  });

  @override
  State<unfinishedInfo> createState() => _unfinishedInfoState();
}

class _unfinishedInfoState extends State<unfinishedInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      alignment: Alignment.centerLeft,
      height: 250,
      width: 380,
      margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
      // color: Colors.blue,
      decoration: BoxDecoration(
        // color: Colors.blue, // 컨테이너의 배경색
        borderRadius: BorderRadius.circular(10.0), // 테두리의 둥근 정도
        border: Border.all(
          color: Colors.grey, // 테두리 색상
          width: 1.0, // 테두리 두께
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("처방 동의서"),
        const Divider(thickness: 1, height: 20, color: Colors.grey),
        Expanded(
          child: FutureBuilder<Object>(
            future: null,
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: 3, // 현재는 하나의 더미 데이터만 사용합니다.
                itemBuilder: (context, index) {
                  // 각 환자 정보를 Card로 표시합니다.
                  return const Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('환자 코드 : 112233444'),
                          Text('OS: 정형외과'),
                          // Text('병/동/호: ${patient.bed}'),
                          // Text('나이/성별: ${patient.age}'),
                          // Text('입원일: ${patient.date}'),
                          // Text(
                          //     'ALERT: BSA: ${patient.bsa}, 혈액형: ${patient.bloodType}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          ),
        ),
      ]),
    );
  }
}
