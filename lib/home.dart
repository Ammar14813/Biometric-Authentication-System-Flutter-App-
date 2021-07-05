import 'dart:async';
import 'dart:io';

import 'package:file/local.dart';
import 'package:final_project/recorder/feature_buttons_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  List<Reference> references;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    TextStyle theme1 = TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold);
    TextStyle theme2 = TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic);

    double sizeX = MediaQuery.of(context).size.width;
    double sizeY = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text('Azhar Multi-Media OTP System',style: theme1),
          backgroundColor: Colors.white10,
        ),
        body: Container(
           width: sizeX,
          child: ListView(
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
                                  enabledBorder:OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
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

                        FeatureButtonsView(
                          onUploadComplete: _onUploadComplete,
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
                  // ignore: deprecated_member_use
                  RaisedButton(
                    child: Text('Verify',style: theme1,),
                    color: Colors.black,
                    onPressed: (){
                      _uploadData(_file);
                      _onUploadComplete();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }

  Future<void> _onUploadComplete() async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    ListResult listResult =
    await firebaseStorage.ref().child('upload-voice-firebase').list();
    setState(() {
      references = listResult.items;
      print(references);
    });
  }

  Future pickercamera() async {
    final image = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      setState(() {
        _file = File(image.path);
      });
      print("Done!");
    } else {
      print("no image selected");
    }
  }

  void _uploadData(File image) async {
    //try to upload the image
    try {
      print("1");
      //make a reference have two child the first one for file name, second for image name
      final ref =
      FirebaseStorage.instance.ref().child('clint_images').child('1.jpg');
      //upload the image into the server
      print("2");
      await ref.putFile(image);
      print("3");
      setState(() {
        _isLoading = false;
        print("Image uploaded successfully");
      });
    }
    //if an error occurred try to know the reason of error and handle it
    catch (e) {
      print(e);
    }
  }
}
