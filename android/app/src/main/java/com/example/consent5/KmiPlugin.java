package com.example.consent5;

import com.androidKmi.KmiApi;

public class KmiPlugin {

	final KmiApi kapi = new KmiApi();

		public Boolean setConnect(String ip, int port) {
			return kapi.kmsConnect(ip, port);
		}

		public Boolean setDisconnect() {
			return kapi.kmsDisconnect();
		}

		public String getKeyAndCert(String id) {
			return kapi.GetKeyAndCert(id);
		}

		public Boolean LocalDelKeyAndCert(String dn) {
			return kapi.LocalDelKeyAndCert(dn);
	}

	public String Error_Msg() {
		return kapi.errorMsg();
	}

	public Boolean CertBatchDel(String dnsuffix) {
		// CertBatchDel("ou=테스트지점,ou=테스트회사,ou=테스트업종,o=SignKorea,c=KR");
		return kapi.CertBatchDel(dnsuffix);
	}
	public String testMethod(){
		return "hi";
	}


}
