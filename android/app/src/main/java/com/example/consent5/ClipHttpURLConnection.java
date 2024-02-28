package com.example.consent5;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Iterator;

import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

public class ClipHttpURLConnection {
	
	private static String TAG_NAME = "HTTP";
	private long startServiceCallTime;
	
	public String request(JSONObject commonParams, JSONObject params){
		URL url = null;
        HttpURLConnection con = null;
        String respone = "";
        String requestParams  = "";
        
        startServiceCallTime = System.currentTimeMillis();
		Log.i(TAG_NAME, "=========== Request Info ==================");
		Log.i(TAG_NAME, "[ SEND REQUEST ]");
        try {
			Log.i(TAG_NAME, "URL : " +  commonParams.getString("serviceUrl"));
			Log.i(TAG_NAME, "params isCloudServer : " +  params.has("isCloudServer"));
			if(params.has("isCloudServer") == true) {
				Log.i(TAG_NAME, "params isCloudServer : " +  params.getString("isCloudServer"));
			}
			if(params.has("cloudServerUrl") == true) {
				Log.i(TAG_NAME, "params cloudServerUrl : " +  params.getString("cloudServerUrl"));
			}
			Log.i(TAG_NAME, "serviceName : " +  commonParams.getString("serviceName"));
	        Log.i(TAG_NAME, "methodName : " +  commonParams.getString("methodName"));
	        Log.i(TAG_NAME, "userId : " +  commonParams.getString("userId"));
	        Log.i(TAG_NAME, "patientCode : " + commonParams.getString("patientCode"));
	        Log.i(TAG_NAME, "deviceType : " + commonParams.getString("deviceType"));
	        Log.i(TAG_NAME, "deviceIdentName : " + commonParams.getString("deviceIdentName"));
	        Log.i(TAG_NAME, "deviceIdentIP : " + commonParams.getString("deviceIdentIP"));
	        Log.i(TAG_NAME, "deviceIdentMac : " + commonParams.getString("deviceIdentMac"));
	        Log.i(TAG_NAME, "params : " +  params.toString().replaceAll("\\\\/", "/"));
        } catch (JSONException e1) {
			e1.printStackTrace();
		}
        try{
        	String methodName =  commonParams.getString("methodName");
        	Log.i(TAG_NAME, "methodName 이름 : " + methodName);        	
        	if(params.has("isCloudServer") == true && methodName.equals("GetDocList") == true) {
        		String isCloudServer = params.getString("isCloudServer");
            	if( isCloudServer.equals("True") == true) {
//					Log.i("타는 URL은 ? ", "url : 1" );
            		url = new URL(params.getString("cloudServerUrl") +"/"+ commonParams.getString("serviceName"));
            		Log.i(TAG_NAME, "EFormServer : CloudServer , url: " + url);
            	}
            	else {
//					Log.i("타는 URL은 ? ", "url : 2" );
            		url = new URL(commonParams.getString("serviceUrl") +"/"+ commonParams.getString("serviceName"));
            		Log.i(TAG_NAME, "EFormServer : HospitalServer , url: " + url);
            	}
        	}
        	else {
//				Log.i("타는 URL은 ? ", "url : 3" );
				// 여기 url로 탄다.
            	url = new URL(commonParams.getString("serviceUrl") +"/"+ commonParams.getString("serviceName"));
            	Log.i(TAG_NAME, "EFormServer : HospitalServer , url: " + url);
        	}
            con = (HttpURLConnection) url.openConnection();
            con.setDoOutput(true);	// OutputStream으로 POST 데이터를 넘겨주겠다는 옵션.
            con.setDoInput(true);	// InputStream으로 서버로 부터 응답을 받겠다는 옵션.
            con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            con.setRequestMethod("POST");
            con.setConnectTimeout(30000);
            con.setReadTimeout(30000);
            
            Log.i(TAG_NAME, "parameters : ");
 			if(params != null){ // 여기 타는지 확인
 				Iterator<?> keys = params.keys();
 				while( keys.hasNext() ) {
 					String key = (String)keys.next();		    			    
 				    String value = params.getString(key);
 				    Log.i(TAG_NAME, "[ " + key +" : " + value + " ]");
// 				    if(key.equals("formXml") || key.equals("dataXml")){
// 						params.put(key, value.replaceAll("", ""));
// 					}		
 			    }
 			}
 			
 	        Log.i(TAG_NAME, "****************************************");	
            requestParams = String.format("%s=%s", "methodName", commonParams.getString("methodName")); // 요청 메소드 명 
            requestParams += "&" + String.format("%s=%s", "userId", commonParams.getString("userId"));// 사용자 ID
            requestParams += "&" + String.format("%s=%s", "patientCode", commonParams.getString("patientCode"));// 환자 등록번호
            requestParams += "&" + String.format("%s=%s", "deviceType", "AND");// 접속 디바이스 정보
            requestParams += "&" + String.format("%s=%s", "deviceIdentName", commonParams.getString("deviceIdentName"));// 접속 디바이스 이름 
            requestParams += "&" + String.format("%s=%s", "deviceIdentIP", commonParams.getString("deviceIdentIP"));// 접속 디바이스 IP
            requestParams += "&" + String.format("%s=%s", "deviceIdentMac", commonParams.getString("deviceIdentMac"));// 접속 디바이스 MAC ADDRESS
            requestParams += "&" + String.format("%s=%s", "params", URLEncoder.encode(params.toString().replaceAll("\\\\/", "/"),"UTF-8")); // 파라메타 
//			Log.i("ClipHttpURLConnection.java", "requestParams : " + requestParams.toString());
//            Log.e(TAG_NAME, "requestParams : "+ requestParams);
            
		    OutputStream out_stream = con.getOutputStream();
		    out_stream.write( requestParams.getBytes("UTF-8") );
		    out_stream.flush();
		    out_stream.close();
	        
		    Log.i(TAG_NAME, "[ RECEIVE RESPONSE ]");
		    Log.i(TAG_NAME, "ResponseCode : " + con.getResponseCode());
	        //display what returns the POST request
			StringBuilder sb = new StringBuilder();
			if(con.getResponseCode() == HttpURLConnection.HTTP_OK) {
			    BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "utf-8"));
				String line = null;  
				while ((line = br.readLine()) != null) {  
				    sb.append(line + "\n");
				}
				br.close();
				respone = sb.toString();
			}else{ 
			    respone = con.getResponseMessage();
			}
			Log.e(TAG_NAME, "respone : " + respone); 
	        Log.e(TAG_NAME, "["+commonParams.getString("methodName")+"] 서비스 호출에 [성공]하였습니다.");
			Log.e(TAG_NAME, "["+commonParams.getString("methodName")+"] 응답에 걸린 시간 " + " : " + ( System.currentTimeMillis() - startServiceCallTime ) / 1000.0 );
		}catch(Exception e){
			e.printStackTrace();
			respone = e.toString();
		}finally{
			if(con != null){
				con.disconnect();
			}
		}        
        return respone;
    }
}
