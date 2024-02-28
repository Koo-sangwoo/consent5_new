import 'package:get/get.dart';

class SearchWordController extends GetxController{
  RxString searchWord = ''.obs;

  void updateSearchWord(String value){
    print('탔다 검색메서드');
    searchWord.value = value;
    print('검색 완료 : ${searchWord.value}');
    update();
    print('검색 업데이트 완료');
  }

}