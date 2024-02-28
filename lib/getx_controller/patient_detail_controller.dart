import 'package:get/get.dart';

/**
 * @author sangU02<br/>
 * @since 2024/02/27<br/>
 * @apiNote 환자 상세정보를 관리하는 컨트롤러 Class
 *          PatientInfoWidget -> 모든 동의서 위젯으로 변수 순환
 */
class PatientDetailController extends GetxController {
  // params -> 유저정보 / detail -> 환자 상세
  RxMap<dynamic, dynamic> patientDetail = {
    'params': {'userId': ''},
    'detail': {}
  }.obs;

  /**
   * 환자 상세정보를 업데이트하는 함수,
   * update()는 위젯을 재생성하는데에만 사용되기때문에 필요 x
   */
  void updatePatientInfo(
      {Map<String, dynamic>? patientInfo, Map<String, dynamic>? userInfo}) {
    // print('컨트롤러로 들어온 상세정보 값 : ${patientInfo.toString()}');

    if (patientInfo != null && patientInfo.length != 0) {
      patientDetail.update('detail', (value) => value = patientInfo);
    }
    if (userInfo != null && userInfo.length != 0) {
      print('아직은 타면안돼 아직은..');
      patientDetail.update('params', (value) => value);
    }
    print('detail값 : ${patientDetail['detail'].toString()}');
    print('user값 : ${patientDetail['params'].toString()}');
    update();
    print('update 완료');
  }
}
