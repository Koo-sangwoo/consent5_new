package com.example.consent5;

import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

public class EFormToolBarOption {

    private JSONObject toolBarOption;
    private boolean isOnlyPlay;
    private String interfaceUser;
    private String docYN;
    private String formType;

    public EFormToolBarOption(boolean isOnlyPlay, String interfaceUser, String interfaceType, String docYN, String formType) throws JSONException{
        this.isOnlyPlay = isOnlyPlay;
        this.interfaceUser = interfaceUser;
        this.docYN = docYN;
        this.formType = formType;

        init();
        setToolbarOption();
        setRequiredInputOption();
        setToastMessageOption();
        setDialogOption();
        setProgressOption();
        setNotificationOption();
        setIdentityCardCamera();
    };
    private void init() {
        toolBarOption = new JSONObject();
    };

    // 툴바 관련 옵션
    private void setToolbarOption() throws JSONException {
        JSONObject toolbar = new JSONObject();
        Log.i("formType", " [runOption]  : " + formType);

        JSONObject pageNumber = new JSONObject();
        JSONObject current = new JSONObject();
        JSONObject textColor = new JSONObject();

        JSONObject buttons = new JSONObject();
        JSONObject drawingtoggle = new JSONObject();
//      JSONObject icon = new JSONObject();
        JSONObject information = new JSONObject();
        JSONObject record = new JSONObject();
        JSONObject pageattach = new JSONObject();
        JSONObject save = new JSONObject();
        JSONObject tempsave = new JSONObject();
        JSONObject tempsave2 = new JSONObject();
        JSONObject exit = new JSONObject();
        JSONObject penDrawingSave = new JSONObject();
        JSONObject penDrawingLoad = new JSONObject();
        JSONObject penDrawingEraseAll = new JSONObject();
        JSONObject penDrawingErasePage = new JSONObject();
        // 하단 툴바의 페이지 표현 부분.
        textColor.put("a", 255);
        textColor.put("r", 14);
        textColor.put("g", 186);
        textColor.put("b", 116);
        current.put("text-color", textColor); // 현재 페이지 표현하는 숫자.
        pageNumber.put("current", current);

        // 툴바에 있는 버튼 설정.

        // 펜 드로잉 버튼(활성상태와 비활성상태의 아이콘 지정.)
        // 기본값 이외에 지정할 수 있는 아이콘은 아래 두 개(gray, orange) 만 존재함
//      icon.put("enable-resource-name", "drawing_toggle_gray");
//      icon.put("disable-resource-name", "drawing_toggle_orange");
//      drawingtoggle.put("icon", icon);
        drawingtoggle.put("visible", "true");

        // 정보창 버튼
        information.put("visible", "true");

        // 첨지 버튼
        pageattach.put("text", "첨지");
        pageattach.put("visible", "true");

        // 녹음 버튼
        if(formType.equals("end")) {
            record.put("visible", "false");
            record.put("enabled", "false");
        }else {
            record.put("visible", "true");
            record.put("enabled", "true");
        }


        // 저장 버튼
        if ((this.docYN.indexOf("Y") > -1)) {
            save.put("text", "저장");
            save.put("visible", "true");
            save.put("enabled", "true");
        }else {
            save.put("text", "저장");
            save.put("visible", "false");
            save.put("enabled", "false");
        }

        // 임시저장 버튼
        if(formType.equals("end")) {
            tempsave.put("text", "임시저장");
            tempsave.put("visible", "false");
            tempsave.put("enabled", "false");
        }else {
            tempsave.put("text", "임시저장");
            tempsave.put("visible", "true");
            tempsave.put("enabled", "true");
        }



        // 임시저장2 버튼
        tempsave2.put("text", "임시저장2");
        tempsave2.put("visible", "false");
        tempsave2.put("enabled", "true");

        // 종료 버튼.
        exit.put("text", "종료");
        exit.put("visible", "true");

        // 펜드로잉 관련 버
        penDrawingSave.put("visible", "true"); // 펜 정보 저장 버튼
        penDrawingLoad.put("visible", "true"); // 펜 정보 불러오기 버튼
        penDrawingEraseAll.put("visible", "true"); // 펜 정보 모든 페이지 삭제 버튼
        penDrawingErasePage.put("visible", "false"); // 펜 정보 현재 페이지 삭제 버튼

        // 녹취재생 모드일 경우
        if(isOnlyPlay){
            record.put("enabled", "false");
            save.put("visible", "false");
            tempsave.put("visible", "false");
            tempsave2.put("visible", "false");
            pageattach.put("visible", "false");
            drawingtoggle.put("visible", "false");
        }

        // 기록실용일 경우
//      if(interfaceUser.equals("REC")) {
//         save.put("visible", "false");
//      }

        buttons.put("drawingtoggle", drawingtoggle);
        buttons.put("information", information);
        buttons.put("record", record);
        buttons.put("pageattach", pageattach);
        buttons.put("save", save);
        buttons.put("tempsave", tempsave);
        buttons.put("tempsave2", tempsave2);
        buttons.put("exit", exit);
        buttons.put("pendrawing-save", penDrawingSave);
        buttons.put("pendrawing-load", penDrawingLoad);
        buttons.put("pendrawing-eraseall", penDrawingEraseAll);
        buttons.put("pendrawing-erasepage", penDrawingErasePage);

        toolbar.put("page-number", pageNumber);
        toolbar.put("buttons", buttons);

        toolBarOption.put("toolbar", toolbar);
    }

