import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timer_button/timer_button.dart';
import 'package:uuid/uuid.dart';
import 'package:video/home_page.dart';
import 'package:video/widget/textBox.dart';

class OtpVerify extends StatelessWidget {
  OtpVerify({super.key, required this.verificationId, required this.number, this.resendToken});
  final String verificationId;
  final String number;
  final int ? resendToken;
  final db = FirebaseFirestore.instance.collection("users");
  final TextEditingController controller = TextEditingController();
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
                  TimerButton.builder(builder: (context,timeLeft){
                    return const Text("resend?");
                  }, onPressed: (){
                    resend(resendToken);

                  }, timeOutInSeconds: 10)
                ],
              ),
              const SizedBox(height: 15,),
              ElevatedButton(onPressed: ()async{
                try{
                  PhoneAuthCredential credential = await
                  PhoneAuthProvider.credential(
                      verificationId: verificationId,
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
                          "phoneNumber": number,

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
  Future<void> resend(int? resendTokens) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        verificationCompleted: (PhoneAuthCredential credential){},
        verificationFailed: (FirebaseAuthException ex){},
        codeSent: (String verificationId, int? resendToken){

        },
        codeAutoRetrievalTimeout: (String verificationID){},
        phoneNumber: number);

    }


}

