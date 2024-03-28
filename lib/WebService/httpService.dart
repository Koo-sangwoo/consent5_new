import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> makeRequest(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  Map date = {
    "UserID": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  Map<String, dynamic> resultData = {};

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = {
          'ERROR_CODE': data['ERROR_CODE'],
          'ERROR_MESSAGE': data['ERROR_MESSAGE']
        };

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = {
        'ERROR_CODE': 'Server Error',
        'ERROR_MESSAGE':
            'Server responded with status code: ${response.statusCode}'
      };

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()};
    print("@@Catch ! ---> $resultData");
  }

  return resultData;
}

// 입원 환자 리스트 요청 메소드
Future<List<dynamic>> makeRequest_inPatient(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    required String clnDate,
    required String ward,
    required String docName,
    required String dept,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  methodName = "GetInpatientSearch";

  Map date = {
    "UserID": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
    ,
    "CLN_DATE": clnDate,
    "WARD": ward,
    "DOCTOR_ID": docName,
    "CLN_DEPT_CODE": dept
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

// 외래 환자 조회 http 요청 메소드
Future<List<dynamic>> makeRequest_outPatient(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    required String clnDate,
    required String docName,
    required String dept,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  methodName = "GetOutpatientSearch";

  Map date = {
    "UserID": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
    ,
    "CLN_DATE": clnDate,
    "DOCTOR_ID": docName,
    "CLN_DEPT_CODE": dept
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

// 응급 환자 조회 요청 메소드
Future<List<dynamic>> makeRequest_emerPatient(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    required String clnDate,
    required String docName,
    required String dept,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  methodName = "GetEmergencyPatientSearch";

  Map date = {
    "UserID": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
    ,
    "CLN_DATE": clnDate,
    "DOCTOR_ID": docName,
    "CLN_DEPT_CODE": dept
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

// 수술 환자 정보 요청 메소드
Future<List<dynamic>> makeRequest_surgePatient(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    required String operDate,
    required String operDocName,
    required String anesType,
    required String operType,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  methodName = "GetOperationSearch";

  Map date = {
    "UserID": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
    ,
    "OPERATION_DATE": operDate,
    "DOCTOR_ID": operDocName,
    "operationAnes": anesType,
    "operationType": operType
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

//검사실 환자 조회 요청 메서드
Future<List<dynamic>> makeRequest_labotaryPatient(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    required String isnDate,
    required String isnDept,
    required String isnOpt,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  methodName = "GetInpatientSearch";

  Map date = {
    "UserID": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
    ,
    "INSPECTION_DATE": isnDate,
    "INSPECTION_DEPT": isnDept,
    "INSPECTION_DATE_OPTION": isnOpt
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

Future<List<dynamic>> makeRequest_GetUnfinished(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  methodName = "GetUnfinishedConsentSearch";

  Map date = {
    "UserID": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

Future<List<dynamic>> makeRequest_consentAll(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  methodName = "GetDocList";

  Map date = {
    "userId": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": '01',
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

Future<List<dynamic>> makeRequest_getConsents(
    {required String methodName,
    required String userId,
    required String userPw,
    required String patientCode,
    required String url,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/ConsentSvc.aspx';

  methodName = "GetConsents";

  Map date = {
    "UserID": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
    ,
    "patientCode": patientCode // 사용자 PW
    ,
    "startDate": "20231201" // 사용자 PW
    ,
    "endDate": "20241231" // 사용자 PW
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

Future<List<dynamic>> makeRequest_consentSearch(
    {required String methodName,
    required String userId,
    required String userPw,
    required String formName,
    required String url,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  methodName = "GetDocList";

  Map date = {
    "userId": userId // 사용자 ID
    ,
    "formName": formName.isNotEmpty ? formName : formName,
  };
  print('동의서 검색어 $formName');

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": '01',
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

Future<List<dynamic>> makeRequest_insertBookmark(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    required String formId,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';
  print('insertBookmark 실행 formId : $formId');
  methodName = "InsertBookMarkConsent";

  Map date = {
    "userId": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
    ,
    "formId": formId,
    "patientCode": "00000010" // 사용자 PW
    ,
    "startDate": "20231201" // 사용자 PW
    ,
    "endDate": "20241230" // 사용자 PW
    ,
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": '01',
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

Future<List<dynamic>> makeRequest_deleteBookmark(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    required String formId,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  methodName = "DeleteBookMarkConsent";

  Map date = {
    "userId": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
    ,
    "formId": formId,
    "patientCode": "00000010" // 사용자 PW
    ,
    "startDate": "20231201" // 사용자 PW
    ,
    "endDate": "20240130" // 사용자 PW
    ,
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

Future<List<dynamic>> makeRequest_getBookmarkList(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/HospitalSvc.aspx';

  methodName = "GetBookMarkList";

  Map date = {
    "userId": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
    ,
    "patientCode": "00000010" // 사용자 PW
    ,
    "startDate": "20231201" // 사용자 PW
    ,
    "endDate": "20240130" // 사용자 PW
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}

/**
 * @author sangU02 <br/>
 * @since 2024/03/08
 * @note 빠른 조회
 */
Future<List<dynamic>> makeRequest_fastSearch(
    {required String methodName,
    required String userId,
    required String userPw,
    required String url,
    Map<String, dynamic>? param}) async {
  url = 'http://59.11.2.207:50089/ConsentSvc.aspx';

  methodName = "Get_Fast_Consents";

  Map date = {
    "UserID": userId // 사용자 ID
    ,
    "UserPassword": userPw // 사용자 PW
    ,
    "patientCode": '' // 사용자 PW
    ,
    "startDate": "2024-03-05" // 사용자 PW
    ,
    "endDate": "2024-03-17" // 사용자 PW
    ,
    "visitType": "",
    "ward": "",
    "clnDeptCode": "",
    "doctor": "",
  };

  var requestParams = {
    "methodName": methodName,
    "params": json.encode(date),
    "userId": userId,
    "deviceType": "AND",
    "deviceIdentName": "Chrome",
    "deviceIdentIP": "172.17.200.48",
    "deviceIdentMac": "E0AA96DEBD0A"
  };

  List<dynamic> resultData = [];

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: requestParams,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['RESULT_CODE'] == '0') {
        // 성공 처리, JSON 데이터 반환
        resultData = data['RESULT_DATA'];
        // print("@@성공 ! ---> $resultData");
      } else {
        // 오류 정보를 JSON 형태로 반환
        resultData = [
          {
            'ERROR_CODE': data['ERROR_CODE'],
            'ERROR_MESSAGE': data['ERROR_MESSAGE']
          }
        ];

        // print("@@실패 ! ---> $resultData");
      }
    } else {
      // 서버 오류 정보를 JSON 형태로 반환
      resultData = [
        {
          'ERROR_CODE': 'Server Error',
          'ERROR_MESSAGE':
              'Server responded with status code: ${response.statusCode}'
        }
      ];

      // print("@@서버오류 ! ---> $resultData");
    }
  } catch (e) {
    // 네트워크 오류 정보를 JSON 형태로 반환
    resultData = [
      {'ERROR_CODE': 'Network Error', 'ERROR_MESSAGE': e.toString()}
    ];
    print("@@Catch ! ---> $e");
  }

  return resultData;
}