    // 필수입력 관련 옵션
    private void setRequiredInputOption() throws JSONException {
        JSONObject requiredInput = new JSONObject();

        JSONObject border = new JSONObject();
        JSONObject borderColor = new JSONObject();

        JSONObject background = new JSONObject();
        JSONObject backgroundColor = new JSONObject();

        // 필수입력 오류일 때 테두리 표시
        borderColor.put("a", 120);
//            borderColor.put("r", 225);
//            borderColor.put("g", 0);
//            borderColor.put("b", 0);
        borderColor.put("r", 255);
        borderColor.put("g", 255);
        borderColor.put("b", 210);
        border.put("color", borderColor);
        border.put("visible", "false");
        border.put("width", 2);
        requiredInput.put("border", border);

        // 필수입력 오류일 때 배경 표시.
        backgroundColor.put("a", 120);
//            backgroundColor.put("r", 255);
//            backgroundColor.put("g", 0);
//            backgroundColor.put("b", 0);
        backgroundColor.put("r", 255);
        backgroundColor.put("g", 255);
        backgroundColor.put("b", 210);
        background.put("color", backgroundColor);
        background.put("visible", "true");
        requiredInput.put("background", background);

        toolBarOption.put("required-input", requiredInput);
    }

    // 토스트 메시지 관련 옵션
    private void setToastMessageOption() throws JSONException {
        JSONObject toastMessage = new JSONObject();
        JSONObject signatureMissingData = new JSONObject();
        // 뷰어에서 사용되는 토스트 메시지 지정.
        signatureMissingData.put("text", "서명이 누락되었습니다.");
        toastMessage.put("signature-missing-data", signatureMissingData);
        toolBarOption.put("toast-message", toastMessage);
    }

    private void setIdentityCardCamera() throws JSONException{
        JSONObject identityCardCamera = new JSONObject();
        JSONObject identityCardList = new JSONObject();
        JSONObject title = new JSONObject();
        JSONObject sizeObject = new JSONObject();
        JSONObject mosaic = new JSONObject();
        JSONObject location = new JSONObject();
        JSONObject size = new JSONObject();


        identityCardCamera.put("title", "신분증을 선택하십시오.a");
        identityCardList.put("type", "ResidentRegistrationCard");
        identityCardList.put("name", "주민등록증b");
        identityCardList.put("visible", "true");
        sizeObject.put("width", "1000");
        sizeObject.put("height", "5");
        identityCardList.put("size", sizeObject);
        identityCardList.put("screenOccupancyRatio", "0.8");
        location.put("X", "100");
        location.put("Y", "100");
        mosaic.put("location", location);
        size.put("width", "600");
        size.put("height", "500");
        mosaic.put("size", size);
        identityCardList.put("mosaic", mosaic);

        identityCardCamera.put("identityCardList", identityCardList);
        toolBarOption.put("identityCardCamera", identityCardCamera);

    }

