package com.example.consent5;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.annotation.NonNull;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import kr.co.clipsoft.eform.EFormToolkit;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.consent5/kmiPlugin";
    KmiPlugin kmiPlugin = new KmiPlugin();



    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("setConnect")) { // 인증서 api 연동확인용
                                String ip = call.argument("ip");
                                int port = call.argument("port");

                                Boolean connectResult = kmiPlugin.setConnect(ip, port);
                                result.success(connectResult);
                            } else if (call.method.equals("openEForm")) { // 서식 열기

                                Context context = MainActivity.this;
                                // Flutter에서 전달한 데이터 추출
                                String type = call.argument("type");
//                                String op = call.argument("op");
                                String consents = call.argument("consents");
                                String params = call.argument("params");

                                try {
                                    JSONArray jsonConsents = new JSONArray(consents);
                                    JSONObject jsonParams = new JSONObject(params);
                                    Log.i("@@params 값 : ",  jsonParams.toString());
                                    Log.i("@@consents 값 : ",  jsonParams.toString());
                                    Log.i("@@저장타입 : ", type);
                                    loadEFormViewByGuid(type,jsonConsents, jsonParams, context);
                                } catch (JSONException e) {
                                    throw new RuntimeException(e);
                                }// 여기서 네이티브 메서드 호출
                            }else if(call.method.equals("requestIgnoreBatteryOptimization")){
                                requestIgnoreBatteryOptimization();
                                result.success("Requested Successfully");
                            }
                        }
                );
    }

    // by sangU02 2024/03/06
    // 배터리 절전권한 요청은 플랫폼마다 다르므로 네이티브에서 요청해야함
    //
    private void requestIgnoreBatteryOptimization() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            String packageName = getPackageName();
            Intent intent = new Intent();
            intent.setAction(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
            intent.setData(Uri.parse("package:" + getPackageName()));
            startActivity(intent);
        }
    }

    // e-from viewer 플러그인
    public void loadEFormViewByGuid(String type,  JSONArray consents, JSONObject params, Context context){ // 기존 인자에서 String op 삭제,
        EFormViewer eFromViewer = new EFormViewer(params, consents,context);
        JSONObject eFromViewerOption = new JSONObject();
        JSONObject paramsdata = new JSONObject();
        String docYN = "";

            // 2024/02/13
            paramsdata = params;
//            docYN = paramsdata.getString("docYN"); //여기는 잘담김.
            docYN = "Y";
        try {
            if(type.equals("new")){
                // 신규일 경우
                eFromViewerOption.put("DefaultValueClear", true);  // 저장된 값 초기화 여부
                eFromViewerOption.put("isOnlyPaly", false);          // 녹취 모드 여부
                eFromViewerOption.put("docYN", docYN);
                eFromViewerOption.put("type", "new");

            }else if (type.equals("end")) {
                // 완료된 동의서일 경우
                eFromViewerOption.put("DefaultValueClear", false); // 저장된 값 초기화 여부
                eFromViewerOption.put("isOnlyPaly", false); // 녹취 모드 여부
                eFromViewerOption.put("docYN", docYN);
                eFromViewerOption.put("type", "end");
            }else if(type.equals("record")){
                // 음성재생일 경우
                eFromViewerOption.put("DefaultValueClear", false);
                eFromViewerOption.put("isOnlyPaly", true);
                eFromViewerOption.put("type", "record");
            }else{
                // 임시 또는 재작성일 경우
                eFromViewerOption.put("DefaultValueClear", false);
                eFromViewerOption.put("isOnlyPaly", false);
                eFromViewerOption.put("docYN", docYN);
                eFromViewerOption.put("type", "temp");
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        eFromViewer.initializeToolkit(eFromViewerOption);

        String fos = eFromViewer.makeFosString(type, consents);// FOS 생성
        EFormToolkit toolkit = eFromViewer.getToolkit();

        String callEFormViewerResult = "";
        callEFormViewerResult = toolkit.startEFormViewer(fos); // CLIP e-Form 호출 (FOS 문자열을 인자)

        if(!callEFormViewerResult.equals("SUCCESS")){
            String message = "";
            switch (callEFormViewerResult) {
                case "ERROR_000":
                    message = "전자동의서 Viewer에서 예상치 못한 오류가 발생 하였습니다.";
                    break;
                case "ERROR_001":
                    message = "전자동의서 Viewer 앱이 설치 되지 않았습니다.\n전산정보팀에 문의 해주시기 바랍니다.";
                    break;
                case "ERROR_002":
                    message = "전자동의서 Viewer 앱이 최신 버전이 아닙니다.\n전산정보팀에 문의 해주시기 바랍니다.";
                    break;
                case "ERROR_003":
                    message = "전자동의서 Viewer에 FOS 값이 비어있습니다.\n전산정보팀에 문의 해주시기 바랍니다.";
                    break;
                case "ERROR_004":
                    message = "전자동의서 Viewer 지정된 시간안에 다시 호출되었습니다.\n전자동의서 Viewer를 종료 후 다시 실행해 주십시오.";
                    break;
                case "ERROR_005":
                    message = "현재 전자동의서 Viewer가 실행중입니다.\n전자동의서 뷰어를 종료 후 다시 실행해 주십시오.";
                    break;
                case "ERROR_006":
                    message = "GET_TASKS 권한이 없습니다.\n전산정보팀에 문의 해주시기 바랍니다.";
                    break;
                default:
                    break;
            }
        }
    }
}
