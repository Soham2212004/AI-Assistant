import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI-Assistant App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
      routes: {
        '/updateProfile': (context) =>
            UpdateProfileScreen(name: '', gender: '', imageFile: null),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  String userName = 'User Name';
  String userGender = '';
  File? userProfileImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'User Name';
      userGender = prefs.getString('userGender') ?? '';
      String? imagePath = prefs.getString('userProfileImage');
      if (imagePath != null) {
        userProfileImage = File(imagePath);
      }
    });
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  Future<void> _updateProfile(String name, String gender, File? image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userGender', gender);
    if (image != null) {
      await prefs.setString('userProfileImage', image.path);
    }
    setState(() {
      userName = name;
      userGender = gender;
      userProfileImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-Assistant App'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleTheme,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Center(
        child: PageView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildPageItem(context, 'Chat Bot', 'assets/chatbot.jpeg', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            }),
            // _buildPageItem(
            //     context, 'Personal Interviewer', 'assets/interview.jpeg', () {
            //   Navigator.of(context).push(
            //     MaterialPageRoute(
            //         builder: (context) => const PersonalAIInterviewerScreen()),
            //   );
            // }),
            // _buildPageItem(context, 'Voice-to-Voice', 'assets/voice.jpeg', () {
            //   Navigator.of(context).push(
            //     MaterialPageRoute(builder: (context) => VoiceScreen()),
            //   );
            // }),
            _buildPageItem(context, 'Code Explainer', 'assets/code.jpeg', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CodeExplainer()),
              );
            }),
            _buildPageItem(
                context, 'AI Voice-Based Note Taking', 'assets/note.jpeg', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => VoiceNoteScreen()),
              );
            }),
            _buildPageItem(context, 'AI Virtual Personal Assistant',
                'assets/assistent.jpeg', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Assistant()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            accountName: Text(userName),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundImage: userProfileImage != null
                  ? FileImage(userProfileImage!)
                  : AssetImage('assets/profile_placeholder.png')
                      as ImageProvider,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              _showTransparentMessage(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.developer_mode),
            title: Text('Developer'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DeveloperScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Feedback'),
            onTap: () {
              Navigator.pushNamed(context, '/feedback');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Update Profile'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProfileScreen(
                    name: userName,
                    gender: userGender,
                    imageFile: userProfileImage,
                  ),
                ),
              );
              if (result != null) {
                final profileData = result as Map<String, dynamic>;
                _updateProfile(profileData['name'], profileData['gender'],
                    profileData['image']);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageItem(BuildContext context, String label, String assetPath,
      VoidCallback onTap) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(assetPath),
            ),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

