import 'package:consent5/WebService/httpService.dart';
import 'package:get/get.dart';


/**
 * @author sangU02 <br/>
 * @since 2024/02/26 <br/>
 * @apiNote searchOption 위젯 환자 검색값을 세팅하고 PatientFuture에 전달 <br/>
 */
class PatientSearchValueController extends GetxController {
  RxString date = ''.obs;
  RxString ward = ''.obs;
  RxString dept = ''.obs;
  RxString doctor = ''.obs;

  void searchValueUpdate(String date, String ward, String dept, String doctor) {
    this.date.value = date;
    this.ward.value = ward;
    this.dept.value = dept;
    this.doctor.value = doctor;
    print('검색 옵션 업데이트');
    print(
        'date ${this.date} , ward ${this.ward} , dept ${this.dept} , doctor ${this.doctor}');

    update();
    getInPatientInfo();
    print('컨트롤러 값 업데이트 완료');
  }

  /**
   * @author sangU02 <br/>
   * @since 2024/1/5 <br/>
   * @apinote 입원환자 정보 요청 메소드
   */
  Future<List<dynamic>> getInPatientInfo() async {
    String dateParam = this.date.value.isNotEmpty ? date.toString().replaceAll('-', '') : '';
    String wardParam = this.ward.value.isNotEmpty ? ward.toString() : '';
    String doctorParam = this.doctor.value.isNotEmpty ? doctor.toString() : '';
    String deptParam = this.dept.value.isNotEmpty ? dept.toString() : '';

    print(
        'getInpatientInfo value = $dateParam / $wardParam / $doctorParam / $deptParam');

    Future<List<dynamic>> makeRequest2 = makeRequest_inPatient(
      methodName: 'GetInpatientSearch',
      userId: '01',
      userPw: '1234',
      clnDate: dateParam,
      ward: wardParam,
      docName: doctorParam,
      dept: deptParam,
      url: 'http://59.11.2.207:50089/HospitalSvc.aspx',
    );
    List<dynamic> printReq = await makeRequest2;
    return printReq;
  }

  int patientListInit() {
    return 0;
  }
}
