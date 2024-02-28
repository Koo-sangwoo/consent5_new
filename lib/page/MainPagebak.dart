import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key); // Flutter 버전에 맞게 수정

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // 여기에 SingleTickerProviderStateMixin 추가
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 여기서 탭의 수를 설정합니다
  }

  @override
  void dispose() {
    _tabController.dispose(); // TabController 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4, // Tab의 수에 따라 변경
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              '전자동의서',
              style: TextStyle(color: Colors.blue),
            ),
            bottom: const TabBar(
              // TabBar의 스타일을 여기서 정의합니다.
              indicatorColor: Colors.blue,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: '입원'),
                Tab(text: '외래'),
                Tab(text: '응급'),
                Tab(text: '수술'),
              ],
            ),
            actions: <Widget>[
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  // DropdownButton의 스타일과 아이템을 여기서 정의합니다.
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  items: <String>['Profile', 'Settings', 'Logout']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
              const CircleAvatar(
                // CircleAvatar에 사용자 프로필 이미지를 설정합니다.
                //   backgroundImage: NetworkImage('url_to_the_image'),
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
          body: const TabBarView(
            // 각 Tab에 해당하는 위젯을 여기에 배치합니다.
            children: [
              Icon(Icons.home), // 각 탭의 내용을 위젯으로 채웁니다.
              Icon(Icons.task),
              Icon(Icons.school),
              Icon(Icons.report),
            ],
          ),
        ),
      ),
    );
  }
}
