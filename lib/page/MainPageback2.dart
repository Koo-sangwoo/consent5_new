import 'dart:convert';

import 'package:consent5/page/I/SearchControl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _storage = const FlutterSecureStorage();
  final _cities = ['서울', '대전', '대구', '부산', '인천', '울산', '광주'];
  String PatientPage = "";
  String? _selectedCity;
  final bool _isClickedInpatient = false;
  final bool _isClickedOutpatient = false;
  final bool _isClickedEmergency = false;
  String _clickedButton = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      _clickedButton = 'Inpatient';
      _selectedCity = _cities[0];
    });
  }

  // page_I 메소드 정의
  Widget page_I() {
    // SearchControl 위젯 또는 원하는 로직을 여기에 구현
    return const PatientIWidget(categoryCode: "I",);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(5),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                  height: double.infinity,
                  width: 170,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        topLeft: Radius.circular(15)),
                    color: Color.fromRGBO(53, 59, 85, 1),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Image(
                            image: AssetImage('assets/images/WhiteLogo.png')),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_clickedButton != 'Inpatient') {
                            // 현재 클릭된 버튼이 입원이 아닐 경우에만 상태 업데이트
                            setState(() {
                              _clickedButton = 'Inpatient'; // 입원 버튼 클릭 상태로 설정
                            });
                            print("@@입원버튼 클릭");
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _clickedButton == 'Inpatient'
                                ? const Color(0xFF738CF3)
                                : null, // 클릭 상태에 따라 배경색 변경
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset('assets/images/I.png'),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_clickedButton != 'Outpatient') {
                            // 현재 클릭된 버튼이 외래가 아닐 경우에만 상태 업데이트
                            setState(() {
                              _clickedButton = 'Outpatient'; // 외래 버튼 클릭 상태로 설정
                            });
                            print("@@외래버튼 클릭");
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _clickedButton == 'Outpatient'
                                ? const Color(0xFF738CF3)
                                : null, // 클릭 상태에 따라 배경색 변경
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset('assets/images/O.png'),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_clickedButton != 'Emergency') {
                            // 현재 클릭된 버튼이 응급이 아닐 경우에만 상태 업데이트
                            setState(() {
                              _clickedButton = 'Emergency'; // 응급 버튼 클릭 상태로 설정
                            });
                            print("@@응급버튼 클릭");
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _clickedButton == 'Emergency'
                                ? const Color(0xFF738CF3)
                                : null, // 클릭 상태에 따라 배경색 변경
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset('assets/images/E.png'),
                        ),
                      )
                    ],
                  )),
              const SizedBox(
                width: 5,
              ),
              //검색조건 컨테이너
              Container(
                  // padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  color: Colors.white,
                  height: double.infinity,
                  width: 700,
                  child: page_I()),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Color.fromRGBO(50, 31, 145, 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
