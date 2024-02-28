import 'package:get/get.dart';

/**
 * @author sangU02 <br/>
 * @since 2024/02/?? <br/>
 * @apiNote 가로 / 세로 모드에 따라 위젯 가시성 조절을 위한 변수 관리 컨트롤러 <br/>
 */
class VisibleController extends GetxController{
  RxBool isVisible = false.obs;
  RxBool isSelected = false.obs;

  /**
   * 무조건 토긇식으로 func 작동시 버그가 너무많다.
   * 따라서 상황에따라 지정하기로한다.
   */
  void toggleVisiblity(bool value){
    isVisible.value = value;
    isSelected.value = value;
    print('토글 완료');
    print('isVisible value : ${isVisible.value} / isSelected value : ${isSelected.value}');
    update();
    print('업데이트 완료');
  }

}