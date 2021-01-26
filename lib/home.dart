import 'dart:async';
import 'dart:io';
import 'dart:io' as io;

import 'package:audioplayers/audioplayers.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  Home({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File _file;
  Future pickercamera() async{
    final image = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _file = File(image.path);
    });
  }


  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
  }


  @override
  Widget build(BuildContext context) {
    TextStyle theme1 = TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold);
    TextStyle theme2 = TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Azhar Multi-Media OTP System',style: theme1),
          backgroundColor: Colors.white10,
        ),
        body: ListView(
          children: [
            Column(
              children:<Widget> [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text('Verification Code ',style: theme2,),
                          SizedBox(width: 8,),
                          SizedBox(width: 150,
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: InputBorder.none,
                                //enabled: false,
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25,),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Recorder',style: theme2,),
                          ],
                        ),
                      ),
                      SizedBox(width: 5,),
                      Padding(
                        padding: const EdgeInsets.only(left: 35),
                        child: Row(
                          children: [
                            new FlatButton(
                              onPressed: () {
                                switch (_currentStatus) {
                                  case RecordingStatus.Initialized:
                                    {
                                      _start();
                                      break;
                                    }
                                  case RecordingStatus.Recording:
                                    {
                                      _pause();
                                      break;
                                    }
                                  case RecordingStatus.Paused:
                                    {
                                      _resume();
                                      break;
                                    }
                                  case RecordingStatus.Stopped:
                                    {
                                      _init();
                                      break;
                                    }
                                  default:
                                    break;
                                }
                              },
                              child: _buildText(_currentStatus),
                              color: Colors.lightBlue,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            new FlatButton(
                              onPressed:
                              _currentStatus != RecordingStatus.Unset ? _stop : null,
                              child:
                              new Text("Stop", style: TextStyle(color: Colors.white)),
                              color: Colors.blueAccent.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            new FlatButton(
                              onPressed: onPlayAudio,
                              child:
                              new Text("Play", style: TextStyle(color: Colors.white)),
                              color: Colors.blueAccent.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 25,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:<Widget> [
                          Text('Take A Picture ',style: theme2,),
                        ],
                      ),
                      SizedBox(height: 15,),
                      IconButton(
                        icon : Icon(Icons.camera_alt),
                        iconSize: 80,
                        onPressed: pickercamera,
                      ),
                      SizedBox(height: 20,),
                      Container(
                        child : _file == null ?  Text('There Is No Pic') : Image.file(_file,scale: 6,),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
                RaisedButton(
                  child: Text('Verify',style: theme1,),
                  color: Colors.black,
                  onPressed: (){},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _resume() async {
    await _recorder.resume();
    setState(() {});
  }

  _pause() async {
    await _recorder.pause();
    setState(() {});
  }

  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
  }

  Widget _buildText(RecordingStatus status) {
    var text = "";
    switch (_currentStatus) {
      case RecordingStatus.Initialized:
        {
          text = 'Start';
          break;
        }
      case RecordingStatus.Recording:
        {
          text = 'Pause';
          break;
        }
      case RecordingStatus.Paused:
        {
          text = 'Resume';
          break;
        }
      case RecordingStatus.Stopped:
        {
          text = 'Init';
          break;
        }
      default:
        break;
    }
    return Text(text, style: TextStyle(color: Colors.white));
  }

  void onPlayAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(_current.path, isLocal: true);
  }
}