void _showTransparentMessage(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            bottom: 25.0, // Adjust to move it higher or lower from the bottom
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                'Version: v1',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class DeveloperScreen extends StatelessWidget {
  final String developerImage =
      'assets/s.jpg'; // Replace with the actual path to your image
  final String developerName = 'Soham Soni';

  final String githubUrl = 'https://github.com/Soham2212004';
  final String linkedinUrl =
      'https://www.linkedin.com/in/soham-soni-2342b4239/';
  final String credlyUrl = 'https://www.credly.com/users/soni-soham';
  final String instagramUrl = 'https://www.instagram.com/_soham_soni_';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Developer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80.0,
              backgroundImage: AssetImage(developerImage),
            ),
            SizedBox(height: 20.0),
            Text(
              developerName,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _launchURL(githubUrl),
                  child: Image.asset(
                    'assets/github.png', // Replace with your GitHub image path
                    width: 40,
                    height: 40,
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Image.asset(
                    'assets/linkedin.png', // Replace with your LinkedIn icon path
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => _launchURL(linkedinUrl),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Image.asset(
                    'assets/credly.png', // Replace with your Credly icon path
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => _launchURL(credlyUrl),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Image.asset(
                    'assets/instagram.png', // Replace with your Instagram icon path
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => _launchURL(instagramUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class UpdateProfileScreen extends StatefulWidget {
  final String name;
  final String gender;
  final File? imageFile;

  const UpdateProfileScreen({
    Key? key,
    required this.name,
    required this.gender,
    this.imageFile,
  }) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  Uint8List? _profileImageData;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _genderController.text = widget.gender;
    _loadImage();
  }

  void _loadImage() async {
    if (widget.imageFile != null) {
      _profileImageData = await widget.imageFile!.readAsBytes();
      setState(() {
        _imageFile = widget.imageFile;
      });
    }
  }

  Future<void> _pickImage(ImageSource imageType) async {
    try {
      final photo = await _picker.pickImage(source: imageType);
      if (photo == null) return; // Handle cancel or null case
      final tempImage = File(photo.path);
      setState(() {
        _imageFile = tempImage;
        _profileImageData = tempImage.readAsBytesSync();
      });
      Get.back();
    } catch (error) {
      debugPrint(error.toString());
      // Handle error case
    }
  }

  void _saveProfile() {
    Navigator.pop(context, {
      'name': _nameController.text,
      'gender': _genderController.text,
      'image': _imageFile,
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Container(
            color: Colors.white,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Pick Image From",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: const Text("CAMERA"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text("GALLERY"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("CANCEL"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageData != null
                        ? MemoryImage(_profileImageData!)
                        : AssetImage('assets/profile_placeholder.png')
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _genderController,
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// Chat App


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _userInput = TextEditingController();
  static const apiKey = "";

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Message> _messages = [];
  bool _isListening = false;
  String _speechResult = "";
  String _previousRecognizedWords = "";

  Future<void> sendMessage() async {
    final message = _userInput.text;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear(); // Clear the input field after sending message
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _messages.add(Message(
        isUser: false,
        message: response.text ?? "",
        date: DateTime.now(),
        isCode: response.text != null && response.text!.startsWith('```') && response.text!.endsWith('```')
      ));
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Copied to clipboard'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Bot'),
      ),
      body: Container(
        color: Colors.black, // Set background color directly on Container
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return MessageWidget(
                    isUser: message.isUser,
                    message: message.message,
                    date: DateFormat('HH:mm').format(message.date),
                    isCode: message.isCode,
                    onCopy: () => _copyToClipboard(message.message),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: TextStyle(
                          color: Colors.white), // Adjust input text color
                      controller: _userInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelText: 'Enter Your Message',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.all(12),
                    iconSize: 30,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(CircleBorder()),
                    ),
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  final bool isCode;

  Message({required this.isUser, required this.message, required this.date, this.isCode = false});
}

class MessageWidget extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  final bool isCode;
  final VoidCallback onCopy;

  const MessageWidget({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
    required this.isCode,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 10,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.black : Colors.grey,
        borderRadius: BorderRadius.circular(25).copyWith(
          bottomLeft: Radius.circular(isUser ? 25 : 0),
          bottomRight: Radius.circular(isUser ? 0 : 25),
        ),
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onCopy,
                icon: Icon(Icons.copy, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  message.replaceAll('```', ''),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: isCode ? 'monospace' : null,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(date, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class Response {
  final String? text;

  Response({this.text});
}

// AI-INTERVIEWER APP

class PersonalAIInterviewerScreen extends StatefulWidget {
  const PersonalAIInterviewerScreen({Key? key}) : super(key: key);

  @override
  State<PersonalAIInterviewerScreen> createState() =>
      _PersonalAIInterviewerScreenState();
}

class _PersonalAIInterviewerScreenState
    extends State<PersonalAIInterviewerScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _fieldController = TextEditingController();
  TextEditingController _answerController = TextEditingController();
  bool _nameEntered = false;
  bool _fieldEntered = false;
  bool _isListening = false;
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  final model = GenerativeModel(
      model: 'gemini-pro', apiKey: "");
  List<String> _interviewQuestions = [];
  int _currentQuestionIndex = 0;
  String _userResponse = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    checkPermissions(); // Check microphone permissions on app start
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('onStatus: $status');
        if (status == 'done' && _isListening) {
          // Automatically process the answer when the user stops speaking
          _submitResponse();
        }
      },
      onError: (errorNotification) => print('onError: $errorNotification'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _userResponse = result
                .recognizedWords; // Capture the recognized words as the user response
          });
        },
        listenFor: Duration(seconds: 30), // Listen for a longer period
        pauseFor: Duration(seconds: 5), // Allow longer pauses
      );
    }
  }

  void stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void checkPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      // Permission granted, proceed with audio input
    } else {
      // Permission denied, handle accordingly (show message, etc.)
    }
  }

  void _startInterview() async {
    // Send the user's name and field to the Gemini API to generate interview questions
    // This is a placeholder, replace with actual Gemini API call
    final response = await model.generateContent([
      Content.text(
          "Generate interview questions for a ${_fieldController.text} candidate")
    ]);

    setState(() {
      _interviewQuestions = response.text!.split('\n'); // Example questions
      _currentQuestionIndex = 0;
      _askNextQuestion();
    });
  }

  void _askNextQuestion() async {
    if (_currentQuestionIndex < _interviewQuestions.length) {
      await _speak(_interviewQuestions[_currentQuestionIndex]);
      await Future.delayed(Duration(seconds: 1)); // Delay for speaking
      await _speak("Now your turn.");
      startListening(); // Start listening after AI finishes speaking
    }
  }

  void _submitResponse() async {
    stopListening(); // Stop listening after capturing the user's response

    // Send the user's response to the Gemini API for evaluation
    // This is a placeholder, replace with actual Gemini API call
    final response = await model.generateContent(
        [Content.text("Evaluate this response: $_userResponse")]);

    setState(() {
      _currentQuestionIndex++;
      _userResponse = ""; // Clear user response for next question
      if (_currentQuestionIndex < _interviewQuestions.length) {
        _askNextQuestion(); // Ask the next question if there are more questions
      } else {
        _endInterview(); // End the interview if all questions are asked
      }
    });
  }

  void _endInterview() {
    // Handle the end of the interview, display results, feedback, etc.
    // This is a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Interview Completed"),
        content: Text(
            "Thank you for your responses. Your interview has been completed."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _greetUser() async {
    String name = _nameController.text;
    await _speak(
        "Welcome $name, Today I'm your virtual AI interviewer. Please tell me your field of study.");
    setState(() {
      _nameEntered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal AI Interviewer'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_nameEntered)
                Column(
                  children: [
                    Text("Please enter your name:"),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: 'Name'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _greetUser();
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              if (_nameEntered && !_fieldEntered)
                Column(
                  children: [
                    Text(
                        "Hello ${_nameController.text}! Please enter your field of study:"),
                    TextField(
                      controller: _fieldController,
                      decoration: InputDecoration(hintText: 'Field of study'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _fieldEntered = true;
                        });
                        _startInterview();
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              if (_nameEntered && _fieldEntered)
                Column(
                  children: [
                    Text(_interviewQuestions.isNotEmpty
                        ? _interviewQuestions[_currentQuestionIndex]
                        : " "),
                    SizedBox(height: 20),
                    Text("Your Answer:"),
                    Text(_userResponse),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? stopListening : startListening,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}

// VOICE-TO-VOICE APP

class VoiceScreen extends StatefulWidget {
  @override
  _VoiceScreenState createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  late FlutterTts flutterTts;
  String _voiceOption = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
          onResult: (val) => setState(() {
                _text = val.recognizedWords;
              }));
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _submit() {
    _stopListening();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Voice Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _voiceOption = 'male';
                  Navigator.pop(context);
                  _convertTextToSpeech();
                },
                child: Text('Male Voice'),
              ),
              ElevatedButton(
                onPressed: () {
                  _voiceOption = 'female';
                  Navigator.pop(context);
                  _convertTextToSpeech();
                },
                child: Text('Female Voice'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _convertTextToSpeech() async {
    String voiceName;
    if (_voiceOption == 'male') {
      voiceName = "en-us-x-sfg#male_1-local";
    } else if (_voiceOption == 'female') {
      voiceName = "en-gb-x-srv#female_1-local";
    } else {
      print("Invalid voice option");
      return;
    }

    await flutterTts.setVoice({"name": voiceName, "locale": "en-US"});

    flutterTts.setStartHandler(() {
      setState(() {
        // Handle TTS engine started
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        // Handle TTS complete
      });
    });

    flutterTts.setErrorHandler((msg) {
      print("Error: $msg");
      setState(() {
        // Handle TTS error
      });
    });

    await flutterTts.speak(_text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice to Voice Conversion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_text, style: TextStyle(fontSize: 24.0)),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Icon(_isListening ? Icons.mic : Icons.mic_off),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// CODE EXPLAINER APP
class CodeExplainer extends StatefulWidget {
  @override
  _CodeExplainerState createState() => _CodeExplainerState();
}

class _CodeExplainerState extends State<CodeExplainer> {
  TextEditingController _userInput = TextEditingController();
  static const apiKey =
      ""; // Replace with your Gemini API key

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  String _outputMessage = '';
  bool _isLoading = false;

  Future<void> explainCode() async {
    final code = _userInput.text;
    final message =
        "Explain This Code Line By Line and the output should be starts like : langauge- , Explanation- \n$code"; // Prepare message

    setState(() {
      _isLoading = true; // Set loading state to true
      _userInput.clear(); // Clear the input field after sending the code
    });

    final content = [Content.text(message)]; // Send message to API
    final response = await model.generateContent(content);

    setState(() {
      _isLoading = false; // Set loading state to false
      _outputMessage = response.text ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Code Explainer'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0), // Add padding around the container
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align to the top
            children: [
              TextField(
                controller: _userInput,
                maxLines: 8, // Allow multiple lines for input
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your code here...',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: explainCode,
                child: Text('Explain Code'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(), // Loading spinner
                        SizedBox(height: 10),
                        Text(
                          'Fetching The Output Please Wait ...',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Container(
                        padding:
                            EdgeInsets.all(16.0), // Add padding around the text
                        child: Text(
                          _outputMessage,
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class Assistant extends StatefulWidget {
  @override
  _AssistantState createState() => _AssistantState();
}

class _AssistantState extends State<Assistant> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts; // TTS instance
  bool _isListening = false;
  String _callName = '';
  bool _isLoading = false;
  String _messageContent = '';
  bool _awaitingMessage = false;
  Contact? _contactForMessage;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeTts(); // Initialize TTS
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.75);
    } catch (e) {
      print('Failed to initialize TTS: $e');
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
  }

  Future<List<Contact>> _fetchContacts() async {
    if (!(await Permission.contacts.request().isGranted)) {
      return [];
    }
    Iterable<Contact> contacts = await ContactsService.getContacts();
    return contacts.toList();
  }

  Future<void> _makeCall(Contact contact) async {
    setState(() {
      _isLoading = true;
    });

    if (await Permission.phone.request().isGranted) {
      if (contact.phones!.isNotEmpty) {
        String phoneNumber = contact.phones!.first.value!;
        const platform = MethodChannel('com.example.direct_call/call');
        try {
          await platform.invokeMethod('makeCall', {'number': phoneNumber});
        } catch (e) {
          print('Error making call: $e');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error Making Call'),
                content: const Text('An error occurred while making the call.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('No Phone Number'),
              content: Text('This contact does not have a phone number.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: null,
                ),
              ],
            );
          },
        );
      }
    } else {
      print('Phone permission not granted');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sendMessage(Contact contact, String message) async {
    if (contact.phones!.isNotEmpty) {
      String phoneNumber = contact.phones!.first.value!;
      final Uri whatsappUri = Uri(
        scheme: 'https',
        host: 'api.whatsapp.com',
        path: 'send',
        queryParameters: {
          'phone': phoneNumber,
          'text': message,
        },
      );

      if (await canLaunch(whatsappUri.toString())) {
        await launch(whatsappUri.toString());
      } else {
        print('Could not launch WhatsApp');
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('No Phone Number'),
            content: Text('This contact does not have a phone number.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: null,
              ),
            ],
          );
        },
      );
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            if (!_awaitingMessage) {
              _callName = val.recognizedWords.trim();
              if (_callName.toLowerCase() == 'hey dev wake up') {
                await _speak('Yes, sir. How can I assist you?');
              } else if (_callName.toLowerCase().startsWith('call ')) {
                _callName = _callName.replaceAll('call ', '').trim();
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _isListening = false;
                  _speech.stop();
                  await _speak(
                      'Please wait, sir. I\'m making a call to $_callName.');
                  _searchAndCall(); // Directly call _searchAndCall(), which is void
                }
              } else if (_callName.toLowerCase().startsWith('message ')) {
                _callName = _callName.replaceAll('message ', '').trim();
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _isListening = false;
                  _speech.stop();
                  await _speak(
                      'Please wait. I\'m preparing a message through WhatsApp.');
                  _searchAndPrepareMessage(); // Directly call _searchAndPrepareMessage(), which is void
                }
              }
            } else {
              _messageContent = val.recognizedWords.trim();
              if (val.hasConfidenceRating && val.confidence > 0) {
                _isListening = false;
                _speech.stop();
                _sendMessageToContact();
              }
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _searchAndCall() async {
    setState(() {
      _isLoading = true;
    });

    List<Contact> contacts = await _fetchContacts();
    Contact? selectedContact;
    for (Contact contact in contacts) {
      String givenName = contact.givenName?.trim()?.toLowerCase() ?? '';
      String familyName = contact.familyName?.trim()?.toLowerCase() ?? '';
      String displayName = contact.displayName?.trim()?.toLowerCase() ?? '';
      if (givenName.contains(_callName.toLowerCase()) ||
          familyName.contains(_callName.toLowerCase()) ||
          displayName.contains(_callName.toLowerCase())) {
        selectedContact = contact;
        break;
      }
    }

    if (selectedContact != null) {
      await _makeCall(selectedContact);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Contact Not Found'),
            content: Text('No contact found with the name "$_callName".'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _searchAndPrepareMessage() async {
    setState(() {
      _isLoading = true;
    });

    List<Contact> contacts = await _fetchContacts();
    Contact? selectedContact;
    for (Contact contact in contacts) {
      String givenName = contact.givenName?.trim()?.toLowerCase() ?? '';
      String familyName = contact.familyName?.trim()?.toLowerCase() ?? '';
      String displayName = contact.displayName?.trim()?.toLowerCase() ?? '';
      if (givenName.contains(_callName.toLowerCase()) ||
          familyName.contains(_callName.toLowerCase()) ||
          displayName.contains(_callName.toLowerCase())) {
        selectedContact = contact;
        break;
      }
    }

    if (selectedContact != null) {
      _contactForMessage = selectedContact;
      setState(() {
        _isLoading = false;
        _awaitingMessage = true;
      });
      _listenForMessage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Contact Not Found'),
            content: Text('No contact found with the name "$_callName".'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _listenForMessage() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) async {
          _messageContent = val.recognizedWords.trim();
          if (val.hasConfidenceRating && val.confidence > 0) {
            _isListening = false;
            _speech.stop();
            _sendMessageToContact();
          }
        },
      );
    }
  }

  Future<void> _sendMessageToContact() async {
    if (_contactForMessage != null) {
      await _sendMessage(_contactForMessage!, _messageContent);
      await _speak(
          'Your message has been sent to ${_contactForMessage!.displayName}.');
    }
    setState(() {
      _awaitingMessage = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Based Chatbot'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                if (!_isListening) {
                  setState(() => _isLoading = true);
                  await _speak('Welcome! Click again to speak.');
                  _listen();
                }
              },
              child: Text(_isListening ? 'Listening...' : 'Press to Speak'),
            ),
            SizedBox(height: 20),
            _isLoading ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
    );
  }
}


class VoiceNoteScreen extends StatefulWidget {
  @override
  _VoiceNoteScreenState createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> {
  final TextEditingController _noteController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _transcribedText = '';
  String _correctedText = '';
  bool _showGeneratePdfButton = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (val) => setState(() {
            _transcribedText = val.recognizedWords;
            _noteController.text = _transcribedText;
          }));
    }
  }

  Future<void> _stopListening() async {
    setState(() => _isListening = false);
    _speech.stop();
    await Future.delayed(Duration(milliseconds: 500)); // Optional: Add a small delay
    _processText();
  }

  void _processText() {
    // Here you can integrate the Gemini API or any other text processing logic
    setState(() {
      _correctedText = _transcribedText; // Assuming the text is corrected for now
      _noteController.text = _correctedText;
      _showGeneratePdfButton = true;
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(_correctedText),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
        '${output.path}/note_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('PDF generated: ${file.path}'),
    ));

    // Open the generated PDF
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Note')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.yellow[100],
              child: TextField(
                controller: _noteController,
                maxLines: null,
                decoration: InputDecoration.collapsed(
                    hintText: 'Your notes will appear here...'),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                onPressed: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
              ),
              if (_showGeneratePdfButton)
                ElevatedButton(
                  onPressed: _generatePdf,
                  child: Text('Generate PDF'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
