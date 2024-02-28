import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';


class VoiceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '1';
  bool _isListening = false;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    setState(() {
      _isListening = true; // Set the listening flag to true
    });

    await _speechToText.listen(
      onResult: _onSpeechResult,
      onSoundLevelChange: (level) {
        // You can use this callback to get the sound level during speech
        print('Sound Level: $level');
      },
    );

    setState(() {
      _isListening = false; // Set the listening flag to false when done
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false; // Set the listening flag to false
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      print('결과 도출');
      _lastWords = result.recognizedWords;
      print('결과 : $_lastWords');
      textController.text = _lastWords.split(' ')[0]; // Set the text field value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _isListening
                      ? 'Listening...' // Display this text when listening
                      : _speechToText.isListening
                      ? '$_lastWords'
                      : _speechEnabled
                      ? 'Tap the microphone to start listening...'
                      : 'Speech not available',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Transcription',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
          _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(
            _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
