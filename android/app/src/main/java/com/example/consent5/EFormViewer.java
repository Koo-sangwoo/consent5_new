package com.example.consent5;

// EformViewer관련 클래스,

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Locale;
import java.util.UUID;
import java.util.concurrent.ExecutionException;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.os.Environment;
import android.graphics.BitmapFactory;
import android.util.Log;

import kr.co.clipsoft.eform.EFormToolkit;
import kr.co.clipsoft.eform.event.ExitEventArgs;
import kr.co.clipsoft.eform.event.IEventHandler;
import kr.co.clipsoft.eform.event.PenDrawingEventArgs;
import kr.co.clipsoft.eform.event.ResultEventArgs;
import kr.co.clipsoft.eform.event.ViewerActionEventArgs;
import kr.co.clipsoft.eform.information.ResultRecordFile;
import kr.co.clipsoft.eform.information.RunOption;
import kr.co.clipsoft.eform.type.enumtype.LogLevel;
import kr.co.clipsoft.eform.type.enumtype.Position;
import kr.co.clipsoft.eform.type.enumtype.SaveType;
import kr.co.clipsoft.eform.type.enumtype.ScreenOrientation;
import kr.co.clipsoft.eform.type.enumtype.TextInputAreaLimit;
import kr.co.clipsoft.eform.type.enumtype.Notification;

public class EFormViewer {

    private static final String TAG = "E-FORM Viewer";

    private static String EFORM_URL; // 서식 URL
    private static String SERVICE_URL;
    private EFormToolkit _toolkit; // 최초 1회에 한하여 생성한다.
    private Context context;
    private JSONObject requestOptions;
    private JSONArray consents;
    private int consentsCount;
    private String isConsentStatComparisonString;
    private boolean isOnlyPlay;
    private String paramUserId;
    private String paramPatientCode;
    private String paramPatientName;
    private String uploadPath;
    // 2024/02/13 by sangU02  아래 두개의 값은 임시값
    private String interfaceUser = "1";
    private String interfaceType = "2";


    public EFormViewer(JSONObject params, JSONArray consents, Context context) {
        this.context = context;
        this.requestOptions = params;
        this.consents = consents;
        this.uploadPath = getUploadPath();


        consentsCount = 0;
        isConsentStatComparisonString = "";
        EFORM_URL = "http://59.11.2.207:8088" + "/"; // V2 path에서 eformservice.aspx => 제거
        SERVICE_URL = "http://59.11.2.207:50089" + "/ConsentSvc.aspx";
        Log.i("EFromViewer", "[EFORM_URL ]: " + EFORM_URL);
    }

