package com.example.consent5;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
 
public class AsyncTaskForHttp extends AsyncTask<String, String, String> {	
    private static final String TAG = "AsyncTaskFoHttp";
    private Context context = null;   
    private String serviceName;
    private String methodName;
    private String parameters;
    private String userId;
    private String patientCode;
    private String popupMessage;
    
    public AsyncTaskForHttp(Context context, String message) {
		// TODO Auto-generated constructor stub
    	Log.i(TAG, "========= AsyncTaskFoHttp Start ==================");
    	this.context = context;
    	if(!message.equals("")){
    		this.popupMessage = message;
    	}else{
    		this.popupMessage = "Loading...";
    	}
	}
    
    /**
     * Before starting background thread Show Progress Bar Dialog
     * */
    @Override
    protected void onPreExecute() {    	
        super.onPreExecute();
        // Loading 바 생성
        LoadingBar.getInstance().show(popupMessage, context);
    }

    
	@Override
    protected String doInBackground(String... params) {
			
			Log.i(TAG, "[ Count 			: " + params.length+ " ]");
			Log.i(TAG, "[ serviceName 	: " + params[0]+ " ]");
			Log.i(TAG, "[ methodName 	: " + params[1]+ " ]");
			Log.i(TAG, "[ parameters 	: " + params[2]+ " ]");
			Log.i(TAG, "[ userId 		: " + params[3]+ " ]");
			Log.i(TAG, "[ patientCode 	: " + params[4]+ " ]");
        	
			serviceName  = params[0];
        	methodName = params[1];
        	parameters = params[2];
        	userId = params[3];
        	patientCode = params[4];
//		Log.i(TAG, "@@ Http 요청시 환자코드 : " + patientCode);
        	String result = "";
        	
        	JSONObject jsonParams = null;
        	try {
        		if(parameters != "" && parameters != null){
        			jsonParams = new JSONObject(parameters);
        		}
	        	ClipHttpURLConnection httpUrlCon = new ClipHttpURLConnection();
	        	
	        	String serviceUrl = Storage.getInstance(context).getStorage("serviceUrl");
	        	
	        	JSONObject commonParam = new JSONObject();	        	
	        	commonParam.put("serviceUrl", "http://59.11.2.207:50089");		// 요청할 URL
	        	commonParam.put("serviceName", serviceName);	// 요청할 서비스 명
	        	commonParam.put("methodName", methodName);		// 요청할 메소드 명
	        	commonParam.put("userId", userId);				// 사용자 ID 
	        	commonParam.put("patientCode", patientCode);	// 환자 등록번호
	        	commonParam.put("deviceType", "AND");			// 접속 디바이스 정보
	        	commonParam.put("deviceIdentName", Storage.getInstance(context).getStorage("deviceName"));	// 접속 디바이스 이름
	        	commonParam.put("deviceIdentIP", Storage.getInstance(context).getStorage("ipAddrss"));		// 접속 디바이스 IP
	        	commonParam.put("deviceIdentMac", Storage.getInstance(context).getStorage("macAddress"));	// 접속 디바이스 MAC Address
//				Log.i(TAG, "@@commonParam : " + commonParam.toString());
	        	result = httpUrlCon.request(commonParam, jsonParams);
	    		
	        	// 이미지 호출 시에는 base64 스트링을 파일로 저장
				if(methodName.equals("GetConsentImage") || methodName.equals("GetConsentRecord")){
					if(methodName.equals("GetConsentImage")){
						result = CommonUtil.getInstance(context).imageView(result);
					}else if(methodName.equals("GetConsentRecord")){
						result = CommonUtil.getInstance(context).base64StringToFile(result, "record");
					}
				}
        	} catch (JSONException e) {
				e.printStackTrace();
				Log.i(TAG, e.toString());
			}
        return result;
    }	

    protected void onProgressUpdate(String... progress) {
        // setting progress percentage
    }

    // request가 끝나고 호출되는 함수
    @Override
    protected void onPostExecute(String respones) {
    	Log.i(TAG, "========= AsyncTaskFoHttp End ==================");
//    	if(callbackContext != null){
//	    	if(CommonUtil.getInstance(context).isJSONValid(respones)){
//				callbackContext.success(respones);
//			}else{
//				callbackContext.error(respones);
//			}
//    	}
    	LoadingBar.getInstance().init();
    };
    
    @Override
    protected void onCancelled() {
        // 작업이 취소된후에 호출된다.
        super.onCancelled();
        LoadingBar.getInstance().init();
    }
}
	