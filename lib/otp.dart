import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timer_button/timer_button.dart';
import 'package:uuid/uuid.dart';
import 'package:video/home_page.dart';
import 'package:video/widget/textBox.dart';

class OtpVerify extends StatefulWidget {
  OtpVerify({super.key, required this.verificationId, required this.number, this.resendToken});
  String verificationId;
  final String number;
  int ? resendToken;

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final db = FirebaseFirestore.instance.collection("users");

  final TextEditingController controller = TextEditingController();
  late Timer _timer;
  int _start = 30;
  bool _canResend = false;
  @override
  void initState() {
    // TODO: implement initState
    startTimer();
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    _timer.cancel();
    super.dispose();
  }
  void startTimer() {
    _start = 30;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void resendOtp() {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.number,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException ex) {
        log('Failed to resend OTP: ${ex.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend OTP: ${ex.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          widget.verificationId = verificationId;
          widget.resendToken = resendToken;
          startTimer();
        });
      },
      forceResendingToken: widget.resendToken,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 11,bottom:20),
              child: SizedBox(
                height: 110,
                width: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset("assets/image/logo.jpg"),
                ),
              ),
            ),
              const SizedBox(height: 30,),
              SizedBox(
                  width: 350,
                  child: TextBoxCustom(
                    inputType: TextInputType.number,
                    controller: controller,
                    hint: "Enter OTP",
                  )),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Did not get otp,"),
                  const SizedBox(width: 7,),
                  GestureDetector(
                    onTap: _canResend ? resendOtp : null,
                    child: Text(
                      _canResend ? "Resend" : "Resend in $_start seconds",
                      style: TextStyle(
                        color: _canResend ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15,),
              ElevatedButton(onPressed: ()async{
                try{
                  PhoneAuthCredential credential = await
                  PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: controller.text.toString());
                  FirebaseAuth.instance.signInWithCredential(credential).then((value)async{
                    final auth = FirebaseAuth.instance;
                    final user = auth.currentUser;
                    final checks = await db.doc(user!.uid);
                    final check  = await checks.get();
                    if(check.exists)
                      {
                        if (!context.mounted) return;
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  HomePage()));
                      }
                    else
                      {
                        final uuid = Uuid();
                        final userName = uuid.v1();
                        await user.updateDisplayName(userName);
                        final data = <String, dynamic>{
                          "Name" : userName,
                          "creation Time":FieldValue.serverTimestamp(),
                          "userID": user.uid,
                          "phoneNumber": widget.number,

                        };
                        checks.set(data);
                        if (!context.mounted) return;
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  HomePage()));

                      }


                  });
                }catch(e){
                  log(e.toString());
                }
              }, child: const Text("Get Started"))

            ]
        ),
      ),
    );
  }



}

