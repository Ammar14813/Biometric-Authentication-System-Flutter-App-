
import 'package:final_project/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  bool codeSent = false;
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0),
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(hintText: 'Enter phone number'),
                    onSaved: (val) {
                      setState(() {
                        phoneController.text = val;
                      });
                    },
                  )),

              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0),
                  child: ElevatedButton(
                      child: Center(
                          child: codeSent ? Text('Login') : Text('Verify')),
                      onPressed: () {
                        print('ok');
                        _submitPhoneNumber(phoneController.text);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
                      }))
            ],
          )),
    );
  }
  Future<List> _submitPhoneNumber(String phoneNumber) async {
    /// NOTE: Either append your phone number country code or add in the code itself
    AuthCredential _phoneAuthCredential=AuthCredential(providerId: '',signInMethod: '');
    String _verifectionId='';
    print(phoneNumber);

    /// The below functions are the callbacks, separated so as to make code more readable
    void verificationCompleted(AuthCredential phoneAuthCredential) async {
      print('verificationCompleted');
      _phoneAuthCredential = phoneAuthCredential;
      print(phoneAuthCredential);
      await FirebaseAuth.instance
          .signInWithCredential(_phoneAuthCredential)
          .then((UserCredential authRes) async{
        print(authRes.user.toString());
      });
    }

    void verificationFailed(Exception error) {
      print(error.toString());
    }

    void codeSent(dynamic verificationId, dynamic code) {
      _verifectionId = verificationId;
      print('تم ارسال رمز التحقق');
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      print('codeAutoRetrievalTimeout');
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>VerfectionScreen(verificationId)));
    }


    await FirebaseAuth.instance.verifyPhoneNumber(
      /// Make sure to prefix with your country code
      phoneNumber: phoneNumber,

      /// `seconds` didn't work. The underlying implementation code only reads in `milliseconds`
      timeout: Duration(milliseconds: 1000),

      /// If the SIM (with phoneNumber) is in the current device this function is called.
      /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
      verificationCompleted: verificationCompleted,

      /// Called when the verification is failed
      verificationFailed: verificationFailed,

      /// This is called after the OTP is sent. Gives a `verificationId` and `code`
      codeSent: codeSent,

      /// After automatic code retrival `tmeout` this function is called
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
    return [_phoneAuthCredential , _verifectionId]; // All the callbacks are above
  }
}