    // e-from toolkit 초기화
    @SuppressWarnings("incomplete-switch")
    public void initializeToolkit(JSONObject eFromViewerOption) {
        _toolkit = new EFormToolkit(context);
        String docYN = "";
        try {
            docYN = eFromViewerOption.getString("docYN");
        } catch (JSONException e1) {
            // TODO Auto-generated catch block
            e1.printStackTrace();
        }
        // 뷰어 실행시 동작에 관한 기본값을 설정 하는 역할
        RunOption runOption = new RunOption();
        // default Option
        runOption.setScreenOrientation(ScreenOrientation.Sensor);  // 가로세로 전환 모드
        runOption.setFirstPageLoad(true);                    // 서식 로딩 시 첫 페이지만 로딩
        runOption.setUseCaching(false);                         // 로컬 파일 생성하여 캐싱 사용 여부
        runOption.setLogLevel(LogLevel.DEBUG);                    // 로그 레벨
        runOption.setFosLogging(true);
        // SET Toolbar Option
        try {
            // runOption record 일경우 적용 시켜야함.
            runOption.setParameterDefaultValueClear(eFromViewerOption.getBoolean("DefaultValueClear")); // 서식 저장된 파라미터 초기화
            // 음성재생 모드일 경우
            isOnlyPlay = eFromViewerOption.getBoolean("isOnlyPaly");
            if (isOnlyPlay) {
                runOption.setUseExitConfirmDialog(false);
                runOption.setPageTouchEnable(false); // 화면 터치 이벤트 방지(ReadOnly)
            }

            String formType = eFromViewerOption.getString("type");


            EFormToolBarOption eFromToolbarOption = new EFormToolBarOption(isOnlyPlay, interfaceUser, interfaceType, docYN, formType);
            String toolbarOption = eFromToolbarOption.getToolBarOptionToString();
            Log.i(TAG, " [runOption] 사용자 타입 : " + interfaceUser);
            Log.i(TAG, " [runOption] 인터페이스 타입 : " + interfaceType);
            Log.i(TAG, " [runOption] 음성 재생 모드 : " + isOnlyPlay);
            Log.i(TAG, " [runOption] toolBarOption : " + toolbarOption + " ] ");
            runOption.setUiStyle(toolbarOption); // 툴바 및 UI 관련 옵션 설정
        } catch (JSONException e) {
            e.printStackTrace();
            Log.i(TAG, " [runOption] Exception : " + e.toString());
        }
        // 기본 옵션
        runOption.setInitializeScrollOnPageMove(true); // 페이지 이동시 스크롤 초기화

        // 입력 텍스트 박스 범위 제한           박승찬 추가
        runOption.setTextInputAreaLimit(TextInputAreaLimit.All);   // 라벨, 한줄입력글상자 , 여러줄입력글상자 범위제한 모두 적용
        runOption.setTextInputAreaLimitContainControlsSetting(true);// 텍스트 입력 제한 기능 사용 시 컨트롤의 설정을 반영할지 여부
        runOption.setTextInputAreaLimitNotification(Notification.Toast); // 범위 초과시 토스트 메시지로 표현

        // 필수입력 항상 체크여부
        runOption.setAlwaysDisplayRequiredInput(true);

        // 다중 녹취 여부
        runOption.setSaveRecordFileIntoMultipleParts(true);

        // 첨지 옵션
        runOption.setAttachPagePosition(Position.Next); // 다음 페이지에 추가 (Confirm, Previous, Next, Last)

        // 페이지템블릿 옵션
        runOption.setPageTemplatePosition(Position.Next); // 다음 페이지에 추가 (Confirm, Previous, Next, Last)

        // 카메라 첨지 옵션
        runOption.setUseCameraAttachPage(true);

        // 펜드로잉 모드일때 하단 이동 버튼 보이기 여부
        runOption.setBottomToolbarButtonsVisibleOnPenDrawMode(true);

        //자동저장
        runOption.setAutoTempSave(true);
        runOption.setAutoTempSaveTimeInSecond(5);

        // SAVE OPTION
        runOption.setReturnDataXmlOnSave(true);             // 저장시 dataXml 리턴 여부
        runOption.setDataXmlSaveAsFileOnSave(false);      // 저장시 dataXml 리턴 시 file 여부(true => file, false => String)
        runOption.setReturnImageOnSave(true);           // 저장시 이미지 파일 리턴 여부
        runOption.setImageSaveOption("{"
                + " 'dpi'        : 100 "
                + " ,'gray'       : false "
                + " ,'encode'     : 'jpg' "
                + " ,'start-index'     : 0 "
                + " ,'quality'        : 75 "
                + "}"
        );                                     // 저장 시 이미지 파일 옵션

        // 저장 시 ept 파일 리턴 여부
        runOption.setReturnTempDocumentOnSave(true);
        // 저장시 dataXml에 펜드로잉 정보 저장 여부
        runOption.setIncludesDrawingOnDataXml(false);

        // TEMP SAVE OPTION
        runOption.setReturnDataXmlOnTempSave(true);          // 임시 저장시 dataXml 리턴 여부
        runOption.setDataXmlSaveAsFileOnTempSave(false);   // 임시 저장시 dataXml 리턴 시 file 여부(true => file, false => String)
        runOption.setIncludesDrawingOnTempDocument(true);  // 임시저장시 펜드로잉 정보 저장 여부
        runOption.setParameterAsFileNameOnSave("filename");    // 파일 생성시 파일명을 설정
        runOption.setUseInputControlsInRepeatSection(true); // 머릿말
//     runOption.setReturnTempDocumentOnTempSave(false);  //  저장시 ept 파일 로컬에 저장 여부
//     runOption.setDeletePrivateTempFilesForDaysFromToday(7);    // 입력한 이전 날짜에 생성된 외부에서 접근 못하는  영역에 저장된 임시저장 파일을 삭제함.

        // 검사실이고 임시 검색한 경우에만 해당 옵션 적용 : 사인부분으로자동 이동 기능
//     runOption.setFirstPageLoad(false);
//     runOption.setScrollPositionOnDocumentLoad(VerticalAlign.Bottom);
//     runOption.setFirstVisiblePageOnDocumentLoad("LastPage");

        // 외부 사용자 컨트롤 URL 변경 : 서버가 변경될때마 서식의 URL을 변경할 수 없기 때문에 서식의 URL에 상관없이 서버의 URL로 변경해줌.
        runOption.setExternalControlDefinedPath(EFORM_URL);

        // 2017.07.17 컨트롤 초기화에 실패했을 경우 저장 이벤트를 동작하지 못하게 설정
        runOption.setPreventSaveAtInitializationError(SaveType.Save); // SaveType.Save, SaveType.TempSave, SaveType.TempSave2

        // 서식 로드시에 펜드로잉 정보 사용 여부
        runOption.setPenDrawingLoadOnDocumentLoad(false);

        // 펜드로잉 제한 영역 지정 (Header, Footer, Body)
//     runOption.setPreventPenDrawingOnSection(SectionType.Header);

        runOption.setRunAsRepositoryV2(true);  // 신서버 대응 API 박승찬 20190201 추가 true => V2 , false => 기존서버

        // Option Set
        _toolkit.setRunOption(runOption);


        // 펜드로잉 저장 및 불러오기 이벤트핸들러
        _toolkit.setPenDrawingEventHandler(new IEventHandler<PenDrawingEventArgs>() {
            @Override
            public void eventReceived(Object arg0, PenDrawingEventArgs event) {
                Log.e(TAG, "펜드로잉 : " + event.getPenDrawing());
                String saveResult = eformSaveDrow(event.getPenDrawing());
                if (saveResult.equals("")) {
                    Log.e(TAG, "펜드로잉 저장 성공");
                    _toolkit.sendEFormViewerOkEvent(); // 정상 처리 되었다고 뷰어에 이벤트 전달
                } else {
                    Log.e(TAG, "펜드로잉 저장 실패 : " + saveResult);
                    _toolkit.sendEFormViewerCancelEvent(saveResult);
                }
            }
        });

        // 저장, 임시저장 시 발생되는이벤트
        _toolkit.setResultEventHandler(new IEventHandler<ResultEventArgs>() {
            @Override
            public void eventReceived(Object sender, ResultEventArgs event) {
                String dataXml = "";      // dataXml
//           String dataXmlPath = "";   // dataXml File Path
                String formFilePath = "";  // FormXml File Path(.ept file)
                boolean saveResult = false;
                boolean audioUploadResult = false;
                String result = "";
                String defaultErrorMessage = "전자동의서 저장에 실패하였습니다.\n다시 저장해주세요.";
                Log.i(TAG, "로컬 경로 : " + Environment.getExternalStorageState());
                Log.i(TAG, " [======== 이벤트 핸들러 ========]");
                Log.i(TAG, " [ getResultCode : " + event.getResultCode() + " ]");


                long totalStartTime = System.currentTimeMillis();
                Log.i(TAG, "저장시작시간  : " + totalStartTime);
                Log.i(TAG, "[======== 저장 핸들러 ========]");
                switch (event.getResultCode()) {
                    case SAVE:
                        try {
                            dataXml = event.getDataXml();              // Data xml 문자열
//                          dataXmlPath = event.getDataXmlPath();        // Data Xml Path
                            formFilePath = event.getTempFilePath();       // ept 저장 경로
                            consentsCount = event.getFormOpenSequence() - 1; // Form List Index

                            // 녹취 파일 처리
                            String audiosPath = audioFileUpload(event.getAudioPath());
                            Log.i(TAG,"녹취파일 저장경로 @@@@@@@@@@@@@@@ : " + event.getAudioPath());
                            if (!event.getAudioPath().isEmpty()) {
                                if (audiosPath.equals("")) {
                                    audioUploadResult = false;
                                } else {
                                    audioUploadResult = true;
                                }
                            } else {
                                audioUploadResult = true;
                            }

                            // 완료 이미지 처리
                            ArrayList<String> imagePaths = event.getImagePath(); // 저장된 이미지 경로
                            String hashCode = imageHash(imagePaths);
                            String signature = "";
                            Log.i(TAG, "[======== 이미지 경로 ========]" + imagePaths);

                            // 전자서명
                            long signatureStartTime = System.currentTimeMillis();
                            signature = "REC";
                            logTimeGap("전자서명 시간", signatureStartTime);

                            // 이미지 업로드
                            JSONObject imagePathObject = new JSONObject();
                            for (int i = 0; i < imagePaths.size(); i++) {
                                File image = new File(imagePaths.get(i));
                                imagePathObject.put("imageFile" + i, uploadPath + image.getName());
                            }

                            String imageUploadResult = uploadFiles(imagePaths, imagePathObject);
                            Log.i(TAG, "[저장실패했다1 " + audioUploadResult + "두번째" + imageUploadResult + " ]");
                            // 저장 결과 저장
                            if (audioUploadResult && !imageUploadResult.equals("")) {
                                long saveStartTime = System.currentTimeMillis();
                                result = eformSaveData(dataXml, "save", formFilePath, imageUploadResult, hashCode, signature, audiosPath);
                                logTimeGap("저장에 걸린 시간", saveStartTime);
                                Log.i(TAG, "[저장실패했다3 " + result + " ]");
                                if (!result.equals("")) {
                                    saveResult = false;
                                    Log.i(TAG, "[저장실패 : " + result + " ]");
                                    defaultErrorMessage = result;
                                } else {
                                    saveResult = true;
                                    Log.i(TAG, "[저장성공]");
                                }
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                            saveResult = false;
                        }
                        break;

                    case TEMP_SAVE:
                        Log.i(TAG, " [======== 임시 저장  핸들러 ========]");
                        dataXml = event.getDataXml();              // Data xml 문자열
                        formFilePath = event.getTempFilePath();          // 임저자장 파일 경로
//                       dataXmlPath = event.getDataXmlPath();        // Data Xml Path
                        consentsCount = event.getFormOpenSequence() - 1;     // Form List Index

                        // 녹취 파일
                        String audiosPath = audioFileUpload(event.getAudioPath());

                        if (!event.getAudioPath().isEmpty()) {
                            if (audiosPath.equals("")) {
                                audioUploadResult = false;
                            } else {
                                audioUploadResult = true;

                            }
                        } else {
                            audioUploadResult = true;
                        }

                        // 임시 저장 결과 저장
                        if (audioUploadResult) {
                            long tempSaveStartTime = System.currentTimeMillis();
                            result = eformSaveData(dataXml, "temp", formFilePath, "", "", "", audiosPath);
                            logTimeGap("임시저장에 걸린 시간", tempSaveStartTime);
                            if (!result.equals("")) {
                                saveResult = false;
                                Log.i(TAG, " [ 저장실패 : " + result + " ]");
                            } else {
                                saveResult = true;
                                Log.i(TAG, " [ 저장성공 : " + result + " ]");
                            }
                        } else {
                            saveResult = false;
                        }

                        break;
                    default:
                        saveResult = false;
                        defaultErrorMessage = isConsentStatComparisonString;
                        break;
                }
                logTimeGap("총 저장 걸린 시간", totalStartTime);

                Log.i(TAG, " [ 저장결과 : " + saveResult + " ]");
                // 저장, 임시 저장 후에는 반드시 아래 두 결과 중 하나의 이벤트를 전달해야 한다.
                if (saveResult) {
                    Log.i(TAG, "[저장이나 임시저장이 정상적으로 되었습니다.]");
                    _toolkit.sendEFormViewerOkEvent(); // 정상 처리 되었다고 뷰어에 이벤트 전달
                } else {
                    Log.i(TAG, "[저장이나 임시저장이 정상적으로 되지 않았습니다.]");
                    Log.i(TAG, "[저장 실패 오류 발생]");
                    // 정상처리가 되지 않고, 안된 이유를 문자열로 담아 뷰어에 이벤트 전달
                    _toolkit.sendEFormViewerCancelEvent(defaultErrorMessage);
                }

            }
        });

        // 뷰어 종료시 발생되는 이벤트
        _toolkit.setExitEventHandler(new IEventHandler<ExitEventArgs>() {
            @Override
            public void eventReceived(Object sender, ExitEventArgs e) {
                Log.i(TAG, "[ E-Form Viewer 종료 이벤트 ] Code : " + e.getResultCode());
                switch (e.getResultCode()) {
                    case EXIT: // 정상종료
                        Log.i(TAG, "[정상종료]");
                        // 종료 후 화면 리스트 재조회
                        break;
                    case ERROR_EXIT: // 비정상 종료 ( 뷰어 초기화 & 서식 로드 중 오류 발생 시 )
                        String errorMessage = e.getErrorMessage(); // 오류메시지
                        Log.i(TAG, "[비정상종료] ErrorMessage : " + errorMessage);
                        // 종료 후 화면에 에러메시지 전달
                        break;
                }
            }
        });

        // 뷰어 페이지이동 발생되는 이벤트
        _toolkit.setViewerActionEventHandler(new IEventHandler<ViewerActionEventArgs>() {
            @Override
            public void eventReceived(Object sender, ViewerActionEventArgs e) {
                switch (e.getViewerActionEventType()) {
                    case MoveFirstPage: // 첫 페이지로 이동
                        break;
                    case MovePreviousPage: // 이전페이지
                        break;
                    case MoveNextPage: // 다음페이지
                        break;
                    case MoveLastPage: //마지막 페이지 이동
                        break;
                    case MoveSelectionPage: //특정 페이지 이동
                        break;
                    default:
                        break;
                }
            }
        });
    }

    // fos xml 만들기
    public String makeFosString(String type, JSONArray consents) {

        Log.i(TAG, "[makeFosString] type : " + type);
//        Log.i(TAG, "[makeFosString] op : " + op);
        Log.i(TAG, "[makeFosString] EFORM_URL : " + EFORM_URL);
        Log.i(TAG, "[makeFosString] Form데이터 : " + consents.toString());
        String fos = "";
        switch (type) {
            case "new":
                fos += "<?xml version='1.0' encoding='utf-8'?>";
                fos += "<fos version='1.0'>";
                fos += "   <global>";
                fos += "      <parameters>"; // form-list의 모든 서식에 적용될 파라미터
                fos += makeFosGlobalParameters();
                fos += "      </parameters>";
                fos += makeFosPageTemplate(EFORM_URL);
                fos += "   </global>";
                fos += "   <form-list>";  // 각 서식에 적용될 파라미터
                fos += makeFosFormList(type, EFORM_URL, consents);
                fos += "   </form-list>";
                fos += "</fos>";
                break;

            case "temp":
                fos += "<?xml version='1.0' encoding='utf-8'?>";
                fos += "<fos version='1.0'>";
                fos += "   <global>";
                fos += "      <parameters>"; // form-list의 모든 서식에 적용될 파라미터
                fos += "      </parameters>";
                fos += makeFosPageTemplate(EFORM_URL);
                fos += "   </global>";
                fos += "   <form-list>";
                fos += makeFosFormList(type, EFORM_URL, consents);
                fos += "   </form-list>";
                fos += "</fos>";
                break;

            case "rewrite":
                fos += "<?xml version='1.0' encoding='utf-8'?>";
                fos += "<fos version='1.0'>";
                fos += "   <global>";
                fos += "      <parameters>"; // form-list의 모든 서식에 적용될 파라미터
                fos += "      </parameters>";
                fos += makeFosPageTemplate(EFORM_URL);
                fos += "   </global>";
                fos += "   <form-list>";
                fos += makeFosFormList(type, EFORM_URL, consents);
                fos += "   </form-list>";
                fos += "</fos>";
                break;

            case "end":
                fos += "<?xml version='1.0' encoding='utf-8'?>";
                fos += "<fos version='1.0'>";
                fos += "   <global>";
                fos += "      <parameters>"; // form-list의 모든 서식에 적용될 파라미터
                fos += "      </parameters>";
                fos += makeFosPageTemplate(EFORM_URL);
                fos += "   </global>";
                fos += "   <form-list>";
                fos += makeFosFormList(type, EFORM_URL, consents);
                fos += "   </form-list>";
                fos += "</fos>";
                break;

            case "record":
                fos += "<?xml version='1.0' encoding='utf-8'?>";
                fos += "<fos version='1.0'>";
                fos += "   <global>";
                fos += makeFosPageTemplate(EFORM_URL);
                fos += "      <parameters>"; // form-list의 모든 서식에 적용될 파라미터
                fos += "      </parameters>";
                fos += "   </global>";
                fos += "   <form-list>";
                fos += makeFosFormList(type, EFORM_URL, consents);
                fos += "   </form-list>";
                fos += "</fos>";
                break;

            case "storage":
                fos += "<?xml version='1.0' encoding='utf-8' ?>";
                fos += "<fos version='1.0'>";
                fos += "   <global>";
                fos += "       <parameters><!--모든 서식에 적용될 파라미터-->";
                fos += "      </parameters>";
                fos += "   </global>";
                fos += "   <form-list><!--각 서식별로 적용될 파라미터-->";
                fos += "      <form name='' open-sequence='1' path='" + EFORM_URL + "'>";
                fos += "         <form-get-parameters> ";
                fos += "         </form-get-parameters>";
                fos += "         <connection connection-type='xml' name='xmlConn'>";
                fos += "            <connection-prop prop-type='setdata-service-url' value='http://emrdev.ncc.re.kr/EMR/EPPSERVER/eformservice.aspx' data-post-key='DataXml'>";
                fos += "            </connection-prop>";
                fos += "         </connection>";
                fos += "         <parameters>";
                fos += "         </parameters>";
                fos += "      </form>";
                fos += "   </form-list>";
                fos += "</fos>";
                break;
            case "test":
                fos += "<?xml version='1.0' encoding='utf-8' ?>";
                fos += "<fos version='1.0'>";
                fos += "   <global>";
                fos += "       <parameters><!--모든 서식에 적용될 파라미터-->";
                fos += "      </parameters>";
                fos += "   </global>";
                fos += "   <form-list><!--각 서식별로 적용될 파라미터-->";
                fos += "      <form name='' open-sequence='1' path='/storage/emulated/0/CLIPe-Form/Data/failconsent.ept'>";
                fos += "         <form-get-parameters> ";
                fos += "         </form-get-parameters>";
                fos += "         <connection connection-type='xml' name='xmlConn'>";
                fos += "            <connection-prop prop-type='setdata-service-url' value='http://emrdev.ncc.re.kr/EMR/EPPSERVER/eformservice.aspx' data-post-key='DataXml'>";
                fos += "            </connection-prop>";
                fos += "         </connection>";
                fos += "         <parameters>";
                fos += "         </parameters>";
                fos += "      </form>";
                fos += "   </form-list>";
                fos += "</fos>";
                break;
            default:
                break;
        }
//        fos = "<?xml version='1.0' encoding='utf-8'?><fos version='1.0'><global><parameters><param key='I_DEVICE_TYPE'><![CDATA[AND]]></param><param key='I_PTNT_NO'><![CDATA[00000010]]></param><param key='I_PTNT_NM'><![CDATA[김영진]]></param><param key='I_PTNT_NAME'><![CDATA[김영진]]></param><param key='I_PTNT_TEL'><![CDATA[]]></param><param key='I_PTNT_SEX'><![CDATA[남]]></param><param key='I_PTNT_AGE'><![CDATA[32]]></param><param key='I_PTNT_BIRTH_DAY'><![CDATA[1999.02.01]]></param><param key='I_PTNT_BIRTH'><![CDATA[990201-1******]]></param><param key='I_PTNT_ADDR'><![CDATA[서울시 OO구 OO동]]></param><param key='I_PTNT_HP'><![CDATA[]]></param><param key='I_VISIT_TYPE'><![CDATA[I]]></param><param key='I_CLN_DATE'><![CDATA[2024.02.14]]></param><param key='I_CLN_DEPT_CODE'><![CDATA[AB]]></param><param key='I_CLN_DEPT_NUMBER'><![CDATA[]]></param><param key='I_CLN_DEPT_NAME'><![CDATA[]]></param><param key='I_DOCTOR_PRO'><![CDATA[]]></param><param key='I_DIAG_CODE'><![CDATA[]]></param><param key='I_DIAG_NAME'><![CDATA[목감기]]></param><param key='I_WARD'><![CDATA[A5]]></param><param key='I_ROOM'><![CDATA[85]]></param><param key='I_CHARGE_ID'><![CDATA[]]></param><param key='I_CHARGE_NAME'><![CDATA[이아진]]></param><param key='I_DOCTOR_ID'><![CDATA[AB00031]]></param><param key='I_PATIENT_DOCTOR_NAME'><![CDATA[이아진]]></param><param key='I_DOCTOR_NAME'><![CDATA[]]></param><param key='I_OPERATION_DOCTOR'><![CDATA[]]></param><param key='I_USER_ID'><![CDATA[02]]></param><param key='I_USER_NAME'><![CDATA[백승찬]]></param><param key='I_USER_DEPT_CODE'><![CDATA[AB]]></param><param key='I_USER_DEPT_NAME'><![CDATA[마취통증의학과]]></param><param key='I_DEFAULT_POPUP_URL'><![CDATA[http://59.11.2.207:50089//]]></param><param key='I_VISIT_TYPE_NUMBER'><![CDATA[]]></param><param key='I_BEDNO'><![CDATA[]]></param><param key='I_OP_DATE'><![CDATA[]]></param><param key='I_OPERATION_NAME'><![CDATA[]]></param><param key='I_AGE'><![CDATA[32]]></param><param key='I_SEX'><![CDATA[남]]></param><param key='I_CERT_DESCRIPTION'><![CDATA[『전자서명법』에 따른 전자서명이 기재된 문서입니다.]]></param><param key='I_RS1'><![CDATA[X]]></param><param key='I_RS2'><![CDATA[X]]></param><param key='I_RS3'><![CDATA[X]]></param><param key='I_RS4'><![CDATA[X]]></param><param key='I_RS5'><![CDATA[X]]></param><param key='I_RS6'><![CDATA[X]]></param><param key='I_RS7'><![CDATA[X]]></param><param key='I_RS8'><![CDATA[X]]></param><param key='I_RS9'><![CDATA[X]]></param><param key='I_RS10'><![CDATA[X]]></param><param key='I_RS11'><![CDATA[X]]></param><param key='I_RS12'><![CDATA[X]]></param><param key='I_RS13'><![CDATA[X]]></param><param key='docYN'><![CDATA[N]]></param><param key='certPw'><![CDATA[]]></param><param key='I_PTNT_SIGN_IMAGE'><![CDATA[iVBORw0KGgoAAAANSUhEUgAABF8AAAIuCAYAAABpdKc6AAAgAElEQVR4Xuy9B5h9RZG4 / X4giKiYMSdAMWIA14QBBQHTrjnHVVEMa05r + LtGdFXMYUVhzVkxYV4xwBpgzQlzzhjByPcUntkdhpl7qk8 + 9779PPP80Kmurn67z53Tdaur / j9sEpCABCQgAQlIQAISkIAEJCABCUhAAr0R + P9606xiCUhAAhKQgAQkIAEJSEACEpCABCQgAXS + uAkkIAEJSEACEpCABCQgAQlIQAISkECPBHS + 9AhX1RKQgAQkIAEJSEACEpCABCQgAQlIQOeLe0ACEpCABCQgAQlIQAISkIAEJCABCfRIQOdLj3BVLQEJSEACEpCABCQgAQlIQAISkIAEdL64ByQgAQlIQAISkIAEJCABCUhAAhKQQI8EdL70CFfVEpCABCQgAQlIQAISkIAEJCABCUhA54t7QAISkIAEJCABCUhAAhKQgAQkIAEJ9EhA50uPcFUtAQlIQAISkIAEJCABCUhAAhKQgAR0vrgHJCABCUhAAhKQgAQkIAEJSEACEpBAjwR0vvQIV9USkIAEJCABCUhAAhKQgAQkIAEJSEDni3tAAhKQgAQkIAEJSEACEpCABCQgAQn0SEDnS49wVS0BCUhAAhKQgAQkIAEJSEACEpCABHS + uAckIAEJSEACEpCABCQgAQlIQAISkECPBHS + 9AhX1RKQgAQkIAEJSEACEpCABCQgAQlIQOeLe0ACEpCABCQgAQlIQAISkIAEJCABCfRIQOdLj3BVLQEJSEACEpCABCQgAQlIQAISkIAEdL64ByQgAQlIQAISkIAEJCABCUhAAhKQQI8EdL70CFfVEpCABCQgAQlIQAISkIAEJCABCUhA54t7QAISkIAEJCABCUhAAhKQgAQkIAEJ9EhA50uPcFUtAQlIQAISkIAEJCABCUhAAhKQgAR0vrgHJCABCUhAAhKQgAQkIAEJSEACEpBAjwR0vvQIV9USkIAEJCABCUhAAhKQgAQkIAEJSEDni3tAAhKQgAQkIAEJSEACEpCABCQgAQn0SEDnS49wVS0BCUhAAhKQgAQkIAEJSEACEpCABHS + uAckIAEJSEACEpCABCQgAQlIQAISkECPBHS + 9AhX1RKQgAQkIAEJSEACEpCABCQgAQlIQOeLe0ACEpCABCQgAQlIQAISkIAEJCABCfRIQOdLj3BVLQEJSEACEpCABCQgAQlIQAISkIAEdL64ByQgAQlIQAISkIAEJCABCUhAAhKQQI8EdL70CFfVEpCABCQgAQlIQAISkIAEJCABCUhA54t7QAISkIAEJCABCUhAAhKQgAQkIAEJ9EhA50uPcFUtAQlIQAISkIAEJCABCUhAAhKQgAR0vrgHJCABCUhAAhKQgAQkIAEJSEACEpBAjwR0vvQIV9USkIAEJCABCUhAAhKQgAQkIAEJSEDni3tAAhKQgAQkIAEJSEACEpCABCQgAQn0SEDnS49wVS0BCUhAAhKQgAQkIAEJSEACEpCABHS + uAckIAEJSEACEpCABCQgAQlIQAISkECPBHS + 9AhX1RKQgAQkIAEJSEACEpCABCQgAQlIQOeLe0ACEpCABCQgAQlIQAISkIAEJCABCfRIQOdLj3BVLQEJSEACEpCABCQgAQlIQAISkIAEdL64ByQgAQlIQAISkIAEJCABCUhAAhKQQI8EdL70CFfVEpCABCQgAQlIQAISkIAEJCABCUhA54t7YBUJXA04EtgOOCOwLXAK8Mfq56bAsasIxjlLQAISkIAEJCABCUhAAhKQQPcEdL50z1SN0ycQzpdjFph5dZ0v019ELZSABCQgAQlIQAISkIAEJDAXAjpf5rJS2tklAZ0vXdJUlwQkIAEJSEACEpCABCQgAQksJKDzxQ2yigSuA / zXgokb + bKKu8I5S0ACEpCABCQgAQlIQAIS6ImAzpeewKp2cgTeU1l0TuB8wEUWWHhz4K2Tm4EGSUACEpCABCQgAQlIQAISkMAsCeh8meWyaXQDAuF8OSDZ7 / 7A85OyiklAAhKQgAQkIAEJSEACEpCABBYS0PniBlkVAp8F9khO9qnAo5OyiklAAhKQgAQkIAEJSEACEpCABHS + uAckAJwA7JokcQRw16SsYhKQgAQkIAEJSEACEpCABCQgAZ0vHe + BqJRzJLAtcKbq378CJwHx700tU9wx8W7UfQXYPanqdcDtkrKKSUACEpCABCQgAQlIQAISkIAEdL50vAcsU9wx0IHUHQ9cMTnWJ4GrJmUVk4AEJCABCUhAAhKQgAQkIAEJ6HzpeA / ofOkY6EDqPg5cIznWz4HzJGUVk4AEJCABCUhAAhKQgAQkIAEJ6HzpeA / ofOkY6EDqPgBcv2CscwAnFsgrKgEJSEACEpCABCQgAQlIQAIS2JSA1Y5yGyPKFEfbCbgQcJEF3a5uzpcc1BGkIqLlXMlxrwzEVSWbBCQgAQlIQAISkIAEJCABCUigFQGdLzl84Xw5ICeKzpckqBHEPgXslRz3lsCbk7KKSUACEpCABCQgAQlIQAISkIAEtiSg8yW3OUryheh8yTEdQ + r1wK2TAz8ceEZSVjEJSEACEpCABCQgAQlIQAISkIDOl5Z7oKRMsc6XlrB77P5U4JFJ / S8CDk7KKrZcBCwnv1zr6WwkIAEJSEACEpCABCQwOgEjX3JL8HVgt5woMk2CGkHsnsBLk + N + EbhcUlax5SJgUu3lWk9nIwEJSEACEpCABCQggdEJ6CjILYHOlxynqUvtC7w / aeQfgR2SsootFwGdL8u1ns5GAhKQgAQkIAEJSEACoxPQ + ZJbAp0vOU5Tl9oF + EaBkdsCfyuQV3Q5COh8WY51dBYSkIAEJCABCUhAAhKYDAGdL7ml0PmS4zQHqb8C2yQNPT / w46SsYvMmYDn5ea + f1ktAAhKQgAQkIAEJSGDSBHS + 5Jbn / wGPz4ma8yXJaSyxEkfapYFItmxbfgKWk1 / +NXaGEpCABCQgAQlIQAISGI2Azpcc + hcDB + VEdb4kOY0l9llgj + Tg1wY + mpRVbN4ELCc / 7 / XTeglIQAISkIAEJCABCUyagM6X3PJEktZI1pppMs1QGk / m08CeyeFvAbwlKavYvAlYTn7e66f1EpCABCQgAQlIQAISmDQBHQW55dH5kuM0B6l3AwcmDb038JKkrGLzJlByHc3PzXmvtdZLQAISkIAEJCABCUhgcAIeInLIvXaU4zQHqacDD0sa + ljgSUlZxeZNQOfLvNdP6yUgAQlIQAISkIAEJDBpAjpfcstjwt0cpzlI3RR4e9LQ5wEPSMoqNm8COl / mvX5aLwEJSEACEpCABCQggUkT0PmSWx6dLzlOc5C6OvCJpKGvA26XlFVs3gR0vsx7 / bReAhKQgAQkIAEJSEACkyag8yW3PF47ynGag9SuwAlJQz9YkGg5qVKxiRLQwTrRhdEsCUhAAhKQgAQkIAEJLAMBnS + 5VTThbo7THKR2An6dNPRrwO5JWcXmTUDny7zXT + slIAEJSEACEpCABCQwaQI6X3LLo / Mlx2kuUicBOySM / RNwxoScIvMnoPNl / mvoDCQgAQlIQAISkIAEJDBZAjpfckuTvXb0M2DnnEqlRiTwXeDCyfG3Bf6WlFVsvgR0vsx37bRcAhKQgAQkIAEJSEACkyeg8yW3RNmD2bOAh + RUKjUigc8AV06Of / aCa0pJlYpNkED2GQ / T / dyc4AJqkgQkIAEJSEACEpCABKZMwENEbnUyB7NXAXfKqVNqZAJHAfsnbYgIme8nZRWbL4HMM742Oz8357vOWi4BCUhAAhKQgAQkIIFRCHiIyGFfdDB7LfBk4Is5VUpNgMA7gBsn7bgs8KWkrGLzJaDzZb5rp + USkIAEJCABCUhAAhKYPAGdL7klejhwyBaijwCenlOj1EQIvA / YL2nLNYBjkrKKzZdANq9TzNDPzfmus5ZLQAISkIAEJCABCUhgFAIeInLYrwQct4Vo5A45PqdmqaXOCVwLuHaVTyUqCr26 + pnaxN8L3CBp1AFAyNuWm4AVzZZ7fZ2dBCQgAQlIQAISkIAERiWg8yWPf7Pol1WMerkgcFHgYsDewDWr / 322LVDeGnhjHvMgki8ADk6ONEX7k6YrVkBA50sBLEUlIAEJSEACEpCABCQggTICOl / KeEUEzNp1lTisLUvEy1mA86z7iXLZ8b / 3BPYAzg1sD5wJ2K4MGUcD1yns07f4XYDDk4PcAzgsKavYfAl47Wi + a6flEpCABCQgAQlIQAISmDwBnS + TX6LODLwQcO8q0Wz89xmAPwM7Vj + dDbSJoh2AP / Y5QKHumwFvSfZ5MPDspKxi8yVgwt35rp2WS0ACEpCABCQgAQlIYPIEdL5MfokaG3gF4OrVTySN3a2xpvYdzwGc2F5NZxquB3wwqe0JQBzMbctNQOfLcq + vs5OABCQgAQlIQAISkMCoBHS + jIq / s8HjOtB6R0v8dzg8ptA + WiXhnYItazbsBXwqaVBEvUT0i225Ceh8We71dXYSkIAEJCABCUhAAhIYlYDOl1HxLxz8zJUD5ezVv + FMWf9zaeBywPmBkJli + 1B11enrEzPuEsDXkjZFvpfI + 2JbbgI6X5Z7fZ2dBCQgAQlIQAISkIAERiWg86Vf / HUOlCsC4USJSkGxFn8Ctq2cLGfs17Retb8deCzw + V5Haa78vMCPk92jUlNUPLItNwGdL8u9vs5OAhKQgAQkIAEJSEACoxLQ + dIcfzhMIvLkNsA + wPmAbYCTlsSB0pwMPAd4YBsFPfeNBMCxTpn2XuCAjKAysyZgtaNZL5 / GS0ACEpCABCQgAQlIYNoEdL7k1iecLPFz + erf + O9dcl1XUmoO5Zmj + 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]]></param><param key='beJSON'><![CDATA[]]></param>\t\t</parameters><page-template path='http://59.11.2.207:8088/' request-encode ='utf-8' response-encode ='utf-8'>\t<template-get-parameters>\t\t<post-param key='parameter'><![CDATA[{}]]>\t \t</post-param>\t</template-get-parameters></page-template> \t</global>\t<form-list><form name= ' (성인)안검내반 수술 동의서 ' open-sequence='1' path='http://59.11.2.207:8088/' request-encode='utf-8' response-encode='utf-8'>\t<parameters>\t\t<param key='filename'><![CDATA[76acfdf7-dedb-43b3-9281-991b50dbdc68]]></param>\t\t<param key='I_FORM_ID'><![CDATA[921]]></param>\t\t<param key='I_FORM_VERSION'><![CDATA[2]]></param>\t\t<param key='I_FORM_NAME'><![CDATA[(성인)안검내반 수술 동의서]]></param>\t\t<param key='I_PTNT_NO'><![CDATA[00000010]]></param>\t</parameters>\t<attachments>\t\t<pen-drawing>\t\t\t<document path='http://59.11.2.207:50089//ConsentSvc.aspx'>\t\t\t\t<pen-drawing-get-parameters>\t\t\t\t\t<post-param key='methodName'><![CDATA[GetConsentDrow]]></post-param>\t\t\t\t\t<post-param key='userId'><![CDATA[02]]></post-param>\t\t\t\t\t<post-param key='patientCode'><![CDATA[00000010]]></post-param>\t\t\t\t\t<post-param key='deviceType'><![CDATA[AND]]></post-param>\t\t\t\t\t<post-param key='deviceIdentName'><![CDATA[DeviceName]]></post-param>\t\t\t\t\t<post-param key='deviceIdentIP'><![CDATA[192.168.1.75]]></post-param>\t\t\t\t\t<post-param key='deviceIdentMac'><![CDATA[AA:BB:CC:DD:EE:FF]]></post-param>\t\t\t\t\t<post-param key='params'><![CDATA[{\"userId\":\"02\",\"formRid\":\"0\",\"formId\":\"921\",\"formVersion\":\"2\",\"drow\":\"\"}]]></post-param>\t\t\t\t</pen-drawing-get-parameters>\t\t\t</document>\t\t</pen-drawing>\t</attachments>\t<form-get-parameters>\t\t<post-param key='parameter'><![CDATA[{\"formId\":\"921\",\n" +
//                "\t\t\t\"formVersion\":\"2\"}]]></post-param>\t</form-get-parameters></form>\t</form-list></fos>";
        Log.i(TAG, "[FOS]  : " + fos);
        return fos;
    }

    public String makeFosFormList(String type, String path, JSONArray consents) {
        String formListXml = "";
        Log.i(TAG, "[makeFosFormList]");
//        Log.i(TAG,"Forme데이터" + consents.toString());
        try {
            for (int i = 0; i < consents.length(); i++) {
                JSONObject consent = new JSONObject(consents.getString(i)); // 동의서 서식에 관한 정보
                JSONObject params = requestOptions.getJSONObject("params"); // 동의서 환자 정보와 유저 정보
                JSONObject patientDetail = new JSONObject(requestOptions.getString("detail")); // 환자 상세 정보

                paramUserId = "01";// 기존 --> params.getString("userId");
                paramPatientCode = patientDetail.getString("PatientCode");
                paramPatientName = patientDetail.getString("PatientName");

                Log.i(TAG, "들어온 타입 : " + type);
                Log.i(TAG, "path : 퓨패패패" + path);
                Log.i(TAG, "로그인 사용자 ID :" + paramUserId);// 기존 --> params.getString("userId")
                Log.i(TAG, "선택한 환자코드 :" + patientDetail.getString("PatientCode"));
                Log.i(TAG, "consent : 퓨퓨퓨퓨" + consent.toString());
                Log.i(TAG, "FormCd :" + consent.getString("FormCd"));
                Log.i(TAG, "FormCd :" + consent.getString("FormCd"));
                Log.i(TAG, "FormId 아이디 :" + consent.getString("FormId"));
                Log.i(TAG, "Form :" + consent.getString("FormVersion"));
                Log.i(TAG, "FormCd :" + consent.getString("FormCd"));
                Log.i(TAG, "FormRid :" + consent.getString("FormRid"));
                Log.i(TAG, "FromGuid :" + consent.getString("FormGuid"));
                Log.i(TAG, "path : 패패패패" + path);
                Log.i(TAG, "type : 패패패패" + type);

                String guid = UUID.randomUUID().toString();
                if (type.equals("new")) {
                    formListXml += "<form name= ' " + consent.getString("FormName") + " ' open-sequence='" + (i + 1) + "' path='" + path + "' request-encode='utf-8' response-encode='utf-8'>";
                } else {
                    formListXml += "<form name='noname' open-sequence='" + (i + 1) + "' path='" + SERVICE_URL + "' request-encode='utf-8' response-encode='utf-8'>";
                }
                formListXml += type;

                formListXml += "   <parameters>";
                formListXml += "      <param key='filename'><![CDATA[" + guid + "]]></param>"; // 저장시 레코드나 이미지 파일명을 해당 파일명을 기준으로 생성됨.
                if (type.equals("new")) {
                    formListXml += "      <param key='I_FORM_ID'><![CDATA[" + consent.getString("FormId") + "]]></param>";   //V2에서 FormCd => FormID
                    formListXml += "      <param key='I_FORM_VERSION'><![CDATA[" + consent.getString("FormVersion") + "]]></param>"; //V2에서 FormCd => FormID
                    formListXml += "      <param key='I_FORM_NAME'><![CDATA[" + consent.getString("FormName") + "]]></param>";    //
                    formListXml += "      <param key='I_PTNT_NO'><![CDATA[" + patientDetail.getString("PatientCode") + "]]></param>";
                    formListXml += "      <param key='I_PTNT_NM'><![CDATA[" + patientDetail.getString("PatientName") + "]]></param>";
                    formListXml += "      <param key='I_WARD'><![CDATA[" + patientDetail.getString("Ward") + "]]></param>";
                }
                formListXml += "   </parameters>";

                // 첨부 파일 정보들
                formListXml += "   <attachments>";
                // 펜드로잉 정보 가져오기
                formListXml += makeFosLoadPendrawing();
                // 신규 서식이 아니면 녹음 파일 추가
                if (!type.equals("new")) {
                    formListXml += makeFosRecordFiles();
                }
                formListXml += "   </attachments>";
                formListXml += "   <form-get-parameters>";
                if (type.equals("new")) {
                    formListXml += "      <post-param key='parameter'><![CDATA[{\"formId\":\"" + consent.getString("FormId") + "\",\r\n";
                    formListXml += "          \"formVersion\":\"" + consent.getString("FormVersion") + "\"}]]></post-param>";          //여기 박승찬 수정예정 FOS_V2
                } else {
                    formListXml += "      <post-param key='use-repository'><![CDATA[false]]></post-param>";        //여기 박승찬 수정예정 FOS_V2
                    formListXml += "      <post-param key='methodName'><![CDATA[GetTempSaveXml]]></post-param>";
                    formListXml += "      <post-param key='params'><![CDATA[" + consent.getString("ConsentMstRid") + "]]></post-param>";
                }

//            formListXml += "      <post-param key='PD'>";                                  //이 부분  Key값, Parameter로 변경
//            formListXml += "         <![CDATA[";
//                if(type.equals("new")){ // 신규 동의서일 경우
//               formListXml += "            <data>";
//               formListXml += "               <action>GET</action>";
//               formListXml += "               <params>";
//               formListXml += "                  <param name='adaptername'>defaultadapter</param>";
//               formListXml += "                  <param name='type'>guid</param>";
//               formListXml += "                  <param name='guid'>"+consent.getString("FormGuid")+"</param>";
//               formListXml += "                  <param name='version'>-1</param>";
//               formListXml += "               </params>";
//               formListXml += "            </data>";
//            }else{             // 임시 저장 동의서일 경우
//               formListXml += "            <data>";
//               formListXml += "               <action>GET_DATA</action>";
//               formListXml += "               <params>";
//               formListXml += "                  <param name='adaptername'>defaultadapter</param>";
//               formListXml += "                  <param name='rid'>"+consent.getString("ConsentMstRid")+"</param>";
//               formListXml += "               </params>";
//               formListXml += "            </data>";
//            }
//            formListXml += "         ]]>";
//            formListXml += "      </post-param>";
                formListXml += "   </form-get-parameters>";
                formListXml += "</form>";
                Log.i(TAG, "여기까지?");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "formListXml : " + formListXml);
        return formListXml;
    }

    ;

    public String makeFosPageTemplate(String path) {
        String parameters = "";
        Log.i(TAG, "여기까지?1");
        parameters += "<page-template path='" + path + "' request-encode ='utf-8' response-encode ='utf-8'>";
        parameters += "    <template-get-parameters>";
        parameters += "       <post-param key='parameter'><![CDATA[{}]]>";
//     parameters += "          <![CDATA[PAGE_TEMPLATE]]>";
//     parameters += "       </post-param>";
//     parameters += "       <post-param key='PD'>";
//     parameters += "          <![CDATA[";
//     parameters += "             <data>";
//     parameters += "                <action>GET_LIST</action>";
//     parameters += "                <params>";
//     parameters += "                   <param name='adaptername'>defaultadapter</param>";
//     parameters += "                </params>";
//     parameters += "             </data>";
//     parameters += "          ]]>";
        parameters += "       </post-param>";
        parameters += "    </template-get-parameters>";
        parameters += "</page-template>";
        Log.i(TAG, "여기까지?2");
        return parameters;
    }

    // FOS에 펜드로잉 정보 불러오기
    public String makeFosLoadPendrawing() {
        String penDrawingUrl = "머시기 url";
        String parameters = "";
        try {
            JSONObject params = new JSONObject();
            JSONObject consent = new JSONObject(consents.getString(consentsCount));
            params.put("userId", paramUserId);
            params.put("formRid", consent.getString("FormRid"));
            params.put("formId", consent.getString("FormId"));
            params.put("formVersion", consent.getString("FormVersion"));
            params.put("drow", "");

            parameters += "       <pen-drawing>";
            parameters += "          <document path='" + penDrawingUrl + "'>";
            parameters += "             <pen-drawing-get-parameters>";
            parameters += "                <post-param key='methodName'><![CDATA[GetConsentDrow]]></post-param>";
            parameters += "                <post-param key='userId'><![CDATA[" + paramUserId + "]]></post-param>";
            parameters += "                <post-param key='patientCode'><![CDATA[" + paramPatientCode + "]]></post-param>";
            parameters += "                <post-param key='patientName'><![CDATA[" + paramPatientCode + "]]></post-param>";
            parameters += "                <post-param key='deviceType'><![CDATA[AND]]></post-param>";
            parameters += "                <post-param key='deviceIdentName'><![CDATA[" + "머시기네임" + "]]></post-param>";
            parameters += "                <post-param key='deviceIdentIP'><![CDATA[" + "머시기네임" + "]]></post-param>";
            parameters += "                <post-param key='deviceIdentMac'><![CDATA[" + "머시기네임" + "]]></post-param>";
            parameters += "                <post-param key='params'><![CDATA[" + params.toString() + "]]></post-param>";
            parameters += "             </pen-drawing-get-parameters>";
            parameters += "          </document>";
            parameters += "       </pen-drawing>";

        } catch (JSONException e) {
            e.printStackTrace();
            Log.i(TAG, "[makeFosLoadPendrawing] exception : " + e.toString());
        }
        Log.e(TAG, "[makeFosLoadPendrawing] pen-drawing : " + parameters);
        return parameters;
    }

    // FOS에 저장된 녹취 파일 추가
    public String makeFosRecordFiles() {
        String recordFilePath = android.os.Environment.getExternalStorageDirectory().getAbsolutePath() + "/CLIPe-Form/CONSENT/RECORD/"; // /CLIPe-Form/CONSENT/RECORD/
        Log.i(TAG, "녹취파일 불러오는 경로 : " + recordFilePath);
        File recordFolder = new File(recordFilePath);

        String parameters = "";
        parameters += "       <record-files>";
        // 녹취 파일 폴더에 파일이 있으면
        if (recordFolder.exists() && recordFolder.isDirectory()) {
            for (File file : recordFolder.listFiles()) {
                if (file.isFile()) {
                    parameters += "<record-file name='" + file.getName() + "' path='" + file.getPath() + "' />";
                }
            }
        }
        parameters += "       </record-files>";

        Log.e(TAG, "[makeFosRecordFiles] record-files : " + parameters);
        return parameters;
    }

    // FOS 전역 파라메타 만들기
    public String makeFosGlobalParameters() {
        String parameters = "";
        try {
            // 환자 정보
            if (!requestOptions.isNull("patient")) {
                parameters += object2param(requestOptions.getJSONObject("patient"), "patient");
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return parameters;
    }

    // KEY, Value => <param key='"+key+"'><![CDATA["+val+"]]></param>로 추가
    private String object2param(JSONObject obj, String type) {
        String param = "";
        if (obj != null) {
            try {
                Iterator<?> keys = obj.keys();
                while (keys.hasNext()) {
                    String key = (String) keys.next();
                    String val = (String) obj.getString(key);
                    Log.i(TAG, "[" + key + " : " + val + " ]");
                    if (val != "" && val != null) {
                        // 팝업 DEFAULT POPUP URL
                        if (key.equals("I_DEFAULT_POPUP_URL")) {
                            String defaultPopupUrl = "머시기팝업" + "/";
                            param += "<param key='" + key + "'><![CDATA[" + defaultPopupUrl + "]]></param>";
                        } else {
                            param += "<param key='" + key + "'><![CDATA[" + val + "]]></param>";
                        }
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
            Log.i(TAG, param);
        }
        return param;
    }

    public EFormToolkit getToolkit() {
        return _toolkit;
    }

    ;

    // 펜드로우잉 저장
    public String eformSaveDrow(String drowData) {
        String result = "";
        String respone = "";
        try {
            JSONObject params = new JSONObject();
            JSONObject consent = new JSONObject(consents.getString(consentsCount));
            Log.i(TAG, "consentsCount : " + consentsCount);
            Log.i(TAG, "consent : " + consents.getString(consentsCount));
            params.put("userId", paramUserId);
            params.put("formRid", consent.getString("FormRid"));
            params.put("formId", consent.getString("FormId"));
            params.put("formVersion", consent.getString("FormVersion"));
            params.put("drow", drowData);

            Log.i(TAG, "[eformSaveDrow] userId : " + paramUserId);
            Log.i(TAG, "[eformSaveDrow] formRid : " + consent.getString("FormRid"));
            Log.i(TAG, "[eformSaveDrow] formId : " + consent.getString("FormId"));
            Log.i(TAG, "[eformSaveDrow] formVersion : " + consent.getString("FormVersion"));
            Log.i(TAG, "[eformSaveDrow] drow : " + drowData);

            respone = "머시기 응답";
            Log.i(TAG, "[SaveDrow] respone : " + respone);
            if (isJSONObjectValid(respone)) {
                JSONObject objResult = new JSONObject(respone);
                if (!"0".equals(objResult.getString("RESULT_CODE"))) {
                    Log.i(TAG, "오류코드 : " + objResult.getString("ERROR_CODE"));
                    Log.i(TAG, "오류메시지 : " + objResult.getString("ERROR_MESSAGE"));
                    result = "오류코드 : " + objResult.getString("ERROR_CODE") + "\n" + objResult.getString("ERROR_MESSAGE") + "\n다시 시도해주세요.";
                }
            } else {
                if (result.toLowerCase(Locale.getDefault()).indexOf("time") > -1) {
                    Log.i(TAG, "펜드로잉 저장중에 타임아웃이 발생하였습니다.\n다시 시도해주시기 바랍니다.");
                    result = "펜드로잉 저장중에 오류가 발생했습니다.\n다시 시도해주세요.";
                } else {
                    result = "펜드로잉 저장중에 오류가 발생했습니다.\n다시 시도해주세요.";
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            Log.i(TAG, "saveDrow Error : " + e.toString());
            result = "펜드로잉 저장중에 오류가 발생했습니다.\n다시 시도해주세요.";
        }
        return result;
    }

    // e-from viewer : save or tempSave result
    public String eformSaveData(String dataXml, String type, String formXmlPath, String imagePaths, String hashCode, String signature, String audioPaths) {
        Log.i(TAG, "저장타입 : " + type);
        String saveResult = "";
        try {
            JSONObject params = requestOptions.getJSONObject("params");

            // 서식 Form XML
            params.put("formXml", readFileString(formXmlPath));
            Log.i(TAG, "formXml : " + readFileString(formXmlPath));
            // 서식 Data XML
            params.put("dataXml", dataXml.replaceAll("\"", "'"));
            PackageInfo appPackageInfo = context.getPackageManager().getPackageInfo("com.example.consent5", 0);
            PackageInfo viewPackageInfo = context.getPackageManager().getPackageInfo("kr.co.clipsoft.eform", 0);
            // 장비 고유 식별자 => 앱버전정보 변경
            String appVersion = appPackageInfo.versionName;
            String viewVersion = viewPackageInfo.versionName;
            params.put("deviceIdentNo", "AA:BB:CC:DD:EE_FF:" + appVersion + "_V:" + viewVersion);
            // 녹취파일 정보
            if (audioPaths != "" && audioPaths != null) {
                params.put("recordFileJson", audioPaths);
                Log.i(TAG, "[params] recordFileJson : " + params.getString("recordFileJson"));
            } else {
                params.put("recordFileJson", "");
            }

            JSONObject consent = new JSONObject(consents.getString(consentsCount));
            Log.i(TAG, "consentsCount : " + consentsCount);
            Log.i(TAG, "consent : " + consents.getString(consentsCount));
            // 서식 Rid
            params.put("formRid", consent.getString("FormRid"));
            // 서식 아이디
            params.put("formId", consent.getString("FormId"));
            if (consent.has("FormName") == true) {
                // 서식 이름
                params.put("formName", consent.getString("FormName"));
            } else if (consent.has("ConsentName") == true) {
                params.put("formName", consent.getString("ConsentName"));
            }
//            Log.i(TAG, "FormName : " + params.getString("formName"));
            // 서식 버전
            params.put("formVersion", consent.getString("FormVersion"));
            // ConsentMstRid 가 있으면 임시저장
            if (!consent.isNull("ConsentMstRid") && !consent.getString("ConsentMstRid").equals("0")) {
                params.put("consentMstRid", consent.getString("ConsentMstRid"));
                Log.i(TAG, "consentMstRid : " + consent.getString("ConsentMstRid"));
            } else {
                params.put("consentMstRid", "");
            }

            // 처방일
            if (!consent.isNull("OrderDate") && !consent.getString("OrderDate").equals("")) {
                params.put("orderDate", consent.getString("OrderDate"));
                Log.i(TAG, "orderDate : " + consent.getString("OrderDate"));
            } else {
                params.put("orderDate", "");
            }
            //  처방순번
            if (!consent.isNull("OrderSeqNo") && !consent.getString("OrderSeqNo").equals("")) {
                params.put("orderSeqNo", consent.getString("OrderSeqNo"));
                Log.i(TAG, "orderSeqNo : " + consent.getString("OrderSeqNo"));
            } else {
                params.put("orderSeqNo", "");
            }

            //  처방명
            if (!consent.isNull("OrderName") && !consent.getString("OrderName").equals("")) {
                params.put("orderName", consent.getString("OrderName"));
                Log.i(TAG, "orderName : " + consent.getString("OrderName"));
            } else {
                params.put("orderName", "");
            }

            //  처방코드
            if (!consent.isNull("OrderCd") && !consent.getString("OrderCd").equals("")) {
                params.put("orderCd", consent.getString("OrderCd"));
                Log.i(TAG, "orderCd : " + consent.getString("OrderCd"));
            } else {
                params.put("orderCd", "");
            }

            // 완료 저장시에만 추가되는 컬럼
            if (type.equals("save")) {
                // 완료저장 이미지 파일 정보
                if (imagePaths != "" && imagePaths != null) {
                    params.put("imageFileJson", imagePaths);
                    Log.i(TAG, "[params] imageFileJson : " + params.getString("imageFileJson"));
                } else {
                    params.put("imageFileJson", "");
                }
                // 전자서명 원본 값
                if (hashCode != "" && hashCode != null) {
                    params.put("certTarget", hashCode);
                    Log.i(TAG, "[params] certTarget : " + params.getString("certTarget"));
                } else {
                    params.put("certTarget", "");
                }
                // 전자서명 결과 값
                if (signature != "" && signature != null) {
                    params.put("certResult", signature);
                    Log.i(TAG, "[params] certResult : " + params.getString("certResult"));
                } else {
                    params.put("certResult", "");
                }
                requestOptions.put("methodName", "SaveComplete");
            } else {
                requestOptions.put("methodName", "SaveTempData"); // 임시저장 서비스
            }
            Log.i(TAG, "=========================================");
            String saveRespone = "";
            JSONObject detail = new JSONObject(requestOptions.getString("detail"));
            // 저장시 넘길 환자 데이터에 대한 변수를 전역 변수로 선언한 JsonObject detail에서 찾아 세팅한다.
            String patientCode = detail.getString("PatientCode");
            String patientName = detail.getString("PatientName");
            Log.i(TAG, "@@@@@@뷰어 저장시 로그 \n MethodName : " + requestOptions.getString("methodName") + "\n 환자 코드 : " + patientCode + "\n params.toString = " + params.toString());
            // 2024/02/27 by sangU02
            // 동의서 저장시 서버에 넘기는 파라미터에 환자번호를 추가해서 보낸다.
            // 02/28에 테스트해볼것.
            params.put("patientCode", patientCode);
            params.put("userId", "01");
            params.put("patientName", patientName);
            params.put("deviceType", "AND");
            if (paramsNullCheck(requestOptions.getString("methodName"), params)) {
                // by sangU02 2024/02/27 저장시 해당 함수를 통해 서버에 저장요청함
                saveRespone = new AsyncTaskForHttp(context, "")
                        .execute("ConsentSvc.aspx", // 기존 --> requestOptions.getString("serviceName") 여기에서 IP부터 수정하고 들어갈것.
                                requestOptions.getString("methodName"),
                                params.toString(), "01", patientCode).get();
            }

            Log.i(TAG, "저장 결과 : " + saveRespone);
            // {"RESULT_CODE":"-1","RESULT_DATA":null,"ERROR_CODE":"2000","ERROR_MESSAGE":"methodName : SaveComplete \r\n message : 개체 참조가 개체의 인스턴스로 설정되지 않았습니다."}

            if (isJSONObjectValid(saveRespone)) {
                JSONObject objResult = new JSONObject(saveRespone);
                if (!"0".equals(objResult.getString("RESULT_CODE"))) {
                    Log.i(TAG, "오류코드 : " + objResult.getString("ERROR_CODE"));
                    Log.i(TAG, "오류메시지 : " + objResult.getString("ERROR_MESSAGE"));
                    saveResult = "오류코드 : " + objResult.getString("ERROR_CODE") + "\n" + objResult.getString("ERROR_MESSAGE") + "\n다시 시도해주세요.";
                }
            } else {
                if (saveRespone.toLowerCase(Locale.getDefault()).indexOf("time") > -1) {
                    Log.i(TAG, "전자동의서 저장중에 타임아웃이 발생하였습니다.\n다시 시도해주시기 바랍니다.");
                    saveResult = "전자동의서 저장중에 오류가 발생했습니다.\n다시 시도해주세요.";
                } else {
                    saveResult = "전자동의서 저장중에 오류가 발생했습니다.\n다시 시도해주세요.";
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            saveResult = "전자동의서 저장중 오류가 발생했습니다. 다시 시도해주세요.";
        } catch (PackageManager.NameNotFoundException e) {
            throw new RuntimeException(e);
        } catch (ExecutionException e) {
            throw new RuntimeException(e);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        return saveResult;
    }

    ;

    public boolean paramsNullCheck(String methodName, JSONObject params) {
        boolean result = true;
        try {
            if (params != null) {
                Iterator<?> keys = params.keys();
                while (keys.hasNext()) {
                    String key = (String) keys.next();
                    if (params.getString(key) == null) {
                        if (methodName.equals("SaveTempData")) {
                            if (key.equals("patientCode") || key.equals("formRid") || key.equals("formId") || key.equals("formXml") || key.equals("formVersion") || key.equals("dataXml")) {
                                result = false;
                            }
                        } else {
                            if (key.equals("patientCode") || key.equals("formRid") || key.equals("formId") || key.equals("formXml") || key.equals("formVersion") || key.equals("dataXml") || key.equals("certTarget") || key.equals("certResult")) {
                                result = false;
                            }
                        }
                    }
                }
            } else {
                result = false;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            result = false;
        }
        return result;
    }

    ;

    // read File to String
    public String readFileString(String filePath) {
        String formXml = "";
        try {
            FileInputStream fis = new FileInputStream(filePath);
            BufferedReader bufferReader = new BufferedReader(new InputStreamReader(fis));

            String temp = "";
            while ((temp = bufferReader.readLine()) != null) {
                formXml += temp;
            }
            bufferReader.close();
            fis.close();
            formXml = formXml.replaceAll("\"", "'");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return formXml;
    }

    ;

    public String imageChangePng2Jpg(String imageFileName) {
        String outputPath = "";
        try {
            String extension = imageFileName.substring(imageFileName.lastIndexOf(".") + 1, imageFileName.length());
            outputPath = imageFileName.replace(extension, "jpg");
            Log.i(TAG, "[PNG->JPG] orgFileName : " + imageFileName);
            Log.i(TAG, "[PNG->JPG] outputPath : " + outputPath);
            Bitmap bitmap = BitmapFactory.decodeFile(imageFileName);
            int quality = 96;
            FileOutputStream fileOutStr = new FileOutputStream(outputPath);
            BufferedOutputStream bufOutStr = new BufferedOutputStream(fileOutStr);
            bitmap.compress(CompressFormat.JPEG, quality, bufOutStr);
            bufOutStr.flush();
            bufOutStr.close();

            File oldImage = new File(imageFileName);
            if (oldImage.exists()) {
                oldImage.delete();
            }
        } catch (FileNotFoundException exception) {
            exception.printStackTrace();
        } catch (IOException exception) {
            exception.printStackTrace();
        }
        return outputPath;
    }

    private String imageHash(ArrayList<String> imagePaths) {
        String hashCode = "";
        long imagHashTotalStartTime = System.currentTimeMillis();
        // 이미지 해쉬
        for (int i = 0; i < imagePaths.size(); i++) {
            String imagePath = imagePaths.get(i);
            // 이미지의 해쉬코드
            long imagHashStartTime = System.currentTimeMillis();
            hashCode += "머시기코드";
            Log.i(TAG, "imagePath[" + i + "] : " + imagePath);
            Log.i(TAG, "hash : " + hashCode);
            logTimeGap("이미지 해쉬에 걸린 시간", imagHashStartTime);
        }
        logTimeGap("이미지 해쉬에 총 걸린 시간", imagHashTotalStartTime);
        return hashCode;
    }

    // 파일 업로드 경로 : 환자번호(앞에서3자리)/환자번호(4번째에서3자리)/환자번호/
    private String getUploadPath(){
        String path = "";
        String patientCode = "";
        try {
            JSONObject params = new JSONObject(requestOptions.getString("detail")); // 환자 상세 정보;

            patientCode = params.getString("PatientCode");
        } catch (JSONException jsonException) {
            jsonException.getMessage();
        }
        // by sangU02 2024/02/28
        // 처음 patientCode.subString이 /하나가 붙어서 나오므로, 처음 /를 삭제함.
        path = patientCode.substring(0, 3) + "/" + patientCode.substring(4, 4) + "/" + patientCode + "/";    ///박승찬 환자번호 수정


        return path;
    }

    private String audioFileUpload(ArrayList<ResultRecordFile> audioList) {
        String result = "";
        try {
            if (audioList != null && !audioList.isEmpty()) {
                JSONObject filePathObject = new JSONObject();
                ArrayList<String> audioPaths = new ArrayList<String>();
                for (int i = 0; i < audioList.size(); i++) {
                    ResultRecordFile audio = audioList.get(i);
                    String audioPath = audio.getPath();
                    Log.i(TAG, "audio[" + i + "] : " + audioPath);
                    audioPaths.add(audioPath);
                    File file = new File(audioPath);
                    filePathObject.put("recordFile" + i, uploadPath + file.getName());
                }
                result = uploadFiles(audioPaths, filePathObject);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return result;
    }

    // 파일 업로드
    private String uploadFiles(ArrayList<String> fileList, JSONObject filePathObject) {
        String result = "";
        // 완료 이미지 파일들
        String[] filePaths = fileList.toArray(new String[fileList.size()]);
        String files = Arrays.toString(filePaths).replaceAll("\\[|\\]", "").replaceAll(", ", ",");

        boolean ftpUploadResult = false;
        int i = 0;
        while (i < 3) {
            if (!ftpUploadResult) {
                Log.i(TAG, "FTP 업로드 시도 : " + (i + 1) + " 번째 시도");
                ftpUploadResult = fileUpload(files, fileList.size());
            } else {
                break;
            }
            i++;
        }
        if (ftpUploadResult) {
            result = filePathObject.toString();
        }
        return result;
    }

    ;

    // FTP 파일 업로드
    public boolean fileUpload(String files, int fileTotalCount) {
        long saveFileUploadTime = System.currentTimeMillis();
        boolean result = false;
        String uploadResult = "";
        try {
            uploadResult = new AsyncTaskForUpload(context, "업로드 중 ...")
                    .execute("UpLoad.aspx", uploadPath, files).get();

            Log.i(TAG, "upload Result : " + uploadResult);
            JSONObject jsonResult = new JSONObject(uploadResult);
            String resultCode = jsonResult.getString("RESULT_CODE");
            if ("0".equals(resultCode)) {
                JSONObject jsonResultData = jsonResult.getJSONObject("RESULT_DATA");
                int successCount = jsonResultData.getInt("successCount");
                if (fileTotalCount == successCount) {
                    result = true;
                    Log.i(TAG, "파일이 모두 정상적으로 업로드 되었습니다.");
                } else {
                    Log.i(TAG, "파일 업로드 중에 몇 개가 업로드 되지 않았습니다. 재시도합니다.");
                }
            } else {
                Log.i(TAG, "파일 업로드가 정상적으로 되지 않았습니다. 재시도합니다.");
            }
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            throw new RuntimeException(e);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        logTimeGap("파일 업로드 시간", saveFileUploadTime);
        return result;
    }

    public static boolean isNumeric(String str) {
        return str.matches("[+-]?\\d*(\\.\\d+)?");
    }

    public boolean isJSONObjectValid(String test) {
        try {
            new JSONObject(test);
        } catch (JSONException ex) {
            ex.printStackTrace();
            return false;
        }
        return true;
    }

    public boolean isJSONArrayValid(String test) {
        try {
            new JSONArray(test);
        } catch (JSONException ex) {
            ex.printStackTrace();
            return false;
        }
        return true;
    }

    public void logTimeGap(String msg, long startTime) {
        long currentTime = System.currentTimeMillis();
        Log.i(TAG, msg + " : " + (currentTime - startTime) / 1000.0);
    }
}
