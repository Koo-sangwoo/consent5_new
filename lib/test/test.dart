import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class test extends StatelessWidget {
  final KmiPlugin _kmiPlugin = KmiPlugin();
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('KmiPlugin Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Example: Connecting
              bool? connectResult = await _kmiPlugin.setConnect('your_ip', 1234);
              print('Connect Result: $connectResult');

              // Add other method calls as needed for testing
            },
            child: Text('Connect'),
          ),
        ),
      ),
    );
  }
}

class KmiPlugin {
  static const MethodChannel _channel = const MethodChannel('com.example.consent5/kmiPlugin');

  Future<bool?> setConnect(String ip, int port) async {
    try {
      return await _channel.invokeMethod('setConnect', {'ip': ip, 'port': port});
    } catch (e) {
      print('Error invoking setConnect method: $e');
      return null;
    }
  }

  Future<bool?> setDisconnect() async {
    try {
      return await _channel.invokeMethod('setDisconnect');
    } catch (e) {
      print('Error invoking setDisconnect method: $e');
      return null;
    }
  }

  Future<String?> getKeyAndCert(String id) async {
    try {
      return await _channel.invokeMethod('getKeyAndCert', {'id': id});
    } catch (e) {
      print('Error invoking getKeyAndCert method: $e');
      return null;
    }
  }

  Future<bool?> localDelKeyAndCert(String dn) async {
    try {
      return await _channel.invokeMethod('localDelKeyAndCert', {'dn': dn});
    } catch (e) {
      print('Error invoking localDelKeyAndCert method: $e');
      return null;
    }
  }

  Future<String?> errorMsg() async {
    try {
      return await _channel.invokeMethod('errorMsg');
    } catch (e) {
      print('Error invoking errorMsg method: $e');
      return null;
    }
  }

  Future<bool?> certBatchDel(String dnsuffix) async {
    try {
      return await _channel.invokeMethod('certBatchDel', {'dnsuffix': dnsuffix});
    } catch (e) {
      print('Error invoking certBatchDel method: $e');
      return null;
    }
  }
}
