import 'package:consent5/getx_controller/patient_detail_controller.dart';
import 'package:consent5/getx_controller/visible_controller.dart';
import 'package:consent5/page/I/SearchControl.dart';
import 'package:consent5/page/I/common_widget/fast_search_consent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final _storage = const FlutterSecureStorage();
  final List<String> categories = [
    '입원',
    '외래',
    '응급',
    '수술',
    '검사실',
    '빠른조회'
  ]; // 우선 검색 뺐음
  String PatientPage = "";

  late PatientDetailController _patientDetailController;
  late VisibleController _visibleController;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _patientDetailController = Get.find();
    _visibleController = Get.put(VisibleController());
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  // 슬라이드로 탭을 넘기면 해당 func가 실행됨
  void _handleTabChange() {
    // 탭 변경 시 호출되는 함수
    print('Current Tab Index: ${_tabController.index}');
    _visibleController.toggleVisiblity(false);
    // 여기에 원하는 기능을 추가하세요
  }

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> userInfo =
        _patientDetailController.patientDetail.value['params'];
    print('userInfo 변수값 : ${userInfo.toString()}');
    return WillPopScope(
      onWillPop: () async {
        bool? logoutConfirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('로그아웃'),
              content: Text('로그아웃하시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // 로그아웃 취소
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // 로그아웃 확인
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );

        return logoutConfirmed ?? false;
      },
      child: OrientationBuilder(builder: (context, orientation) {
        bool isVerticalMode = orientation == Orientation.portrait;
        return DefaultTabController(
          length: categories.length, // 탭의 개수
          child: Scaffold(
            key: UniqueKey(), // Scaffold 위젯에 고유한 GlobalKey 할당
            backgroundColor: Color.fromRGBO(239, 243, 250, 1),
            resizeToAvoidBottomInset:
                false, // 키보드가 올라올 때 바텀의 요소가 밀리는 것을 방지 by sangU02 2024/01/18
            // drawer: Drawer(
            //   // 드로어 내용을 여기에 추가합니다.
            //   child: ListView(
            //     children: [
            //       const DrawerHeader(
            //         decoration: BoxDecoration(
            //           color: Colors.blue,
            //         ),
            //         child: Text('검색조건'),
            //       ),
            //       ListTile(
            //         title: const Text('Item 1'),
            //         onTap: () {
            //           // 아이템 1 클릭 시 로직
            //         },
            //       ),
            //       ListTile(
            //         title: const Text('Item 2'),
            //         onTap: () {
            //           // 아이템 1 클릭 시 로직
            //         },
            //       ),
            //       // 다른 ListTile 위젯들을 추가하여 더 많은 드로어 아이템을 만듭니다.
            //     ],
            //   ),
            // ),
            appBar: AppBar(
              backgroundColor: const Color.fromRGBO(115, 140, 243, 1),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0), // 이미지 주변의 패딩
                    child: Image.asset('assets/images/WhiteLogo.png',
                        height: 20), // 이미지 추가
                  ),
                  Expanded(
                    // 탭바가 여유 공간을 모두 채우도록 확장
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      padding: isVerticalMode
                          ? null
                          : const EdgeInsets.symmetric(horizontal: 150.0),
                      // 기기에 따라 조정 by sangU02 2023/01/12
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      unselectedLabelStyle: isVerticalMode
                          ? const TextStyle(color: Colors.white, fontSize: 9)
                          : const TextStyle(color: Colors.white, fontSize: 12),

                      dividerColor: Colors.transparent,
                      isScrollable: isVerticalMode ? true : false,
                      // 세로모드일때 스크롤을 통해 요소를 이동하도록 설정

                      /// 탭바 클릭시 나오는 splash effect 컬러
                      overlayColor: MaterialStatePropertyAll(
                        Colors.purple.shade100,
                      ),

                      //선택안되었을때 색깔
                      unselectedLabelColor: Colors.white,
                      // indicatorColor: Colors.pink.shade100,
                      indicator: BoxDecoration(
                          color: Color.fromRGBO(76, 96, 176, 1),
                          borderRadius: BorderRadius.circular(12)),
                      indicatorPadding: EdgeInsets.fromLTRB(-25, 5, -25, 5),

                      /// 탭바 클릭할 때 나오는 splash effect의 radius
                      splashBorderRadius: BorderRadius.circular(20),
                      tabs: categories
                          .map((e) => Tab(
                                text: e,
                              ))
                          .toList(),
                      onTap: (index) {
                        _visibleController.toggleVisiblity(false);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0), // 이미지 주변의 패딩
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade100,
                          radius: 20,
                          child:
                              Image.asset('assets/images/lion.png', height: 20),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${userInfo['UserName']}(${userInfo['UserDeptNum']})", //"라이언 112233(OS)"
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        IconButton(
                            onPressed: () {
                              print("@@아이콘 버튼 클릭");
                              Get.back();
                            },
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                ],
              ),
              centerTitle: true, // 타이틀(여기서는 Row)을 가운데 정렬
            ),
            body: Row(
              // Row 위젯을 추가합니다.
              children: [
                // Container(
                //   width: 200.0,
                //   height: 200.0,
                //   color: Colors.red,
                // ),
                Expanded(
                  // Expanded 위젯을 사용하여 TabBarView가 모든 가로 공간을 차지하도록 합니다.
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const Center(
                          child: PatientIWidget(
                        categoryCode: "I",
                      )),
                      const Center(
                        child: PatientIWidget(categoryCode: "O"),
                      ),
                      const Center(
                        child: PatientIWidget(categoryCode: "E"),
                      ),
                      const Center(
                        child: PatientIWidget(categoryCode: "S"),
                      ),
                      // const Center(child: PatientIWidget(categoryCode: "I"),), // 기존 검색 위젯
                      const Center(
                        child: PatientIWidget(categoryCode: "INS"),
                      ),
                      const Center(
                        child: FastSearchWidget(),
                      ),
                    ],
                  ),
                ),
                // Row 안에 다른 위젯을 추가할 수 있습니다. 예를 들어, 사이드바나 추가적인 정보를 표시하는 컨테이너 등을 추가할 수 있습니다.
                // 예:
                // Container(
                //   width: 100.0,
                //   color: Colors.blue,
                //   // 여기에 추가적인 내용을 채울 수 있습니다.
                // ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