    // 다이얼로그 관련 옵션
    private void setDialogOption() throws JSONException {
        JSONObject dialog = new JSONObject();

        JSONObject save = new JSONObject();
        JSONObject tempSave = new JSONObject();
        JSONObject tempSave2 = new JSONObject();
        JSONObject exit = new JSONObject();
        JSONObject requiredError = new JSONObject();
        JSONObject preventProcess = new JSONObject();
        JSONObject localTempFileLoad = new JSONObject();
        JSONObject localTempFileLoadButtons = new JSONObject();
        JSONObject newFileLoad = new JSONObject();
        JSONObject tempFileLoad = new JSONObject();

        JSONObject moveNext = new JSONObject();
        JSONObject buttons = new JSONObject();
        JSONObject saveMove = new JSONObject();
        JSONObject tempsaveMove = new JSONObject();
        JSONObject tempsave2Move = new JSONObject();
        JSONObject move = new JSONObject();

        save.put("title", "저장");
        save.put("contents", "저장 하시겠습니까?");

        tempSave.put("title", "임시저장");
        tempSave.put("contents", "임시저장 하시겠습니까?");

        tempSave2.put("title", "임시저장2");
        tempSave2.put("contents", "임시저장2 하시겠습니까?");

        exit.put("title", "종료");
        exit.put("contents", "현재 작성된 동의서는 저장되지 않았습니다.\n\n저장하지 않고 종료하시겠습니까?");

        requiredError.put("title", "필수 입력 항목이 누락되었습니다.");

        preventProcess.put("title", "저장 실패");
        preventProcess.put("contents", "컨트롤 로드가 안되어서 저장에 실패하였습니다.");

        // 임시저장 파일 불러오기 다이얼로그 옵션
        newFileLoad.put("text", "새로운 서식 불러오기");
        tempFileLoad.put("text", "임시저장 불러오기");

        localTempFileLoadButtons.put("new-file-load", newFileLoad);
        localTempFileLoadButtons.put("temp-file-load", tempFileLoad);

        localTempFileLoad.put("title", "임시저장 파일 불러오기");
        localTempFileLoad.put("buttons", "임시저장 파일을 불러오시겠습니까?");
        localTempFileLoad.put("buttons", localTempFileLoadButtons);

        dialog.put("save", save);
        dialog.put("temp-save", tempSave);
        dialog.put("temp-save2", tempSave2);
        dialog.put("exit", exit);
        dialog.put("required-error", requiredError);
        dialog.put("prevent-process", preventProcess);
        dialog.put("local-temp-file-load", localTempFileLoad);

        saveMove.put("text", "저장 후 이동");
        saveMove.put("visible", "true");
        saveMove.put("enabled", "true");

        tempsaveMove.put("text", "임시저장 후 이동");
        tempsaveMove.put("visible", "false");
        tempsaveMove.put("enabled", "true");

        tempsave2Move.put("text", "임시저장2 후 이동");
        tempsave2Move.put("visible", "false");
        tempsave2Move.put("enabled", "true");

        move.put("text", "저장 없이 이동");
        move.put("visible", "false");
        move.put("enabled", "true");

        // 테스트 모드 일 경우 연속출력 이동 가능하게 수정
        if(interfaceUser.equals("TEST")){
            move.put("visible", "true");
        }

        buttons.put("save-move", saveMove);
        buttons.put("tempsave-move", tempsaveMove);
        buttons.put("tempsave2-move", tempsave2Move);
        buttons.put("move", move);
        // 연속 출력 시 다이얼로그에 다음 서식의 명칭을 포함한 내용을 표현할 경우 아래와 같이 지정합니다.
        moveNext.put("title", "{NextFormName} 열기");
        moveNext.put("contents", "다음 작성할 동의서는 {NextFormName} 입니다.");
        moveNext.put("buttons", buttons);

        dialog.put("move-next", moveNext);

        toolBarOption.put("dialog", dialog);
    }

    private void setProgressOption() throws JSONException {
        JSONObject progress = new JSONObject();

        JSONObject initialize = new JSONObject();
        JSONObject save = new JSONObject();
        JSONObject tempSave = new JSONObject();
        JSONObject tempSave2 = new JSONObject();

        initialize.put("title", "서식");

        save.put("title", "저장");
        save.put("title", "서식 저장 중...");

        tempSave.put("title", "임시저장");
        tempSave.put("title", "서식 임시저장 중...");

        tempSave2.put("title", "임시저장2");
        tempSave2.put("title", "서식 임시저장2 중...");

        progress.put("initialize", initialize);
        progress.put("save", save);
        progress.put("tempSave", tempSave);
        progress.put("tempSave2", tempSave2);

//      toolBarOption.put("progress", progress);
    };

    // 2017.07.17 페이지템블릿 알림 화면 위치 옵쳐 추가
    private void setNotificationOption() throws JSONException {
        JSONObject notification = new JSONObject();

        JSONObject pageTemplateName = new JSONObject();
        JSONObject position = new JSONObject();

        position.put("vertical", "top");
        position.put("horizontal", "rigth");

        pageTemplateName.put("page-template-name", position);

        notification.put("notification", pageTemplateName);

    }

    public String getToolBarOptionToString(){
        return toolBarOption.toString();
    };
}
