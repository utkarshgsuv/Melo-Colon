import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:semicolon/main_interface.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class WavePage extends StatefulWidget {
  final String? id_token;
  const WavePage({super.key, required this.id_token});

  @override
  _WavePageState createState() => _WavePageState();
}

class _WavePageState extends State<WavePage> with TickerProviderStateMixin {
  String mood = "neutral";
  late FlutterTts _flutterTts;
  bool isFirstRecordingDone = false;

  late AnimationController _rippleController;
  bool isListening = false;
  bool isAssistantSpeaking = false;
  late stt.SpeechToText _speech;
  String recognizedText = "";

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  late String _filePath;

  Future<void> _setupTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.1);
    try {
      await _flutterTts
          .setVoice({"name": "en-US-Wavenet-F", "locale": "en-US"});
    } catch (e) {
      print("Error setting voice: $e");
      await _flutterTts
          .setVoice({"name": "en-us-x-sfg-local", "locale": "en-US"});
    }
  }

  Future<void> _initRecorder() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      print("❌ Microphone permission denied!");
      return;
    }

    try {
      await _recorder.openRecorder();
      _recorder.setSubscriptionDuration(Duration(milliseconds: 500));
      print("✅ FlutterSoundRecorder initialized successfully");
    } catch (e) {
      print("❌ Error initializing FlutterSoundRecorder: $e");
    }
  }

  Future<void> startListening() async {
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/recorded_audio.wav';

    try {
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
        _filePath = filePath;
        isListening = true;
      });
      print("🎙 Recording started at: $filePath");
    } catch (e) {
      print("❌ Error starting recorder: $e");
      setState(() {
        _isRecording = false;
        isListening = false;
      });
    }
  }

  Future<void> stopListening() async {
    try {
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        isListening = false;
      });
      print("🛑 Recording stopped. Saved to: $_filePath");
    } catch (e) {
      print("❌ Error stopping recorder: $e");
      setState(() {
        _isRecording = false;
        isListening = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _flutterTts = FlutterTts();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _speech = stt.SpeechToText();
    _checkMicrophonePermission();

    _speech.statusListener = (status) {
      print("🎤 Speech Status: $status");
      if (status == "notListening" && isListening && isFirstRecordingDone) {
        print("🔄 Speech recognition stopped. Setting isListening to false.");
        setState(() {
          isListening = false;
        });
      }
    };

    _setupTTS();
  }

  Future<void> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        print("❌ Microphone permission denied!");
      }
    }
  }

  Future<void> _speak(String text) async {
    print("🗣 Speaking: $text");
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.1);
    try {
      await _flutterTts
          .setVoice({"name": "en-US-Wavenet-F", "locale": "en-US"});
    } catch (e) {
      print("Error setting voice: $e");
      await _flutterTts
          .setVoice({"name": "en-us-x-sfg-local", "locale": "en-US"});
    }
    var result = await _flutterTts.speak(text);
    print("🛠 TTS Result: $result");
  }

  Future<void> sendAudioToAPI(File audioFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://colonemotion-production.up.railway.app/predict'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
      ),
    );

    try {
      var response = await request.send().timeout(Duration(seconds: 30));
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        mood = jsonResponse['mood'];
        print("Predicted Mood: ${jsonResponse['mood']}");
      } else {
        print("Error: ${response.statusCode}");
        mood = "neutral";
      }
    } catch (e) {
      print("Exception: $e");
      mood = "neutral";
    }
  }

  Future<void> sendDataToAPI(String text) async {
    final String apiUrl = "https://colon-nsxy.onrender.com/hey";
    final Map<String, dynamic> requestBody = {
      "query": text,
      "mood": mood,
      "id_token": widget.id_token,
    };

    print("📡 Sending to API: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String assistantResponse = responseData["summary"] ?? "";
        print("✅ Raw API Response: $responseData"); // Log the full response
        print("✅ Extracted Summary: $assistantResponse");

        // Filter out the mood-related text from the assistantResponse
        String filteredResponse = assistantResponse;
        if (assistantResponse.contains("**Mood**:") ||
            assistantResponse.contains("Mood:")) {
          // Remove the mood part (e.g., "- **Mood**: happy")
          filteredResponse = assistantResponse.replaceAll(
              RegExp(r'-?\s*\*\*Mood\*\*:\s*[a-zA-Z]+\s*'), '');
          filteredResponse = filteredResponse.trim();
          print("✅ Filtered Response: $filteredResponse");
        }

        if (filteredResponse.isNotEmpty) {
          await _speak(filteredResponse); // Speak only the filtered response
        } else {
          print("⚠ Filtered API Response is empty!");
        }
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("⚠ Exception: $e");
    }
  }

  void _toggleListening() async {
    print(
        "🎤 _toggleListening triggered! Current state: isListening=$isListening, isFirstRecordingDone=$isFirstRecordingDone");

    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        print("❌ Microphone permission denied!");
        return;
      }
    }

    if (isListening) {
      print("🛑 Stopping listening...");
      if (!isFirstRecordingDone) {
        // First recording: Stop flutter_sound
        await stopListening();
        if (_filePath != null && File(_filePath).existsSync()) {
          File audioFile = File(_filePath);
          await sendAudioToAPI(audioFile);
          print("📡 Sending default text 'hello' to API...");
          await sendDataToAPI("hello");
        } else {
          print("⚠ Recorded file does not exist: $_filePath");
          mood = "neutral";
          await sendDataToAPI("hello");
        }
        setState(() {
          isFirstRecordingDone = true;
          isListening = false;
          isAssistantSpeaking = true;
        });
      } else {
        // Subsequent recordings: Stop speech_to_text
        await _speech.stop();
        setState(() {
          isListening = false;
          isAssistantSpeaking = true;
        });
        print("📝 Final recognized text: $recognizedText");
        if (recognizedText.isNotEmpty) {
          print("📡 Sending recognized text to API...");
          await sendDataToAPI(recognizedText);
        } else {
          print("⚠ No text recognized, skipping API call.");
        }
      }
    } else {
      print("🎙 Starting listening...");
      if (!isFirstRecordingDone) {
        // First recording: Start flutter_sound
        await startListening();
        Future.delayed(Duration(seconds: 5), () async {
          if (_isRecording) {
            print("⏰ Recording timeout reached, stopping automatically...");
            await stopListening();
            if (_filePath != null && File(_filePath).existsSync()) {
              File audioFile = File(_filePath);
              await sendAudioToAPI(audioFile);
              print("📡 Sending default text 'hello' to API...");
              await sendDataToAPI("hello");
            } else {
              print("⚠ Recorded file does not exist: $_filePath");
              mood = "neutral";
              await sendDataToAPI("hello");
            }
            setState(() {
              isFirstRecordingDone = true;
              isListening = false;
              isAssistantSpeaking = true;
            });
          }
        });
      } else {
        // Subsequent recordings: Start speech_to_text
        bool available = await _speech.initialize(
          onStatus: (status) => print("🎤 Speech Status: $status"),
          onError: (error) {
            print("⚠ Speech Error: $error");
            setState(() {
              isListening = false;
            });
          },
        );

        if (available) {
          setState(() {
            isListening = true;
            isAssistantSpeaking = false;
            recognizedText = "";
          });
          _startSpeechListening();
        } else {
          print("❌ Speech recognition not available");
          setState(() {
            isListening = false;
          });
        }
      }
    }
  }

  void _startSpeechListening() async {
    print("🔄 _startSpeechListening() called...");

    await _flutterTts.stop();

    _speech.listen(
      onResult: (result) {
        setState(() {
          recognizedText = result.recognizedWords;
        });
        print("📝 Recognized: ${result.recognizedWords}");
      },
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
      onSoundLevelChange: (level) {
        print("🎚 Sound Level: $level");
      },
    );

    print("🎙 Speech listening started...");
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _rippleController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color lightBlueListening = const Color(0xFFD3E8E1);
    final Color darkAssistantSpeaking = const Color(0xFF4A635D);
    final Color idleBackground = const Color(0xFFF4F1E1);

    Color backgroundColor;
    if (isListening) {
      backgroundColor = lightBlueListening;
    } else if (isAssistantSpeaking) {
      backgroundColor = darkAssistantSpeaking;
    } else {
      backgroundColor = idleBackground;
    }

    final Color buttonColor = const Color(0xFF8FB8A8);
    final Color iconColor = Colors.white;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isListening
                      ? "Listening to you..."
                      : isAssistantSpeaking
                          ? "Your Homie's got something to say!"
                          : "Your Best Friend!",
                  key: ValueKey<String>(
                      isListening.toString() + isAssistantSpeaking.toString()),
                  style: GoogleFonts.merriweather(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isAssistantSpeaking
                        ? buttonColor
                        : const Color(0xFF4A635D),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _rippleController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: RipplePainter(_rippleController.value,
                            isListening, isAssistantSpeaking),
                        child: Container(
                          width: 250,
                          height: 250,
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: _toggleListening,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: buttonColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: buttonColor.withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.waves,
                                color: iconColor,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _toggleListening,
                      child: Container(
                        width: 70,
                        height: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isListening
                              ? buttonColor.withOpacity(0.7)
                              : buttonColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: buttonColor.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          isListening ? Icons.pause_circle_filled : Icons.mic,
                          color: iconColor,
                          size: 36,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainInterface(),
                          ),
                        );
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: buttonColor.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.home,
                          color: iconColor,
                          size: 36,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final double animationValue;

  RipplePainter(
      this.animationValue, bool isListening, bool isAssistantSpeaking);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue.withOpacity(1 - animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final double radius = size.width * 0.5 * animationValue;
    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
