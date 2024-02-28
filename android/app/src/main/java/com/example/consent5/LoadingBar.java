package com.example.consent5;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.util.Log;
import com.example.consent5.MainActivity;
public class LoadingBar{

	private ProgressDialog loadingBar;
	private static LoadingBar mInstance;
	private static String TAG = "LoadingBar";
	
	public static LoadingBar getInstance(){
        if(mInstance == null){
            mInstance = new LoadingBar();
        }
        return mInstance;
    }
	
	public LoadingBar() {
		init();
	}
	
	public void init(){
		if(loadingBar != null){
			loadingBar.dismiss();
			loadingBar = null;
		}
		Log.i(TAG, "LoadingBar 초기화");
	}

	public void show(String message, Context context){
		Activity activity = (Activity)context;
		Log.i(TAG, "Activity 종료 여부 : " + activity.isFinishing());
			loadingBar = new ProgressDialog(context, android.R.style.Theme_Panel);
			//Theme_Panel
			loadingBar.setMessage(message);
			loadingBar.setIndeterminate(false);
			//loadingBar.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
			loadingBar.setProgressStyle(ProgressDialog.STYLE_SPINNER); 
			loadingBar.setCancelable(false); 
			loadingBar.show();
			Log.i(TAG, "LoadingBar 시작");

	};
	
	public void hide(){
		Log.i(TAG, "LoadingBar 종료");
		if(loadingBar != null){
			loadingBar.dismiss();
			loadingBar = null;
    	}
	};

}